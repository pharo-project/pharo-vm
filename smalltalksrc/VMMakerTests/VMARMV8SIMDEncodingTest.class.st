Class {
	#name : #VMARMV8SIMDEncodingTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'building suites' }
VMARMV8SIMDEncodingTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'aarch64'. #wordSize -> 8};
		yourself
]

{ #category : #tests }
VMARMV8SIMDEncodingTest >> armInstructionAt: index [

	| addr inst |
	addr := initialAddress + ((index - 1) * 8).
	inst := memory long32At: addr.
	
	^ inst aarch64Disassembled
]

{ #category : #configuration }
VMARMV8SIMDEncodingTest >> generateCaptureCStackPointers [
	
	^ false
]

{ #category : #accessing }
VMARMV8SIMDEncodingTest >> initializationOptions [

	^ super initializationOptions , { 
		#ProcessorClass . DummyProcessor }
]

{ #category : #accessing }
VMARMV8SIMDEncodingTest >> jitOptions [

	^ super jitOptions
		  at: #ProcessorClass
		  put: DummyProcessor;
		  yourself
]

{ #category : #tests }
VMARMV8SIMDEncodingTest >> testEncodeDupRVRWith64BitLanes [

	self compile: [ cogit DupS: 64 R: 3 VR: 0 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'dup	v0.2d, x3'
]

{ #category : #tests }
VMARMV8SIMDEncodingTest >> testEncodeSt1WithOne64BitLaneRegisterAndImmediateOffset [

	self compile: [ cogit St1S: 64 VR: 0 Mw: 1 O: 16 ].
	
	self
		assert: (self armInstructionAt: 1) assemblyCodeString
		equals: 'st1	{ v0.2d }, [x1], #16'
]
