Class {
	#name : #CGLRIncrementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'object'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRIncrementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitIncrement: self
]

{ #category : #generated }
CGLRIncrementNode >> object [
	^ object
]

{ #category : #generated }
CGLRIncrementNode >> object: aCGLRAbstractNode [
	self object notNil
		ifTrue: [ self object parent: nil ].
	object := aCGLRAbstractNode.
	self object notNil
		ifTrue: [ self object parent: self ]
]
