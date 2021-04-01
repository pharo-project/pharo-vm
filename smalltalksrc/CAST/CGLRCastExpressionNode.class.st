Class {
	#name : #CGLRCastExpressionNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'expr',
		'type',
		'leftParenToken',
		'rightParenToken'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRCastExpressionNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitCastExpression: self
]

{ #category : #generated }
CGLRCastExpressionNode >> expression [
	^ expr
]

{ #category : #generated }
CGLRCastExpressionNode >> expression: aCGLRAbstractNode [
	self expression notNil
		ifTrue: [ self expression parent: nil ].
	expr := aCGLRAbstractNode.
	self expression notNil
		ifTrue: [ self expression parent: self ]
]

{ #category : #generated }
CGLRCastExpressionNode >> type [
	^ type
]

{ #category : #generated }
CGLRCastExpressionNode >> type: aCGLRTypeNameNode [
	self type notNil
		ifTrue: [ self type parent: nil ].
	type := aCGLRTypeNameNode.
	self type notNil
		ifTrue: [ self type parent: self ]
]
