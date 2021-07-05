Class {
	#name : #CSwitchStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'statement',
		'if'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CSwitchStatementNode class >> if: anExpression statement: aStatement [

	^ self new
		if: anExpression;
		statement: aStatement;
		yourself
]

{ #category : #generated }
CSwitchStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitSwitchStatement: self
]

{ #category : #generated }
CSwitchStatementNode >> if [
	^ if
]

{ #category : #generated }
CSwitchStatementNode >> if: aCGLRExpressionNode [
	self if notNil
		ifTrue: [ self if parent: nil ].
	if := aCGLRExpressionNode.
	self if notNil
		ifTrue: [ self if parent: self ]
]

{ #category : #testing }
CSwitchStatementNode >> isSwitch [
	
	^ true
]

{ #category : #testing }
CSwitchStatementNode >> needsSeparator [

	^ false
]

{ #category : #generated }
CSwitchStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CSwitchStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]
