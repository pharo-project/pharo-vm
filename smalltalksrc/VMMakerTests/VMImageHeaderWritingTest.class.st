Class {
	#name : #VMImageHeaderWritingTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-ImageFormat'
}

{ #category : #running }
VMImageHeaderWritingTest >> setUp [

	super setUp.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	self saveImage.
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectBaseAddress [

	| header |

	header := self readHeader.

	self assert: header oldBaseAddr equals: memory getMemoryMap oldSpaceStart
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectBytesLeftInOldSpace [

	| header |

	header := self readHeader.

	self assert: header freeOldSpaceInImage equals: memory bytesLeftInOldSpace
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectCodeSize [

	| header |

	header := self readHeader.

	self assert: header hdrCogCodeSize equals: interpreter unknownShortOrCodeSizeInKs
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectDataSize [

	| header |

	header := self readHeader.

	self assert: header dataSize equals: memory imageSizeToWrite
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectDesiredEdenSize [

	| header |

	header := self readHeader.

	self assert: header hdrEdenBytes equals: interpreter getDesiredEdenBytes
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectDesiredNumberStackPages [

	| header |

	header := self readHeader.

	self assert: header hdrNumStackPages equals: interpreter getDesiredNumStackPages
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectExternalSemaphoreTable [

	| header |

	header := self readHeader.

	self assert: header hdrMaxExtSemTabSize equals: (interpreter getMaxExtSemTabSizeSet ifTrue: [interpreter ioGetMaxExtSemTableSize] ifFalse: [0])
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectExtraVMMemory [

	| header |

	header := self readHeader.

	self assert: header extraVMMemory equals: interpreter getExtraVMMemory
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectFirstSegmentSize [

	| header |

	header := self readHeader.

	self assert: header firstSegSize equals: memory firstSegmentBytes
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectHeaderFlags [

	| header |

	header := self readHeader.

	self assert: header headerFlags equals: interpreter getImageHeaderFlags
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectHeaderSize [

	| header expectedHeaderSize |

	expectedHeaderSize := self wordSize = 8 ifTrue: [128] ifFalse: [64].

	header := self readHeader.

	self assert: header imageHeaderSize equals: expectedHeaderSize.
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectImageFormat [

	| header |

	header := self readHeader.

	self assert: header imageFormat equals: interpreter imageFormatVersion
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectNextObjectHash [

	| header |

	header := self readHeader.

	self assert: header hdrLastHash equals: memory lastHash
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingImageWritesCorrectSpecialObjectsArrayOop [

	| header |

	header := self readHeader.

	self assert: header initialSpecialObjectsOop equals: memory specialObjectsOop
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingSTONHeader [

	| header readHeader |

	imageWriterClass ~= ComposedImageWriter ifTrue: [ ^ self skip ].

	header := interpreter newHeader.

	readHeader := (self imageFileName asFileReference  / 'header.ston') contents.

	self assert: readHeader equals: (self stonPretty: header).
]

{ #category : #tests }
VMImageHeaderWritingTest >> testWritingSTONSegment [

	| header writtenHeader segmentMetadata |

	imageWriterClass ~= ComposedImageWriter ifTrue: [ ^ self skip ].

	header := interpreter newHeader.

	writtenHeader := (self imageFileName asFileReference  / 'seg0.ston') contents.
	
	segmentMetadata := ComposedSegmentMetadataStruct new.
	segmentMetadata segStart: header oldBaseAddr.
	segmentMetadata segSize: header dataSize.

	self assert: writtenHeader equals: (self stonPretty: segmentMetadata).
]
