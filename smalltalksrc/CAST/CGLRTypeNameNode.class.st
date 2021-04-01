Class {
	#name : #CGLRTypeNameNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'symbol'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRTypeNameNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTypename: self
]

{ #category : #generated }
CGLRTypeNameNode >> symbol [
	^ symbol
]

{ #category : #generated }
CGLRTypeNameNode >> symbol: aSmaCCToken [
	symbol := aSmaCCToken
]
