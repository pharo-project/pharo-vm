Class {
	#name : 'VMSimpleStackBasedCogitRememberedSetTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMSimpleStackBasedCogitRememberedSetTest >> assertReceiver: receiver value: value shouldCallTrampoline: shouldCallTrampoline [

	| trampoline afterBytecode |
	machineSimulator receiverRegisterValue: receiver.

	self pushAddress: value.

	cogit objectRepresentation ceStoreCheckTrampoline: (self compileTrampoline: [ trampoline := cogit Stop ] named:#ceStoreCheckTrampoline).
		
	"The bytecode for popIntoRcvrVariable is 0 based"
	cogit byte0: 0.		
	self compile: [ 
		cogit genStoreAndPopReceiverVariableBytecode.
		afterBytecode := cogit Stop ].	

	machineSimulator
		startAt: cogInitialAddress
		until: (shouldCallTrampoline ifTrue:[trampoline address] ifFalse: [afterBytecode address])
		timeout: 0
		count: 0.
	
]

{ #category : 'initialization' }
VMSimpleStackBasedCogitRememberedSetTest >> setUp [

	super setUp.
	self setUpTrampolines
]

{ #category : 'tests' }
VMSimpleStackBasedCogitRememberedSetTest >> testStoringNewObjectInNewObjectDoesNotCallTrampoline [

	| newObject otherNewObject |
	newObject := self newObjectWithSlots: 1.
	otherNewObject := self newObjectWithSlots: 0.
	
	self 
		assertReceiver: newObject
		value: otherNewObject
		shouldCallTrampoline: false
]

{ #category : 'tests' }
VMSimpleStackBasedCogitRememberedSetTest >> testStoringNewObjectInOldObjectDoesCallTrampoline [

	| oldObject otherNewObject |
	
	oldObject := self newOldSpaceObjectWithSlots: 1.
	otherNewObject := self newObjectWithSlots: 0.
	
	self 
		assertReceiver: oldObject
		value: otherNewObject
		shouldCallTrampoline: true
]

{ #category : 'tests' }
VMSimpleStackBasedCogitRememberedSetTest >> testStoringOldObjectInOldObjectDoesNotCallTrampoline [

	| oldObject otherOldObject |
	
	oldObject := self newOldSpaceObjectWithSlots: 1.
	otherOldObject := self newOldSpaceObjectWithSlots: 0.
	
	self 
		assertReceiver: oldObject
		value: otherOldObject
		shouldCallTrampoline: false
]

{ #category : 'tests' }
VMSimpleStackBasedCogitRememberedSetTest >> testStoringOldObjectInPermObjectDoesCallTrampoline [

	| permObject otherPermObject |
	
	memory getMemoryMap extendPermObjectsSpaceMinimum: 0.
	
	permObject := self newPermanentObjectWithSlots: 1.
	otherPermObject := self newPermanentObjectWithSlots: 0.
	
	self 
		assertReceiver: permObject
		value: otherPermObject
		shouldCallTrampoline: false
]
