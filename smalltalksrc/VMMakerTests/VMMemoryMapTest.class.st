"
Unit tests for the space-discrimination masks of VMMemoryMap.

The VM used to hard-error when oldSpace was not allocated exactly at the
configured base address; that check was replaced by recomputing the masks
from the address actually obtained (so kernels whose user virtual address
space cannot reach the configured base, e.g. aarch64 VA39, can still run).
These tests keep the allocation-location expectations as an executable
guarantee: wherever the spaces end up, the masks must classify every
address into exactly its own space, and the mask computation must stay
finite in simulation.
"
Class {
	#name : 'VMMemoryMapTest',
	#superclass : 'TestCase',
	#instVars : [
		'memoryMap',
		'configuration'
	],
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'running' }
VMMemoryMapTest >> setUp [

	super setUp.
	configuration := VMMemoryMapConfigurationFor64Bits new.
	memoryMap := VMMemoryMap new.
	memoryMap initializeMemoryMap.
	memoryMap memoryMapConfiguration: configuration
]

{ #category : 'asserting' }
VMMemoryMapTest >> assertSpacesAreClassifiedCorrectly [

	"The behavioral guarantee that used to be enforced by requiring allocation
	 at the configured base: wherever the spaces actually are, the masks must
	 classify every space's addresses into exactly that space."

	self assert: (memoryMap isYoungObject: memoryMap newSpaceStart).
	self assert: (memoryMap isYoungObject: memoryMap newSpaceEnd - 8).
	self deny: (memoryMap isOldObject: memoryMap newSpaceStart).
	self deny: (memoryMap isOldObject: memoryMap newSpaceEnd - 8).
	self deny: (memoryMap isPermanentObject: memoryMap newSpaceStart).

	self assert: (memoryMap isOldObject: memoryMap oldSpaceStart).
	self assert: (memoryMap isOldObject: memoryMap oldSpaceEnd - 8).
	self deny: (memoryMap isYoungObject: memoryMap oldSpaceStart).
	self deny: (memoryMap isYoungObject: memoryMap oldSpaceEnd - 8).
	self deny: (memoryMap isPermanentObject: memoryMap oldSpaceStart).

	self assert: (memoryMap isPermanentObject: memoryMap fixedPermSpaceStart).
	self deny: (memoryMap isYoungObject: memoryMap fixedPermSpaceStart).
	self deny: (memoryMap isOldObject: memoryMap fixedPermSpaceStart)
]

{ #category : 'tests' }
VMMemoryMapTest >> testCalculateMaskBeforeAllocationTerminatesWithDiscriminatingMask [

	"initializeMemoryMap calls calculateMaskToUse on the zero-initialized map.
	 It must terminate (simulation Integers are unbounded: without the
	 bitAnd: guard in maskForObjectsFrom:to:allOnes: the shift loop
	 sign-extends forever) and produce a usable mask from the configured
	 bases."

	memoryMap calculateMaskToUse.
	self deny: memoryMap spaceMaskToUse = 0
]

{ #category : 'tests' }
VMMemoryMapTest >> testMaskForObjectsGroupsWholeRangeToOneValue [

	"The defining property of a space mask: every address inside the range
	 masks to the same value, so the range is one equivalence class."

	| allOnes mask |
	allOnes := 16rFFFFFFFFFFFFFFFF.
	mask := memoryMap
		        maskForObjectsFrom: 16r4000000000
		        to: 16r7FFFFFFFFF
		        allOnes: allOnes.
	self
		assert: (16r4000000000 bitAnd: mask)
		equals: (16r7FFFFFFFFF bitAnd: mask).
	self
		assert: (16r4123456789 bitAnd: mask)
		equals: (16r4000000000 bitAnd: mask).
	self assert: (mask bitAnd: allOnes) equals: mask
]

{ #category : 'tests' }
VMMemoryMapTest >> testMaskForObjectsTerminatesOnDegenerateRange [

	"Regression guard: lastAddress < firstAddress occurs transiently during
	 initialization. Bounding the differing bits with allOnes keeps the shift
	 loop finite in simulation; without it this send never returns."

	| mask |
	mask := memoryMap
		        maskForObjectsFrom: configuration newSpaceInitialAddress
		        to: configuration newSpaceInitialAddress - 1
		        allOnes: 16rFFFFFFFFFFFFFFFF.
	self assert: mask >= 0
]

{ #category : 'tests' }
VMMemoryMapTest >> testNextPowerOfTwoAfter [

	self
		assert: (memoryMap nextPowerOfTwoAfter: 16r4000000000)
		equals: 16r8000000000.
	self
		assert: (memoryMap nextPowerOfTwoAfter: 16r4000000001)
		equals: 16r8000000000.
	self assert: (memoryMap nextPowerOfTwoAfter: 1) equals: 2
]

{ #category : 'tests' }
VMMemoryMapTest >> testOldSpaceAllocatedAtVA39FallbackAddressIsClassifiedCorrectly [

	"On CONFIG_ARM64_VA_BITS_39 kernels the configured oldSpace base (2^40)
	 is not mappable and the platform allocator falls back to a lower window
	 (base 16r4000000000). The masks recomputed from the obtained address
	 must still discriminate all spaces."

	memoryMap newSpaceStart: configuration newSpaceInitialAddress.
	memoryMap newSpaceEnd:
		configuration newSpaceInitialAddress + (64 * 1024 * 1024).
	memoryMap oldSpaceStart: 16r4000000000.
	memoryMap setOldSpaceEnd: 16r4000000000 + (512 * 1024 * 1024).
	memoryMap calculateMaskToUse.
	self assertSpacesAreClassifiedCorrectly
]

{ #category : 'tests' }
VMMemoryMapTest >> testSpacesAllocatedAtConfiguredBasesAreClassifiedCorrectly [

	"The primary path: allocation succeeded exactly at the configured bases
	 (every VA48 platform). This is the allocation-location expectation the
	 removed hard error used to protect."

	memoryMap newSpaceStart: configuration newSpaceInitialAddress.
	memoryMap newSpaceEnd:
		configuration newSpaceInitialAddress + (64 * 1024 * 1024).
	memoryMap oldSpaceStart: configuration oldSpaceInitialAddress.
	memoryMap setOldSpaceEnd:
		configuration oldSpaceInitialAddress + (512 * 1024 * 1024).
	memoryMap calculateMaskToUse.
	self assertSpacesAreClassifiedCorrectly
]
