Class {
	#name : 'MLLinerarisedStatement',
	#superclass : 'Object',
	#instVars : [
		'expressionToLinearise'
	],
	#category : 'Slang-Optimizations',
	#package : 'Slang',
	#tag : 'Optimizations'
}

{ #category : 'building' }
MLLinerarisedStatement >> asExpressionIn: aMLStatementListBuider [ 
	
	"Expression value is used:
	  Add an assignment, add it as a statement and return the assigned variable"
	^ aMLStatementListBuider addLinearisedStatement: expressionToLinearise
]

{ #category : 'building' }
MLLinerarisedStatement >> asStatementIn: aMLStatementListBuider [ 
	
	"Expression value is not used"
	^ expressionToLinearise
]

{ #category : 'accessing' }
MLLinerarisedStatement >> expressionToLinearise [

	^ expressionToLinearise
]

{ #category : 'accessing' }
MLLinerarisedStatement >> expressionToLinearise: anObject [

	expressionToLinearise := anObject
]
