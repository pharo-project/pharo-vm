Class {
	#name : #CForStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'init',
		'until',
		'statement',
		'step'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CForStatementNode class >> init: initialization until: condition step: aStep statement: aStatement [

	^ self new
		  init: initialization;
		  until: condition;
		  step: aStep;
		  statement: aStatement;
		  yourself
]

{ #category : #generated }
CForStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitForStatement: self
]

{ #category : #generated }
CForStatementNode >> init [
	^ init
]

{ #category : #generated }
CForStatementNode >> init: anOrderedCollection [
	self assertListOfExpressions: anOrderedCollection.
	
	self setParents: self init to: nil.
	init := anOrderedCollection.
	self setParents: self init to: self
]

{ #category : #testing }
CForStatementNode >> isForStatement [

	^true
]

{ #category : #generated }
CForStatementNode >> statement [
	^ statement
]

{ #category : #generated }
CForStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]

{ #category : #generated }
CForStatementNode >> step [
	^ step
]

{ #category : #generated }
CForStatementNode >> step: anOrderedCollection [
	self assertListOfExpressions: anOrderedCollection.
	
	self setParents: self step to: nil.
	step := anOrderedCollection.
	self setParents: self step to: self
]

{ #category : #generated }
CForStatementNode >> until [
	^ until
]

{ #category : #generated }
CForStatementNode >> until: aCGLRExpressionStatementNode [
	self assertExpression: aCGLRExpressionStatementNode.

	self until notNil
		ifTrue: [ self until parent: nil ].
	until := aCGLRExpressionStatementNode.
	self until notNil
		ifTrue: [ self until parent: self ]
]
