Class {
	#name : #VMImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#instVars : [
		'originalNilObjectIdentityHash',
		'permanentObject',
		'originalPermanentObjectIdentityHash'
	],
	#category : #'VMMakerTests-ImageFormat'
}

{ #category : #query }
VMImageReadingTest >> dataFrom: fileName [

	^ self imageFileName asFileReference / fileName
]

{ #category : #accessing }
VMImageReadingTest >> initializationOptions [

	^ super initializationOptions , { #CloneOnGC. false. #CloneOnScavenge. false }
]

{ #category : #utilities }
VMImageReadingTest >> loadImage [

	environmentBuilder := VMSimulatedEnvironmentBuilder new.
	environmentBuilder 
		interpreterClass: self interpreterClass;
		objectMemoryClass: self memoryClass;
	 	initializationOptions: self initializationOptions;
		wordSize: self wordSize;
		useComposedImageFormatAsDefault: useComposedImageFormat.

	environmentBuilder doBuildSimulator.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
	
	interpreter openOn: self imageFileName extraMemory: 0.

]

{ #category : #query }
VMImageReadingTest >> metadataFrom: fileName [

	| writtenHeader |
	writtenHeader := (self imageFileName asFileReference / fileName) contents.
	^ STON fromString: writtenHeader
]

{ #category : #utilities }
VMImageReadingTest >> saveImage [

	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	super saveImage.
	
	memory postSnapshot.

]

{ #category : #initialization }
VMImageReadingTest >> setUp [

	super setUp.

	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.
	
	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.

]

{ #category : #tests }
VMImageReadingTest >> testMovingObjectsToPermSpaceReduceOldSpace [

	| obj magicNumber initSegmentSize initPermSpaceSize finalSegmentSize finalPermSpaceSize |
	imageReaderClass ~= ComposedImageReader ifTrue: [ ^ self skip ].

	magicNumber := 77.
	obj := self newOldSpaceArrayWithSlots: magicNumber.
	memory splObj: 4 put: obj. "Store object in SpecialObjects Array to keep it"

	self saveImage.
	memory allOldSpaceObjectsDo: [ :oop | "Remap" 
		(memory numSlotsOf: oop) = magicNumber ifTrue: [ obj := oop ] ].

	initSegmentSize := (self dataFrom: 'seg0.data') size.
	initPermSpaceSize := (self dataFrom: 'permSpace.data') size.

	self assert: initSegmentSize > 0.
	self assert: initPermSpaceSize equals: 0.

	self assert: (self metadataFrom: 'seg0.ston') dataSize equals: initSegmentSize.
	self assert: (self metadataFrom: 'permSpace.ston') dataSize equals: initPermSpaceSize.

	"------------------------------------------------------------------------------"

	self assert: (memory numSlotsOf: obj) equals: 77.

	memory moveToPermSpace: obj.

	self saveImage.

	finalSegmentSize := (self dataFrom: 'seg0.data') size.
	finalPermSpaceSize := (self dataFrom: 'permSpace.data') size.

	self assert: finalPermSpaceSize < initSegmentSize.
	self assert: finalPermSpaceSize > 0.

	self assert: (self metadataFrom: 'seg0.ston') dataSize equals: finalSegmentSize.
	self assert: (self metadataFrom: 'permSpace.ston') dataSize equals: finalPermSpaceSize
]

{ #category : #tests }
VMImageReadingTest >> testReadingSTONHeader [

	| headerStruct headerFile |

	imageReaderClass ~= ComposedImageReader ifTrue: [ ^ self skip ].

	self saveImage.	
	headerStruct := SpurImageHeaderStruct new.
	headerFile := (self imageFileName asFileReference  / 'header.ston') readStream.
	
	imageReader readSTONFrom: headerFile into: headerStruct .

	headerFile position: 0.

	self assert: (self stonPretty: headerStruct) equals: headerFile contents.
]

{ #category : #tests }
VMImageReadingTest >> testSavedImageSavesObjectFromOldSpace [
	
	self saveImage.	
	self loadImage.
		
	self assert: originalNilObjectIdentityHash equals: (memory hashBitsOf: memory nilObject).
]

{ #category : #tests }
VMImageReadingTest >> testSavedImageSavesObjectFromPermanentSpace [

	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.	
	
	self saveImage.	
	self loadImage.
		
	self assert: originalPermanentObjectIdentityHash equals: (memory hashBitsOf: permanentObject).

]

{ #category : #tests }
VMImageReadingTest >> testSavingImageWithThreeSegmentsIsCorrectlySqueezed [
	
	| firstNewSegmentSize secondNewSegmentSize obj newObj originalObjHash |
	firstNewSegmentSize := memory growOldSpaceByAtLeast: 12 * 1024.
	secondNewSegmentSize := memory growOldSpaceByAtLeast: 12 * 1024.
	
	self assert: memory segmentManager numSegments equals: 3.

	self assert: (memory segmentManager segments at: 1) segSize equals: firstNewSegmentSize.
	self assert: (memory segmentManager segments at: 2) segSize equals: secondNewSegmentSize.

	obj := self newOldSpaceObjectWithSlots: (firstNewSegmentSize / 2) // memory wordSize.
	memory splObj: 4 put: obj. "Store object in SpecialObjects Array to keep it" 
	originalObjHash := memory hashBitsOf: obj.


	"Ensure the object is created in the last segment".
	self assert: obj > (memory segmentManager segments at: 2) segStart.
	self assert: obj < (memory segmentManager segments at: 2) segLimit.

	self saveImage.	

	self loadImage.

	self assert: memory segmentManager numSegments equals: 1.
	
	newObj := memory splObj: 4. 
	
	self assert: originalObjHash equals: (memory hashBitsOf: newObj).
]

{ #category : #tests }
VMImageReadingTest >> testSavingPermanentSpaceObjectsInSpurFormatFails [

	imageWriterClass = SpurImageWriter ifFalse: [ ^ self skip ].
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.	
	
	self should: [ self saveImage ] raise: PrimitiveFailed	

]
