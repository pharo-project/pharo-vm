Class {
	#name : #CCastExpressionNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'expr',
		'type',
		'leftParenToken',
		'rightParenToken'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CCastExpressionNode class >> type: aType expression: anExpression [

	^ self new
		  type: aType;
		  expression: anExpression;
		  yourself
]

{ #category : #generated }
CCastExpressionNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitCastExpression: self
]

{ #category : #generated }
CCastExpressionNode >> expression [
	^ expr
]

{ #category : #generated }
CCastExpressionNode >> expression: aCGLRAbstractNode [

	self assertExpression: aCGLRAbstractNode.
	
	self expression notNil
		ifTrue: [ self expression parent: nil ].
	expr := aCGLRAbstractNode.
	self expression notNil
		ifTrue: [ self expression parent: self ]
]

{ #category : #generated }
CCastExpressionNode >> isCastExpression [
	^ true
]

{ #category : #generated }
CCastExpressionNode >> type [
	^ type
]

{ #category : #generated }
CCastExpressionNode >> type: aCGLRTypeNameNode [
	self type notNil
		ifTrue: [ self type parent: nil ].
	type := aCGLRTypeNameNode.
	self type notNil
		ifTrue: [ self type parent: self ]
]
