Class {
	#name : 'CParameterDeclarationNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'specifiers',
		'declarator',
		'rawDeclaration'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CParameterDeclarationNode class >> declarator: aString [

	^ self new declarator: aString
]

{ #category : 'instance creation' }
CParameterDeclarationNode class >> declarator: aString cDeclaration: cDecleration [

	^ self new
		  declarator: aString;
		  rawDeclaration: cDecleration;
		  yourself
]

{ #category : 'instance creation' }
CParameterDeclarationNode class >> declarator: aString specifiers: anOrderedCollection [

	^ self new
		  declarator: aString;
		  specifiers: anOrderedCollection;
		  yourself
]

{ #category : 'generated' }
CParameterDeclarationNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitParameterDeclaration: self
]

{ #category : 'generated' }
CParameterDeclarationNode >> declarator [
	^ declarator
]

{ #category : 'generated' }
CParameterDeclarationNode >> declarator: aCGLRAbstractNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRAbstractNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : 'generated-initialize-release' }
CParameterDeclarationNode >> initialize [
	super initialize.
	specifiers := OrderedCollection new: 2.
]

{ #category : 'accessing' }
CParameterDeclarationNode >> rawDeclaration [

	^ rawDeclaration
]

{ #category : 'accessing' }
CParameterDeclarationNode >> rawDeclaration: anObject [

	rawDeclaration := anObject
]

{ #category : 'generated' }
CParameterDeclarationNode >> specifiers [
	^ specifiers
]

{ #category : 'generated' }
CParameterDeclarationNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]
