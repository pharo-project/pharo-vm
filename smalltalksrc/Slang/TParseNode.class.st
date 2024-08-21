"
A TParseNode is node in the parse tree of a TMethod. Subclasses correspond to different types of nodes in a method parse tree. The tree of translation parse nodes mirrors the parse tree of a Smalltalk method, and is used for translating a Smalltalk method to C source.
"
Class {
	#name : 'TParseNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'comment'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'visiting' }
TParseNode >> accept: aVisitor [

	self subclassResponsibility
]

{ #category : 'utilities' }
TParseNode >> allCalls [
	"Answer a collection of selectors for the messages sent in this parse tree."

	| calls |
	calls := Set new: 32.
	self nodesDo:
		[:node|
		node isSend ifTrue:
			[calls add: node selector].
		(node isConstant and: [node value isSymbol]) ifTrue:
			[calls add: node value]].
	^calls
]

{ #category : 'enumerating' }
TParseNode >> allSatisfy: aBlock [
	self nodesDo: [:n| (aBlock value: n) ifFalse: [^false]].
	^true
]

{ #category : 'enumerating' }
TParseNode >> allStatementsDo: aFullBlockClosure [ 
	
	self children do: [ :child | child allStatementsDo: aFullBlockClosure ]
]

{ #category : 'enumerating' }
TParseNode >> anySatisfy: aBlock [
	self nodesDo: [:n| (aBlock value: n) ifTrue: [^true]].
	^false
]

{ #category : 'transforming' }
TParseNode >> asCASTExpressionIn: aBuilder [

	"By default use the normal translation.
	Override for those translations that are not expressions by default"	
	^ self asCASTIn: aBuilder
]

{ #category : 'tranforming' }
TParseNode >> asCASTIn: aBuilder [

	self subclassResponsibility
]

{ #category : 'C code generation' }
TParseNode >> asCASTIn: aBuilder prependToEnd: aNodeOrNil [
	aNodeOrNil ifNotNil:
		[^ aNodeOrNil prependCASTIn: aBuilder expression: self].
	^ self asCASTExpressionIn: aBuilder
]

{ #category : 'linearisation' }
TParseNode >> asExpressionIn: aMLStatementListBuider [ 
	
	"A TNode returns itself as an expression"
	^ self
]

{ #category : 'transformations' }
TParseNode >> asReturnNode [
	^TReturnNode new 
		setExpression: self;
		yourself
]

{ #category : 'linearisation' }
TParseNode >> asStatementIn: aMLStatementListBuider [ 

	"A TNode returns itself as a statement"
	^ self
]

{ #category : 'transformations' }
TParseNode >> assignLastExpressionTo: aTVariableNode [ 
	
	"An expression just assigns itself"
	 ^ TAssignmentNode new
			setVariable: aTVariableNode
			expression: self
]

{ #category : 'transformations' }
TParseNode >> bindVariableUsesIn: aDictionary [
	"Bind uses of all variables in the given dictionary, but do not change variables that appear on the left-hand-side of an assignment statement."

	^ self

]

{ #category : 'transformations' }
TParseNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound.
	 But do not change variables that appear on the left-hand-side of an assignment statement."
	^self

]

{ #category : 'transformations' }
TParseNode >> bindVariablesIn: aDictionary [

	^self
]

{ #category : 'transformations' }
TParseNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	^self
]

{ #category : 'accessing' }
TParseNode >> children [

	self subclassResponsibility
]

{ #category : 'enumerating' }
TParseNode >> collect: aBlock [
	| nodes |
	nodes := OrderedCollection new.
	self nodesDo: [:n| nodes add: (aBlock value: n) ].
	^nodes
]

{ #category : 'accessing' }
TParseNode >> comment [
	^comment
]

{ #category : 'accessing' }
TParseNode >> comment: aComment [

	comment := aComment 
]

{ #category : 'accessing' }
TParseNode >> constantNumbericValueIfAtAllPossibleOrNilIn: aCCodeGen [
	"This is a version of constantNumbericValueOrNil for type checking rather than code generation.
	 It aims to yield a value if at all possible."
	^self constantNumbericValueOrNil
]

{ #category : 'accessing' }
TParseNode >> constantNumbericValueOrNil [

	^nil
]

{ #category : 'enumerating' }
TParseNode >> detect: aBlock [
	^self detect: aBlock ifNone: [self error: 'Node is not in the tree']
]

{ #category : 'enumerating' }
TParseNode >> detect: aBlock ifNone: defaultBlock [
	self nodesDo: [:n| (aBlock value: n) ifTrue: [^n]].
	^defaultBlock value
]

{ #category : 'testing' }
TParseNode >> endsWithReturn [

	^false
]

{ #category : 'flattenin' }
TParseNode >> flattened [
	
	^ { self }
]

{ #category : 'testing' }
TParseNode >> hasExplicitReturn [

	self nodesDo: [ :node |
		node isReturn ifTrue: [ ^true ].
	].
	^false
]

{ #category : 'testing' }
TParseNode >> hasNothingButComments [
	"an alternative to isEmpty related to inlining"

	^ self children allSatisfy: [ :child | child isComment ]
]

{ #category : 'testing' }
TParseNode >> hasSideEffect [
	"Answer if the parse tree rooted at this node has a side-effect or not.  By default assume it has.  Nodes that don't override."
	^true
]

{ #category : 'testing' }
TParseNode >> isAssertion [
	^false
]

{ #category : 'testing' }
TParseNode >> isAssignment [

	^false
]

{ #category : 'testing' }
TParseNode >> isCaseStmt [

	^false
]

{ #category : 'testing' }
TParseNode >> isComment [

	^false
]

{ #category : 'testing' }
TParseNode >> isConditionalSend [
	"Answer if the receiver is a send of any of the conditionals, ifTrue: ifTrue:ifFalse: et al"
	^false
]

{ #category : 'testing' }
TParseNode >> isConstant [

	^false
]

{ #category : 'testing' }
TParseNode >> isDefine [

	^false
]

{ #category : 'testing' }
TParseNode >> isGoTo [

	^false
]

{ #category : 'testing' }
TParseNode >> isInline [
	^false
]

{ #category : 'testing' }
TParseNode >> isLabel [

	^false
]

{ #category : 'testing' }
TParseNode >> isLeaf [
	"Answer true if the receiver is a variable or a constant node."

	^false
]

{ #category : 'testing' }
TParseNode >> isLiteralArrayDeclaration [
	^false
]

{ #category : 'testing' }
TParseNode >> isNonNullCCode [
	"overridden in TSendNode"
	^false
]

{ #category : 'testing' }
TParseNode >> isReturn [

	^false
]

{ #category : 'testing' }
TParseNode >> isReturningIf [
	^false
]

{ #category : 'comparing' }
TParseNode >> isSameAs: aTParseNode [
	"Answer if the ParseTree rooted at this node is the same as aTParseNode.
	 By default answer false and have subclasses override as appropriate."
	^ self subclassResponsibility
]

{ #category : 'testing' }
TParseNode >> isSend [

	^false
]

{ #category : 'testing' }
TParseNode >> isStatementList [

	^false
]

{ #category : 'testing' }
TParseNode >> isSwitch [
	^false
]

{ #category : 'testing' }
TParseNode >> isTMethod [
	^false
]

{ #category : 'testing' }
TParseNode >> isTParseNode [
	^true
]

{ #category : 'testing' }
TParseNode >> isVariable [

	^false
]

{ #category : 'accessing' }
TParseNode >> nameOrValue [

	self error: 'object is neither variable nor constant'
]

{ #category : 'testing' }
TParseNode >> needsTrailingSemicolon [
	"Answer if, when emitted as a statement (in particular in a TStmtList), the
	 receiver needs a trailing semicolon.  Subclasses redefine as appropriate."
	^true
]

{ #category : 'enumerating' }
TParseNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	aBlock value: self
]

{ #category : 'enumerating' }
TParseNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	self subclassResponsibility
]

{ #category : 'enumerating' }
TParseNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [
	"Evaluate aBlock for all nodes in  the tree except those for which cautionaryBlock
	 answers true or are children of those for which cautionaryBlock answers true."
	(cautionaryBlock value: self value: parent) ifFalse:
		[aBlock value: self value: parent]
]

{ #category : 'enumerating' }
TParseNode >> nodesDo: aBlock unless: cautionaryBlock [
	"Evaluate aBlock for all nodes in  the tree except those for which cautionaryBlock
	 answers true or are children of those for which cautionaryBlock answers true."
	(cautionaryBlock value: self) ifFalse:
		[aBlock value: self]
]

{ #category : 'enumerating' }
TParseNode >> nodesWithParentsDo: aBlock [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	self nodesDo: aBlock parent: nil
]

{ #category : 'enumerating' }
TParseNode >> nodesWithParentsDo: aBlock unless: cautionaryBlock [
	"Evaluate aBlock for all nodes in the tree and their parent except those for which
	 cautionaryBlock answers true or are children of those for which cautionaryBlock
	 answers true. Cautionary block is invoked with node and parent.  parent may be nil."
	self nodesDo: aBlock parent: nil unless: cautionaryBlock
]

{ #category : 'enumerating' }
TParseNode >> noneSatisfy: aBlock [
	self nodesDo: [:n| (aBlock value: n) ifTrue: [^false]].
	^true
]

{ #category : 'enumerating' }
TParseNode >> noneSatisfy: aBlock unless: cautionaryBlock [
	self
		nodesDo: [:n| (aBlock value: n) ifTrue: [^false]]
		unless: cautionaryBlock.
	^true
]

{ #category : 'enumerating' }
TParseNode >> occurrencesOf: aNode [
	| count |
	count := 0.
	self nodesDo:
		[:node|
		node = aNode ifTrue: [count := count + 1]].
	^count
]

{ #category : 'accessing' }
TParseNode >> parent [

	^ parent
]

{ #category : 'accessing' }
TParseNode >> parent: anObject [

	parent := anObject
]

{ #category : 'printing' }
TParseNode >> printOn: aStream [ 
	"Append a description of the receiver onto the given stream."

	self printOn: aStream level: 0.
]

{ #category : 'printing' }
TParseNode >> printOn: aStream level: anInteger [ 
	"Typically overridden. If control actually gets here, avoid recursion loop by sending to super."

	super printOn: aStream.
]

{ #category : 'transformations' }
TParseNode >> removeAssertions [
	"default: do nothing"
]

{ #category : 'dead-code-elimination' }
TParseNode >> removeUnusedNodesInBranch: aChild [
	"this method should be only called when cleaning an AST tree after an unused expression was found"

	self children remove: aChild.
	(self children isEmpty or: [ self hasNothingButComments ]) ifTrue: [
		self parent removeUnusedNodesInBranch: self ]
]

{ #category : 'transformations' }
TParseNode >> replaceBy: aNode [

	self parent replaceChild: self with: aNode
]

{ #category : 'transformations' }
TParseNode >> replaceChild: aNode with: aReplacementNode [

	self subclassResponsibility
]

{ #category : 'transformations' }
TParseNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [self]
]

{ #category : 'enumerating' }
TParseNode >> select: aBlock [
	| nodes |
	nodes := OrderedCollection new.
	self nodesDo: [:n| (aBlock value: n) ifTrue: [nodes add: n]].
	^nodes
]

{ #category : 'testing' }
TParseNode >> structTargetKindIn: aCodeGen [
	"Answer if the recever evaluates to a struct or struct pointer
	 and hence can be dereferenced using . or ->.  Answer any of
	 #struct #pointer or nil"
	^nil
]

{ #category : 'accessing' }
TParseNode >> tMethod [

	"Climb up the parent links up to the TMethod node"

	| n |
	n := self.
	[ true ] whileTrue: [
		n ifNil: [ ^ nil ].
		n class == TMethod ifTrue: [ ^ n ].
		n := n parent ]
]

{ #category : 'type inference' }
TParseNode >> typeFrom: aCodeGenerator in: aTMethod [
	"This is the default type in case of doubt"
	^(self typeOrNilFrom: aCodeGenerator in: aTMethod)
		ifNil: [ aCodeGenerator defaultType ]
]

{ #category : 'type inference' }
TParseNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	"When we don't know, it's nil"
	^nil
]

{ #category : 'accessing' }
TParseNode >> variableNameOrNil [
	"Overridden in TAssignmentNode & TVariableNode to answer their variable name."
	^nil
]
