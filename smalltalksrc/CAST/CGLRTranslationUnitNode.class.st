Class {
	#name : #CGLRTranslationUnitNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'declarations'
	],
	#category : #CAST
}

{ #category : #generated }
CGLRTranslationUnitNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitTranslationUnit: self
]

{ #category : #generated }
CGLRTranslationUnitNode >> declarations [
	^ declarations
]

{ #category : #generated }
CGLRTranslationUnitNode >> declarations: anOrderedCollection [
	self setParents: self declarations to: nil.
	declarations := anOrderedCollection.
	self setParents: self declarations to: self
]

{ #category : #'generated-initialize-release' }
CGLRTranslationUnitNode >> initialize [
	super initialize.
	declarations := OrderedCollection new: 2.
]
