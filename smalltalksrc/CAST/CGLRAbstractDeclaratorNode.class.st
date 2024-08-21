Class {
	#name : 'CGLRAbstractDeclaratorNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'pointers',
		'qualifiers',
		'direct'
	],
	#category : 'CAST',
	#package : 'CAST'
}

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitAbstractDeclarator: self
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> direct [
	^ direct
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> direct: aCGLRAbstractNode [
	self direct notNil
		ifTrue: [ self direct parent: nil ].
	direct := aCGLRAbstractNode.
	self direct notNil
		ifTrue: [ self direct parent: self ]
]

{ #category : 'generated-initialize-release' }
CGLRAbstractDeclaratorNode >> initialize [
	super initialize.
	pointers := OrderedCollection new: 2.
	qualifiers := OrderedCollection new: 2.
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> pointers [
	^ pointers
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> pointers: anOrderedCollection [
	pointers := anOrderedCollection
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> qualifiers [
	^ qualifiers
]

{ #category : 'generated' }
CGLRAbstractDeclaratorNode >> qualifiers: anOrderedCollection [
	qualifiers := anOrderedCollection
]
