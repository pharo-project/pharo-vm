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

{ #category : #actions }
VMAbstractImageFormatTest >> saveImage [

	interpreter setExtraVMMemory: 0.

	interpreter imageName: self imageFileName.
	interpreter preemptionYields: false.
	interpreter setImageHeaderFlagsFrom: 0.
	
	interpreter writeImageFileIO.

]

{ #category : #running }
VMAbstractImageFormatTest >> setUp [

	super setUp.
	
	"Objects should be registerd in Special Object Array, as they are validated while loading"
	memory splObj: NilObject put: memory nilObject.
	memory splObj: FalseObject put: memory falseObject.
	memory splObj: TrueObject put: memory trueObject.	
	
	imageReader := SpurImageReader newWithMemory: memory andInterpreter: interpreter 
]

{ #category : #running }
VMAbstractImageFormatTest >> tearDown [

	self imageFileName asFileReference ensureDelete.
	super tearDown.
]
