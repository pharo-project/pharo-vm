Class {
	#name : #ImageWriter,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter'
	],
	#category : #'VMMaker-Support'
}

{ #category : #'instance creation' }
ImageWriter class >> newWithMemory: memory andInterpreter: anInterpreter [


	| imageWriter |
	imageWriter := self new.
	imageWriter objectMemory: memory.
	imageWriter interpreter: anInterpreter.
	^ imageWriter
]

{ #category : #accessing }
ImageWriter >> interpreter: anInterpreter [

	<doNotGenerate>
	interpreter := anInterpreter
]

{ #category : #accessing }
ImageWriter >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #writing }
ImageWriter >> padHeader: emptySize toFile: f [

	emptySize timesRepeat: [self putLong: 0 toFile: f].
	
	objectMemory wordSize = 8 ifTrue:
		[3 timesRepeat: [self putLong: 0 toFile: f]]. "Pad the rest of the header."

]

{ #category : #writing }
ImageWriter >> putLong: aLong toFile: aFile [
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
ImageWriter >> putShort: aShort toFile: aFile [
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
ImageWriter >> putWord32: aWord32 toFile: aFile [
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
ImageWriter >> sqImage: file File: imageName StartLocation: location [

	<doNotGenerate>
	^0
]

{ #category : #'accessing - files' }
ImageWriter >> sqImageFile: imageName Open: fileMode [

	<doNotGenerate>
	^imageName asFileReference binaryWriteStream
]

{ #category : #'accessing - files' }
ImageWriter >> sqImageFileClose: file [

	<doNotGenerate>
	file close
]

{ #category : #'accessing - files' }
ImageWriter >> sqImageFilePosition: file [

	<doNotGenerate>
	^file position
]

{ #category : #writing }
ImageWriter >> writeHeader: header toFile: f [

	self putWord32: header imageFormat toFile: f.
	self putWord32: header headerSize toFile: f.
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
ImageWriter >> writeImageFile: imageName fromHeader: header [
	"Write the image header and heap contents to imageFile for snapshot. c.f. writeImageFileIOSimulation.
	 The game below is to maintain 64-bit alignment for all putLong:toFile: occurrences."
	<inline: #never>
	| headerStart headerSize f imageBytes bytesWritten |
	<var: #headerStart type: #squeakFileOffsetType>
	<var: #imageName declareC: 'extern char imageName[]'>
	<var: #f type: #sqImageFile>
	<var: #sCWIfn type: #'void *'> "?"

	headerStart := 0.  
	headerSize := header headerSize.

	self logDebug: 'Writing snapshot file %s' _: imageName.

	f := self sqImageFile: imageName Open: 'wb'.
	f = nil ifTrue: "could not open the image file for writing"
		[^self primitiveFail].

	imageBytes := header dataSize.
	headerStart := self sqImage: f File: imageName StartLocation: headerSize + imageBytes.
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
	self assert: headerStart + headerSize = (self sqImageFilePosition: f).
	self sqImageFile: f Seek: headerStart + headerSize.

	interpreter successful ifFalse: "file write or seek failure"
		[self sqImageFileClose: f.
		 ^nil].

	"write the image data"
	objectMemory hasSpurMemoryManagerAPI
		ifTrue:
			[bytesWritten := objectMemory writeImageSegmentsToFile: f]
		ifFalse:
			[bytesWritten := self sq: (self pointerForOop: objectMemory baseAddressOfImage)
								Image: (self sizeof: #char)
								File: imageBytes
								Write: f].

	interpreter success: bytesWritten = imageBytes.
	self sqImageFileClose: f.
	
	self logDebug: 'Snapshot file %s done' _: imageName.

]
