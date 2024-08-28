Class {
	#name : 'TStatementListNode',
	#superclass : 'TParseNode',
	#instVars : [
		'locals',
		'declarations',
		'arguments',
		'statements',
		'usedVariables'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'instance creation' }
TStatementListNode class >> declarations: declarations locals: locals statements: aCollection [ 
	
	^ self new
		declarations: declarations;
		locals: locals;
		statements: aCollection;
		yourself
]

{ #category : 'instance creation' }
TStatementListNode class >> declarations: declarations statements: aCollection [ 
	
	^ self new
		declarations: declarations;
		locals: declarations keys;
		statements: aCollection;
		yourself
]

{ #category : 'instance creation' }
TStatementListNode class >> parameters: parameters statements: statementList [
	
	^ self new
		setArguments: parameters statements: statementList
		yourself
]

{ #category : 'instance creation' }
TStatementListNode class >> statements: aCollection [ 
	
	^ self new
		statements: aCollection;
		yourself
]

{ #category : 'comparing' }
TStatementListNode >> = aNode [

	super = aNode ifFalse: [ ^ false ].
	aNode isStatementList ifFalse: [ ^ false ].
	statements size = aNode statements size ifFalse: [ ^ false ].
	statements doWithIndex: [ :stmt :i | 
		stmt = (aNode statements at: i) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'visiting' }
TStatementListNode >> accept: aVisitor [ 
	
	^ aVisitor visitStatementListNode: self
]

{ #category : 'adding' }
TStatementListNode >> addAllLast: aListOfStatement [

	(statements isNotEmpty and: [ statements last isComment ])
		ifFalse: [ statements addAllLast: aListOfStatement ]
		ifTrue: [
			| actualLast actualLastMet allWithoutEndComment endComment |
			actualLast := self lastNonCommentStatement.
			allWithoutEndComment := OrderedCollection new.
			endComment := OrderedCollection new.
			actualLastMet := false.
			statements do: [ :e |
				actualLastMet
					ifFalse: [
						allWithoutEndComment add: e.
						actualLastMet := e == actualLast ]
					ifTrue: [ endComment add: e ] ].
			statements := allWithoutEndComment , aListOfStatement , endComment ]
]

{ #category : 'declarations' }
TStatementListNode >> addDeclarations: aCollection [ 
	
	declarations addAll: aCollection.
	locals addAll: aCollection keys.
]

{ #category : 'utilities' }
TStatementListNode >> addReadBeforeAssignedIn: variables to: readBeforeAssigned assignments: assigned in: aCodeGen [
	"Add any variables in variables that are read before written to readBeforeAssigned.
	 Add unconditional assignments to assigned.  For convenience answer assigned."

	self
		nodesWithParentsDo: [ :node :parent |
			(node isAssignment and: [ variables includes: node variable name ])
				ifTrue: [ assigned add: node variable name ].
			(node isVariable and: [
				 (variables includes: node name) and: [
					 (assigned includes: node name) not and: [
						 (#( nil pointer ) includes: (node structTargetKindIn: aCodeGen))
							 and: [
								 (parent notNil and: [
									  parent isAssignment and: [ parent variable == node ] ]) not ] ] ] ])
				ifTrue: [
					node name = 'theCalloutState' ifTrue: [ self halt ].
					readBeforeAssigned add: node name ] ]
		unless: [ :node :parent |
			| conditionalAssignments mayHaveSideEffects |
			node isSend
				ifTrue: [ "First deal with implicit assignments..."
					node isValueExpansion ifTrue: [
						assigned addAll: node receiver arguments ].
					(#( #memcpy:_:_: #memmove:_:_: ) includes: node selector)
						ifTrue: [
							assigned add:
								(node arguments first detect: [ :subnode | subnode isVariable ])
									name ].
					(#( #to:do: #to:by:do: ) includes: node selector) ifTrue: [
						assigned addAll:
							(node arguments at: node selector numArgs) arguments.
						mayHaveSideEffects := node arguments size = 4. "See TMethod>>prepareMethodIn:"
						mayHaveSideEffects ifTrue: [
							assigned add: node arguments last name ] ].
					"Then deal with read-before-written in the arms of conditionals..."
					(#( ifTrue: ifFalse: ifNil: ifNotNil: ) intersection:
						 node selector keywords) notEmpty
						ifTrue: [ "First find assignments in the expression..."
							(TStatementListNode new
								 statements: { node receiver };
								 yourself)
								addReadBeforeAssignedIn: variables
								to: readBeforeAssigned
								assignments: assigned
								in: aCodeGen.
							"Now find read-before-written in each arm, and collect the assignments to spot those assigned in both arms"
							conditionalAssignments := node arguments
								                          collect: [ :block |
									                          block isStatementList ifTrue: [
										                          block
											                          addReadBeforeAssignedIn:
											                          variables
											                          to: readBeforeAssigned
											                          assignments: assigned copy
											                          in: aCodeGen ] ]
								                          thenSelect: [ :each | each notNil ].
							"add to assigned those variables written to in both arms"
							conditionalAssignments size = 2 ifTrue: [
								conditionalAssignments := conditionalAssignments collect: [
									                          :set | set difference: assigned ].
								assigned addAll: (conditionalAssignments first intersection:
										 conditionalAssignments last) ].
							true ]
						ifFalse: [ false ] ]
				ifFalse: [ false ] ].
	^ assigned
]

{ #category : 'accessing' }
TStatementListNode >> allButLastNonCommentStatement [
	"the last statement can be a comment if the TStatementList has been through inlining, return the statements without the actual last statement"

	| actualLast |
	statements last isComment ifFalse: [ ^ statements allButLast ].
	actualLast := self lastNonCommentStatement.
	^ statements select: [ :node | node ~~ actualLast ]
]

{ #category : 'enumerating' }
TStatementListNode >> allStatementsDo: aFullBlockClosure [ 
	
	statements do: [ :statement |
		aFullBlockClosure value: statement.
		statement allStatementsDo: aFullBlockClosure ].
]

{ #category : 'accessing' }
TStatementListNode >> args [
	self
		deprecated: 'use #arguments instead'
		transformWith: '`@rec args' -> '`@rec arguments'.
	^arguments
]

{ #category : 'accessing' }
TStatementListNode >> arguments [

	^arguments
]

{ #category : 'tranforming' }
TStatementListNode >> asCASTExpressionIn: aBuilder [

	| expressionList |
	expressionList := CExpressionListNode new.
	statements size == 1 ifTrue: [
		^ statements first asCASTExpressionIn: aBuilder ].
	statements withIndexDo: [ :node :idx |
		(node isLeaf and: [
			 node isLabel not and: [ node ~~ self lastNonCommentStatement ] ])
			ifFalse: [ expressionList , (node asCASTExpressionIn: aBuilder) ] ].
	^ expressionList
]

{ #category : 'tranforming' }
TStatementListNode >> asCASTIn: aBuilder [
	
	"Push the argument before pushing myself in the scope stack.
	This makes the variable available my the parent scope"
	self arguments do: [ :e | aBuilder noteUsedVariableName: e ].

	^ aBuilder
		pushScope: self
		while: [ self asCASTIn: aBuilder prependToEnd: nil ]
]

{ #category : 'C code generation' }
TStatementListNode >> asCASTIn: aBuilder prependToEnd: aNodeOrNil [

	| cDeclarations collect methodIsVolatile actualLast |
	cDeclarations := OrderedCollection new.
	collect := OrderedCollection new.
	statements isNotEmpty ifTrue: [
		actualLast := self lastNonCommentStatement ].

	statements doWithIndex: [ :e :index |
		(e isLeaf and: [
			 e isLabel not and: [
				 aNodeOrNil isNil or: [ index < statements size ] ] ])
			ifFalse: [
				(aNodeOrNil notNil and: [ e == actualLast ])
					ifTrue: [
					collect add: (e asCASTIn: aBuilder prependToEnd: aNodeOrNil) ]
					ifFalse: [ collect add: (e asCASTIn: aBuilder) ] ]
			ifTrue: [ CEmptyStatementNode new ] ].

  "We should collect the variable declarations after generating the body, because the body generation will record used yet non declared variables"
	methodIsVolatile := aBuilder currentMethod isVolatile.
	(self parent notNil and: [
		 self parent isTMethod and: [ self parent refersToGlobalStruct ] ])
		ifTrue: [
			cDeclarations add: (CIdentifierNode name: (methodIsVolatile
						  ifTrue: [ 'DECL_MAYBE_VOLATILE_SQ_GLOBAL_STRUCT' ]
						  ifFalse: [ 'DECL_MAYBE_SQ_GLOBAL_STRUCT' ])) ].

	(aBuilder sortStrings: self locals asSet) do: [ :var |
		| declaration |
		declaration := aBuilder
			               declarationAt: var
			               ifAbsent: [ aBuilder defaultType , ' ' , var ].

		self flag: #TODO.
		"Avoid implicit variables.
		Before this was not generating unused variables at generation time, by
		  - tracking used variables during code generation
		  - generating variables after code"
		(declaration beginsWith: 'implicit') ifFalse: [
			methodIsVolatile ifTrue: [
				declaration := 'volatile ' , declaration ].
			cDeclarations add: (CRawCodeNode code: declaration) ] ].

	^ CCompoundStatementNode
		  declarations: cDeclarations
		  statements: collect
]

{ #category : 'transformations' }
TStatementListNode >> asReturnNode [
	"return a new STatementListNode with the last non-comment statement changed to a return"

	| newStmtsListNode |
	self endsWithReturn ifTrue: [ ^ self ].
	newStmtsListNode := self class new setArguments: arguments.
	statements last isComment
		ifFalse: [
			newStmtsListNode statements:
				statements allButLast , { statements last asReturnNode } ]
		ifTrue: [
			| actualLast |
			newStmtsListNode statements: statements copy.
			actualLast := newStmtsListNode lastNonCommentStatement.
			newStmtsListNode
				replaceChild: actualLast
				with: actualLast asReturnNode ].
	^ newStmtsListNode
]

{ #category : 'transformations' }
TStatementListNode >> assignLastExpressionTo: variableNode [
	"Destructively transform the receiver so that its last expression is assigned to the argument."
	| index lastExpression replacement |
	index := statements findLast: [:expr| (expr isGoTo or: [expr isLabel]) not].
	
	"Recursively deal with complex nodes"
	lastExpression := statements at: index.
	replacement := lastExpression assignLastExpressionTo: variableNode.
	statements
		at: index
		put: replacement.
	replacement parent: self.
]

{ #category : 'transformations' }
TStatementListNode >> bindVariableUsesIn: aDictionary [

	self statements: (statements collect: [ :s | s bindVariableUsesIn: aDictionary ]).
]

{ #category : 'transformations' }
TStatementListNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [

	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound."

	| newStatements |
	newStatements := statements collect: [ :s | 
		                 s
			                 bindVariableUsesIn: aDictionary
			                 andConstantFoldIf: constantFold
			                 in: codeGen ].
	^ newStatements = statements
		  ifTrue: [ self ]
		  ifFalse: [ 
			  self shallowCopy
				  statements: newStatements;
				  yourself ]
]

{ #category : 'transformations' }
TStatementListNode >> bindVariablesIn: aDictionary [

	self statements: (statements collect: [ :s | s bindVariablesIn: aDictionary ]).
]

{ #category : 'transformations' }
TStatementListNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	self statements: (statements collect: [ :s | s bindVariablesIn: aDictionary unless: cautionaryBlock]).
]

{ #category : 'enumerating' }
TStatementListNode >> children [

	^ statements
]

{ #category : 'transformations' }
TStatementListNode >> copyWithoutReturn [

	| newStmtsListNode |
	self assert: self endsWithReturn.
	statements size = 1 ifTrue: [
		statements last parent: self parent.
		^ statements last copyWithoutReturn ].
	newStmtsListNode := self class new setArguments: arguments.
	statements last isComment
		ifFalse: [
			newStmtsListNode statements:
				statements allButLast , { statements last copyWithoutReturn } ]
		ifTrue: [
			| actualLast |
			newStmtsListNode statements: statements copy.
			actualLast := newStmtsListNode lastNonCommentStatement.
			newStmtsListNode
				replaceChild: actualLast
				with: actualLast copyWithoutReturn ].
	^ newStmtsListNode]

{ #category : 'declarations' }
TStatementListNode >> declarationAt: aString ifPresent: aFullBlockClosure [ 
	
	^ declarations at: aString ifPresent: aFullBlockClosure
]

{ #category : 'accessing' }
TStatementListNode >> declarations [

	^ declarations ifNil: [ declarations := Dictionary new ]
]

{ #category : 'accessing' }
TStatementListNode >> declarations: anObject [

	declarations := anObject
]

{ #category : 'displaying' }
TStatementListNode >> displayString [

	"Nothing..."
	^ ''
]

{ #category : 'testing' }
TStatementListNode >> endsWithReturn [
	"Answer true if the last statement of this lock is a return."

	^ statements notEmpty and: [
		  self lastNonCommentStatement isReturn or: [
			  self lastNonCommentStatement isReturningIf ] ]
]

{ #category : 'accessing' }
TStatementListNode >> first [
	
	^ self statements first
]

{ #category : 'flattening' }
TStatementListNode >> flattened [

	^ statements flatCollect: [ :each |
		each flattened ]
]

{ #category : 'accessing' }
TStatementListNode >> initialize [

	super initialize.
	declarations := Dictionary new.
	usedVariables := Set new.
	locals := OrderedCollection new.
	arguments := #()
]

{ #category : 'testing' }
TStatementListNode >> isComment [

	^ self hasNothingButComments
]

{ #category : 'testing' }
TStatementListNode >> isEmptyStmtListNode [
	"return true if the statement node is empty orContains only comments"

	(statements isEmpty or: [ self isComment ]) ifTrue: [ ^ true ].
	^ false
]

{ #category : 'testing' }
TStatementListNode >> isNilStmtListNode [

	|stmt|
	statements size = 1 ifFalse: [^false].
	stmt := statements at: 1.
	^ stmt isVariable and: [stmt name = 'nil']
]

{ #category : 'testing' }
TStatementListNode >> isSameAs: aTParseNode [
	(aTParseNode isStatementList
	 and: [statements size = aTParseNode statements size]) ifFalse:
		[^false].
	statements with: aTParseNode statements do:
		[:mine :theirs|
		 (mine isSameAs: theirs) ifFalse:
			[^false]].
	^true
]

{ #category : 'testing' }
TStatementListNode >> isStatementList [

	^true
]

{ #category : 'accessing' }
TStatementListNode >> last [
	
	^ self statements last
]

{ #category : 'accessing' }
TStatementListNode >> lastNonCommentStatement [
	"the last statement can be a comment if the TStatementList has been through inlining, return the actual last statement"

	| last indexOfLast |
	last := statements last.
	indexOfLast := statements size.
	[ last isComment ] whileTrue: [
		indexOfLast := indexOfLast - 1.
		indexOfLast = 0 ifTrue: [ ^ nil ].
		last := statements at: indexOfLast ].

	^ last
]

{ #category : 'accessing' }
TStatementListNode >> locals [

	^ locals
]

{ #category : 'accessing' }
TStatementListNode >> locals: anObject [

	locals := anObject
]

{ #category : 'enumerating' }
TStatementListNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	statements do: [ :s | s nodesDo: aBlock ].	
	aBlock value: self
]

{ #category : 'enumerating' }
TStatementListNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	statements do: [:s| s nodesDo: aBlock parent: self].
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TStatementListNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	statements do: [ :s | s nodesDo: aBlock parent: self unless: cautionaryBlock].
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TStatementListNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	statements do: [ :s | s nodesDo: aBlock unless: cautionaryBlock ].	
	aBlock value: self
]

{ #category : 'accessing' }
TStatementListNode >> noteUsedVariableName: aString [ 

	usedVariables add: aString
]

{ #category : 'accessing' }
TStatementListNode >> parameterNames [
	
	^ arguments
]

{ #category : 'copying' }
TStatementListNode >> postCopy [

	arguments := arguments copy.
	self statements: (statements collect: [ :s | s copy parent: self ])
]

{ #category : 'printing' }
TStatementListNode >> printOn: aStream level: level [

	statements size > 1 ifTrue: [ aStream crtab: level + 1 ].
	aStream nextPut: $[.
	(arguments notNil and: [arguments notEmpty]) ifTrue:
		[arguments do: [ :arg | aStream nextPutAll: ' :'; nextPutAll: arg].
		 aStream nextPutAll: ' | '].
	self printStatementsOn: aStream level: level.
	aStream nextPut: $]
]

{ #category : 'printing' }
TStatementListNode >> printStatementsOn: aStream level: level [

	statements
		do: [:s| s printOn: aStream level: level]
		separatedBy: [aStream nextPut: $.; crtab: level + 1]
]

{ #category : 'transformations' }
TStatementListNode >> removeAssertions [
	| newStatements |
	newStatements := OrderedCollection new: statements size.
	statements do: [ :stmt |
		stmt isAssertion ifFalse: [
			newStatements add: (stmt removeAssertions; yourself).
		]
	].
	self setStatements: newStatements asArray
]

{ #category : 'transformations' }
TStatementListNode >> removeLast [
	"the last statement can be a comment if the TStatementList has been through inlining, remove the actual last statement"

	statements := self allButLastNonCommentStatement
]

{ #category : 'dead-code-elimination' }
TStatementListNode >> removeUnusedNodesInBranch: aChild [
	"this method should be only called when cleaning an AST tree after an unused expression was found, remove aChild from the list of statements"

	statements := statements select: [ :stmt | stmt ~~ aChild ].
	(statements isEmpty or: [ self hasNothingButComments ]) ifTrue: [
		self parent removeUnusedNodesInBranch: self ]
]

{ #category : 'inlining support' }
TStatementListNode >> renameLabelsForInliningInto: aTMethod [
	"TMethod already has a method for this; hijack it..."
	| labels |
	labels := OrderedCollection new.
	self nodesDo:
		[:node| node isLabel ifTrue: [labels add: node label]].
	TMethod new
		parseTree: self;
		labels: labels;
		renameLabelsForInliningInto: aTMethod
]

{ #category : 'transformations' }
TStatementListNode >> replaceChild: aNode with: bNode [

	self statements: (statements collect: [ :node |
		node == aNode
			ifTrue: [ bNode ]
			ifFalse: [ node ] ])
]

{ #category : 'transformations' }
TStatementListNode >> replaceChild: aNode withList: aListOfStatement [

	| aNodeMet allWithoutANode endWithoutANode |
	allWithoutANode := OrderedCollection new.
	endWithoutANode := OrderedCollection new.
	aNodeMet := false.
	statements do: [ :e |
		aNodeMet
			ifFalse: [
				aNodeMet := e == aNode.
				aNodeMet ifFalse: [ allWithoutANode add: e ] ]
			ifTrue: [ endWithoutANode add: e ] ].
	statements := allWithoutANode , aListOfStatement , endWithoutANode
]

{ #category : 'transformations' }
TStatementListNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		self statements: (statements collect: [ :s | s replaceNodesIn: aDictionary ]).
		self]
]

{ #category : 'testing' }
TStatementListNode >> returnsExpression [
	"Answer true if the last statement of this block is a return of some expression, not merely self or nil."

	statements isEmpty ifTrue:
		[^false].
	self lastNonCommentStatement isReturn ifFalse:
		[^false].
	self lastNonCommentStatement isVariable ifFalse:
		[^true].
	^self lastNonCommentStatement variable ~= 'self'
	  and: [self lastNonCommentStatement variable ~= 'nil']
]

{ #category : 'accessing' }
TStatementListNode >> second [
	
	^ self statements second
]

{ #category : 'accessing' }
TStatementListNode >> setArguments: argList [

	arguments := argList.
]

{ #category : 'accessing' }
TStatementListNode >> setArguments: argList statements: statementList [
	"Initialize this method using the given information."
	arguments := argList.
	self statements: statementList.
]

{ #category : 'accessing' }
TStatementListNode >> setStatements: stmtList [

	self
		deprecated: 'Call statements: pliz'
		transformWith: '`@receiver setStatements: `@arg' -> '`@receiver statements: `@arg'.
	self statements: stmtList.
]

{ #category : 'inlining' }
TStatementListNode >> shouldExpand [
	^(statements detect: [:stmt| stmt isInline]) shouldExpand
]

{ #category : 'accessing' }
TStatementListNode >> statements [

	^statements
]

{ #category : 'accessing' }
TStatementListNode >> statements: anObject [

	statements := anObject asOrderedCollection.
	statements do: [ :e | e parent: self ]
]

{ #category : 'type inference' }
TStatementListNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	^statements isEmpty ifFalse:
		[statements last typeOrNilFrom: aCodeGenerator in: aTMethod]
]

{ #category : 'accessing' }
TStatementListNode >> usedVariables [
	
	^ usedVariables
]
