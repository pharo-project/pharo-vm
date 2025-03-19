Class {
	#name : 'CMemberAccessNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'object',
		'member'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CMemberAccessNode class >> object: anObject member: aMember [

	^ self new
		  object: anObject;
		  member: aMember;
		  yourself
]

{ #category : 'generated' }
CMemberAccessNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitPoint: self
]

{ #category : 'testing' }
CMemberAccessNode >> isMemberAccess [
	
	^ true
]

{ #category : 'generated' }
CMemberAccessNode >> member [
	^ member
]

{ #category : 'generated' }
CMemberAccessNode >> member: aCGLRIdentifierNode [
	self member notNil
		ifTrue: [ self member parent: nil ].
	member := aCGLRIdentifierNode.
	self member notNil
		ifTrue: [ self member parent: self ]
]

{ #category : 'generated' }
CMemberAccessNode >> object [
	^ object
]

{ #category : 'generated' }
CMemberAccessNode >> object: aCGLRAbstractNode [

	self assertExpression: aCGLRAbstractNode.

	self object notNil
		ifTrue: [ self object parent: nil ].
	object := aCGLRAbstractNode.
	self object notNil
		ifTrue: [ self object parent: self ]
]
