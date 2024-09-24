Class {
	#name : 'VMSpurScavengerTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'asserting' }
VMSpurScavengerTest >> assertPastSpaceIsEmpty [
	self
		assert: memory pastSpaceStart
		equals: memory scavenger pastSpace start
]

{ #category : 'helpers' }
VMSpurScavengerTest >> fullNewSpace [

	| rootObjectAddress referencedObjectAddress freeStartAtBeginning |
	freeStartAtBeginning := memory freeStart.

	rootObjectAddress := self newObjectWithSlots: 200.

	1 to: 200 do: [ :i |
		referencedObjectAddress := self newObjectWithSlots: 100.
		memory
			storePointer: i - 1
			ofObject: rootObjectAddress
			withValue: referencedObjectAddress.
		1 to: 100 do: [ :i2 |
			memory
				storePointer: i2 - 1
				ofObject: referencedObjectAddress
				withValue: (self newObjectWithSlots: 10).

			memory freeStart - freeStartAtBeginning
			> memory scavenger futureSpace size ifTrue: [ ^ rootObjectAddress ] ] ].

	self error: 'New space is not full!'
]

{ #category : 'helpers' }
VMSpurScavengerTest >> makeBaseFrameWithMethod: aMethodOop context: aContextOop receiver: aReceiverOop args: argsOops andStack: stackOops [
	
	| page pointer |
	page := memory coInterpreter stackPages newStackPage.
	pointer := page baseAddress.
	memory coInterpreter stackPointer: pointer + memory wordSize.
	"Receiver"
	memory coInterpreter push: aReceiverOop.
	argsOops do: [ :e | memory coInterpreter push: e ].
	"sender context"
	memory coInterpreter push: memory nilObject.
	"base frame's saved fp is null"
	memory coInterpreter push: 0.
	page
		baseFP: memory coInterpreter stackPointer;
		headFP: memory coInterpreter stackPointer.
	"method"
	memory coInterpreter push: aMethodOop.
	"Flags: this stack frame is single. I.e., it has no context object.
	Otherwise GC fails with an assertion looking for it in the heap"
	memory coInterpreter push: (memory coInterpreter 
		encodeFrameFieldHasContext: (aContextOop ~= memory nilObject)
		isBlock: false
		numArgs: argsOops size).
	"context"
	memory coInterpreter push: aContextOop.
	"rcvr"
	memory coInterpreter push: aReceiverOop.
	"frame stack => empty"
	stackOops do: [ :e | memory coInterpreter push: e ].
	"ip"
	memory coInterpreter push: (aMethodOop + memory baseHeaderSize - 2).
	page headSP: memory coInterpreter stackPointer.
	memory coInterpreter setStackPageAndLimit: page.
	memory coInterpreter setStackPointersFromPage: page.
	memory coInterpreter popStack.
	
	"Mark context as married by setting its sender to the frame pointer plus SmallInteger
	 tags and the InstructionPointer to the saved fp (which ensures correct alignment
	 w.r.t. the frame when we check for validity) plus SmallInteger tags."
	(aContextOop ~= memory nilObject) ifTrue: [ 
		memory
			storePointerUnchecked: 0 "SenderIndex"
			ofObject: aContextOop
			withValue: (memory coInterpreter withSmallIntegerTags: page baseFP) ]
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testAllocatingObjectsBelowThresholdDoesNotScheduleScavenge [

	| times |
	times := ((memory scavengeThreshold - memory freeStart) / 16) floor.
	
	times timesRepeat: [ self newZeroSizedObject ].
	
	"We are just below the threshold and we do not need a GC"
	self deny: memory needGCFlag
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testAllocatingObjectsBelowThresholdShouldBeYoung [

	| times anObjectOop |
	times := ((memory scavengeThreshold - memory freeStart) / 16) floor.
	
	times timesRepeat: [ anObjectOop := self newZeroSizedObject ].
	
	self assert: (memory getMemoryMap isYoungObject: anObjectOop)
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testAllocatingObjectsOverThresholdShouldBeOld [

	| times anObject |
	times := ((memory scavengeThreshold - memory freeStart) / 16) floor.
	times timesRepeat: [ self newZeroSizedObject ].
	
	"We are just below the threshold and we do not need a GC"
	"We will allocate a new one forcing the allocation in the old space and asking the GC"
	
	anObject := memory
		allocateSlots: 0
		format: 0 "zero sized object"
		classIndex: self zeroSizedObjectClassIndex.
		
	self assert: (memory getMemoryMap isOldObject: anObject)
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testAllocatingObjectsOverThresholdShouldScheduleScavenge [

	| times |
	times := ((memory scavengeThreshold - memory freeStart) / 16) floor.
	times timesRepeat: [ self newZeroSizedObject ].
	
	"We are just below the threshold and we do not need a GC"
	"We will allocate a new one forcing the allocation in the old space and asking the GC"
	
	memory
		allocateSlots: 0
		format: 0 "zero sized object"
		classIndex: self zeroSizedObjectClassIndex.
		
	self assert: memory needGCFlag
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testArgumentInStackShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |	
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).

	stackBuilder args: { newObjectOop }.
	stackBuilder addNewFrame.
	stackBuilder buildStack.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-8-scavenge-tenuring' }
VMSpurScavengerTest >> testComputeTenuringThresholdWithFewSurvivors [

	| rootObjectAddress |

	rootObjectAddress := self newZeroSizedObject.
	memory coInterpreter method: rootObjectAddress.

	self assert: memory scavenger tenuringProportion equals: 0.9. "When tenuring, keep 90% of the objects"
	self assert: memory scavenger scavengerTenuringProportion equals: 0 "Not tenure next pass".
	
	memory doScavenge: 1 "TenureByAge".

	self assert: memory scavenger scavengerTenuringProportion closeTo: 0 "Past space keep not full -> Not tenure next pass"
]

{ #category : 'tests-8-scavenge-tenuring' }
VMSpurScavengerTest >> testComputeTenuringThresholdWithManySurvivors [

	| rootObjectAddress |
	rootObjectAddress := self fullNewSpace.
	memory coInterpreter method: rootObjectAddress.

	self assert: memory scavenger tenuringProportion equals: 0.9. "When tenuring, keep 90% of the objects"
	self assert: memory scavenger scavengerTenuringProportion equals: 0. "Not tenure next pass"

	memory doScavenge: 1. "TenureByAge"

	self assert: memory scavenger scavengerTenuringProportion closeTo: 0.1 "Past space is full -> Tenure next pass"
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testContextInStackShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |
	stackBuilder addNewFrame method: methodBuilder newMethod buildMethod.
	stackBuilder buildStack.
	newObjectOop := interpreter
		                ensureFrameIsMarried: interpreter framePointer
		                SP: interpreter stackPointer.
	newObjectHash := memory hashBitsOf: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1. "TenureByAge"

	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self
		assert: (memory hashBitsOf: newObjectAddress)
		equals: newObjectHash
]

{ #category : 'tests-5-scavenge-specialObjects' }
VMSpurScavengerTest >> testInterpreterMethodShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |	
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	memory coInterpreter method: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-5-scavenge-specialObjects' }
VMSpurScavengerTest >> testInterpreterNewMethodShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |	
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	memory coInterpreter newMethod: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-5-scavenge-specialObjects' }
VMSpurScavengerTest >> testInterpreterProfileMethodShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |	
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	memory coInterpreter profileMethod: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-5-scavenge-specialObjects' }
VMSpurScavengerTest >> testInterpreterProfileProcessShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |	
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	memory coInterpreter profileProcess: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-5-scavenge-specialObjects' }
VMSpurScavengerTest >> testInterpreterProfileSemaphoreShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	memory coInterpreter profileSemaphore: newObjectOop.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testMethodInStackShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |

	newObjectOop := self newZeroSizedObject.
	
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	stackBuilder addNewFrame method: newObjectOop.
	stackBuilder buildStack.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testMovingReferencedObjectShouldUpdateReference [

	| rootObjectAddress newRootObjectAddress referencedObjectAddress referencedObjectHash |
	rootObjectAddress := self newObjectWithSlots: 1.

	referencedObjectAddress := self newZeroSizedObject.
	referencedObjectHash := (memory hashBitsOf: referencedObjectAddress).
	
	memory storePointer: 0 ofObject: rootObjectAddress withValue: referencedObjectAddress.
	
	memory coInterpreter method: rootObjectAddress.

	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newRootObjectAddress := memory remapObj: rootObjectAddress.
	
	self
		assert: (memory hashBitsOf: (memory fetchPointer: 0 ofObject: newRootObjectAddress))
		equals: referencedObjectHash
]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testObjectInStackShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	stackBuilder addNewFrame stack: { newObjectOop }.
	stackBuilder buildStack.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".

	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testOldObjectReferenceToYoungObjectShouldBeRemappedAfterScanvenge [

	| oldObjectAddress rememberedObjectAddress rememberedObjectHash newRememberedObjectAddress maybeMappedReferenceToYoungObject |
	
	"Create a young object and reference it from the old object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	rememberedObjectAddress := self newZeroSizedObject.
	rememberedObjectHash := memory hashBitsOf: rememberedObjectAddress.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: rememberedObjectAddress.
	
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	maybeMappedReferenceToYoungObject := memory fetchPointer: 0 ofObject: oldObjectAddress.
	newRememberedObjectAddress := memory remapObj: rememberedObjectAddress.
	
	self assert: maybeMappedReferenceToYoungObject equals: newRememberedObjectAddress
]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testPermObjectInRemeberedSetShouldBeKeptWhenTheReferencedObjectIsInTheOldSpace [

	| permObjectAddress youngObject otherOldObjectAddress |
	
	"Create a young object and reference it from the perm object"
	permObjectAddress := self newPermanentObjectWithSlots: 1.
	otherOldObjectAddress := self newOldSpaceObjectWithSlots: 0.

	youngObject := self newZeroSizedObject.

	memory storePointer: 0 ofObject: permObjectAddress withValue: youngObject.

	memory storePointer: 0 ofObject: permObjectAddress withValue: otherOldObjectAddress.

	"Should be in the remembered set as this is clean up during the scavenge"
	self assert: (memory isRemembered: permObjectAddress).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permObjectAddress).
	
	memory doScavenge: 1 "TenureByAge".
	
	self deny: (memory isRemembered: permObjectAddress).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permObjectAddress).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permObjectAddress).

]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testPermObjectInRemeberedSetShouldBeRemovedFromPermSpaceWhenMutatedToPointAPermObject [

	| permObjectAddress youngObject otherPermObjectAddress |
	
	"Create a young object and reference it from the perm object"
	permObjectAddress := self newPermanentObjectWithSlots: 1.
	otherPermObjectAddress := self newPermanentObjectWithSlots: 0.

	youngObject := self newZeroSizedObject.

	memory storePointer: 0 ofObject: permObjectAddress withValue: youngObject.

	memory storePointer: 0 ofObject: permObjectAddress withValue: otherPermObjectAddress.

	"Should be in the remembered set as this is clean up during the scavenge"
	self assert: (memory isRemembered: permObjectAddress).
	
	memory doScavenge: 1 "TenureByAge".
	
	self deny: (memory isRemembered: permObjectAddress).

]

{ #category : 'tests-4-scavenge-stack' }
VMSpurScavengerTest >> testReceiverInStackShouldSurviveScanvenge [

	| newObjectOop newObjectHash newObjectAddress |
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).
	
	stackBuilder addNewFrame receiver: newObjectOop.
	stackBuilder buildStack.

	"Nil should survive, but newObjectOop should survive too.
	Nil is referenced by the roots because many of their slots are nilled.
	newObjectOop is referenced by the stack"
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testReferencedObjectShouldSurviveScavenge [

	| rootObjectAddress rootObjectHash newRootObjectAddress referencedObjectAddress referencedObjectHash newReferencedObjectAddress |
	rootObjectAddress := self newObjectWithSlots: 1.
	rootObjectHash := (memory hashBitsOf: rootObjectAddress).

	referencedObjectAddress := self newZeroSizedObject.
	referencedObjectHash := (memory hashBitsOf: referencedObjectAddress).
	
	memory storePointer: 0 ofObject: rootObjectAddress withValue: referencedObjectAddress.
	
	memory coInterpreter method: rootObjectAddress.

	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newRootObjectAddress := memory remapObj: rootObjectAddress.
	newReferencedObjectAddress := memory remapObj: referencedObjectAddress.
	self assert: (memory hashBitsOf: newRootObjectAddress) equals: rootObjectHash.
	self assert: (memory hashBitsOf: newReferencedObjectAddress) equals: referencedObjectHash
]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testScanvengeTenureByAgeWithRSInRedZoneShouldShrink [

	| youngObjectAddress oneOldObjectAddress otherOldObjectAddress |
	
	memory getFromOldSpaceRememberedSet rememberedSetRedZone: 2.
	
	"Create a young object and reference it from two old objects"
	youngObjectAddress := self newZeroSizedObject.

	oneOldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oneOldObjectAddress withValue: youngObjectAddress.

	otherOldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: otherOldObjectAddress withValue: youngObjectAddress.

	self assert: memory fromOldSpaceRememberedSet isInRedZone.
	self assert: memory scavenger refCountToShrinkRT isNil. 
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: memory scavenger refCountToShrinkRT equals: 8. 

]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeEmptyMemoryShouldExchangePastAndFutureSpaces [

	| oldPastSpaceStart oldFutureSpaceStart |
	oldPastSpaceStart := memory scavenger pastSpace start.
	oldFutureSpaceStart := memory scavenger futureSpace start.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: memory scavenger pastSpace start equals: oldFutureSpaceStart.
	self assert: memory scavenger futureSpace start equals: oldPastSpaceStart.
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeNonSurvivorShouldEmptyEden [
	"Nil should survive."
	"A new object not referenced should not survive."
	self newZeroSizedObject.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: memory freeStart equals: memory scavenger eden start
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeNonSurvivorShouldOnlyCopySurvivorObjectToPastSpace [

	"Only Nil should survive."
	"A new object not referenced should not survive."
	self newObjectWithSlots: 1.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assertPastSpaceIsEmpty
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengeObjectInRememberedSetShouldBeInvertedToBeBeforeObjectInStack [

	| objectInTheStack oldObjectAddress objectInRememberedSet |
	"Create an object, reference it, and move it to old space"
	oldObjectAddress := self newObjectWithSlots: 1.
	memory coInterpreter newMethod: oldObjectAddress.
	memory flushNewSpace.
	oldObjectAddress := memory remapObj: oldObjectAddress.

	"Instantiate first the object in the stack, then the object in the remembered set.
	They will be inverted in memory when the scavenger copies them to future space"
	objectInTheStack := self newZeroSizedObject.
	objectInRememberedSet := self newZeroSizedObject.

	stackBuilder addNewFrame method: objectInTheStack.
	stackBuilder buildStack.
		
	memory storePointer: 0 ofObject: oldObjectAddress withValue: objectInRememberedSet.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: objectInRememberedSet) < (memory remapObj: objectInTheStack)
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengeObjectInRemembererdSetShouldBeBeforeObjectInStack [

	| objectInTheStack oldObjectAddress objectInRememberedSet |
	"Create an object, reference it, and move it to old space"
	oldObjectAddress := self newObjectWithSlots: 1.
	memory coInterpreter newMethod: oldObjectAddress.
	memory flushNewSpace.
	oldObjectAddress := memory remapObj: oldObjectAddress.

	"Instantiate first the object in the remembered set, then the object in the stack.
	They will be copied to future space in the same order by the scavenger"
	objectInRememberedSet := self newZeroSizedObject.
	objectInTheStack := self newZeroSizedObject.
	
	stackBuilder addNewFrame method: objectInTheStack.
	stackBuilder buildStack.
	
	memory storePointer: 0 ofObject: oldObjectAddress withValue: objectInRememberedSet.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: objectInRememberedSet) < (memory remapObj: objectInTheStack)
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengeObjectInStackShouldBeBeforeObjectInSpecialVariable [

	| objectInTheStack objectInSpecialVariable |
	objectInTheStack := self newZeroSizedObject.
	objectInSpecialVariable := self newZeroSizedObject.
	
	stackBuilder addNewFrame method: objectInTheStack.
	stackBuilder buildStack.
		
	memory coInterpreter method: objectInSpecialVariable.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: objectInTheStack) < (memory remapObj: objectInSpecialVariable)
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengeObjectInStackShouldBeInvertedToBeBeforeObjectInSpecialVariable [

	| objectInTheStack objectInSpecialVariable |
	objectInSpecialVariable := self newZeroSizedObject.
	objectInTheStack := self newZeroSizedObject.
	
	stackBuilder addNewFrame method: objectInTheStack.
	stackBuilder buildStack.
		
	memory coInterpreter method: objectInSpecialVariable.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: objectInTheStack) < (memory remapObj: objectInSpecialVariable)
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeShouldCopySurvivorObjectToPastSpace [	
	"Nil should survive.
	It is referenced by the roots because many of their slots are nilled."
	memory doScavenge: 1 "TenureByAge".
	
	self assertPastSpaceIsEmpty
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeSurvivorShouldEmptyEden [

	memory doScavenge: 1 "TenureByAge".
	
	self assert: memory freeStart equals: memory scavenger eden start
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testScavengeTwiceShouldExchangePastAndFutureSpacesBackAndForth [

	| oldPastSpaceStart oldFutureSpaceStart |	
	oldPastSpaceStart := memory scavenger pastSpace start.
	oldFutureSpaceStart := memory scavenger futureSpace start.
	
	2 timesRepeat: [ memory doScavenge: 1 "TenureByAge" ].
	
	self assert: memory scavenger pastSpace start equals: oldPastSpaceStart.
	self assert: memory scavenger futureSpace start equals: oldFutureSpaceStart.
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengedObjectsShouldBeCopiedInInstanceVariableOrder [

	| rootObjectAddress objectThatShouldGoSecond objectThatShouldGoFirst |
	rootObjectAddress := self newObjectWithSlots: 2.
	objectThatShouldGoSecond := self newZeroSizedObject.
	objectThatShouldGoFirst := self newZeroSizedObject.
	
	memory storePointer: 0 ofObject: rootObjectAddress withValue: objectThatShouldGoFirst.
	memory storePointer: 1 ofObject: rootObjectAddress withValue: objectThatShouldGoSecond.
	
	memory coInterpreter method: rootObjectAddress.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: objectThatShouldGoFirst) < (memory remapObj: objectThatShouldGoSecond)
]

{ #category : 'tests-7-scavenge-order' }
VMSpurScavengerTest >> testScavengedRootObjectsShouldBeCopiedBeforeOtherObjects [

	| firstRootObjectAddress nonRootObjectAddress secondRootObjectAddress |
	firstRootObjectAddress := self newObjectWithSlots: 1.
	nonRootObjectAddress := self newZeroSizedObject.
	secondRootObjectAddress := self newZeroSizedObject.
	
	memory storePointer: 0 ofObject: firstRootObjectAddress withValue: nonRootObjectAddress.
	
	memory coInterpreter method: firstRootObjectAddress.
	memory coInterpreter newMethod: secondRootObjectAddress.
	
	memory doScavenge: 1 "TenureByAge".
	
	self assert: (memory remapObj: secondRootObjectAddress) < (memory remapObj: nonRootObjectAddress)
]

{ #category : 'tests-8-scavenge-tenuring' }
VMSpurScavengerTest >> testShouldTenureBasedOnTheThreshold [

	| firstObjectAddress secondObjectAddress |

	firstObjectAddress := self newZeroSizedObject.
	secondObjectAddress := self newZeroSizedObject.
	memory coInterpreter method: firstObjectAddress.
	memory coInterpreter profileSemaphore: secondObjectAddress.

	memory doScavenge: 1. "TenureByAge"
	firstObjectAddress := memory remapObj: firstObjectAddress.
	secondObjectAddress := memory remapObj: secondObjectAddress.

	"Both still in new space"
	self assert: (memory isInNewSpace: firstObjectAddress).
	self assert: (memory isInNewSpace: secondObjectAddress).
	
	"Set threshold aftes first object"
	memory scavenger setRawTenuringThreshold: firstObjectAddress + 1.
	
	memory doScavenge: 1. "TenureByAge"
	firstObjectAddress := memory remapObj: firstObjectAddress.
	secondObjectAddress := memory remapObj: secondObjectAddress.

	"Objects before the threshold where tenured"
	self assert: (memory isInOldSpace: firstObjectAddress).
	"Next objects keep in new space"
	self assert: (memory isInNewSpace: secondObjectAddress)

]

{ #category : 'tests-8-scavenge-tenuring' }
VMSpurScavengerTest >> testShouldTenureObjectsWhenPastSpaceIsFull [

	| rootObjectAddress newRootObjectAddress |

	rootObjectAddress := self fullNewSpace.
	memory coInterpreter method: rootObjectAddress.

	self assert: memory scavenger scavengerTenuringProportion equals: 0. "Start without tenuring"

	memory doScavenge: 1. "TenureByAge"
	newRootObjectAddress := memory remapObj: rootObjectAddress.

	"Survivors should touched the threshold, so next scavenge will be tenured"
	self assert: memory scavenger scavengerTenuringProportion closeTo: 0.1.
	self assert: (memory isInNewSpace: newRootObjectAddress).
	
	memory doScavenge: 1. "TenureByAge"
	newRootObjectAddress := memory remapObj: newRootObjectAddress.

	"Some objects should be tenured"
	self assert: (memory isInOldSpace: newRootObjectAddress)
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testUnreferencedObjectCycleShouldNotSurviveScavenge [
	| objectA objectB |
	objectA := self newObjectWithSlots: 1.
	objectB := self newObjectWithSlots: 1.
	memory
		storePointer: 0
		ofObject: objectA
		withValue: objectB.
	memory
		storePointer: 0
		ofObject: objectB
		withValue: objectA.

	memory doScavenge: 1. "TenureByAge"
	
	self assertPastSpaceIsEmpty
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testUnreferencedObjectGraphShouldNotSurviveScavenge [
	| unreferencedRootObjectAddress referencedObjectAddress |
	unreferencedRootObjectAddress := self newObjectWithSlots: 1.
	referencedObjectAddress := self newZeroSizedObject.
	memory
		storePointer: 0
		ofObject: unreferencedRootObjectAddress
		withValue: referencedObjectAddress.

	memory doScavenge: 1. "TenureByAge"
	
	self assertPastSpaceIsEmpty
]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testYoungObjectRememberedFromOldObjectShouldSurviveScanvenge [

	| oldObjectAddress rememberedObjectAddress rememberedObjectHash newRememberedObjectAddress |
	
	"Create a young object and reference it from the old object"
	oldObjectAddress := self newOldSpaceObjectWithSlots: 1.
	rememberedObjectAddress := self newZeroSizedObject.
	rememberedObjectHash := memory hashBitsOf: rememberedObjectAddress.
	memory storePointer: 0 ofObject: oldObjectAddress withValue: rememberedObjectAddress.
	
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newRememberedObjectAddress := memory remapObj: rememberedObjectAddress.
	self assert: (memory hashBitsOf: newRememberedObjectAddress) equals: rememberedObjectHash
]

{ #category : 'tests-6-scavenge-rememberedset' }
VMSpurScavengerTest >> testYoungObjectRememberedFromPermanentObjectShouldSurviveScanvenge [

	| permObjectAddress rememberedObjectAddress rememberedObjectHash newRememberedObjectAddress |
	
	"Create a young object and reference it from the perm object"
	permObjectAddress := self newPermanentObjectWithSlots: 1.
	rememberedObjectAddress := self newZeroSizedObject.
	rememberedObjectHash := memory hashBitsOf: rememberedObjectAddress.
	memory storePointer: 0 ofObject: permObjectAddress withValue: rememberedObjectAddress.
	
	memory doScavenge: 1 "TenureByAge".
	
	"Remap our object address to its new location"
	newRememberedObjectAddress := memory remapObj: rememberedObjectAddress.
	self assert: (memory hashBitsOf: newRememberedObjectAddress) equals: rememberedObjectHash
]

{ #category : 'tests-3-scavenge-basic' }
VMSpurScavengerTest >> testYoungObjectsFromPermanentSpaceAreRemapped [

	| newObjectOop newObjectHash permObject newObjectAddress |
	newObjectOop := self newZeroSizedObject.
	newObjectHash := (memory hashBitsOf: newObjectOop).


	permObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permObject withValue: newObjectOop.

	memory doScavenge: 1 "TenureByAge".
	
	newObjectAddress := memory remapObj: newObjectOop.
	self assert: (memory hashBitsOf: newObjectAddress) equals: newObjectHash.
	
	self assert: (memory fetchPointer: 0 ofObject: permObject) equals: newObjectAddress
]
