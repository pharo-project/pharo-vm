Class {
	#name : #CConstantNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CConstantNode class >> value: aValue [

	^ self new
		value: aValue;
		yourself
]

{ #category : #comparing }
CConstantNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ value = anObject value
]

{ #category : #generated }
CConstantNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitConstant: self
]

{ #category : #comparing }
CConstantNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ value hash
]

{ #category : #testing }
CConstantNode >> isConstant [
	
	^ true
]

{ #category : #generated }
CConstantNode >> value [
	^ value
]

{ #category : #generated }
CConstantNode >> value: aSmaCCToken [
	value := aSmaCCToken
]
