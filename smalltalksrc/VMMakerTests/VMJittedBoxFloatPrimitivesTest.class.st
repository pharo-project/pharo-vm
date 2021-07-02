Class {
	#name : #VMJittedBoxFloatPrimitivesTest,
	#superclass : #VMJittedPrimitivesTest,
	#pools : [
		'CogRTLOpcodes'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #tests }
VMJittedBoxFloatPrimitivesTest >> testAsFloat [

	cogit receiverTags: memory smallIntegerTag.
	
	self compile: [ cogit objectRepresentation genPrimitiveAsFloat ].

	self executePrimitiveWithReceiver: (self memory integerObjectOf: 27).

	self 
		assert: (memory floatValueOf: machineSimulator receiverRegisterValue) 
		equals: 27.0
]

{ #category : #tests }
VMJittedBoxFloatPrimitivesTest >> testAsFloatWhenThereIsNotSpaceFailsPrimitive [

	| stop |
	cogit receiverTags: memory smallIntegerTag.

	memory freeStart: memory scavengeThreshold.
	
	self compile: [ 
			cogit objectRepresentation genPrimitiveAsFloat.
			stop := cogit Stop ].

	self prepareStackForSendReceiver: (self memory integerObjectOf: 27) arguments: #().
	self runFrom: initialAddress until: stop address.
	self assert: machineSimulator instructionPointerValue equals: stop address

]
