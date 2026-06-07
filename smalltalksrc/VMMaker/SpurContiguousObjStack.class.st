Class {
	#name : 'SpurContiguousObjStack',
	#superclass : 'SpurNewSpaceSpace',
	#instVars : [
		'top',
		'initialSize',
		'memoryManager',
		'objectMemory'
	],
	#category : 'VMMaker-SpurMemoryManager',
	#package : 'VMMaker',
	#tag : 'SpurMemoryManager'
}

{ #category : 'translation' }
SpurContiguousObjStack class >> filteredInstVarNames [

	^ super filteredInstVarNames copyWithoutAll: #(memoryManager objectMemory)
]

{ #category : 'adding' }
SpurContiguousObjStack >> addToStack: anOop [

	self top = self limit ifTrue: [ self extendObjStack ].

	objectMemory longAt: self top put: anOop.
	self top: self top + objectMemory bytesPerOop.
]

{ #category : 'C library simulation' }
SpurContiguousObjStack >> calloc: num _: size [ 

	<doNotGenerate>
	^ self malloc: num * size
]

{ #category : 'adding' }
SpurContiguousObjStack >> extendObjStack [

	| newTop newSize newStart newLimit |

	"We double the size of the stack"
	newSize := ((self limit - self start) / objectMemory wordSize) * 2.

	newStart := objectMemory realloc: self start _: (objectMemory wordSize * newSize).
	newStart ifNil: [ 
		objectMemory error: 'Imposible to extend SpurContiguousObjStack' ].

	newLimit := newStart asInteger + (newSize * objectMemory wordSize).

	newTop := (self top - self start) + newStart asInteger.

	self
		start: newStart asInteger;
		limit: newLimit.

	self top: newTop
]

{ #category : 'C library simulation' }
SpurContiguousObjStack >> free: anAddress [

	<doNotGenerate>
	memoryManager free: anAddress
]

{ #category : 'freeing' }
SpurContiguousObjStack >> freeObjectStack [
	
	objectMemory free: self start.
	self start: 0.
	self top: 0.
]

{ #category : 'accessing' }
SpurContiguousObjStack >> initialSize [

	^ initialSize
]

{ #category : 'accessing' }
SpurContiguousObjStack >> initialSize: anObject [

	initialSize := anObject
]

{ #category : 'initialization' }
SpurContiguousObjStack >> initializeWithAtLeast: anInitialSizeIfNotProvided onError: onErrorBlock [ 

	"Initialize the queue so that 
	  - start points at the beginning of the allocated chunk,
	  - limit points to the last potential entry
	  - top is by default the start"

	<inline: true>

	| allocation |
	
	(self initialSize isNil or: [ self initialSize = 0 ]) 
		ifTrue: [ self initialSize: anInitialSizeIfNotProvided ].

	allocation := objectMemory malloc: (objectMemory sizeof: #'void *') * self initialSize.

	allocation ifNil: [ onErrorBlock value ].

	self
		start: allocation asInteger;
		limit: allocation asInteger
			+ ((objectMemory sizeof: #'void *') * self initialSize).

	self top: self start
]

{ #category : 'C library simulation' }
SpurContiguousObjStack >> malloc: size [
	<doNotGenerate>
	| address region |
	
	size = 0 ifTrue: [ ^ nil ].
	
	address := memoryManager allocate: size.
	region := memoryManager regionAtAddress: address.
	^ CNewArrayAccessor new
		setObject: region;
		address: address;
		yourself
]

{ #category : 'accessing' }
SpurContiguousObjStack >> memoryManager: anObject [
	<doNotGenerate>
	memoryManager := anObject
]

{ #category : 'accessing' }
SpurContiguousObjStack >> objectMemory: anObject [
	<doNotGenerate>
	objectMemory := anObject
]

{ #category : 'enumerating' }
SpurContiguousObjStack >> objectStackDo: aFullBlockClosure [

	<inline: true>

	self start 
		to: self top - objectMemory bytesPerOop
		by: objectMemory bytesPerOop
		do: [ :anAddress | aFullBlockClosure value: (objectMemory longAt: anAddress) ]
]

{ #category : 'printing' }
SpurContiguousObjStack >> printOn: aStream [
	<doNotGenerate>
	super printOn: aStream.
	top ifNotNil:
		[aStream nextPutAll: ' top: '; nextPutAll: top hex]
]

{ #category : 'accessing' }
SpurContiguousObjStack >> top [
	"Answer the value of top"

	^ top
]

{ #category : 'accessing' }
SpurContiguousObjStack >> top: anObject [
	"Set the value of top"

	^top := anObject
]
