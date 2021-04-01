Class {
	#name : #CGLRStringLiteralNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'value'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRStringLiteralNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStringLiteral: self
]

{ #category : #generated }
CGLRStringLiteralNode >> value [
	^ value
]

{ #category : #generated }
CGLRStringLiteralNode >> value: aSmaCCToken [
	value := aSmaCCToken
]
