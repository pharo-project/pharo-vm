Class {
	#name : #CStringLiteralNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'value',
		'needsDoubleQuotes'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CStringLiteralNode class >> value: aString [

	^ self new
		  value: aString;
		  needsDoubleQuotes: true;
		  yourself
]

{ #category : #generated }
CStringLiteralNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStringLiteral: self
]

{ #category : #generated }
CStringLiteralNode >> isLeaf [

	^ true
]

{ #category : #accessing }
CStringLiteralNode >> needsDoubleQuotes [

	^ needsDoubleQuotes
]

{ #category : #accessing }
CStringLiteralNode >> needsDoubleQuotes: aBoolean [

	needsDoubleQuotes := aBoolean
]

{ #category : #generated }
CStringLiteralNode >> value [
	^ value
]

{ #category : #generated }
CStringLiteralNode >> value: aSmaCCToken [
	value := aSmaCCToken
]
