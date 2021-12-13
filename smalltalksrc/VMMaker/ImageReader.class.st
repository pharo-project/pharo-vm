Class {
	#name : #ImageReader,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory'
	],
	#category : #'VMMaker-Support'
}

{ #category : #'instance creation' }
ImageReader class >> newWithMemory: memory [

	| imageReader |
	imageReader := self new.
	imageReader objectMemory: memory.
	^ imageReader
]

{ #category : #reading }
ImageReader >> extractImageVersionFrom: file into: header [
	"Read and verify the image file version number and return true if the the given image file needs to be byte-swapped. As a side effect, position the file stream just after the version number of the image header. This code prints a warning and does a hard-exit if it cannot find a valid version number."
	"This code is based on C code by Ian Piumarta."

	<inline: false>
	| version firstVersion |
	<var: #file type: #sqImageFile>
	<var: #imageOffset type: #squeakFileOffsetType>
	<var: #header type: #SpurImageHeaderStruct>

	"check the version number"
	version := firstVersion := self getWord32FromFile: file swap: false.
	(self readableFormat: version) ifTrue: [
		header imageFormat: version.
		header swapBytes: false.
		^ self].

	"try with bytes reversed"
	(self readableFormat: version byteSwap32) 
		ifTrue: [
			header imageFormat: version byteSwap32.
			header swapBytes: true.
			^ self].

	"hard failure; abort"
	self logError: 'Invalid image format: detected version %d, expected version %d' 
		_: firstVersion 
		_: self imageFormatVersion.
	
	self ioExitWithErrorCode: 1.

]

{ #category : #reading }
ImageReader >> getLongFromFile: aFile swap: swapFlag [
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

{ #category : #reading }
ImageReader >> getShortFromFile: aFile swap: swapFlag [
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

{ #category : #reading }
ImageReader >> getWord32FromFile: aFile swap: swapFlag [
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
ImageReader >> imageFormatCompatibilityVersion [
	"This VM is backward-compatible with the immediately preceding version."

	^objectMemory wordSize = 4 ifTrue: [6504] ifFalse: [68002]
]

{ #category : #reading }
ImageReader >> imageFormatVersion [
	"Return a magic constant that changes when the image format changes.
	 Since the image reading code uses this to detect byte ordering, one
	 must avoid version numbers that are invariant under byte reversal."
	
	"THIS METHOD KEEP DUPLICATED IN StackInterpreter UNTIL SPLIT IMAGE WRITTER"
	<doNotGenerate>
	self assert: (objectMemory imageFormatVersion anyMask: 16) = objectMemory hasSpurMemoryManagerAPI.
	^objectMemory imageFormatVersion
]

{ #category : #accessing }
ImageReader >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #reading }
ImageReader >> readHeaderFrom: f startingAt: headerStart [

	<var: #f type: #sqImageFile>
	<var: #headerStart type: #squeakFileOffsetType>
	<var: #header type: #SpurImageHeaderStruct>
	<returnTypeC: #SpurImageHeaderStruct>
	| header |
	self simulationOnly: [ header := SpurImageHeaderStruct new ]. "It's ok this simulationOnly: ?"

	self extractImageVersionFrom: f into: header.

	header headerSize: (self getWord32FromFile: f swap: header swapBytes).
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
	self sqImageFile: f Seek: headerStart + header headerSize.

	^ header
]

{ #category : #reading }
ImageReader >> readableFormat: imageVersion [
	"Anwer true if images of the given format are readable by this interpreter.
	 Allows a virtual machine to accept selected older image formats."

	^imageVersion = self imageFormatVersion "Float words in platform-order"
	   or: [objectMemory hasSpurMemoryManagerAPI not "No compatibility version for Spur as yet"
			and: [imageVersion = self imageFormatCompatibilityVersion]] "Float words in BigEndian order"
]
