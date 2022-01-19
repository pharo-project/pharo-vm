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

	objectMemory initializeMemoryMap.

	objectMemory specialObjectsOop: header initialSpecialObjectsOop.
	objectMemory lastHash: header hdrLastHash.
	
	interpreter setImageHeaderFlagsFrom: header headerFlags.
	interpreter setExtraVMMemory: header extraVMMemory.

	interpreter setNumStackPages: header hdrNumStackPages.

	interpreter initializeObjectMemoryWithEdenBytes: header hdrEdenBytes.

	header hdrMaxExtSemTabSize ~= 0 ifTrue: [ 
		interpreter setMaxExtSemSizeTo: header hdrMaxExtSemTabSize ].

]

{ #category : #accessing }
AbstractImageAccess >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #accessing }
AbstractImageAccess >> segmentManager: anObject [

	<doNotGenerate>
	segmentManager := anObject
]
