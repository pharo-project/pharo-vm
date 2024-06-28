Class {
	#name : 'ComposedImageWriter',
	#superclass : 'AbstractComposedImageAccess',
	#traits : 'TImageWriter',
	#classTraits : 'TImageWriter classTrait',
	#category : 'VMMaker-ImageFormat',
	#package : 'VMMaker',
	#tag : 'ImageFormat'
}

{ #category : 'writing' }
ComposedImageWriter >> ensureDeleteSegments: imageFileName [ 
	
	| segmentIndex r |
	segmentIndex := 0.
	
	[ self existSegment: segmentIndex inImage: imageFileName ] 
		whileTrue: [ 
			r := self unlink: (self segmentMetadataFile: segmentIndex inImage: imageFileName). 
			r ~= 0 ifTrue: [ 
					self logError: 'Error deleting %s' _: (self segmentMetadataFile: segmentIndex inImage: imageFileName).
					^ coInterpreter primitiveFail. ].
			
			r := self unlink: (self segmentDataFile: segmentIndex inImage: imageFileName). 
			r ~= 0 ifTrue: [ 
					self logError: 'Error deleting %s' _: (self segmentDataFile: segmentIndex inImage: imageFileName).
					^ coInterpreter primitiveFail. ].
			segmentIndex := segmentIndex + 1 ]
]

{ #category : 'writing' }
ComposedImageWriter >> unlink: aFileName [

	<doNotGenerate>
	| fileReference |
	
	fileReference := aFileName asFileReference.
	fileReference exists ifFalse: [ ^ -1 ].
	fileReference delete.
	
	^ 0
]

{ #category : 'writing' }
ComposedImageWriter >> writeDataStatingAt: start withSize: size inFileName: fullFileName [

	<var: #dataFile type: #sqImageFile>
	<var: #nWritten type: #'size_t'>
	<returnTypeC: #'size_t'>
	
	| dataFile nWritten |
	dataFile := self sqImageFile: fullFileName Open: 'wb'.
	dataFile ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	nWritten := 0.

	size > 0 ifTrue:[	
			nWritten := self
		            sq: start
		            Image: 1
		            File: size
		            Write: dataFile].

	self sqImageFileClose: dataFile.

	^ nWritten
]

{ #category : 'writing' }
ComposedImageWriter >> writeHeaderFile: imageFileName fromHeader: header [

	<inline: true>
	<var: #file type: #sqImageFile>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer file |
		
	self simulationOnly: [ buffer := nil ].
	
	file := self sqImageFile: (self headerFileNameinImage: imageFileName into: buffer bufferSize: 255) Open: 'w'.
	file ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	self writeHeaderSTON: header toFile: file.

	self sqImageFileClose: file.

]

{ #category : 'writing' }
ComposedImageWriter >> writeHeaderSTON: header toFile: f [ 

	self writeSTON: header toFile: f
]

{ #category : 'api' }
ComposedImageWriter >> writeImageFile: imageFileName fromHeader: header [

	"Write one image header file + many segments files (metadata & data per segment)"

	<inline: false>

	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #oldSpaceBytesWritten type:#'size_t'>
	<var: #permanentSpaceBytesWritten type:#'size_t'>
	<var: #bytesWritten type:#'size_t'>
	<var: #header type: #SpurImageHeaderStruct> "TODO: Rename this class"

	| oldSpaceBytesWritten permanentSpaceBytesWritten bytesWritten |

	self logDebug: 'Writing snapshot %s' _: imageFileName.

	self createImageDirectory: imageFileName.

	self writeHeaderFile: imageFileName fromHeader: header.

	self flag: #TODO. "success: header imageHeaderSize?"

	oldSpaceBytesWritten := self writeImageSegments: imageFileName.
	
	permanentSpaceBytesWritten := self writeImagePermanentSpace: imageFileName.

	bytesWritten := oldSpaceBytesWritten + permanentSpaceBytesWritten.

	coInterpreter success: bytesWritten = header dataSize 
]

{ #category : 'perm - space' }
ComposedImageWriter >> writeImagePermanentSpace: imageFileName [

	<returnTypeC: #'size_t'>
	
	self writePermanentSpaceMetadata: imageFileName.

	^ self writePermanentSpaceData: imageFileName
]

{ #category : 'segments' }
ComposedImageWriter >> writeImageSegments: imageFileName [

	<var: 'aSegment' type:#'SpurSegmentInfo *'>
	<returnTypeC: #'size_t'>

	self beginWriteImageSegments.
	self ensureDeleteSegments: imageFileName.
	
	coInterpreter failed ifTrue: [ ^ 0 ].

	^ segmentManager withNonEmptySegmentsDo: [ :aSegment :segmentIndex | 
		self
          writeSegment: aSegment
          nextIndex: segmentIndex
			 inImage: imageFileName ].


]

{ #category : 'writing' }
ComposedImageWriter >> writeMetadata: metadata inFileName: fullFileName [

	<var: #metadataFile type: #sqImageFile>
	<var: #metadata type: #ComposedMetadataStruct>

	| metadataFile |

	metadataFile := self sqImageFile: fullFileName Open: 'w'.
	metadataFile ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	self writeSTON: metadata toFile: metadataFile.

	self sqImageFileClose: metadataFile.


]

{ #category : 'perm - space' }
ComposedImageWriter >> writePermanentSpaceData: imageFileName [

	<returnTypeC: #'size_t'>

	^ self
		  writeDataStatingAt: objectMemory getMemoryMap permSpaceStart asVoidPointer
		  withSize: objectMemory totalBytesInPermanentSpace
		  inFileName: (self permSpaceDataFileInImage: imageFileName)
]

{ #category : 'perm - space' }
ComposedImageWriter >> writePermanentSpaceMetadata: imageFileName [

	<var: #metadata type: #ComposedMetadataStruct>
	| metadata |
	self simulationOnly: [ metadata := ComposedMetadataStruct new ].
	metadata startAddress: objectMemory getMemoryMap permSpaceStart.
	metadata dataSize: objectMemory totalBytesInPermanentSpace.

	self
		writeMetadata: metadata
		inFileName: (self permSpaceMetadataFileNameInImage: imageFileName)
]

{ #category : 'writing' }
ComposedImageWriter >> writeSTON: struct toFile: f [

	<inline: true>
	struct withStructNameDo: [ :name | self fprintf: f _: self headFormat _: name ].
	struct withFieldsDo: [ :fieldName :fieldValue |
			self fprintf: f _: self fieldFormat _: fieldName _: (self cCoerce: fieldValue to: #sqInt)]
		separatedBy: [ self fprintf: f _: ',\n'].
		
	self fprintf: f _: '\n}'. 
]

{ #category : 'segments' }
ComposedImageWriter >> writeSegment: segment nextIndex: segmentIndex inImage: imageFileName [

	<inline: false>
	<var: 'segment' type: #'SpurSegmentInfo *'>
	<var: #imageFileName declareC: 'char *imageFileName'>
	<returnTypeC: #'size_t'>

	self logDebug: (self msgFormat: 'Segment Start: ') _: segment segStart.
	self logDebug: (self msgFormat: 'Segment Size: ') _: segment segSize.

	self writeSegmentMetadata: segment nextIndex: segmentIndex inImage: imageFileName.

	^ self writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName.
]

{ #category : 'segments' }
ComposedImageWriter >> writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName [

	<returnTypeC: #'size_t'>

	^ self
		  writeDataStatingAt: segment segStart asVoidPointer
		  withSize: segment segSize
		  inFileName: (self segmentDataFile: segmentIndex inImage: imageFileName)
]

{ #category : 'segments' }
ComposedImageWriter >> writeSegmentMetadata: segment nextIndex: segmentIndex inImage: imageFileName [

	<var: #metadata type: #ComposedMetadataStruct>
	| metadata |

	self simulationOnly: [ metadata := ComposedMetadataStruct new. ].
	metadata startAddress: segment segStart.
	metadata dataSize: segment segSize.

	self
		writeMetadata: metadata
		inFileName: (self segmentMetadataFile: segmentIndex inImage: imageFileName)
]

{ #category : 'writing' }
ComposedImageWriter >> writeSegmentSTON: segmentMetadata toFile: f [ 

	<var: #f type: #sqImageFile>
	<var: #segmentMetadata type: #ComposedMetadataStruct>

	self writeSTON: segmentMetadata toFile: f
]
