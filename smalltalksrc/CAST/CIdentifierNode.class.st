Class {
	#name : #CIdentifierNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'name'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CIdentifierNode class >> name: aString [ 
	
	^ self new
		name: aString;
		yourself
]

{ #category : #comparing }
CIdentifierNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ name = anObject name
]

{ #category : #generated }
CIdentifierNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitIdentifier: self
]

{ #category : #comparing }
CIdentifierNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ name hash
]

{ #category : #testing }
CIdentifierNode >> isIdentifier [
	
	^ true
]

{ #category : #testing }
CIdentifierNode >> isLeaf [
	
	^ true
]

{ #category : #accessing }
CIdentifierNode >> name [
	
	^ name
]

{ #category : #accessing }
CIdentifierNode >> name: aName [
	
	name := aName
]
