Class {
	#name : 'CGLRTypeNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'qualifiers',
		'specifiers',
		'abstract'
	],
	#category : 'CAST',
	#package : 'CAST'
}

{ #category : 'generated' }
CGLRTypeNode >> abstract [
	^ abstract
]

{ #category : 'generated' }
CGLRTypeNode >> abstract: aCGLRAbstractDeclaratorNode [
	self abstract notNil
		ifTrue: [ self abstract parent: nil ].
	abstract := aCGLRAbstractDeclaratorNode.
	self abstract notNil
		ifTrue: [ self abstract parent: self ]
]

{ #category : 'generated' }
CGLRTypeNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTypeName: self
]

{ #category : 'generated-initialize-release' }
CGLRTypeNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
	qualifiers := OrderedCollection new: 2.
]

{ #category : 'generated' }
CGLRTypeNode >> isTypeNode [
	^ true
]

{ #category : 'generated' }
CGLRTypeNode >> qualifiers [
	^ qualifiers
]

{ #category : 'generated' }
CGLRTypeNode >> qualifiers: anOrderedCollection [
	qualifiers := anOrderedCollection
]

{ #category : 'generated' }
CGLRTypeNode >> specifiers [
	^ specifiers
]

{ #category : 'generated' }
CGLRTypeNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
