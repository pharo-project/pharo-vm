Class {
	#name : #CGLRUnaryExpressionNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'expr',
		'sizeofToken',
		'type',
		'operator'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRUnaryExpressionNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitUnaryExpression: self
]

{ #category : #generated }
CGLRUnaryExpressionNode >> expression [
	^ expr
]

{ #category : #generated }
CGLRUnaryExpressionNode >> expression: anObject [
	expr := anObject
]

{ #category : #generated }
CGLRUnaryExpressionNode >> operator [
	^ operator
]

{ #category : #generated }
CGLRUnaryExpressionNode >> operator: aSmaCCToken [
	operator := aSmaCCToken
]

{ #category : #generated }
CGLRUnaryExpressionNode >> sizeofToken [
	^ sizeofToken
]

{ #category : #generated }
CGLRUnaryExpressionNode >> sizeofToken: aSmaCCToken [
	sizeofToken := aSmaCCToken
]

{ #category : #generated }
CGLRUnaryExpressionNode >> type [
	^ type
]

{ #category : #generated }
CGLRUnaryExpressionNode >> type: aCGLRTypeNameNode [
	self type notNil
		ifTrue: [ self type parent: nil ].
	type := aCGLRTypeNameNode.
	self type notNil
		ifTrue: [ self type parent: self ]
]
