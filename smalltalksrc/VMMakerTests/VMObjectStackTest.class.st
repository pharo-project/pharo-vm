Class {
	#name : #VMObjectStackTest,
	#superclass : #VMSpurInitializedOldSpaceTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #tests }
VMObjectStackTest >> testGrowingMournQueueUpdatesVMGlobalVariable [

	
	self testPushObjects: memory objectStackPageLimit + 1 inStackAtIndex: 4098"MournQueueRootIndex".
	self assert: memory mournQueue equals: (memory objStackAt: 4098"MournQueueRootIndex")
]

{ #category : #tests }
VMObjectStackTest >> testNewMournQueueIsEmpty [

	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4098 "MournQueueIndex".

	self assert: (memory isEmptyObjStack: objStack)
	
]

{ #category : #tests }
VMObjectStackTest >> testNewObjectStackIsEmpty [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4096.

	self assert: (memory isEmptyObjStack: objStack)
	
]

{ #category : #tests }
VMObjectStackTest >> testObjectsInMournQueueArePoppedInOrder [

	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4098 "MournQueueIndex".
	1 to: memory objectStackPageLimit do: [ :i |
		memory noCheckPush: (memory integerObjectOf: i) onObjStack: objStack.
	].
	memory objectStackPageLimit to: 1 by: -1 do: [ :i |
		self assert: (memory popObjStack: objStack) equals: (memory integerObjectOf: i).
	].
]

{ #category : #tests }
VMObjectStackTest >> testObjectsInObjectStackArePoppedInOrder [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4096.
	1 to: memory objectStackPageLimit do: [ :i |
		memory noCheckPush: (memory integerObjectOf: i) onObjStack: objStack.
	].
	memory objectStackPageLimit to: 1 by: -1 do: [ :i |
		self assert: (memory popObjStack: objStack) equals: (memory integerObjectOf: i).
	].
]

{ #category : #tests }
VMObjectStackTest >> testPopMournQueueReducesSize [

	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4098 "MournQueueIndex".
	memory noCheckPush: memory trueObject onObjStack: objStack.
	memory popObjStack: objStack.
	self assert: (memory isEmptyObjStack: objStack)
]

{ #category : #tests }
VMObjectStackTest >> testPopObjectInMournQueueReturnsInitiallyPushedObject [

	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4098 "MournQueueIndex".
	memory noCheckPush: memory trueObject onObjStack: objStack.
	self assert: (memory popObjStack: objStack) equals: memory trueObject
]

{ #category : #tests }
VMObjectStackTest >> testPopObjectInStackReturnsInitiallyPushedObject [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4096.
	memory noCheckPush: memory trueObject onObjStack: objStack.
	self assert: (memory popObjStack: objStack) equals: memory trueObject
]

{ #category : #tests }
VMObjectStackTest >> testPopObjectStackReducesSize [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4096.
	memory noCheckPush: memory trueObject onObjStack: objStack.
	memory popObjStack: objStack.
	self assert: (memory isEmptyObjStack: objStack)
]

{ #category : #tests }
VMObjectStackTest >> testPushObjects: n [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	self testPushObjects: n inStackAtIndex: 4096
]

{ #category : #tests }
VMObjectStackTest >> testPushObjects: n inStackAtIndex: objectStackIndex [

	memory ensureRoomOnObjStackAt: objectStackIndex.
	1 to: n do: [ :i |
		memory
			noCheckPush: (memory integerObjectOf: i)
			onObjStack: (memory objStackAt: objectStackIndex).
	].
	self assert: (memory sizeOfObjStack: (memory objStackAt: objectStackIndex)) equals: n
]

{ #category : #tests }
VMObjectStackTest >> testPushObjectsAboveObjectStackLimit [

	self testPushObjects: memory objectStackPageLimit + 1
]

{ #category : #tests }
VMObjectStackTest >> testPushObjectsToObjectStackLimit [

	self testPushObjects: memory objectStackPageLimit
]

{ #category : #tests }
VMObjectStackTest >> testPushToMournQueueIncreasesSize [

	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4098 "MournQueueIndex".
	memory noCheckPush: memory trueObject onObjStack: objStack.
	self assert: (memory sizeOfObjStack: objStack) equals: 1
]

{ #category : #tests }
VMObjectStackTest >> testPushToObjectStackIncreasesSize [

	"Create an object stack at the position of the mark stack in the class table (4096)"
	| objStack |
	objStack := memory ensureRoomOnObjStackAt: 4096.
	memory noCheckPush: memory trueObject onObjStack: objStack.
	self assert: (memory sizeOfObjStack: objStack) equals: 1
]
