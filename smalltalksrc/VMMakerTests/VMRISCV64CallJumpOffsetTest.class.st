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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 This test uses a 12-bit value with the 12th (sign) bit activated.
	 see concretizeCall for more details on how it is handled in practice."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 We check here that a negative offset call is correctly handled as well.
	 See concretizeCall for more details on how it is handled in practice."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time, then performed again for the new offset. See rewriteCallAt:target: for more details."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	 
	 This test uses a positive call offset < 12-bit.
	 See concretizeCall for more details on how it is handled in practice."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time. See extractOffsetFromCall for more details."

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: (cogInitialAddress + 16rE8) ].
		
	self assert: (cogit backend callTargetFromReturnAddress: cogInitialAddress + cogit backend callInstructionByteSize) equals: (cogInitialAddress + 16rE8).
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffsetRewriting [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time, then performed again for the new offset. See rewriteCallAt:target: for more details."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a jump long), 
	 the sign bit has to be correctly handled if it is activated.
	 
	 Long jumps are calls without links, the same 
	 This test uses a positive call offset < 12-bit with the sign bit active.
	 See concretizeJumpLong for more details on how it is handled in practice."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time. It uses the same logic as callTargetFromReturnAddress"

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rBE8) ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: cogInitialAddress + cogit backend jumpLongByteSize) equals: (cogInitialAddress + 16rBE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffset [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a jump long), 
	 the sign bit has to be correctly handled if it is activated.
	 
	 Long jumps are calls without links, the same 
	 This test uses a positive jump offset < 12-bit.
	 See concretizeJumpLong for more details on how it is handled in practice."

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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time. It uses the same logic as callTargetFromReturnAddress"

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: (cogInitialAddress + 16rE8) ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: cogInitialAddress + cogit backend jumpLongByteSize) equals: (cogInitialAddress + 16rE8).
	
]

{ #category : 'running' }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffsetRewriting [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated.
	
	 The encoding of those instruction is performed at concretization time and has to be reversed at extraction
	 time, then performed again for the new offset. See rewriteJumpLongAt:target: for more details."

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
