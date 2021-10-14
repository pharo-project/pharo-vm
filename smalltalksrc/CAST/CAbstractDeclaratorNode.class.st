Class {
	#name : #CAbstractDeclaratorNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'declarator'
	],
	#category : #'CAST-Nodes'
}

{ #category : #generated }
CAbstractDeclaratorNode class >> declarator: aDeclarator [
	
	^ self new
		declarator: aDeclarator;
		yourself
]

{ #category : #'instance creation' }
CAbstractDeclaratorNode class >> identifier: aString [ 
	
	^ self declarator: (CIdentifierNode name: aString)
]

{ #category : #comparing }
CAbstractDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ declarator = anObject declarator1
]

{ #category : #generated }
CAbstractDeclaratorNode >> declarator [
	^ declarator
]

{ #category : #accessing }
CAbstractDeclaratorNode >> declarator1 [

	^ declarator
]

{ #category : #generated }
CAbstractDeclaratorNode >> declarator: aCGLRAbstractNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRAbstractNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : #comparing }
CAbstractDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ declarator hash
]
