Class {
	#name : 'CGLRStructDeclarationNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'declarators',
		'specifiers',
		'qualifiers'
	],
	#category : 'CAST',
	#package : 'CAST'
}

{ #category : 'generated' }
CGLRStructDeclarationNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStructDeclaration: self
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> declarators [
	^ declarators
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> declarators: anOrderedCollection [
	self setParents: self declarators to: nil.
	declarators := anOrderedCollection.
	self setParents: self declarators to: self
]

{ #category : 'generated-initialize-release' }
CGLRStructDeclarationNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
	qualifiers := OrderedCollection new: 2.
	declarators := OrderedCollection new: 2.
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> qualifiers [
	^ qualifiers
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> qualifiers: anOrderedCollection [
	qualifiers := anOrderedCollection
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> specifiers [
	^ specifiers
]

{ #category : 'generated' }
CGLRStructDeclarationNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
