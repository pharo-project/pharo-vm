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
	^ (charLeft = self endOfLine) and: [ charRight = $} ]
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

	"This solution does NOT WORK with STON file without fields (empty STON)"

	[ 
		self
			fscanf: file
			_: fieldFormat
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

	self fscanf: file _: headFormat _: structName.

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
ComposedImageReader >> readSTONFrom: file into: aStruct [

	<inline: true>
	self readHeadSTONFrom: file into: aStruct.
	self readFieldsSTONFrom: file into: aStruct
]

{ #category : #segments }
ComposedImageReader >> readSegmentData: segmentIndex fromImage: imageFileName startingAt: startingAddress bytes: bytesToRead [ 

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #buffer declareC: 'char buffer[255]'>
	| buffer file bytes |
	self simulationOnly: [ buffer := nil ].

	file := self sqImageFile: (self
				         segmentFileName: segmentIndex
				         withExtension: '.data'
				         inImage: imageFileName
				         into: buffer
				         bufferSize: 255)
		        Open: 'rb'.

	bytes := self sq: startingAddress Image: (self sizeof: #char) File: bytesToRead Read: file.

	self sqImageFileClose: file.
	
	^ bytes
]

{ #category : #segments }
ComposedImageReader >> readSegmentMetadata: segmentIndex fromImage: imageFileName [

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #buffer declareC: 'char buffer[255]'>
	<var: #segmentMetadata type: #ComposedSegmentMetadataStruct>
	| segmentMetadata buffer file |
	self simulationOnly: [ 
		buffer := nil.
		segmentMetadata := ComposedSegmentMetadataStruct new ].

	file := self
		        sqImageFile: (self
				         segmentFileName: segmentIndex
				         withExtension: '.ston'
				         inImage: imageFileName
				         into: buffer
				         bufferSize: 255)
		        Open: 'r'.

	self readSTONFrom: file into: (self addressOf: segmentMetadata).

	self sqImageFileClose: file.

	^ segmentMetadata
]

{ #category : #segments }
ComposedImageReader >> readSegmentsFromImageFile: imageFileName header: aHeader [

	<inline: false>
	<var: #imageFile type: #sqImageFile>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	<var: #segmentMetadata type: #ComposedSegmentMetadataStruct>
	| bytesRead totalBytesRead segmentSize oldBase newBase segmentIndex segmentMetadata |
	self prepareSegmentsToRead.

	"segment sizes include the two-header-word bridge at the end of each segment."
	segmentIndex := 0.
	totalBytesRead := 0.
	newBase := objectMemory getMemoryMap oldSpaceStart.

	[ 
	
	segmentMetadata := self readSegmentMetadata: segmentIndex fromImage: imageFileName.
	oldBase := segmentMetadata segStart.
	segmentSize := segmentMetadata segSize.
	
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
