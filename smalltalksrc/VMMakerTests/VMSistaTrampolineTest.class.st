Class {
	#name : 'VMSistaTrampolineTest',
	#superclass : 'VMTrampolineTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'running' }
VMSistaTrampolineTest >> jitOptions [

	^ super jitOptions
		  at: #bytecodeTableInitializer put: #initializeBytecodeTableForSistaV1;
		  yourself
]

{ #category : 'tests' }
VMSistaTrampolineTest >> testSendTrampolineWithFourArguments [
	
	| trampolineStart receiver |
	trampolineStart := self compileWithoutOutput: [ 
		cogit
			generateSuperSendTrampolineTo: #ceSend:aboveClassBinding:to:numArgs:
			named: 'ceDirectedSuperBindingSend'
			numArgs: 0 "to be in Arg3Reg"
			in: cogit directedBindingSuperSendTrampolines ] bytecodes: 10.
	
	receiver := 13.
	self prepareStackForSendReceiver: receiver arguments: { }.

	"Initialize the state of the interpreter"
	machineSimulator classRegisterValue: 11.
	machineSimulator temporaryRegisterValue: 12.
	machineSimulator receiverRegisterValue: receiver.
	self runFrom: trampolineStart until: (cogit simulatedTrampolineFor: #ceSend:aboveClassBinding:to:numArgs:).

	"Check they arrive to the correct C-calling convention registers"
	self assert: machineSimulator carg0 equals: 11.
	self assert: machineSimulator carg1 equals: 12.
	self assert: machineSimulator carg2 equals: 13.
	self assert: machineSimulator carg3 equals: 0.
]
