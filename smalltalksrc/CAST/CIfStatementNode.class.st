Class {
	#name : #CIfStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'then',
		'else',
		'if'
	],
	#category : #'CAST-Nodes'
}

{ #category : #generated }
CIfStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitSelectionStatement: self
]

{ #category : #generated }
CIfStatementNode >> else [
	^ else
]

{ #category : #generated }
CIfStatementNode >> else: aCGLRAbstractNode [
	self else notNil
		ifTrue: [ self else parent: nil ].
	else := aCGLRAbstractNode.
	self else notNil
		ifTrue: [ self else parent: self ]
]

{ #category : #generated }
CIfStatementNode >> if [
	^ if
]

{ #category : #generated }
CIfStatementNode >> if: aCGLRExpressionNode [
	self if notNil
		ifTrue: [ self if parent: nil ].
	if := aCGLRExpressionNode.
	self if notNil
		ifTrue: [ self if parent: self ]
]

{ #category : #testing }
CIfStatementNode >> isIf [
	
	^ true
]

{ #category : #generated }
CIfStatementNode >> then [
	^ then
]

{ #category : #generated }
CIfStatementNode >> then: aCGLRAbstractNode [
	self then notNil
		ifTrue: [ self then parent: nil ].
	then := aCGLRAbstractNode.
	self then notNil
		ifTrue: [ self then parent: self ]
]
