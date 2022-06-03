Class {
	#name : #VMX64InstructionTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'building suites' }
VMX64InstructionTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #X64. #wordSize -> 8};
		yourself
]

{ #category : #utils }
VMX64InstructionTest >> disassembleInstructions [
	
	^ machineSimulator disassembler 
		disassembleNext: 15 instructionsIn: (machineSimulator memoryAt: initialAddress readNext: self getLastAddress - initialAddress + 1) startAddress: initialAddress pc: initialAddress

]

{ #category : #configuration }
VMX64InstructionTest >> generateCaptureCStackPointers [
	
	^ false
]

{ #category : #tests }
VMX64InstructionTest >> testDupAndStoreFromVectorRegister [

	| mem |

	self compile: [
		cogit MoveCq: 16r0123456789ABCDEF R: 2.
		cogit DupS: 64 R: 2 Vr: 0.
		cogit MoveCq: memory newSpaceStart R: 2.
		cogit St1S: 64 Vr: 0 R: 2 Mw: 16 ].
	
	self runGeneratedCode.
		
	mem := machineSimulator memoryAt: memory newSpaceStart + 16 readNext: 16. 	
		
	self 
		assert: mem 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

]

{ #category : #tests }
VMX64InstructionTest >> testDupSRVr [


	self compile: [
		cogit MoveCq: 16r0123456789ABCDEF R: 2.
		cogit DupS: 64 R: 2 Vr: 0].
	
	self runGeneratedCode.
		
	self 
		assert: machineSimulator xmm0 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

]
