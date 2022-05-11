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

{ #category : #'tests - MoveRMwr' }
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
