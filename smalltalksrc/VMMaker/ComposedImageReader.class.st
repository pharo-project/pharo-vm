Class {
	#name : #ComposedImageReader,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #reading }
ComposedImageReader >> readFieldsSTONFrom: file into: aStruct [

	<inline: true>
	<var: #fieldName declareC: 'char buffer[255]'>
	<var: #fieldValue type: #sqLong>
	| fieldName fieldValue |
	self simulationOnly: [ 
		fieldName := ValueHolder new.
		fieldValue := ValueHolder new ].

	[ self
		fscanf: file
		_: fieldFormat
		_: (self addressOf: fieldName)
		_: (self addressOf: fieldValue) 
	] whileTrue: [  
		aStruct setField: fieldName contents to: fieldValue contents.
	]
	
]

{ #category : #reading }
ComposedImageReader >> readHeadSTONFrom: file into: aStruct [

	<inline: true>
	<var: #structName declareC: 'char buffer[255]'>
	| structName |
	self simulationOnly: [ structName := ValueHolder new ].

	self fscanf: file _: headFormat _: (self addressOf: structName).

	aStruct withStructNameDo: [ :name | 
		self assert: name = structName contents ]
]

{ #category : #api }
ComposedImageReader >> readHeaderFromImage: imageFileName [

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #buffer declareC: 'char buffer[255]'>
	<var: #header type: #SpurImageHeaderStruct>
	| header buffer file |
	
	self simulationOnly: [ 
		buffer := nil. 
		header:= SpurImageHeaderStruct new 
	].
	
	file := self sqImageFile: (self headerFileNameinImage: imageFileName into: buffer bufferSize: 255) Open: 'r'.
	
	self readSTONFrom: file into: (self addressOf: header).

	self extractImageVersionFrom: (header imageFormat) into: (self addressOf: header).
	
	self sqImageFileClose: file.

	^ header
]

{ #category : #api }
ComposedImageReader >> readImageNamed: imageName [
	
	<var: #f type: #sqImageFile>
	<var: #imageName declareC: 'char *imageName'>
	<var: #aHeader type: #'SpurImageHeaderStruct'>
	<api>

	| aHeader f |

	f := self imageFile: imageName.
	aHeader := self readHeaderFromImage: imageName.

	self loadHeaderToMemory: aHeader.
	interpreter allocateMemoryForImage: f withHeader: aHeader.

	self flag: #TODO. "Fix this"
	^ self sqImageFileClose: f readStream .
]

{ #category : #reading }
ComposedImageReader >> readSTONFrom: file [

	<doNotGenerate>
	^ STON reader
		  on: file;
		  next
]

{ #category : #reading }
ComposedImageReader >> readSTONFrom: file into: aStruct [

	<inline: true>
	self readHeadSTONFrom: file into: aStruct.
	self readFieldsSTONFrom: file into: aStruct
]

{ #category : #segments }
ComposedImageReader >> readSegmentMetadata: segmentIndex fromFile: imageFile [

	^ (self segmentMetadataFile: segmentIndex fromFile: imageFile) 
		  readStreamDo: [ :f | self readSTONFrom: f ]
]

{ #category : #segments }
ComposedImageReader >> readSegmentsFromImageFile: imageFile header: aHeader [

	<inline: false>
	<var: #imageFile type: #sqImageFile>
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
	existsNextSegment := imageFile hasChildrenMatching: (self segmentFileName: segmentIndex withExtension: '*').
	
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
