Class {
	#name : #CCallNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'arguments',
		'identifier'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CCallNode class >> identifier: anIndentifier [
	
	^ self identifier: anIndentifier arguments: #()
]

{ #category : #'instance creation' }
CCallNode class >> identifier: anIndentifier arguments: anOrderdList [
	
	^ self new
		identifier: anIndentifier;
		arguments: anOrderdList;
		yourself
]

{ #category : #generated }
CCallNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitCall: self
]

{ #category : #generated }
CCallNode >> arguments [
	^ arguments
]

{ #category : #generated }
CCallNode >> arguments: anOrderedCollection [
	self setParents: self arguments to: nil.
	arguments := anOrderedCollection.
	self setParents: self arguments to: self
]

{ #category : #generated }
CCallNode >> identifier [
	^ identifier
]

{ #category : #generated }
CCallNode >> identifier: aCGLRAbstractNode [
	self identifier notNil
		ifTrue: [ self identifier parent: nil ].
	identifier := aCGLRAbstractNode.
	self identifier notNil
		ifTrue: [ self identifier parent: self ]
]

{ #category : #'generated-initialize-release' }
CCallNode >> initialize [
	super initialize.
	arguments := OrderedCollection new: 2.
]

{ #category : #testing }
CCallNode >> isFunctionCall [
	
	^ true
]
