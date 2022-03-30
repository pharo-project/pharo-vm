Class {
	#name : #SpurImageWriter,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #writing }
SpurImageWriter >> padHeader: emptySize toFile: f [

	emptySize timesRepeat: [self putLong: 0 toFile: f].
	
	objectMemory wordSize = 8 ifTrue:
		[3 timesRepeat: [self putLong: 0 toFile: f]]. "Pad the rest of the header."

]

{ #category : #writing }
SpurImageWriter >> putLong: aLong toFile: aFile [
	"Append aLong to aFile in this platform's 'natural' byte order.  aLong is either 32 or 64 bits,
	 depending on ObjectMemory.  (Bytes will be swapped, if necessary, when the image is read
	 on a different platform.) Set successFlag to false if the write fails."

	<var: #aLong type: #sqInt>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aLong) Image: (self sizeof: #sqInt) File: 1 Write: aFile]
						inSmalltalk:
							[| value |
							 value := aLong.
							 objectMemory wordSize timesRepeat:
								[aFile nextPut: (value bitAnd: 16rFF).
								 value := value >> 8].
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #writing }
SpurImageWriter >> putShort: aShort toFile: aFile [
	"Append the 16-bit aShort to aFile in this platform's 'natural' byte order.
	 (Bytes will be swapped, if necessary, when the image is read on a
	 different platform.) Set successFlag to false if the write fails."

	<var: #aShort type: #short>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aShort) Image: (self sizeof: #short) File: 1 Write: aFile]
						inSmalltalk:
							[aFile
								nextPut: (aShort bitAnd: 16rFF);
								nextPut: (aShort >> 8 bitAnd: 16rFF).
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #writing }
SpurImageWriter >> putWord32: aWord32 toFile: aFile [
	"Append aWord32 to aFile in this platform's 'natural' byte order.  aWord32 is 32 bits,
	 depending on ObjectMemory.  (Bytes will be swapped, if necessary, when the image is read
	 on a different platform.) Set successFlag to false if the write fails."

	<var: #aWord32 type: #int>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aWord32) Image: 4 File: 1 Write: aFile]
						inSmalltalk:
							[| value |
							 value := aWord32.
							 4 timesRepeat:
								[aFile nextPut: (value bitAnd: 16rFF).
								 value := value >> 8].
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #'accessing - files' }
SpurImageWriter >> sqImage: file File: imageName StartLocation: location [

	<doNotGenerate>
	^0
]

{ #category : #'accessing - files' }
SpurImageWriter >> sqImageFilePosition: file [

	<doNotGenerate>
	^file position
]

{ #category : #writing }
SpurImageWriter >> writeHeader: header toFile: f [

	self putWord32: header imageFormat toFile: f.
	self putWord32: header imageHeaderSize toFile: f.
	self putLong: header dataSize toFile: f.
	self putLong: header oldBaseAddr toFile: f.
	self putLong: header initialSpecialObjectsOop toFile: f.
	self putLong: header hdrLastHash toFile: f.
	self putLong: header screenSize toFile: f.
	self putLong: header headerFlags toFile: f.
	self putWord32: header extraVMMemory toFile: f.
	self putShort: header hdrNumStackPages toFile: f.
	self putShort: header hdrCogCodeSize toFile: f.
	self putWord32: header hdrEdenBytes toFile: f.
	self putShort: header hdrMaxExtSemTabSize toFile: f.
	self putShort: 0 toFile: f. "the2ndUnknownShort"

]

{ #category : #writing }
SpurImageWriter >> writeImageFile: imageFileName fromHeader: header [

	"Write the image header and heap contents to imageFile for snapshot. c.f. writeImageFileIOSimulation.
	 The game below is to maintain 64-bit alignment for all putLong:toFile: occurrences."

	<var: #headerStart type: #squeakFileOffsetType>
	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #f type: #sqImageFile>
	<var: #header type: #SpurImageHeaderStruct>
	| headerStart imageHeaderSize f imageBytes bytesWritten |
	headerStart := 0.
	imageHeaderSize := header imageHeaderSize.

	self logDebug: 'Writing snapshot file %s' _: imageFileName.

	f := self sqImageFile: imageFileName Open: 'wb'.
	f ifNil: [ "could not open the image file for writing" 
		^ self primitiveFail ].

	imageBytes := header dataSize.
	headerStart := self
		               sqImage: f
		               File: imageFileName
		               StartLocation: imageHeaderSize + imageBytes.
	self cCode:
		'/* Note: on Unix systems one could put an exec command here, padded to 512 bytes */'.
	"position file to start of header"
	self sqImageFile: f Seek: headerStart.

	self writeHeader: header toFile: f.

	self putLong: objectMemory firstSegmentBytes toFile: f.
	self putLong: objectMemory bytesLeftInOldSpace toFile: f.
	self padHeader: 2 toFile: f.


	"position file after the header"
	self assert:
		headerStart + imageHeaderSize = (self sqImageFilePosition: f).
	self sqImageFile: f Seek: headerStart + imageHeaderSize.

	interpreter successful ifFalse: [ "file write or seek failure"
		self sqImageFileClose: f.
		^ nil ].

	"write the image data"
	bytesWritten := self writeImageSegmentsToFile: f.

	interpreter success: bytesWritten = imageBytes.
	self sqImageFileClose: f.

	self logDebug: 'Snapshot file %s done' _: imageFileName
]

{ #category : #writing }
SpurImageWriter >> writeImageSegmentsToFile: aBinaryStream [

	<var: 'aBinaryStream' type: #sqImageFile>
	<var: 'aSegment' type:#'SpurSegmentInfo *'>

	self beginWriteImageSegments.

	^ segmentManager withNonEmptySegmentsDo: [ :aSegment :segmentIndex | 
		self 
			writeSegment: aSegment
			nextSegment: (segmentManager nextNonEmptySegmentAfter: segmentIndex)
			toFile: aBinaryStream ].

]

{ #category : #writing }
SpurImageWriter >> writeSegment: segment nextSegment: nextSegment toFile: aBinaryStream [

	"Write the segment contents, the size of and the distance to the next segment to aBinaryStream."

	<var: 'segment' type: #'SpurSegmentInfo *'>
	<var: 'nextSegment' type: #'SpurSegmentInfo *'>
	<var: 'aBinaryStream' type: #sqImageFile>
	<var: 'firstSavedBridgeWord' type: #usqLong>
	<var: 'secondSavedBridgeWord' type: #usqLong>

	| pier1 pier2 firstSavedBridgeWord secondSavedBridgeWord nWritten |

	pier1 := segment segLimit - objectMemory bridgeSize.
	pier2 := pier1 + objectMemory baseHeaderSize.
	
	self assert: (segmentManager isValidSegmentBridge: (segmentManager bridgeFor: segment)).
	self assert: (objectMemory startOfObject: (segmentManager bridgeFor: segment)) = pier1.
	
	"Temporarily change the bridge to bridge to the next non-empty segment.
	 The first double word of the bridge includes the bridge size in slots, and
	 hence specifies the distance to the next segment. The following double
	 word is replaced by the size of the next segment, or 0 if there isn't one."
	
	firstSavedBridgeWord := objectMemory long64At: pier1.
	secondSavedBridgeWord := objectMemory long64At: pier2.
	
	segmentManager bridgeFrom: segment to: nextSegment.
	
	objectMemory
		long64At: pier2
		put: (nextSegment ifNil: [0] ifNotNil: [nextSegment segSize]).
	
	nWritten := self
						sq: segment segStart asVoidPointer
						Image: 1
						File: segment segSize
						Write: aBinaryStream.

	objectMemory
		long64At: pier1 put: firstSavedBridgeWord;
		long64At: pier2 put: secondSavedBridgeWord.

	^nWritten
]
