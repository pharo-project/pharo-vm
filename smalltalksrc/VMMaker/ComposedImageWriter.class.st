Class {
	#name : #ComposedImageWriter,
	#superclass : #AbstractComposedImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #api }
ComposedImageWriter >> writeImageFile: imageFileName fromHeader: header [

	| bytesWritten |

	(self headerFile: imageFileName) writeStreamDo: [ :file | 
		self writeSTON: header toFile: file ].

	bytesWritten := self writeImageSegments: imageFileName.

	interpreter success: bytesWritten = header dataSize "Is it neccessary?"

]

{ #category : #writing }
ComposedImageWriter >> writeImageSegments: imageFileName [

	"Almost duplicated from SpurImageWriter >> writeImageSegmentsToFile:"

	| total |
	self assert:
		(objectMemory endOfMemory = segmentManager lastSegment segLimit 
		or: [ objectMemory endOfMemory + objectMemory bridgeSize = segmentManager lastSegment segLimit ]).

	self assert: segmentManager firstSegmentBytes > 0.

	total := 0.

	segmentManager withNonEmptySegmentsDo: [ :aSegment :segmentIndex | 
		total := total + (self
			          writeSegment: aSegment
			          nextIndex: segmentIndex
						 inImage: imageFileName)].

	^ total
]

{ #category : #writing }
ComposedImageWriter >> writeSTON: ston toFile: f [

	STON writer
		on: f;
		nextPut: ston
]

{ #category : #writing }
ComposedImageWriter >> writeSegment: segment nextIndex: segmentIndex inImage: imageFileName [

	| metadata |

	metadata := ComposedSegmentMetadataStruct new.
	metadata segStart: segment segStart.
	metadata segSize: segment segSize.

	self 	cCode: [ "TODO" ] 
			inSmalltalk: [ 
				(self segmentMetadataFile: segmentIndex inImage: imageFileName) writeStreamDo: [ :file |
					self writeSTON: metadata toFile: file 
				]	
			].


	self 	cCode: [ "TODO" ] 
			inSmalltalk: [ 
				| region |
				region := objectMemory memoryManager regionForAddress: segment segStart.

				(self segmentDataFile: segmentIndex inImage: imageFileName) binaryWriteStreamDo: [ :file |
					file
						next: segment segSize
						putAll: region memory
						startingAt: segment segStart - region start + 1
				]
					
			].

	^ segment segSize
]
