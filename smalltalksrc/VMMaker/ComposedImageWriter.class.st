Class {
	#name : #ComposedImageWriter,
	#superclass : #AbstractComposedImageAccess,
	#instVars : [
		'stonWriter'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #writing }
ComposedImageWriter >> initialize [ 

	super initialize .
	stonWriter := STON writer.
]

{ #category : #writing }
ComposedImageWriter >> writeHeaderFile: imageFileName fromHeader: header [

	<var: #file type: #sqImageFile> "ImageFile ?"
	| file |

	file := self vmImageSTONFile: (self headerFile: imageFileName) Open: 'wb'.
	file ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	self writeHeaderSTON: header toFile: file.

	self sqImageFileClose: file.

]

{ #category : #api }
ComposedImageWriter >> writeImageFile: imageFileName fromHeader: header [

	"Write one image header file + many segments files (metadata & data per segment)"

	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #header type: #SpurImageHeaderStruct> "TODO: Rename this class"
	| bytesWritten |

	self logDebug: 'Writing snapshot %s' _: imageFileName.

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

	stonWriter
		on: f;
		nextPut: struct
]

{ #category : #writing }
ComposedImageWriter >> writeSegment: segment nextIndex: segmentIndex inImage: imageFileName [

	| metadataFile dataFile nWritten |

	metadataFile := self vmImageSTONFile: (self segmentMetadataFile: segmentIndex inImage: imageFileName) Open: 'wb'.
	metadataFile ifNil: [ "could not open the file for writing" 
		^ self primitiveFail ].

	self writeSegmentMetadata: segment toFile: metadataFile.

	self sqImageFileClose: metadataFile.


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
ComposedImageWriter >> writeSegmentMetadata: segment toFile: file [

	<var: #metadata type: #ComposedSegmentMetadataStruct>
	| metadata |

	self simulationOnly: [ metadata := ComposedSegmentMetadataStruct new. ].
	metadata segStart: segment segStart.
	metadata segSize: segment segSize.

	self writeSTON: metadata toFile: file 	


]
