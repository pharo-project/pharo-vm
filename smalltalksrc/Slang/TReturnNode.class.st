Class {
	#name : #TReturnNode,
	#superclass : #TParseNode,
	#instVars : [
		'expression'
	],
	#category : #'Slang-AST'
}

{ #category : #generated }
TReturnNode class >> expression: anExpression [

	self haltIf: [ anExpression isStatementList ].
	^ self new
		expression: anExpression;
		yourself
]

{ #category : #comparing }
TReturnNode >> = aNode [

	super = aNode ifFalse: [ ^false ].
	aNode isReturn ifFalse: [ ^false ].
	expression = aNode expression ifFalse: [ ^ false ].
	^ true
]

{ #category : #visiting }
TReturnNode >> accept: aVisitor [
	
	^ aVisitor visitReturnNode: self
]

{ #category : #tranforming }
TReturnNode >> asCASTIn: aBuilder [

	| cast |
	(expression isSwitch or: [ expression isCaseStmt ]) ifTrue: [ 
		^ expression asCASTIn: aBuilder addToEndOfCases: self ].

	"Transforms the statment
	^ a ifTrue: [ ^ 1 ] ifFalse: [ bla. 2 ]
	=>
	a ifTrue: [ ^ 1 ] ifFalse: [ bla . ^ 2 ]
	"
	expression isConditionalSend ifTrue: [ 
		| conditionalAsStatement |
		conditionalAsStatement := expression copy.
		conditionalAsStatement arguments:
			(conditionalAsStatement arguments collect: [ :arg | 
				 arg asReturnNode ]).
		^ conditionalAsStatement asCASTIn: aBuilder ].

	"Transforms
	^ [ a . last] value
	=>
	{ a . ^ last }.
	"
	(expression isSend and: [ expression isValueExpansion ]) ifTrue: [ "If the any argument is used inside the block, we cannot just ignore arguments!"
		expression receiver nodesDo: [ :n | 
			(n isVariable and: [ 
				 expression receiver arguments includes: n name ]) ifTrue: [ 
				self notYetImplemented ] ].
		^ expression receiver asReturnNode asCASTIn: aBuilder ].

	'void' = aBuilder currentMethod returnType ifTrue: [ "If the function is void, don't say 'return x' instead say ' x; return' "
		| statements |
		statements := OrderedCollection new.
		expression isLeaf ifFalse: [ 
			statements add: (expression asCASTIn: aBuilder) ].
		statements add: CReturnStatementNode new.
		^ (CCompoundStatementNode statements: statements)
			  needsBrackets: false;
			  yourself "Slang compatibility" ].

	cast := expression asCASTExpressionIn: aBuilder.

	"If the expression is a sequence, inject the return at the last element.
	It may be more clean to do that at the TAST level instead of the CAST level. I dunno."
	cast isCompoundStatement ifTrue: [ 
		cast last: (CReturnStatementNode expression: cast last).
		^ cast ].

	"Or else build a return"
	^ CReturnStatementNode expression: cast
]

{ #category : #transforming }
TReturnNode >> asLastExpressionAssignmentTo: aTVariableNode [ 

	"Do not assign return statements"
	^ self
]

{ #category : #transformations }
TReturnNode >> asReturnNodeWithComment: aComment [

	^ self copy
		  comment: aComment;
		  yourself
]

{ #category : #transformations }
TReturnNode >> assignLastExpressionTo: aTVariableNode [

	^ TReturnNode expression:
		  (expression assignLastExpressionTo: aTVariableNode)
]

{ #category : #transformations }
TReturnNode >> bindVariableUsesIn: aDictionary [

	self expression: (expression bindVariableUsesIn: aDictionary)
]

{ #category : #transformations }
TReturnNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound."
	| newExpression |
	newExpression := expression bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen.
	^newExpression = expression
		ifTrue: [self]
		ifFalse:
			[self shallowCopy
				setExpression: newExpression;
				yourself]
]

{ #category : #transformations }
TReturnNode >> bindVariablesIn: aDictionary [

	self expression: (expression bindVariablesIn: aDictionary)
]

{ #category : #transformations }
TReturnNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].	
	self expression: (expression bindVariablesIn: aDictionary unless: cautionaryBlock)
]

{ #category : #accessing }
TReturnNode >> children [

	^ { expression }
]

{ #category : #transformations }
TReturnNode >> copyWithoutReturn [
	^expression
]

{ #category : #testing }
TReturnNode >> endsWithReturn [

	^true
]

{ #category : #accessing }
TReturnNode >> expression [

	^expression
]

{ #category : #accessing }
TReturnNode >> expression: anExpression [

	expression := anExpression.
	expression parent: self.
]

{ #category : #testing }
TReturnNode >> isReturn [

	^true
]

{ #category : #comparing }
TReturnNode >> isSameAs: aTParseNode [

	aTParseNode isReturn ifFalse: [ ^ false ].
	^ expression isSameAs: aTParseNode expression
]

{ #category : #enumerating }
TReturnNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock.
	aBlock value: self
]

{ #category : #enumerating }
TReturnNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock parent: self.
	aBlock value: self value: parent
]

{ #category : #enumerating }
TReturnNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	expression nodesDo: aBlock parent: self unless: cautionaryBlock.
	aBlock value: self value: parent
]

{ #category : #enumerating }
TReturnNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	expression nodesDo: aBlock unless: cautionaryBlock.
	aBlock value: self.
]

{ #category : #copying }
TReturnNode >> postCopy [

	self expression: expression copy
]

{ #category : #'C code generation' }
TReturnNode >> prependCASTIn: aBuilder expression: nodeExp [

	^ CReturnStatementNode expression:
		  (nodeExp asCASTExpressionIn: aBuilder)
]

{ #category : #printing }
TReturnNode >> printOn: aStream level: level [

	aStream nextPut: $^.
	expression printOn: aStream level: level.
]

{ #category : #transformations }
TReturnNode >> removeAssertions [
	expression removeAssertions
]

{ #category : #transformations }
TReturnNode >> replaceChild: aNode with: aReplacementNode [

	expression == aNode ifFalse: [ self error: 'Node is not a child of current node' ].
	self expression: aReplacementNode
]

{ #category : #transformations }
TReturnNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		self expression: (expression replaceNodesIn: aDictionary).
		self]
]

{ #category : #accessing }
TReturnNode >> setExpression: aNode [

	self expression: aNode
]

{ #category : #'type inference' }
TReturnNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	^expression typeOrNilFrom: aCodeGenerator in: aTMethod
]
