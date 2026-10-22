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

{ #category : 'running' }
VMRISCV64SpecificEncodingTest >> initialCodeSize [
	"The branch range tests generate more than 4KB of code"

	^ 16 * 1024
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

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> doTestOperation: aSelector constants: constants expected: aBlock [
	"Compile aSelector (an xxCq:R: opcode) once per constant, each on its own register, and check each
	 register against aBlock value: initialValue value: constant.
	 I-type immediates are signed 12-bit: 2047 and -2048 fit, 2048 and -2049 must go through a literal."

	| registers setters getters initialValue |
	registers := { ReceiverResultReg. Arg0Reg. Arg1Reg. ClassReg. TempReg }.
	setters := #( #receiverRegisterValue: #arg0RegisterValue: #arg1RegisterValue: #classRegisterValue: #temporaryRegisterValue: ).
	getters := #( #receiverRegisterValue #arg0RegisterValue #arg1RegisterValue #classRegisterValue #temporaryRegisterValue ).
	self assert: constants size <= registers size.
	initialValue := 16r123456.

	self
		compile: [ constants withIndexDo: [ :constant :i | cogit perform: aSelector with: constant with: (registers at: i) ] ]
		bytecodes: 10.

	constants withIndexDo: [ :constant :i | machineSimulator perform: (setters at: i) with: initialValue ].
	self runGeneratedCode.

	constants withIndexDo: [ :constant :i |
		self
			assert: (machineSimulator perform: (getters at: i))
			equals: ((aBlock value: initialValue value: constant) bitAnd: 16rFFFFFFFFFFFFFFFF) ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> negativeBoundaryConstants [

	^ #( -2048 -2049 -2050 -4096 -4097 )
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> positiveBoundaryConstants [

	^ #( 2047 2048 2049 4095 4096 )
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testAddCqRNegativeBoundaryConstants [

	self doTestOperation: #AddCq:R: constants: self negativeBoundaryConstants expected: [ :v :c | v + c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testAddCqRPositiveBoundaryConstants [

	self doTestOperation: #AddCq:R: constants: self positiveBoundaryConstants expected: [ :v :c | v + c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testAndCqRNegativeBoundaryConstants [

	self doTestOperation: #AndCq:R: constants: self negativeBoundaryConstants expected: [ :v :c | v bitAnd: c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testAndCqRPositiveBoundaryConstants [

	self doTestOperation: #AndCq:R: constants: self positiveBoundaryConstants expected: [ :v :c | v bitAnd: c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testOrCqRNegativeBoundaryConstants [

	self doTestOperation: #OrCq:R: constants: self negativeBoundaryConstants expected: [ :v :c | v bitOr: c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testOrCqRPositiveBoundaryConstants [

	self doTestOperation: #OrCq:R: constants: self positiveBoundaryConstants expected: [ :v :c | v bitOr: c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testSubCqRNegativeBoundaryConstants [

	"SubCq is encoded as addi of the negated constant: 2048 cannot be, -2048 can"
	self doTestOperation: #SubCq:R: constants: self negativeBoundaryConstants expected: [ :v :c | v - c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testSubCqRPositiveBoundaryConstants [

	self doTestOperation: #SubCq:R: constants: self positiveBoundaryConstants expected: [ :v :c | v - c ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> doTestMoveMwrRAtOffsets: offsets [
	"Load words at offsets from one base register (ld's offset is a signed 12-bit immediate)"

	| destinations getters base |
	destinations := { ReceiverResultReg. Arg0Reg. Arg1Reg. TempReg }.
	getters := #( #receiverRegisterValue #arg0RegisterValue #arg1RegisterValue #temporaryRegisterValue ).
	"The middle of a 1100-slot object, so that +-4096 stays inside it"
	base := (self newObjectWithSlots: 1100) + 8 + 4400.

	self
		compile: [ offsets withIndexDo: [ :offset :i | cogit MoveMw: offset r: ClassReg R: (destinations at: i) ] ]
		bytecodes: 10.

	offsets withIndexDo: [ :offset :i | memory long64At: base + offset put: 16r1000 + i ].
	machineSimulator classRegisterValue: base.
	self runGeneratedCode.

	offsets withIndexDo: [ :offset :i |
		self assert: (machineSimulator perform: (getters at: i)) equals: 16r1000 + i ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> doTestMoveRMwrAtOffsets: offsets [
	"Store words at offsets from one base register (sd's offset is a signed 12-bit immediate)"

	| sources setters base |
	sources := { ReceiverResultReg. Arg0Reg. Arg1Reg. TempReg }.
	setters := #( #receiverRegisterValue: #arg0RegisterValue: #arg1RegisterValue: #temporaryRegisterValue: ).
	"The middle of a 1100-slot object, so that +-4096 stays inside it"
	base := (self newObjectWithSlots: 1100) + 8 + 4400.

	self
		compile: [ offsets withIndexDo: [ :offset :i | cogit MoveR: (sources at: i) Mw: offset r: ClassReg ] ]
		bytecodes: 10.

	offsets withIndexDo: [ :offset :i | machineSimulator perform: (setters at: i) with: 16r1000 + i ].
	machineSimulator classRegisterValue: base.
	self runGeneratedCode.

	offsets withIndexDo: [ :offset :i |
		self assert: (memory long64At: base + offset) equals: 16r1000 + i ]
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testMoveMwrRNegativeBoundaryOffsets [

	self doTestMoveMwrRAtOffsets: #( -2048 -2056 -4088 -4096 )
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testMoveMwrRPositiveBoundaryOffsets [

	self doTestMoveMwrRAtOffsets: #( 2040 2048 2056 4088 )
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testMoveRMwrNegativeBoundaryOffsets [

	self doTestMoveRMwrAtOffsets: #( -2048 -2056 -4088 -4096 )
]

{ #category : 'tests - immediate ranges' }
VMRISCV64SpecificEncodingTest >> testMoveRMwrPositiveBoundaryOffsets [

	self doTestMoveRMwrAtOffsets: #( 2040 2048 2056 4088 )
]

{ #category : 'tests - branch ranges' }
VMRISCV64SpecificEncodingTest >> testConditionalJumpOverMoreThan4KB [
	"Conditional branches (beq/bne...) have a signed 13-bit offset (+-4KB).
	 A conditional jump over more code than that must still reach its target"

	| jump |
	self
		compile: [
			cogit CmpR: ClassReg R: ClassReg.
			jump := cogit JumpZero: 0.
			1100 timesRepeat: [ cogit Nop ].
			cogit MoveCq: 2 R: ReceiverResultReg.
			jump jmpTarget: cogit Label.
			cogit Nop ]
		bytecodes: 120.

	machineSimulator receiverRegisterValue: 1.
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 1
]

{ #category : 'tests - branch ranges' }
VMRISCV64SpecificEncodingTest >> testConditionalJumpBackwardOverMoreThan4KB [
	"A loop whose body is more than 4KB: the backward conditional branch needs the long form"

	| loop |
	self
		compile: [
			loop := cogit Label.
			cogit AddCq: 1 R: ReceiverResultReg.
			1100 timesRepeat: [ cogit Nop ].
			cogit CmpCq: 3 R: ReceiverResultReg.
			cogit JumpLess: loop.
			cogit Nop ]
		bytecodes: 120.

	machineSimulator receiverRegisterValue: 0.
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 3
]

{ #category : 'tests - branch ranges' }
VMRISCV64SpecificEncodingTest >> testFPConditionalJumpOverMoreThan4KB [
	"FP branches are a compare into a register then a branch on it: the branch needs the long form too"

	| jump |
	self
		compile: [
			cogit CmpRd: DPFPReg0 Rd: DPFPReg0.
			jump := cogit JumpFPEqual: 0.
			1100 timesRepeat: [ cogit Nop ].
			cogit MoveCq: 2 R: ReceiverResultReg.
			jump jmpTarget: cogit Label.
			cogit Nop ]
		bytecodes: 120.

	machineSimulator receiverRegisterValue: 1.
	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 1
]

{ #category : 'tests - branch ranges' }
VMRISCV64SpecificEncodingTest >> testNearConditionalJumpKeepsShortForm [
	"A branch that reaches stays a single 4-byte B-type instruction (the compare is folded into it, the jump
	 instruction becomes the branch)"

	| jump |
	self
		compile: [
			cogit CmpR: ClassReg R: ClassReg.
			jump := cogit JumpZero: 0.
			10 timesRepeat: [ cogit Nop ].
			jump jmpTarget: cogit Label ]
		bytecodes: 20.

	self assert: jump machineCodeSize equals: 4
]

{ #category : 'tests - branch ranges' }
VMRISCV64SpecificEncodingTest >> testFarConditionalJumpUsesLongForm [
	"A branch over more than 4KB becomes the opposite branch over a jal: 8 bytes"

	| jump |
	self
		compile: [
			cogit CmpR: ClassReg R: ClassReg.
			jump := cogit JumpZero: 0.
			1100 timesRepeat: [ cogit Nop ].
			jump jmpTarget: cogit Label ]
		bytecodes: 120.

	self assert: jump machineCodeSize equals: 8
]

{ #category : 'tests - pc-relative addresses' }
VMRISCV64SpecificEncodingTest >> doTestPCRelativeAddressWithAUIPCField: high20 offset: low12 [
	"Write auipc t0, high20 + ld t0, low12(t0) and check pcRelativeAddressAt: decodes the address the hardware computes:
	 both immediates are sign-extended"

	| address |
	address := cogInitialAddress + 16r100.
	memory long32At: address put: (cogit backend addUpperImmediateToPC: high20 toRegister: 5).
	memory long32At: address + 4 put: (cogit backend loadDoubleWordFromAddressInRegister: 5 withOffset: low12 toRegister: 5).

	self assert: (cogit backend pcRelativeAddressAt: address) equals: address + (high20 << 12) + low12
]

{ #category : 'tests - pc-relative addresses' }
VMRISCV64SpecificEncodingTest >> testPCRelativeAddressWithNegativeAUIPCField [

	self doTestPCRelativeAddressWithAUIPCField: -1 offset: 16
]

{ #category : 'tests - pc-relative addresses' }
VMRISCV64SpecificEncodingTest >> testPCRelativeAddressWithNegativeOffset [

	self doTestPCRelativeAddressWithAUIPCField: 0 offset: -8
]

{ #category : 'tests - pc-relative addresses' }
VMRISCV64SpecificEncodingTest >> testPCRelativeAddressWithPositiveFieldAndOffset [

	self doTestPCRelativeAddressWithAUIPCField: 1 offset: 16r7F8
]

{ #category : 'tests - pc-relative addresses' }
VMRISCV64SpecificEncodingTest >> testLiteralMoreThan2KBAway [
	"Out-of-line literals are dumped after outOfLineLiteralOpcodeLimit opcodes, which can be more
	 than 2KB of code: the auipc + ld literal load must reach them"

	self
		compile: [
			cogit MoveCq: 16r123456789AB R: ReceiverResultReg.
			600 timesRepeat: [ cogit Nop ] ]
		bytecodes: 70.

	self runGeneratedCode.

	self assert: machineSimulator receiverRegisterValue equals: 16r123456789AB
]
