Class {
	#name : #STONImageReader,
	#superclass : #AbstractSTONImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #api }
STONImageReader >> loadImageFromFile: f withHeader: header [

	self flag: #TODO. "We have many files"
	self flag: #TODO. "Read segments"
	self initializeInterpreterFromHeader: header withBytes: 0 "bytesToShift"
]

{ #category : #reading }
STONImageReader >> readHeaderFrom: f [

	<var: #f type: #sqImageFile>
	<var: #headerStart type: #squeakFileOffsetType>
	<var: #header type: #SpurImageHeaderStruct>
	<returnTypeC: #SpurImageHeaderStruct>

	^ STON reader on: f; next
]

{ #category : #api }
STONImageReader >> readHeaderFromImage: anImageFileName [

	| header |
	header := (self headerFileName: anImageFileName) asFileReference readStreamDo: [ :f | 
		          self readHeaderFrom: f ].

	^ header
]

{ #category : #api }
STONImageReader >> readImageNamed: anImageName [
	
	| header f |

	self flag: #TODO. "We have many files"
	f := anImageName asFileReference readStream.

	header := self readHeaderFromImage: anImageName.

	self loadHeaderToMemory: header.

	interpreter allocateMemoryForImage: f withHeader: header.

	^ header dataSize
]
