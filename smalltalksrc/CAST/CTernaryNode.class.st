Class {
	#name : #CTernaryNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'condition',
		'else',
		'then',
		'printOnMultipleLines'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CTernaryNode class >> condition: aCondition then: thenExpression else: elseExpression [

	^ self new
		  condition: aCondition;
		  then: thenExpression;
		  else: elseExpression;
		  printOnMultipleLines: false;
		  yourself
]

{ #category : #generated }
CTernaryNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTernary: self
]

{ #category : #generated }
CTernaryNode >> condition [
	^ condition
]

{ #category : #generated }
CTernaryNode >> condition: aCGLRAbstractNode [
	self condition notNil
		ifTrue: [ self condition parent: nil ].
	condition := aCGLRAbstractNode.
	self condition notNil
		ifTrue: [ self condition parent: self ]
]

{ #category : #generated }
CTernaryNode >> else [
	^ else
]

{ #category : #generated }
CTernaryNode >> else: aCGLRAbstractNode [
	self else notNil
		ifTrue: [ self else parent: nil ].
	else := aCGLRAbstractNode.
	self else notNil
		ifTrue: [ self else parent: self ]
]

{ #category : #generated }
CTernaryNode >> isTernary [
	^ true
]

{ #category : #accessing }
CTernaryNode >> printOnMultipleLines [

	^ printOnMultipleLines
]

{ #category : #accessing }
CTernaryNode >> printOnMultipleLines: aBoolean [

	printOnMultipleLines := aBoolean
]

{ #category : #generated }
CTernaryNode >> then [
	^ then
]

{ #category : #generated }
CTernaryNode >> then: aCGLRExpressionNode [
	self then notNil
		ifTrue: [ self then parent: nil ].
	then := aCGLRExpressionNode.
	self then notNil
		ifTrue: [ self then parent: self ]
]
