Class {
	#name : #STONImageReader,
	#superclass : #AbstractSTONImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #api }
STONImageReader >> readHeaderFromImage: anImageFileName [

	| header |
	header := (self headerFile: anImageFileName) readStreamDo: [ :f | 
		          self readSTONFrom: f ].

	self extractImageVersionFrom: (header imageFormat) into: (self addressOf: header).

	^ header
]

{ #category : #api }
STONImageReader >> readImageNamed: anImageName [
	
	| header imageFile |

	imageFile := self imageFile: anImageName.
	header := self readHeaderFromImage: anImageName.

	self loadHeaderToMemory: header.
	interpreter allocateMemoryForImage: imageFile withHeader: header.

	^ header dataSize
]

{ #category : #reading }
STONImageReader >> readSTONFrom: f [

	<var: #f type: #sqImageFile>
	<returnTypeC: #SpurImageHeaderStruct>

	^ STON reader on: f; next
]

{ #category : #api }
STONImageReader >> readSegmentMetadata: segmentIndex fromFile: imageFile [

	^ (self segmentMetadataFile: segmentIndex fromFile: imageFile) 
		  readStreamDo: [ :f | self readSTONFrom: f ]
]

{ #category : #reading }
STONImageReader >> readSegmentsFromImageFile: imageFile header: aHeader [

	"Compare with SpurImageReader >> readSegmentsFromImageFile:header:"

	<var: #imageFile type: #sqImageFile>
	<inline: false>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	| bytesRead totalBytesRead bridgehead bridge segmentSize oldBase newBase segmentIndex existNextSegment |

	segmentManager clearSegments.
	segmentManager allocateOrExtendSegmentInfos.

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
	existNextSegment := (imageFile childrenMatching: 'seg' , segmentIndex asString , '*' ) isNotEmpty.
	
	existNextSegment ifTrue: [ | nextSegmentMetadata |
			nextSegmentMetadata := self readSegmentMetadata: segmentIndex fromFile: imageFile.
			oldBase := nextSegmentMetadata segStart.
			segmentSize := nextSegmentMetadata segSize.
		].
	
	existNextSegment
	] whileTrue.

	"newBase should point just past the last bridge. all others should have been eliminated."
	self assert:
		newBase - objectMemory getMemoryMap oldSpaceStart = (totalBytesRead
		 - (segmentManager numSegments * objectMemory bridgeSize)).

	"Segments has correct swizzle values, so it can be used to swizzle objects"
	segmentManager setCanSwizzle: true.

	"set freeOldSpaceStart now for adjustAllOopsBy:"
	objectMemory setFreeOldSpaceStart: newBase.

	^ totalBytesRead
]

{ #category : #reading }
STONImageReader >> sq: startingAddress readSegment: segmentIndex File: bytesToRead Read: imageFile [

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
