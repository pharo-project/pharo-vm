Class {
	#name : 'VMSpurEphemeronsAlgorithmTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#instVars : [
		'ephemeronObjectOopOne',
		'ephemeronObjectOopTwo',
		'nonEphemeronObjectOopOne',
		'nonEphemeronObjectOopTwo'
	],
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'helper' }
VMSpurEphemeronsAlgorithmTest >> addKeysToEphemerons [

	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.

	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopTwo
]

{ #category : 'helper' }
VMSpurEphemeronsAlgorithmTest >> keepEphemeronsInVMVariables [
	"Force ephemerons to not be collected by putting them in special variables"

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo
]

{ #category : 'helper' }
VMSpurEphemeronsAlgorithmTest >> newEphemeronObjectOldSpace [
	"In pharo Ephemerons have 3 slots"

	^ self newOldSpaceObjectWithSlots: 3
		  format: memory ephemeronFormat
		  classIndex: (memory ensureBehaviorHash: ourEphemeronClass)
]

{ #category : 'running' }
VMSpurEphemeronsAlgorithmTest >> setUp [

	super setUp.
	memory initializeMournQueue.
	self createEphemeronClass
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsOldObjectsOld [

	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 1.
	nonEphemeronObjectOopTwo := self newOldSpaceObjectWithSlots: 0.
	"Make object 1 reference object 2"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopOne withValue: nonEphemeronObjectOopTwo. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory fullGC.

	"ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo."
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsOldObjectsOldInverse [

	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 0.
	nonEphemeronObjectOopTwo := self newOldSpaceObjectWithSlots: 1.
	"Make object 2 reference object 1"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopTwo withValue: nonEphemeronObjectOopOne. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.

	"Collect both non ephemeron objects"
	memory fullGC.

	"ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo."
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsOldObjectsYoung [
	
	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newObjectWithSlots: 1.
	nonEphemeronObjectOopTwo := self newZeroSizedObject.
	"Make object 1 reference object 2"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopOne withValue: nonEphemeronObjectOopTwo. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory doScavenge:1 "Tenured by age".
	memory fullGC.

	"ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo."
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsOldObjectsYoungInverse [

	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newZeroSizedObject.
	nonEphemeronObjectOopTwo := self newObjectWithSlots: 1.
	"Make object 2 reference object 1"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopTwo withValue: nonEphemeronObjectOopOne. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory doScavenge:1 "Tenured by age".
	memory fullGC.

	"ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo."
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - ephemerons with same key' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsWithSameKeyNewSpace [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newZeroSizedObject.

	"Both ephemerons share the same key"
	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.
	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopOne.

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo.

	"Collect non ephemeoron objetc"
	memory doScavenge: 1.

	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner).
	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner)
]

{ #category : 'tests - ephemerons with same key' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsWithSameKeyNewSpaceFlush [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newZeroSizedObject.

	"Both ephemerons share the same key"
	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.
	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopOne.

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo.

	"Collect both non ephemeron objects"
	memory flushNewSpace.

	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner).
	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner)
]

{ #category : 'tests - ephemerons with same key' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsWithSameKeyNewSpaceOldSpace [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 0.

	"Both ephemerons share the same key"
	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.
	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopOne.

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo.

	"Collect non ephemeron object"
	memory fullGC.

	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner).
	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner)
]

{ #category : 'tests - ephemerons with same key' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsWithSameKeyOldSpace [

	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 0.

	"Both ephemerons share the same key"
	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.
	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopOne.

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo.

	"Collect ephemerons"
	memory fullGC.

	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner).
	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner)
]

{ #category : 'tests - ephemerons with same key' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsWithSameKeyOldSpaceNewSpace [

	ephemeronObjectOopOne := self newEphemeronObjectOldSpace.
	ephemeronObjectOopTwo := self newEphemeronObjectOldSpace.
	nonEphemeronObjectOopOne := self newZeroSizedObject.

	"Both ephemerons share the same key"
	memory storePointer: 0
		ofObject: ephemeronObjectOopOne
		withValue: nonEphemeronObjectOopOne.
	memory storePointer: 0
		ofObject: ephemeronObjectOopTwo
		withValue: nonEphemeronObjectOopOne.

	self keepObjectInVMVariable1: ephemeronObjectOopOne.
	self keepObjectInVMVariable2: ephemeronObjectOopTwo.

	"Collect ephemerons"
	memory fullGC.

	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner).
	self assert: ({ ephemeronObjectOopOne. ephemeronObjectOopTwo } includes: memory dequeueMourner)
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsYoungObjectsOld [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 1.
	nonEphemeronObjectOopTwo := self newOldSpaceObjectWithSlots: 0.
	"Make object 1 reference object 2"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopOne withValue: nonEphemeronObjectOopTwo. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory doScavenge:1 "Tenured by age".
	memory fullGC.

	ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo.
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsYoungObjectsOldInverse [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newOldSpaceObjectWithSlots: 0.
	nonEphemeronObjectOopTwo := self newOldSpaceObjectWithSlots: 1.
	"Make object 2 reference object 1"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopTwo withValue: nonEphemeronObjectOopOne. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory doScavenge:1 "Tenured by age".
	memory fullGC.

	ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo.
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo.
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsYoungObjectsYoung [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newObjectWithSlots: 1.
	nonEphemeronObjectOopTwo := self newZeroSizedObject.
	"Make object 1 reference object 2"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopOne withValue: nonEphemeronObjectOopTwo. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.

	"Collect both non ephemeron objects"
	memory doScavenge: 1. "TenureByAge"

	ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo.

	self assert: memory dequeueMourner equals: ephemeronObjectOopOne.
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo
]

{ #category : 'tests - finalization - algorithm' }
VMSpurEphemeronsAlgorithmTest >> testEphemeronsYoungObjectsYoungInverse [

	ephemeronObjectOopOne := self newEphemeronObject.
	ephemeronObjectOopTwo := self newEphemeronObject.
	nonEphemeronObjectOopOne := self newZeroSizedObject.
	nonEphemeronObjectOopTwo := self newObjectWithSlots: 1.
	"Make object 2 reference object 1"
	memory storePointer: 0 ofObject: nonEphemeronObjectOopTwo withValue: nonEphemeronObjectOopOne. 

	self addKeysToEphemerons.
	self keepEphemeronsInVMVariables.
	
	"Collect both non ephemeron objects"
	memory doScavenge: 1. "TenureByAge"

	ephemeronObjectOopOne := memory remapObj: ephemeronObjectOopOne.
	ephemeronObjectOopTwo := memory remapObj: ephemeronObjectOopTwo.
	
	self assert: memory dequeueMourner equals: ephemeronObjectOopOne.
	self assert: memory dequeueMourner equals: ephemeronObjectOopTwo
]
