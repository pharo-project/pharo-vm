Class {
	#name : #SpurImageHeaderStruct,
	#superclass : #VMStructType,
	#instVars : [
		'headerSize',
		'dataSize',
		'oldBaseAddr',
		'initialSpecialObjectsOop',
		'headerFlags',
		'extraVMMemory',
		'hdrNumStackPages',
		'hdrCogCodeSize',
		'hdrEdenBytes',
		'hdrMaxExtSemTabSize',
		'firstSegSize',
		'freeOldSpaceInImage',
		'swapBytes',
		'hdrLastHash',
		'imageFormat',
		'screenSize'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #'simulation only' }
SpurImageHeaderStruct class >> byteSizeForSimulator: aCogit [

	"Answer an approximation of the byte size of an AbstractInstruction struct.
	 This is for estimating the alloca in allocateOpcodes:bytecodes:ifFail:"
	^self instSize * (aCogit sizeof: #'void *')
]

{ #category : #translation }
SpurImageHeaderStruct class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a struct of this type."

	<var: #dataSize type: #size_t>
	<var: #desiredHeapSize type: #usqInt>
	<var: #headerStart type: #squeakFileOffsetType>

	self filteredInstVarNames do:
		[:ivn|
		aBinaryBlock
			value: ivn
			value: (ivn caseOf: {
						['dataSize']				-> [#'size_t'].
						['desiredHeapSize']	-> [#'usqInt'].
						['headerStart']			-> [#'squeakFileOffsetType'].
				} otherwise: [ #'sqInt' ])]
]

{ #category : #accessing }
SpurImageHeaderStruct >> dataSize [

	^ dataSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> dataSize: anObject [

	dataSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> extraVMMemory [

	^ extraVMMemory
]

{ #category : #accessing }
SpurImageHeaderStruct >> extraVMMemory: anObject [

	extraVMMemory := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> firstSegSize [

	^ firstSegSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> firstSegSize: anObject [

	firstSegSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> freeOldSpaceInImage [

	^ freeOldSpaceInImage
]

{ #category : #accessing }
SpurImageHeaderStruct >> freeOldSpaceInImage: anObject [

	freeOldSpaceInImage := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrCogCodeSize [

	^ hdrCogCodeSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrCogCodeSize: anObject [

	hdrCogCodeSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrEdenBytes [

	^ hdrEdenBytes
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrEdenBytes: anObject [

	hdrEdenBytes := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrLastHash [

	^ hdrLastHash
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrLastHash: anObject [

	hdrLastHash := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrMaxExtSemTabSize [

	^ hdrMaxExtSemTabSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrMaxExtSemTabSize: anObject [

	hdrMaxExtSemTabSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrNumStackPages [

	^ hdrNumStackPages
]

{ #category : #accessing }
SpurImageHeaderStruct >> hdrNumStackPages: anObject [

	hdrNumStackPages := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> headerFlags [

	^ headerFlags
]

{ #category : #accessing }
SpurImageHeaderStruct >> headerFlags: anObject [

	headerFlags := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> headerSize [

	^ headerSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> headerSize: anObject [

	headerSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> imageFormat [

	^ imageFormat
]

{ #category : #accessing }
SpurImageHeaderStruct >> imageFormat: anObject [

	imageFormat := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> initialSpecialObjectsOop [

	^ initialSpecialObjectsOop
]

{ #category : #accessing }
SpurImageHeaderStruct >> initialSpecialObjectsOop: anObject [

	initialSpecialObjectsOop := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> oldBaseAddr [

	^ oldBaseAddr
]

{ #category : #accessing }
SpurImageHeaderStruct >> oldBaseAddr: anObject [

	oldBaseAddr := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> screenSize [

	^ screenSize
]

{ #category : #accessing }
SpurImageHeaderStruct >> screenSize: anObject [

	screenSize := anObject
]

{ #category : #accessing }
SpurImageHeaderStruct >> swapBytes [

	^ swapBytes
]

{ #category : #accessing }
SpurImageHeaderStruct >> swapBytes: anObject [

	swapBytes := anObject
]
