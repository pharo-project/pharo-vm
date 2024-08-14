Class {
	#name : 'CSizeofNode',
	#superclass : 'CExpressionNode',
	#instVars : [
		'child'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CSizeofNode class >> operator: anOperator expression: anExpression [

	^ self new
		  operator: anOperator;
		  expression: anExpression;
		  yourself
]

{ #category : 'generated' }
CSizeofNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitSizeof: self
]

{ #category : 'accessing' }
CSizeofNode >> child [

	^ child
]

{ #category : 'accessing' }
CSizeofNode >> child: anObject [
	self assertExpression: anObject.
	
	child := anObject
]

{ #category : 'accessing' }
CSizeofNode >> isSizeof [ 

	^ true
]
