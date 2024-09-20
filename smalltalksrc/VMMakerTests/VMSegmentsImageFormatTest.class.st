Class {
	#name : #VMSegmentsImageFormatTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-ImageFormat'
}

{ #category : #tests }
VMSegmentsImageFormatTest >> testImageWithTwoSegmentsHasCorrectSizeForFirstSegment [

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
VMSegmentsImageFormatTest >> testImageWithTwoSegmentsHasCorrectSizeForFullImage [

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
VMSegmentsImageFormatTest >> testImageWithTwoSegmentsRespectGrowHeadroomWhenIsBigger [

	| newSegmentSize |
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self assert: newSegmentSize >= memory growHeadroom
]

{ #category : #tests }
VMSegmentsImageFormatTest >> testImageWithTwoSegmentsRespectGrowHeadroomWhenIsSmaller [

	| newSegmentSize |
	
	memory growHeadroom: 4096.
	
	newSegmentSize := memory growOldSpaceByAtLeast: 10000.
	
	self assert: memory segmentManager numSegments equals: 2.
	self assert: (memory segmentManager segments at: 1) segSize equals: newSegmentSize.
	
	self assert: newSegmentSize >= memory growHeadroom
]

{ #category : #tests }
VMSegmentsImageFormatTest >> testMinimalImageHasASingleSegment [


	| header |
	self assert: memory segmentManager numSegments equals: 1.
	self saveImage.

	header := self readHeader.

	"Having a single segment is that the size of data is equals to the first segment size"
	self assert: header firstSegSize equals: header dataSize 
]
