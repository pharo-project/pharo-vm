Class {
	#name : 'SLDeadCodeElimination',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator',
		'workList',
		'markedElements',
		'markedElementsAsExpression',
		'currentMethod',
		'variableOccurences',
		'variableDefinitions',
		'variableDefiningStmtList',
		'localVariableScope'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addDefiningStatementFor: aTVariableNode [

	| definingStmt varName |
	varName := aTVariableNode name.
	localVariableScope do: [ :assoc |
		assoc value do: [ :localName |
			localName = varName ifTrue: [ definingStmt := assoc key ] ] ].
	variableDefiningStmtList at: aTVariableNode put: definingStmt.
	self addOcurrencesFor: varName in: definingStmt
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addDefinitionsFor: anAssignmentNode [

	| varName |
	varName := anAssignmentNode variable name.
	anAssignmentNode isSelfAssign
		ifTrue: [ ^ self ].
	variableDefinitions
		at: varName
		ifPresent: [
			variableDefinitions
				at: varName
				put: ((variableDefinitions at: varName)
						 add: anAssignmentNode;
						 yourself) ]
		ifAbsent: [
			variableDefinitions at: varName put: (OrderedCollection new
					 add: anAssignmentNode;
					 yourself) ]
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addLocalDefinitionFor: aStmtListNode [

	self addStmtListLocalsAndSuppressRedundantDeclarationIn:
		aStmtListNode.

	localVariableScope push: aStmtListNode -> aStmtListNode locals.
	aStmtListNode statements do: [ :node |
		node isStatementList
			ifTrue: [ self addLocalDefinitionFor: node ]
			ifFalse: [ self findAndHandleStatementsVariablesIn: node ] ].
	localVariableScope pop
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addOcurrencesFor: varName in: definingStmt [

	self addOcurrencesFor: varName in: definingStmt init: false
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addOcurrencesFor: varName in: definingStmt init: aBoolean [

	| init |
	init := aBoolean
		        ifTrue: [ 0 ]
		        ifFalse: [ 1 ].
	variableOccurences
		at: varName
		ifPresent: [
			| subDict |
			subDict := variableOccurences at: varName.
			subDict
				at: definingStmt
				ifPresent: [
				subDict at: definingStmt update: [ :counter | counter + 1 ] ]
				ifAbsent: [ subDict at: definingStmt put: init ] ]
		ifAbsent: [
			variableOccurences at: varName put: (Dictionary new
					 at: definingStmt put: init;
					 yourself) ]
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> addStmtListLocalsAndSuppressRedundantDeclarationIn: aStmtListNode [
	"eliminate redundancy in variable declarations and mark locals that was not seen at the method scope"

	| allLocals |
	allLocals := Set new.
	localVariableScope do: [ :assoc | allLocals addAll: assoc value ].
	aStmtListNode locals do: [ :stmtLocal |
		(allLocals includes: stmtLocal)
			ifTrue: [ aStmtListNode removeLocal: stmtLocal ]
			ifFalse: [
			self addOcurrencesFor: stmtLocal in: aStmtListNode init: true ] ]
]

{ #category : 'cleaning' }
SLDeadCodeElimination >> clean [

	currentMethod nodesDo: [ :n |
		((markedElements includes: n) or: [
			 markedElementsAsExpression includes: n ]) ifFalse: [
			n isVariable ifTrue: [ self decreaseVariableOcurencesFor: n ].
			n parent ifNotNil: [ :parent | parent removeUnusedNodesInBranch: n ] ] ].
	self cleanUnusedVariableDeclaration
]

{ #category : 'cleaning' }
SLDeadCodeElimination >> cleanUnusedVariableDeclaration [

	variableOccurences associationsDo: [ :assocNameStmtDict |
		| varName |
		varName := assocNameStmtDict key.
		assocNameStmtDict value associationsDo: [ :assocStmtCounter |
			assocStmtCounter value <= 0 ifTrue: [
				assocStmtCounter key removeLocal: varName ] ] ]
]

{ #category : 'accessing' }
SLDeadCodeElimination >> codeGenerator [

	^ codeGenerator
]

{ #category : 'accessing' }
SLDeadCodeElimination >> codeGenerator: aCodeGen [

	codeGenerator := aCodeGen
]

{ #category : 'accessing' }
SLDeadCodeElimination >> currentMethod [

	^ currentMethod
]

{ #category : 'accessing' }
SLDeadCodeElimination >> currentMethod: aTMethod [

	currentMethod := aTMethod
]

{ #category : 'cleaning' }
SLDeadCodeElimination >> decreaseVariableOcurencesFor: aTVariableNode [

	| definingStmtList |
	definingStmtList := variableDefiningStmtList at: aTVariableNode.
	definingStmtList ifNil: [ ^ self ].
	(variableOccurences at: aTVariableNode name)
		at: definingStmtList
		update: [ :counter | counter - 1 ]
]

{ #category : 'init-variable-data' }
SLDeadCodeElimination >> findAndHandleStatementsVariablesIn: aNode [

	aNode isVariable ifTrue: [
		self addDefiningStatementFor: aNode.
		^ self ].
	aNode isStatementList ifTrue: [
		self addLocalDefinitionFor: aNode.
		^ self ].
	aNode isLeaf ifFalse: [
		aNode isInline
			ifTrue: [
			self findAndHandleStatementsVariablesIn: aNode method parseTree ]
			ifFalse: [
				aNode children do: [ :subNode |
					self findAndHandleStatementsVariablesIn: subNode ] ] ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> handleBinaryIterativeSend: aSendNode [
	"directly reduce send like '[self methodWithSideEffect] whileTrue as self methodWithSideEffect' since the algorithm won't detect this case as useless code, it will however detect it for send like '[true] whileTrue' (which will be supress the send) or '[var. self methodWithSideEffect] whileTrue' (which will trigger the optimisation later by removing var)"

	| stmts |
	aSendNode isBinaryIterativeSend ifFalse: [ ^ false ].
	stmts := aSendNode receiver statements.
	aSendNode receiver statements size > 1
		ifTrue: [
			self markAsStatementAndAddToWorkList: aSendNode.
			self markAsExpressionAndAddToWorkList: aSendNode receiver.
			(markedElementsAsExpression includes: aSendNode) ifTrue: [
				aSendNode arguments do: [ :arg |
					self markAsExpressionAndAddToWorkList: arg ] ] ]
		ifFalse: [
			aSendNode transformReceiverAfterEmptyArguments
				ifNotNil: [ :replacement |
					replacement statements do: [ :stmt |
						self markAsExpressionAndAddToWorkList: stmt ] ]
				ifNil: [ aSendNode parent removeUnusedNodesInBranch: aSendNode ] ].

	^ true
]

{ #category : 'mark' }
SLDeadCodeElimination >> handleConditionalAndBinaryIterativeSend: aSendNode [

	(aSendNode isConditionalSend or: [ aSendNode isBinaryIterativeSend ])
		ifFalse: [ ^ false ].
	self markAsStatementAndAddToWorkList: aSendNode.
	self markAsExpressionAndAddToWorkList: aSendNode receiver.
	(markedElementsAsExpression includes: aSendNode) ifTrue: [
		aSendNode arguments do: [ :arg |
			self markAsExpressionAndAddToWorkList: arg ] ].
	^ true
]

{ #category : 'mark' }
SLDeadCodeElimination >> handleUnaryIterativeSend: aSendNode [
	"directly reduce send like '[self methodWithSideEffect] whileTrue as self methodWithSideEffect' since the algorithm won't detect this case as useless code, it will however detect it for send like '[true] whileTrue' (which will be supress the send) or '[var. self methodWithSideEffect] whileTrue' (which will trigger the optimisation later by removing var)"

	| stmts |
	aSendNode isUnaryIterativeSendWithImportantLastStatement ifFalse: [
		^ false ].
	stmts := aSendNode receiver statements.
	aSendNode receiver statements size > 1
		ifTrue: [
			self markAsStatementAndAddToWorkList: aSendNode.
			self markAsExpressionAndAddToWorkList: aSendNode receiver.
			(markedElementsAsExpression includes: aSendNode) ifTrue: [
				aSendNode arguments do: [ :arg |
					self markAsExpressionAndAddToWorkList: arg ] ] ]
		ifFalse: [
			aSendNode transformReceiverAfterEmptyArguments
				ifNotNil: [ :replacement |
					replacement statements do: [ :stmt |
						self markAsExpressionAndAddToWorkList: stmt ] ]
				ifNil: [ aSendNode parent removeUnusedNodesInBranch: aSendNode ] ].

	^ true
]

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> initMarkAndWorkList [

	| currentMethodParseTree |
	currentMethodParseTree := currentMethod parseTree.

	self addLocalDefinitionFor: currentMethodParseTree.

	currentMethodParseTree nodesDo: [ :node |
		node isSend ifTrue: [ self mayMarkSendNode: node ].

		node isAssignment ifTrue: [ self mayMarkAssignementNode: node ].

		node isReturn ifTrue: [
			self markAsStatementAndAddToWorkList: node.
			self markAsExpressionAndAddToWorkList: node expression ].

		node isGoTo ifTrue: [ self markAsStatementAndAddToWorkList: node ].

		node isLabel ifTrue: [ self markAsStatementAndAddToWorkList: node ].

		node isSwitch ifTrue: [ self markAsStatementAndAddToWorkList: node ] ]
]

{ #category : 'initialization' }
SLDeadCodeElimination >> initialize [

	markedElements := IdentitySet new: 300.
	markedElementsAsExpression := IdentitySet new: 300.
	workList := OrderedCollection new.
	variableOccurences := Dictionary new: 100.
	variableDefinitions := Dictionary new: 100.
	variableDefiningStmtList := Dictionary new: 100.
	localVariableScope := Stack new
]

{ #category : 'testing' }
SLDeadCodeElimination >> isStructAccessorWithNoSideEffect: aSendNode [

	^ (codeGenerator isStructSend: aSendNode) and: [ aSendNode numArgs = 0 ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsExpression: aNode [

	markedElementsAsExpression add: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsExpressionAndAddToWorkList: aNode [

	(markedElementsAsExpression includes: aNode) ifTrue: [ ^ self ].
	workList add: aNode.
	self markAsExpression: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsStatement: aNode [

	markedElements add: aNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> markAsStatementAndAddToWorkList: aNode [

	(markedElements includes: aNode) ifTrue: [ ^ self ].
	workList add: aNode.
	self markAsStatement: aNode
]

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> mayMarkAssignementNode: anAssignmentNode [

	| variable |
	variable := anAssignmentNode variable.
	self addDefinitionsFor: anAssignmentNode.
	(currentMethod locals includes: variable name) ifTrue: [ ^ self ].
	self visitAssignmentNode: anAssignmentNode
]

{ #category : 'init-mark-and-worklist' }
SLDeadCodeElimination >> mayMarkSendNode: aSendNode [

	(aSendNode hasSideEffect not or: [
		 aSendNode isConditionalSend or: [
			 aSendNode isIterativeSend or: [
				 (self isStructAccessorWithNoSideEffect: aSendNode) or: [
					 aSendNode selector beginsWith: #cCoerce ] ] ] ]) ifTrue: [
		^ self ].
	self visitSendNode: aSendNode
]

{ #category : 'mark' }
SLDeadCodeElimination >> propagateMarkedElement: node [
	"if a node has been marked useful, mark its dependences and add them to the workList via a visitor pattern, behavior may change if we are marked as an expression or not "

	| parent |
	
	self visit: node.

	parent := node parent.
	(parent isNil or: [
		 parent isTMethod or: [
			 (markedElements includes: parent) or: [
				 markedElementsAsExpression includes: parent ] ] ]) ifFalse: [
		self markAsStatementAndAddToWorkList: parent ]
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeInCurrentMethod [

	| i |
	currentMethod expandAST.
	"self initMarkAndWorkList.
	[ workList isEmpty ] whileFalse: [
		i := workList removeFirst.
		self propagateMarkedElement: i ].
	self clean.
	self initialize"
]

{ #category : 'dead-code-elimination' }
SLDeadCodeElimination >> removeDeadCodeUsing: aCodeGen [

	codeGenerator := aCodeGen.
	UIManager default
		displayProgress: 'dead code elimination '
		from: 0
		to: codeGenerator methods size
		during: [ :bar |
			codeGenerator methods doWithIndex: [ :m :i |
				bar value: i.
				currentMethod := m.
				codeGenerator currentMethod: m.
				self removeDeadCodeInCurrentMethod ] ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visit: aNode [

	aNode accept: self
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitAssignmentNode: anAssignmentNode [

	anAssignmentNode isSelfAssign ifTrue: [ ^ self ].

	self markAsStatementAndAddToWorkList: anAssignmentNode.
	self markAsExpressionAndAddToWorkList: anAssignmentNode variable.
	self markAsExpressionAndAddToWorkList: anAssignmentNode expression
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitCaseStatementNode: aCaseStmtNode [

	self markAsStatementAndAddToWorkList: aCaseStmtNode.
	self markAsExpressionAndAddToWorkList: aCaseStmtNode expression.

	aCaseStmtNode cases do: [ :case |
		self markAsExpressionAndAddToWorkList: case ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitConstantNode: aConstantNode [
	"nothing to do for an already marked constant"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitGoToNode: aTGotoNode [
	"nothing to do for an already marked TGotToNode"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitInlineNode: anInlineNode [

	self markAsStatementAndAddToWorkList: anInlineNode.
	(markedElementsAsExpression includes: self) ifTrue: [
		self markAsExpressionAndAddToWorkList: anInlineNode method parseTree ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitLabeledCommentNode: aLabeledCommentNode [
	"nothing to do for an already marked label or comment"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitReturnNode: aReturnNode [
	"should't be called : return are handled in the first pass of the algorithm"

	
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitSendNode: aSendNode [

	(self handleConditionalAndBinaryIterativeSend: aSendNode) ifTrue: [ ^ self ].
		(self handleUnaryIterativeSend: aSendNode) ifTrue: [ ^ self ].
	self markAsStatementAndAddToWorkList: aSendNode.
	self markAsExpressionAndAddToWorkList: aSendNode receiver.

	(#( #cCall:withArguments: f:printf: ) includes: aSendNode selector)
		ifTrue: [
			(aSendNode arguments at: 2) statements do: [ :stmt |
				self markAsExpressionAndAddToWorkList: stmt ] ].



	aSendNode arguments do: [ :arg |
		self markAsExpressionAndAddToWorkList: arg ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitStatementListNode: aStatementsListNode [
	"node statements are either marked from a children, for example [ 5.self method.true ] then we don't need to do anythings since the node and the useful branch(es) are already being marked.
	When it is marked from a parent (as expression), for example ^ [ 5.self method.true ] or ^ [ 5 ], in this case to keep the correct behavior, the last expression is kept."

	| statements |
	statements := aStatementsListNode statements.
	((markedElementsAsExpression includes: aStatementsListNode) and: [
		 aStatementsListNode isEmptyStmtListNode not ]) ifTrue: [
		self markAsExpressionAndAddToWorkList:
			aStatementsListNode lastNonCommentStatement ].
	statements do: [ :n | "keep the comments"
		n isComment ifTrue: [ self markAsStatement: n ] ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitSwitchStatementNode: aSwitchStatementNode [

	| otherwiseOrNil expressionOrStatementSend |
	otherwiseOrNil := aSwitchStatementNode otherwiseOrNil.
	expressionOrStatementSend := (markedElementsAsExpression includes:
		                              aSwitchStatementNode)
		                             ifTrue: [
		                             #markAsExpressionAndAddToWorkList: ]
		                             ifFalse: [
		                             #markAsStatementAndAddToWorkList: ].

	self markAsStatementAndAddToWorkList: aSwitchStatementNode.
	self markAsExpressionAndAddToWorkList:
		aSwitchStatementNode expression.

	aSwitchStatementNode cases do: [ :c |
		| caseLabels caseStatements |
		caseLabels := c first.
		caseStatements := c second.
		caseLabels do: [ :label |
			self markAsExpressionAndAddToWorkList: label ].
		self
			perform: expressionOrStatementSend asSymbol
			withArguments: { caseStatements } ].

	otherwiseOrNil ifNotNil: [
		self
			perform: expressionOrStatementSend asSymbol
			withArguments: { otherwiseOrNil } ]
]

{ #category : 'mark' }
SLDeadCodeElimination >> visitVariableNode: aVariableNode [

	| varName |
	varName := aVariableNode name.
	variableDefinitions
		at: varName
		ifPresent: [
			(variableDefinitions at: varName) do: [ :definition |
				self visit: definition ] ]
		ifAbsent: [ "self and non-local variables" ]
]
