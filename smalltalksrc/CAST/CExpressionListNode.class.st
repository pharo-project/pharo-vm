Class {
	#name : #CExpressionListNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'expressions'
	],
	#category : #'CAST-Nodes'
}

{ #category : #adding }
CExpressionListNode >> , anotherExpression [
	
	self add: anotherExpression.
	^ self
]

{ #category : #adding }
CExpressionListNode >> add: anExpression [
	
	expressions add: anExpression
]

{ #category : #adding }
CExpressionListNode >> combineWithExpression: firstExpression [
	
	| result |
	result := CExpressionListNode new.
	result add: firstExpression.
	expressions do: [ :expr |
		result add: expr ].
	^ result
]

{ #category : #generated }
CExpressionListNode >> expressions [
	^ expressions
]

{ #category : #generated }
CExpressionListNode >> expressions: anOrderedCollection [
	self setParents: self expressions to: nil.
	expressions := anOrderedCollection.
	self setParents: self expressions to: self
]

{ #category : #'generated-initialize-release' }
CExpressionListNode >> initialize [
	super initialize.
	expressions := OrderedCollection new: 2.
]

{ #category : #testing }
CExpressionListNode >> isCommaSeparatedExpression [

	^ true
]
