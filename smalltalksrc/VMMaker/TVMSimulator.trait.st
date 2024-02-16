Trait {
	#name : #TVMSimulator,
	#category : #VMMaker
}

{ #category : #initialization }
TVMSimulator >> openOn: fileName extraMemory: extraBytes [

	"CogVMSimulator new openOn: 'clone.im' extraMemory: 100000"

	"We set the memory manager if it is not already set"	
	self memoryManager ifNil: [	
		self memoryManager: MachineSimulatorMemoryManager new.
		self objectMemory memoryManager: self memoryManager.
		self memoryManager wordSize: self objectMemory wordSize.
	].

	"Set the image name and the first argument; there are
	 no arguments during simulation unless set explicitly."
	self systemAttributes
		at: 1 put: fileName;
		at: 2 put: nil.

	self simulationOnly: [ self setImageName: fileName  ].
	^ self imageReaderWriter readImageNamed: fileName 

]

{ #category : #'frame access' }
TVMSimulator >> withoutSmallIntegerTags: anInteger [
	| signBit |
	self assert: (anInteger >= 0 and: [anInteger highBit <= (self objectMemory wordSize * 8)]).
	signBit := 1 << (self objectMemory wordSize * 8 - 1).
	^(anInteger bitAnd: signBit) ~= 0
		ifTrue: ["negative"
				(anInteger bitClear: signBit + 1) - signBit]
		ifFalse: ["positive"
				anInteger - 1]
]
