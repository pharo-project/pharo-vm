Class {
	#name : #VMMemoryMap,
	#superclass : #VMStructType,
	#instVars : [
		'memoryManager',
		'oldSpaceStart',
		'oldSpaceEnd',
		'newSpaceStart',
		'newSpaceEnd',
		'allocationReserve',
		'initialOldSpaceSize',
		'initialNewSpaceSize',
		'initialHeadroom',
		'memoryMapConfiguration',
		'permSpaceStart',
		'permSpaceEnd',
		'oldSpaceMask',
		'initialCodeZoneSize',
		'codeZoneStart',
		'codeZoneEnd',
		'stackPagesStart',
		'stackPagesEnd',
		'initialPermSpaceSize',
		'minPermSpaceSize',
		'objectMemory',
		'spaceMaskToUse'
	],
	#pools : [
		'VMBasicConstants'
	],
	#category : #'VMMaker-Memory'
}

{ #category : #translation }
VMMemoryMap class >> filteredInstVarNames [

	^ super filteredInstVarNames copyWithoutAll: #(memoryManager memoryMapConfiguration objectMemory)
]

{ #category : #translation }
VMMemoryMap class >> generateHeader: aBinaryBlock [

	aBinaryBlock
		value: 'vmMemoryMap.h'
		value: (String streamContents: [ :s | 
				 self printTypedefOn: s.
				 s cr ])
]

{ #category : #translation }
VMMemoryMap class >> implicitVariables [

	^ #(memoryMapConfiguration)
]

{ #category : #translation }
VMMemoryMap class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :aName |
		aBinaryBlock value: aName value: #'usqInt'  ].

]

{ #category : #translation }
VMMemoryMap class >> needsTypeTag [

	^true
]

{ #category : #translation }
VMMemoryMap class >> shouldBeGenerated [

	^ false
]

{ #category : #private }
VMMemoryMap >> allocateCodeZone [
	
	initialCodeZoneSize = 0 ifTrue: [ ^ self ].
	self codeZoneStart: (self allocateJITMemory: initialCodeZoneSize _: memoryMapConfiguration codeZoneInitialAddress).
	self codeZoneStart ifNil: [ self insufficientMemoryAvailableError ].

	self codeZoneStart = memoryMapConfiguration codeZoneInitialAddress 
		ifFalse: [ 
			self logError: 'Could not allocate codeZone in the expected place (%p), got %p' _: self codeZoneStart _: memoryMapConfiguration codeZoneInitialAddress.
			self error: 'Error allocating' ].
	
	self codeZoneEnd: codeZoneStart + initialCodeZoneSize.
]

{ #category : #allocating }
VMMemoryMap >> allocateHeap [
	<inline: false>
	
	self allocateCodeZone.
	self allocateNewObjectsSpace.
	self allocateOldObjectsSpace.
	self allocatePermObjectsSpace.
]

{ #category : #private }
VMMemoryMap >> allocateJITMemory: desiredSize _: desiredPosition [ 

	<doNotGenerate>
	^ memoryManager allocate: desiredSize desiredPosition: desiredPosition
]

{ #category : #private }
VMMemoryMap >> allocateMemory: desiredSize BaseAddress: baseAddress [

	<doNotGenerate>
	^ memoryManager allocate: desiredSize desiredPosition: baseAddress
]

{ #category : #private }
VMMemoryMap >> allocateNewObjectsSpace [
	
	| newSpaceSizeToAllocate |
	
	newSpaceSizeToAllocate := self roundToAllocationSize: self initialNewSpaceSize + self allocationReserve.
	
	self newSpaceStart: (self allocateMemory: newSpaceSizeToAllocate BaseAddress: memoryMapConfiguration newSpaceInitialAddress).
	
	self newSpaceStart ifNil: [ self insufficientMemoryAvailableError ].
	
	self newSpaceStart = memoryMapConfiguration newSpaceInitialAddress 
		ifFalse: [ 
			self logError: 'Could not allocate newSpace in the expected place (%p), got %p' _: self newSpaceStart _: memoryMapConfiguration newSpaceInitialAddress.
			self error: 'Error allocating' ].
	
	self newSpaceMask: (self newSpaceStart bitAnd: self spaceMaskToUse).
		
	self newSpaceEnd: self newSpaceStart + newSpaceSizeToAllocate.
]

{ #category : #private }
VMMemoryMap >> allocateOldObjectsSpace [

	| sizeToAllocate |

	sizeToAllocate := self roundToAllocationSize: self initialOldSpaceSize + self initialHeadroom.

	self oldSpaceStart: (self allocateMemory: sizeToAllocate BaseAddress: memoryMapConfiguration oldSpaceInitialAddress).

	self oldSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self oldSpaceStart = memoryMapConfiguration oldSpaceInitialAddress 
		ifFalse: [ 
			self logError: 'Could not allocate oldSpace in the expected place (%p), got %p' _: self oldSpaceStart _: memoryMapConfiguration oldSpaceInitialAddress.
			self error: 'Error allocating' ].

	self oldSpaceMask: (self oldSpaceStart bitAnd: self spaceMaskToUse).

	self setOldSpaceEnd: self oldSpaceStart + sizeToAllocate
]

{ #category : #private }
VMMemoryMap >> allocatePermObjectsSpace [

	| minSize |
	minSize := minPermSpaceSize max: initialPermSpaceSize.

	minSize = 0 ifTrue: [ ^ self ].

	minSize := self roundToAllocationSize: minSize.

	self permSpaceStart: (self 
		allocateMemory: minSize 
		BaseAddress: memoryMapConfiguration permSpaceInitialAddress).

	self permSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self permSpaceStart = memoryMapConfiguration permSpaceInitialAddress 
		ifFalse: [ 
			self logError: 'Could not allocate permSpace in the expected place (%p), got %p' _: self permSpaceStart _: memoryMapConfiguration permSpaceInitialAddress.
			self error: 'Error allocating' ].

	self permSpaceEnd: self permSpaceStart + minSize.

	self permSpaceMask: (self permSpaceStart bitAnd: self spaceMaskToUse).

	objectMemory setPermSpaceFreeStart: self permSpaceStart
]

{ #category : #allocating }
VMMemoryMap >> allocateSegmentOfSize: ammount minAddress: minAddress resultsIn: blockWithAddressAndSegSize [

	| sizeToRequest segmentAddress |

	<inline:true>
	<var: #sizeToRequest type:'size_t'>
	<var: #segmentAddress type:'void *'>
	
	sizeToRequest := self roundToAllocationSize: ammount.
	segmentAddress := self allocateMemory: sizeToRequest BaseAddress: minAddress.
	
	blockWithAddressAndSegSize value: segmentAddress value: sizeToRequest.
]

{ #category : #allocating }
VMMemoryMap >> allocateStackPages: initialStackSize [ 
	
	<inline: false>
	<returnTypeC: #void>
	
	| sizeToRequest |
	sizeToRequest := self roundToAllocationSize: initialStackSize.
	
	self stackPagesStart: (self allocateMemory: sizeToRequest BaseAddress: memoryMapConfiguration stackPagesInitialAddress).
	
	self stackPagesStart ifNil: [ self insufficientMemoryAvailableError ].
	
	self stackPagesStart = memoryMapConfiguration stackPagesInitialAddress 
		ifFalse: [ 
			self logError: 'Could not allocate stack in the expected place (%p), got %p' _: self stackPagesStart _: memoryMapConfiguration stackPagesInitialAddress.
			self error: 'Error allocating' ].
	
	self stackPagesEnd: self stackPagesStart + sizeToRequest.
	
	self memset: self stackPagesStart _: 0 _: sizeToRequest.

]

{ #category : #utils }
VMMemoryMap >> allocationGranularity [
	
	"In windows we have an allocation granularity. Maybe we have to get it from the system.
	https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info"
	self cppIf: WIN32 ifTrue: [ ^ 64 * 1024 ] ifFalse: [ ^ 0 ]
]

{ #category : #accessing }
VMMemoryMap >> allocationReserve [
	^ allocationReserve
]

{ #category : #accessing }
VMMemoryMap >> allocationReserve: anInteger [ 

	allocationReserve := anInteger 
]

{ #category : #accessing }
VMMemoryMap >> codeZoneEnd [

	^ codeZoneEnd
]

{ #category : #accessing }
VMMemoryMap >> codeZoneEnd: anInteger [ 
	codeZoneEnd := anInteger
]

{ #category : #accessing }
VMMemoryMap >> codeZoneStart [

	^ codeZoneStart
]

{ #category : #accessing }
VMMemoryMap >> codeZoneStart: anInteger [ 
	codeZoneStart := anInteger
]

{ #category : #asserting }
VMMemoryMap >> doCheckMemoryMap [

	self assert: (self isYoungObject: self newSpaceStart).
	self assert: (self isYoungObject: self newSpaceEnd - memoryMapConfiguration confWordSize).
	self assert: (self isOldObject: self newSpaceStart) not.
	self assert: (self isOldObject: self newSpaceEnd - memoryMapConfiguration confWordSize) not.
	self assert: (self isYoungObject: self newSpaceEnd).
	self assert: (self isYoungObject: self oldSpaceStart) not.
	self assert: (self isYoungObject: self oldSpaceEnd) not.
	self assert: (self isOldObject: self oldSpaceStart).
	self assert: (self isOldObject: self oldSpaceEnd - memoryMapConfiguration confWordSize).
	self assert: (self isOldObject: self oldSpaceEnd).

]

{ #category : #allocating }
VMMemoryMap >> ensureAtLeastPermSpaceOf: requestedSize [ 

	| diff |

	requestedSize = 0 ifTrue: [ ^ true ].
	
	self permSpaceStart = 0 
		ifTrue: [ 
			self initialPermSpaceSize: requestedSize.
			self allocatePermObjectsSpace.
			^ true. ].

	diff := requestedSize - self permSpaceSize.
	diff <= 0
		ifTrue: [ ^ true ]. 

	^ self extendPermObjectsSpaceBy: diff.
]

{ #category : #allocating }
VMMemoryMap >> extendPermObjectsSpace [

	self permSpaceStart = 0 
		ifTrue: [ ^ self ensureAtLeastPermSpaceOf: 10 * 1024 * 1024 ].

	^ self extendPermObjectsSpaceBy: 10 * 1024 * 1024
]

{ #category : #allocating }
VMMemoryMap >> extendPermObjectsSpaceBy: aSize [

	| requestedSize extendedAddress |

	requestedSize := self roundToAllocationSize: aSize.

	extendedAddress := self 
		allocateMemory: requestedSize 
		BaseAddress: self permSpaceEnd.
	
	extendedAddress ~= self permSpaceEnd 
		ifTrue: [ self logError: 'Could not extend perm space.'. ^ false ].
	
	self permSpaceEnd: self permSpaceEnd + requestedSize.	
		
	^ true.
]

{ #category : #simulation }
VMMemoryMap >> getpagesize [

	<doNotGenerate>
	
	^ 4096
]

{ #category : #accessing }
VMMemoryMap >> initialCodeZoneSize [

	^ initialCodeZoneSize
]

{ #category : #accessing }
VMMemoryMap >> initialCodeZoneSize: aValue [

	initialCodeZoneSize := aValue
]

{ #category : #accessing }
VMMemoryMap >> initialHeadroom [
	^ initialHeadroom
]

{ #category : #accessing }
VMMemoryMap >> initialHeadroom: anInteger [ 
	
	initialHeadroom := anInteger 
]

{ #category : #accessing }
VMMemoryMap >> initialNewSpaceSize [
	^ initialNewSpaceSize
]

{ #category : #accessing }
VMMemoryMap >> initialNewSpaceSize: anInteger [ 
	
	initialNewSpaceSize := anInteger
]

{ #category : #accessing }
VMMemoryMap >> initialOldSpaceSize [
	^ initialOldSpaceSize
]

{ #category : #accessing }
VMMemoryMap >> initialOldSpaceSize: anInteger [ 

	initialOldSpaceSize := anInteger
]

{ #category : #accessing }
VMMemoryMap >> initialPermSpaceSize [

	^ initialPermSpaceSize
]

{ #category : #accessing }
VMMemoryMap >> initialPermSpaceSize: anObject [

	initialPermSpaceSize := anObject
]

{ #category : #initialization }
VMMemoryMap >> initializeMemoryMap [

	initialCodeZoneSize := 0.
	initialPermSpaceSize := 0.
	minPermSpaceSize := 0.
	permSpaceStart := 0.
	permSpaceEnd := 0.
	permSpaceMask := -1.

	self simulationOnly: [ 
		memoryMapConfiguration := (VMMemoryMapConfiguration forWordsize:
			                          self class objectMemoryClass wordSize) new ].
		
	spaceMaskToUse := memoryMapConfiguration calculateMaskToUse.
]

{ #category : #private }
VMMemoryMap >> insufficientMemoryAvailableError [

	<doNotGenerate>
	self error.
]

{ #category : #'testing objects' }
VMMemoryMap >> isOldObject: anOop [ 

	<api>

	^ anOop allMask: oldSpaceMask
]

{ #category : #'testing objects' }
VMMemoryMap >> isPermanentObject: anOop [ 

	<api>

	^ anOop allMask: permSpaceMask

]

{ #category : #'testing objects' }
VMMemoryMap >> isYoungObject: anOop [ 

	<api>

	^ (anOop bitAnd: spaceMaskToUse) = newSpaceMask
]

{ #category : #accessing }
VMMemoryMap >> memoryManager [

	^ memoryManager
]

{ #category : #accessing }
VMMemoryMap >> memoryManager: anObject [

	memoryManager := anObject
]

{ #category : #simulation }
VMMemoryMap >> memset: startAddress _: value _: size [

	<doNotGenerate>
	
	startAddress to: startAddress + size - 1 by: memoryMapConfiguration confWordSize do: [ :address |
		memoryManager longAt: address put: value ]

]

{ #category : #accessing }
VMMemoryMap >> minPermSpaceSize [

	^ minPermSpaceSize
]

{ #category : #accessing }
VMMemoryMap >> minPermSpaceSize: anObject [

	minPermSpaceSize := anObject
]

{ #category : #accessing }
VMMemoryMap >> newSpaceEnd [

	^ newSpaceEnd
]

{ #category : #accessing }
VMMemoryMap >> newSpaceEnd: anObject [

	newSpaceEnd := anObject
]

{ #category : #accessing }
VMMemoryMap >> newSpaceMask [

	^ newSpaceMask
]

{ #category : #accessing }
VMMemoryMap >> newSpaceMask: anObject [

	newSpaceMask := anObject
]

{ #category : #accessing }
VMMemoryMap >> newSpaceStart [

	^ newSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> newSpaceStart: anObject [

	newSpaceStart := anObject
]

{ #category : #accessing }
VMMemoryMap >> objectMemory: aValue [	

	<doNotGenerate>
	objectMemory := aValue
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceEnd [
	^ oldSpaceEnd
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceMask [

	^ oldSpaceMask
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceMask: anObject [

	oldSpaceMask := anObject
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceStart [

	^ oldSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceStart: anObject [

	oldSpaceStart := anObject
]

{ #category : #accessing }
VMMemoryMap >> permSpaceEnd [
	^ permSpaceEnd
]

{ #category : #accessing }
VMMemoryMap >> permSpaceEnd: anInteger [ 

	permSpaceEnd := anInteger
]

{ #category : #accessing }
VMMemoryMap >> permSpaceMask [

	^ permSpaceMask
]

{ #category : #accessing }
VMMemoryMap >> permSpaceMask: anObject [

	permSpaceMask := anObject
]

{ #category : #accessing }
VMMemoryMap >> permSpaceSize [

	^ self permSpaceEnd - self permSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> permSpaceStart [
	^ permSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> permSpaceStart: anInteger [ 

	self assert: anInteger > oldSpaceEnd.
	permSpaceStart := anInteger 
]

{ #category : #utils }
VMMemoryMap >> roundToAllocationSize: anInteger [

	<inline: false>

	"First we round up to Page Size, and then we calculate the min with the platform granularity"

	| pageSize pageMask rounded |
	
	pageSize := self getpagesize.
	pageMask := (pageSize - 1) bitInvert64.

	rounded := anInteger bitAnd: pageMask.

	rounded < anInteger ifTrue: [ rounded := rounded + pageSize ].

	^ rounded max: self allocationGranularity
]

{ #category : #initialization }
VMMemoryMap >> setOldSpaceEnd: anInteger [ 
	
	oldSpaceEnd := anInteger.
	self assert: (permSpaceStart isZero or: [anInteger < permSpaceStart]).

]

{ #category : #accessing }
VMMemoryMap >> spaceMaskToUse [

	^ spaceMaskToUse
]

{ #category : #accessing }
VMMemoryMap >> spaceMaskToUse: anObject [

	spaceMaskToUse := anObject
]

{ #category : #accessing }
VMMemoryMap >> stackPagesEnd [

	^ stackPagesEnd
]

{ #category : #accessing }
VMMemoryMap >> stackPagesEnd: anObject [

	stackPagesEnd := anObject
]

{ #category : #accessing }
VMMemoryMap >> stackPagesStart [

	^ stackPagesStart
]

{ #category : #accessing }
VMMemoryMap >> stackPagesStart: anObject [

	stackPagesStart := anObject
]

{ #category : #accessing }
VMMemoryMap >> startOfObjectMemory [
	
	<api>
	
	"The first object space in the memory map is the newSpace."
	^ self newSpaceStart 
]
