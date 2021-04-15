Class {
	#name : #CUnaryOperatorNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'expr',
		'sizeofToken',
		'type',
		'operator'
	],
	#category : #'CAST-Nodes'
}

{ #category : #generated }
CUnaryOperatorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitUnaryExpression: self
]

{ #category : #generated }
CUnaryOperatorNode >> expression [
	^ expr
]

{ #category : #generated }
CUnaryOperatorNode >> expression: anObject [
	expr := anObject
]

{ #category : #generated }
CUnaryOperatorNode >> operator [
	^ operator
]

{ #category : #generated }
CUnaryOperatorNode >> operator: aSmaCCToken [
	operator := aSmaCCToken
]

{ #category : #generated }
CUnaryOperatorNode >> sizeofToken [
	^ sizeofToken
]

{ #category : #generated }
CUnaryOperatorNode >> sizeofToken: aSmaCCToken [
	sizeofToken := aSmaCCToken
]

{ #category : #generated }
CUnaryOperatorNode >> type [
	^ type
]

{ #category : #generated }
CUnaryOperatorNode >> type: aCGLRTypeNameNode [
	self type notNil
		ifTrue: [ self type parent: nil ].
	type := aCGLRTypeNameNode.
	self type notNil
		ifTrue: [ self type parent: self ]
]
