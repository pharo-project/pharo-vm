Class {
	#name : #AbstractImageAccess,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter',
		'segmentManager'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
AbstractImageAccess class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		removeVariable: 'objectMemory';
		removeVariable: 'interpreter';
		removeVariable: 'segmentManager'
]

{ #category : #translation }
AbstractImageAccess class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."
	^#void
]

{ #category : #'instance creation' }
AbstractImageAccess class >> newWithMemory: memory andInterpreter: anInterpreter [

	| newInstance |
	
	newInstance := self new.
	newInstance objectMemory: memory.
	newInstance interpreter: anInterpreter.
	newInstance segmentManager: memory segmentManager.
	
	^ newInstance
]

{ #category : #'accessing - files' }
AbstractImageAccess >> beginWriteImageSegments [

	self assert:
		(objectMemory getMemoryMap oldSpaceEnd = segmentManager lastSegment segLimit 
		or: [ objectMemory getMemoryMap oldSpaceEnd + objectMemory bridgeSize = segmentManager lastSegment segLimit ]).

	self assert: segmentManager firstSegmentBytes > 0.

]

{ #category : #reading }
AbstractImageAccess >> extractImageVersionFrom: fileVersion into: header [
	"Read and verify the image file version number and return true if the the given image file needs to be byte-swapped. As a side effect, position the file stream just after the version number of the image header. This code prints a warning and does a hard-exit if it cannot find a valid version number."
	"This code is based on C code by Ian Piumarta."

	| version firstVersion |
	<var: #file type: #sqImageFile>
	<var: #imageOffset type: #squeakFileOffsetType>
	<var: #header type: #'SpurImageHeaderStruct *'>

	"check the version number"
	version := firstVersion := fileVersion.
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

{ #category : #segments }
AbstractImageAccess >> finalizeSegmentsRead: totalBytesRead newBase: newBase [

	"newBase should point just past the last bridge. all others should have been eliminated."
	self assert: newBase - objectMemory getMemoryMap oldSpaceStart = (totalBytesRead
		 - (segmentManager numSegments * objectMemory bridgeSize)).

	"Segments has correct swizzle values, so it can be used to swizzle objects"
	segmentManager setCanSwizzle: true.

	"set freeOldSpaceStart now for adjustAllOopsBy:"
	objectMemory setFreeOldSpaceStart: newBase.

]

{ #category : #reading }
AbstractImageAccess >> imageFormatCompatibilityVersion [
	"This VM is backward-compatible with the immediately preceding version."

	^objectMemory wordSize = 4 ifTrue: [6504] ifFalse: [68002]
]

{ #category : #reading }
AbstractImageAccess >> imageFormatVersion [
	"Return a magic constant that changes when the image format changes.
	 Since the image reading code uses this to detect byte ordering, one
	 must avoid version numbers that are invariant under byte reversal."

	<doNotGenerate>
	self assert: (objectMemory imageFormatVersion anyMask: 16) = objectMemory hasSpurMemoryManagerAPI.
	^objectMemory imageFormatVersion
]

{ #category : #reading }
AbstractImageAccess >> initializeInterpreterFromHeader: header withBytes: bytesRead [

	| bytesToShift |

	bytesRead ~= header dataSize ifTrue: [ 
		interpreter unableToReadImageError ].

	interpreter ensureImageFormatIsUpToDate: header swapBytes.

	"compute difference between old and new memory base addresses"
	bytesToShift := objectMemory getMemoryMap oldSpaceStart - header oldBaseAddr.
	
	interpreter initializeInterpreter: bytesToShift "adjusts all oops to new location"
]

{ #category : #accessing }
AbstractImageAccess >> interpreter [

	<doNotGenerate>

	^ interpreter
]

{ #category : #accessing }
AbstractImageAccess >> interpreter: anObject [

	<doNotGenerate>

	interpreter := anObject
]

{ #category : #reading }
AbstractImageAccess >> loadHeaderToMemory: header [

	objectMemory createMemoryMap.

	objectMemory specialObjectsOop: header initialSpecialObjectsOop.
	objectMemory lastHash: header hdrLastHash.
	
	interpreter setImageHeaderFlagsFrom: header headerFlags.
	interpreter setExtraVMMemory: header extraVMMemory.

	interpreter setNumStackPages: header hdrNumStackPages.

	interpreter initializeObjectMemoryWithEdenBytes: header hdrEdenBytes.

	header hdrMaxExtSemTabSize ~= 0 ifTrue: [ 
		interpreter setMaxExtSemSizeTo: header hdrMaxExtSemTabSize ].

]

{ #category : #api }
AbstractImageAccess >> loadImageFromFile: imageFile withHeader: header [

	"read in the image in bulk, then swap the bytes if necessary"

	<var: #f type: #sqImageFile>
	<var: #header type: #SpurImageHeaderStruct>
	| bytesRead |

	bytesRead := self readSegmentsFromImageFile: imageFile header: header.

	self initializeInterpreterFromHeader: header withBytes: bytesRead

]

{ #category : #accessing }
AbstractImageAccess >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #segments }
AbstractImageAccess >> prepareSegmentsToRead [

	segmentManager clearSegments.
	segmentManager allocateOrExtendSegmentInfos
]

{ #category : #segments }
AbstractImageAccess >> readSegmentsFromImageFile: imageFile header: header [

	self subclassResponsibility 
]

{ #category : #reading }
AbstractImageAccess >> readableFormat: imageVersion [
	"Anwer true if images of the given format are readable by this interpreter.
	 Allows a virtual machine to accept selected older image formats."

	^imageVersion = self imageFormatVersion "Float words in platform-order"
	   or: [objectMemory hasSpurMemoryManagerAPI not "No compatibility version for Spur as yet"
			and: [imageVersion = self imageFormatCompatibilityVersion]] "Float words in BigEndian order"
]

{ #category : #accessing }
AbstractImageAccess >> segmentManager: anObject [

	<doNotGenerate>
	segmentManager := anObject
]

{ #category : #'accessing - files' }
AbstractImageAccess >> sq: segStart Image: n File: segSize Write: file [

	<doNotGenerate>
	| region |
	region := objectMemory memoryManager regionForAddress: segStart.

	file
		next: segSize
		putAll: region memory
		startingAt: segStart - region start + 1.
	
	^ segSize
]

{ #category : #'accessing - files' }
AbstractImageAccess >> sqImageFile: imageName Open: fileMode [

	<doNotGenerate>
	| file |
	file := imageName asFileReference.
	(fileMode = 'r') ifTrue: [ ^ file readStream ].
	(fileMode = 'rb') ifTrue: [ ^ file binaryReadStream ].
	(fileMode = 'w') ifTrue: [ ^ file writeStream ].
	(fileMode = 'wb') ifTrue: [ ^ file binaryWriteStream ].
	self error: 'File mode not supported'
]

{ #category : #'accessing - files' }
AbstractImageAccess >> sqImageFileClose: file [

	<doNotGenerate>
	file close
]
