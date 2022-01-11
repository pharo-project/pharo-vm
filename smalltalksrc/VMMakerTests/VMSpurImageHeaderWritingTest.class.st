Class {
	#name : #VMSpurImageHeaderWritingTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #running }
VMSpurImageHeaderWritingTest >> setUp [

	super setUp.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	self saveImage.
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectBaseAddress [

	| header |

	header := self readHeader.

	self assert: header oldBaseAddr equals: memory oldSpaceStart
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectBytesLeftInOldSpace [

	| header |

	header := self readHeader.

	self assert: header freeOldSpaceInImage equals: memory bytesLeftInOldSpace
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectCodeSize [

	| header |

	header := self readHeader.

	self assert: header hdrCogCodeSize equals: interpreter unknownShortOrCodeSizeInKs
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectDataSize [

	| header |

	header := self readHeader.

	self assert: header dataSize equals: memory imageSizeToWrite
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectDesiredEdenSize [

	| header |

	header := self readHeader.

	self assert: header hdrEdenBytes equals: interpreter getDesiredEdenBytes
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectDesiredNumberStackPages [

	| header |

	header := self readHeader.

	self assert: header hdrNumStackPages equals: interpreter getDesiredNumStackPages
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectExternalSemaphoreTable [

	| header |

	header := self readHeader.

	self assert: header hdrMaxExtSemTabSize equals: (interpreter getMaxExtSemTabSizeSet ifTrue: [interpreter ioGetMaxExtSemTableSize] ifFalse: [0])
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectExtraVMMemory [

	| header |

	header := self readHeader.

	self assert: header extraVMMemory equals: interpreter getExtraVMMemory
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectFirstSegmentSize [

	| header |

	header := self readHeader.

	self assert: header firstSegSize equals: memory firstSegmentBytes
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectHeaderFlags [

	| header |

	header := self readHeader.

	self assert: header headerFlags equals: interpreter getImageHeaderFlags
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectHeaderSize [

	| header expectedHeaderSize |

	expectedHeaderSize := self wordSize = 8 ifTrue: [128] ifFalse: [64].

	header := self readHeader.

	self assert: header imageHeaderSize equals: expectedHeaderSize.
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectImageFormat [

	| header |

	header := self readHeader.

	self assert: header imageFormat equals: interpreter imageFormatVersion
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectNextObjectHash [

	| header |

	header := self readHeader.

	self assert: header hdrLastHash equals: memory lastHash
]

{ #category : #tests }
VMSpurImageHeaderWritingTest >> testWritingImageWritesCorrectSpecialObjectsArrayOop [

	| header |

	header := self readHeader.

	self assert: header initialSpecialObjectsOop equals: memory specialObjectsOop
]
