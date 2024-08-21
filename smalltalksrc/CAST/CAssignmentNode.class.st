Class {
	#name : 'CAssignmentNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'lvalue',
		'rvalue',
		'operator'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CAssignmentNode class >> lvalue: lvalue operator: aString rvalue: rvalue [
	
	^ self new
		lvalue: lvalue;
		operator: aString;
		rvalue: rvalue;
		yourself
]

{ #category : 'instance creation' }
CAssignmentNode class >> lvalue: lValue rvalue: rValue [

	^ self lvalue: lValue operator: '=' rvalue: rValue
]

{ #category : 'comparing' }
CAssignmentNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ rvalue = anObject rvalue and: [ 
		  operator = anObject operator and: [ lvalue = anObject lvalue ] ]
]

{ #category : 'generated' }
CAssignmentNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitAssignment: self
]

{ #category : 'comparing' }
CAssignmentNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ rvalue hash bitXor: (operator hash bitXor: lvalue hash)
]

{ #category : 'generated' }
CAssignmentNode >> lvalue [
	^ lvalue
]

{ #category : 'generated' }
CAssignmentNode >> lvalue: aCGLRAbstractNode [
	self lvalue notNil
		ifTrue: [ self lvalue parent: nil ].
	lvalue := aCGLRAbstractNode.
	self lvalue notNil
		ifTrue: [ self lvalue parent: self ]
]

{ #category : 'generated' }
CAssignmentNode >> operator [
	^ operator
]

{ #category : 'generated' }
CAssignmentNode >> operator: aSmaCCToken [
	operator := aSmaCCToken
]

{ #category : 'generated' }
CAssignmentNode >> rvalue [
	^ rvalue
]

{ #category : 'generated' }
CAssignmentNode >> rvalue: aCGLRAbstractNode [
	self assertExpression: aCGLRAbstractNode.

	self rvalue notNil
		ifTrue: [ self rvalue parent: nil ].
	rvalue := aCGLRAbstractNode.
	self rvalue notNil
		ifTrue: [ self rvalue parent: self ]
]
