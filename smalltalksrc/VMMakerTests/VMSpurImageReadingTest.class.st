Class {
	#name : #VMSpurImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #initialization }
VMSpurImageReadingTest >> setUp [

	super setUp.

	"ByteArrayClass is asserted while loading image"
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory ensureBehaviorHash: memory classByteArray.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	interpreter desiredEdenBytes: memory edenBytes.

	self saveImage.
	
]

{ #category : #initialization }
VMSpurImageReadingTest >> testReadingSavedImageHasSameHeader [

	| memoryManager primitiveLogSize originalNilObject newSpaceStartOffset |
	
	
	originalNilObject := memory nilObject.
	
	memoryManager := MachineSimulatorMemoryManager new.
	memoryManager initialAddress: initialAddress.
	memoryManager wordSize: self wordSize.

	primitiveLogSize := self roundToPageSize: self primitiveTraceLogSize.

	newSpaceStartOffset := self initialCodeSize + stackSpaceSize
	                 + methodCacheSize + primitiveLogSize
	                 + rumpCStackSize.

	memoryManager allocate: newSpaceStartOffset.

	interpreter := self newInterpreter.
	interpreter memoryManager: memoryManager.

	memory := interpreter objectMemory.
	memory memoryManager: memoryManager.	
	memory coInterpreter: interpreter.
	interpreter objectMemory: memory.
	
	interpreter openOn: self imageFileName extraMemory: 0.
	
	self assert: originalNilObject - memory nilObject equals: 0

]
