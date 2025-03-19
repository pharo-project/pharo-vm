Class {
	#name : 'CDoStatementNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'statement',
		'while'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CDoStatementNode class >> while: aConditionExpression statement: aStatement [

	^ self new
		  while: aConditionExpression;
		  statement: aStatement;
		  yourself
]

{ #category : 'generated' }
CDoStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitDoStatement: self
]

{ #category : 'generated' }
CDoStatementNode >> isDoWhile [

	^true
]

{ #category : 'generated' }
CDoStatementNode >> statement [
	^ statement
]

{ #category : 'generated' }
CDoStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]

{ #category : 'generated' }
CDoStatementNode >> while [
	^ while
]

{ #category : 'generated' }
CDoStatementNode >> while: aCGLRExpressionNode [
	self while notNil
		ifTrue: [ self while parent: nil ].
	while := aCGLRExpressionNode.
	self while notNil
		ifTrue: [ self while parent: self ]
]
