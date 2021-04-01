Class {
	#name : #CWhileStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'statement',
		'while'
	],
	#category : #'CAST-Nodes'
}

{ #category : #generated }
CWhileStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitWhileStatement: self
]

{ #category : #testing }
CWhileStatementNode >> isWhile [
	
	^ true
]

{ #category : #generated }
CWhileStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CWhileStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]

{ #category : #generated }
CWhileStatementNode >> while [
	^ while
]

{ #category : #generated }
CWhileStatementNode >> while: aCGLRExpressionNode [
	self while notNil
		ifTrue: [ self while parent: nil ].
	while := aCGLRExpressionNode.
	self while notNil
		ifTrue: [ self while parent: self ]
]
