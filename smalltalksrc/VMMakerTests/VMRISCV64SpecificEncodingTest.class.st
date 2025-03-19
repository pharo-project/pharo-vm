Class {
	#name : 'VMRISCV64SpecificEncodingTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest class >> wordSizeParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'riscv64' . #wordSize -> 8 };
		yourself
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode12BitImmediate [

	self compile: [		 
		cogit MoveCq: 16r800 R: ReceiverResultReg ].
	
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode12BitImmediateB40 [

	self compile: [		 
		cogit MoveCq: 16rB40 R: ReceiverResultReg ].
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rB40
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode13BitImmediate [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16r1800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r1800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode13BitNegativeImmediate [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: -16r1800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: (-16r1800 twoComplementOfBitSize: 64)
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode24BitImmediate [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16rFFFFFF R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFF
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode32BitImmediate [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16r80000000 R: ReceiverResultReg ].
	
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r80000000
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode32BitImmediateWithLowerPart [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16r80000800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r80000800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediate [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16r7777777777777777 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r7777777777777777
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediate800 [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16r8000800800800800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r8000800800800800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediateF [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16rFFFFFFFFFFFFFFFF R: ReceiverResultReg ].

	"1halt.
	self openMachineDebugger."
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFFFFFFFFFFFF
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediateFA1 [

	"Should lui addi"
	self compile: [		 
		cogit MoveCq: 16rFFFFFFFFFFFFFFA1 R: ReceiverResultReg ].

	"1halt.
	self openMachineDebugger."
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFFFFFFFFFFA1
]
