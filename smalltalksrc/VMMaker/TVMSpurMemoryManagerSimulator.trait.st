Trait {
	#name : #TVMSpurMemoryManagerSimulator,
	#category : #'VMMaker-SpurMemoryManagerSimulation'
}

{ #category : #initialization }
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

{ #category : #initialization }
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

{ #category : #initialization }
TVMSpurMemoryManagerSimulator >> setUpForUseByFacade: aCurrentImageCoInterpreterFacade [
	"Make sure that eden etc are initialized, so that methods can be printed.
	 This is really to make addressCouldBeObj: et al work."
	<doNotGenerate>
	self edenBytes: 0.
	self setHeapBase: self freeStart
		memoryLimit: self getMemoryMap oldSpaceEnd
		endOfMemory: self getMemoryMap oldSpaceEnd
]
