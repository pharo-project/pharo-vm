Class {
	#name : #SlangMemoryManager,
	#superclass : #Object,
	#instVars : [
		'nextAvailableAddress',
		'memoryMap',
		'wordSize'
	],
	#category : #'Slang-Simulation'
}

{ #category : #allocating }
SlangMemoryManager >> allocate: desiredSize [

	^ self allocate: desiredSize desiredPosition: nextAvailableAddress
]

{ #category : #allocating }
SlangMemoryManager >> allocate: desiredSize desiredPosition: desiredPosition [ 

	| allocatedAddress newMemoryRegion allocatedSize newMemory |
	"Allocate chunks multiple of 4KB, as they are required by the machine code simulator"

	allocatedSize := (desiredSize / 4096) ceiling * 4096.

	self assert: desiredPosition \\ 4096 = 0.

	self assert: desiredPosition >= nextAvailableAddress.

	allocatedAddress := desiredPosition.
	nextAvailableAddress := desiredPosition + allocatedSize.

	"Warrantee that memory regions do not move, for simulation purposes with the FFI"
	newMemory := ByteArray new: allocatedSize.
	newMemory pinInMemory.
	newMemoryRegion := SlangMemoryRegion new
		                   start: allocatedAddress;
		                   memory: newMemory;
		                   originallyRequestedMemory: desiredSize;
		                   yourself.

	"Index regions by the high bits of the address"
	self
		registerNewRegion: newMemoryRegion
		size: desiredSize
		address: allocatedAddress.
	^ allocatedAddress
]

{ #category : #allocating }
SlangMemoryManager >> checkIsRegionAddress: address [

	((address bitAnd: 16rfff) > 0)
		ifTrue: [ self error: 'Not a region start address' ]
]

{ #category : #accessing }
SlangMemoryManager >> copyFrom: start to: end [

	| region |
	region := self regionForAddress: start.
	
	^ region memory
		copyFrom: start - region start + 1
		to: end - region start + 1
]

{ #category : #allocating }
SlangMemoryManager >> free: address [ 
	
	self checkIsRegionAddress: address.
	memoryMap removeKey: address >> 12
]

{ #category : #accessing }
SlangMemoryManager >> initialAddress: anInteger [ 
	
	nextAvailableAddress := anInteger
]

{ #category : #allocating }
SlangMemoryManager >> initialize [

	super initialize.
	nextAvailableAddress := 4*1024.
	memoryMap := Dictionary new
]

{ #category : #'memory-access' }
SlangMemoryManager >> long32At: address [
	
	^ self readSignedIntegerAt: address size: 4
]

{ #category : #'memory-access' }
SlangMemoryManager >> long32At: address put: a32BitValue [
	
	^ self writeSignedInteger: a32BitValue at: address size: 4
]

{ #category : #'memory-access' }
SlangMemoryManager >> long64At: address [
	
	^ self readSignedIntegerAt: address size: 8
]

{ #category : #'memory-access' }
SlangMemoryManager >> long64At: address put: a64BitValue [
	
	^ self writeSignedInteger: a64BitValue at: address size: 8
]

{ #category : #'memory-access' }
SlangMemoryManager >> longAt: address [
	
	^ self readSignedIntegerAt: address size: self wordSize
]

{ #category : #'memory-access' }
SlangMemoryManager >> longAt: address put: aWordSizedValue [
	
	^ self writeSignedInteger: aWordSizedValue at: address size: self wordSize
]

{ #category : #'memory-access' }
SlangMemoryManager >> readIntegerAt: address size: size signed: aBoolean [
	
	| region |
	"Check the access is aligned to the size we want to read"
	address \\ size ~= 0 ifTrue: [self unalignedAccessError].
	
	"Get the memory region where the address is stored"
	region := self regionForAddress: address.
	
	^ region
		integerAt: address - region start
		size: size
		signed: aBoolean
]

{ #category : #'memory-access' }
SlangMemoryManager >> readSignedIntegerAt: address size: size [
	
	^ self readIntegerAt: address size: size signed: true
]

{ #category : #'memory-access' }
SlangMemoryManager >> readUnsignedIntegerAt: address size: size [
	
	^ self readIntegerAt: address size: size signed: false
]

{ #category : #'memory-allocation' }
SlangMemoryManager >> reallocate: originalAddress withSize: desiredSize [
	
	| newAddress oldRegion newRegion |
	newAddress := self allocate: desiredSize.
	oldRegion := self regionAtAddress: originalAddress.
	newRegion := self regionAtAddress: newAddress.
	newRegion replaceFrom: 1 to: oldRegion originallyRequestedMemory with: oldRegion.
	self free: originalAddress.
	^ newAddress
]

{ #category : #'memory-access' }
SlangMemoryManager >> regionAtAddress: address [

	self checkIsRegionAddress: address.
	^ self regionForAddress: address
]

{ #category : #'memory-access' }
SlangMemoryManager >> regionForAddress: address [

	"Memory regions are allocated in multiples of 4KB (12 bits).
	The Memory map indexes memory regions by the high part"
	^ memoryMap at: address >> 12
]

{ #category : #enumerating }
SlangMemoryManager >> regionsDo: aFullBlockClosure [ 
	
	memoryMap values asSet do: [ :region |
		aFullBlockClosure
			value: region start
			value: region memory ]
]

{ #category : #allocating }
SlangMemoryManager >> registerNewRegion: newMemoryRegion size: desiredSize address: allocatedAddress [

	allocatedAddress to: allocatedAddress + desiredSize by: 4096 do: [ 
		:pageAddress | "Index regions by the high bits of the address" 
		memoryMap at: pageAddress >> 12 put: newMemoryRegion ]
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedByteAt: anInteger [
	
	^ self readUnsignedIntegerAt: anInteger size: 1
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedByteAt: anAddress put: aValue [
	
	^ self writeUnsignedInteger: aValue at: anAddress size: 1
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLong32At: address [

	^ self readUnsignedIntegerAt: address size: 4
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLong32At: address put: a32BitValue [ 

	^ self writeUnsignedInteger: a32BitValue at: address size: 4
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLong64At: address [

	^ self readUnsignedIntegerAt: address size: 8
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLong64At: address put: a64BitValue [ 

	^ self writeUnsignedInteger: a64BitValue at: address size: 8
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLongAt: address [
	
	^ self readUnsignedIntegerAt: address size: self wordSize
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedLongAt: address put: aValue [
	
	^ self writeUnsignedInteger: aValue at: address size: self wordSize
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedShortAt: anAddress [
	
	^ self readUnsignedIntegerAt: anAddress size: 2
]

{ #category : #'memory-access' }
SlangMemoryManager >> unsignedShortAt: anAddress put: aValue [
	
	^ self writeUnsignedInteger: aValue at: anAddress size: 2
]

{ #category : #accessing }
SlangMemoryManager >> wordSize [

	^ wordSize
]

{ #category : #accessing }
SlangMemoryManager >> wordSize: anObject [

	wordSize := anObject
]

{ #category : #'memory-access' }
SlangMemoryManager >> writeInteger: aValue at: address size: size signed: aBoolean [
	
	| region |
	"Check the access is aligned to the size we want to read"
	address \\ size ~= 0 ifTrue: [self unalignedAccessError].
	
	"Get the memory region where the address is stored"
	region := self regionForAddress: address.
	
	^ region
		integerAt: address - region start
		put: aValue
		size: size
		signed: aBoolean
]

{ #category : #'memory-access' }
SlangMemoryManager >> writeSignedInteger: aValue at: address size: size [

	^ self writeInteger: aValue at: address size: size signed: true
]

{ #category : #'memory-access' }
SlangMemoryManager >> writeUnsignedInteger: aValue at: address size: size [
	
	^ self writeInteger: aValue at: address size: size signed: false
]
