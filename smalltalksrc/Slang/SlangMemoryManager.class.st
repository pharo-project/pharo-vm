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
SlangMemoryManager >> allocate: aSize [ 
	
	| allocatedAddress newMemoryRegion |
	allocatedAddress := nextAvailableAddress.
	nextAvailableAddress := nextAvailableAddress + aSize.
	
	"Warrantee that memory regions do not move, for simulation purposes with the FFI"
	newMemoryRegion := ByteArray new: aSize.
	newMemoryRegion pinInMemory.
	
	memoryMap at: allocatedAddress put: newMemoryRegion.
	^ allocatedAddress
]

{ #category : #accessing }
SlangMemoryManager >> copyFrom: start to: end [

	| region |
	region := self regionForAddress: start.
	
	^ region value
		copyFrom: start - region key + 1
		to: end - region key + 1
]

{ #category : #allocating }
SlangMemoryManager >> free: anInteger [ 
	
	memoryMap removeKey: anInteger
]

{ #category : #accessing }
SlangMemoryManager >> initialAddress: anInteger [ 
	
	nextAvailableAddress := anInteger
]

{ #category : #allocating }
SlangMemoryManager >> initialize [

	super initialize.
	nextAvailableAddress := 0.
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
	
	| memory |
	"Check the access is aligned to the size we want to read"
	address \\ size ~= 0 ifTrue: [self unalignedAccessError].
	
	"Get the memory region where the address is stored"
	memory := self regionForAddress: address.
	
	^ memory value
		integerAt: address - memory key + 1
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
	oldRegion := memoryMap at: originalAddress.
	newRegion := memoryMap at: newAddress.
	newRegion replaceFrom: 1 to: oldRegion size with: oldRegion.
	self free: originalAddress.
	^ newAddress
]

{ #category : #'memory-access' }
SlangMemoryManager >> regionAtAddress: address [

	^ memoryMap at: address
]

{ #category : #'memory-access' }
SlangMemoryManager >> regionForAddress: address [

	^ memoryMap associations detect: [ :assoc | 
		  address between: assoc key and: assoc key + assoc value size - 1 ]
]

{ #category : #enumerating }
SlangMemoryManager >> regionsDo: aFullBlockClosure [ 
	
	memoryMap keysAndValuesDo: aFullBlockClosure
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
	
	| memory |
	"Check the access is aligned to the size we want to read"
	address \\ size ~= 0 ifTrue: [self unalignedAccessError].
	
	"Get the memory region where the address is stored"
	memory := self regionForAddress: address.
	
	^ memory value
		integerAt: address - memory key + 1
		put: aValue
		size: size
		signed: aBoolean
]

{ #category : #'memory-access' }
SlangMemoryManager >> writeSignedInteger: aValue at: address size: size [
	self haltIf: [address = 16848072].
	^ self writeInteger: aValue at: address size: size signed: true
]

{ #category : #'memory-access' }
SlangMemoryManager >> writeUnsignedInteger: aValue at: address size: size [
	
	^ self writeInteger: aValue at: address size: size signed: false
]
