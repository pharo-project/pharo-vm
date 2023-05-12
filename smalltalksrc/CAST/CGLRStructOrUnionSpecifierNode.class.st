Class {
	#name : #CGLRStructOrUnionSpecifierNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'prefix',
		'symbol',
		'members'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitStructOrUnionSpecifier: self
]

{ #category : #'generated-initialize-release' }
CGLRStructOrUnionSpecifierNode >> initialize [
	super initialize.
	members := OrderedCollection new: 2.
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> members [
	^ members
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> members: anOrderedCollection [
	self setParents: self members to: nil.
	members := anOrderedCollection.
	self setParents: self members to: self
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> nodeVariables [
	^ #(#symbol)
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> prefix [
	^ prefix
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> prefix: aSmaCCToken [
	prefix := aSmaCCToken
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> symbol [
	^ symbol
]

{ #category : #generated }
CGLRStructOrUnionSpecifierNode >> symbol: aCGLRIdentifierNode [
	self symbol notNil
		ifTrue: [ self symbol parent: nil ].
	symbol := aCGLRIdentifierNode.
	self symbol notNil
		ifTrue: [ self symbol parent: self ]
]
