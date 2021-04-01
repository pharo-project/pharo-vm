Class {
	#name : #CGLRForStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'init',
		'until',
		'statement',
		'step'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRForStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitForStatement: self
]

{ #category : #generated }
CGLRForStatementNode >> init [
	^ init
]

{ #category : #generated }
CGLRForStatementNode >> init: aCGLRExpressionStatementNode [
	self init notNil
		ifTrue: [ self init parent: nil ].
	init := aCGLRExpressionStatementNode.
	self init notNil
		ifTrue: [ self init parent: self ]
]

{ #category : #generated }
CGLRForStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CGLRForStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]

{ #category : #generated }
CGLRForStatementNode >> step [
	^ step
]

{ #category : #generated }
CGLRForStatementNode >> step: aCGLRExpressionNode [
	self step notNil
		ifTrue: [ self step parent: nil ].
	step := aCGLRExpressionNode.
	self step notNil
		ifTrue: [ self step parent: self ]
]

{ #category : #generated }
CGLRForStatementNode >> until [
	^ until
]

{ #category : #generated }
CGLRForStatementNode >> until: aCGLRExpressionStatementNode [
	self until notNil
		ifTrue: [ self until parent: nil ].
	until := aCGLRExpressionStatementNode.
	self until notNil
		ifTrue: [ self until parent: self ]
]
