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
		'oldSpaceMask'
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

{ #category : #allocating }
VMMemoryMap >> allocateHeap [
	<inline: false>
	self allocateNewObjectsSpace.
	self allocateOldObjectsSpace.
	self allocatePermObjectsSpace.	
]

{ #category : #private }
VMMemoryMap >> allocateMemory: desiredSize BaseAddress: baseAddress [

	<doNotGenerate>
	^ memoryManager allocate: desiredSize desiredPosition: baseAddress
]

{ #category : #private }
VMMemoryMap >> allocateNewObjectsSpace [
	
	| newSpaceSize |
	
	newSpaceSize := self initialNewSpaceSize + self allocationReserve.
	
	self newSpaceStart: (self allocateMemory: newSpaceSize BaseAddress: memoryMapConfiguration newSpaceInitialAddress).
	
	self newSpaceStart ifNil: [ self insufficientMemoryAvailableError ].
	
	self newSpaceEnd: self newSpaceStart + newSpaceSize.
]

{ #category : #private }
VMMemoryMap >> allocateOldObjectsSpace [

	| sizeToAllocate |

	sizeToAllocate := self initialOldSpaceSize + self initialHeadroom.

	self oldSpaceStart: (self allocateMemory: sizeToAllocate BaseAddress: memoryMapConfiguration oldSpaceInitialAddress).

	self oldSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self setOldSpaceEnd: self oldSpaceStart + sizeToAllocate
]

{ #category : #allocating }
VMMemoryMap >> allocatePermObjectsSpace [

	| permSpaceSize |
	permSpaceSize := 10*1024*1024.

	self permSpaceStart: (self 
		allocateMemory: permSpaceSize 
		BaseAddress: memoryMapConfiguration permSpaceInitialAddress).

	self permSpaceStart ifNil: [ self insufficientMemoryAvailableError ].

	self permSpaceEnd: self permSpaceStart + permSpaceSize	
]

{ #category : #accessing }
VMMemoryMap >> allocationReserve [
	^ allocationReserve
]

{ #category : #accessing }
VMMemoryMap >> allocationReserve: anInteger [ 

	allocationReserve := anInteger 
]

{ #category : #asserting }
VMMemoryMap >> checkMemoryMap [

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

{ #category : #initialization }
VMMemoryMap >> initializeMemoryMap [

	self cCode: [  ] inSmalltalk: [ 
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
	self assert: (permSpaceStart isNil or: [anInteger < permSpaceStart]).

]

{ #category : #accessing }
VMMemoryMap >> startOfObjectMemory [
	
	<api>
	
	"The first object space in the memory map is the newSpace."
	^ self newSpaceStart 
]
