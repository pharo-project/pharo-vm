Class {
	#name : #MLStatementListBuider,
	#superclass : #Object,
	#instVars : [
		'parent',
		'statements',
		'expressionStack',
		'declarations',
		'codeGenerator'
	],
	#category : #'Slang-AST'
}

{ #category : #building }
MLStatementListBuider >> addStatement: aStatement [ 
	
	statements addLast: aStatement
]

{ #category : #transforming }
MLStatementListBuider >> assignLastExpressionOf: aNode toVariable: aTVariableNode [ 
	
	"We need to take the expression and find its last expression recursively.
	We should rewrite it to add an assignment to its last expression"
	
	| worklist |
	worklist := OrderedCollection with: aNode.
	[ worklist isEmpty ] whileFalse: [ | current |
		current := worklist removeLast.
		current isStatementList ifTrue: [ 
				worklist add: current last
			] ifFalse: [ | replacement parentBeforeReplacement |
				self flag: #polymorphism.
				parentBeforeReplacement := current parent.
				replacement := (current isSend and: [ #(#ifTrue: #ifFalse:) includes: current selector])
					ifTrue: [ self transformControlFlowNodeForValue: current withVariable: aTVariableNode copy ]
					ifFalse: [ current assignLastExpressionTo: aTVariableNode copy ].
				parentBeforeReplacement replaceChild: current with: replacement ] ].
	^ aNode
]

{ #category : #building }
MLStatementListBuider >> buildStatementList [
	
	"Build a statement list that could be in an expression.
	Add an explicit nil in case there were no expressions or statements in it"
	^ TStatementListNode
		declarations: declarations
		statements: (statements ifEmpty: [ { TConstantNode value: nil } ])
]

{ #category : #accessing }
MLStatementListBuider >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #building }
MLStatementListBuider >> finishStatement [
	
	"If there was an unused expression yet in the stack, pop it and add it as a statement"
	expressionStack ifEmpty: [ ^ self ].
	self popNoValue
]

{ #category : #initialization }
MLStatementListBuider >> initialize [

	super initialize.
	statements := OrderedCollection new.
	expressionStack := OrderedCollection new.
	declarations := Dictionary new
]

{ #category : #testing }
MLStatementListBuider >> isBlockClosure [
	"If the lexical parent is nil we are in top context => method
	else => closure"
	^ parent notNil
]

{ #category : #building }
MLStatementListBuider >> newVariableName [

	^ 't' , statements size asString
]

{ #category : #accessing }
MLStatementListBuider >> parent [

	^ parent
]

{ #category : #accessing }
MLStatementListBuider >> parent: anObject [

	parent := anObject
]

{ #category : #building }
MLStatementListBuider >> pop [

	"Add the expression when used"

	| expressionNode name assignment declaration |
	
	self flag: #rewrite.
	"Could we rewrite this to self popNoValue assignLastExpressionTo: var ?"
	
	expressionNode := expressionStack removeLast.

	"If it's a variable or constant, just return it, the caller will use it in the right place"
	(expressionNode isLeaf or: [ expressionNode isStatementList ]) 
		ifTrue: [ ^ expressionNode ].

	"If it's a control flow structure, and we are using it's value, write its last expression to a variable:
	v ifTrue: [ r := ... ] ifFalse: [ r := ...].
	Return the value r that is holding the result"
	(codeGenerator isControlFlowNode: expressionNode) ifTrue: [ | variable |
		variable := TVariableNode named: self newVariableName.
		self addStatement: (self
			transformControlFlowNodeForValue: expressionNode
			withVariable: variable).
		^ variable ].

	name := self newVariableName.
	declaration := (codeGenerator
		                typeFor: expressionNode
		                in: codeGenerator currentMethod) , ' ' , name.
	declarations at: name put: declaration.

	assignment := TAssignmentNode
		              variableNamed: name
		              expression: expressionNode.
	self addStatement: assignment.
	^ assignment variable
]

{ #category : #building }
MLStatementListBuider >> popNoValue [

	"Add the expression when used"	
	| expressionNode  |
	expressionNode := expressionStack removeLast.
	
	"If it's a variable or constant, just return it, the caller will use it in the right place"
	(expressionNode isLeaf
		or: [ expressionNode isStatementList ]) ifTrue: [
		^ expressionNode
	].

	self addStatement: expressionNode
]

{ #category : #building }
MLStatementListBuider >> push: anExpression [

	"pushes an expression to add it as a new statement"
	expressionStack addLast: anExpression
]

{ #category : #'control-flow' }
MLStatementListBuider >> transformControlFlowNodeForValue: aTSendNode withVariable: aVariable [
	
	| arguments |
	arguments := {
		self assignLastExpressionOf: aTSendNode arguments first toVariable: aVariable copy.
		TStatementListNode statements: { TAssignmentNode variable: aVariable copy expression: aTSendNode receiver }
	}.
	
	aTSendNode selector = #ifFalse: ifTrue: [
		arguments := arguments reversed ].
	
	^ TSendNode
		receiver: aTSendNode receiver
		selector: #ifTrue:ifFalse:
		arguments: arguments
]
