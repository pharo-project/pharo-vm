Class {
	#name : #CFunctionDeclaratorNode,
	#superclass : #CAbstractDeclaratorNode,
	#instVars : [
		'identifiers',
		'parameters',
		'ellipsis',
		'isPrototype'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CFunctionDeclaratorNode class >> declarator: aDeclarator parameters: parameters [

	^ self new
		  declarator: aDeclarator;
		  parameters: parameters;
		  yourself
]

{ #category : #comparing }
CFunctionDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ parameters = anObject parameters and: [ 
		  identifiers = anObject identifiers and: [ 
			  ellipsis = anObject ellipsis and: [ 
				  declarator = anObject declarator ] ] ]
]

{ #category : #generated }
CFunctionDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitFunctionDeclarator: self
]

{ #category : #generated }
CFunctionDeclaratorNode >> compositeNodeVariables [
	^ #(#parameters #identifiers)
]

{ #category : #generated }
CFunctionDeclaratorNode >> declarator [
	^ declarator
]

{ #category : #generated }
CFunctionDeclaratorNode >> declarator: aCGLRAbstractNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRAbstractNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : #generated }
CFunctionDeclaratorNode >> ellipsis [
	^ ellipsis
]

{ #category : #generated }
CFunctionDeclaratorNode >> ellipsis: aSmaCCToken [
	ellipsis := aSmaCCToken
]

{ #category : #comparing }
CFunctionDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ parameters hash bitXor:
		  (identifiers hash bitXor: (ellipsis hash bitXor: declarator hash))
]

{ #category : #generated }
CFunctionDeclaratorNode >> identifiers [
	^ identifiers
]

{ #category : #generated }
CFunctionDeclaratorNode >> identifiers: anOrderedCollection [
	self setParents: self identifiers to: nil.
	identifiers := anOrderedCollection.
	self setParents: self identifiers to: self
]

{ #category : #'generated-initialize-release' }
CFunctionDeclaratorNode >> initialize [

	super initialize.
	parameters := OrderedCollection new: 2.
	identifiers := OrderedCollection new: 2.
	isPrototype := false
]

{ #category : #testing }
CFunctionDeclaratorNode >> isFunctionDeclarator [
	
	^ true
]

{ #category : #accessing }
CFunctionDeclaratorNode >> isPrototype [

	^ isPrototype
]

{ #category : #accessing }
CFunctionDeclaratorNode >> isPrototype: aBoolean [

	isPrototype := aBoolean
]

{ #category : #generated }
CFunctionDeclaratorNode >> parameters [
	^ parameters
]

{ #category : #generated }
CFunctionDeclaratorNode >> parameters: anOrderedCollection [
	self setParents: self parameters to: nil.
	parameters := anOrderedCollection.
	self setParents: self parameters to: self
]
