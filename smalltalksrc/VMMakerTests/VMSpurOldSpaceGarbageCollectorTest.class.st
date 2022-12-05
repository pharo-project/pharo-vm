Class {
	#name : #VMSpurOldSpaceGarbageCollectorTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#instVars : [
		'objectStackLimit'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #assertion }
VMSpurOldSpaceGarbageCollectorTest >> assertHashOf: anOop equals: aHash [ 
	self assert: (memory hashBitsOf: anOop) equals: aHash
]

{ #category : #assertion }
VMSpurOldSpaceGarbageCollectorTest >> assertObjectWereReclaimed: aBlock [ 
	| initialSpace firstObjectToBeRemembered sizeOfObject |
	"The planning compactor frees object by sliding, and therefore does not reclaim memory if there is only dead objects in the oldspace."
	
	"We allocate objects during the setup"
	memory fullGC. 
	
	initialSpace := memory totalFreeListBytes.
	
	aBlock value.
	
	firstObjectToBeRemembered := self newOldSpaceObjectWithSlots: 0.
	self keepObjectInVMVariable1: firstObjectToBeRemembered.
	sizeOfObject := memory bytesInObject: firstObjectToBeRemembered.
	
	memory fullGC.
	
	self assert: initialSpace - sizeOfObject equals: memory totalFreeListBytes
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> initializationOptions [

	^ super initializationOptions , { 
		#ObjStackPageSlots . objectStackLimit }
]

{ #category : #testing }
VMSpurOldSpaceGarbageCollectorTest >> isValidFirstBridge [

	^ memory segmentManager
		isValidSegmentBridge: (memory segmentManager bridgeAt: 0)
]

{ #category : #running }
VMSpurOldSpaceGarbageCollectorTest >> runCaseManaged [ 

	^ self runCase
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> setUp [

	objectStackLimit :=  10.
	super setUp.
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectBiggerThanSizeOfFreeSpace [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber.

	self assert: anObjectOop isNil
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectBiggerThanSizeOfFreeSpaceShouldPlanifyGC [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber.

	self assert: memory needGCFlag
]

{ #category : #testCompactor }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectRightBeforeOverflowingFreeChunk [
	| chuckSize chunk next object free |

	"before GC:
		dead object
		free chunk with overflow header
	after GC:
		free chunk
		free chunk with overflow header
	
	Note: this scenario expects the free chunks to not be coallesced.
	Improve this test if the memory manager become more efficient."

	memory fullGC.

	"Allocate a contiguous chunk of memory to be splited into entities"
	chuckSize := 512*8.
	chunk := next := memory allocateOldSpaceChunkOfBytes: chuckSize.
	"first entity is an object to be free"
	object := next := memory initializeHeaderOfStartAddress: next numSlots: 5 format: memory arrayFormat classIndex: memory arrayClassIndexPun pinned: false.	
	next := memory objectAfter: next.
	"second entity is a free chunk with an overflow header"
	free := next := memory freeChunkWithBytes: chunk + chuckSize - next at: next.
	next := memory objectAfter: next.
	
	self assert: (memory isFreeObject: object) not.
	self assert: (memory isFreeObject: free).
		
	memory fullGC.

	self assert: (memory isFreeObject: object).
	self assert: (memory isFreeObject: free).
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSize [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace - (objectHeaderSize * 2) / memory wordSize.
	
	anObjectOop := self newOldSpaceObjectWithSlots: slotsNumber. "Big object have 2 wordSize of header"

	self assert: anObjectOop isNotNil
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSizeShouldBeZero [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace - (objectHeaderSize * 2) / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber. "Big object have 2 wordSize of header"
	
	self assert: memory totalFreeOldSpace equals: 0
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSizeShouldPlanifyGC [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber - 2. "Big object have 2 wordSize of header"
	
	self assert: memory needGCFlag
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateUnreferencedCycleShouldBeReclaimed [
	self assertObjectWereReclaimed: [
		| obj1 obj2 |
	
		obj1 := self newOldSpaceObjectWithSlots: 1.
		obj2 := self newOldSpaceObjectWithSlots: 1.
		memory storePointer: 0 ofObject: obj1 withValue: obj2.
		memory storePointer: 0 ofObject: obj2 withValue: obj1.
	]
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectNotReferencedShouldBeCollected [

	| oldFreeSpaceSize obj2 keptObjectSize |
	
	"The free objects are only reclaimed when there is a object after it. 
	For example if I have a free object and then only free space, the compactor assumes 
	that the heap is compacted, but it does not compact the free list. So the last free chunk is never 
	count on.
	This is a ""feature"" of the compactor. Changing the compactor strategy may change this behavior."
	
	memory fullGC.
	oldFreeSpaceSize := memory totalFreeListBytes.
	
	self newOldSpaceObjectWithSlots: 0.	
	obj2 := self newOldSpaceObjectWithSlots: 0.
	
	self keepObjectInVMVariable1: obj2.
	keptObjectSize := memory bytesInObject: obj2.
	
	memory fullGC.
	
	self assert: memory totalFreeListBytes equals: oldFreeSpaceSize - keptObjectSize.
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromVMVariableShouldBeKept [
	| anObjectOop |
	memory fullGC.
	
	anObjectOop := self newOldSpaceObjectWithSlots: 0.

	self keepObjectInVMVariable1: anObjectOop.
	
	memory fullGC.
	
	self deny: (memory isFreeObject: anObjectOop)
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromVMVariableShouldBeMoved [

	| anObjectOop hash |
	1 timesRepeat: [ self newOldSpaceObjectWithSlots: 0 ].
	
	anObjectOop := self newOldSpaceObjectWithSlots: 0.

	self keepObjectInVMVariable1: anObjectOop.
	hash := memory hashBitsOf: anObjectOop.
		
	memory fullGC.
	"after this point anObjectOop cannot be used anymore as it has been moved by the compacting phase.
	We have to use the hash instead."
	
	self deny: anObjectOop equals: self keptObjectInVMVariable1.
	self assertHashOf: self keptObjectInVMVariable1 equals: hash
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testDoubleForwardToYoungs [

		| obj1 obj2 obj3 arrFrom arrTo arrFrom2 arrTo2 |

		obj1 := self newObjectWithSlots: 1.
		obj2 := self newOldSpaceObjectWithSlots: 1.
		obj3 := self newOldSpaceObjectWithSlots: 1.

		arrFrom := self newArrayWithSlots: 1.
		arrTo := self newArrayWithSlots: 1.

		memory storePointer: 0 ofObject: arrFrom withValue: obj2.
		memory storePointer: 0 ofObject: arrTo withValue: obj1.
		memory become: arrFrom with: arrTo twoWay: false copyHash: false.
		"obj2 forwards to obj1, but since obj1 is newspace, obj2 is remembered"

		arrFrom2 := self newOldSpaceArrayWithSlots: 1.
		arrTo2 := self newOldSpaceArrayWithSlots: 1.
		memory storePointer: 0 ofObject: arrFrom2 withValue: obj3.
		memory storePointer: 0 ofObject: arrTo2 withValue: obj2.
		"Here, arrFrom2 & arrTo2 (oldspace) contains only oldspace."

		memory become: arrFrom2 with: arrTo2 twoWay: false copyHash: false.

		"We want arrFrom2 & arrTo2 points to obj1 and be remembered"
		self assert: (memory fetchPointer: 0 ofObject: arrFrom2) equals: obj1.
		self assert: (memory isRemembered: arrFrom2).
		self assert: (memory fetchPointer: 0 ofObject: arrTo2) equals: obj1.
		self assert: (memory isRemembered: arrTo2).
]

{ #category : #'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testDoNotCollectRoots [

	memory fullGC.
	
	self deny: (memory isFreeObject: (memory nilObject)).
	self deny: (memory isFreeObject: (memory trueObject)).
	self deny: (memory isFreeObject: (memory falseObject)).
	self deny: (memory isFreeObject: (memory freeListsObj)).
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testEphemeronOverflowUnscannedEphemeronQueue [

	"This test Fires more ephemerons than those that fit in a single page of the mourn queue.
	All ephemerons should be put in the mourn queue.
	The mourn queue should grow with new pages to make them all fit.
	Then we test we can extract all the objects from the queue"	

	| ephemeronKey ephemeronContainer mourned numberJustOverLimit |
	self createEphemeronClass.
	ephemeronKey := self newZeroSizedObject.
	ephemeronContainer := self newObjectWithSlots: 10.
	numberJustOverLimit := 10.
	1 to: numberJustOverLimit do: [ :i | | ephemeronObjectOop |
		ephemeronObjectOop := self newEphemeronObject.
		memory
			storePointer: 0 "zero based"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: i - 1 "zero based"
			ofObject: ephemeronContainer
			withValue: ephemeronObjectOop
	 ].
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronContainer.

	self assert: memory validObjStacks.
	memory unscannedEphemeronsQueueInitialSize: numberJustOverLimit - 1.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: numberJustOverLimit
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testGrowOldSpace [

	| freespace freespace2 slotsNumber anObjectOop |
	
	memory fullGC.
	
	freespace := memory totalFreeOldSpace.
	slotsNumber := freespace / memory wordSize.	
	memory growOldSpaceByAtLeast: slotsNumber.
	freespace2 := memory totalFreeOldSpace.
	self assert: freespace*2 <= freespace2.
	
	anObjectOop := self newObjectWithSlots: slotsNumber.
	self deny: anObjectOop equals: nil.
	self assert: freespace2 - (memory bytesInObject: anObjectOop) equals: memory totalFreeOldSpace.
	
	memory fullGC.
	self assert: freespace equals: memory totalFreeOldSpace.
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testMournQueue [

	| roots keyObj ephemeronObj |

	roots := self newArrayWithSlots: 1.
	self keepObjectInVMVariable1: roots.	

	keyObj := self newObjectWithSlots: 1.
	ephemeronObj := self newOldEphemeronObjectWithSlots: 1.
	memory storePointer: 0 ofObject: ephemeronObj withValue: keyObj.
	memory storePointer: 0 ofObject: roots withValue: ephemeronObj.

	memory fullGC.
	
	self assert: memory dequeueMourner equals: ephemeronObj.
	self assert: memory dequeueMourner equals: nil.
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testMournQueue2 [

	| roots keyObj ephemeronObj keyObj2 ephemeronObj2 |

	"This test covers a diferent path in the CG code than testMournQueue."

	roots := self newArrayWithSlots: 3.
	self keepObjectInVMVariable1: roots.	

	keyObj := self newObjectWithSlots: 1.
	ephemeronObj := self newOldEphemeronObjectWithSlots: 1.
	memory storePointer: 0 ofObject: ephemeronObj withValue: keyObj.
	memory storePointer: 0 ofObject: roots withValue: ephemeronObj.

	keyObj2 := self newObjectWithSlots: 1.
	ephemeronObj2 := self newOldEphemeronObjectWithSlots: 1.
	memory storePointer: 0 ofObject: ephemeronObj2 withValue: keyObj2.
	memory storePointer: 1 ofObject: roots withValue: keyObj2.
	memory storePointer: 2 ofObject: roots withValue: ephemeronObj2.

	memory fullGC.
	
	self assert: memory dequeueMourner equals: ephemeronObj.
	self assert: memory dequeueMourner equals: nil.
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testEphemeronDiscoverKey [

	| roots ephemeron1 ephemeron2 ephemeron3 key1 key2 key3 |

	"roots: E1 E2 K2
	 E1 key: K1
	 E2 Key: K2 value: K1.
	 E3 key: K3.
	
	We assume the the scaning order E1 E2 E3 K2.
	* E1 is marked but not scanned since K1 is not marked, E1 instead is put on unscannedEphemerons for future processing.
	* Same for E2 because K2 is not marked.
	* Same for E3 because K3 is not marked.
	* K2 is then marked.
	Then
	* E1 remains on unscannedEphemerons because K1 is still unmarked.
	* E2 is removed from unscannedEphemerons because K2 is marked. This triggers a scan on E2, that marks K1.
	* E3 remains on unscannedEphemerons because K3 is still unmarked.
	Then
	* E1 is removed from unscannedEphemerons because K1 is marked. This triggers a scan on E1, that does nothing here.
	* E3 remains on unscannedEphemerons because K3 is still unmarked.
	Then
	* E3 remains on unscannedEphemerons because K3 is still unmarked.
	Then
	* E3 is fired, removed from unscannedEphemerons, and scanned (that does nothing here).
	Then
	* unscannedEphemerons is empty, we leave
	"

	"Note: roots are stored in reverse order because slots are scanned from the last one to the first one"
	roots := self newOldSpaceArrayWithSlots: 4. "K2 E3 E2 E1"
	self keepObjectInVMVariable1: roots.

	ephemeron1 := self newOldEphemeronObjectWithSlots: 1. "K1"
	memory storePointer: 3 ofObject: roots withValue: ephemeron1.

	key1 := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: ephemeron1 withValue: key1.

	ephemeron2 := self newOldEphemeronObjectWithSlots: 2. "K2 K1"
	memory storePointer: 2 ofObject: roots withValue: ephemeron2.

	key2 := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: roots withValue: key2.
	memory storePointer: 0 ofObject: ephemeron2 withValue: key2.
	memory storePointer: 1 ofObject: ephemeron2 withValue: key1.

	ephemeron3 := self newOldEphemeronObjectWithSlots: 1. "K3"
	memory storePointer: 1 ofObject: roots withValue: ephemeron3.

	key3 := self newOldSpaceObjectWithSlots: 0.
	memory storePointer: 0 ofObject: ephemeron3 withValue: key3.
	
	memory setCheckForLeaks: 63 "all".
	memory fullGC.
	
	self assert: memory coInterpreter pendingFinalizationSignals equals: 1.
	self assert: memory dequeueMourner equals: ephemeron3.
	self assert: memory dequeueMourner equals: nil.

]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testMultiPageMournQueue [

	"This test Fires more ephemerons than those that fit in a single page of the mourn queue.
	All ephemerons should be put in the mourn queue.
	The mourn queue should grow with new pages to make them all fit.
	Then we test we can extract all the objects from the queue"	

	| ephemeronKey ephemeronContainer mourned numberJustOverLimit |
	self createEphemeronClass.
	numberJustOverLimit := objectStackLimit + 1.

	ephemeronKey := self newZeroSizedObject.
	ephemeronContainer := self newArrayWithSlots: numberJustOverLimit.
	1 to: numberJustOverLimit do: [ :i | | ephemeronObjectOop |
		ephemeronObjectOop := self newEphemeronObject.
		memory
			storePointer: 0 "zero based"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: i - 1 "zero based"
			ofObject: ephemeronContainer
			withValue: ephemeronObjectOop
	 ].
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronContainer.

	self assert: memory validObjStacks.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: numberJustOverLimit
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testNewRootEphemeronHoldsAnotherEphemeronAsKeyThenFullGC [

	| ephemeron1 ephemeron2 |

	ephemeron1 := self newEphemeronObjectWithSlots: 5.
	self keepObjectInVMVariable1: ephemeron1.
	ephemeron2 := self newEphemeronObjectWithSlots: 3.
	self keepObjectInVMVariable2: ephemeron2.
	memory storePointer: 0 ofObject: ephemeron1 withValue: ephemeron2.
	
	memory setCheckForLeaks: 63 "all".
	memory fullGC
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testNewRootEphemeronHoldsOldNonRootEphemeronAsNonKeyThenFullGC [

	| ephemeron1 ephemeron2 |

	ephemeron1 := self newEphemeronObjectWithSlots: 17.
	self keepObjectInVMVariable1: ephemeron1.
	ephemeron2 := self newOldEphemeronObjectWithSlots: 7.
	memory storePointer: 1 "Not the key" ofObject: ephemeron1 withValue: ephemeron2.
	
	memory setCheckForLeaks: 63 "all".
	memory fullGC
]

{ #category : #tests }
VMSpurOldSpaceGarbageCollectorTest >> testNewRootEphemeronIsHeldsByOldNonRootEphemeronAsNonKeyThenFullGC [

	| ephemeron1 ephemeron2 |

	ephemeron1 := self newEphemeronObjectWithSlots: 6.
	self keepObjectInVMVariable1: ephemeron1.
	memory fullGC.
	ephemeron1 := self keptObjectInVMVariable1.
	
	ephemeron2 := self newOldEphemeronObjectWithSlots: 15.
	memory storePointer: 10 "Not the key" ofObject: ephemeron2 withValue: ephemeron1.
	
	memory setCheckForLeaks: 63 "all".
	memory fullGC
]

{ #category : #ephemerons }
VMSpurOldSpaceGarbageCollectorTest >> testPageLimitMournQueue [

	"This test Fires more ephemerons than those that fit in a single page of the mourn queue.
	All ephemerons should be put in the mourn queue.
	The mourn queue should grow with new pages to make them all fit.
	Then we test we can extract all the objects from the queue"	

	| ephemeronKey ephemeronContainer mourned objStackLimit numberJustBelowLimit |
	self createEphemeronClass.
	numberJustBelowLimit := objectStackLimit - 1.
	
	ephemeronKey := self newZeroSizedObject.
	ephemeronContainer := self newArrayWithSlots: numberJustBelowLimit.
	objStackLimit := numberJustBelowLimit.
	1 to: objStackLimit do: [ :i | | ephemeronObjectOop |
		ephemeronObjectOop := self newEphemeronObject.
		memory
			storePointer: 0 "zero based"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: i - 1 "zero based"
			ofObject: ephemeronContainer
			withValue: ephemeronObjectOop
	 ].
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronContainer.

	self assert: memory validObjStacks.
	memory compactor recordMovements.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: objStackLimit
]
