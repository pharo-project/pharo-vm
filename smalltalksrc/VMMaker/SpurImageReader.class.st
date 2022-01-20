Class {
	#name : #SpurImageReader,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'file operations' }
SpurImageReader >> getLongFromFile: aFile swap: swapFlag [
	"Answer the next 32 or 64 bit word read from aFile, byte-swapped according to the swapFlag."
	<var: #aFile type: #sqImageFile>
	<var: #w type: #usqInt>
	| w |
	w := 0.
	self cCode: [self
					sq: (self addressOf: w)
					Image: (self sizeof: w)
					File: 1
					Read: aFile]
		inSmalltalk: [w := objectMemory nextLongFrom: aFile].
	^swapFlag
		ifTrue: [objectMemory byteSwapped: w]
		ifFalse: [w]
]

{ #category : #'file operations' }
SpurImageReader >> getShortFromFile: aFile swap: swapFlag [
	"Answer the next 16 bit word read from aFile, byte-swapped according to the swapFlag."

	<var: #aFile type: #sqImageFile>
	| w |
	<var: #w type: #'unsigned short'>
	w := 0.
	self cCode: [self
					sq: (self addressOf: w)
					Image: (self sizeof: #'unsigned short')
					File: 1
					Read: aFile]
		inSmalltalk: [w := aFile nextLittleEndianNumber: 2].
	^swapFlag
		ifTrue: [((w >> 8) bitAnd: 16rFF) bitOr: ((w bitAnd: 16rFF) << 8)]
		ifFalse: [w]
]

{ #category : #'file operations' }
SpurImageReader >> getWord32FromFile: aFile swap: swapFlag [
	"Answer the next 32 bit word read from aFile, byte-swapped according to the swapFlag."

	<var: #aFile type: #sqImageFile>
	| w |
	<var: #w type: #int>
	w := 0.
	self cCode: [self
					sq: (self addressOf: w)
					Image: (self sizeof: #int)
					File: 1
					Read: aFile]
		inSmalltalk: [w := objectMemory nextWord32From: aFile].
	^swapFlag
		ifTrue: [w byteSwap32]
		ifFalse: [w]
]

{ #category : #reading }
SpurImageReader >> readHeaderFrom: f startingAt: headerStart [

	<var: #f type: #sqImageFile>
	<var: #headerStart type: #squeakFileOffsetType>
	<var: #header type: #SpurImageHeaderStruct>
	<returnTypeC: #SpurImageHeaderStruct>
	
	| header version |
	
	self simulationOnly: [ header := SpurImageHeaderStruct new ].
	
	version := self getWord32FromFile: f swap: false.
	self extractImageVersionFrom: version into: (self addressOf: header).

	header imageHeaderSize: (self getWord32FromFile: f swap: header swapBytes).
	header dataSize: (self getLongFromFile: f swap: header swapBytes).
	header oldBaseAddr: (self getLongFromFile: f swap: header swapBytes).
	header initialSpecialObjectsOop:
		(self getLongFromFile: f swap: header swapBytes).

	header hdrLastHash: (self getLongFromFile: f swap: header swapBytes).

	"savedWindowSize :="
	self getLongFromFile: f swap: header swapBytes.
	header headerFlags: (self getLongFromFile: f swap: header swapBytes).

	header extraVMMemory:
		(self getWord32FromFile: f swap: header swapBytes).
	header hdrNumStackPages:
		(self getShortFromFile: f swap: header swapBytes).
	"This slot holds the size of the native method zone in 1k units. (pad to word boundary)."
	header hdrCogCodeSize:
		(self getShortFromFile: f swap: header swapBytes) * 1024.
	header hdrEdenBytes:
		(self getWord32FromFile: f swap: header swapBytes).

	header hdrMaxExtSemTabSize:
		(self getShortFromFile: f swap: header swapBytes).
	"pad to word boundary.  This slot can be used for anything else that will fit in 16 bits.
	 Preserve it to be polite to other VMs."
	"the2ndUnknownShort :="
	self getShortFromFile: f swap: header swapBytes.
	header firstSegSize: (self getLongFromFile: f swap: header swapBytes).

	header freeOldSpaceInImage:
		(self getLongFromFile: f swap: header swapBytes).

	"position file after the header"
	self sqImageFile: f Seek: headerStart + header imageHeaderSize.

	^ header
]

{ #category : #api }
SpurImageReader >> readHeaderFromImage: anImageName [

	| header |
	header := anImageName asFileReference binaryReadStreamDo: [ :f | 
		          self readHeaderFrom: f startingAt: 0 ].
	^ header
]

{ #category : #reading }
SpurImageReader >> readImageFromFile: f StartingAt: headerStart [

	"Read an image from the given file stream, allocating an amount of memory to its object heap.
	
	 This routine will attempt to provide at least extraVMMemory's
	 ammount of free space after the image is loaded, taking any free space in teh image into account.
	 extraVMMemory is stored in the image header and is accessible as vmParameterAt: 23.  If
	 extraVMMemory is 0, the value defaults to the default grow headroom.  Fail if the image has an
	 unknown format or if sufficient memory cannot be allocated.

	 Details: This method detects when the image was stored on a machine with the opposite byte
	 ordering from this machine and swaps the bytes automatically. Furthermore, it allows the header
	 information to start 512 bytes into the file, since some file transfer programs for the Macintosh
	 apparently prepend a Mac-specific header of this size. Note that this same 512 bytes of prefix
	 area could also be used to store an exec command on Unix systems, allowing one to launch
	 Smalltalk by invoking the image name as a command."

	<var: #f type: #sqImageFile>
	<var: #headerStart type: #'squeakFileOffsetType'>

	<var: #heapSize type: #usqInt>
	<var: #minimumMemory type: #usqInt>
	<var: #allocationReserve type: #usqInt>
	<var: #header type: #'SpurImageHeaderStruct'>

	<api>
	
	| header |

	header := self readHeaderFrom: f startingAt: headerStart.

	self loadHeaderToMemory: header.

	interpreter allocateMemoryForImage: f withHeader: header.

	^ header dataSize
]

{ #category : #api }
SpurImageReader >> readImageNamed: anImageName [
	
	^ self readImageFromFile: anImageName asFileReference binaryReadStream StartingAt: 0  
]

{ #category : #segments }
SpurImageReader >> readSegmentsFromImageFile: f header: aHeader [

	"Read numBytes of image data from f into memory at memoryBaseForImageRead.
	 Answer the number of bytes written.  In addition, read each segment, build up the
	 segment info for swizzling, while eliminating the bridge objects at the end of each
	 segment that specify the distance to and the size of the subsequent segment."

	<var: #f type: #sqImageFile>
	<inline: false>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	| bytesRead totalBytesRead bridgehead bridge nextSegmentSize oldBase newBase bridgeSpan |
	segmentManager clearSegments.
	segmentManager allocateOrExtendSegmentInfos.

	"segment sizes include the two-header-word bridge at the end of each segment."
	totalBytesRead := 0.
	oldBase := aHeader oldBaseAddr.
	newBase := objectMemory getMemoryMap oldSpaceStart.
	nextSegmentSize := aHeader firstSegSize.
	bridgehead := aHeader firstSegSize + objectMemory getMemoryMap oldSpaceStart
	              - objectMemory bridgeSize.

	[ 
	segmentManager withNewSegmentDo: [ :segInfo | 
		segInfo
			segStart: oldBase;
			segSize: nextSegmentSize;
			swizzle: newBase - oldBase ].

	bytesRead := self
		             sq: (self pointerForOop: newBase)
		             Image: (self sizeof: #char)
		             File: nextSegmentSize
		             Read: f.

	bytesRead > 0 ifTrue: [ totalBytesRead := totalBytesRead + bytesRead ].

	bytesRead ~= nextSegmentSize ifTrue: [ 
		interpreter unableToReadImageError ].

	bridge := bridgehead + objectMemory baseHeaderSize.
	bridgeSpan := (objectMemory rawNumSlotsOf: bridgehead) = 0
		              ifTrue: [ 0 ]
		              ifFalse: [ 
			              objectMemory bytesPerOop
			              * (objectMemory rawOverflowSlotsOf: bridge) ].
	oldBase := oldBase + nextSegmentSize + bridgeSpan.
	newBase := newBase + nextSegmentSize - objectMemory bridgeSize.
	nextSegmentSize := (objectMemory long64At: bridge) asUnsignedInteger.
	nextSegmentSize ~= 0 ] whileTrue: [ 
		bridgehead := bridgehead - objectMemory bridgeSize + nextSegmentSize ].

	"newBase should point just past the last bridge. all others should have been eliminated."
	self assert: newBase - objectMemory getMemoryMap oldSpaceStart = (totalBytesRead
		 - (segmentManager numSegments * objectMemory bridgeSize)).

	"Segments has correct swizzle values, so it can be used to swizzle objects"
	segmentManager setCanSwizzle: true.

	"set freeOldSpaceStart now for adjustAllOopsBy:"
	objectMemory setFreeOldSpaceStart: newBase.

	^ totalBytesRead
]

{ #category : #'file operations' }
SpurImageReader >> sq: startingAddress Image: byteSize File: bytesToRead Read: aZnBufferedReadStream [ 

	<doNotGenerate>
	| region |

	region := objectMemory memoryManager regionForAddress: startingAddress.

	^ aZnBufferedReadStream
		readInto: region memory
		startingAt: startingAddress - region start + 1
		count: bytesToRead
]
