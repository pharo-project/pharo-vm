Class {
	#name : #ComposedImageWriter,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

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
	| bytesWritten |

	self logDebug: 'Writing snapshot %s' _: imageFileName.

	self createImageDirectory: imageFileName.

	self writeHeaderFile: imageFileName fromHeader: header.

	self flag: #TODO. "success: header imageHeaderSize?"

	bytesWritten := self writeImageSegments: imageFileName.

	interpreter success: bytesWritten = header dataSize 
]

{ #category : #writing }
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
ComposedImageWriter >> writeSTON: struct toFile: f [

	<inline: true>
	| fieldHasNilValue |

	struct withStructNameDo: [ :name | self fprintf: f _: '%s {\n' _: name ].
	struct withFieldsDo: [ :fieldName :fieldValue |
		fieldValue 
			ifNil: [ 	fieldHasNilValue := true ]
			ifNotNil: [  
				fieldHasNilValue := false.			
				self fprintf: f _: '\t#%s : %ld' _: fieldName _: fieldValue ]]
		separatedBy: [ fieldHasNilValue ifFalse: [self fprintf: f _: ',\n'] ].
		
	self fprintf: f _: '\n}'. 
]

{ #category : #writing }
ComposedImageWriter >> writeSegment: segment nextIndex: segmentIndex inImage: imageFileName [

	<inline: false>
	<var: 'segment' type: #'SpurSegmentInfo *'>
	<var: #imageFileName declareC: 'char *imageFileName'>

	self writeSegmentMetadata: segment nextIndex: segmentIndex inImage: imageFileName.

	^ self writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName.
]

{ #category : #writing }
ComposedImageWriter >> writeSegmentData: segment nextIndex: segmentIndex inImage: imageFileName [

	<var: #dataFile type: #sqImageFile>
	| dataFile nWritten |

	dataFile := self sqImageFile: (self segmentDataFile: segmentIndex inImage: imageFileName) Open: 'wb'.
	dataFile ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	nWritten := self
						sq: segment segStart asVoidPointer
						Image: 1
						File: segment segSize
						Write: dataFile.

	self sqImageFileClose: dataFile.


	^ nWritten
]

{ #category : #writing }
ComposedImageWriter >> writeSegmentMetadata: segment nextIndex: segmentIndex inImage: imageFileName [

	<var: #metadataFile type: #sqImageFile>
	| metadataFile |

	metadataFile := self sqImageFile: (self segmentMetadataFile: segmentIndex inImage: imageFileName) Open: 'w'.
	metadataFile ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	self writeSegmentMetadata: segment toFile: metadataFile.

	self sqImageFileClose: metadataFile.


]

{ #category : #writing }
ComposedImageWriter >> writeSegmentMetadata: segment toFile: file [

	<var: #metadata type: #ComposedSegmentMetadataStruct>
	| metadata |

	self simulationOnly: [ metadata := ComposedSegmentMetadataStruct new. ].
	metadata segStart: segment segStart.
	metadata segSize: segment segSize.

	self writeSegmentSTON: metadata toFile: file 	


]

{ #category : #writing }
ComposedImageWriter >> writeSegmentSTON: segmentMetadata toFile: f [ 

	<var: #f type: #sqImageFile>
	<var: #segmentMetadata type: #ComposedSegmentMetadataStruct>

	self writeSTON: segmentMetadata toFile: f
]
