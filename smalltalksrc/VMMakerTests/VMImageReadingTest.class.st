Class {
	#name : 'VMImageReadingTest',
	#superclass : 'VMAbstractImageFormatTest',
	#instVars : [
		'originalNilObjectIdentityHash',
		'permanentObject',
		'originalPermanentObjectIdentityHash'
	],
	#category : 'VMMakerTests-ImageFormat',
	#package : 'VMMakerTests',
	#tag : 'ImageFormat'
}

{ #category : 'query' }
VMImageReadingTest >> dataFrom: fileName [

	^ self imageFileName asFileReference / fileName
]

{ #category : 'accessing' }
VMImageReadingTest >> initializationOptions [

	^ super initializationOptions , { #CloneOnGC. false. #CloneOnScavenge. false }
]

{ #category : 'utilities' }
VMImageReadingTest >> loadImage [

	self loadImageWithMemoryMapConfiguration: nil

]

{ #category : 'utilities' }
VMImageReadingTest >> loadImageWithMemoryMapConfiguration: aMemoryMapConfiguration [

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
	aMemoryMapConfiguration ifNotNil: [ :config |
		interpreter memoryManager: (MachineSimulatorMemoryManager new
				 wordSize: self wordSize;
				 yourself).
		memory memoryManager: interpreter memoryManager.
		memory ensureMemoryMap.
		memory getMemoryMap memoryMapConfiguration: config.
		memory getMemoryMap calculateMaskToUse ].

	interpreter openOn: self imageFileName extraMemory: 0
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

	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.
	
	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.

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

	self assert: finalPermSpaceSize < initSegmentSize.
	self assert: finalPermSpaceSize > 0.

	self assert: (self metadataFrom: 'seg0.ston') dataSize equals: finalSegmentSize.
	self assert: (self metadataFrom: 'permSpace.ston') dataSize equals: finalPermSpaceSize
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
VMImageReadingTest >> testSavedImageLoadsUnderSmallerMemoryMapConfiguration [

	"Regression test for #955: an image saved under the 64-bit memory map
	 (oldSpace at 16r10000000000) and loaded under a smaller memory map
	 (where permSpaceInitialAddress is 16r80000000, below the saved oldSpace
	 base) must still swizzle old-space pointers instead of misclassifying
	 save-time oops against the load-time permSpace boundary."

	self wordSize = 8 ifFalse: [ ^ self skip ].

	self saveImage.
	self loadImageWithMemoryMapConfiguration:
		VMMemoryMapConfigurationFor32Bits new.

	self
		assert: originalNilObjectIdentityHash
		equals: (memory hashBitsOf: memory nilObject)
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
VMImageReadingTest >> testSavedImageWithPermanentSpaceLoadsUnderSmallerMemoryMapConfiguration [

	"When a composed image carrying permanent-space objects is saved under the
	 64-bit memory map (oldSpace at 2^40, permSpace at 2^41) and loaded under
	 a smaller memory map (oldSpace at 16r40000000, permSpace at 16r80000000),
	 both spaces and cross-space pointers must be relocated and swizzled."

	| oldObj oldObjHash loadedOldObj loadedPermObj |
	(useComposedImageFormat and: [ self wordSize = 8 ]) ifFalse: [
		^ self skip ].

	permanentObject := self newPermanentByteObjectOfSize: 14.
	originalPermanentObjectIdentityHash := memory hashBitsOf:
		                                       permanentObject.
	oldObj := self newOldSpaceObjectWithSlots: 1.
	oldObjHash := memory hashBitsOf: oldObj.
	memory storePointer: 0 ofObject: oldObj withValue: permanentObject.
	memory splObj: 4 put: oldObj.

	self saveImage.
	self loadImageWithMemoryMapConfiguration:
		VMMemoryMapConfigurationFor32Bits new.

	loadedOldObj := memory splObj: 4.
	loadedPermObj := memory fetchPointer: 0 ofObject: loadedOldObj.
	self assert: (memory hashBitsOf: loadedOldObj) equals: oldObjHash.
	self
		assert: (memory hashBitsOf: loadedPermObj)
		equals: originalPermanentObjectIdentityHash.
	self assert: (memory getMemoryMap isOldObject: loadedOldObj).
	self assert: (memory getMemoryMap isPermanentObject: loadedPermObj).
	self deny: (memory getMemoryMap isPermanentObject: loadedOldObj).
	self deny: (memory getMemoryMap isOldObject: loadedPermObj)
]

{ #category : 'tests' }
VMImageReadingTest >> testSavedImageWithPermToOldRememberedSetLoadsUnderSmallerMemoryMapConfiguration [

	"Permanent-space objects pointing into old space are recorded in
	 fromPermToOldSpaceRememberedSet (a wordIndexableFormat object preserved
	 across snapshots). When permSpace or oldSpace relocates on load,
	 those remembered-set entries must also be swizzled before fullGC."

	| permObj permObjHash oldObj oldObjHash loadedPermObj loadedOldObj remSet |
	(useComposedImageFormat and: [ self wordSize = 8 ]) ifFalse: [
		^ self skip ].

	permObj := self newPermanentObjectWithSlots: 1.
	permObjHash := memory hashBitsOf: permObj.
	oldObj := self newOldSpaceObjectWithSlots: 0.
	oldObjHash := memory hashBitsOf: oldObj.
	memory storePointer: 0 ofObject: permObj withValue: oldObj.
	memory splObj: 4 put: permObj.

	self saveImage.
	self loadImageWithMemoryMapConfiguration:
		VMMemoryMapConfigurationFor32Bits new.

	loadedPermObj := memory splObj: 4.
	loadedOldObj := memory fetchPointer: 0 ofObject: loadedPermObj.
	remSet := memory getFromPermToOldSpaceRememberedSet.

	self assert: (memory hashBitsOf: loadedPermObj) equals: permObjHash.
	self assert: (memory hashBitsOf: loadedOldObj) equals: oldObjHash.
	self assert: remSet rememberedSetSize equals: 1.
	self assert: (remSet objectAt: 0) equals: loadedPermObj.
	self assert: (remSet isInRememberedSet: loadedPermObj).

	"Full GC relies on the swizzled remembered set to trace and keep oldObj alive."
	interpreter initStackPages.
	memory fullGC.

	loadedOldObj := memory fetchPointer: 0 ofObject: loadedPermObj.
	self assert: (memory hashBitsOf: loadedOldObj) equals: oldObjHash.
	self assert: remSet rememberedSetSize equals: 1.

	memory storePointer: 0 ofObject: loadedPermObj withValue: memory nilObject.
	memory fullGC.

	self assert: remSet rememberedSetSize equals: 0.
	self deny: (remSet isInRememberedSet: loadedPermObj)
]

{ #category : 'tests' }
VMImageReadingTest >> testSavedImageWithOnlyPermSpaceRelocatedLoadsCleanly [

	"When oldSpace reloads at its saved base (bytesToShift = 0, numSegments = 1)
	 but permSpace relocates to a different address, adjustAllOopsBy: must
	 still run so old->perm, perm->old, and perm->old remembered-set entries
	 are swizzled."

	| customConfig permObj permObjHash oldObj oldObjHash loadedOldObj loadedPermObj remSet |
	(useComposedImageFormat and: [ self wordSize = 8 ]) ifFalse: [
		^ self skip ].

	permObj := self newPermanentObjectWithSlots: 1.
	permObjHash := memory hashBitsOf: permObj.
	oldObj := self newOldSpaceObjectWithSlots: 1.
	oldObjHash := memory hashBitsOf: oldObj.
	memory storePointer: 0 ofObject: oldObj withValue: permObj.
	memory storePointer: 0 ofObject: permObj withValue: oldObj.
	memory splObj: 4 put: oldObj.

	self saveImage.

	customConfig := VMMemoryMapConfigurationFor64Bits newAnonymousSubclass.
	customConfig compile: 'permSpaceInitialAddress ^ 16r18000000000'.
	self loadImageWithMemoryMapConfiguration: customConfig new.

	loadedOldObj := memory splObj: 4.
	loadedPermObj := memory fetchPointer: 0 ofObject: loadedOldObj.
	remSet := memory getFromPermToOldSpaceRememberedSet.

	self assert: memory getMemoryMap permSpaceStart equals: 16r18000000000.
	self assert: (memory hashBitsOf: loadedOldObj) equals: oldObjHash.
	self assert: (memory hashBitsOf: loadedPermObj) equals: permObjHash.
	self
		assert: (memory fetchPointer: 0 ofObject: loadedPermObj)
		equals: loadedOldObj.
	self assert: (remSet isInRememberedSet: loadedPermObj).

	interpreter initStackPages.
	memory fullGC.

	self
		assert: (memory fetchPointer: 0 ofObject: loadedPermObj)
		equals: (memory splObj: 4)
]

{ #category : 'tests' }
VMImageReadingTest >> testSavedMultiSegmentImageWithPermanentSpaceLoadsUnderSmallerMemoryMapConfiguration [

	"Multi-segment oldSpace combined with permanent space (and bidirectional
	 cross-space references) must coalesce oldSpace segments, relocate permSpace
	 independently of segment order, and swizzle all oops including remembered sets."

	| firstNewSegmentSize oldObj oldObjHash permObj permObjHash loadedOldObj loadedPermObj |
	(useComposedImageFormat and: [ self wordSize = 8 ]) ifFalse: [
		^ self skip ].

	firstNewSegmentSize := memory
		                       growOldSpaceByAtLeast: 12 * 1024
		                       callingOperation: 'testSavedMultiSegmentImageWithPermanentSpaceLoadsUnderSmallerMemoryMapConfiguration'.
	memory
		growOldSpaceByAtLeast: 12 * 1024
		callingOperation: 'testSavedMultiSegmentImageWithPermanentSpaceLoadsUnderSmallerMemoryMapConfiguration'.

	oldObj := self newOldSpaceObjectWithSlots:
		          firstNewSegmentSize / 2 // memory wordSize.
	self assert: oldObj > (memory segmentManager segments at: 2) segStart.
	oldObjHash := memory hashBitsOf: oldObj.

	permObj := self newPermanentObjectWithSlots: 1.
	permObjHash := memory hashBitsOf: permObj.

	memory storePointer: 0 ofObject: oldObj withValue: permObj.
	memory storePointer: 0 ofObject: permObj withValue: oldObj.
	memory splObj: 4 put: oldObj.

	self saveImage.
	self loadImageWithMemoryMapConfiguration:
		VMMemoryMapConfigurationFor32Bits new.

	self assert: memory segmentManager numSegments equals: 1.
	loadedOldObj := memory splObj: 4.
	loadedPermObj := memory fetchPointer: 0 ofObject: loadedOldObj.
	self assert: (memory hashBitsOf: loadedOldObj) equals: oldObjHash.
	self assert: (memory hashBitsOf: loadedPermObj) equals: permObjHash.
	self
		assert: (memory fetchPointer: 0 ofObject: loadedPermObj)
		equals: loadedOldObj.
	self assert: (memory getMemoryMap isOldObject: loadedOldObj).
	self assert: (memory getMemoryMap isPermanentObject: loadedPermObj).

	interpreter initStackPages.
	memory fullGC.

	loadedOldObj := memory splObj: 4.
	self
		assert: (memory fetchPointer: 0 ofObject: loadedPermObj)
		equals: loadedOldObj
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
