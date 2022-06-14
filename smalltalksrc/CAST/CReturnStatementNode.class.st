Class {
	#name : #CReturnStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'expr'
	],
	#category : #'CAST-Nodes'
}

{ #category : #accessing }
CReturnStatementNode class >> expression: anExpression [

	^ self new
		expression: anExpression;
		yourself
]

{ #category : #generated }
CReturnStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitReturnStatement: self
]

{ #category : #generated }
CReturnStatementNode >> expression [
	^ expr
]

{ #category : #generated }
CReturnStatementNode >> expression: aCGLRExpressionNode [

	self assertExpression: aCGLRExpressionNode.
	
	self expression notNil
		ifTrue: [ self expression parent: nil ].
	expr := aCGLRExpressionNode withoutParentheses.
	self expression notNil
		ifTrue: [ self expression parent: self ]
]

{ #category : #testing }
CReturnStatementNode >> isExpression [
	
	^ false
]

{ #category : #testing }
CReturnStatementNode >> isReturn [
	
	^ true
]
