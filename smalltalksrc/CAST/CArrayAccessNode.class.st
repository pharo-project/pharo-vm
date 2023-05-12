Class {
	#name : #CArrayAccessNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'array',
		'index'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CArrayAccessNode class >> array: anIdentifierNode index: anExpressionNode [

	^ self new
		  array: anIdentifierNode;
		  index: anExpressionNode;
		  yourself
]

{ #category : #generated }
CArrayAccessNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitArray: self
]

{ #category : #generated }
CArrayAccessNode >> array [
	^ array
]

{ #category : #generated }
CArrayAccessNode >> array: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.
	
	self array notNil
		ifTrue: [ self array parent: nil ].
	array := aCGLRAbstractNode.
	self array notNil
		ifTrue: [ self array parent: self ]
]

{ #category : #generated }
CArrayAccessNode >> index [
	^ index
]

{ #category : #generated }
CArrayAccessNode >> index: aCGLRExpressionNode [
	self assertExpression: aCGLRExpressionNode.
	
	self index notNil
		ifTrue: [ self index parent: nil ].
	index := aCGLRExpressionNode.
	self index notNil
		ifTrue: [ self index parent: self ]
]

{ #category : #testing }
CArrayAccessNode >> isArrayAccessNode [
	
	^ true
]
