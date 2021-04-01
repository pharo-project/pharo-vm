Class {
	#name : #CGLRTernaryNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'condition',
		'else',
		'then'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRTernaryNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTernary: self
]

{ #category : #generated }
CGLRTernaryNode >> condition [
	^ condition
]

{ #category : #generated }
CGLRTernaryNode >> condition: aCGLRAbstractNode [
	self condition notNil
		ifTrue: [ self condition parent: nil ].
	condition := aCGLRAbstractNode.
	self condition notNil
		ifTrue: [ self condition parent: self ]
]

{ #category : #generated }
CGLRTernaryNode >> else [
	^ else
]

{ #category : #generated }
CGLRTernaryNode >> else: aCGLRAbstractNode [
	self else notNil
		ifTrue: [ self else parent: nil ].
	else := aCGLRAbstractNode.
	self else notNil
		ifTrue: [ self else parent: self ]
]

{ #category : #generated }
CGLRTernaryNode >> then [
	^ then
]

{ #category : #generated }
CGLRTernaryNode >> then: aCGLRExpressionNode [
	self then notNil
		ifTrue: [ self then parent: nil ].
	then := aCGLRExpressionNode.
	self then notNil
		ifTrue: [ self then parent: self ]
]
