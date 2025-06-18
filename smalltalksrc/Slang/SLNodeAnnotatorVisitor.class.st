Class {
	#name : 'SLNodeAnnotatorVisitor',
	#superclass : 'Object',
	#instVars : [
		'returnStack',
		'exitVarStack',
		'currentMethod',
		'info',
		'useAsExpressionStack',
		'inExpressionStack',
		'jumpMetStack'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToExitVar: aNode [
	"when an assignment has been met, the effective exitVar is not all of the nodes in it, often it is just a single node (or more if conditionals) the nodes have a link to theirs assignment
	true or nil on the stack indicate if the node is the effective exitVar"

	| entry top |
	exitVarStack isEmpty ifTrue: [ ^ self ].

	top := exitVarStack top.
	entry := info at: aNode.
	"we are just above a jump thus the node is an exitVar"
	(jumpMetStack isNotEmpty and: [ jumpMetStack top ]) ifTrue: [
		top := true -> top value ].

	entry at: self exitVarString put: top.
	exitVarStack pop.
	exitVarStack push: nil -> top value
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToInExpression: aNode [

	inExpressionStack isEmpty ifTrue: [ ^ self ].
	(info at: aNode) at: self inExpressionString put: true
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToReturn: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is the exit value
	true or false on the stack only indicate if the node is the effective value of the returning expression or not"

	| entry assoc |
	returnStack isEmpty ifTrue: [ ^ self ].

	entry := info at: aNode.
	assoc := returnStack top.

	"we are just above a jump thus the node is an exitValue"
	(jumpMetStack isNotEmpty and: [ jumpMetStack top ]) ifTrue: [
		assoc := true -> assoc value ].

	entry at: self returnString put: assoc.
	returnStack pop.
	"no longer the direct return"
	returnStack push: false -> assoc value
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToStatementOrExpression: aNode [

	| entry |
	entry := info at: aNode.
	(self isDirectExpression: aNode) ifTrue: [
		entry at: self expressionString put: true.
		aNode isAnExpression: true.
		^ self ].
	(useAsExpressionStack isNotEmpty and: [
		 useAsExpressionStack top = self expressionString ])
		ifTrue: [
			entry at: self expressionString put: true.
			aNode isAnExpression: true ]
		ifFalse: [
			entry at: self expressionString put: false.
			aNode isAnExpression: false ].

	"default to a statement by default"
	useAsExpressionStack isEmpty ifFalse: [ ^ self ].
	entry at: self expressionString put: false.
	aNode isAnExpression: false
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode [

	self annotateNodeState: aNode canBeAnExpression: true
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode canBeAnExpression: aBoolean [
	"annotate the node by assuming the ast exploration ensure that the different exitValue are the first to reach this method for each branch"

	self ensureEntryInInfoDictFor: aNode.
	self addToInExpression: aNode.

	"comment, label and goTo cannot be an expression, in C as in Pharo
	so if we may be looking for an exitValue, the node should be ignored
	and we can mark it as statement"
	aBoolean ifFalse: [
		useAsExpressionStack push: self statementString.
		self addToStatementOrExpression: aNode.
		useAsExpressionStack pop.
		^ self ].

	self addToReturn: aNode.
	self addToExitVar: aNode.
	self addToStatementOrExpression: aNode.

	(jumpMetStack isNotEmpty and: [ jumpMetStack top ]) ifFalse: [
		^ self ].
	jumpMetStack pop.
	jumpMetStack push: false
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> currendMethod: aTmethod [

	currentMethod := aTmethod
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> exitVarString [

	^ #exitVar
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> getAssignmentForExitVar: aNode [

	| assignmentNode |
	assignmentNode := (info at: aNode)
		                  at: self exitVarString
		                  ifAbsent: [ nil ].
	(assignmentNode isNil or: [ assignmentNode key isNil ]) ifTrue: [
		^ nil ].
	^ assignmentNode value
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> handleConditionalSendVisit: aSendNode [
	
	"conditionals are handle like they would be in C, they are not considered as expression like other sends comming from pharo"
	| returnTop exitVarTop size |
	inExpressionStack push: self inExpressionString.

	size := aSendNode arguments size.
	"re give the informations for each branch after using it"
	aSendNode arguments doWithIndex: [ :arg :index |
		returnTop := returnStack isEmpty ifFalse: [ returnStack top ].
		exitVarTop := exitVarStack isEmpty ifFalse: [ exitVarStack top ].
		arg accept: self.
		index ~= size ifTrue: [
			returnTop ifNotNil: [
				returnStack pop.
				returnStack push: returnTop ].
			exitVarTop ifNotNil: [
				exitVarStack pop.
				exitVarStack push: exitVarTop ] ] ].
	
	"can't be a exitValue, but the information have been taken by the arguments"
	aSendNode receiver accept: self.

	inExpressionStack pop.
	
	"the effective values are not the result of this message"
	self annotateNodeState: aSendNode canBeAnExpression: false
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> inExpressionString [
	"value doesn't actually matter, but the stack need elements"

	^ #inExpression
]

{ #category : 'initialization' }
SLNodeAnnotatorVisitor >> initialize [

	super initialize.
	useAsExpressionStack := Stack new.
	returnStack := Stack new.
	exitVarStack := Stack new.
	inExpressionStack := Stack new.
	jumpMetStack := Stack new.
	info := IdentityDictionary new
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isDirectExpression: aNode [

	^ (self isDirectReturn: aNode) or: [ (self getAssignmentForExitVar: aNode) isNotNil ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isDirectReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc key ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInAssignment: aNode [ 
	
	^ (info at: aNode) at: self exitVarString ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInExpression: aNode [

	^ (info at: aNode)
		  at: self inExpressionString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeAssigningParentFrom: aSendNode [
	"use in inlining to put assignment down the ast : x = { ... exp} -> {x = ... exp}, clean all the info as a side effect, it needs to be recalculated
	answer if something was done"

	| assignment exitVar |
	exitVar := self getAssignmentForExitVar: aSendNode.
	exitVar ifNil: [ ^ false ].

	assignment := exitVar parent.
	self haltIf: [ assignment isAssignment not ].
	"necessary because of the inlining hack"
	self cleanInfo.
	self visit: assignment tMethod parseTree.
	self transformToAssignmentFrom: assignment exitVar: exitVar.

	assignment parent
		replaceChild: assignment
		with: assignment expression.

	self cleanInfo.
	^ true
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeReturningParentFrom: aSendNode [
	"use in inlining for redondant return : return {return exp} -> {return exp}, clean all the info as a side effect, it needs to be recalculated
	answer if anything was done"

	| returningParent |
	(self isDirectReturn: aSendNode) ifFalse: [ ^ false ].

	returningParent := self returningParentFor: aSendNode.

	self transformDirectReturnFrom: returningParent.

	returningParent parent
		replaceChild: returningParent
		with: returningParent expression.

	self cleanInfo.
	^ true
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> returnString [

	^ #return
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> returningParentFor: aNode [
	"if the node is in a return give the returningParent even if the node is not the exitvalue itself"
	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc value ]
		  ifAbsent: [ nil ]
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> statementString [

	^ #statement
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformDirectReturnFrom: parentNode [
	"recursively go throught the ast to transfrom directReturn
	^ exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [^exp] ifFalse [^exp]"

	parentNode children do: [ :child |
		(self isDirectReturn: child)
			ifTrue: [
			child parent replaceChild: child with: child asReturnNode ]
			ifFalse: [ self transformDirectReturnFrom: child ] ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformToAssignmentFrom: parentNode exitVar: exitVar [
	"recursively go throught the ast to transfrom expression of assignment
	a = exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [a = exp] ifFalse [a = exp]"

	parentNode children do: [ :child |
		(self getAssignmentForExitVar: child) == exitVar
			ifTrue: [
				child parent replaceChild: child with: (TAssignmentNode new
						 variable: exitVar;
						 expression: child;
						 yourself) ]
			ifFalse: [ self transformToAssignmentFrom: child exitVar: exitVar ] ]
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> useAsExpressionsSet [

	| expressions |
	expressions := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifTrue: [
			expressions add: assoc key ] ].
	^ expressions
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> useAsStatementsSet [

	| statements |
	statements := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifFalse: [
			statements add: assoc key ] ].
	^ statements
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visit: aNode [

	aNode accept: self.
	self assert: exitVarStack isEmpty.
	self assert: returnStack isEmpty.
	self assert: useAsExpressionStack isEmpty.
	self assert: inExpressionStack isEmpty.
	self assert: jumpMetStack isEmpty
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitAssignmentNode: anAssignmentNode [

	self annotateNodeState: anAssignmentNode.

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	exitVarStack push: true -> anAssignmentNode variable.

	anAssignmentNode expression accept: self.
	anAssignmentNode variable accept: self.

	inExpressionStack pop.
	useAsExpressionStack pop.

	exitVarStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitBraceCaseNode: aTBraceCaseNode [
	"shouldn't be reachable in real condition, TBraceCaseNode are translated to switch before going throught any operation.
	it can be reach throught tests as a side effect since inlining goes for all knowned methods in the codeGenerator even if they are not the tests focuss"

	
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitCaseStatementNode: aCaseStmtNode [

	self annotateNodeState: aCaseStmtNode.

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	aCaseStmtNode expression accept: self.
	aCaseStmtNode cases do: [ :case | case accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitConstantNode: aConstantNode [

	self annotateNodeState: aConstantNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitGoToNode: aTGotoNode [

	self annotateNodeState: aTGotoNode canBeAnExpression: false.

	aTGotoNode haveBeenMetInInlining ifTrue: [ ^ self ].
	jumpMetStack pop.
	jumpMetStack push: true.
	aTGotoNode metInInlining
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitInlineNode: anInlineNode [

	self annotateNodeState: anInlineNode.

	anInlineNode method parseTree accept: self
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitLabeledCommentNode: aLabeledCommentNode [

	self annotateNodeState: aLabeledCommentNode canBeAnExpression: false
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitReturnNode: aReturnNode [

	self annotateNodeState: aReturnNode.

	useAsExpressionStack push: self expressionString.
	returnStack push: true -> aReturnNode.
	inExpressionStack push: self inExpressionString.

	aReturnNode expression accept: self.

	inExpressionStack pop.
	useAsExpressionStack pop.
	returnStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSendNode: aSendNode [

	aSendNode isConditionalSend ifTrue: [
		self handleConditionalSendVisit: aSendNode.
		^ self ].

	self annotateNodeState: aSendNode.

	inExpressionStack push: self inExpressionString.
	useAsExpressionStack push: self expressionString.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitStatementListNode: aStatementsListNode [

	| stmts needExitValue |
	stmts := aStatementsListNode statements.
	needExitValue := useAsExpressionStack isEmpty
		                 ifTrue: [ false ]
		                 ifFalse: [
		                 useAsExpressionStack top = self expressionString ].
	useAsExpressionStack push: self statementString.
	jumpMetStack push: needExitValue.
	stmts reverse do: [ :stmt | stmt accept: self ].

	useAsExpressionStack pop.
	jumpMetStack pop.
	self annotateNodeState: aStatementsListNode canBeAnExpression: false
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	self annotateNodeState: aSwitchStatementNode.

	aSwitchStatementNode cases do: [ :case |
		| caseLabels caseStatements |
		caseLabels := case first.
		caseStatements := case second.
		caseLabels do: [ :label |
			useAsExpressionStack push: self statementString.
			label accept: self.
			useAsExpressionStack pop.

			caseStatements accept: self ] ].

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	aSwitchStatementNode expression accept: self.
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o | o accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
