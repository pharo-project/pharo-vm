Class {
	#name : #VMPermanentSpaceTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#instVars : [
		'byteArrayClassIndex'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #running }
VMPermanentSpaceTest >> configureEnvironmentBuilder [ 

	super configureEnvironmentBuilder.
	
	environmentBuilder permSpaceSize: 10*1024*1024.
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> newPermanentByteObjectOfSize: byteSize [
	
	| oop numSlots instSpec |

	numSlots := memory numSlotsForBytes: byteSize.
	instSpec := memory byteFormatForNumBytes: byteSize.
	
	oop := memory
			allocateSlotsInPermSpace: numSlots
			format: instSpec
			classIndex: byteArrayClassIndex.

	0 to: byteSize - 1 do: [ :index | 
		memory storeByte: index ofObject: oop withValue: 	0 ].

	^ oop
]

{ #category : #running }
VMPermanentSpaceTest >> setUp [

	super setUp.

	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	byteArrayClassIndex := memory ensureBehaviorHash: memory classByteArray.

	


	
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testMarkingNewSpaceDoesNotMarkPermSpace [

	| permanentObject newObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	newObject := self newObjectWithSlots: 1.
	self keepObjectInVMVariable1: newObject.
	
	self assert: (memory isYoungObject: newObject).

	memory storePointer: 0 ofObject: newObject withValue: permanentObject.

	memory doScavenge: 1 "TenureByAge".

	self deny: (memory isMarked: permanentObject)
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testMarkingOldSpaceDoesNotMarkPermSpace [

	| permanentObject oldObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	oldObject := self newOldSpaceObjectWithSlots: 1.
	self keepObjectInVMVariable1: oldObject.
	
	self assert: (memory isOldObject: oldObject).

	memory storePointer: 0 ofObject: oldObject withValue: permanentObject.

	memory fullGC.

	self deny: (memory isMarked: permanentObject)
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testNewPermanentByteArrayIsCorrectlyAllocated [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self assert: permanentObject equals: memory getMemoryMap permSpaceStart
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testNewPermanentByteArrayIsNonYoungObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self deny: (memory isYoungObject: permanentObject)
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testNewPermanentByteArrayIsNotAnOldObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self deny: (memory isOldObject: permanentObject)
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testNewPermanentByteArrayIsPermanentObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self assert: (memory isPermanentObject: permanentObject)
]

{ #category : #'instance creation' }
VMPermanentSpaceTest >> testNextObjectIsReturningAGoodValue [

	| permanentObject nextObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	nextObject := memory objectAfter: permanentObject.

	self assert: nextObject equals: memory permSpaceFreeStart
	
]
