Class {
	#name : #CBinaryOperatorNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'left',
		'right',
		'operator'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CBinaryOperatorNode class >> operator: aString left: lexpression right: rexpression [
	
	^ self new
		operator: aString;
		left: lexpression;
		right: rexpression;
		yourself
]

{ #category : #generated }
CBinaryOperatorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitBinary: self
]

{ #category : #testing }
CBinaryOperatorNode >> isBinaryOperation [
	
	^ true
]

{ #category : #generated }
CBinaryOperatorNode >> left [
	^ left
]

{ #category : #generated }
CBinaryOperatorNode >> left: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.
	
	self left notNil
		ifTrue: [ self left parent: nil ].
	left := aCGLRAbstractNode.
	self left notNil
		ifTrue: [ self left parent: self ]
]

{ #category : #generated }
CBinaryOperatorNode >> operator [
	^ operator
]

{ #category : #generated }
CBinaryOperatorNode >> operator: aSmaCCToken [
	operator := aSmaCCToken
]

{ #category : #generated }
CBinaryOperatorNode >> right [
	^ right
]

{ #category : #generated }
CBinaryOperatorNode >> right: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.
	
	self right notNil
		ifTrue: [ self right parent: nil ].
	right := aCGLRAbstractNode.
	self right notNil
		ifTrue: [ self right parent: self ]
]
