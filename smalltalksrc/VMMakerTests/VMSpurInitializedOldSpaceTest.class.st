Class {
	#name : #VMSpurInitializedOldSpaceTest,
	#superclass : #VMSpurMemoryManagerTest,
	#instVars : [
		'ourEphemeronClass'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #testing }
VMSpurInitializedOldSpaceTest class >> isAbstract [

	^ self == VMSpurInitializedOldSpaceTest
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> assertFreeListEmpty: aFreeListOop [

	self assert: aFreeListOop equals: 0
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> createEphemeronClass [
	ourEphemeronClass := self newObjectWithSlots: 3.
	memory 
		storePointer: "InstanceSpecificationIndex" 2
		ofObject: ourEphemeronClass
		withValue: (memory integerObjectOf: Ephemeron format).
	memory ensureBehaviorHash: ourEphemeronClass.
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> createFreeChunkOfSize: aSize [

	| address |
	address := memory allocateOldSpaceChunkOfBytes: aSize.
	memory freeChunkWithBytes: aSize at: address.
	^ address
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> denyFreeListEmpty: aFreeListOop [

	self deny: aFreeListOop equals: 0
]

{ #category : #tests }
VMSpurInitializedOldSpaceTest >> forgetObject3 [
	memory coInterpreter profileMethod: memory nilObject
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> freeListForSize: allocationSize [
	
	^ memory freeLists at: allocationSize / memory allocationUnit
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> freeTreeRootOop [

	"Initially the old space has a single big chunk of free memory and no small free chunks.
	So
	 - the free lists are empty
	 - the single big chunk of memory is the root of the free tree
	
	The root of the free tree has no child nodes"

	^ memory freeLists at: 0
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> freeTreeRootStartAddress [

	"The free tree lists stores the oop of free tree nodes.
	That means that the address stored references the beginning of the base header of the tree node.
	This is important because tree nodes can be large objects and have more than one header.
	
	We use #startOfObject: to return invariably the address where the node starts"
	^ memory startOfObject: self freeTreeRootOop
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> largerNodeOf: aNode [

	^ memory
		fetchPointer: memory freeChunkLargerIndex
		ofFreeChunk: aNode
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> newEphemeronObject [

"In pharo Ephemerons have 3 slots"
	
	^ self
		newObjectWithSlots: 3
		format: memory ephemeronFormat
		classIndex: (memory ensureBehaviorHash: ourEphemeronClass)
]

{ #category : #'instance creation' }
VMSpurInitializedOldSpaceTest >> newPermanentByteObjectOfSize: byteSize [
	
	| oop numSlots instSpec |

	numSlots := memory numSlotsForBytes: byteSize.
	instSpec := memory byteFormatForNumBytes: byteSize.
	
	oop := memory
			allocateSlotsInPermSpace: numSlots
			format: instSpec
			classIndex: (memory ensureBehaviorHash: memory classByteArray).

	0 to: byteSize - 1 do: [ :index | 
		memory storeByte: index ofObject: oop withValue: 	0 ].

	^ oop
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> nextNodeOf: aNode [

	^ memory
		fetchPointer: memory freeChunkNextIndex
		ofFreeChunk: aNode
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> parentNodeOf: aNode [

	^ memory
		fetchPointer: memory freeChunkParentIndex
		ofFreeChunk: aNode
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> previousNodeOf: aNode [

	^ memory
		fetchPointer: memory freeChunkPrevIndex
		ofFreeChunk: aNode
]

{ #category : #running }
VMSpurInitializedOldSpaceTest >> setUp [

	super setUp.
	self initializeOldSpaceForScavenger.
	self initializeOldSpaceForFullGC.
	memory lastHash: 1.
	memory classByteArray: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0)).
	memory setPermSpaceDirty: false.
]

{ #category : #helpers }
VMSpurInitializedOldSpaceTest >> smallerNodeOf: aNode [

	^ memory
		fetchPointer: memory freeChunkSmallerIndex
		ofFreeChunk: aNode
]
