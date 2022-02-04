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
		'memoryMapConfiguration'
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

	self oldSpaceEnd: self oldSpaceStart + sizeToAllocate
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
VMMemoryMap >> oldSpaceEnd: anInteger [ 
	
	oldSpaceEnd := anInteger
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
VMMemoryMap >> startOfObjectMemory [
	
	<api>
	
	"The first object space in the memory map is the newSpace."
	^ self newSpaceStart 
]

{ #category : #accessing }
VMMemoryMap >> wordSize: anInteger [ 

	<doNotGenerate>

	wordSize := anInteger
]
