Class {
	#name : #SpurImageWriter,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
SpurImageWriter class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		removeVariable: 'objectMemory';
		removeVariable: 'interpreter'.

]

{ #category : #'instance creation' }
SpurImageWriter class >> newWithMemory: memory andInterpreter: anInterpreter [


	| imageWriter |
	imageWriter := self new.
	imageWriter objectMemory: memory.
	imageWriter interpreter: anInterpreter.
	^ imageWriter
]

{ #category : #accessing }
SpurImageWriter >> interpreter: anInterpreter [

	<doNotGenerate>
	interpreter := anInterpreter
]

{ #category : #accessing }
SpurImageWriter >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

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
SpurImageWriter >> sqImageFile: imageName Open: fileMode [

	<doNotGenerate>
	^imageName asFileReference binaryWriteStream
]

{ #category : #'accessing - files' }
SpurImageWriter >> sqImageFileClose: file [

	<doNotGenerate>
	file close
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

	| headerStart imageHeaderSize f imageBytes bytesWritten |

	<var: #headerStart type: #squeakFileOffsetType>
	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #f type: #sqImageFile>
	<var: #header type: #SpurImageHeaderStruct>

	headerStart := 0.  
	imageHeaderSize := header imageHeaderSize.

	self logDebug: 'Writing snapshot file %s' _: imageFileName.

	f := self sqImageFile: imageFileName Open: 'wb'.
	f = nil ifTrue: "could not open the image file for writing"
		[^self primitiveFail].

	imageBytes := header dataSize.
	headerStart := self sqImage: f File: imageFileName StartLocation: imageHeaderSize + imageBytes.
	self cCode: '/* Note: on Unix systems one could put an exec command here, padded to 512 bytes */'.
	"position file to start of header"
	self sqImageFile: f Seek: headerStart.

	self writeHeader: header toFile: f.

	objectMemory hasSpurMemoryManagerAPI
		ifTrue:
			[self putLong: objectMemory firstSegmentBytes toFile: f.
			 self putLong: objectMemory bytesLeftInOldSpace toFile: f.
			 self padHeader: 2 toFile: f]
		ifFalse:
			[self padHeader: 4 toFile: f].


	"position file after the header"
	self assert: headerStart + imageHeaderSize = (self sqImageFilePosition: f).
	self sqImageFile: f Seek: headerStart + imageHeaderSize.

	interpreter successful ifFalse: "file write or seek failure"
		[self sqImageFileClose: f.
		 ^nil].

	"write the image data"
	bytesWritten := objectMemory writeImageSegmentsToFile: f.

	interpreter success: bytesWritten = imageBytes.
	self sqImageFileClose: f.
	
	self logDebug: 'Snapshot file %s done' _: imageFileName.
]
