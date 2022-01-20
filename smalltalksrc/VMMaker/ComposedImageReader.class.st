Class {
	#name : #ComposedImageReader,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #api }
ComposedImageReader >> readHeaderFromImage: anImageFileName [

	| header |
	header := (self headerFile: anImageFileName) readStreamDo: [ :f | 
		          self readSTONFrom: f ].

	self extractImageVersionFrom: (header imageFormat) into: (self addressOf: header).

	^ header
]

{ #category : #api }
ComposedImageReader >> readImageNamed: anImageName [
	
	| header imageFile |

	imageFile := self imageFile: anImageName.
	header := self readHeaderFromImage: anImageName.

	self loadHeaderToMemory: header.
	interpreter allocateMemoryForImage: imageFile withHeader: header.

	^ header dataSize
]

{ #category : #reading }
ComposedImageReader >> readSTONFrom: f [

	<var: #f type: #sqImageFile>
	<returnTypeC: #SpurImageHeaderStruct>

	^ STON reader on: f; next
]

{ #category : #api }
ComposedImageReader >> readSegmentMetadata: segmentIndex fromFile: imageFile [

	^ (self segmentMetadataFile: segmentIndex fromFile: imageFile) 
		  readStreamDo: [ :f | self readSTONFrom: f ]
]

{ #category : #segments }
ComposedImageReader >> readSegmentsFromImageFile: imageFile header: aHeader [

	"Compare with SpurImageReader >> readSegmentsFromImageFile:header:"

	<var: #imageFile type: #sqImageFile>
	<inline: false>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	| bytesRead totalBytesRead segmentSize oldBase newBase segmentIndex existsNextSegment |

	self prepareSegmentsToRead.

	"segment sizes include the two-header-word bridge at the end of each segment."
	segmentIndex := 0. 
	totalBytesRead := 0.
	oldBase := aHeader oldBaseAddr.
	newBase := objectMemory getMemoryMap oldSpaceStart.
	segmentSize := aHeader firstSegSize.
	
	[ 
	segmentManager withNewSegmentDo: [ :segInfo | 
		segInfo
			segStart: oldBase;
			segSize: segmentSize;
			swizzle: newBase - oldBase ].

	bytesRead := self 
		sq: (self pointerForOop: newBase)
		readSegment: segmentIndex
		File: segmentSize
		Read: imageFile.

	bytesRead > 0 ifTrue: [ totalBytesRead := totalBytesRead + bytesRead ].
	
	"Check segment bytes read"
	bytesRead ~= segmentSize ifTrue: [ interpreter unableToReadImageError ].

	"The next segment will override the bridge of this segment"
	newBase := newBase + segmentSize - objectMemory bridgeSize.

	"Check if exist next segment"
	segmentIndex := segmentIndex + 1. 
	existsNextSegment := imageFile hasChildrenMatching: (self segmentFileNameWithoutExtension: segmentIndex) , '*'.
	
	existsNextSegment ifTrue: [ | nextSegmentMetadata |
			nextSegmentMetadata := self readSegmentMetadata: segmentIndex fromFile: imageFile.
			oldBase := nextSegmentMetadata segStart.
			segmentSize := nextSegmentMetadata segSize.
		].
	
	existsNextSegment
	] whileTrue.

	self finalizeSegmentsRead: totalBytesRead newBase: newBase.

	^ totalBytesRead
]

{ #category : #segments }
ComposedImageReader >> sq: startingAddress readSegment: segmentIndex File: bytesToRead Read: imageFile [

	<doNotGenerate>
	| region |

	region := objectMemory memoryManager regionForAddress: startingAddress.

	^ (self segmentDataFile: segmentIndex fromFile: imageFile) binaryReadStreamDo: [ :file |
		file 
			readInto: region memory
			startingAt: startingAddress - region start + 1
			count: bytesToRead
		 ]
		
]
