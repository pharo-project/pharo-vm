Class {
	#name : #CGLRParameterDeclarationNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'specifiers',
		'declarator'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRParameterDeclarationNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitParameterDeclaration: self
]

{ #category : #generated }
CGLRParameterDeclarationNode >> declarator [
	^ declarator
]

{ #category : #generated }
CGLRParameterDeclarationNode >> declarator: aCGLRAbstractNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRAbstractNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : #'generated-initialize-release' }
CGLRParameterDeclarationNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
]

{ #category : #generated }
CGLRParameterDeclarationNode >> specifiers [
	^ specifiers
]

{ #category : #generated }
CGLRParameterDeclarationNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
