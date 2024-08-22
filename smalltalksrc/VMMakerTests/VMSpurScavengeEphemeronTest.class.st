Class {
	#name : 'VMSpurScavengeEphemeronTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

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
