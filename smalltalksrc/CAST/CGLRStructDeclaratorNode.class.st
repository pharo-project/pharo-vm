Class {
	#name : #CGLRStructDeclaratorNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'declarator',
		'_size'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRStructDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStructDeclarator: self
]

{ #category : #generated }
CGLRStructDeclaratorNode >> declarator [
	^ declarator
]

{ #category : #generated }
CGLRStructDeclaratorNode >> declarator: aCGLRDeclaratorNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRDeclaratorNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : #generated }
CGLRStructDeclaratorNode >> size [
	^ _size
]

{ #category : #generated }
CGLRStructDeclaratorNode >> size: aCGLRAbstractNode [
	self size notNil
		ifTrue: [ self size parent: nil ].
	_size := aCGLRAbstractNode.
	self size notNil
		ifTrue: [ self size parent: self ]
]
