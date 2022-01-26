Class {
	#name : #VMAbstractImageFormatTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#instVars : [
		'imageReader',
		'imageReaderClass',
		'imageWriterClass'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #tests }
VMAbstractImageFormatTest class >> testParameters [ 

	^ super testParameters * { 
		{ #imageReaderClass -> SpurImageReader. #imageWriterClass -> SpurImageWriter }.
		{ #imageReaderClass -> ComposedImageReader. #imageWriterClass -> ComposedImageWriter }.
	}
]

{ #category : #tests }
VMAbstractImageFormatTest >> imageFileName [

	^ 'lala.image'
]

{ #category : #accessing }
VMAbstractImageFormatTest >> imageReaderClass [

	^ imageReaderClass
]

{ #category : #accessing }
VMAbstractImageFormatTest >> imageReaderClass: anObject [

	imageReaderClass := anObject
]

{ #category : #accessing }
VMAbstractImageFormatTest >> imageWriterClass [

	^ imageWriterClass
]

{ #category : #accessing }
VMAbstractImageFormatTest >> imageWriterClass: anObject [

	imageWriterClass := anObject
]

{ #category : #accessing }
VMAbstractImageFormatTest >> initializationOptions [

	^ super initializationOptions, { #ImageReader.  imageReaderClass name. #ImageWriter. imageWriterClass name }
]

{ #category : #tests }
VMAbstractImageFormatTest >> readHeader [

	^ imageReader readHeaderFromImage: self imageFileName
]

{ #category : #actions }
VMAbstractImageFormatTest >> saveImage [
	
	interpreter writeImageFileIO.

]

{ #category : #running }
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
	
	imageReader := imageReaderClass newWithMemory: memory andInterpreter: interpreter 
]

{ #category : #running }
VMAbstractImageFormatTest >> tearDown [

	self imageFileName asFileReference ensureDeleteAll.
	super tearDown.
]
