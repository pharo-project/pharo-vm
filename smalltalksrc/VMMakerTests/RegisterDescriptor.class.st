Class {
	#name : #RegisterDescriptor,
	#superclass : #Object,
	#instVars : [
		'simulator',
		'name',
		'alias',
		'smalltalkAlias'
	],
	#category : #VMMakerTests
}

{ #category : #accessing }
RegisterDescriptor >> alias [
	^ alias
]

{ #category : #accessing }
RegisterDescriptor >> alias: aString [ 
	
	alias := aString
]

{ #category : #actions }
RegisterDescriptor >> copyValueToClipboard [
	
	Clipboard clipboardText: self value hex
]

{ #category : #actions }
RegisterDescriptor >> inspectValue [

	self value inspect
]

{ #category : #accessing }
RegisterDescriptor >> name [
	^ name
]

{ #category : #accessing }
RegisterDescriptor >> name: anObject [
	name := anObject
]

{ #category : #accessing }
RegisterDescriptor >> printOn: aStream [

	(self value isKindOf: Boolean )
		ifTrue: [ ^ aStream print: self value ].
		
	aStream print: self value hex	

]

{ #category : #actions }
RegisterDescriptor >> printValue [

	simulator memory interpreter longPrintOop: self value
]

{ #category : #accessing }
RegisterDescriptor >> simulator [
	^ simulator
]

{ #category : #accessing }
RegisterDescriptor >> simulator: anObject [
	simulator := anObject
]

{ #category : #accessing }
RegisterDescriptor >> smalltalkAlias [
	
	^ smalltalkAlias
]

{ #category : #accessing }
RegisterDescriptor >> smalltalkAlias: aString [ 
	
	smalltalkAlias := aString
]

{ #category : #accessing }
RegisterDescriptor >> value [

	^ simulator perform: name
]
