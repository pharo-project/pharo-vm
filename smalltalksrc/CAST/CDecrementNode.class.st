Class {
	#name : #CDecrementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'object',
		'prefix'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CDecrementNode class >> object: aVariable [
	
	^self new object: aVariable; prefix: false; yourself
]

{ #category : #'instance creation' }
CDecrementNode class >> object: aVariable prefix: boolean [
	
	^self new object: aVariable; prefix: boolean; yourself
]

{ #category : #generated }
CDecrementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitDecrement: self
]

{ #category : #testing }
CDecrementNode >> isDecrement [

	^ true
]

{ #category : #generated }
CDecrementNode >> nodeVariables [
	^ #(#object)
]

{ #category : #generated }
CDecrementNode >> object [
	^ object
]

{ #category : #generated }
CDecrementNode >> object: aCGLRAbstractNode [
	self object notNil
		ifTrue: [ self object parent: nil ].
	object := aCGLRAbstractNode.
	self object notNil
		ifTrue: [ self object parent: self ]
]

{ #category : #acccessing }
CDecrementNode >> prefix [

	^ prefix
]

{ #category : #acccessing }
CDecrementNode >> prefix: boolean [

	prefix := boolean
]
