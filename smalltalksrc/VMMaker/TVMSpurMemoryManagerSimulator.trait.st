Trait {
	#name : 'TVMSpurMemoryManagerSimulator',
	#category : 'VMMaker-SpurMemoryManagerSimulation',
	#package : 'VMMaker',
	#tag : 'SpurMemoryManagerSimulation'
}

{ #category : 'object format' }
TVMSpurMemoryManagerSimulator >> firstIndexableField: objOop [
	"NOTE: overridden from SpurMemoryManager to add coercion to CArray, so please duplicate any changes.
	 There are only two important cases, both for objects with named inst vars, i.e. formats 2,3 & 5.
	 The first indexable field for formats 2 & 5 is the slot count (by convention, even though that's off the end
	 of the object).  For 3 we must go to the class."
	| fmt classFormat |
	<returnTypeC: #'void *'>
	fmt := self formatOf: objOop.
	fmt <= self lastPointerFormat ifTrue: "pointer; may need to delve into the class format word"
		[(fmt between: self indexablePointersFormat and: self weakArrayFormat) ifTrue:
			[classFormat := self formatOfClass: (self fetchClassOfNonImm: objOop).
			 ^self cCoerce: (self pointerForOop: objOop
												+ self baseHeaderSize
												+ ((self fixedFieldsOfClassFormat: classFormat) << self shiftForWord))
					to: #'oop *'].
		^self cCoerce: (self pointerForOop: objOop + self baseHeaderSize)
				to: #'oop *'].
	"All bit objects, and indeed CompiledMethod, though this is a no-no, start at 0"
	self assert: (fmt >= self sixtyFourBitIndexableFormat and: [fmt < self firstCompiledMethodFormat]).
	^self
		cCoerce: (self pointerForOop: objOop + self baseHeaderSize)
		to: (fmt < self firstByteFormat
				ifTrue:
					[fmt = self sixtyFourBitIndexableFormat
						ifTrue: ["64 bit field objects" #'long long *']
						ifFalse:
							[fmt < self firstShortFormat
								ifTrue: ["32 bit field objects" #'int *']
								ifFalse: ["16-bit field objects" #'short *']]]
				ifFalse: ["byte objects (including CompiledMethod" #'char *'])
]

{ #category : 'initialization' }
TVMSpurMemoryManagerSimulator >> initializeFreeSpaceForFacadeFrom: base to: limit [
	"c.f. initializeFreeSpacePostLoad: freeListObj."
	| freeListObj freeBytes |

	self getMemoryMap newSpaceEnd: (self freeStart: base).
	self getMemoryMap oldSpaceStart: self getMemoryMap newSpaceEnd.
	self getMemoryMap setOldSpaceEnd: limit.
	
	self scavengeThreshold: limit * 3 // 4.
	self segmentManager initSegmentForInImageCompilationFrom: base to: limit.
	freeListObj := self allocateSlots: self numFreeLists
						format: self wordIndexableFormat
						classIndex: self wordSizeClassIndexPun.
	self freeLists: self firstIndexableField: freeListObj.
	self freeListsMask: 0.
	
	0 to: self numFreeLists - 1 do:
		[:i|
		(self freeLists at: i) ~= 0 ifTrue:
			[self freeListsMask: self freeListsMask bitOr: (1 << i).
			 self freeLists at: i put: (self segmentManager swizzleObj: (self freeLists at: i))]].
	freeBytes := self segmentManager lastSegment segLimit - self bridgeSize - self freeStart.
	self freeLists at: 0 put: (self initFreeChunkWithBytes: freeBytes at: self freeStart).
	self totalFreeOldSpace: freeBytes
]

{ #category : 'initialization' }
TVMSpurMemoryManagerSimulator >> setHeapBase: baseOfHeap memoryLimit: memLimit endOfMemory: memEnd [
	"Set the dimensions of the heap, answering the start of oldSpace. edenBytes holds the desired ``size of eden''
	 which is actually the total size of new space minus the reserve.  edenBytes is then divided up between eden
	 and the two survivor spaces, where each survivor space is a scavengerDenominator (one seventh) of the total."
	"Transcript
		cr; nextPutAll: 'heapBase: '; print: baseOfHeap; nextPut: $/; nextPutAll: baseOfHeap hex;
		nextPutAll: ' memLimit '; print: memLimit; nextPut: $/; nextPutAll: memLimit hex;
		nextPutAll: ' memEnd '; print: memEnd; nextPut: $/; nextPutAll: memEnd hex; cr; flush."
	"This is more than a little counter-intuitive.  Eden must include interpreterAllocationReserveBytes."
	<inline: #never>
	| reserve |
	reserve := self coInterpreter interpreterAllocationReserveBytes.
	self getMemoryMap newSpaceStart: baseOfHeap.
	self getMemoryMap newSpaceEnd: baseOfHeap + self edenBytes + reserve.
	
	self scavenger newSpaceStart: self getMemoryMap newSpaceStart
				newSpaceBytes: self getMemoryMap newSpaceEnd - self getMemoryMap newSpaceStart
				survivorBytes: self getMemoryMap newSpaceEnd - self getMemoryMap newSpaceStart - reserve // self scavengerDenominator.

	self freeStart: self scavenger eden start.
	self pastSpaceStart: self scavenger pastSpace start.

	self getMemoryMap oldSpaceStart: self getMemoryMap newSpaceEnd.
	self freeOldSpaceStart: memEnd.
	self getMemoryMap setOldSpaceEnd: memLimit.

	^baseOfHeap
]

{ #category : 'initialization' }
TVMSpurMemoryManagerSimulator >> setUpForUseByFacade: aCurrentImageCoInterpreterFacade [
	"Make sure that eden etc are initialized, so that methods can be printed.
	 This is really to make addressCouldBeObj: et al work."
	<doNotGenerate>
	self edenBytes: 0.
	self setHeapBase: self freeStart
		memoryLimit: self getMemoryMap oldSpaceEnd
		endOfMemory: self getMemoryMap oldSpaceEnd
]
