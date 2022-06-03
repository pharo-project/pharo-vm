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
		
	mem := machineSimulator memoryAt: memory newSpaceStart readNext: 16. 	
		
	self 
		assert: mem 
		equals: #[16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 16rEF 16rCD 16rAB 16r89 16r67 16r45 16r23 16r01 ].

	self assert: machineSimulator rdx 
		equals: memory newSpaceStart + 16

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
