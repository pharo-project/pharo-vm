Class {
	#name : 'CPointerDeclaratorNode',
	#superclass : 'CAbstractDeclaratorNode',
	#instVars : [
		'pointers',
		'qualifiers'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'as yet unclassified' }
CPointerDeclaratorNode class >> declarator: aDeclarator pointers: numberOfPointers [
	
	^ (self declarator: aDeclarator)
		pointers: ((1 to: numberOfPointers) collect: [ :e | '*' ]);
		yourself
]

{ #category : 'comparing' }
CPointerDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ qualifiers = anObject qualifiers and: [ 
		  pointers = anObject pointers and: [ 
			  declarator = anObject declarator2 ] ]
]

{ #category : 'generated' }
CPointerDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitDeclarator: self
]

{ #category : 'accessing' }
CPointerDeclaratorNode >> declarator2 [

	^ declarator
]

{ #category : 'comparing' }
CPointerDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ qualifiers hash bitXor: (pointers hash bitXor: declarator hash)
]

{ #category : 'generated-initialize-release' }
CPointerDeclaratorNode >> initialize [
	super initialize.
	pointers := OrderedCollection new: 2.
	qualifiers := OrderedCollection new: 2.
]

{ #category : 'testing' }
CPointerDeclaratorNode >> isPointerDeclarator [
	
	^ true
]

{ #category : 'generated' }
CPointerDeclaratorNode >> pointers [
	^ pointers
]

{ #category : 'generated' }
CPointerDeclaratorNode >> pointers: anOrderedCollection [
	pointers := anOrderedCollection
]

{ #category : 'generated' }
CPointerDeclaratorNode >> qualifiers [
	^ qualifiers
]

{ #category : 'generated' }
CPointerDeclaratorNode >> qualifiers: anOrderedCollection [
	qualifiers := anOrderedCollection
]
