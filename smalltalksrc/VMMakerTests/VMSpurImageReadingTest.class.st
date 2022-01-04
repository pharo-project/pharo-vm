Class {
	#name : #VMSpurImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#instVars : [
		'originalNilObjectIdentityHash'
	],
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

	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.

	self saveImage.
	
]

{ #category : #initialization }
VMSpurImageReadingTest >> testSavedImageSavesObject [
	
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
	
	self assert: originalNilObjectIdentityHash equals: (memory hashBitsOf: memory nilObject).
]
