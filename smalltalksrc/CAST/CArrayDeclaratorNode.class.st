Class {
	#name : 'CArrayDeclaratorNode',
	#superclass : 'CAbstractDeclaratorNode',
	#instVars : [
		'size'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'comparing' }
CArrayDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ size = anObject size and: [ declarator = anObject declarator ]
]

{ #category : 'generated' }
CArrayDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitArrayDeclarator: self
]

{ #category : 'comparing' }
CArrayDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ size hash bitXor: declarator hash
]

{ #category : 'testing' }
CArrayDeclaratorNode >> isArrayDeclarator [
	
	^ true
]

{ #category : 'generated' }
CArrayDeclaratorNode >> size [
	^ size
]

{ #category : 'generated' }
CArrayDeclaratorNode >> size: aCGLRAbstractNode [
	self size notNil
		ifTrue: [ self size parent: nil ].
	size := aCGLRAbstractNode.
	self size notNil
		ifTrue: [ self size parent: self ]
]
