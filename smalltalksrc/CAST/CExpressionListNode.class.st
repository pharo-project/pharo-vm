Class {
	#name : 'CExpressionListNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'expressions',
		'printOnMultipleLines'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'adding' }
CExpressionListNode >> , anotherExpression [
	
	self add: anotherExpression.
	^ self
]

{ #category : 'adding' }
CExpressionListNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitExpressionList: self
]

{ #category : 'adding' }
CExpressionListNode >> add: anExpression [
	
	expressions add: anExpression
]

{ #category : 'adding' }
CExpressionListNode >> combineWithExpression: firstExpression [
	
	| result |
	self assertExpression: firstExpression.
	
	result := CExpressionListNode new.
	result add: firstExpression.
	expressions do: [ :expr |
		result add: expr ].
	^ result
]

{ #category : 'generated' }
CExpressionListNode >> expressions [
	^ expressions
]

{ #category : 'generated' }
CExpressionListNode >> expressions: anOrderedCollection [
	self assertListOfExpressions: anOrderedCollection.

	self setParents: self expressions to: nil.
	expressions := anOrderedCollection.
	self setParents: self expressions to: self
]

{ #category : 'generated-initialize-release' }
CExpressionListNode >> initialize [
	super initialize.
	expressions := OrderedCollection new: 2.
	printOnMultipleLines := false.
]

{ #category : 'testing' }
CExpressionListNode >> isCommaSeparatedExpression [

	^ true
]

{ #category : 'accessing' }
CExpressionListNode >> printOnMultipleLines [

	^ printOnMultipleLines
]

{ #category : 'accessing' }
CExpressionListNode >> printOnMultipleLines: aBoolean [

	printOnMultipleLines := aBoolean
]
