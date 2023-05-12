Class {
	#name : #CGLREnumeratorNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'symbol',
		'expr'
	],
	#category : #CAST
}

{ #category : #generated }
CGLREnumeratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitEnumerator: self
]

{ #category : #generated }
CGLREnumeratorNode >> expression [
	^ expr
]

{ #category : #generated }
CGLREnumeratorNode >> expression: aCGLRAbstractNode [
	self expression notNil
		ifTrue: [ self expression parent: nil ].
	expr := aCGLRAbstractNode.
	self expression notNil
		ifTrue: [ self expression parent: self ]
]

{ #category : #generated }
CGLREnumeratorNode >> symbol [
	^ symbol
]

{ #category : #generated }
CGLREnumeratorNode >> symbol: aCGLRIdentifierNode [
	self symbol notNil
		ifTrue: [ self symbol parent: nil ].
	symbol := aCGLRIdentifierNode.
	self symbol notNil
		ifTrue: [ self symbol parent: self ]
]
