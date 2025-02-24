Class {
	#name : 'VMForwardLiteralInMachineMethodTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'helpers' }
VMForwardLiteralInMachineMethodTest >> initStack [

	self createBaseFrame.
	
	"Initialize Stack to the correct pointers in the selected page"
	machineSimulator smalltalkStackPointerRegisterValue: interpreter stackPointer.
	machineSimulator framePointerRegisterValue: interpreter framePointer.
	machineSimulator baseRegisterValue: cogit varBaseAddress.

	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.

]

{ #category : 'methods under test' }
VMForwardLiteralInMachineMethodTest >> methodWithGlobal [

	^ Smalltalk
]

{ #category : 'tests' }
VMForwardLiteralInMachineMethodTest >> testForwardLiteralInMethod [

	| machineCodeMethod literal methodOop array literalValue selector associationClass valueClass literalKey |
	
	methodOop := self createMethodOopFromHostMethod: (self findMethod: #methodWithGlobal).
	
	selector := self newZeroSizedObject.
	
	literal := methodBuilder literals at: 1.
	literalKey := memory fetchPointer: 0 ofObject: literal.

	associationClass := self newClassInOldSpaceWithSlots: 2 instSpec: Association instSpec. 
	memory setClassIndexOf: literal to: (memory ensureBehaviorHash: associationClass).

	valueClass := self newClassInOldSpaceWithSlots: 0 instSpec: Object instSpec. 
	literalValue := self newObjectWithSlots: 0 classIndex: (memory ensureBehaviorHash: valueClass).
	
	memory storePointer: 1 ofObject: literal withValue: literalValue.

	self initStack.

	machineCodeMethod := cogit cog: methodOop selector: selector.

	array := memory newArrayWith: {literal. literalValue}.

	memory moveToPermSpaceInBulk: array.	
		
	self assert: (memory isForwarded: literal).
	self assert: (memory isForwarded: literalValue).

	literal := memory followForwarded: literal.
	literalValue := memory followForwarded: literalValue.

	"We mark because we don't care about this, we care about resolving the forwarders"
	memory setIsMarkedOf: methodOop to: true. 	
	memory setIsMarkedOf: selector to: true. 	
	memory setIsMarkedOf: associationClass to: true.
	memory setIsMarkedOf: valueClass to: true.
	memory setIsMarkedOf: literalKey to: true. 

	memory initializeMarkStack.

	self assert: (cogit hasMachineCodeMethodForwardedLiterals: machineCodeMethod).

	cogit markAndTraceLiteralsIn:machineCodeMethod.
			
	self deny: (cogit hasMachineCodeMethodForwardedLiterals: machineCodeMethod)
]
