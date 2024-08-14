Class {
	#name : 'CRawCodeNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'code'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'accessing' }
CRawCodeNode class >> code: aString [

	^ self new
		  code: aString;
		  yourself
]

{ #category : 'visiting' }
CRawCodeNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitRawCode: self
]

{ #category : 'accessing' }
CRawCodeNode >> code [

	^ code
]

{ #category : 'accessing' }
CRawCodeNode >> code: anObject [

	code := anObject
]
