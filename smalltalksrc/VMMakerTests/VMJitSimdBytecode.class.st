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
VMJitSimdBytecode >> testAddVectorCopiesArraySumIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	arguments := { memory integerObjectOf: 0.  array := self new64BitIndexableOfSize: 4. memory integerObjectOf: 2 }.	
		
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
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister2Value.
	
	self assert: (register doubleAt: 1) equals: 4.0.
	self assert: (register doubleAt: 9) equals: 6.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testAddVectorPushesArraySumIntoSimulatedStack [

	| endInstruction primitiveAddress array entry |
	
	arguments := { memory integerObjectOf: 0.  array := self new64BitIndexableOfSize: 4. memory integerObjectOf: 2 }.	
		
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
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 2.

]

{ #category : #tests }
VMJitSimdBytecode >> testPushArrayToRegisterCopiesArrayChunkIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
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
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 3.0.
	self assert: (register doubleAt: 9) equals: 4.0.

]

{ #category : #tests }
VMJitSimdBytecode >> testPushArrayToRegisterPushesArrayChunkIntoSimulatedStack [

	| endInstruction primitiveAddress array entry |
	
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
	
	entry := cogit ssTop.
	
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 0.
]

{ #category : #tests }
VMJitSimdBytecode >> testStoreRegisterIntoArrayReplacesArrayElementsWithRegisterContent [

	| endInstruction primitiveAddress array |
	
	arguments := { memory integerObjectOf: 2.  array := self new64BitIndexableOfSize: 4. memory integerObjectOf: 0 }.	
		
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
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.
								 cogit genStoreRegisterIntoArray.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	self assert: (memory fetchFloat64: 0 ofObject: array) equals: 3.0.
	self assert: (memory fetchFloat64: 1 ofObject: array) equals: 4.0.
]
