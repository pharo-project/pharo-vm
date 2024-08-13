Class {
	#name : 'CTypeNameNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'symbol'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CTypeNameNode class >> symbol: aType [

	^ self new
		  symbol: aType;
		  yourself
]

{ #category : 'generated' }
CTypeNameNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTypename: self
]

{ #category : 'generated' }
CTypeNameNode >> isTypeName [

	^ true
]

{ #category : 'generated' }
CTypeNameNode >> symbol [
	^ symbol
]

{ #category : 'generated' }
CTypeNameNode >> symbol: aSmaCCToken [
	symbol := aSmaCCToken
]
