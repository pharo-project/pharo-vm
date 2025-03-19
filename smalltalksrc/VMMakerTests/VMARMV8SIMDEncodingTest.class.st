Class {
	#name : 'VMARMV8SIMDEncodingTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'building suites' }
VMARMV8SIMDEncodingTest class >> wordSizeParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'aarch64'. #wordSize -> 8};
		yourself
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> armInstructionAt: index [

	| addr inst |
	addr := memory getMemoryMap codeZoneStart + ((index - 1) * 8).
	inst := memory uint32AtPointer: addr.
	
	^ inst aarch64Disassembled
]

{ #category : 'configuration' }
VMARMV8SIMDEncodingTest >> generateCaptureCStackPointers [
	
	^ false
]

{ #category : 'accessing' }
VMARMV8SIMDEncodingTest >> initializationOptions [

	^ super initializationOptions , { 
		#ProcessorClass . DummyProcessor }
]

{ #category : 'accessing' }
VMARMV8SIMDEncodingTest >> jitOptions [

	^ super jitOptions
		  at: #ProcessorClass
		  put: DummyProcessor;
		  yourself
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeDupWith64BitLanes [

	self compile: [ cogit DupS: 64 R: 3 Vr: 0 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'dup	v0.2d, x3'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeFaddWith32BitLanes [

	self compile: [ cogit FaddS: 32 Rv: 0 Rv: 1 Rv: 2 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'fadd	v2.4s, v0.4s, v1.4s'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeFaddWith64BitLanes [

	self compile: [ cogit FaddS: 64 Rv: 0 Rv: 1 Rv: 2 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'fadd	v2.2d, v0.2d, v1.2d'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeFsubWith64BitLanes [

	self compile: [ cogit FsubS: 64 Rv: 0 Rv: 1 Rv: 2 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'fsub	v2.2d, v0.2d, v1.2d'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeLd1WithOne32BitLaneRegisterAndImmediateOffset [

	self compile: [ cogit Ld1S: 32 Vr: 0 R: 1 Mw: 16 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'ld1	{ v0.4s }, [x1], #16'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeLd1WithOne64BitLaneRegisterAndImmediateOffset [

	self compile: [ cogit Ld1S: 64 Vr: 0 R: 1 Mw: 16 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'ld1	{ v0.2d }, [x1], #16'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeLd1WithOne64BitLaneRegisterAndNoOffset [

	self compile: [ cogit Ld1S: 64 Vr: 0 R: 1 Mw: 0 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'ld1	{ v0.2d }, [x1]'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeSt1WithOne32BitLaneRegisterAndImmediateOffset [

	self compile: [ cogit St1S: 32 Vr: 0 R: 1 Mw: 16 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'st1	{ v0.4s }, [x1], #16'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeSt1WithOne64BitLaneRegisterAndImmediateOffset [

	self compile: [ cogit St1S: 64 Vr: 0 R: 1 Mw: 16 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'st1	{ v0.2d }, [x1], #16'
]

{ #category : 'tests' }
VMARMV8SIMDEncodingTest >> testEncodeSt1WithOne64BitLaneRegisterAndNoOffset [

	self compile: [ cogit St1S: 64 Vr: 0 R: 1 Mw: 0 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'st1	{ v0.2d }, [x1]'
]
