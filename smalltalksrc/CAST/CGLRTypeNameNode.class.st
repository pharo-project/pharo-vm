Class {
	#name : #CGLRTypeNameNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'qualifiers',
		'specifiers',
		'abstract'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRTypeNameNode >> abstract [
	^ abstract
]

{ #category : #generated }
CGLRTypeNameNode >> abstract: aCGLRAbstractDeclaratorNode [
	self abstract notNil
		ifTrue: [ self abstract parent: nil ].
	abstract := aCGLRAbstractDeclaratorNode.
	self abstract notNil
		ifTrue: [ self abstract parent: self ]
]

{ #category : #generated }
CGLRTypeNameNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTypeName: self
]

{ #category : #'generated-initialize-release' }
CGLRTypeNameNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
	qualifiers := OrderedCollection new: 2.
]

{ #category : #generated }
CGLRTypeNameNode >> qualifiers [
	^ qualifiers
]

{ #category : #generated }
CGLRTypeNameNode >> qualifiers: anOrderedCollection [
	qualifiers := anOrderedCollection
]

{ #category : #generated }
CGLRTypeNameNode >> specifiers [
	^ specifiers
]

{ #category : #generated }
CGLRTypeNameNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
