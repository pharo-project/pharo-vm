Class {
	#name : #VMCallingConventionTest,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #tests }
VMCallingConventionTest >> testSendShouldSpillAboveReceiver [

	| stop method |
	method := self compile: [
		cogit methodOrBlockNumTemps: 0.
		cogit needsFrame: true.
		cogit initSimStackForFramefulMethod: 0.

		"This will push 0 and be spilled on the send"
		cogit genPushConstantZeroBytecode.

		"Let's compile 1 + true, spill what was pushed before"
		cogit genPushConstantOneBytecode.
		cogit genPushConstantTrueBytecode.
		cogit marshallSendArguments: 1.
		
		stop := cogit Stop
	].

	self runFrom: method until: stop address.
	
	self assert: (memory integerValueOf: self machineSimulator popWord) equals: 0
]

{ #category : #tests }
VMCallingConventionTest >> testSendShouldSpillReceiver [

	| stop method |
	method := self compile: [
		cogit methodOrBlockNumTemps: 0.
		cogit needsFrame: true.
		cogit initSimStackForFramefulMethod: 0.

		"Let's push two constants and spill the stack"
		cogit ssPushConstant: 42.
		cogit ssPushConstant: 17.
		cogit ssFlushTo: cogit simStackPointer.
		
		"Prepare to send a message with 0 arguments.
		The top of the stack (receiver) should be in a register and not the stack, to follow the calling convention"
		cogit marshallSendArguments: 0.
		
		stop := cogit Stop
	].
	self prepareStackForSendReceiver: 42 arguments: #().
	self runFrom: method until: stop address.

	"The receiver register should contain the receiver value"
	self assert: self machineSimulator receiverRegisterValue equals: 17.
	"The top of the stack should contain the marker value 42"
	self assert: self machineSimulator stackValues first value equals: 42
]
