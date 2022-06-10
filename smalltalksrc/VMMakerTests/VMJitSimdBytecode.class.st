Class {
	#name : #VMJitSimdBytecode,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMJitSimdBytecode >> jitOptions [

	^ super jitOptions
		  at: #bytecodeTableInitializer put: #initializeBytecodeTableForSistaV1;
		  yourself
]

{ #category : #tests }
VMJitSimdBytecode >> testPushArrayToRegister [

	| selector binding literalVariableIndex literalSelectorIndex startPC receiver expectedSelector endInstruction primitiveAddress array |
	
	arguments := { memory integerObjectOf: 2.  array := self new64BitIndexableOfSize: 4 }.	
		
	memory storeFloat64: 0 ofObject: array withValue: 1.0. 
	memory storeFloat64: 1 ofObject: array withValue: 2.0.
	memory storeFloat64: 2 ofObject: array withValue: 3.0.
	memory storeFloat64: 3 ofObject: array withValue: 4.0. 
		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	self openMachineDebugger.
	
	self assert: machineSimulator temporaryRegisterValue equals: binding.
	self assert: machineSimulator receiverRegisterValue equals: receiver
]
