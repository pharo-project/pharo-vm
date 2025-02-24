Class {
	#name : 'CGotoStatementNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'label'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'generated' }
CGotoStatementNode class >> identifier: id [

	^ self new
		  label: (CIdentifierNode name: id);
		  yourself
]

{ #category : 'comparing' }
CGotoStatementNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ label = anObject label
]

{ #category : 'generated' }
CGotoStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitGotoStatement: self
]

{ #category : 'comparing' }
CGotoStatementNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ label hash
]

{ #category : 'testing' }
CGotoStatementNode >> isGoTo [
	^ true.
]

{ #category : 'generated' }
CGotoStatementNode >> label [
	^ label
]

{ #category : 'generated' }
CGotoStatementNode >> label: aCGLRIdentifierNode [
	self label notNil
		ifTrue: [ self label parent: nil ].
	label := aCGLRIdentifierNode.
	self label notNil
		ifTrue: [ self label parent: self ]
]
