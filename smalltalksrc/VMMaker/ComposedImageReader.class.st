Class {
	#name : #ComposedImageReader,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #reading }
ComposedImageReader >> endOfSTON: file [
	
	"This method consume 2 chars from file and return they are equivalent to '\n}'"
		
	| charLeft charRight |
	charLeft := self fgetc: file.
	charRight := self fgetc: file.

	^ (self isEndOfLine: charLeft) and: [ charRight = $} ]
]

{ #category : #reading }
ComposedImageReader >> readDataFromFileName: fullFileName startingAt: startingAddress bytes: bytesToRead [

	<inline: true>
	<var: #file type: #sqImageFile>
	| file bytes |

	file := self
		        sqImageFile: fullFileName
		        Open: 'rb'.

	bytesToRead > 0 ifTrue:[
		bytes := self
			         sq: startingAddress
			         Image: (self sizeof: #char)
			         File: bytesToRead
			         Read: file]
		ifFalse: [ bytes := 0 ].

	self sqImageFileClose: file.

	^ bytes
]

{ #category : #reading }
ComposedImageReader >> readFieldsSTONFrom: file into: aStruct [

	<inline: true>
	<var: #fieldName declareC: 'char fieldName[255]'>
	<var: #fieldValue type: #sqLong>
	| fieldName fieldValue |
	self simulationOnly: [ 
		fieldName := ValueHolder new.
		fieldValue := ValueHolder new ].

	"Initialize the Struct with zeros"
	
	aStruct 
		withFieldsDo: [ :fn :fv | aStruct setField: fn to: 0 ]
		separatedBy: [ ].

	"This solution does NOT WORK with STON file without fields (empty STON)"
	[ 
		self
			fscanf: file
			_: self fieldFormat
			_: fieldName
			_: (self addressOf: fieldValue).

		aStruct setField: (self contentsOf: fieldName) to: (self contentsOf: fieldValue).

		self endOfSTON: file
	] whileFalse
]

{ #category : #reading }
ComposedImageReader >> readHeadSTONFrom: file into: aStruct [

	<inline: true>
	<var: #structName declareC: 'char structName[255]'>
	| structName |
	self simulationOnly: [ structName := ValueHolder new ].

	self fscanf: file _: self headFormat _: structName.

	self simulationOnly: [ 
		aStruct withStructNameDo: [ :name | 
			self assert: name = (self contentsOf: structName) ] ]
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
	
	file 
		ifNil: [ 
			self logError: 'Could not open header file: %s' 
				_: buffer.
	
			interpreter ioExitWithErrorCode: 1 ].
	
	
	self readSTONFrom: file into: (self addressOf: header).

	self extractImageVersionFrom: (header imageFormat) into: (self addressOf: header).
	
	self sqImageFileClose: file.

	^ header
]

{ #category : #api }
ComposedImageReader >> readImageNamed: imageName [
	
	<var: #imageName declareC: 'char *imageName'>
	<var: #aHeader type: #'SpurImageHeaderStruct'>
	<api>

	| aHeader |

	aHeader := self readHeaderFromImage: imageName.

	self loadHeaderToMemory: aHeader.
	interpreter allocateMemoryForImage: imageName withHeader: aHeader.
	
	^ 0 "Must return sqInt"
]

{ #category : #reading }
ComposedImageReader >> readMetadataFromFileName: fullFileName [ 

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #metadata type: #ComposedMetadataStruct>
	
	| metadata file |
	
	self simulationOnly: [ metadata := ComposedMetadataStruct new ].

	file := self
		        sqImageFile: fullFileName
		        Open: 'r'.

	self readSTONFrom: file into: (self addressOf: metadata).

	self sqImageFileClose: file.

	^ metadata
]

{ #category : #'perm - space' }
ComposedImageReader >> readPermanentSpaceDataFromImage: imageFileName startingAt: startingAddress bytes: bytesToRead [

	^ self
		  readDataFromFileName: (self permSpaceDataFileInImage: imageFileName)
		  startingAt: startingAddress
		  bytes: bytesToRead
]

{ #category : #'perm - space' }
ComposedImageReader >> readPermanentSpaceFromImageFile: imageFileName header: aHeader [

	<inline: false>
	<var: #imageFile type: #sqImageFile>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	<var: #permSpaceMetadata type: #ComposedMetadataStruct>

	| newBase permSpaceMetadata oldBase dataSize bytesRead |
	
	newBase := objectMemory getMemoryMap permSpaceStart.
	permSpaceMetadata := self readPermanentSpaceMetadataFromImage: imageFileName.
	oldBase := permSpaceMetadata startAddress.
	dataSize := permSpaceMetadata dataSize.

	newBase ~= oldBase ifTrue: [ interpreter unableToReadImageError ].

	(objectMemory getMemoryMap ensureAtLeastPermSpaceOf: dataSize)
		ifFalse: [ interpreter error: 'Could not allocate PermSpace' ].

	bytesRead := self
		             readPermanentSpaceDataFromImage: imageFileName
		             startingAt: (self pointerForOop: newBase)
		             bytes: dataSize.

	"Check bytes read"
	bytesRead ~= dataSize ifTrue: [ interpreter unableToReadImageError ].

	^ bytesRead
]

{ #category : #'perm - space' }
ComposedImageReader >> readPermanentSpaceMetadataFromImage: imageFileName [ 

	^ self readMetadataFromFileName: (self permSpaceMetadataFileNameInImage: imageFileName) 
]

{ #category : #reading }
ComposedImageReader >> readSTONFrom: file into: aStruct [

	<inline: true>
	self readHeadSTONFrom: file into: aStruct.
	self readFieldsSTONFrom: file into: aStruct
]

{ #category : #segments }
ComposedImageReader >> readSegmentData: segmentIndex fromImage: imageFileName startingAt: startingAddress bytes: bytesToRead [ 

	^ self
		  readDataFromFileName: (self segmentDataFile: segmentIndex inImage: imageFileName)
		  startingAt: startingAddress
		  bytes: bytesToRead
]

{ #category : #segments }
ComposedImageReader >> readSegmentMetadata: segmentIndex fromImage: imageFileName [

	^ self readMetadataFromFileName: (self segmentMetadataFile: segmentIndex inImage: imageFileName)
]

{ #category : #segments }
ComposedImageReader >> readSegmentsFromImageFile: imageFileName header: aHeader [

	<inline: false>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	<var: #segmentMetadata type: #ComposedMetadataStruct>
	| bytesRead totalBytesRead segmentSize oldBase newBase segmentIndex segmentMetadata |
	self prepareSegmentsToRead.

	"segment sizes include the two-header-word bridge at the end of each segment."
	segmentIndex := 0.
	totalBytesRead := 0.
	newBase := objectMemory getMemoryMap oldSpaceStart.

	[ 
	
	segmentMetadata := self readSegmentMetadata: segmentIndex fromImage: imageFileName.
	oldBase := segmentMetadata startAddress.
	segmentSize := segmentMetadata dataSize.
	
	segmentManager withNewSegmentDo: [ :segInfo | 
		segInfo
			segStart: oldBase;
			segSize: segmentSize;
			swizzle: newBase - oldBase ].

	bytesRead := self
		             readSegmentData: segmentIndex
		             fromImage: imageFileName
		             startingAt: (self pointerForOop: newBase)
		             bytes: segmentSize.

	bytesRead > 0 ifTrue: [ totalBytesRead := totalBytesRead + bytesRead ].

	"Check segment bytes read"
	bytesRead ~= segmentSize ifTrue: [ 
		interpreter unableToReadImageError ].

	"The next segment will override the bridge of this segment"
	newBase := newBase + segmentSize - objectMemory bridgeSize.

	"Move to (maybe) next segment"
	segmentIndex := segmentIndex + 1.
	self existSegment: segmentIndex inImage: imageFileName.
	] whileTrue.

	self finalizeSegmentsRead: totalBytesRead newBase: newBase.

	^ totalBytesRead
]

{ #category : #testing }
ComposedImageReader >> validateContent: imageFile [

	"Contains header metadata and AT LEAST one segment (data & metadata)"

	<doNotGenerate>
	{ 'header.ston'. 'seg0.ston'. 'seg0.data' } do: [ :fileName | 
		self assert: (imageFile hasChildrenMatching: fileName) ]
]
