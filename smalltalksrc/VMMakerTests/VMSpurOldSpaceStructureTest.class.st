Class {
	#name : 'VMSpurOldSpaceStructureTest',
	#superclass : 'VMSpurMemoryManagerTest',
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'tests' }
VMSpurOldSpaceStructureTest >> testNewMemoryOldSpaceShouldHaveOneSegment [

	self assert: memory segmentManager numSegments equals: 1
]

{ #category : 'tests' }
VMSpurOldSpaceStructureTest >> testNewMemoryOldSpaceSingleSegmentShouldBeHaveSameSizeAsOldSpace [

	self
		assert: memory segmentManager segments first segSize
		equals: memory oldSpaceSize
]

{ #category : 'tests' }
VMSpurOldSpaceStructureTest >> testNewMemoryOldSpaceSizeShouldBeAskedMemory [

	self assert: memory oldSpaceSize equals: oldSpaceSize
]
