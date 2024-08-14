Class {
	#name : 'CIncrementNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'object',
		'prefix'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CIncrementNode class >> object: aVariable [
	
	^self new object: aVariable; prefix: false; yourself
]

{ #category : 'instance creation' }
CIncrementNode class >> object: aVariable prefix: boolean [
	
	^self new object: aVariable; prefix: boolean; yourself
]

{ #category : 'generated' }
CIncrementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitIncrement: self
]

{ #category : 'generated' }
CIncrementNode >> isIncrement [
	^ true
]

{ #category : 'generated' }
CIncrementNode >> object [
	^ object
]

{ #category : 'generated' }
CIncrementNode >> object: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.
	
	self object notNil
		ifTrue: [ self object parent: nil ].
	object := aCGLRAbstractNode.
	self object notNil
		ifTrue: [ self object parent: self ]
]

{ #category : 'accessing' }
CIncrementNode >> prefix [

	^ prefix
]

{ #category : 'accessing' }
CIncrementNode >> prefix: boolean [

	prefix := boolean
]
