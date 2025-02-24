Class {
	#name : 'VMAbstractImageFormatTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#instVars : [
		'imageReader',
		'imageReaderClass',
		'imageWriterClass'
	],
	#category : 'VMMakerTests-ImageFormat',
	#package : 'VMMakerTests',
	#tag : 'ImageFormat'
}

{ #category : 'accessing' }
VMAbstractImageFormatTest >> defaultTimeLimit [

	^ 30 seconds
]

{ #category : 'tests' }
VMAbstractImageFormatTest >> imageFileName [

	^ 'lala.image'
]

{ #category : 'tests' }
VMAbstractImageFormatTest >> readHeader [

	^ imageReader readHeaderFromImage: self imageFileName
]

{ #category : 'actions' }
VMAbstractImageFormatTest >> saveImage [
	
	interpreter writeImageFileIO.

]

{ #category : 'running' }
VMAbstractImageFormatTest >> setUp [

	super setUp.
	
	"Objects should be registerd in Special Object Array, as they are validated while loading"
	memory splObj: NilObject put: memory nilObject.
	memory splObj: FalseObject put: memory falseObject.
	memory splObj: TrueObject put: memory trueObject.	
	
	interpreter setExtraVMMemory: 0.
	interpreter imageName: self imageFileName.
	interpreter preemptionYields: false.
	interpreter setImageHeaderFlagsFrom: 0.
	
	imageReaderClass := useComposedImageFormat ifTrue: [ ComposedImageReader ] ifFalse: [ SpurImageReader ].
	imageReader := imageReaderClass newWithMemory: memory andInterpreter: interpreter.
	
	interpreter imageReaderWriter useComposedImageFormatAsDefault: useComposedImageFormat.
	
	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.

]

{ #category : 'ston' }
VMAbstractImageFormatTest >> stonPretty: anObject [ 

	^ String streamContents: [ :s |
		(STONWriter on: s)
			prettyPrint: true;
			newLine: OSPlatform current lineEnding;
			nextPut: anObject			
		 ]
]

{ #category : 'running' }
VMAbstractImageFormatTest >> tearDown [

	self imageFileName asFileReference ensureDeleteAll.
	super tearDown.
]
