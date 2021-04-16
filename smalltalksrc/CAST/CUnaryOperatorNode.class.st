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

{ #category : #'instance creation' }
CUnaryOperatorNode class >> operator: anOperator expression: anExpression [

	^ self new
		  operator: anOperator;
		  expression: anExpression;
		  yourself
]

{ #category : #generated }
CUnaryOperatorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitUnaryOperator: self
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
