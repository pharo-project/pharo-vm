Class {
	#name : #CGLREnumNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'enumerators',
		'identifier'
	],
	#category : #CAST
}

{ #category : #generated }
CGLREnumNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitEnum: self
]

{ #category : #generated }
CGLREnumNode >> compositeNodeVariables [
	^ #(#enumerators)
]

{ #category : #generated }
CGLREnumNode >> enumerators [
	^ enumerators
]

{ #category : #generated }
CGLREnumNode >> enumerators: anOrderedCollection [
	self setParents: self enumerators to: nil.
	enumerators := anOrderedCollection.
	self setParents: self enumerators to: self
]

{ #category : #generated }
CGLREnumNode >> identifier [
	^ identifier
]

{ #category : #generated }
CGLREnumNode >> identifier: aCGLRIdentifierNode [
	self identifier notNil
		ifTrue: [ self identifier parent: nil ].
	identifier := aCGLRIdentifierNode.
	self identifier notNil
		ifTrue: [ self identifier parent: self ]
]

{ #category : #'generated-initialize-release' }
CGLREnumNode >> initialize [
	super initialize.
	enumerators := OrderedCollection new: 2.
]

{ #category : #generated }
CGLREnumNode >> nodeVariables [
	^ #(#identifier)
]
