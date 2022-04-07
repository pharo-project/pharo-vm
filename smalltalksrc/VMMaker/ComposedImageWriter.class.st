Class {
	#name : #ComposedImageWriter,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #writing }
ComposedImageWriter >> writeDataStatingAt: start withSize: size inFileName: fullFileName [

	<var: #dataFile type: #sqImageFile>
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

{ #category : #writing }
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

{ #category : #writing }
ComposedImageWriter >> writeHeaderSTON: header toFile: f [ 

	self writeSTON: header toFile: f
]

{ #category : #api }
ComposedImageWriter >> writeImageFile: imageFileName fromHeader: header [

	"Write one image header file + many segments files (metadata & data per segment)"

	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #header type: #SpurImageHeaderStruct> "TODO: Rename this class"
	| oldSpaceBytesWritten permanentSpaceBytesWritten bytesWritten |

	self logDebug: 'Writing snapshot %s' _: imageFileName.

	self createImageDirectory: imageFileName.

	self writeHeaderFile: imageFileName fromHeader: header.

	self flag: #TODO. "success: header imageHeaderSize?"

	oldSpaceBytesWritten := self writeImageSegments: imageFileName.
	
	permanentSpaceBytesWritten := self writeImagePermanentSpace: imageFileName.

	bytesWritten := oldSpaceBytesWritten + permanentSpaceBytesWritten.

	interpreter success: bytesWritten = header dataSize 
]

{ #category : #'perm - space' }
ComposedImageWriter >> writeImagePermanentSpace: imageFileName [

	objectMemory isPermSpaceDirty ifFalse: [ ^ objectMemory totalBytesInPermanentSpace ].

	objectMemory setPermSpaceDirty: false.

	self writePermanentSpaceMetadata: imageFileName.

	^ self writePermanentSpaceData: imageFileName
]

{ #category : #segments }
ComposedImageWriter >> writeImageSegments: imageFileName [

	<var: 'aSegment' type:#'SpurSegmentInfo *'>

	self beginWriteImageSegments.

	^ segmentManager withNonEmptySegmentsDo: [ :aSegment :segmentIndex | 
		self
          writeSegment: aSegment
          nextIndex: segmentIndex
			 inImage: imageFileName ].


]

{ #category : #writing }
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

{ #category : #'perm - space' }
ComposedImageWriter >> writePermanentSpaceData: imageFileName [

	^ self
		  writeDataStatingAt: objectMemory getMemoryMap permSpaceStart asVoidPointer
		  withSize: objectMemory totalBytesInPermanentSpace
		  inFileName: (self permSpaceDataFileInImage: imageFileName)
]

{ #category : #'perm - space' }
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

{ #category : #writing }
ComposedImageWriter >> writeSTON: struct toFile: f [

	<inline: true>
	| fieldHasNilValue |

	struct withStructNameDo: [ :name | self fprintf: f _: self headFormat _: name ].
	struct withFieldsDo: [ :fieldName :fieldValue |
		fieldValue 
			ifNil: [ 	fieldHasNilValue := true ]
			ifNotNil: [  
				fieldHasNilValue := false.
				self fprintf: f _: self fieldFormat _: fieldName _: fieldValue ]]
		separatedBy: [ fieldHasNilValue ifFalse: [self fprintf: f _: ',\n'] ].
		
	self fprintf: f _: '\n}'. 
]

{ #category : #segments }
ComposedImageWriter >> writeSegment: segment nextIndex: segmentIndex inImage: imageFileName [

	<inline: false>
	<var: 'segment' type: #'SpurSegmentInfo *'>
	<var: #imageFileName declareC: 'char *imageFileName'>

	self writeSegmentMetadata: segment nextIndex: segmentIndex inImage: imageFileName.

	^ self writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName.
]

{ #category : #segments }
ComposedImageWriter >> writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName [

	^ self
		  writeDataStatingAt: segment segStart asVoidPointer
		  withSize: segment segSize
		  inFileName: (self segmentDataFile: segmentIndex inImage: imageFileName)
]

{ #category : #segments }
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

{ #category : #writing }
ComposedImageWriter >> writeSegmentSTON: segmentMetadata toFile: f [ 

	<var: #f type: #sqImageFile>
	<var: #segmentMetadata type: #ComposedMetadataStruct>

	self writeSTON: segmentMetadata toFile: f
]
