Class {
	#name : #VMSistaSuperSendsTest,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMSistaSuperSendsTest >> jitOptions [

	^ super jitOptions
		  at: #bytecodeTableInitializer put: #initializeBytecodeTableForSistaV1;
		  yourself
]

{ #category : #'tests - sends/super' }
VMSistaSuperSendsTest >> testSuperSendLiteralZeroWithZeroArgsMovesSelectorIndexClassRegisterIn64bits [

	| selector binding literalVariableIndex literalSelectorIndex startPC receiver expectedSelector |
	sendTrampolineAddress := self compile: [ cogit RetN: 0 ].
	cogit
		directedBindingSuperSendTrampolineAt: 0
		put: sendTrampolineAddress. "num args"

	self createFramefulCallFrom: callerAddress.

	cogit byte0: 0.
	binding := self newObjectWithSlots: 2.
	selector := memory falseObject.
	cogit methodObj: (methodBuilder newMethod
			 literalAt: (literalVariableIndex := 0) put: binding;
			 literalAt: (literalSelectorIndex := 1) put: selector;
			 numberOfArguments: 1;
			 bytecodes: #[ 16r11 16rE1 16r40 16rEB 16r00 ];
			 buildMethod).
	"Push literal variable"
	"Directed super send"
	startPC := interpreter startPCOfMethod: cogit methodObj.
	sendAddress := self compile: [ 
		               cogit methodOrBlockNumTemps: 0.
		               cogit initSimStackForFramelessMethod: startPC.
		               cogit bytecodePC: startPC.
		               cogit endPC: (memory numBytesOf: cogit methodObj).


		               "Push receiver and arguments"
		               cogit genPushReceiverBytecode.

		               "Push lookup class binding, then send"
		               cogit genPushLiteralVariable: literalVariableIndex.
		               cogit
			               genSendDirectedSuper: literalSelectorIndex
			               numArgs: 0 ].

	"Push receiver, arg, then send"
	receiver := memory integerObjectOf: 17.
	self
		prepareStackForSendReceiver: receiver
		arguments: { (memory integerObjectOf: 42) }.
	self runFrom: sendAddress until: sendTrampolineAddress.

	"In 64 bits we have the literal selector index that will be mapped by the send trampoline.
	In 32 bits we have the selector directly."
	expectedSelector := self wordSize = 8
		                    ifTrue: [ literalSelectorIndex ]
		                    ifFalse: [ selector ].
	self
		assert: machineSimulator classRegisterValue
		equals: expectedSelector.
	self assert: machineSimulator temporaryRegisterValue equals: binding.
	self assert: machineSimulator receiverRegisterValue equals: receiver
]
