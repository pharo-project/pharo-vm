"
Spur64BitCoMemoryManager is a refinement of Spur64BitMemoryManager that supports the CoInterpreter/Cogit just-in-time compiler.  The significant difference from Spur64BitMemoryManager is the memory layout.  Spur64BitCoMemoryManager adds the cogCodeZone beneath newSpace:

low address:
	cogCodeZone:
		generated run-time
		cog methods
		free space
		young referrers
	newSpace:
		past/future survivor space
		future/past survivor space
		eden
	first oldSpace segment
	...
	subsequent oldSpace segment
high address:

It would be convenient if the code zone were placed between newSpace and oldSpace; then Cog methods could be onsidered neither old nor young, filtering them out of copyAndForward: and the store check with single bounds checks.  But the CoInterpreter already assumes Cog methods are less than all objects (e.g. in its isMachineCodeFrame:).  If the dynamic frequency of isMachineCodeFrame: is higher (likely because this is used in e.g. scanning for unwind protects in non-local return) then it should keep the single bounds check.  So the coder zone remains beneath newSpace and Spur64BitCoMemoryManager ocerrides isReallyYoungObject: to filter-out Cog methods for copyAndForward:.

Instance Variables
	cogit:		<SimpleStackBasedCogit or subclass>

cogit
	- the just-in-time compiler
"
Class {
	#name : #Spur64BitCoMemoryManager,
	#superclass : #Spur64BitMemoryManager,
	#instVars : [
		'cogit'
	],
	#pools : [
		'CogMethodConstants'
	],
	#category : #'VMMaker-SpurMemoryManager'
}

{ #category : #simulation }
Spur64BitCoMemoryManager class >> defaultISA [
	"Answer the default instruction set architecture to use for simulation."
	^#X64
]

{ #category : #'accessing class hierarchy' }
Spur64BitCoMemoryManager class >> objectRepresentationClass [
	^CogObjectRepresentationFor64BitSpur
]

{ #category : #simulation }
Spur64BitCoMemoryManager class >> simulatorClass [
	^ Spur64BitMMLECoSimulator
]

{ #category : #'growing/shrinking memory' }
Spur64BitCoMemoryManager >> assimilateNewSegment: segInfo [
	"Update after adding a segment.
	 Here we make sure the new segment is not executable."
	<var: #segInfo type: #'SpurSegmentInfo *'>
	super assimilateNewSegment: segInfo.
	coInterpreter sqMakeMemoryNotExecutableFrom: segInfo segStart To: segInfo segLimit
]

{ #category : #trampolines }
Spur64BitCoMemoryManager >> ceScheduleScavenge [
	<api>
	self assert: freeStart >= scavengeThreshold.
	self scheduleScavenge
]

{ #category : #'debug support' }
Spur64BitCoMemoryManager >> checkMemoryMap [
	"Override to check that Cog methods are considered neither young nor old.
	 Being young would cause them to be scavenged.
	 Being old would cause them to be remembered if stored into (but wait, they don't get stored into)."

	super checkMemoryMap.

	"we would like the following to be true, but we either choose one boundary check for
	 cogMethods vs objects (isMachineCodeFrame: et al) or one boundary check for
	 copyAndForward:.  We can't have both, and the former is likely the highest dynamic
	 frequency."
	false ifTrue:
		[self assert: (memoryMap isYoungObject: cogit minCogMethodAddress) not.
		 self assert: (memoryMap isYoungObject: cogit maxCogMethodAddress) not].
	self assert: (memoryMap isOldObject: cogit minCogMethodAddress) not.
	self assert: (memoryMap isOldObject: cogit maxCogMethodAddress) not
]

{ #category : #accessing }
Spur64BitCoMemoryManager >> classSmallFloat [
	<api>
	^self fetchPointer: self smallFloatTag ofObject: classTableFirstPage
]

{ #category : #'debug support' }
Spur64BitCoMemoryManager >> clearLeakMapAndMapAccessibleObjects [
	"Perform an integrity/leak check using the heapMap.  Set a bit at each object's header.
	 Override to set a bit at each Cog method"
	super clearLeakMapAndMapAccessibleObjects.
	cogit addCogMethodsToHeapMap
]

{ #category : #accessing }
Spur64BitCoMemoryManager >> cogit: aCogit [ 
	<doNotGenerate>

	cogit := aCogit
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> ensureNoForwardedLiteralsIn: aMethodObj [
	"Ensure there are no forwarded literals in the argument."
	<api>
	self followForwardedObjectFields: aMethodObj toDepth: 0
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> freeStart: aValue [
	self assert: (aValue >= scavenger eden start and: [aValue < (scavengeThreshold + 1024)]).
	self assert: (scavengeThreshold max: aValue) + coInterpreter interpreterAllocationReserveBytes <= scavenger eden limit.
	^freeStart := aValue
]

{ #category : #'trampoline support' }
Spur64BitCoMemoryManager >> freeStartAddress [
	<api>
	<returnTypeC: #usqInt>
	^self cCode: [(self addressOf: freeStart) asUnsignedInteger]
		inSmalltalk: [cogit simulatedReadWriteVariableAddress: #freeStart in: self]
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> getScavengeThreshold [
	<api>
	<returnTypeC: #usqInt>
	^scavengeThreshold
]

{ #category : #'garbage collection' }
Spur64BitCoMemoryManager >> headerWhileForwardingOf: aCompiledMethodObjOop [
	"Answer the header of the argument even though
	 it may have its header word in a forwarding block
	 (which shouldn't happen with Spur)."
	self assert: (self isForwarded: aCompiledMethodObjOop) not.
	^self baseHeader: aCompiledMethodObjOop
]

{ #category : #'class table' }
Spur64BitCoMemoryManager >> isForwardedClassIndex: maybeClassIndex [
	"A lenient tester of forwarded class indices for inline cache management in the Cogit."
	<api>
	| classTablePage entry |
	maybeClassIndex asUnsignedInteger >= self classTableRootSlots ifTrue:
		[^false].
	classTablePage := self fetchPointer: maybeClassIndex >> self classTableMajorIndexShift
							ofObject: hiddenRootsObj.
	classTablePage = nilObj ifTrue:
		[^false].
	entry := self
				fetchPointer: (maybeClassIndex bitAnd: self classTableMinorIndexMask)
				ofObject: classTablePage.
	^self isForwarded: entry
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> isImmediateClass: classObj [
	<api>
	^(self instSpecOfClass: classObj) = self instSpecForImmediateClasses
]

{ #category : #compaction }
Spur64BitCoMemoryManager >> methodHeaderFromSavedFirstField: field [
	(self isIntegerObject: field) ifTrue:
		[^field].
	self assert: ((self isNonImmediate: field) and: [field < memoryMap newSpaceStart]).
	self assert: (coInterpreter cCoerceSimple: field to: #'CogMethod *') objectHeader
				= self nullHeaderForMachineCodeMethod.
	^(coInterpreter cCoerceSimple: field to: #'CogMethod *') methodHeader
]

{ #category : #'growing/shrinking memory' }
Spur64BitCoMemoryManager >> methodHeaderOf: methodObj [
	"Answer the method header of a CompiledMethod object.
	 If the method has been cogged then the header is a pointer to
	 the CogMethod and the real header will be stored in the CogMethod."
	<api>
	<inline: true>
	| header |
	self assert: (self isCompiledMethod: methodObj).
	header := self fetchPointer: HeaderIndex ofObject: methodObj.
	^(self isIntegerObject: header)
		ifTrue: [header]
		ifFalse:
			[self assert: header asUnsignedInteger < memoryMap newSpaceStart.
			 self assert: (coInterpreter cCoerceSimple: header to: #'CogMethod *') objectHeader
						= self nullHeaderForMachineCodeMethod.
			(coInterpreter cCoerceSimple: header to: #'CogMethod *') methodHeader]
]

{ #category : #'trampoline support' }
Spur64BitCoMemoryManager >> needGCFlagAddress [
	<api>
	<returnTypeC: #usqInt>
	^self cCode: [(self addressOf: needGCFlag) asUnsignedInteger]
		inSmalltalk: [cogit simulatedReadWriteVariableAddress: #needGCFlag in: self]
]

{ #category : #'object enumeration' }
Spur64BitCoMemoryManager >> objectBytesForSlots: numSlots [
	"Answer the total number of bytes in an object with the given
	 number of slots, including header and possible overflow size header."
	<api>
	<option: #SistaVM>
	^super objectBytesForSlots: numSlots
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> receiverTagBitsForMethod: aMethodObj [
	"Answer the tag bits for the receiver based on the method's methodClass, if any."
	<api>
	| methodClassOrNil |
	methodClassOrNil := coInterpreter methodClassOf: aMethodObj.
	(methodClassOrNil = nilObj
		 or: [(self instSpecOfClass: methodClassOrNil) ~= self forwardedFormat]) ifTrue:
			[^0].
	methodClassOrNil = (self fetchPointer: self smallIntegerTag ofObject: classTableFirstPage) ifTrue:
		[^self smallIntegerTag].
	methodClassOrNil = (self fetchPointer: self characterTag ofObject: classTableFirstPage) ifTrue:
		[^self characterTag].
	self assert: methodClassOrNil = (self fetchPointer: self smallFloatTag ofObject: classTableFirstPage).
	^self smallFloatTag
]

{ #category : #'trampoline support' }
Spur64BitCoMemoryManager >> scavengeThresholdAddress [
	<api>
	<returnTypeC: #usqInt>
	^self cCode: [(self addressOf: scavengeThreshold) asUnsignedInteger]
		inSmalltalk: [cogit simulatedReadWriteVariableAddress: #getScavengeThreshold in: self]
]

{ #category : #'trampoline support' }
Spur64BitCoMemoryManager >> specialObjectsArrayAddress [
	<api>
	^self cCode: [(self addressOf: specialObjectsOop) asUnsignedInteger]
		inSmalltalk: [cogit simulatedVariableAddress: #specialObjectsOop in: self]
]

{ #category : #'simulation only' }
Spur64BitCoMemoryManager >> unalignedLongAt: byteAddress [
	<doNotGenerate>
	| rem |
	rem := byteAddress \\ 8.
	^rem = 0
		ifTrue: [self longAt: byteAddress]
		ifFalse: [((self unsignedLong64At: byteAddress - rem) + ((self unsignedLong64At: byteAddress - rem + 8) bitShift: 64) bitShift: rem * -8) bitAnd: 16rFFFFFFFFFFFFFFFF]
]

{ #category : #'simulation only' }
Spur64BitCoMemoryManager >> unalignedLongAt: byteAddress put: aLong [
	<doNotGenerate>
	| rem mask |
	rem := byteAddress \\ 8.
	^rem = 0
		ifTrue: [self unsignedLong64At: byteAddress put: aLong]
		ifFalse:
			[mask := 16rFFFFFFFFFFFFFFFF bitAnd: (-1 bitShift: rem * 8).
			 self unsignedLong64At: byteAddress - rem
				put: ((self unsignedLong64At: byteAddress - rem) bitAnd: mask bitInvert)
					+ ((aLong bitShift: rem * 8) bitAnd: mask).
			 self unsignedLong64At: byteAddress - rem + 8
				put: ((self unsignedLong64At: byteAddress - rem + 8) bitAnd: mask)
					+ ((aLong bitShift: 8 - rem * -8) bitAnd: mask bitInvert).
			 aLong]
]

{ #category : #'cog jit support' }
Spur64BitCoMemoryManager >> withoutForwardingOn: obj1 and: obj2 with: aBool sendToCogit: selector [
	"For the purposes of become: send selector to the cogit with obj1, obj2
	 and aBool and answer the result.  Undo forwarding for the selector."
	<api>
	<var: #selector declareC: 'sqInt (*selector)(sqInt,sqInt,sqInt)'>
	| targetA targetB |
	targetA := self followForwarded: obj1.
	targetB := self followForwarded: obj2.
	^cogit perform: selector with: targetA with: targetB with: aBool
]
