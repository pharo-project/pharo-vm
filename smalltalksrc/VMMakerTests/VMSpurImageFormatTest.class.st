Class {
	#name : #VMSpurImageFormatTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #running }
VMSpurImageFormatTest >> setUp [

	super setUp.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	interpreter extraVMMemory: 0.

	interpreter imageName: self imageFileName.
	interpreter preemptionYields: false.
	interpreter setImageHeaderFlagsFrom: 0.
	
	interpreter writeImageFileIO.
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectBaseAddress [

	| header |

	header := self readHeader.

	self assert: header oldBaseAddr equals: memory baseAddressOfImage
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectBytesLeftInOldSpace [

	| header |

	header := self readHeader.

	self assert: header freeOldSpaceInImage equals: memory bytesLeftInOldSpace
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectCodeSize [

	| header |

	header := self readHeader.

	self assert: header hdrCogCodeSize equals: interpreter unknownShortOrCodeSizeInKs
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectDataSize [

	| header |

	header := self readHeader.

	self assert: header dataSize equals: memory imageSizeToWrite
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectDesiredEdenSize [

	| header |

	header := self readHeader.

	self assert: header hdrEdenBytes equals: interpreter desiredEdenBytes
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectDesiredNumberStackPages [

	| header |

	header := self readHeader.

	self assert: header hdrNumStackPages equals: interpreter desiredNumStackPages
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectExternalSemaphoreTable [

	| header |

	header := self readHeader.

	self assert: header hdrMaxExtSemTabSize equals: (interpreter maxExtSemTabSizeSet ifTrue: [interpreter ioGetMaxExtSemTableSize] ifFalse: [0])
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectExtraVMMemory [

	| header |

	header := self readHeader.

	self assert: header extraVMMemory equals: interpreter extraVMMemory
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectFirstSegmentSize [

	| header |

	header := self readHeader.

	self assert: header firstSegSize equals: memory firstSegmentBytes
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectHeaderFlags [

	| header |

	header := self readHeader.

	self assert: header headerFlags equals: interpreter getImageHeaderFlags
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectHeaderSize [

	| header expectedHeaderSize |

	expectedHeaderSize := self wordSize = 8 ifTrue: [128] ifFalse: [64].

	header := self readHeader.

	self assert: header headerSize equals: expectedHeaderSize.
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectImageFormat [

	| header |

	header := self readHeader.

	self assert: header imageFormat equals: interpreter imageFormatVersion
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectNextObjectHash [

	| header |

	header := self readHeader.

	self assert: header hdrLastHash equals: memory lastHash
]

{ #category : #tests }
VMSpurImageFormatTest >> testWritingImageWritesCorrectSpecialObjectsArrayOop [

	| header |

	header := self readHeader.

	self assert: header initialSpecialObjectsOop equals: memory specialObjectsOop
]
