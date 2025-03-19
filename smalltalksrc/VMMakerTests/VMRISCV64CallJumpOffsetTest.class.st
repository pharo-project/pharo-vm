Class {
	#name : 'VMRISCV64CallJumpOffsetTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMRISCV64CallJumpOffsetTest class >> wordSizeParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'riscv64' . #wordSize -> 8};
		yourself
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallBigPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: cogInitialAddress + 16rBE8 ].
	
	self machineSimulator
			startAt: cogInitialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator linkRegisterValue equals: cogInitialAddress + cogit backend callInstructionByteSize.
	self assert: machineSimulator instructionPointerRegisterValue equals: cogInitialAddress + 16rBE8.
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallNegativeOffset [

	| callInstruction |
	self compile: [		 
		cogit Nop. cogit Nop. cogit Nop.
		callInstruction := cogit Call: cogInitialAddress ].

	self machineSimulator
			startAt: cogInitialAddress + 4
			until: cogInitialAddress
			timeout: 0
			count: 0.
	
	self assert: machineSimulator linkRegisterValue equals: cogInitialAddress + cogit backend callInstructionByteSize + 12 "3 nops".
	self assert: machineSimulator instructionPointerRegisterValue equals: cogInitialAddress.
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallNegativeOffsetRewriting [

	| callInstruction |
	self compile: [	
		cogit Nop. cogit Nop. cogit Nop. cogit Nop. cogit Nop.
		callInstruction := cogit Call: cogInitialAddress + 16rE8 ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteCallAt: cogInitialAddress + cogit backend jumpLongByteSize + 20 target: cogInitialAddress.
	self assert: (cogit backend callTargetFromReturnAddress: cogInitialAddress + cogit backend callInstructionByteSize + 20) equals: cogInitialAddress.
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: cogInitialAddress + 20 until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: cogInitialAddress
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: cogInitialAddress + 16rE8 ].
	
	self machineSimulator
			startAt: cogInitialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator linkRegisterValue equals: cogInitialAddress + cogit backend callInstructionByteSize.
	self assert: machineSimulator instructionPointerRegisterValue equals: cogInitialAddress + 16rE8.
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: (cogInitialAddress + 16rE8) ].
		
	self assert: (cogit backend callTargetFromReturnAddress: cogInitialAddress + cogit backend callInstructionByteSize) equals: (cogInitialAddress + 16rE8).
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffsetRewriting [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: cogInitialAddress + 16rBE8 ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteCallAt: cogInitialAddress + cogit backend jumpLongByteSize target: (cogInitialAddress + 16rAAA).
	self assert: (cogit backend callTargetFromReturnAddress: cogInitialAddress + cogit backend callInstructionByteSize) equals: (cogInitialAddress + 16rAAA).
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: cogInitialAddress until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: cogInitialAddress + 16rAAA
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongBigPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rBE8) ].
	self machineSimulator
			startAt: cogInitialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator instructionPointerRegisterValue equals: (cogInitialAddress + 16rBE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongBigPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rBE8) ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: cogInitialAddress + cogit backend jumpLongByteSize) equals: (cogInitialAddress + 16rBE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rE8) ].
	self machineSimulator
			startAt: cogInitialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator instructionPointerRegisterValue equals: (cogInitialAddress + 16rE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rE8) ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: cogInitialAddress + cogit backend jumpLongByteSize) equals: (cogInitialAddress + 16rE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffsetRewriting [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rE8) ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteJumpLongAt: cogInitialAddress + cogit backend jumpLongByteSize target: (cogInitialAddress + 16rAAA).
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: cogInitialAddress + cogit backend jumpLongByteSize) equals: (cogInitialAddress + 16rAAA).
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: cogInitialAddress until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: (cogInitialAddress + 16rAAA)


]
