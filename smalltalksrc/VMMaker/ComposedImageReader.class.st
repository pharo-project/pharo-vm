Class {
	#name : 'ComposedImageReader',
	#superclass : 'AbstractComposedImageAccess',
	#traits : 'TImageReader',
	#classTraits : 'TImageReader classTrait',
	#category : 'VMMaker-ImageFormat',
	#package : 'VMMaker',
	#tag : 'ImageFormat'
}

{ #category : 'translation' }
ComposedImageReader class >> declareCVarsIn: aCCodeGenerator [
	"currently Slang lacks some support for subclasses: prevent <sys/stat.h> to be include a second time during C code generation as the superclass already includes it but declareCVarsIn: is called for each concrete class logging the warning inside addHeaderFile: method"
]

{ #category : 'reading' }
ComposedImageReader >> endOfSTON: file [
	
	"This method consume 2 chars from file and return they are equivalent to '\n}'"
		
	| charLeft charRight |
	charLeft := self fgetc: file.
	charRight := self fgetc: file.

	^ (self isEndOfLine: charLeft) and: [ charRight = $} ]
]

{ #category : 'reading' }
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

{ #category : 'reading' }
ComposedImageReader >> readFieldsSTONFrom: file into: aStruct [

	<inline: true>
	<var: #fieldName declareC: 'char fieldName[255]'>
	<var: #fieldValue type: #'long long'>
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
			_: (self cCoerce: (self addressOf: fieldValue) to: #'sqInt*').

		aStruct setField: (self contentsOf: fieldName) to: (self contentsOf: fieldValue).

		self endOfSTON: file
	] whileFalse
]

{ #category : 'reading' }
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

{ #category : 'api' }
ComposedImageReader >> readHeaderFromImage: imageFileName [

	<inline: true>
	<var: #imageFileName type: 'char *'>
	<var: #file type: #sqImageFile>
	<var: #buffer declareC: 'char buffer[255]'>
	<var: #header type: #SpurImageHeaderStruct>
	<var: #headerPtr type: #'SpurImageHeaderStruct *'>

	| header buffer file headerPtr |
	
	self simulationOnly: [ 
		buffer := nil. 
		header:= SpurImageHeaderStruct new 
	].
	
	file := self sqImageFile: (self headerFileNameinImage: imageFileName into: buffer bufferSize: 255) Open: 'r'.
	
	file 
		ifNil: [ 
			self logError: 'Could not open header file: %s' 
				_: buffer.
	
			coInterpreter ioExitWithErrorCode: 1 ].
	
	headerPtr := self addressOf: header.
	self readSTONFrom: file into: headerPtr.

	self extractImageVersionFrom: (header imageFormat) into: headerPtr.
	
	self sqImageFileClose: file.

	^ header
]

{ #category : 'api' }
ComposedImageReader >> readImageNamed: imageName [
	
	<var: #imageName declareC: 'char *imageName'>
	<var: #aHeader type: #'SpurImageHeaderStruct'>

	| aHeader |

	objectMemory ensureAuxiliarStructures.

	aHeader := self readHeaderFromImage: imageName.

	self loadHeaderToMemory: aHeader.
	coInterpreter allocateMemoryForImage: imageName withHeader: aHeader.
	
	^ 0 "Must return sqInt"
]

{ #category : 'reading' }
ComposedImageReader >> readMetadataFromFileName: fullFileName [ 

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #metadata type: #ComposedMetadataStruct>
	<var: #metadataPointer type: #'ComposedMetadataStruct *'>
	
	| metadata file metadataPointer |
	
	self simulationOnly: [ metadata := ComposedMetadataStruct new ].

	file := self
		        sqImageFile: fullFileName
		        Open: 'r'.

	"Needed because addressOf: miss the parameter type"
	metadataPointer := self addressOf: metadata.
	self readSTONFrom: file into: metadataPointer.

	self sqImageFileClose: file.

	^ metadata
]

{ #category : 'perm - space' }
ComposedImageReader >> readPermanentSpaceDataFromImage: imageFileName startingAt: startingAddress bytes: bytesToRead [

	^ self
		  readDataFromFileName: (self permSpaceDataFileInImage: imageFileName)
		  startingAt: startingAddress
		  bytes: bytesToRead
]

{ #category : 'perm - space' }
ComposedImageReader >> readPermanentSpaceFromImageFile: imageFileName header: aHeader [

	<inline: false>
	<var: #imageFile type: #sqImageFile>
	<var: #aHeader type: #SpurImageHeaderStruct>
	<var: #permSpaceMetadata type: #ComposedMetadataStruct>
	<var: #bytesRead type: #'size_t'>
	<var: #dataSize type: #'size_t'>
	<var: #oldBase type: #'void*'>
	<var: #newBase type: #'void*'>
	<returnTypeC: #size_t>

	| newBase permSpaceMetadata oldBase dataSize bytesRead |

	(self fileExists: (self permSpaceMetadataFileNameInImage: imageFileName))
		ifFalse: [ ^ 0 ]. 
	
	permSpaceMetadata := self readPermanentSpaceMetadataFromImage: imageFileName.
	oldBase := permSpaceMetadata startAddress.
	dataSize := permSpaceMetadata dataSize.

	(objectMemory getMemoryMap ensureAtLeastPermSpaceOf: dataSize)
		ifFalse: [ coInterpreter error: 'Could not allocate PermSpace' ].

	newBase := objectMemory getMemoryMap permSpaceStart.
	newBase ~= oldBase ifTrue: [ 
		self logError: 'Expecting Base %p Got %p' _: oldBase _: newBase.		
		coInterpreter unableToReadImageError ].

	bytesRead := self
		             readPermanentSpaceDataFromImage: imageFileName
		             startingAt: (self pointerForOop: newBase)
		             bytes: dataSize.

	objectMemory setPermSpaceFreeStart: (objectMemory getMemoryMap permSpaceStart + dataSize).

	"Check bytes read"
	bytesRead ~= dataSize ifTrue: [ 
		self logError: 'Expecting %lld Got %lld' _: dataSize _: bytesRead.		
		coInterpreter unableToReadImageError ].

	^ bytesRead
]

{ #category : 'perm - space' }
ComposedImageReader >> readPermanentSpaceMetadataFromImage: imageFileName [ 

	^ self readMetadataFromFileName: (self permSpaceMetadataFileNameInImage: imageFileName) 
]

{ #category : 'reading' }
ComposedImageReader >> readSTONFrom: file into: aStruct [

	<inline: true>
	self readHeadSTONFrom: file into: aStruct.
	self readFieldsSTONFrom: file into: aStruct
]

{ #category : 'segments' }
ComposedImageReader >> readSegmentData: segmentIndex fromImage: imageFileName startingAt: startingAddress bytes: bytesToRead [ 

	^ self
		  readDataFromFileName: (self segmentDataFile: segmentIndex inImage: imageFileName)
		  startingAt: startingAddress
		  bytes: bytesToRead
]

{ #category : 'segments' }
ComposedImageReader >> readSegmentMetadata: segmentIndex fromImage: imageFileName [

	^ self readMetadataFromFileName: (self segmentMetadataFile: segmentIndex inImage: imageFileName)
]

{ #category : 'segments' }
ComposedImageReader >> readSegmentsFromImageFile: imageFileName header: aHeader [

	<inline: false>
	<var: 'segInfo' type: #'SpurSegmentInfo *'>
	<var: 'aHeader' type: #SpurImageHeaderStruct>
	<var: #segmentMetadata type: #ComposedMetadataStruct>
	<var: #bytesRead type: #'size_t'>
	<var: #totalBytesRead type: #'size_t'>
	<var: #segmentSize type: #'size_t'>
		
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
		self logError: 'Expecting %lld Got %lld' _: segmentSize _: bytesRead.
		coInterpreter unableToReadImageError ].

	"The next segment will override the bridge of this segment"
	newBase := newBase + segmentSize - objectMemory bridgeSize.

	"Move to (maybe) next segment"
	segmentIndex := segmentIndex + 1.
	self existSegment: segmentIndex inImage: imageFileName.
	] whileTrue.

	self finalizeSegmentsRead: totalBytesRead newBase: newBase.

	^ totalBytesRead
]

{ #category : 'testing' }
ComposedImageReader >> validateContent: imageFile [

	"Contains header metadata and AT LEAST one segment (data & metadata)"

	<doNotGenerate>
	{ 'header.ston'. 'seg0.ston'. 'seg0.data' } do: [ :fileName | 
		self assert: (imageFile hasChildrenMatching: fileName) ]
]
