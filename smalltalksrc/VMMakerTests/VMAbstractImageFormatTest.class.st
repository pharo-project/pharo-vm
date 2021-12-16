Class {
	#name : #VMAbstractImageFormatTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#instVars : [
		'imageReader'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #tests }
VMAbstractImageFormatTest >> imageFileName [

	^ 'lala.image'
]

{ #category : #tests }
VMAbstractImageFormatTest >> readHeader [

	| header |
	header := self imageFileName asFileReference binaryReadStreamDo: [ :f | 
		          imageReader readHeaderFrom: f startingAt: 0 ].
	^ header
]

{ #category : #running }
VMAbstractImageFormatTest >> setUp [

	super setUp.
	
	memory bootstrapping: false.
	
	imageReader := ImageReader newWithMemory: memory
]

{ #category : #running }
VMAbstractImageFormatTest >> tearDown [

	self imageFileName asFileReference ensureDelete.
	super tearDown.
]
