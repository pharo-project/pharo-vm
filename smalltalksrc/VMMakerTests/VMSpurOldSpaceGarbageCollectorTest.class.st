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
