Class {
	#name : #VMSpurSegmentsImageFormatTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #actions }
VMSpurSegmentsImageFormatTest >> saveImage [

	interpreter extraVMMemory: 0.

	interpreter imageName: self imageFileName.
	interpreter preemptionYields: false.
	interpreter setImageHeaderFlagsFrom: 0.
	
	interpreter writeImageFileIO.

]

{ #category : #tests }
VMSpurSegmentsImageFormatTest >> testImageWithTwoSegmentsHasCorrectSizeForFirstSegment [

	| header newSegmentSize |
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self saveImage.

	header := self readHeader.

	self
		assert: header firstSegSize
		equals: (memory segmentManager segments at: 0) segSize
]

{ #category : #tests }
VMSpurSegmentsImageFormatTest >> testImageWithTwoSegmentsHasCorrectSizeForFullImage [

	| header newSegmentSize |
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self saveImage.

	header := self readHeader.

	self
		assert: header firstSegSize
		equals: (memory segmentManager segments at: 0) segSize.
		
	self
		assert: header dataSize
		equals: header firstSegSize + newSegmentSize
]

{ #category : #tests }
VMSpurSegmentsImageFormatTest >> testImageWithTwoSegmentsRespectGrowHeadroomWhenIsBigger [

	| newSegmentSize |
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self assert: newSegmentSize >= memory growHeadroom
]

{ #category : #tests }
VMSpurSegmentsImageFormatTest >> testImageWithTwoSegmentsRespectGrowHeadroomWhenIsSmaller [

	| newSegmentSize |
	
	memory growHeadroom: 4096.
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self assert: newSegmentSize >= memory growHeadroom
]

{ #category : #tests }
VMSpurSegmentsImageFormatTest >> testMinimalImageHasASingleSegment [


	| header |
	self assert: memory segmentManager numSegments equals: 1.
	self saveImage.

	header := self readHeader.

	"Having a single segment is that the size of data is equals to the first segment size"
	self assert: header firstSegSize equals: header dataSize 
]
