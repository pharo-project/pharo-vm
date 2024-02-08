Class {
	#name : #VMJittedPrimitivesTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#instVars : [
		'classFloat'
	],
	#pools : [
		'CogRTLOpcodes'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #private }
VMJittedPrimitivesTest class >> isAbstract [
	^ self == VMJittedPrimitivesTest
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executeMethodWithReceiver: receiverOop withArguments: aCollection [
	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the argument should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"

	self
		prepareStackForSendReceiver: (self twoComplementFor: receiverOop)
		arguments: (aCollection collect: [ :arg | self twoComplementFor: arg ]).

	self runUntilReturn
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop [
	
	^ self executePrimitiveWithReceiver: receiverOop withArguments: { }
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArgument: argumentOop [
	
	^ self executePrimitiveWithReceiver: receiverOop withArguments: { argumentOop }
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArgument: firstArgumentOop and: secondArgumentOop [ 

	^ self executePrimitiveWithReceiver: receiverOop withArguments:  { firstArgumentOop. secondArgumentOop }.
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArguments: aCollection [
	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the argument should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"

	self
		prepareStackForPrimitiveReceiver: (self twoComplementFor: receiverOop)
		arguments: (aCollection collect: [ :arg | self twoComplementFor: arg ])
		method: 0.

"self openMachineDebugger . 1halt."

	self runUntilReturn
]

{ #category : #helpers }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArguments: aCollection method: aMethod [

	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the argument should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"
	self
		prepareStackForPrimitiveReceiver: (self twoComplementFor: receiverOop)
		arguments: (aCollection collect: [ :arg | self twoComplementFor: arg ])
		method: aMethod.

	self runUntilReturn
]

{ #category : #helpers }
VMJittedPrimitivesTest >> new16BitIndexableOfSize: aSize [

	^ self newBitIndexableOfSize: aSize bytesPerSlot: 2 format: memory firstShortFormat
]

{ #category : #helpers }
VMJittedPrimitivesTest >> new32BitIndexableOfSize: aSize [

	^ self newBitIndexableOfSize: aSize bytesPerSlot: 4 format: memory firstLongFormat
]

{ #category : #helpers }
VMJittedPrimitivesTest >> new64BitIndexableOfSize: aSize [

	^ self newBitIndexableOfSize: aSize bytesPerSlot: 8 format: memory sixtyFourBitIndexableFormat
]

{ #category : #helpers }
VMJittedPrimitivesTest >> setUp [

	super setUp.

	classFloat := self newClassInOldSpaceWithSlots: 0 instSpec: memory firstLongFormat.
	memory setHashBitsOf: classFloat to: ClassFloatCompactIndex.
	memory
		storePointer: ClassFloatCompactIndex
		ofObject: memory classTableFirstPage
		withValue: classFloat.
		
	memory classExternalAddress: (self newClassInOldSpaceWithSlots: 0 instSpec: (memory byteFormatForNumBytes: 0) ).
	
]

{ #category : #helpers }
VMJittedPrimitivesTest >> twoComplementFor: aNumber [

	^ aNumber twoComplementOfBitSize: self wordSize * 8
]
