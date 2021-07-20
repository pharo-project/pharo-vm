Class {
	#name : #CStructurePointerAccessNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'member',
		'structurePointer'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CStructurePointerAccessNode class >> structurePointer: aPointer member: aMember [

	^ self new
		  structurePointer: aPointer;
		  member: aMember;
		  yourself
]

{ #category : #generated }
CStructurePointerAccessNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitArrow: self
]

{ #category : #testing }
CStructurePointerAccessNode >> isStructPointerAccess [
	
	^ true
]

{ #category : #generated }
CStructurePointerAccessNode >> member [
	^ member
]

{ #category : #generated }
CStructurePointerAccessNode >> member: aCGLRIdentifierNode [
	self member notNil
		ifTrue: [ self member parent: nil ].
	member := aCGLRIdentifierNode.
	self member notNil
		ifTrue: [ self member parent: self ]
]

{ #category : #accessing }
CStructurePointerAccessNode >> structurePointer [
	
	^ structurePointer
]

{ #category : #generated }
CStructurePointerAccessNode >> structurePointer: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.

	self structurePointer notNil
		ifTrue: [ self structurePointer parent: nil ].
	structurePointer := aCGLRAbstractNode.
	self structurePointer notNil
		ifTrue: [ self structurePointer parent: self ]
]
