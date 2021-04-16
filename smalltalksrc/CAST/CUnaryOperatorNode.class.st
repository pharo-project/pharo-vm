Class {
	#name : #CUnaryOperatorNode,
	#superclass : #CExpressionNode,
	#instVars : [
		'expr',
		'operator'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CUnaryOperatorNode class >> operator: anOperator expression: anExpression [

	^ self new
		  operator: anOperator;
		  expression: anExpression;
		  yourself
]

{ #category : #generated }
CUnaryOperatorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitUnaryOperator: self
]

{ #category : #generated }
CUnaryOperatorNode >> expression [
	^ expr
]

{ #category : #generated }
CUnaryOperatorNode >> expression: anObject [
	expr := anObject
]

{ #category : #generated }
CUnaryOperatorNode >> isUnaryOperation [
	^ true
]

{ #category : #generated }
CUnaryOperatorNode >> operator [
	^ operator
]

{ #category : #generated }
CUnaryOperatorNode >> operator: aSmaCCToken [
	operator := aSmaCCToken
]
