Class {
	#name : #CGLRDoStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'statement',
		'while'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRDoStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitDoStatement: self
]

{ #category : #generated }
CGLRDoStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CGLRDoStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]

{ #category : #generated }
CGLRDoStatementNode >> while [
	^ while
]

{ #category : #generated }
CGLRDoStatementNode >> while: aCGLRExpressionNode [
	self while notNil
		ifTrue: [ self while parent: nil ].
	while := aCGLRExpressionNode.
	self while notNil
		ifTrue: [ self while parent: self ]
]
