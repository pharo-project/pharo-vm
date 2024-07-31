Class {
	#name : 'CLabeledStatementNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'label',
		'statement',
		'case'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'generated' }
CLabeledStatementNode class >> case: aCase statement: aStatement [

	^ self new
		case: aCase;
		statement: aStatement;
		yourself
]

{ #category : 'generated' }
CLabeledStatementNode class >> defaultDoing: aCompoundStatement [

	^ self case: 'default' statement: aCompoundStatement
]

{ #category : 'generated' }
CLabeledStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitLabeledStatement: self
]

{ #category : 'generated' }
CLabeledStatementNode >> case [
	^ case
]

{ #category : 'generated' }
CLabeledStatementNode >> case: anObject [
	case := anObject
]

{ #category : 'testing' }
CLabeledStatementNode >> isLabelledStatement [
	
	^ true
]

{ #category : 'generated' }
CLabeledStatementNode >> label [
	^ label
]

{ #category : 'generated' }
CLabeledStatementNode >> label: aCGLRIdentifierNode [
	self label notNil
		ifTrue: [ self label parent: nil ].
	label := aCGLRIdentifierNode.
	self label notNil
		ifTrue: [ self label parent: self ]
]

{ #category : 'testing' }
CLabeledStatementNode >> needsSeparator [

	"The labeled statement node is a case:.
	The case itself should not have a statement separator.
	Its child statement will have its own separator"
	^ false
]

{ #category : 'generated' }
CLabeledStatementNode >> statement [
	^ statement
]

{ #category : 'generated' }
CLabeledStatementNode >> statement: aCGLRAbstractNode [
	self statement notNil
		ifTrue: [ self statement parent: nil ].
	statement := aCGLRAbstractNode.
	self statement notNil
		ifTrue: [ self statement parent: self ]
]
