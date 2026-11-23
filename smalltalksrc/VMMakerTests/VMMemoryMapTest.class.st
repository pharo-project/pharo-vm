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
		'configuration',
		'memoryManager'
	],
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'asserting' }
VMMemoryMapTest >> assertAllocationFailsDuring: aBlock [
	"In simulation logError signals the logged message (see VMStructType>>#logError:withArgs:)"

	self should: aBlock raise: Error withExceptionDo: [ :error |
		self assert:
			(error messageText beginsWith: 'Could not allocate the ') ]
]

{ #category : 'asserting' }
VMMemoryMapTest >> assertCodeZoneIsNotAnObjectSpace [

	self deny: (memoryMap isYoungObject: memoryMap codeZoneStart).
	self deny: (memoryMap isYoungObject: memoryMap codeZoneEnd - 8).
	self deny: (memoryMap isOldObject: memoryMap codeZoneStart).
	self deny: (memoryMap isOldObject: memoryMap codeZoneEnd - 8)
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

{ #category : 'helpers' }
VMMemoryMapTest >> codeZoneSize [

	^ 1024 * 1024
]

{ #category : 'helpers' }
VMMemoryMapTest >> occupy: anAddress size: aSize [
	"Simulate memory taken by someone else (e.g. a thread stack) before the VM allocates."

	^ memoryManager allocate: aSize desiredPosition: anAddress
]

{ #category : 'helpers' }
VMMemoryMapTest >> occupyAllHolesOf: aSize from: firstAddress to: lastAddress [
	"Leave no hole of aSize bytes in [firstAddress, lastAddress).
	 The simulated allocator looks for a hole stepping by the requested size
	 (see SlangMemoryManager>>#findHoleBiggerThan:from:), so one page every
	 aSize bytes is enough."

	firstAddress to: lastAddress - 1 by: aSize do: [ :anAddress |
	self occupy: anAddress size: memoryManager pageSize ]
]

{ #category : 'helpers' }
VMMemoryMapTest >> prepareAllocation [
	"Allocate through a simulated memory manager. Like the Windows allocator,
	 it answers the first hole at or above the desired address."

	memoryManager := SlangMemoryManager new.
	memoryManager wordSize: configuration confWordSize.
	memoryMap
		memoryManager: memoryManager;
		allocationReserve: 0;
		initialNewSpaceSize: 4 * 1024 * 1024;
		initialOldSpaceSize: 8 * 1024 * 1024;
		initialHeadroom: 0;
		initialCodeZoneSize: self codeZoneSize
]

{ #category : 'running' }
VMMemoryMapTest >> setUp [

	super setUp.
	configuration := VMMemoryMapConfigurationFor64Bits new.
	memoryMap := VMMemoryMap new.
	memoryMap initializeMemoryMap.
	memoryMap memoryMapConfiguration: configuration
]

{ #category : 'helpers' }
VMMemoryMapTest >> stackPagesSize [

	^ 1024 * 1024
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

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testCodeZoneIsAllocatedAboveItsAddressWhenItIsTaken [
	"Issue #1112: on Windows another mapping (e.g. a thread stack placed by ASLR)
	 can take the configured address. The allocator answers the next hole above it,
	 which is usable as long as the code zone stays below new space."

	self prepareAllocation.
	self occupy: configuration codeZoneInitialAddress size: 1024 * 1024.

	memoryMap allocateHeap.

	self assert:
		memoryMap codeZoneStart > configuration codeZoneInitialAddress.
	self assert: memoryMap codeZoneEnd <= memoryMap newSpaceStart.
	self assertCodeZoneIsNotAnObjectSpace.
	self assertSpacesAreClassifiedCorrectly
]

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testCodeZoneIsRejectedWhenItWouldReachNewSpace [

	self prepareAllocation.
	self
		occupyAllHolesOf: self codeZoneSize
		from: configuration codeZoneInitialAddress
		to: configuration newSpaceInitialAddress.

	self assertAllocationFailsDuring: [ memoryMap allocateHeap ]
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

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testNewSpaceIsAllocatedAboveItsAddressWhenItIsTaken [

	self prepareAllocation.
	self occupy: configuration newSpaceInitialAddress size: 1024 * 1024.

	memoryMap allocateHeap.

	self assert:
		memoryMap newSpaceStart > configuration newSpaceInitialAddress.
	self assert: memoryMap codeZoneEnd <= memoryMap newSpaceStart.
	self assert: memoryMap newSpaceEnd <= memoryMap oldSpaceStart.
	self deny:
		(memoryMap isYoungObject: configuration newSpaceInitialAddress).
	self assertCodeZoneIsNotAnObjectSpace.
	self assertSpacesAreClassifiedCorrectly
]

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testNewSpaceIsRejectedWhenItWouldReachOldSpace [
	"Use the 32 bits memory map: its gap between new and old space is small
	 enough to fill in the simulator."

	configuration := VMMemoryMapConfigurationFor32Bits new.
	memoryMap memoryMapConfiguration: configuration.
	self prepareAllocation.
	self
		occupyAllHolesOf: 4 * 1024 * 1024
		from: configuration newSpaceInitialAddress
		to: configuration oldSpaceInitialAddress.

	self assertAllocationFailsDuring: [ memoryMap allocateHeap ]
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

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testStackPagesAreAllocatedAboveTheirAddressWhenItIsTaken [
	"Issue #1112: the main thread stack can take the configured address of the
	 stack pages. The next hole above it is usable as long as the stack pages
	 stay below the code zone."

	self prepareAllocation.
	memoryMap allocateHeap.
	self occupy: configuration stackPagesInitialAddress size: 1024 * 1024.

	memoryMap allocateStackPages: self stackPagesSize.

	self assert:
		memoryMap stackPagesStart > configuration stackPagesInitialAddress.
	self assert: memoryMap stackPagesEnd <= memoryMap codeZoneStart
]

{ #category : 'tests - allocation' }
VMMemoryMapTest >> testStackPagesAreRejectedWhenTheyWouldReachTheCodeZone [

	self prepareAllocation.
	memoryMap allocateHeap.
	self
		occupyAllHolesOf: self stackPagesSize
		from: configuration stackPagesInitialAddress
		to: configuration codeZoneInitialAddress.

	self assertAllocationFailsDuring: [
		memoryMap allocateStackPages: self stackPagesSize ]
]
