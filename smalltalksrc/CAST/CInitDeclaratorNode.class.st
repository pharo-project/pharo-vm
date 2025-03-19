Class {
	#name : 'CInitDeclaratorNode',
	#superclass : 'CAbstractDeclaratorNode',
	#instVars : [
		'initializer'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CInitDeclaratorNode class >> declarator: aDeclarator initializer: anInitializer [
	
	^ self new
		declarator: aDeclarator;
		initializer: anInitializer;
		yourself
]

{ #category : 'comparing' }
CInitDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ initializer = anObject initializer and: [ 
		  declarator = anObject declarator ]
]

{ #category : 'generated' }
CInitDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitInitDeclarator: self
]

{ #category : 'comparing' }
CInitDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ initializer hash bitXor: declarator hash
]

{ #category : 'generated' }
CInitDeclaratorNode >> initializer [
	^ initializer
]

{ #category : 'generated' }
CInitDeclaratorNode >> initializer: aCGLRAbstractNode [
	self initializer notNil
		ifTrue: [ self initializer parent: nil ].
	initializer := aCGLRAbstractNode.
	self initializer notNil
		ifTrue: [ self initializer parent: self ]
]

{ #category : 'testing' }
CInitDeclaratorNode >> isInitializerDeclarator [
	
	^ true
]
