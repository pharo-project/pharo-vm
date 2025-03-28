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

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r800 R: ReceiverResultReg ].
	
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode12BitImmediateB40 [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16rB40 R: ReceiverResultReg ].
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rB40
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode13BitImmediate [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r1800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r1800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode13BitNegativeImmediate [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: -16r1800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: (-16r1800 twoComplementOfBitSize: 64)
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode24BitImmediate [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16rFFFFFF R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFF
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode32BitImmediate [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r80000000 R: ReceiverResultReg ].
	
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r80000000
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode32BitImmediateWithLowerPart [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r80000800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r80000800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediate [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r7777777777777777 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r7777777777777777
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediate800 [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16r8000800800800800 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r8000800800800800
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediateF [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16rFFFFFFFFFFFFFFFF R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFFFFFFFFFFFF
]

{ #category : 'tests' }
VMRISCV64SpecificEncodingTest >> testEncode64BitImmediateFA1 [

	"RISC-V uses one single way to express immediate values: ALWAYS sign-extending them through their default
	 12-bit size. This means that when a larger immediate needs to be used (e.g. in a call), 
	 the sign bit has to be correctly handled if it is activated. It can even get worse when a large immediate
	 is directly embedded in the instruction without an out-of-line literals, a 64-bit immediate can lead to 8
	 RISC-V instructions.
	
	 Note that the initial purpose of these tests was to test this behaviour that was covered by out-of-line
	 literals in the end, as soon as immediates are > 12-bits"

	self compile: [		 
		cogit MoveCq: 16rFFFFFFFFFFFFFFA1 R: ReceiverResultReg ].

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16rFFFFFFFFFFFFFFA1
]
