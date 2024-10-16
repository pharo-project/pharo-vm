Class {
	#name : 'VMPermanentSpaceMemoryTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#category : 'VMMakerTests-PermSpace',
	#package : 'VMMakerTests',
	#tag : 'PermSpace'
}

{ #category : 'running' }
VMPermanentSpaceMemoryTest >> setUp [

	super setUp.
	self createEphemeronClass.
	self createWeakArrayClass
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testAllInstancesReturnsObjectsInPermSpace [

	| permanentObject allInstances |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	allInstances := memory allInstancesOf: memory classByteArray.

	self assert: (memory slotSizeOf: allInstances) equals: 1.
	self assert: (memory fetchPointer: 0 ofObject: allInstances) equals: permanentObject.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingOneWayOfPermanentObjectWithOldObject [

	| permanentObject oldReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	oldReplacement := self newOldSpaceObjectWithSlots: 0.
	self keepObjectInVMVariable3: oldReplacement.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: oldReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: false copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: oldReplacement.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObjectReferencingPermanent).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObjectReferencingPermanent).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	oldReplacement := self keptObjectInVMVariable3.
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: oldReplacement.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: oldReplacement.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: oldReplacement.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingOneWayOfPermanentObjectWithPermanentObject [

	| permanentObject permanentReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	permanentReplacement := self newPermanentObjectWithSlots: 0.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: permanentReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: false copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentReplacement.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentReplacement.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentReplacement.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentReplacement.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingOneWayOfPermanentObjectWithYoungObject [

	| permanentObject oldReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	oldReplacement := self newObjectWithSlots: 0.
	self keepObjectInVMVariable3: oldReplacement.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: oldReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: false copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: oldReplacement.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObjectReferencingPermanent).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObjectReferencingPermanent).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	oldReplacement := self keptObjectInVMVariable3.
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: oldReplacement.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: oldReplacement.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: oldReplacement.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithOldObjectLeavingForwarded [

	| permanentObject oldReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	oldReplacement := self newOldSpaceObjectWithSlots: 0.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: oldReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	self keepObjectInVMVariable3: (memory followForwarded: permanentObject).
	self assert: (memory isPermanent: (memory followForwarded: oldReplacement)).
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithOldObjectNotLeavingForwarded [

	| permanentObject oldReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent oldValue newValue |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (oldValue := self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	oldReplacement := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldReplacement withValue: (newValue := self newObjectWithSlots: 0).

	self keepObjectInVMVariable3: oldReplacement.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: oldReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
		
	"The initial permanent object is in place changed, so it is the same address"	
	self deny: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).

	self assert: (memory fetchPointer: 0 ofObject: permanentObject) equals: newValue.
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithPermanentObjectLeavingForwarded [

	| permanentObject permanentReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	permanentReplacement := self newPermanentObjectWithSlots: 0.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: permanentReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	self keepObjectInVMVariable3: (memory followForwarded: permanentObject).
	
	self assert: (memory isPermanent: (memory followForwarded: permanentReplacement)).
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithPermanentObjectNotLeavingForwarded [

	| permanentObject oldReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent oldValue newValue |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (oldValue := self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	oldReplacement := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldReplacement withValue: (newValue := self newObjectWithSlots: 0).

	self keepObjectInVMVariable3: oldReplacement.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: oldReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
		
	"The initial permanent object is in place changed, so it is the same address"	
	self deny: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).

	self assert: (memory fetchPointer: 0 ofObject: permanentObject) equals: newValue.
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithYoungObjectLeavingForwarded [

	| permanentObject youngReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	youngReplacement := self newObjectWithSlots: 0.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: youngReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
	
	self keepObjectInVMVariable3: (memory followForwarded: permanentObject).
	self assert: (memory isPermanent: (memory followForwarded: youngReplacement)).
	
	"The initial permanent object is now forwarded"	
	self assert: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.
	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: self keptObjectInVMVariable3.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'tests - become' }
VMPermanentSpaceMemoryTest >> testBecomingTwoWayOfPermanentObjectWithYoungObjectNotLeavingForwarded [

	| permanentObject youngReplacement arrFrom arrTo ec youngObjectReferencingPermanent oldObjectReferencingPermanent permanentObjectReferencingPermanent oldValue newValue |
	
	permanentObject := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObject withValue: (oldValue := self newOldSpaceObjectWithSlots: 0).

	youngObjectReferencingPermanent := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable1: youngObjectReferencingPermanent.
	
	oldObjectReferencingPermanent := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObjectReferencingPermanent withValue: permanentObject.
	self keepObjectInVMVariable2: oldObjectReferencingPermanent.

	permanentObjectReferencingPermanent := self newPermanentObjectWithSlots: 1.
	memory storePointer: 0 ofObject: permanentObjectReferencingPermanent withValue: permanentObject.
	
	memory fullGC.

	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.

	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	
	youngReplacement := self newObjectWithSlots: 1.
	memory storePointer: 0 ofObject: youngReplacement withValue: (newValue := self newObjectWithSlots: 0).

	self keepObjectInVMVariable3: youngReplacement.
	
	arrFrom := self newArrayWithSlots: 1.
	arrTo := self newArrayWithSlots: 1.

	memory storePointer: 0 ofObject: arrFrom withValue: permanentObject.
	memory storePointer: 0 ofObject: arrTo withValue: youngReplacement.
	ec := memory become: arrFrom with: arrTo twoWay: true copyHash: false.

	self assert: ec equals: PrimNoErr.
		
	"The initial permanent object is in place changed, so it is the same address"	
	self deny: (memory isForwarded: permanentObject).
	"Old and New objects still points to it"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.

	"Perm objects still points to the result"
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	"The forwarded object is not in any remembered set"
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).

	self assert: (memory fetchPointer: 0 ofObject: permanentObject) equals: newValue.
	
	memory fullGC.
	
	youngObjectReferencingPermanent := self keptObjectInVMVariable1.
	oldObjectReferencingPermanent := self keptObjectInVMVariable2.	
	
	"After GC nobody points to the forwarded object"
	self assert: (memory fetchPointer: 0 ofObject: oldObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: youngObjectReferencingPermanent) equals: permanentObject.
	self assert: (memory fetchPointer: 0 ofObject: permanentObjectReferencingPermanent) equals: permanentObject.
	
	self assert: memory isPermSpaceRememberedSetSane.
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testCompiledMethodWithMachineCodeIsNotRememberedWhenModified [

	| oldObject1 permanentObject1 |

	oldObject1 := self newOldSpaceObjectWithSlots: 2.

	permanentObject1 := memory moveToPermSpace: oldObject1.

	memory
		storePointer: 0
		ofObject: permanentObject1
		withValue: (VMMemoryMapConfiguration forWordsize: wordSize) new codeZoneInitialAddress. "I create an address as it was a machine code method"

	self deny: (memory isRemembered: permanentObject1).
	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet:
			 permanentObject1).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet:
			 permanentObject1)
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testCompiledMethodWithMachineCodeIsNotRememberedWhenMoving [

	| oldObject1 permanentObject1 |

	oldObject1 := self newOldSpaceObjectWithSlots: 2.

	memory
		storePointer: 0
		ofObject: oldObject1
		withValue: (VMMemoryMapConfiguration forWordsize: wordSize) new codeZoneInitialAddress. "I create an address as it was a machine code method"

	permanentObject1 := memory moveToPermSpace: oldObject1.

	self deny: (memory isRemembered: permanentObject1).
	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet:
			 permanentObject1).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet:
			 permanentObject1)
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testMarkingNewSpaceDoesNotMarkPermSpace [

	| permanentObject newObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	newObject := self newObjectWithSlots: 1.
	self keepObjectInVMVariable1: newObject.
	
	self assert: (memory getMemoryMap isYoungObject: newObject).

	memory storePointer: 0 ofObject: newObject withValue: permanentObject.

	memory doScavenge: 1 "TenureByAge".

	self deny: (memory isMarked: permanentObject)
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testMarkingOldSpaceDoesNotMarkPermSpace [

	| permanentObject oldObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	oldObject := self newOldSpaceObjectWithSlots: 1.
	self keepObjectInVMVariable1: oldObject.
	
	self assert: (memory getMemoryMap isOldObject: oldObject).

	memory storePointer: 0 ofObject: oldObject withValue: permanentObject.

	memory fullGC.

	self deny: (memory isMarked: permanentObject)
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMoveOldObjectInRememberedSetIsMovedFromSet [

	| oldObject youngObject permanentObject |

	oldObject := self newOldSpaceArrayWithSlots: 1.
	youngObject := self newObjectWithSlots: 0.
	
	memory storePointer: 0 ofObject: oldObject withValue: youngObject.
	
	self assert: (memory isRemembered: oldObject). 
	self assert: (memory getFromOldSpaceRememberedSet isInRememberedSet: oldObject). 
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: oldObject). 
	
	permanentObject := memory moveToPermSpace: oldObject.	
	
	self assert: (memory isRemembered: permanentObject). 
	
	"Old object is now a forwarder should not be in any remembered set"
	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet: oldObject). 
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: oldObject). 
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: oldObject). 

	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet: permanentObject). 
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject). 
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject). 

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMovingAnObjectReferencingAYoungOnePutsInRememberedSet [

	| permanentObject youngObject rootObject|
	
	rootObject := self newObjectWithSlots:  1.
	youngObject := self newZeroSizedObject.

	memory storePointer: 0 ofObject: rootObject withValue: youngObject.

	permanentObject := memory moveToPermSpace: rootObject.	
		
	self assert: (memory isRemembered: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject).
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMovingAnObjectReferencingAnOldOnePutsInRememberedSet [

	| permanentObject oldObject rootObject|
	
	rootObject := self newOldSpaceObjectWithSlots: 1.
	oldObject := self newOldByteObjectOfSize: 1.

	memory storePointer: 0 ofObject: rootObject withValue: oldObject.

	permanentObject := memory moveToPermSpace: rootObject.	
	
	"Perm to Old objects are not set the remembered bit"
	self deny: (memory isRemembered: permanentObject).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject).
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMovingOldObjectToPermSpaceIsCorrectlyForwarded [

	| permanentObject oldObject rootObject|
	
	rootObject := self newOldSpaceObjectWithSlots: 1.
	oldObject := self newOldByteObjectOfSize: 1.

	memory storePointer: 0 ofObject: rootObject withValue: oldObject.
	self keepObjectInVMVariable1: rootObject.

	permanentObject := memory moveToPermSpace: oldObject.	
	
	self assert: (memory isForwarded: (memory fetchPointer: 0 ofObject: rootObject)).

	memory fullGC.
	rootObject := self keptObjectInVMVariable1.
	
	self deny: (memory isForwarded: (memory fetchPointer: 0 ofObject: rootObject)).
	self assert: (memory fetchPointer: 0 ofObject: rootObject) equals: permanentObject.

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMovingOldObjectToPermSpaceLeavesForwarder [

	| permanentObject oldObject |
	
	oldObject := self newOldByteObjectOfSize: 1.
	self keepObjectInVMVariable1: oldObject.
	self assert: (memory getMemoryMap isOldObject: oldObject).

	permanentObject := memory moveToPermSpace: oldObject.	
	
	self assert: (memory isForwarded: oldObject).

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testMovingTwoObjectsPutBothInPermSpaceAndUpdatesArray [

	| permanentObject youngObject rootObject anArray|
	
	rootObject := self newObjectWithSlots:  1.
	youngObject := self newZeroSizedObject.
	anArray := self newArrayWithSlots: 2.

	memory storePointer: 0 ofObject: rootObject withValue: youngObject.
	memory storePointer: 0 ofObject: anArray withValue: rootObject.
	memory storePointer: 1 ofObject: anArray withValue: youngObject.

	memory moveToPermSpaceInBulk: anArray.	
		
	rootObject := memory fetchPointer: 0 ofObject: anArray.
	youngObject := memory fetchPointer: 1 ofObject: anArray.
	
	self deny: (memory isOopForwarded: rootObject).
	self deny: (memory isOopForwarded: youngObject).
	self assert: (memory getMemoryMap isPermanentObject: rootObject).
	self assert: (memory getMemoryMap isPermanentObject: youngObject).	
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testNewPermanentByteArrayIsCorrectlyAllocated [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self assert: permanentObject equals: memory getMemoryMap permSpaceStart + 16 "There is a zero-slot objects always in the perm space"
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testNewPermanentByteArrayIsNonYoungObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self deny: (memory getMemoryMap isYoungObject: permanentObject)
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testNewPermanentByteArrayIsNotAnOldObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self deny: (memory getMemoryMap isOldObject: permanentObject)
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testNewPermanentByteArrayIsPermanentObject [

	| permanentObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.

	self assert: (memory getMemoryMap isPermanentObject: permanentObject)
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testNextObjectIsReturningAGoodValue [

	| permanentObject nextObject |
	
	permanentObject := self newPermanentByteObjectOfSize: 14.
	nextObject := memory objectAfter: permanentObject.

	self assert: nextObject equals: memory permSpaceFreeStart
	
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testObjectInBothRememberedSetIsCorrectlyUpdated [

	| oldObject1 permanentObject1 oldObject2 youngObject |
	
	"To force compaction"
	self newOldSpaceArrayWithSlots: 2.
	
	self keepObjectInVMVariable1: (self newOldSpaceArrayWithSlots: 3).
	
	oldObject1 := self newOldSpaceObjectWithSlots: 2.
	
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	self keepObjectInVMVariable2: oldObject2.
	
	youngObject := self newZeroSizedObject.
	self keepObjectInVMVariable3: youngObject.
	
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	
	memory storePointer: 1 ofObject: permanentObject1  withValue: youngObject.
	
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject1).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1).

	memory fullGC.
	
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject1).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1).
	
	self assert: (memory fetchPointer: 0 ofObject: permanentObject1) equals: self keptObjectInVMVariable2.
	self assert: (memory fetchPointer: 1 ofObject: permanentObject1) equals: self keptObjectInVMVariable3.
	
]

{ #category : 'tests - allocation' }
VMPermanentSpaceMemoryTest >> testObjectReferencingOldIsAddedToCorrectRememberedSetAndThenRemoved [

	| oldObject1 oldObject2 permObject2 |
	oldObject1 := self newOldSpaceObjectWithSlots: 0.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	
	memory storePointer: 0 ofObject: oldObject2 withValue: oldObject1.
	
	permObject2 := memory moveToPermSpace: oldObject2.
	
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permObject2).

	"Add again as duplicated"
	memory getFromPermToOldSpaceRememberedSet rememberWithoutMarkingAsRemembered: permObject2.

	memory storePointer: 0 ofObject: permObject2 withValue: memory nilObject.

	memory fullGC.
		
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permObject2).
	self assert: memory getFromPermToNewSpaceRememberedSet rememberedSetSize equals: 0.
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testObjectWithForwarderIsCorrectlyResolved [

	
	| oldObject1 oldObject2 permanentObject1 permanentObject2 |
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	
	memory storePointer: 0 ofObject: oldObject2 withValue: oldObject1.

	permanentObject1 := memory moveToPermSpace: oldObject1.
	permanentObject2 := memory moveToPermSpace: oldObject2.
		
	self assert: (memory fetchPointer: 0 ofObject: permanentObject2) equals: permanentObject1.
	self deny: (memory isForwarded: (memory fetchPointer: 0 ofObject: permanentObject2)).

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingObjectInBulkToPermSpaceKeepsFirstInRememberedSet [

	| oldObject1 permanentObject1 oldObject2 array |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	array := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: array withValue: oldObject1.
	
	memory moveToPermSpaceInBulk: array.

	permanentObject1 := memory fetchPointer: 0 ofObject: array.

	self deny: (memory isRemembered: permanentObject1).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1 ).	

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingObjectsInBulkPreservesObjectAlreadyInTheRememberedSet [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 array youngObject |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	youngObject := self newZeroSizedObject.

	memory storePointer: 0 ofObject: oldObject1  withValue: youngObject.
	memory storePointer: 0 ofObject: oldObject2  withValue: youngObject.

	permanentObject1 := memory moveToPermSpace: oldObject1.
	
	self assert: (memory isRemembered: permanentObject1).	
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject1).
	
	array := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: array withValue: oldObject2.
	
	memory moveToPermSpaceInBulk: array.

	permanentObject2 := memory fetchPointer: 0 ofObject: array.

	self assert: (memory isRemembered: permanentObject1).	
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject1).

	self assert: (memory isRemembered: permanentObject2).	
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject2).

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsInBulkToPermSpaceIsRemovedFromRememberedSet [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 array |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	array := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: array withValue: oldObject1.
	memory storePointer: 1 ofObject: array withValue: oldObject2.
	
	memory moveToPermSpaceInBulk: array.

	permanentObject1 := memory fetchPointer: 0 ofObject: array.
	permanentObject2 := memory fetchPointer: 1 ofObject: array.

	self deny: (memory isRemembered: permanentObject1).
	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet: permanentObject1).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1).		
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsToPermSpaceIsRemovedFromRememberedSet [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	permanentObject2 := memory moveToPermSpace: oldObject2.

	"The FromPermToOld Remembered set is cleaned on FullGC"
	memory fullGC.

	self deny: (memory isRemembered: permanentObject1).
	self deny: (memory getFromOldSpaceRememberedSet isInRememberedSet: permanentObject1).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1).		
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsToPermSpaceKeepsFirstInRememberedSet [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	permanentObject2 := memory moveToPermSpace: oldObject2.

	"But it is not marked"
	self deny: (memory isRemembered: permanentObject1).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject1 ).	

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsToPermSpaceKeepsPointerToForwarderInOldSpace [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	permanentObject2 := memory moveToPermSpace: oldObject2.

	self assert: (memory fetchPointer: 0 ofObject: permanentObject1) equals: oldObject2
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsToPermSpaceNotUpdatesForwarderInScanvenge [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	permanentObject2 := memory moveToPermSpace: oldObject2.

	memory doScavenge: 1.

	self deny: (memory fetchPointer: 0 ofObject: permanentObject1) equals: permanentObject2
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPassingTwoObjectsToPermSpaceUpdatesForwarderInGC [

	| oldObject1 permanentObject1 oldObject2 permanentObject2 |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	permanentObject1 := memory moveToPermSpace: oldObject1.	
	permanentObject2 := memory moveToPermSpace: oldObject2.

	memory fullGC.

	self assert: (memory fetchPointer: 0 ofObject: permanentObject1) equals: permanentObject2
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermObjectPointingToOldSpaceIsUpdatedWhenCompactingForSaving [

	| oldObject1 permanentObject1 oldObject2 oldObject2Hash |
	
	oldObject1 := self newOldSpaceObjectWithSlots: 1.
	self newOldSpaceObjectWithSlots: 3.
	self newOldSpaceObjectWithSlots: 3.
	oldObject2 := self newOldSpaceObjectWithSlots: 1.
	self newOldSpaceObjectWithSlots: 3.
	self newOldSpaceObjectWithSlots: 3.
	self newOldSpaceObjectWithSlots: 3.
	self newOldSpaceObjectWithSlots: 3.
		
	memory storePointer: 0 ofObject: oldObject1  withValue: oldObject2.
	
	oldObject2Hash := memory hashBitsOf: oldObject2.
	permanentObject1 := memory moveToPermSpace: oldObject1.	

	memory garbageCollectForSnapshot.

	self assert: (memory hashBitsOf: (memory fetchPointer: 0 ofObject: permanentObject1)) equals: oldObject2Hash 
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectMarksItsOldClass [

	| permanentObject oldObject oldClass oldClassHash found |
	
	"When a old class is referenced indirectly from the perm space it is not marked. 
	We need to guarantee that the instances on the perm space or they are from permanent classes
	or old classes are never collected."
	self skip.
	
	oldClass := self newClassInOldSpaceWithSlots: 0 instSpec: memory zeroSlotsNonIndexablePointerFormat.
	oldClassHash := memory ensureBehaviorHash: oldClass.
	oldObject := self newOldSpaceObjectWithSlots: 0 format: memory zeroSlotsNonIndexablePointerFormat classIndex: oldClassHash.
	
	permanentObject := memory moveToPermSpace: oldObject.
	
	memory fullGC.
	
	found := false.
	
	memory allOldSpaceObjectsDo: [ :anOop | ((memory rawHashBitsOf: anOop) = oldClassHash) 
		ifTrue: [ found := true ]  ].
	
	self assert: found
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectPointingToFalseIsNotRemembered [

	
	| oldObject permanentObject |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject withValue: memory falseObject.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject ).	
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectPointingToMachineCodeIsNotRemembered [

	
	| oldObject permanentObject |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject withValue: "memory getMemoryMap codeZoneStart + 8" 16.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject ).	
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectPointingToNilIsNotRemembered [

	
	| oldObject permanentObject |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject ).	
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectPointingToTrueIsNotRemembered [

	
	| oldObject permanentObject |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	memory storePointer: 0 ofObject: oldObject withValue: memory trueObject.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permanentObject ).	
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectPointingToYoungObjectIsRemovedWhenPointingToMachineCodeMethod [

	
	| oldObject permanentObject youngObject fakeMachineCodeMethod |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	youngObject := self newZeroSizedObject.
	memory storePointer: 0 ofObject: oldObject withValue: youngObject.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self assert: (memory isRemembered: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject ).	
	
	"We allocate some memory in the codeZone. 
	Also we set the null header for the machineCodeMethods, this is used to threat references to it as other objects.
	For example, check the header to see if it is a forwarder, a machine code method is never a forwarder."
	
	fakeMachineCodeMethod := (VMMemoryMapConfiguration forWordsize: wordSize) new codeZoneInitialAddress.
	memory memoryManager allocate: 32 desiredPosition: fakeMachineCodeMethod.
	memory unsignedLong64At: fakeMachineCodeMethod put: memory nullHeaderForMachineCodeMethod.
	
	"We update the permanent object with the value as if it was a CompiledMethod with a corresponding MachineCodeMethod"	
	memory storePointer: 0 ofObject: permanentObject withValue: fakeMachineCodeMethod.

	memory doScavenge: 1.

	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject ).	
	self assert: (memory fetchPointer: 0 ofObject: permanentObject ) equals: fakeMachineCodeMethod.
]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testPermanentObjectUpdatedToTrueIsRemovedFromRememberedSet [

	
	| oldObject permanentObject youngObject |
	oldObject := self newOldSpaceObjectWithSlots: 1.
	youngObject := self newZeroSizedObject.
	memory storePointer: 0 ofObject: oldObject withValue: youngObject.
	permanentObject := memory moveToPermSpace: oldObject.
	
	self assert: (memory isRemembered: permanentObject).
	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject ).	
	
	memory storePointer: 0 ofObject: permanentObject withValue: memory trueObject.

	memory doScavenge: 1.

	self deny: (memory isRemembered: permanentObject).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permanentObject ).	

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testReferencingAnObjectFromOldEphemeronIsNotFired [

	| permanentObject oldObject ephemeronObject |
	
	oldObject := self newOldByteObjectOfSize: 1.	
		
	ephemeronObject := self
									newOldSpaceObjectWithSlots: 3
									format: memory ephemeronFormat
									classIndex: (memory ensureBehaviorHash: ourEphemeronClass).
	
	self keepObjectInVMVariable1: ephemeronObject.
	self assert: (memory getMemoryMap isOldObject: ephemeronObject).

	permanentObject := memory moveToPermSpace: oldObject.
	
	memory storePointer: 0 ofObject: ephemeronObject withValue: permanentObject.
	
	memory fullGC.
	
	self assert: (memory fetchPointer: 0 ofObject: self keptObjectInVMVariable1) equals: permanentObject.
	self assert: (memory formatOf: self keptObjectInVMVariable1) equals: memory ephemeronFormat.

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testReferencingAnObjectFromOldWeakObjectIsNotNilled [

	| permanentObject oldObject weakObject |
	
	oldObject := self newOldByteObjectOfSize: 1.	
	
	weakObject := self newOldSpaceObjectWithSlots: 1 format: memory weakArrayFormat classIndex: (memory ensureBehaviorHash: ourWeakClass).
	
	"As weak objects are iterated at the end of the process, the class of the weakArray is pushed in the stack but not visited.
	To ensure it is visited, be need to reference it. It seems like an issue."
	self keepObjectInVMVariable2: ourWeakClass.
	self keepObjectInVMVariable1: weakObject.

	self assert: (memory getMemoryMap isOldObject: weakObject).
	self assert: (memory isWeakNonImm: weakObject).

	permanentObject := memory moveToPermSpace: oldObject.
	
	memory storePointer: 0 ofObject: weakObject withValue: permanentObject.
	
	self assert: (memory fetchPointer: 0 ofObject: weakObject) equals: permanentObject.

	memory fullGC.
	
	self assert: (memory fetchPointer: 0 ofObject: self keptObjectInVMVariable1) equals: permanentObject.

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testReferencingAnObjectFromYoungEphemeronIsNotFired [

	| permanentObject oldObject ephemeronObject |
	
	oldObject := self newOldByteObjectOfSize: 1.	
		
	ephemeronObject := self newEphemeronObject.
	
	self keepObjectInVMVariable1: ephemeronObject.
	self assert: (memory getMemoryMap isYoungObject: ephemeronObject).

	permanentObject := memory moveToPermSpace: oldObject.
	
	memory storePointer: 0 ofObject: ephemeronObject withValue: permanentObject.
	
	memory fullGC.
	
	self assert: (memory fetchPointer: 0 ofObject: self keptObjectInVMVariable1) equals: permanentObject.
	self assert: (memory formatOf: self keptObjectInVMVariable1) equals: memory ephemeronFormat.

]

{ #category : 'test - moving' }
VMPermanentSpaceMemoryTest >> testReferencingAnObjectFromYoungWeakObjectIsNotNilled [

	| permanentObject oldObject weakObject |
	
	oldObject := self newOldByteObjectOfSize: 1.	
	weakObject := self newWeakObjectOfSize: 1.
	
	self keepObjectInVMVariable1: weakObject.

	self assert: (memory getMemoryMap isYoungObject: weakObject).
	self assert: (memory isWeakNonImm: weakObject).

	permanentObject := memory moveToPermSpace: oldObject.
	
	memory storePointer: 0 ofObject: weakObject withValue: permanentObject.
	
	self assert: (memory fetchPointer: 0 ofObject: weakObject) equals: permanentObject.

	memory doScavenge: 1.

	weakObject := memory remapObj: weakObject.

	self assert: (memory fetchPointer: 0 ofObject: weakObject) equals: permanentObject.

]
