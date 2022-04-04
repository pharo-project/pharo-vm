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
		'minPermSpaceSize'
	],
	#category : #'VMMaker-Memory'
}

{ #category : #translation }
VMMemoryMap class >> filteredInstVarNames [

	^ super filteredInstVarNames copyWithoutAll: #(memoryManager memoryMapConfiguration)
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
	
	newSpaceSizeToAllocate := self initialNewSpaceSize + self allocationReserve.
	
	self newSpaceStart: (self allocateMemory: newSpaceSizeToAllocate BaseAddress: memoryMapConfiguration newSpaceInitialAddress).
	
	self newSpaceStart ifNil: [ self insufficientMemoryAvailableError ].
	
	self newSpaceEnd: self newSpaceStart + newSpaceSizeToAllocate.
]

{ #category : #private }
VMMemoryMap >> allocateOldObjectsSpace [

	| sizeToAllocate |

	sizeToAllocate := self initialOldSpaceSize + self initialHeadroom.

	self oldSpaceStart: (self allocateMemory: sizeToAllocate BaseAddress: memoryMapConfiguration oldSpaceInitialAddress).

	self oldSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self setOldSpaceEnd: self oldSpaceStart + sizeToAllocate
]

{ #category : #private }
VMMemoryMap >> allocatePermObjectsSpace [

	| minSize |
	minSize := minPermSpaceSize max: initialPermSpaceSize.

	minSize = 0 ifTrue: [ ^ self ].

	self permSpaceStart: (self 
		allocateMemory: minSize 
		BaseAddress: memoryMapConfiguration permSpaceInitialAddress).

	self permSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self permSpaceEnd: self permSpaceStart + minSize	
]

{ #category : #allocating }
VMMemoryMap >> allocateStackPages: initialStackSize [ 
	
	<inline: false>
	<returnTypeC: #void>
	
	self stackPagesStart: (self allocateMemory: initialStackSize BaseAddress: memoryMapConfiguration stackPagesInitialAddress).
	
	self stackPagesStart ifNil: [ self insufficientMemoryAvailableError ].
	
	self stackPagesEnd: self stackPagesStart + initialStackSize.
	
	self memset: self stackPagesStart _: 0 _: initialStackSize.

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
	self assert: (self isYoungObject: self newSpaceEnd - memoryMapConfiguration wordSize).
	self assert: (self isOldObject: self newSpaceStart) not.
	self assert: (self isOldObject: self newSpaceEnd - memoryMapConfiguration wordSize) not.
	self assert: (self isYoungObject: self newSpaceEnd) not.
	self assert: (self isYoungObject: self oldSpaceStart) not.
	self assert: (self isYoungObject: self oldSpaceEnd) not.
	self assert: (self isOldObject: self oldSpaceStart).
	self assert: (self isOldObject: self oldSpaceEnd - memoryMapConfiguration wordSize).
	self assert: (self isOldObject: self oldSpaceEnd) not.

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

	self cCode: [ ] inSmalltalk: [ 
		memoryMapConfiguration := (VMMemoryMapConfiguration forWordsize:
			                          self class objectMemoryClass wordSize) new ]
]

{ #category : #private }
VMMemoryMap >> insufficientMemoryAvailableError [

	<doNotGenerate>
	self error.
]

{ #category : #'testing objects' }
VMMemoryMap >> isOldObject: anOop [ 
	<api>
	self flag:#todo.
	"^ anOop allMask: oldSpaceMask "
	^ oldSpaceStart <= anOop and: [ anOop < oldSpaceEnd ]

]

{ #category : #'testing objects' }
VMMemoryMap >> isPermanentObject: anOop [ 
	<api>
	self flag:#todo.
	"^ anOop allMask: oldSpaceMask "
	^ permSpaceStart <= anOop and: [ anOop < permSpaceEnd ]

]

{ #category : #'testing objects' }
VMMemoryMap >> isYoungObject: anOop [ 
	<api>
	self flag:#todo.
	"^ anOop allMask: oldSpaceMask "
	^ newSpaceStart <= anOop and: [ anOop < newSpaceEnd ]

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
	
	startAddress to: startAddress + size - 1 by: memoryMapConfiguration wordSize do: [ :address |
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
VMMemoryMap >> newSpaceStart [

	^ newSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> newSpaceStart: anObject [

	newSpaceStart := anObject
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceEnd [
	^ oldSpaceEnd
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
VMMemoryMap >> permSpaceStart [
	^ permSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> permSpaceStart: anInteger [ 

	self assert: anInteger > oldSpaceEnd.
	permSpaceStart := anInteger 
]

{ #category : #initialization }
VMMemoryMap >> setOldSpaceEnd: anInteger [ 
	
	oldSpaceEnd := anInteger.
	self assert: (permSpaceStart isZero or: [anInteger < permSpaceStart]).

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
