Class {
	#name : 'VMJittedPrimitivesTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#instVars : [
		'classFloat'
	],
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'private' }
VMJittedPrimitivesTest class >> isAbstract [
	^ self == VMJittedPrimitivesTest
]

{ #category : 'helpers' }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop [
	
	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the argument should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"
	
	self prepareStackForSendReceiver: receiverOop arguments: #().
	self runUntilReturn.

]

{ #category : 'helpers' }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArgument: argumentOop [
	
	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the argument should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"
	
	self prepareStackForSendReceiver: receiverOop arguments: { argumentOop }.
	self runUntilReturn.

]

{ #category : 'utils' }
VMJittedPrimitivesTest >> executePrimitiveWithReceiver: receiverOop withArgument: firstArgumentOop and: secondArgumentOop [ 

	"Simulate a primitive execution having an object as receiver and a single argument
	  - the receiver goes to the receiver register
	  - the arguments should be pushed to the stack
	If we are in a system without a link register, we need to push the caller IP to the stack to simulate a call"

	self prepareStackForSendReceiver: receiverOop arguments: { firstArgumentOop. secondArgumentOop }.
	
	self runUntilReturn
]

{ #category : 'helpers' }
VMJittedPrimitivesTest >> prepareStackForSendReceiver: aReceiver [

	self prepareStackForSendReceiver: aReceiver arguments: #()
]

{ #category : 'helpers' }
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
