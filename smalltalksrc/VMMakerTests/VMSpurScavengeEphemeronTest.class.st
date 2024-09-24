Class {
	#name : 'VMSpurScavengeEphemeronTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> pushRoot: anObject [

	| link |
	link := self newArrayWithSlots: 2.
	memory
		storePointer: 0 "Value"
		ofObject: link
		withValue: anObject.
	memory
		storePointer: 1 "Next"
		ofObject: link
		withValue: self keptObjectInVMVariable1.
	self keepObjectInVMVariable1: link.
]

{ #category : 'initialization' }
VMSpurScavengeEphemeronTest >> setUp [

	super setUp.
	memory initializeMournQueue.
	self createEphemeronClass
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testDequeueMournerWithOnlyOneEphemeronShouldEmptyMournQueue [

	| ephemeronObjectOop nonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	memory dequeueMourner.
	self assert: memory dequeueMourner equals: nil
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testEphemeronDiscoveredDuringEphemeronListIteration [

	| ephemeronObjectOop1 ephemeronObjectOop2 dicoveredEphemeron nonSurvivingKey key1 key2 |
	ephemeronObjectOop1 := self newEphemeronObject.
	ephemeronObjectOop2 := self newEphemeronObject.
	dicoveredEphemeron := self newEphemeronObject.
	key1 := self newObjectWithSlots: 0.
	key2 := self newObjectWithSlots: 0.
	nonSurvivingKey := self newObjectWithSlots: 0.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop1
		withValue: key1.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop2
		withValue: key2.
	memory
		storePointer: 0
		ofObject: dicoveredEphemeron
		withValue: nonSurvivingKey.
	memory
		storePointer: 1
		ofObject: ephemeronObjectOop1
		withValue: dicoveredEphemeron.
	
	"Order is important here. The surviving key should be traced AFTER the ephemerons.
	This way they are added to the ephemeron list to be traced later."
	self pushRoot: key1.
	self pushRoot: key2.
	
	"Both these ephemerons must survive.
	When iterating the ephemeron list, if the head survives, the head gets rewritten and the ephemeron gets traced.
	If, when tracing the ephemeron a new ephemeron is discovered, it gets added at the head of the list"
	self pushRoot: ephemeronObjectOop1.
	
	"Then, when iterating the second ephemeron in the list, the head has changed!
	This should be properly handled"
	self pushRoot: ephemeronObjectOop2.
	
	memory doScavenge: 1 "TenureByAge".

	"Weak assertion: check the heap is in correct state"
	memory setCheckForLeaks: -1.
	memory runLeakCheckerFor: GCModeIncremental
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testEphemeronDiscoveredTwiceInRememberedSet [

	| ephemeronObjectOop oldEphemeronObjectOop1 oldEphemeronObjectOop2 |
	ephemeronObjectOop := self newEphemeronObject.
	oldEphemeronObjectOop1 := self newOldEphemeronObject.
	oldEphemeronObjectOop2 := self newOldEphemeronObject.
	memory
		storePointer: 0
		ofObject: oldEphemeronObjectOop1
		withValue: ephemeronObjectOop.
	memory
		storePointer: 0
		ofObject: oldEphemeronObjectOop2
		withValue: ephemeronObjectOop.

	memory doScavenge: 1 "TenureByAge".

	memory setCheckForLeaks: -1.
	memory runLeakCheckerFor: GCModeIncremental
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testFireManyEphemeronWithSameKey [

	| numberOfEphemerons ephemeronKey |
	"All ephemerons share the same key that is collectable"
	numberOfEphemerons := 5.
	self keepObjectInVMVariable1:
		(self newObjectWithSlots: numberOfEphemerons).
	ephemeronKey := self newZeroSizedObject.

	1 to: numberOfEphemerons do: [ :i | 
		| ephemeron |
		ephemeron := self newEphemeronObject.
		memory storePointer: 0 ofObject: ephemeron withValue: ephemeronKey.
		memory
			storePointer: 1
			ofObject: ephemeron
			withValue: (memory integerObjectOf: i - 1). "Store its index in the array"
		memory
			storePointer: i - 1
			ofObject: self keptObjectInVMVariable1
			withValue: ephemeron ].

	1 to: numberOfEphemerons do: [ :i | 
		| mourner |
		memory doScavenge: 1. "TenureByAge"
		mourner := memory dequeueMourner.
		self assert: mourner notNil.

		"Remove it from the registry"
		memory
			storePointer: (memory integerValueOf: (memory fetchPointer: 1 ofObject: mourner))
			ofObject: self keptObjectInVMVariable1
			withValue: memory nilObject ]
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testNewEphemeronObjectShouldBeInstanceOfEphemeronClass [

	| ephemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.

	self
		assert: (memory fetchClassOfNonImm: ephemeronObjectOop)
		equals: ourEphemeronClass
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronInRememberdSetBecomesNormalObjectAfterFinalizationIsFired [

	| ephemeronObjectOop nonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	"Move ephemeron to old space"
	memory flushNewSpace.
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	nonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	self
		assert: (memory formatOf: ephemeronObjectOop)
		equals: memory nonIndexablePointerFormat
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronInRememberedSetReferencingDyingObjectShouldBeAddedInTheMournQueue [

	| ephemeronObjectOop nonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	"Move ephemeron to old space"
	memory flushNewSpace.
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	nonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	self assert: memory dequeueMourner equals: ephemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronInRememberedSetReferencingDyingObjectShouldScavengeEphemeronKey [

	| ephemeronObjectOop nonEphemeronObjectOop nonEphemeronObjectHash |
	ephemeronObjectOop := self newEphemeronObject.
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	"Move ephemeron to old space"
	memory flushNewSpace.
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	nonEphemeronObjectOop := self newZeroSizedObject.
	nonEphemeronObjectHash := memory hashBitsOf: nonEphemeronObjectOop.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	self
		assert: (memory hashBitsOf: nonEphemeronObjectOop)
		equals: nonEphemeronObjectHash
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronInRememberedSetReferencingSurvivorShouldLeaveEphemeronObjectAsIs [

	| ephemeronObjectOop nonEphemeronObjectOop nonEphemeronObjectHash |
	ephemeronObjectOop := self newEphemeronObject.
	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	"Move ephemeron to old space"
	memory flushNewSpace.
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	nonEphemeronObjectOop := self newZeroSizedObject.
	nonEphemeronObjectHash := memory hashBitsOf: nonEphemeronObjectOop.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: nonEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	self
		assert: (memory hashBitsOf:
				 (memory fetchPointer: 0 ofObject: ephemeronObjectOop))
		equals: nonEphemeronObjectHash
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronObjectBecomesNormalObjectAfterFinalizationIsFired [

	| ephemeronObjectOop nonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	self
		assert: (memory formatOf: ephemeronObjectOop)
		equals: memory nonIndexablePointerFormat
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronObjectReferencingDyingObjectShouldBeAddedInTheMournQueue [

	| ephemeronObjectOop nonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	self assert: memory dequeueMourner equals: ephemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronObjectReferencingDyingObjectShouldScavengeEphemeronKey [

	| ephemeronObjectOop nonEphemeronObjectOop nonEphemeronObjectHash |
	ephemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	nonEphemeronObjectHash := memory hashBitsOf: nonEphemeronObjectOop.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	nonEphemeronObjectOop := memory remapObj: nonEphemeronObjectOop.
	self
		assert: (memory hashBitsOf: nonEphemeronObjectOop)
		equals: nonEphemeronObjectHash
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeEphemeronObjectReferencingSurvivorShouldLeaveEphemeronObjectAsIs [

	| ephemeronObjectOop nonEphemeronObjectOop nonEphemeronObjectHash |
	ephemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	nonEphemeronObjectHash := memory hashBitsOf: nonEphemeronObjectOop.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: nonEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	self
		assert: (memory hashBitsOf:
				 (memory fetchPointer: 0 ofObject: ephemeronObjectOop))
		equals: nonEphemeronObjectHash
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingDifferentDyingObjectsShouldBeAddedInTheMournQueueAfterScavengingInEden [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop anotherNonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	anotherNonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: anotherNonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.
	self assert: memory dequeueMourner equals: ephemeronObjectOop.

	self assert: memory dequeueMourner equals: anotherEphemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingDifferentDyingObjectsShouldBeAddedInTheMournQueueAfterScavengingInPastSpace [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop anotherNonEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.
	anotherNonEphemeronObjectOop := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: anotherNonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.
	self keepObjectInVMVariable3: anotherNonEphemeronObjectOop.

	"Scavence once so all three objects are moved from eden to past space"
	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.
	anotherNonEphemeronObjectOop := memory remapObj:
		                                anotherNonEphemeronObjectOop.

	self forgetObject3.
	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.

	self assert: memory dequeueMourner equals: anotherEphemeronObjectOop.

	self assert: memory dequeueMourner equals: ephemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingSameDyingObjectsShouldAddOnlyOneEphemeron [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.

	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.

	"Consume the first mourner"
	memory dequeueMourner.
	self assert: memory dequeueMourner equals: nil
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingSameDyingObjectsShouldAddOnlySecond [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.

	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.

	self assert: memory dequeueMourner equals: anotherEphemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingSameDyingObjectsShouldBeQueuedAfterConsumingMournQueue [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.

	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	"The second ephemeron changed format, now it keeps the key strongly.
	Nil the ephemeron key to allow the next ephemeron to be finalized too"
	memory
		storePointer: 0
		ofObject: memory dequeueMourner
		withValue: memory nilObject.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.

	self assert: memory dequeueMourner equals: ephemeronObjectOop
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingSameDyingObjectsShouldLeaveFirstOneAsEphemeron [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.

	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.

	self assert: (memory isEphemeron: ephemeronObjectOop)
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeTwoEphemeronObjectsReferencingSameDyingObjectsShouldScavengeKeyOfSecond [

	| ephemeronObjectOop nonEphemeronObjectOop anotherEphemeronObjectOop |
	ephemeronObjectOop := self newEphemeronObject.
	anotherEphemeronObjectOop := self newEphemeronObject.
	nonEphemeronObjectOop := self newZeroSizedObject.

	memory
		storePointer: 0
		ofObject: ephemeronObjectOop
		withValue: nonEphemeronObjectOop.

	memory
		storePointer: 0
		ofObject: anotherEphemeronObjectOop
		withValue: nonEphemeronObjectOop.

	"Force object to not be collected by putting them in special variables"
	self keepObjectInVMVariable1: ephemeronObjectOop.
	self keepObjectInVMVariable2: anotherEphemeronObjectOop.

	memory doScavenge: 1. "TenureByAge"
	ephemeronObjectOop := memory remapObj: ephemeronObjectOop.
	anotherEphemeronObjectOop := memory remapObj:
		                             anotherEphemeronObjectOop.

	self
		assert: (memory fetchPointer: 0 ofObject: ephemeronObjectOop)
		equals: (memory remapObj: nonEphemeronObjectOop)
]

{ #category : 'tests-ephemerons-globals' }
VMSpurScavengeEphemeronTest >> testScavengeZeroSizedEphemeronShouldTreatItAsNormalObject [
	| ephemeronObjectOop zeroSizedEphemeronClass hashBefore addressBefore |
	
	"Create a zero sized ephemeron"
	zeroSizedEphemeronClass := self createEphemeronClassForSlots: 0.
	ephemeronObjectOop := memory instantiateClass: zeroSizedEphemeronClass.
		
	"Force object to not be collected by putting them in special variables"
	hashBefore := memory hashBitsOf: ephemeronObjectOop.
	addressBefore := ephemeronObjectOop.
	self keepObjectInVMVariable1: ephemeronObjectOop.

	"This should work ok, as the minimal object always at least one slot to use as a forwarding pointer.
	This means that a 0 sized ephemeron will have a slot referencing nil and it should work as a normal object"
	memory fullGC.

	"The object should move, but should be the same and keep the same hash"
	self
		deny: addressBefore
		equals: self keptObjectInVMVariable1.
	self
		assert: hashBefore
		equals: (memory hashBitsOf: self keptObjectInVMVariable1).
]
