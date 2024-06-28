Class {
	#name : 'VMJittedBoxFloatPrimitivesTest',
	#superclass : 'VMJittedPrimitivesTest',
	#pools : [
		'CogAbstractRegisters',
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMJittedBoxFloatPrimitivesTest >> setUp [

	super setUp.

	"If we are in Intel 32bits, we need to check if we have SSE instruction set"
	isa = #IA32 ifTrue: [ 
		cogit ceCheckFeaturesFunction: (self
				 compileTrampoline: [ 
					 cogit MoveCq: 1 << 26 R: TempReg.
					 cogit RetN: 0 ]
				 named: 'ceCheckFeatures') ]
]

{ #category : 'tests' }
VMJittedBoxFloatPrimitivesTest >> testAsFloat [

	cogit receiverTags: memory smallIntegerTag.
	
	cogInitialAddress := self compile: [ cogit objectRepresentation genPrimitiveAsFloat ].

	self executePrimitiveWithReceiver: (self memory integerObjectOf: 27).

	self 
		assert: (memory floatValueOf: machineSimulator receiverRegisterValue) 
		equals: 27.0
]

{ #category : 'tests' }
VMJittedBoxFloatPrimitivesTest >> testAsFloatWhenThereIsNotSpaceFailsPrimitive [

	| stop |

	"We can only generate BoxedFloat from an SmallInteger in 32bits"
	wordSize ~= 4 ifTrue: [ ^ self skip ].

	cogit receiverTags: memory smallIntegerTag.

	memory freeStart: memory scavengeThreshold.
	
	cogInitialAddress := self compile: [ 
			cogit objectRepresentation genPrimitiveAsFloat.
			stop := cogit Stop ].

	self prepareStackForSendReceiver: (self memory integerObjectOf: 27) arguments: #().

	self runFrom: cogInitialAddress until: stop address.
	self assert: machineSimulator instructionPointerRegisterValue equals: stop address

]
