Class {
	#name : #CGLRInitializerNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'initializers'
	],
	#category : #CAST
}

{ #category : #'instance creation' }
CGLRInitializerNode class >> initializers: aCollection [ 
	
	^ self new
		initializers: aCollection;
		yourself
]

{ #category : #comparing }
CGLRInitializerNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ initializers = anObject initializers
]

{ #category : #generated }
CGLRInitializerNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitInitializer: self
]

{ #category : #comparing }
CGLRInitializerNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ initializers hash
]

{ #category : #'generated-initialize-release' }
CGLRInitializerNode >> initialize [
	super initialize.
	initializers := OrderedCollection new: 2.
]

{ #category : #generated }
CGLRInitializerNode >> initializers [
	^ initializers
]

{ #category : #generated }
CGLRInitializerNode >> initializers: anOrderedCollection [
	self setParents: self initializers to: nil.
	initializers := anOrderedCollection.
	self setParents: self initializers to: self
]
