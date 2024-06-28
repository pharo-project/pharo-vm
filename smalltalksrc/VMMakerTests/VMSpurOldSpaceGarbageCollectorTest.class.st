Class {
	#name : 'VMSpurOldSpaceGarbageCollectorTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#instVars : [
		'objectStackLimit'
	],
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'assertion' }
VMSpurOldSpaceGarbageCollectorTest >> assertHashOf: anOop equals: aHash [ 
	self assert: (memory hashBitsOf: anOop) equals: aHash
]

{ #category : 'helpers' }
VMSpurOldSpaceGarbageCollectorTest >> deltaFreeSpaceAfterGC: aBlock [ 
	| initialSpace lastObjectToBeRemembered sizeOfLastObject |
	"The planning compactor frees object by sliding, and therefore does not reclaim memory if there is only dead objects in the oldspace."
	"The free objects are only reclaimed when there is a object after it."
	"We allocate objects during the setup"
	memory fullGC. 
	
	initialSpace := memory totalFreeListBytes.
	
	aBlock value.
	
	lastObjectToBeRemembered := self newOldSpaceObjectWithSlots: 0.
	self keepObjectInVMVariable1: lastObjectToBeRemembered.
	sizeOfLastObject := memory bytesInObject: lastObjectToBeRemembered.
	
	memory fullGC.
	
	^ initialSpace - sizeOfLastObject - memory totalFreeListBytes
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> initializationOptions [

	^ super initializationOptions , { 
		#ObjStackPageSlots . objectStackLimit }
]

{ #category : 'testing' }
VMSpurOldSpaceGarbageCollectorTest >> isValidFirstBridge [

	^ memory segmentManager
		isValidSegmentBridge: (memory segmentManager bridgeAt: 0)
]

{ #category : 'running' }
VMSpurOldSpaceGarbageCollectorTest >> runCaseManaged [ 

	^ self runCase
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> setUp [

	objectStackLimit :=  10.
	super setUp.
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectBiggerThanSizeOfFreeSpace [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber.

	self assert: anObjectOop isNil
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectBiggerThanSizeOfFreeSpaceShouldPlanifyGC [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber.

	self assert: memory needGCFlag
]

{ #category : 'testCompactor' }
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

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSize [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace - (self objectHeaderSize * 2) / memory wordSize.
	
	anObjectOop := self newOldSpaceObjectWithSlots: slotsNumber. "Big object have 2 wordSize of header"

	self assert: anObjectOop isNotNil
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSizeShouldBeZero [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace - (self objectHeaderSize * 2) / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber. "Big object have 2 wordSize of header"
	
	self assert: memory totalFreeOldSpace equals: 0
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAllocateObjectWithFreeSpaceSizeShouldPlanifyGC [

	| anObjectOop slotsNumber |
	slotsNumber := memory totalFreeOldSpace / memory wordSize.
	
	anObjectOop := self newObjectWithSlots: slotsNumber - 2. "Big object have 2 wordSize of header"
	
	self assert: memory needGCFlag
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectNotReferencedShouldBeCollected [

	| deltaFreeSpace |
	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ 
		              self newOldSpaceObjectWithSlots: 0 ].

	self assert: deltaFreeSpace equals: 0
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromNewObjectShouldBeCollected [

	| deltaFreeSpace |
	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ 
		              | oldObj newObj |
		              oldObj := self newOldSpaceObjectWithSlots: 0.
		              newObj := self newObjectWithSlots: 1.
		              memory storePointer: 0 ofObject: newObj withValue: oldObj ].

	self assert: deltaFreeSpace equals: 0
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromRememberedPermObjectShouldBeKept [

	| oldObjectSize deltaFreeSpace |
	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ | permOop oldOop |
		                  permOop := self newPermanentObjectWithSlots: 1.
		                  oldOop := self newOldSpaceObjectWithSlots: 0.
		                  oldObjectSize := memory bytesInObject: oldOop.
		                  memory storePointer: 0 ofObject: permOop withValue: oldOop ].

	self assert: deltaFreeSpace equals: oldObjectSize
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromUnreferencedCycleObjectShouldBeCollected [

	| deltaFreeSpace |
	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ 
		              | obj1 obj2 |
		              obj1 := self newOldSpaceObjectWithSlots: 1.
		              obj2 := self newOldSpaceObjectWithSlots: 1.
		              memory storePointer: 0 ofObject: obj1 withValue: obj2.
		              memory storePointer: 0 ofObject: obj2 withValue: obj1 ].

	self assert: deltaFreeSpace equals: 0
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testAnOldObjectReferencedFromVMVariableShouldBeKept [

	| oldOop objectSize deltaFreeSpace |
	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ 
		                  oldOop := self newOldSpaceObjectWithSlots: 0.
		                  objectSize := memory bytesInObject: oldOop.
		                  self keepObjectInVMVariable2: oldOop ].


	self deny: (memory isFreeObject: oldOop).
	self assert: deltaFreeSpace equals: objectSize
]

{ #category : 'tests-OldSpaceSize' }
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

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testArrayOfPermanentObjectsPointingToOldObjectsIsCorrectlyMantained [

	| deltaFreeSpace arrayOfPerms objectsSize aPermObject anOldObject originalRememberedSetSize afteRememberedSetSize numberOfObjects originalNewRememberedSetSize afteNewRememberedSetSize |

	originalRememberedSetSize := memory bytesInObject: memory getFromPermToOldSpaceRememberedSet objectOop. 
	originalNewRememberedSetSize := memory bytesInObject: memory getFromPermToNewSpaceRememberedSet objectOop. 

	numberOfObjects := 4096.

	deltaFreeSpace := self deltaFreeSpaceAfterGC: [ 
								arrayOfPerms := self newOldSpaceArrayWithSlots: numberOfObjects.
								objectsSize := memory bytesInObject: arrayOfPerms.
								0 to: numberOfObjects - 1 do: [ :i |
									anOldObject := self newOldSpaceObjectWithSlots: 0.
									aPermObject := self newPermanentObjectWithSlots: 1.
									objectsSize := objectsSize + (memory bytesInObject: anOldObject).
									memory storePointer: 0 ofObject: aPermObject withValue: anOldObject.
									memory storePointer: i ofObject: arrayOfPerms withValue: aPermObject ].
		                  self keepObjectInVMVariable2: arrayOfPerms ].

	afteRememberedSetSize := memory bytesInObject: memory getFromPermToOldSpaceRememberedSet objectOop.
	afteNewRememberedSetSize := memory bytesInObject: memory getFromPermToNewSpaceRememberedSet objectOop.

	self assert: deltaFreeSpace equals: objectsSize + (afteRememberedSetSize - originalRememberedSetSize) + (afteNewRememberedSetSize - originalNewRememberedSetSize)
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testArrayOfPermanentObjectsPointingToOldObjectsIsCorrectlyMantainedWhenObjectsMoved [

	| numberOfObjects originalHashes permArray anOldObject |
	numberOfObjects := 4096.
	originalHashes := Array new: numberOfObjects.

	self deltaFreeSpaceAfterGC: [ 
		permArray := self newPermanentObjectWithSlots: numberOfObjects.

		"Objects to be collected"
		self newOldSpaceObjectWithSlots: 0.
		self newOldSpaceObjectWithSlots: 0.

		1 to: numberOfObjects do: [ :i |
			anOldObject := self newOldSpaceObjectWithSlots: 0.
			originalHashes at: i put: (memory hashBitsOf: anOldObject). 
			memory storePointer: (i - 1) ofObject: permArray withValue: anOldObject ]].

	1 to: numberOfObjects do: [ :i |
		self assert: (originalHashes at: i) equals: (memory hashBitsOf: (memory fetchPointer: i - 1 ofObject: permArray))]
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> testChainOfFirableEphemerons [

	"This test creates a set of ephemerons on the old space that should be fired because their key is not referenced.
	However, the only strong reference to an ephemeron is in another ephemeron.
	Since all ephemerons depend on different keys, all should be fired at the same time."

	| mourned previousEphemeron ephemerons |
	self createEphemeronClass.
	previousEphemeron := memory nilObject.
	ephemerons := 3.
	1 to: ephemerons do: [ :i | | ephemeronKey ephemeronObjectOop |
		ephemeronKey := self newZeroSizedObject.
		"An ephemeron with 3 slots"
		ephemeronObjectOop := self newOldEphemeronObject.
		memory
			storePointer: 0 "key"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: 1 "value"
			ofObject: ephemeronObjectOop
			withValue: previousEphemeron.
		previousEphemeron := ephemeronObjectOop.
	].
	
	"Force the first ephemeron in the chain to not be collected by putting it in an intepreter register"
	self keepObjectInVMVariable1: previousEphemeron.

	self assert: memory validObjStacks.
	memory unscannedEphemeronsQueueInitialSize: ephemerons.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: ephemerons
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> testChainOfFirableEphemeronsWithNonFirableHead [

	"This test creates a set of ephemerons on the old space that should be fired because their key is not referenced.
	The only strong reference to an ephemeron is in another ephemeron.
	
	However, the head of the list is an ephemeron with a referenced key!
	Since all other ephemerons depend on different keys, all should be fired at the same time."

	| mourned previousEphemeron nonFirableEphemeron |
	self createEphemeronClass.
	previousEphemeron := memory nilObject.
	1 to: 5 do: [ :i | | ephemeronKey ephemeronObjectOop |
		ephemeronKey := self newZeroSizedObject.
		ephemeronObjectOop := self newOldEphemeronObject.
		memory
			storePointer: 0 "key"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: 1 "value"
			ofObject: ephemeronObjectOop
			withValue: previousEphemeron.
		previousEphemeron := ephemeronObjectOop.
	].

	nonFirableEphemeron := self newOldEphemeronObject.
	memory
			storePointer: 0 "key"
			ofObject: nonFirableEphemeron
			withValue: memory nilObject.
		memory
			storePointer: 1 "value"
			ofObject: nonFirableEphemeron
			withValue: previousEphemeron.
	
	"Force the first ephemeron in the chain to not be collected by putting it in an intepreter register"
	self keepObjectInVMVariable1: nonFirableEphemeron.

	self assert: memory validObjStacks.
	memory unscannedEphemeronsQueueInitialSize: 5.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: 5
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> testChainOfFirableEphemeronsWithOldKeys [

	"This test creates a set of ephemerons on the old space that should be fired because their key is not referenced.
	However, the only strong reference to an ephemeron is in another ephemeron.
	Since all ephemerons depend on different keys, all should be fired at the same time."

	| mourned previousEphemeron ephemerons |
	self createEphemeronClass.
	previousEphemeron := memory nilObject.
	ephemerons := 3.
	1 to: ephemerons do: [ :i | | ephemeronKey ephemeronObjectOop |
		ephemeronKey := self newOldSpaceObjectWithSlots: 0.
		"An ephemeron with 3 slots"
		ephemeronObjectOop := self newOldEphemeronObject.
		memory
			storePointer: 0 "key"
			ofObject: ephemeronObjectOop
			withValue: ephemeronKey.
		memory
			storePointer: 1 "value"
			ofObject: ephemeronObjectOop
			withValue: previousEphemeron.
		previousEphemeron := ephemeronObjectOop.
	].
	
	"Force the first ephemeron in the chain to not be collected by putting it in an intepreter register"
	self keepObjectInVMVariable1: previousEphemeron.

	self assert: memory validObjStacks.
	memory unscannedEphemeronsQueueInitialSize: ephemerons.
	memory fullGC.

	mourned := 0.
	[ memory dequeueMourner notNil ] whileTrue: [ mourned := mourned + 1 ].
	self
		assert: mourned
		equals: ephemerons
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> testCompactEphemeronQueuePass1 [

	| ephemeron |

	"Hole, then mourn queue"
	self newOldSpaceObjectWithSlots: 0.
	memory initializeMournQueue.

	"Hole, then ephemeron. Does not really need to be an ephemeron for this tests, any object does it"
	self newOldSpaceObjectWithSlots: 0.	
	ephemeron := self newOldSpaceObjectWithSlots: 0.
	self keepObjectInVMVariable1: ephemeron.
	memory push: ephemeron onObjStack: memory mournQueue.

	"Compact in one pass"
	memory garbageCollectForSnapshot.
	
	self assert: (memory sizeOfObjStack: memory mournQueue) equals: 1.
	self assert: memory dequeueMourner equals: self keptObjectInVMVariable1.
]

{ #category : 'ephemerons' }
VMSpurOldSpaceGarbageCollectorTest >> testCompactEphemeronQueuePass2 [

	| ephemeron |

	"For first compaction pass"
	"Hole, then mourn queue"
	self newOldSpaceObjectWithSlots: 0.
	memory initializeMournQueue.

	"For second compaction pass"
	"Hole, then ephemeron. Does not really need to be an ephemeron for this tests, any object does it"
	self newOldSpaceObjectWithSlots: 0.	
	ephemeron := self newOldSpaceObjectWithSlots: 0.
	self keepObjectInVMVariable1: ephemeron.
	memory push: ephemeron onObjStack: memory mournQueue.

	"Set the number of objects to compact per compact Phase.
	We set N=1 to make two compaction phases.
	The first phase will compact the mourn queue.
	The second phase will compact the ephemeron."
	memory compactor savedFirstFieldSpaceMaxSlots: 1.
	
	"Compact"
	memory garbageCollectForSnapshot.
	
	self assert: (memory sizeOfObjStack: memory mournQueue) equals: 1.
	self assert: memory dequeueMourner equals: self keptObjectInVMVariable1.
]

{ #category : 'tests-OldSpaceSize' }
VMSpurOldSpaceGarbageCollectorTest >> testDoNotCollectRoots [

	memory fullGC.
	
	self deny: (memory isFreeObject: (memory nilObject)).
	self deny: (memory isFreeObject: (memory trueObject)).
	self deny: (memory isFreeObject: (memory falseObject)).
	self deny: (memory isFreeObject: (memory freeListsObj)).
]

{ #category : 'tests-OldSpaceSize' }
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

{ #category : 'ephemerons' }
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

{ #category : 'ephemerons' }
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

{ #category : 'tests' }
VMSpurOldSpaceGarbageCollectorTest >> testEphemeronWithImmediateKeyShouldNotFail [

	| ephemeron1 key |
	ephemeron1 := self newEphemeronObjectWithSlots: 5.
	self keepObjectInVMVariable1: ephemeron1.
	key := memory integerObjectOf: 15.
	memory storePointer: 0 ofObject: ephemeron1 withValue: key.

	memory setCheckForLeaks: 63. "all"
	memory fullGC.

	self
		assert:
		(memory fetchInteger: 0 ofObject: self keptObjectInVMVariable1)
		equals: 15
]

{ #category : 'tests' }
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

{ #category : 'ephemerons' }
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

{ #category : 'ephemerons' }
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

{ #category : 'ephemerons' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
VMSpurOldSpaceGarbageCollectorTest >> testNewRootEphemeronHoldsOldNonRootEphemeronAsNonKeyThenFullGC [

	| ephemeron1 ephemeron2 |

	ephemeron1 := self newEphemeronObjectWithSlots: 17.
	self keepObjectInVMVariable1: ephemeron1.
	ephemeron2 := self newOldEphemeronObjectWithSlots: 7.
	memory storePointer: 1 "Not the key" ofObject: ephemeron1 withValue: ephemeron2.
	
	memory setCheckForLeaks: 63 "all".
	memory fullGC
]

{ #category : 'tests' }
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

{ #category : 'ephemerons' }
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
