Class {
	#name : 'Spur32BitMMLECoSimulator',
	#superclass : 'Spur32BitCoMemoryManager',
	#traits : 'TVMSpurMemoryManagerSimulator',
	#classTraits : 'TVMSpurMemoryManagerSimulator classTrait',
	#instVars : [
		'parent',
		'bootstrapping'
	],
	#category : 'VMMaker-SpurMemoryManagerSimulation',
	#package : 'VMMaker',
	#tag : 'SpurMemoryManagerSimulation'
}

{ #category : 'accessing' }
Spur32BitMMLECoSimulator >> bootstrapping [
	^bootstrapping
]

{ #category : 'accessing' }
Spur32BitMMLECoSimulator >> bootstrapping: aBoolean [
	bootstrapping := aBoolean.
	segmentManager initForBootstrap
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> byteAt: byteAddress [
	| lowBits long32 |
	lowBits := byteAddress bitAnd: 3.
	long32 := memoryManager uint32AtPointer: byteAddress - lowBits.
	^(long32 bitShift: -8 * lowBits) bitAnd: 16rFF
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> byteAt: byteAddress put: byte [
	| lowBits long32 longAddress mask value |
	lowBits := byteAddress bitAnd: 3.
	longAddress := byteAddress - lowBits.
	long32 := self uint32AtPointer: longAddress.
	mask := (16rFF bitShift: 8 * lowBits) bitInvert.
	value := byte bitShift: 8 * lowBits.
	self uint32AtPointer: longAddress put: ((long32 bitAnd: mask) bitOr: value).
	^byte
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> byteAtPointer: pointer [
	"This gets implemented by Macros in C, where its types will also be checked.
	 pointer is a raw address."

	^self byteAt: pointer
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> byteSwapped32IfBigEndian: w [
	^w bitAnd: 16rFFFFFFFF
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> byteSwapped64IfBigEndian: w [
	^w bitAnd: 16rFFFFFFFFFFFFFFFF
]

{ #category : 'initialization' }
Spur32BitMMLECoSimulator >> coInterpreter: aCoInterpreter cogit: aCogit [
	coInterpreter := aCoInterpreter.
	cogit := aCogit.
	scavenger coInterpreter: aCoInterpreter.
	compactor coInterpreter: aCoInterpreter
]

{ #category : 'simulation only' }
Spur32BitMMLECoSimulator >> cogCodeBase [
	^Cogit guardPageSize
]

{ #category : 'debug support' }
Spur32BitMMLECoSimulator >> eek [
	self halt
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> endianness [
	^#little
]

{ #category : 'float primitives' }
Spur32BitMMLECoSimulator >> fetchFloatAt: floatBitsAddress into: aFloat [
	aFloat at: 2 put: (self uint32AtPointer: floatBitsAddress).
	aFloat at: 1 put: (self uint32AtPointer: floatBitsAddress+4)
]

{ #category : 'object access' }
Spur32BitMMLECoSimulator >> fetchPointer: fieldIndex ofObject: objOop [
	self assert: (self isForwarded: objOop) not.
	self assert: (fieldIndex >= 0 and: [fieldIndex < (self numSlotsOfAny: objOop)
				or: [fieldIndex = 0 "forwarders"]]).
	^super fetchPointer: fieldIndex ofObject: objOop
]

{ #category : 'spur bootstrap' }
Spur32BitMMLECoSimulator >> freeLists [
	^freeLists
]

{ #category : 'accessing' }
Spur32BitMMLECoSimulator >> freeStart [
	"freeStart = 16r1163E0 ifTrue: [self halt]."
	^super freeStart
]

{ #category : 'gc - global' }
Spur32BitMMLECoSimulator >> globalGarbageCollect [
	"If we're /not/ a clone, clone the VM and push it over the cliff.
	 If it survives, destroy the clone and continue.  We should be OK until next time."
	parent ifNil:
		[coInterpreter cr; print: 'GC number '; print: statFullGCs; tab; flush.
		 CloneOnGC ifTrue:
			[coInterpreter cloneSimulation objectMemory globalGarbageCollect.
			 Smalltalk garbageCollect]].
	^super globalGarbageCollect
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> halfWordHighInLong32: long32 [
	"Used by Balloon"

	^long32 bitAnd: 16rFFFF
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> halfWordLowInLong32: long32 [
	"Used by Balloon"

	^long32 bitShift: -16
]

{ #category : 'header format' }
Spur32BitMMLECoSimulator >> headerForSlots: numSlots format: formatField classIndex: classIndex [
	"The header format in LSB is
	 MSB:	| 2 bits				|
			| 22: identityHash	|
			| 8: slotSize			|
			| 3 bits				|
			| 5: format			|
			| 2 bits				|
			| 22: classIndex		| : LSB"
	self assert: (numSlots bitAnd: self numSlotsMask) = numSlots.
	self assert: (formatField bitAnd: self formatMask) = formatField.
	self assert: (classIndex bitAnd: self classIndexMask) = classIndex.
	^super headerForSlots: numSlots format: formatField classIndex: classIndex
]

{ #category : 'debug support' }
Spur32BitMMLECoSimulator >> heapMapAtWord: address [
	^heapMap heapMapAtWord: address asInteger
]

{ #category : 'initialization' }
Spur32BitMMLECoSimulator >> initialize [
	super initialize.
	bootstrapping := false
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> intAt: byteAddress [ 
	^self longAt: byteAddress
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> intAt: byteAddress put: a32BitValue [
	^self longAt: byteAddress put: (a32BitValue bitAnd: 16rFFFFFFFF)
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> long32At: byteAddress [
	"Answer the 32-bit word at byteAddress which must be 0 mod 4."

	^self longAt: byteAddress
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> long32At: byteAddress put: a32BitValue [
	"Store the 32-bit value at byteAddress which must be 0 mod 4."

	^self longAt: byteAddress put: a32BitValue
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> long64At: byteAddress [
	"memory is a Bitmap, a 32-bit indexable array of bits"
	| hiWord loWord |
	byteAddress \\ 8 ~= 0 ifTrue: [self unalignedAccessError].
	loWord := memoryManager uint32AtPointer: byteAddress.
	hiWord := memoryManager uint32AtPointer: byteAddress + 4.
	^hiWord = 0
		ifTrue: [loWord]
		ifFalse: [(hiWord bitShift: 32) + loWord]
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> long64At: byteAddress put: a64BitValue [
	byteAddress \\ 8 ~= 0 ifTrue: [self unalignedAccessError].
	self
		longAt: byteAddress put: (a64BitValue bitAnd: 16rffffffff);
		longAt: byteAddress + 4 put: a64BitValue >> 32.
	^a64BitValue
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> longAt: byteAddress [

	^memoryManager long32At: byteAddress
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> longAt: byteAddress put: a32BitValue [
	"Note: Adjusted for Smalltalk's 1-based array indexing."
	"(byteAddress = 16r101348 and: [a32BitValue = 16r53]) ifTrue:
		[self halt]."
	"((byteAddress between: 16rda8ac and: 16rda8c0)
	 or: [byteAddress between: 16r8eb98 and: 16r8ebb0]) ifTrue:
		[self halt]."
	^ memoryManager uint32AtPointer: byteAddress put: a32BitValue
]

{ #category : 'gc - global' }
Spur32BitMMLECoSimulator >> markAndTrace: objOop [
	"objOop = 16rB26020 ifTrue: [self halt].
	objOop = 16rB25FD8 ifTrue: [self halt].
	objOop = 16rB26010 ifTrue: [self halt]."
	^super markAndTrace: objOop
]

{ #category : 'initialization' }
Spur32BitMMLECoSimulator >> nextLongFrom: aStream [
	"Read a 32- or 64-bit quantity from the given (binary) stream."

	^aStream nextLittleEndianNumber: self wordSize
]

{ #category : 'initialization' }
Spur32BitMMLECoSimulator >> nextWord32From: aStream [
	"Read a 32-bit quantity from the given (binary) stream."

	^aStream nextLittleEndianNumber: 4
]

{ #category : 'spur bootstrap' }
Spur32BitMMLECoSimulator >> numClassTablePages [
	^numClassTablePages
]

{ #category : 'accessing' }
Spur32BitMMLECoSimulator >> parent [

	^ parent
]

{ #category : 'accessing' }
Spur32BitMMLECoSimulator >> parent: anObject [

	parent := anObject
]

{ #category : 'debug support' }
Spur32BitMMLECoSimulator >> runLeakCheckerFor: gcModes excludeUnmarkedObjs: excludeUnmarkedObjs classIndicesShouldBeValid: classIndicesShouldBeValid [

	(gcModes anyMask: checkForLeaks) ifTrue: [ 
		coInterpreter transcript
			nextPutAll: 'leak-checking...';
			flush ].
	^ super
		  runLeakCheckerFor: gcModes
		  excludeUnmarkedObjs: excludeUnmarkedObjs
		  classIndicesShouldBeValid: classIndicesShouldBeValid
]

{ #category : 'gc - global' }
Spur32BitMMLECoSimulator >> scavengingGCTenuringIf: tenuringCriterion [
	"If we're /not/ a clone, clone the VM and push it over the cliff.
	 If it survives, destroy the clone and continue.  We should be OK until next time."
	(self leakCheckNewSpaceGC
	 and: [parent isNil]) ifTrue:
		[coInterpreter cr; print: 'scavenge '; print: statScavenges; tab; flush.
		 CloneOnScavenge ifTrue:
			[coInterpreter cloneSimulation objectMemory scavengingGCTenuringIf: tenuringCriterion.
			 Smalltalk garbageCollect]].
	^super scavengingGCTenuringIf: tenuringCriterion
]

{ #category : 'header access' }
Spur32BitMMLECoSimulator >> setIsMarkedOf: objOop to: aBoolean [
	"objOop = 16rB26020 ifTrue: [self halt]."
	super setIsMarkedOf: objOop to: aBoolean.
	"(aBoolean
	 and: [(self isContextNonImm: objOop)
	 and: [(coInterpreter
			checkIsStillMarriedContext: objOop
			currentFP: coInterpreter framePointer)
	 and: [(coInterpreter stackPages stackPageFor: (coInterpreter frameOfMarriedContext: objOop)) trace = 0]]]) ifTrue:
		[self halt]"
]

{ #category : 'debug support' }
Spur32BitMMLECoSimulator >> setUpForUseByFacade: aCurrentImageCoInterpreterFacade [
	"Make sure that eden etc are initialized, so that methods can be printed.
	 This is really to make addressCouldBeObj: et al work."
	<doNotGenerate>
	self edenBytes: 0.
	self setHeapBase: self freeStart
		memoryLimit: self endOfMemory
		endOfMemory: self endOfMemory
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> shortAt: byteAddress [
    "Return the half-word at byteAddress which must be even."
	| lowBits long |
	lowBits := byteAddress bitAnd: 2.
	long := self longAt: byteAddress - lowBits.
	^ lowBits = 2
		ifTrue: [ long bitShift: -16 ]
		ifFalse: [ long bitAnd: 16rFFFF ]
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> shortAt: byteAddress put: a16BitValue [
    "Return the half-word at byteAddress which must be even."
	| lowBits long longAddress |
	lowBits := byteAddress bitAnd: 2.
	lowBits = 0
		ifTrue: "storing into LS word"
			[long := self longAt: byteAddress.
			 self longAt: byteAddress
				put: ((long bitAnd: 16rFFFF0000) bitOr: a16BitValue)]
		ifFalse: "storing into MS word"
			[longAddress := byteAddress - 2.
			long := self longAt: longAddress.
			self longAt: longAddress
				put: ((long bitAnd: 16rFFFF) bitOr: (a16BitValue bitShift: 16))].
	^a16BitValue
]

{ #category : 'float primitives' }
Spur32BitMMLECoSimulator >> storeFloatAt: floatBitsAddress from: aFloat [
	self long32At: floatBitsAddress put: (aFloat at: 2).
	self long32At: floatBitsAddress+4 put: (aFloat at: 1)
]

{ #category : 'memory access' }
Spur32BitMMLECoSimulator >> vmEndianness [
	"1 = big, 0 = little"
	^0
]
