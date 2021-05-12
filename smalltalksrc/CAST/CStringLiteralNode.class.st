Class {
	#name : #CStringLiteralNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'value'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CStringLiteralNode class >> value: aString [

	^ self new
		  value: aString;
		  yourself
]

{ #category : #generated }
CStringLiteralNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStringLiteral: self
]

{ #category : #generated }
CStringLiteralNode >> value [
	^ value
]

{ #category : #generated }
CStringLiteralNode >> value: aSmaCCToken [
	value := aSmaCCToken
]
