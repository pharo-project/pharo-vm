Class {
	#name : #CDeclarationNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'specifiers',
		'declarators'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CDeclarationNode class >> specifiers: specifiers declarator: aDeclarator [
	
	^ self specifiers: specifiers declarators: {aDeclarator}
]

{ #category : #'instance creation' }
CDeclarationNode class >> specifiers: specifiers declarators: declarators [
	
	^ self new
		specifiers: specifiers;
		declarators: declarators;
		yourself
]

{ #category : #comparing }
CDeclarationNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ specifiers = anObject specifiers and: [ 
		  declarators = anObject declarators ]
]

{ #category : #generated }
CDeclarationNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitDeclaration: self
]

{ #category : #generated }
CDeclarationNode >> declarators [
	^ declarators
]

{ #category : #generated }
CDeclarationNode >> declarators: anOrderedCollection [
	self setParents: self declarators to: nil.
	declarators := anOrderedCollection.
	self setParents: self declarators to: self
]

{ #category : #comparing }
CDeclarationNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ specifiers hash bitXor: declarators hash
]

{ #category : #'generated-initialize-release' }
CDeclarationNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
	declarators := OrderedCollection new: 2.
]

{ #category : #generated }
CDeclarationNode >> specifiers [
	^ specifiers
]

{ #category : #generated }
CDeclarationNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
