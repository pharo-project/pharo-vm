Class {
	#name : #VMSpurImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#instVars : [
		'originalNilObjectIdentityHash'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #utilities }
VMSpurImageReadingTest >> loadImage [

	| memoryManager |
	
	memoryManager := MachineSimulatorMemoryManager new.
	memoryManager initialAddress: initialAddress.
	memoryManager wordSize: self wordSize.

	interpreter := self newInterpreter.
	interpreter memoryManager: memoryManager.

	memory := interpreter objectMemory.
	memory memoryManager: memoryManager.	
	memory coInterpreter: interpreter.
	interpreter objectMemory: memory.
	
	interpreter openOn: self imageFileName extraMemory: 0.

]

{ #category : #initialization }
VMSpurImageReadingTest >> setUp [

	super setUp.

	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.
	
]

{ #category : #tests }
VMSpurImageReadingTest >> testSavedImageSavesObject [
	
	self saveImage.	
	self loadImage.
		
	self assert: originalNilObjectIdentityHash equals: (memory hashBitsOf: memory nilObject).
]

{ #category : #tests }
VMSpurImageReadingTest >> testSavingImageWithThreeSegmentsIsCorrectlySqueezed [
	
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
