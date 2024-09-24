Class {
	#name : 'VMX64InstructionTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'building suites' }
VMX64InstructionTest class >> wordSizeParameters [ 

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #X64. #wordSize -> 8};
		yourself
]

{ #category : 'configuration' }
VMX64InstructionTest >> generateCaptureCStackPointers [
	
	^ false
]

{ #category : 'tests' }
VMX64InstructionTest >> testDupAndStoreFromVectorRegister [

	| mem |

	self compile: [
		cogit MoveCq: 16r0123456789ABCDEF R: 2.
		cogit DupS: 64 R: 2 Vr: 0.
		cogit MoveCq: memory getMemoryMap newSpaceStart R: 2.
		cogit AlignedSt1S: 64 Vr: 0 R: 2 Mw: 16 ].
	
	self runGeneratedCode.
		
	mem := machineSimulator memoryAt: memory getMemoryMap newSpaceStart readNext: 16. 	
		
	self 
		assert: mem 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

	self assert: machineSimulator rdx 
		equals: memory getMemoryMap newSpaceStart + 16

]

{ #category : 'tests' }
VMX64InstructionTest >> testDupAndStoreFromVectorRegisterUnAligned [

	| mem |

	self compile: [
		cogit MoveCq: 16r0123456789ABCDEF R: 2.
		cogit DupS: 64 R: 2 Vr: 0.
		cogit MoveCq: memory getMemoryMap newSpaceStart + 8 R: 2.
		cogit St1S: 64 Vr: 0 R: 2 Mw: 16 ].
	
	
	self runGeneratedCode.
		
	mem := machineSimulator memoryAt: memory getMemoryMap newSpaceStart + 8 readNext: 16. 	
		
	self 
		assert: mem 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

	self assert: machineSimulator rdx 
		equals: memory getMemoryMap newSpaceStart + 8 + 16

]

{ #category : 'tests' }
VMX64InstructionTest >> testDupSRVr [


	self compile: [
		cogit MoveCq: 16r0123456789ABCDEF R: 2.
		cogit DupS: 64 R: 2 Vr: 0].
	
	self runGeneratedCode.
		
	self 
		assert: machineSimulator xmm0 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

]

{ #category : 'tests' }
VMX64InstructionTest >> testFaddSRvRvRv [

	| result |
		
	self compile: [
		cogit MoveCq: 1.0 asIEEE64BitWord R: 0.
		cogit MoveCq: 2.0 asIEEE64BitWord R: 1.
		cogit DupS: 64 R: 0 Vr: 0.
		cogit DupS: 64 R: 1 Vr: 1.
		cogit FaddS: 64 Rv: 0 Rv: 1 Rv: 0].
	
	self runGeneratedCode.
	
	result := machineSimulator xmm0.
	self assert: (result doubleAt: 1) equals: 3.0.	
	self assert: (result doubleAt: 9) equals: 3.0.	
]

{ #category : 'tests' }
VMX64InstructionTest >> testFaddSRvRvRvWithThreeDifferentRegisters [

	| result |
		
	self compile: [
		cogit MoveCq: 1.0 asIEEE64BitWord R: 0.
		cogit MoveCq: 2.0 asIEEE64BitWord R: 1.
		cogit DupS: 64 R: 0 Vr: 0.
		cogit DupS: 64 R: 1 Vr: 1.
		cogit FaddS: 64 Rv: 0 Rv: 1 Rv: 2].
	
	self runGeneratedCode.
	
	result := machineSimulator xmm2.
	self assert: (result doubleAt: 1) equals: 3.0.	
	self assert: (result doubleAt: 9) equals: 3.0.	
]

{ #category : 'tests' }
VMX64InstructionTest >> testFsubSRvRvRv [

	| result |
		
	self compile: [
		cogit MoveCq: 1.0 asIEEE64BitWord R: 0.
		cogit MoveCq: 2.0 asIEEE64BitWord R: 1.
		cogit DupS: 64 R: 0 Vr: 0.
		cogit DupS: 64 R: 1 Vr: 1.
		cogit FsubS: 64 Rv: 0 Rv: 1 Rv: 0].
	
	self runGeneratedCode.
	
	result := machineSimulator xmm0.
	self assert: (result doubleAt: 1) equals: -1.0.	
	self assert: (result doubleAt: 9) equals: -1.0.	
]

{ #category : 'tests' }
VMX64InstructionTest >> testFsubSRvRvRvWithThreeDifferentRegisters [

	| result |
		
	self compile: [
		cogit MoveCq: 1.0 asIEEE64BitWord R: 0.
		cogit MoveCq: 2.0 asIEEE64BitWord R: 1.
		cogit DupS: 64 R: 0 Vr: 0.
		cogit DupS: 64 R: 1 Vr: 1.
		cogit FsubS: 64 Rv: 0 Rv: 1 Rv: 2].
	
	self runGeneratedCode.
	
	result := machineSimulator xmm2.
	self assert: (result doubleAt: 1) equals: -1.0.	
	self assert: (result doubleAt: 9) equals: -1.0.	
]
