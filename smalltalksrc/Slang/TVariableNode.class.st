Class {
	#name : #TVariableNode,
	#superclass : #TParseNode,
	#instVars : [
		'name'
	],
	#category : #'Slang-AST'
}

{ #category : #'instance creation' }
TVariableNode class >> named: aName [

	^ self new
		setName: aName;
		yourself
]

{ #category : #'instance creation' }
TVariableNode class >> selfNode [

	^ self named: 'self'
]

{ #category : #visiting }
TVariableNode >> accept: aVisitor [
	
	^ aVisitor visitVariableNode: self
]

{ #category : #tranforming }
TVariableNode >> asCASTIn: aBuilder [

	aBuilder currentMethod ifNotNil: [ :m | m noteUsedVariableName: name ].
	^ name = 'nil'
		  ifTrue: [ CIdentifierNode name: aBuilder nilTranslation ]
		  ifFalse: [ 
		  CIdentifierNode name: (aBuilder returnPrefixFromVariable: name) ]
]

{ #category : #transformations }
TVariableNode >> bindVariableUsesIn: aDictionary [

	^ (aDictionary at: name ifAbsent: [^ self]) copy
]

{ #category : #transformations }
TVariableNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it is not a reference to one of the given variables, or the replacement if it is."
	^(aDictionary at: name ifAbsent: [^self]) copy
]

{ #category : #transformations }
TVariableNode >> bindVariablesIn: aDictionary [ 
	^ (aDictionary at: name ifAbsent: [^ self]) copy
]

{ #category : #transformations }
TVariableNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	^ (aDictionary at: name ifAbsent: [^ self]) copy
]

{ #category : #accessing }
TVariableNode >> children [
	
	^ #()
]

{ #category : #testing }
TVariableNode >> hasSideEffect [
	"Answer if the parse tree rooted at this node has a side-effect or not."
	^false
]

{ #category : #testing }
TVariableNode >> isLeaf [

	^true
]

{ #category : #comparing }
TVariableNode >> isSameAs: aTParseNode [
	^aTParseNode isVariable
	 and: [name = aTParseNode name]
]

{ #category : #testing }
TVariableNode >> isVariable [

	^true
]

{ #category : #accessing }
TVariableNode >> name [

	^name asString
]

{ #category : #accessing }
TVariableNode >> nameOrValue [

	^name
]

{ #category : #enumerating }
TVariableNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	aBlock value: self value: parent
]

{ #category : #printing }
TVariableNode >> printOn: aStream level: level [

	super printOn: aStream level: level.
	aStream
		nextPutAll: '(';
		nextPutAll: name;
		nextPutAll: ')'
]

{ #category : #accessing }
TVariableNode >> setName: aString [

	name := aString.
]

{ #category : #testing }
TVariableNode >> structTargetKindIn: aCodeGen [
	"Answer if the recever evaluates to a struct or struct pointer
	 and hence can be dereferenced using . or ->.  Answer any of
	 #struct #pointer or nil"
	^aCodeGen structTargetKindForVariableName: name
]

{ #category : #'type inference' }
TVariableNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	^aTMethod typeFor: self name in: aCodeGenerator
]

{ #category : #accessing }
TVariableNode >> variableNameOrNil [
	^name
]
