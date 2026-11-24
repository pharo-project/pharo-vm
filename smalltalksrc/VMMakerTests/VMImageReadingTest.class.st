Class {
	#name : 'VMImageReadingTest',
	#superclass : 'VMAbstractImageFormatTest',
	#instVars : [
		'originalNilObjectIdentityHash',
		'permanentObject',
		'originalPermanentObjectIdentityHash',
		'useMMap',
		'minPermSpaceSize'
	],
	#category : 'VMMakerTests-ImageFormat',
	#package : 'VMMakerTests',
	#tag : 'ImageFormat'
}

{ #category : 'utilities' }
VMImageReadingTest >> changeStartAddressOfPermSpaceTo: newAddress [

	| file contents oldAddress |
	file := self imageFileName asFileReference / 'permSpace.ston'.
	contents := file contents.
	oldAddress := (self metadataFrom: 'permSpace.ston') startAddress.

	file ensureDelete.
	file writeStreamDo: [ :stream | 
		stream nextPutAll: (contents copyReplaceAll: oldAddress printString with: newAddress printString) ].

	self assert: (self metadataFrom: 'permSpace.ston') startAddress equals: newAddress
]

{ #category : 'query' }
VMImageReadingTest >> dataFrom: fileName [

	^ self imageFileName asFileReference / fileName
]

{ #category : 'accessing' }
VMImageReadingTest >> initializationOptions [

	^ super initializationOptions , { #CloneOnGC. false. #CloneOnScavenge. false }
]

{ #category : 'utilities' }
VMImageReadingTest >> initializeMinPermSpaceSize [

	"The memory map needs the memory manager, that otherwise is created when opening the image"

	interpreter memoryManager: MachineSimulatorMemoryManager new.
	memory memoryManager: interpreter memoryManager.
	interpreter memoryManager wordSize: memory wordSize.

	memory setMinimalPermSpaceSize: minPermSpaceSize
]

{ #category : 'utilities' }
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
	
	memory setUseMMapWhenPossible: useMMap.
	minPermSpaceSize > 0 ifTrue: [ self initializeMinPermSpaceSize ].
	
	interpreter openOn: self imageFileName extraMemory: 0.
]

{ #category : 'query' }
VMImageReadingTest >> metadataFrom: fileName [

	| writtenHeader |
	writtenHeader := (self imageFileName asFileReference / fileName) contents.
	^ STON fromString: writtenHeader
]

{ #category : 'utilities' }
VMImageReadingTest >> saveImage [

	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	super saveImage.
	
	memory postSnapshot.

]

{ #category : 'initialization' }
VMImageReadingTest >> setUp [

	super setUp.

	useMMap := false.
	minPermSpaceSize := 0.

	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.
	
	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.
]

{ #category : 'tests - mmap' }
VMImageReadingTest >> testLoadingEmptyPermanentSpaceUsingMMap [

	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	self saveImage.

	useMMap := true.
	self loadImage.

	self assert: memory getMemoryMap permSpaceStart equals: 0.
	self assert: memory getMemoryMap permSpaceEnd equals: 0
]

{ #category : 'tests' }
VMImageReadingTest >> testLoadingEmptyPermanentSpaceWithMinPermSpaceSize [

	| map |
	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	self saveImage.

	minPermSpaceSize := 1024 * 1024.
	self loadImage.

	map := memory getMemoryMap.
	self assert: map permSpaceStart equals: map fixedPermSpaceStart.
	self assert: map permSpaceSize equals: minPermSpaceSize.
	self assert: memory permSpaceFreeStart equals: map permSpaceStart
]

{ #category : 'tests - mmap' }
VMImageReadingTest >> testLoadingPermanentSpaceUsingMMap [

	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	permanentObject := self newPermanentByteObjectOfSize: 14.
	0 to: 13 do: [ :index | memory storeByte: index ofObject: permanentObject withValue: index + 100 ].
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.

	self saveImage.

	useMMap := true.
	self loadImage.

	self assert: (memory isPermanent: permanentObject).
	self assert: (memory hashBitsOf: permanentObject) equals: originalPermanentObjectIdentityHash.
	0 to: 13 do: [ :index | self assert: (memory fetchByte: index ofObject: permanentObject) equals: index + 100 ]
]

{ #category : 'tests - mmap' }
VMImageReadingTest >> testLoadingPermanentSpaceUsingMMapRespectsMinPermSpaceSize [

	| metadata map |
	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.

	self saveImage.
	metadata := self metadataFrom: 'permSpace.ston'.

	useMMap := true.
	minPermSpaceSize := metadata fileSize * 2.
	self loadImage.

	map := memory getMemoryMap.
	self assert: map permSpaceStart equals: map fixedPermSpaceStart.
	self assert: map permSpaceSize equals: minPermSpaceSize.
	self assert: memory permSpaceFreeStart equals: map permSpaceStart + metadata dataSize.
	self assert: (memory hashBitsOf: permanentObject) equals: originalPermanentObjectIdentityHash
]

{ #category : 'tests - mmap' }
VMImageReadingTest >> testLoadingPermanentSpaceUsingMMapSetsLimits [

	| metadata map |
	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	self newPermanentByteObjectOfSize: 14.

	self saveImage.
	metadata := self metadataFrom: 'permSpace.ston'.

	useMMap := true.
	self loadImage.

	map := memory getMemoryMap.
	self assert: map permSpaceStart equals: map fixedPermSpaceStart.
	self assert: map permSpaceSize equals: metadata fileSize.
	self assert: memory permSpaceFreeStart equals: map permSpaceStart + metadata dataSize
]

{ #category : 'tests - mmap' }
VMImageReadingTest >> testLoadingPermanentSpaceUsingMMapWithWrongBaseFails [

	| wrongAddress |
	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].

	self newPermanentByteObjectOfSize: 14.

	self saveImage.

	wrongAddress := memory getMemoryMap fixedPermSpaceStart + 16r100000.
	self changeStartAddressOfPermSpaceTo: wrongAddress.

	useMMap := true.
	self
		should: [ self loadImage ]
		raise: Error
		whoseDescriptionIncludes: 'Expecting Base'
		description: 'Loading an image with a wrong base should fail'.

	"It should fail before modifying the memory map"
	self assert: memory getMemoryMap permSpaceStart equals: 0.
	self assert: memory getMemoryMap permSpaceEnd equals: 0
]

{ #category : 'tests' }
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

	self assert: finalPermSpaceSize > 0.

	self assert: (self metadataFrom: 'seg0.ston') fileSize equals: finalSegmentSize.
	self assert: (self metadataFrom: 'permSpace.ston') fileSize equals: finalPermSpaceSize
]

{ #category : 'tests' }
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

{ #category : 'tests' }
VMImageReadingTest >> testSavedImageSavesObjectFromOldSpace [
	
	self saveImage.	
	self loadImage.
		
	self assert: originalNilObjectIdentityHash equals: (memory hashBitsOf: memory nilObject).
]

{ #category : 'tests' }
VMImageReadingTest >> testSavedImageSavesObjectFromPermanentSpace [

	"Only valid in the new format"
	useComposedImageFormat ifFalse: [ ^ self skip ].
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.	
	
	self saveImage.	
	self loadImage.
		
	self assert: originalPermanentObjectIdentityHash equals: (memory hashBitsOf: permanentObject).

]

{ #category : 'tests' }
VMImageReadingTest >> testSavingImageWithThreeSegmentsIsCorrectlySqueezed [

	| firstNewSegmentSize secondNewSegmentSize obj newObj originalObjHash |
	firstNewSegmentSize := memory
		                       growOldSpaceByAtLeast: 12 * 1024
		                       callingOperation: 'testSavingImageWithThreeSegmentsIsCorrectlySqueezed'.
	secondNewSegmentSize := memory
		                        growOldSpaceByAtLeast: 12 * 1024
		                        callingOperation: 'testSavingImageWithThreeSegmentsIsCorrectlySqueezed'.

	self assert: memory segmentManager numSegments equals: 3.

	self
		assert: (memory segmentManager segments at: 1) segSize
		equals: firstNewSegmentSize.
	self
		assert: (memory segmentManager segments at: 2) segSize
		equals: secondNewSegmentSize.

	obj := self newOldSpaceObjectWithSlots:
		       firstNewSegmentSize / 2 // memory wordSize.
	memory splObj: 4 put: obj. "Store object in SpecialObjects Array to keep it"
	originalObjHash := memory hashBitsOf: obj.


	"Ensure the object is created in the last segment"
	self assert: obj > (memory segmentManager segments at: 2) segStart.
	self assert: obj < (memory segmentManager segments at: 2) segLimit.

	self saveImage.

	self loadImage.

	self assert: memory segmentManager numSegments equals: 1.

	newObj := memory splObj: 4.

	self assert: originalObjHash equals: (memory hashBitsOf: newObj)
]

{ #category : 'tests' }
VMImageReadingTest >> testSavingPermanentSpaceObjectsInSpurFormatFails [

	imageWriterClass = SpurImageWriter ifFalse: [ ^ self skip ].
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf: permanentObject.	
	
	self should: [ self saveImage ] raise: PrimitiveFailed	

]
