Class {
	#name : #CGLRGotoStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'label'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRGotoStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitGotoStatement: self
]

{ #category : #generated }
CGLRGotoStatementNode >> label [
	^ label
]

{ #category : #generated }
CGLRGotoStatementNode >> label: aCGLRIdentifierNode [
	self label notNil
		ifTrue: [ self label parent: nil ].
	label := aCGLRIdentifierNode.
	self label notNil
		ifTrue: [ self label parent: self ]
]
