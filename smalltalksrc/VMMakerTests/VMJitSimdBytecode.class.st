Class {
	#name : 'VMJitSimdBytecode',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMJitSimdBytecode class >> wordSizeParameters [ 

	^ self wordSize64Parameters 
]

{ #category : 'running' }
VMJitSimdBytecode >> jitOptions [

	^ super jitOptions
		  at: #bytecodeTableInitializer put: #initializeBytecodeTableForSistaV1;
		  yourself
]

{ #category : 'tests' }
VMJitSimdBytecode >> testAddVector32CopiesArraySumIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	arguments := { memory integerObjectOf: 0.  array := self new32BitIndexableOfSize: 8. memory integerObjectOf: 4 }.	
		
	memory storeFloat32: 0 ofObject: array withValue: 1.0. 
	memory storeFloat32: 1 ofObject: array withValue: 2.0.
	memory storeFloat32: 2 ofObject: array withValue: 3.0.
	memory storeFloat32: 3 ofObject: array withValue: 4.0. 		
	memory storeFloat32: 4 ofObject: array withValue: 5.0. 
	memory storeFloat32: 5 ofObject: array withValue: 6.0.
	memory storeFloat32: 6 ofObject: array withValue: 7.0.
	memory storeFloat32: 7 ofObject: array withValue: 8.0. 		
		
	sentSelector := #+.
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.
								 cogit genPushFloat32ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat32ArrayToRegister.
								 cogit genAddFloat32Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register floatAt: 1) equals: 6.0.
	self assert: (register floatAt: 5) equals: 8.0.
	self assert: (register floatAt: 9) equals: 10.0.
	self assert: (register floatAt: 13) equals: 12.0.

]

{ #category : 'tests' }
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
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 4.0.
	self assert: (register doubleAt: 9) equals: 6.0.

]

{ #category : 'tests' }
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
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genAddFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	"The register with the result is the same as the first one"
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 0.

]

{ #category : 'tests' }
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
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 3.0.
	self assert: (register doubleAt: 9) equals: 4.0.

]

{ #category : 'tests' }
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
								 cogit genPushFloat64ArrayToRegister.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	entry := cogit ssTop.
	
	self assert: (entry type) equals: SSVectorRegister.
	self assert: (entry register) equals: 0.
]

{ #category : 'tests' }
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
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.
								 cogit genStoreFloat64RegisterIntoArray.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].

	self runFrom: primitiveAddress until: endInstruction address.
	
	self assert: (memory fetchFloat64: 0 ofObject: array) equals: 3.0.
	self assert: (memory fetchFloat64: 1 ofObject: array) equals: 4.0.
]

{ #category : 'tests' }
VMJitSimdBytecode >> testSubVectorStoreResultIntoVectorRegister [

	| endInstruction primitiveAddress array register |
	
	arguments := { memory integerObjectOf: 0.  array := self new64BitIndexableOfSize: 4. memory integerObjectOf: 2 }.	
		
	memory storeFloat64: 0 ofObject: array withValue: 5.0. 
	memory storeFloat64: 1 ofObject: array withValue: 3.0.
	memory storeFloat64: 2 ofObject: array withValue: 2.0.
	memory storeFloat64: 3 ofObject: array withValue: 1.0. 		
		
	sentSelector := #-."TODO is this necessary?"
	self buildStackFrame.
	
	primitiveAddress := self compile: [ 
								 cogit genPushTemporaryVariable: 0.		
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genPushTemporaryVariable: 2.
								 cogit genPushTemporaryVariable: 1.		
								 cogit genPushFloat64ArrayToRegister.
								 cogit genSubFloat64Vector.
		                    "If the primitive fails it continues, so we need to have an instruction to detect the end"
		                    endInstruction := cogit Stop ].
	
	self runFrom: primitiveAddress until: endInstruction address.
	
	register := machineSimulator vectorRegister0Value.
	
	self assert: (register doubleAt: 1) equals: 3.0.
	self assert: (register doubleAt: 9) equals: 2.0.

]
