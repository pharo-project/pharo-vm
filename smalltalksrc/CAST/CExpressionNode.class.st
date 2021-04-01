Class {
	#name : #CExpressionNode,
	#superclass : #CGLRAbstractNode,
	#category : #'CAST-Nodes'
}

{ #category : #combining }
CExpressionNode >> , anotherExpression [
	
	^ anotherExpression combineWithExpression: self
]

{ #category : #generated }
CExpressionNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitExpression: self
]

{ #category : #combining }
CExpressionNode >> combineWithExpression: firstExpression [
	
	| result |
	result := CExpressionListNode new.
	result add: firstExpression.
	result add: self.
	^ result
]

{ #category : #testing }
CExpressionNode >> isExpression [

	^ true
]
