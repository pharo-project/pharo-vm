Class {
	#name : #CGLRSwitchStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'statement',
		'if'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRSwitchStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitSwitchStatement: self
]

{ #category : #generated }
CGLRSwitchStatementNode >> if [
	^ if
]

{ #category : #generated }
CGLRSwitchStatementNode >> if: aCGLRExpressionNode [
	self if notNil
		ifTrue: [ self if parent: nil ].
	if := aCGLRExpressionNode.
	self if notNil
		ifTrue: [ self if parent: self ]
]

{ #category : #generated }
CGLRSwitchStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CGLRSwitchStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]
