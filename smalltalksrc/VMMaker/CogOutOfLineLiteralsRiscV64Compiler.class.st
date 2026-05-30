Class {
	#name : 'CogOutOfLineLiteralsRiscV64Compiler',
	#superclass : 'CogRiscVCompiler',
	#instVars : [
		'conditionOrNil',
		'previousOperands',
		'previousOpcode'
	],
	#classVars : [
		'AddCheckOverflowCqR',
		'AddCheckOverflowRR',
		'BrEqualRR',
		'BrFPEqualRR',
		'BrFPGreaterEqualRR',
		'BrFPGreaterRR',
		'BrFPLessEqualRR',
		'BrFPLessRR',
		'BrFPNotEqualRR',
		'BrLongEqualRR',
		'BrLongNotEqualRR',
		'BrNotEqualRR',
		'BrSignedGreaterEqualRR',
		'BrSignedGreaterRR',
		'BrSignedLessEqualRR',
		'BrSignedLessRR',
		'BrUnsignedGreaterEqualRR',
		'BrUnsignedGreaterRR',
		'BrUnsignedLessEqualRR',
		'BrUnsignedLessRR',
		'CArg0Reg',
		'CArg1Reg',
		'CArg2Reg',
		'CArg3Reg',
		'CMPMULOverflow',
		'ConcreteCarryReg',
		'ConcreteIPFPReg',
		'ConcreteIPFPReg2',
		'ConcreteIPReg',
		'ConcreteIPReg2',
		'ConcreteIPReg3',
		'ConcreteOverflowReg',
		'ConcretePCReg',
		'ConcreteSignReg',
		'ConcreteVarBaseReg',
		'ConcreteZeroReg',
		'DivRR',
		'EQ',
		'F0',
		'F1',
		'F2',
		'F3',
		'F4',
		'F5',
		'F6',
		'F7',
		'FP',
		'GE',
		'GEU',
		'LR',
		'LT',
		'LTU',
		'MSTATUS',
		'MSUB',
		'MUL',
		'MulCheckOverflowRR',
		'MulRR',
		'NE',
		'PC',
		'RemRR',
		'SDIV',
		'SMULH',
		'SP',
		'SubCheckOverflowCqR',
		'SubCheckOverflowRR',
		'X0',
		'X1',
		'X10',
		'X11',
		'X12',
		'X13',
		'X14',
		'X15',
		'X16',
		'X17',
		'X18',
		'X19',
		'X2',
		'X20',
		'X21',
		'X22',
		'X23',
		'X24',
		'X25',
		'X26',
		'X27',
		'X28',
		'X29',
		'X3',
		'X30',
		'X31',
		'X4',
		'X5',
		'X6',
		'X7',
		'X8',
		'X9'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler class >> IPReg [
	^ConcreteIPReg
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> ISA [
	"Answer the name of the ISA the receiver implements."
	^#riscv64
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler class >> PCReg [
	^ConcretePCReg
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler class >> VarBaseReg [
	"Answer the number of the reg we use to hold the base address of CoInterpreter variables"
	^ConcreteVarBaseReg
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> defaultCompilerClass [
	^ CogOutOfLineLiteralsRiscV64Compiler
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> filteredInstVarNames [
	"Edit such that conditionOrNil is amongst the char size vars opcode machineCodeSize and maxSize."
	^(super filteredInstVarNames copyWithout: 'conditionOrNil')
		copyReplaceFrom: 5 to: 4 with: #('conditionOrNil')
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> identifyingPredefinedMacros [

	"The possible preprocessor definitions are: (extracted from https://github.com/riscv-non-isa/riscv-toolchain-conventions)
	__riscv: defined for any RISC-V target. Older versions of the GCC toolchain defined __riscv__.
	__riscv_xlen: 32 for RV32 and 64 for RV64.
	__riscv_float_abi_soft, __riscv_float_abi_single, __riscv_float_abi_double: one of these three will be defined, depending on target ABI.
	__riscv_cmodel_medlow, __riscv_cmodel_medany: one of these two will be defined, depending on the target code model.
	__riscv_mul: defined when targeting the 'M' ISA extension.
	__riscv_muldiv: defined when targeting the 'M' ISA extension and -mno-div has not been used.
	__riscv_div: defined when targeting the 'M' ISA extension and -mno-div has not been used.
	__riscv_atomic: defined when targeting the 'A' ISA extension.
	__riscv_flen: 32 when targeting the 'F' ISA extension (but not 'D') and 64 when targeting 'FD'.
	__riscv_fdiv: defined when targeting the 'F' or 'D' ISA extensions and -mno-fdiv has not been used.
	__riscv_fsqrt: defined when targeting the 'F' or 'D' ISA extensions and -mno-fdiv has not been used.
	__riscv_compressed: defined when targeting the 'C' ISA extension.	"
	^#('__riscv__' '__riscv')
]

{ #category : 'class initialization' }
CogOutOfLineLiteralsRiscV64Compiler class >> initialize [

	"Initialize various RISCV instruction-related constants."
	"CogRTLOpcodes initialize"
	"CogOutOfLineLiteralsRiscV64Compiler initialize might be required to make changes effective"
	
	super initialize.
	self ~~ CogOutOfLineLiteralsRiscV64Compiler ifTrue: [^self].

	"RISCV general registers"
	X0 := 0.
	X1 := 1.
	X2 := 2.
	X3 := 3.
	X4 := 4.
	X5 := 5.
	X6 := 6.
	X7 := 7.
	X8 := 8.
	X9 := 9.
	X10 := 10.
	X11 := 11.
	X12 := 12.
	X13 := 13.
	X14 := 14.
	X15 := 15.
	X16 := 16.
	X17 := 17.
	X18 := 18.
	X19 := 19.
	X20 := 20.
	X21 := 21.
	X22 := 22.
	X23 := 23.
	X24 := 24.
	X25 := 25.
	X26 := 26.
	X27 := 27. "Flag register"
	X28 := 28.
	X29 := 29.
	X30 := 30.
	X31 := 31.

	SP := X2. "Stack Pointer"
	LR := X1. "Link Register"
	FP := X8. "Frame Pointer"
	
	"RISCV Floating Point Registers"
	F0 := 0.
	F1 := 1.
	F2 := 2.
	F3 := 3.
	F4 := 4.
	F5 := 5.
	F6 := 6.
	F7 := 7.
	"Function arguments registers"
	CArg0Reg := X10.
	CArg1Reg := X11.
	CArg2Reg := X12.
	CArg3Reg := X13.
	
	ConcretePCReg := PC.
	"Base register that will serve as anchor to trampoline between stacks"
	ConcreteVarBaseReg := X26.
	"X5 and X6 are temporary registers used as the intra procedural scratch registers, they are not preserved accross calls"
	ConcreteIPReg := X5.
	ConcreteIPReg2 := X6.
	ConcreteIPReg3 := X7.
	ConcreteIPFPReg := F6.
	ConcreteIPFPReg2 := F7.
	
	"Flag Register"		
	ConcreteZeroReg := X28.
	ConcreteSignReg := X29.
	ConcreteOverflowReg := X30.
	ConcreteCarryReg := X31.
	
	
	"Branch Condition Codes"
	EQ  := 2r000. "Equal"
	NE  := 2r001. "Not equal"
	GE  := 2r101. "Greater or Equal"
	GEU := 2r111. "Greater or Equal Unsigned"
	LT  := 2r100. "Less Than"
	LTU := 2r110. "Less Than Unsigned"
	
	MSTATUS := 2r001100000000. "mstatus csr"
	
	"Specific opcodes"
	self initializeSpecificOpcodes: #(
		MulRR 
		DivRR 
		RemRR 
		AddCheckOverflowCqR
		AddCheckOverflowRR 
		SubCheckOverflowCqR
		SubCheckOverflowRR 
		MulCheckOverflowRR
		BrEqualRR
		BrNotEqualRR
		BrUnsignedLessRR
		BrUnsignedLessEqualRR
		BrUnsignedGreaterRR
		BrUnsignedGreaterEqualRR
		BrSignedLessRR
		BrSignedLessEqualRR
		BrSignedGreaterRR
		BrSignedGreaterEqualRR
		BrLongEqualRR
		BrLongNotEqualRR
		BrFPEqualRR
		BrFPNotEqualRR
		BrFPLessRR
		BrFPLessEqualRR
		BrFPGreaterRR
		BrFPGreaterEqualRR) 
	     in: thisContext method 
	
	"When inspecting the Assocation, use the following to add the class variable:
	(ClassVariable key: self key value: value)
    owningClass: CogRiscV64Compiler;
    become: self"
	
	
]

{ #category : 'class initialization' }
CogOutOfLineLiteralsRiscV64Compiler class >> initializeAbstractRegisters [

	"Assign the abstract registers with the identities/indices of the relevant concrete registers."

	super initializeAbstractRegisters.

	"https://en.wikichip.org/wiki/risc-v/registers
	Caller saved Registers:
	X1     | RA    | Return Address Register
	X5 -7  | T0-2  | Temporary Registers
	X10-11 | A0-1  | Function Arguments / Return Values Registers 
	X12-17 | A2-7  | Function Arguments 
	X28-31 | T3-6  | Temporary Registers 
	
	Callee saved registers:
	X2     | SP    | Stack Pointer 
	X8     | S0/FP | Saved Register / Frame Pointer 
	X9     | S1    | Saved Register
	X18-27 | S2-11 | Saved Registers 
	
	X1 is LR.
	X8 is SP."
	
	CallerSavedRegisterMask := self registerMaskFor: 13 and: 14.

	TempReg := X22.
	ClassReg := X23.
	ReceiverResultReg := X24.
	SendNumArgsReg := X25.
	SPReg := SP. "X2 is the machine stack pointer, we use the same" self assert: SP = X2.
	FPReg := FP. "X8 as the frame pointer" self assert: FP = X8.
	Arg0Reg := X13.	 "Overlaps with last CArg" 	
	Arg1Reg := X14.
	Extra0Reg := X18.  "These are callee saved registers"
	Extra1Reg := X19.
	Extra2Reg := X20.
	VarBaseReg := X26. self assert: ConcreteVarBaseReg = X26. "Base address for calls from machine code. Must be callee saved"
	RISCTempReg := X5. self assert: ConcreteIPReg = X5.
	LinkReg := LR. "X1 is ra" self assert: LR = X1.
	PCReg := PC. "PC has its dedicated register "

	NumRegisters := 16.

	DPFPReg0 := F0.
	DPFPReg1 := F1.
	DPFPReg2 := F2.
	DPFPReg3 := F3.
	DPFPReg4 := F4.
	DPFPReg5 := F5.
	DPFPReg6 := F6.
	DPFPReg7 := F7.

	"Placeholders for now, need to add the V extension and corresponding registers"
	VReg0 := F0.
	VReg1 := F1.
	VReg2 := F2.
	VReg3 := F3.
	VReg4 := F4.
	VReg5 := F5.
	VReg6 := F6.
	VReg7 := F7.

	NumFloatRegisters := 8
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler class >> isRISCTempRegister: reg [
	"For tests to filter-out bogus values left in the RISCTempRegister, if any."
	self flag: #TODO.
	^ (reg = ConcreteIPReg) or: [(reg = ConcreteIPReg2) or: (reg = ConcreteIPReg3)]
]

{ #category : 'accessing class hierarchy' }
CogOutOfLineLiteralsRiscV64Compiler class >> literalsManagerClass [
	^OutOfLineLiteralsManager
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> machineCodeDeclaration [
	"Answer the declaration for the machineCode array.
	 ARM instructions are 32-bits in length."
	^{#'unsigned int'. '[', self basicNew machineCodeWords printString, ']'}
]

{ #category : 'class initialization' }
CogOutOfLineLiteralsRiscV64Compiler class >> specificOpcodes [
	"Answer the processor-specific opcodes for this class.
	 They're all in an Array literal in the initialize method."
	^(self class >> #initialize) literals detect: [:l| l isArray and: [l includes: #LDMFD]]
]

{ #category : 'translation' }
CogOutOfLineLiteralsRiscV64Compiler class >> wordSize [
	"This is a 64-bit ISA"
	^8
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> addImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"addi: Adds the sign-extended immediate to register x[rs1] and writes the result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                 20  19   15  14  12  11  7  6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0010011  |
	"
	
	| signExtendedImmediate |
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ ((((signExtendedImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> addRegister: sourceRegister1 toRegister: sourceRegister2 inRegister: destinationRegister [

	"add: Adds register x[rs2] to register x[rs1] and writes the result to x[rd]. 
	Arithmetic overflow is ignored.
	
	31        25 24   20 19   15 14  12  11  7  6         0
	|  	0000000  |  rs2  |  rs1  |  000  |  rd  |  0110011  |
	"
	
	^ ((((sourceRegister2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceRegister1 bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0110011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> addUpperImmediateToPC: anImmediate toRegister: destinationRegister [

	"auipc: Adds the sign-extended 20-bit immediate, left-shifted by 12 bits, to the pc, and writes the result to x[rd].
	
	31                  12  11    7  6         0
	|  	immediate[31:12]  |   rd   |   0010111  |
	"

	| signExtendedImmediate |
	"Check size and sign"	
	self assertValue: anImmediate isContainedIn: 32.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 32.
	^ (((signExtendedImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0010111
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> addWordImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"addiw: Adds the sign-extended immediate to register x[rs1], truncates the result to 32 bits, 
	 and writes the sign-extended result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                20 19    15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0011011  |
	"
	
	| signExtendedImmediate |
	self flag: #CLEANUP.
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ ((((signExtendedImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0011011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> addWordRegister: sourceRegister1 toRegister: sourceRegister2 inRegister: destinationRegister [

	"addw: Adds register x[rs2] to register x[rs1], truncates the result to 32 bits, 
	 and writes the sign-extended result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31        25 24   20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2  |  rs1  |  000  |  rd  | 0111011  |
	"

	self flag: #CLEANUP.
	^ ((((sourceRegister1 bitAnd: 16r1f) << 20) 
	  bitOr: (sourceRegister2 bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0111011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> arithmeticShiftRightValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"srai: Shifts register x[rs1] right by shamt bit positions. 
	 The vacated bits are filled with copies of x[rs1] MSB, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  010000 |  shamt  |  rs1  |  101  |  rd  |  0010011  |
	"

	^ ((((((2r1 << 30) 
	  bitOr: ((shiftAmount bitAnd: 16r3f) << 20))
	  bitOr: (sourceReg bitAnd: 16r1f) << 15))
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> arithmeticShiftRightValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"sra: Shifts register x[rs1] right by x[rs2] bit positions. 
	 The vacated bits are filled with copies of x[rs1] MSB, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0100000 |  rs2  |  rs1  |  101  |  rd  |  0110011  |
	"

	^ ((((((2r1 << 30) 
	  bitOr: ((sourceReg2 bitAnd: 16r3f) << 20))
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15))
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : 'helpers - size sign' }
CogOutOfLineLiteralsRiscV64Compiler >> assertValue: aValue isContainedIn: aSize [ 

	"Checks that the given value is contained in a certain number of bits"
	self assert: (self value: aValue isContainedIn: aSize)
]

{ #category : 'register allocation' }
CogOutOfLineLiteralsRiscV64Compiler >> availableRegisterOrNoneFor: liveRegsMask [
	"Answer an unused abstract register in the liveRegMask.
	 Subclasses with more registers can override to answer them.
	 N.B. Do /not/ allocate TempReg."
	<returnTypeC: #sqInt>
	(cogit register: Extra0Reg isInMask: liveRegsMask) ifFalse:
		[^Extra0Reg].
	(cogit register: Extra1Reg isInMask: liveRegsMask) ifFalse:
		[^Extra1Reg].
	(cogit register: Extra2Reg isInMask: liveRegsMask) ifFalse:
		[^Extra2Reg].
	^super availableRegisterOrNoneFor: liveRegsMask
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg andImmediate: anImmediate toRegister: destReg [
	
	"andi: Computes the bitwise AND of registers x[rs1] and sign extended immediate and writes the result to x[rd].
	
	31                20 19   15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1  |  111  |  rd  |  0010011 
	"
	| signExtendedImmediate |
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: 2r111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg [
	
	"and: Computes the bitwise AND of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31        25 24    20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2   |  rs1  |  111  |  rd  |  0110011 
	"
	
	^ (((((sourceReg2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseOrBetweenRegister: sourceReg andImmediate: anImmediate toRegister: destReg [
	
	"ori: Computes the bitwise OR of register x[rs1] and the sign-extended immediate and writes the result to x[rd].
	
	31                20 19   15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1  |  110  |  rd  |  0010011 
	"
	| signExtendedImmediate |
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.	
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseOrBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg [
	
	"or: Computes the bitwise OR of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31        25 24    20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2   |  rs1  |  110  |  rd  |  0110011 
	"
	
	^ (((((sourceReg2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseXorBetweenRegister: srcReg andImmediate: immediate intoRegister: destReg [

	"xori: Computes the bitwise exclusive-OR of the sign-extended immediate
	 and register x[rs1] and writes the result to x[rd]
	
	 31               20 19   15 14   12 11     7 6         0
	|  	immediate[11:0]  |  rs1  |  100  |   rd   |  0010011  |
	"

	| signExtendedImmediate |	
	"Check for sign and size"
	self assertValue: immediate isContainedIn: 12.	
	signExtendedImmediate :=	self computeSignedValueOf: immediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> bitwiseXorBetweenRegister: srcReg1 andRegister: srcReg2 intoRegister: destReg [

	"xor: Computes the bitwise exclusive-OR of registers x[rs1] and x[rs2] 
	 and writes the result to x[rd]
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0000000  |  rs2  |  rs1  |  100  |   rd   |  0110011  |
	"

	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifCondition: condition betweenRegister: srcReg1 andRegister: srcReg2 [ 

	"Offset handling common to all branches. The condition is the three bit code.
	
	31                25 24   20 19   15 14         12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  condition  | offset[4:1|11] | 1100011 
	"	

	| signExtendedOffset |
	 "Check size and sign"	
	self assertValue: offset isContainedIn: 13.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 13.
	^ (((((((((signExtendedOffset >> 12) bitAnd: 16r1) << 31)
	  bitOr: ((signExtendedOffset >> 5) bitAnd: 16r3f)  << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f)  << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f)  << 15)
	  bitOr: (condition bitAnd: 16r7) << 12)
	  bitOr: ((signExtendedOffset >> 1) bitAnd: 16rf)   << 8)
	  bitOr: ((signExtendedOffset >> 11) bitAnd: 16r1)  << 7)
	  bitOr: 2r1100011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isEqualToRegisterValue: srcReg2 [
	
	"beq: If register x[rs1] equals x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  000  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg1 andRegister: srcReg2
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanOrEqualRegisterValue: srcReg2 [
	
	"bge: If register x[rs1] is greater than or equal x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  101  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanRegisterValue: srcReg2 [
	
	"bgt: Pseudo-instruction that adds the offset to the PC if x[rs1] > x[rs2] 
	 Expands to blt rs2, rs1, offset
	"
	
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanOrEqualRegisterValue: srcReg2 [
	
	"ble: Pseudo-instruction that adds the offset to the PC if x[rs1] <= x[rs2] 
	 Expands to bge rs2, rs1, offset
	"
	
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanRegisterValue: srcReg2 [
	
	"blt: If register x[rs1] is less than x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  100  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg1 andRegister: srcReg2
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isNotEqualToRegisterValue: srcReg2 [
	
	"bne: If register x[rs1] does not equal x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  001  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueIsEqualToZero: srcReg [
	
	"beqz: Pseudo instruction that branches to the offset if the value in the register is 0
	Expands to beq x[rs1], x0, offset
 	"
	
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueIsNegative: srcReg [
	
	"bltz: Pseudo instruction that branches to the offset if the value in the register is < 0
	Expands to blt x[rs1], x0, offset
 	"
	self flag: #CLEANUP.
	^ self branchTo: offset ifRegisterValue: srcReg isLessThanRegisterValue: X0
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueIsNonNegative: srcReg [
	
	"bgtz: Pseudo instruction that branches to the offset if the value in the register is > 0
	Expands to blt x0, x[rs1], offset
 	"
	self flag: #CLEANUP.
	^ self branchTo: offset ifRegisterValue: X0 isLessThanRegisterValue: srcReg
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueIsNotEqualToZero: srcReg [
	
	"bnez: Pseudo instruction that branches to the offset if the value in the register is not 0
	Expands to bne x[rs1], x0, offset
 	"
	
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isGreaterThanOrEqualRegisterValueUnsigned: srcReg2 [
	
	"bgeu: If register x[rs1] is greater than or equal x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  111  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: GEU betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isGreaterThanRegisterValueUnsigned: srcReg2 [

	"bgtu: If register x[rs1] is greater than x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	Expands to: bltu x[rs2], x[rs1], offset
	"
	
	^ self branchTo: offset ifCondition: LTU betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isLessThanOrEqualRegisterValueUnsigned: srcReg2 [

	"bleu If register x[rs1] is less than or equal x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	Expands to: bgeu x[rs2], x[rs1], offset
	"
	
	^ self branchTo: offset ifCondition: GEU betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isLessThanRegisterValueUnsigned: srcReg2 [
	
	"bltu: If register x[rs1] is less than x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  110  | offset[4:1|11] | 1100011 
	"
	
	^ self branchTo: offset ifCondition: LTU betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> byteReadsZeroExtend [
	^true
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesForArithmeticFlagUpdate [ 
	"Return the number of bytes needed to update the flags, 
     zero flag setting 
     carry flag setting 
     sign flag setting"
	self flag: #CLEANUP.
	^ 12
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesForCMPCq [
	
	| loadOffset | 
	self flag: #CLEANUP.
	(self value: (operands at: 0) isContainedIn: 12)
		ifTrue: [ loadOffset := self bytesToLoadImmediate: (operands at: 0) ] "Immediate embedded in operations" 
		ifFalse: [ loadOffset := self literalLoadInstructionBytes ].
	^ loadOffset + self bytesForSUBOverflowCheck + self bytesForArithmeticFlagUpdate + 4

	
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesForDataLoadOperationOfSize: operationSize andImmediateOperationSize: immOperationSize [
	
	"When loading, the offset is operands at 0"
	dependent
		ifNil: [ 
			self assertValue: (operands at: 0) isContainedIn: 12.
			^ immOperationSize ].
	^ self literalLoadInstructionBytes + operationSize 
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesForDataStoreOperationOfSize: operationSize andImmediateOperationSize: immOperationSize [
	
	"When storing, the offset is operands at 1"
	dependent
		ifNil: [ 
			self assertValue: (operands at: 1) isContainedIn: 12.
			^ immOperationSize ].
	^ self literalLoadInstructionBytes + operationSize 
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesForSUBOverflowCheck [ 

	self flag: #CLEANUP.
	^ 16
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> bytesToLoadImmediate: anImmediate [ 

	"Returns the number of bytes (instructions * 4) needed to generate"
	<inline:true>
	^ 8
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> cResultRegister [
	"Answer the register through which C funcitons return integral results."
	<inline: true>
	^X10
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> cStackPointer [
	
	^ SP
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> callInstructionByteSize [

	^ 8
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> callTargetFromReturnAddress: callSiteReturnAddress [
	
	"Answer the address that the call immediately preceding callSiteReturnAddress will jump to."
	| callAddress callDistance |
	"Check if an alignment NOP is present. Needed for compilePolymorphicICPrototype since an OutOfLineLiteralsManager
	 may add alignment nops at the end of the PIC entry."
	callAddress := self instructionAddressBefore: callSiteReturnAddress.
	(self instructionIsNOP: (objectMemory long32At: callAddress))
		ifTrue: [ callAddress:= callAddress -4 ].
	self assert: (self instructionIsAUIPC:  (objectMemory long32At: callAddress - 4)).
	self assert: (self instructionIsJALR:  (objectMemory long32At: callAddress)).
	callDistance := self extractOffsetFromCall: callAddress.
	^ callAddress + callDistance - 4
	
	
	
	
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> canDivQuoRem [
	^true
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> canMulRR [
"we can do a MulRR be we can't simulate it correctly for some reason. More bug-fixing in the simulator one day"
	^true
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> checkSUBFloatingPointOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow
	 sub    res,  src1,  src2 
  	 fcvt   tfp,  x0,    tfp      # put 0 in tfp  
	 flt.d  t1,   src2,  tfp      # t1 = (src2 < 0)
    flt.d  t2,   res,   src1     # t2 = (src1 - src2 < res)
    bne    t1,   t2,    offset   # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (underflow)
                                            || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (overflow) 

	Except the branching is a verification for equality (not equal => overflow)"
	self flag: #CLEANUP.
	"As there is no hardwire fp zero we need to get one by converting X0"
	self machineCodeAt: index put: (self fConvertLongSignedInRegister: X0 toDoublePrecisionInRegister: ConcreteIPFPReg).
	"1. Check if one operand is negative"
	self machineCodeAt: index + 4 put: (self fSetOneIn: ConcreteIPReg2 ifRegisterValue: srcReg2 isLessThanRegisterValue: ConcreteIPFPReg).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 8 put: (self fSetOneIn: ConcreteIPReg3 ifRegisterValue: destReg isLessThanRegisterValue: srcReg1).
	"Check if both registers are equal -> xor and complement"
	self machineCodeAt: index + 12 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg).
	^ machineCodeSize := 16
	  
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> checkSUBOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow, as according to the example in the book: 
	 sub   res,  src1,  src2    # res = src1 - src2 
    slti  t1,   src2,  0       # t1 = (src2 < 0)
    slt   t2,   res,   src1    # t2 = (src1 - src2 < res)
    be    t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (overflow)
                                          || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (underflow) 

	As we will not branch directly, we need to check if the two conditions are equal 
	and set the overflow flag acordingly: different => no overflow"
	self flag: #CLEANUP.
   "1. Check if one operand is negative, OR EQUAL TO ZERO"
	self machineCodeAt: index put: (self setOneIn: ConcreteIPReg2 ifValueIn: srcReg2 isLessThanImmediate: 1). 
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteIPReg3 ifValueIn: destReg isLessThanValueIn: srcReg1).
	"Put one if t2 = t3, xor and complement"
	self machineCodeAt: index + 8 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg).
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteOverflowReg ifValueInRegisterIsEqualToZero: ConcreteOverflowReg).
	^ machineCodeSize := 16 
	  
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> cmpC32RTempByteSize [
	^8
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> codeGranularity [
	"Answer the size in bytes of a unit of machine code."
	<inline: true>
	^4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> computeMaximumSize [

	"Because we don't use compressed instructions, each RISC-V instruction has 4 bytes. Many
	 abstract opcodes need more than one instruction. Instructions that refer
	 to constants and/or literals depend on literals being stored in-line or out-of-line.

	 N.B.  The ^N forms are to get around the bytecode compiler's long branch
	 limits which are exceeded when each case jumps around the otherwise."

	opcode caseOf: { 
			([ Label ]         -> [ ^ 0 ]).
			([ Literal ]       -> [ ^ 8 ]).
			([ AlignmentNops ] -> [ ^ (operands at: 0) - 4 ]).
			([ Fill32 ]        -> [ ^ 4 ]).
			([ Nop ]           -> [ ^ 4 ]). 
			"Branches"
			([ BrEqualRR ]                 -> [ ^ 4 ]).
			([ BrNotEqualRR ]              -> [ ^ 4 ]).
			([ BrSignedGreaterRR ]         -> [ ^ 4 ]).
			([ BrSignedGreaterEqualRR ]    -> [ ^ 4 ]).
			([ BrSignedLessRR ]            -> [ ^ 4 ]).
			([ BrSignedLessEqualRR ]       -> [ ^ 4 ]).
			([ BrUnsignedLessRR ]          -> [ ^ 4 ]).
			([ BrUnsignedLessEqualRR ]     -> [ ^ 4 ]).
			([ BrUnsignedGreaterRR ]       -> [ ^ 4 ]).
			([ BrUnsignedGreaterEqualRR ]  -> [ ^ 4 ]).
			([ BrLongEqualRR ]             -> [ ^ 12 ]).
			([ BrFPEqualRR ]               -> [ ^ 8 ]).
			([ BrFPNotEqualRR ]            -> [ ^ 8 ]).
			([ BrFPLessRR ]                -> [ ^ 8 ]).
			([ BrFPLessEqualRR ]           -> [ ^ 8 ]).
			([ BrFPGreaterRR ]             -> [ ^ 8 ]).
			([ BrFPGreaterEqualRR ]        -> [ ^ 8 ]).
			
			"Overflow"
			([ AddCheckOverflowRR ]       -> [ ^ 16 ]).
			([ AddCheckOverflowCqR ]      -> [ dependent ifNil: [ ^ 16 ]. ^ self literalLoadInstructionBytes + 16 ]).
			([ SubCheckOverflowRR ]       -> [ ^ 16 ]).
			([ SubCheckOverflowCqR ]      -> [ dependent ifNil: [ ^ 16 ]. ^ self literalLoadInstructionBytes + 16 ]).
			([ MulCheckOverflowRR ]       -> [ ^ 16 ]).	
				
			"Control"
			([ Call ]                 -> [ ^ self callInstructionByteSize ]).
			([ CallFull ]             -> [ ^ self literalLoadInstructionBytes + 4 ]).
			([ JumpR ]                -> [ ^ 4 ]).
			([ Jump ]                 -> [ ^ 4 ]).
			([ JumpFull ]             -> [ ^ self literalLoadInstructionBytes + 4 ]).
			([ JumpLong ]             -> [ ^ self jumpLongByteSize ]).
			([ RetN ] -> [ ^ (operands at: 0) = 0 ifTrue: [ 4 ] ifFalse: [ 8 ] ]).
			([ Stop ] -> [ ^ 4 ]).
			
			"Next jumps are overwritten by branches in noteFollowingConditional:"
			([ JumpZero ]             -> [ ^ 0 ]).
			([ JumpNonZero ]          -> [ ^ 0 ]).
			([ JumpNegative ]         -> [ ^ 0 ]).
			([ JumpNonNegative ]      -> [ ^ self notYetImplemented ]).
			([ JumpOverflow ]         -> [ ^ 0 ]).
			([ JumpNoOverflow ]       -> [ ^ 0 ]).
			([ JumpCarry ]            -> [ ^ self notYetImplemented ]).
			([ JumpNoCarry ]          -> [ ^ self notYetImplemented ]).
			([ JumpLess ]             -> [ ^ 0 ]).
			([ JumpGreaterOrEqual ]   -> [ ^ 0 ]).
			([ JumpGreater ]          -> [ ^ 0 ]).
			([ JumpLessOrEqual ]      -> [ ^ 0 ]).
			([ JumpBelow ]            -> [ ^ 0 ]).
			([ JumpAboveOrEqual ]     -> [ ^ 0 ]).
			([ JumpAbove ]            -> [ ^ 0 ]).
			([ JumpBelowOrEqual ]     -> [ ^ 0 ]).
			([ JumpLongZero ]         -> [ ^ 0 ]).
			([ JumpLongNonZero ]      -> [ ^ 0 ]).
			([ JumpFPEqual ]          -> [ ^ 0 ]).
			([ JumpFPNotEqual ]       -> [ ^ 0 ]).
			([ JumpFPLess ]           -> [ ^ 0 ]).
			([ JumpFPGreaterOrEqual ] -> [ ^ 0 ]).
			([ JumpFPGreater ]        -> [ ^ 0 ]).
			([ JumpFPLessOrEqual ]    -> [ ^ 0 ]).
			([ JumpFPOrdered ]        -> [ ^ self notYetImplemented ]).
			([ JumpFPUnordered ]      -> [ ^ self notYetImplemented ]).
			
			"Logic"
			([ AndCqR ]  -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]). 
			([ AndCqRR ] -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ AndCwR ]  -> [ ^ self literalLoadInstructionBytes + 4 ]).
			([ AndRR ]   -> [ ^ 4 ]).
			([ OrCqR ]   -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ OrCwR ]   -> [ ^ self literalLoadInstructionBytes + 4 ]).
			([ OrRR ]    -> [ ^ 4 ]).
			([ TstCqR ]  -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4  ]). 
			([ XorCqR ]  -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4  ]).
			([ XorCwR ]  -> [  ^ self literalLoadInstructionBytes + 4 ]).
			([ XorRR ]   -> [ ^ 4 ]).
			
			"Arithmetic"
			([ AddCqR ] -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ AddCwR ] -> [ ^ self literalLoadInstructionBytes + 4 ]). 
			([ AddRR ]  -> [ ^ 4 ]).
			([ LoadEffectiveAddressMwrR ]
				 -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ SubCqR ]  -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]). 
			([ SubCwR ]  -> [ ^ self literalLoadInstructionBytes + 4 ]).
			([ SubRR ]   -> [ ^ 4 ]).
			([ MulRR ]   -> [ ^ 4 ]).
			([ DivRR ]   -> [ ^ 4 ]).
			([ RemRR ]   -> [ ^ 4 ]).
			([ NegateR ] -> [ ^ 4 ]).
		
			([ CmpCqR ] -> [ (self value: (operands at: 0) isContainedIn: 12)
				ifTrue: [ ^ self bytesToLoadImmediate: (operands at: 0) + 4 ] "Immediate embedded in operations" 
				ifFalse: [ ^ self literalLoadInstructionBytes + 4 ]. ]). 
			([ CmpC32R ] -> [ ^ 0 ]).
			([ CmpCwR ]  -> [ ^ 0 ]).
			([ CmpRR ]   -> [ ^ 0 ]).

			"Bit shifts"
			([ LogicalShiftLeftCqR ]     -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ LogicalShiftRightCqR ]    -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ ArithmeticShiftRightCqR ] -> [ dependent ifNil: [ ^ 4 ]. ^ self literalLoadInstructionBytes + 4 ]).
			([ LogicalShiftLeftRR ]      -> [ ^ 4 ]).
			([ LogicalShiftRightRR ]     -> [ ^ 4 ]).
			([ ArithmeticShiftRightRR ]  -> [ ^ 4 ]).
			([ RotateLeftCqR ]  -> [ dependent ifNil: [ ^ 12 ]. ^ self literalLoadInstructionBytes + 16 ]).
			([ RotateRightCqR ] -> [ dependent ifNil: [ ^ 12 ]. ^ self literalLoadInstructionBytes + 16 ]).

			"Floating point operations"
			([ AddRdRd ] -> [ ^ 4 ]).
			([ SubRdRd ] -> [ ^ 4 ]).
			([ CmpRdRd ] -> [ ^ 8 ]).
			([ MulRdRd ] -> [ ^ 4 ]).
			([ DivRdRd ] -> [ ^ 8 ]).
			([ SqrtRd ]  -> [ ^ 4 ]).
			([ XorRdRd ] -> [ ^ 4 ]).
			
			"Pop/Push"
			([ PopR ]   -> [ ^ 8 ]).
			([ PushR ]  -> [ ^ 8 ]).
			([ PushCw ] -> [ ^ self literalLoadInstructionBytes + 8 ]).
			([ PushCq ] -> [ dependent
				 ifNil: [ ^ (self bytesToLoadImmediate: (operands at: 0)) + 8 ]
				 ifNotNil: [ ^ self literalLoadInstructionBytes + 8 ] ]).

			"Conversion"
			([ ConvertRdRs ] -> [ ^ 4 ]). "DONE"
			([ ConvertRsRd ] -> [ ^ 4 ]). "DONE"
			([ ConvertRRd ] -> [ ^ 4 ]). "DONE"
			([ MoveRdR ] -> [ ^ 4 ]). "DONE"
			([ MoveRRd ] -> [ ^ 4 ]). "DONE"
			
			"Prefetch operation"
			([ PrefetchAw ] -> [ ^ 0 ]).
			
			"Data Movement - Basic"
			([ MoveCqR ] -> [ 
			 dependent
				 ifNil: [ 
					 | cq |
					 cq := operands at: 0.
					 self assertValue: cq isContainedIn: 12.
					 ^ self bytesToLoadImmediate: cq ]
				 ifNotNil: [ "Literal load" ^ self literalLoadInstructionBytes ] ]).
			([ MoveC32R ] -> [ ^ 0 ]). "shouldBeImplemented"
			([ MoveCwR ] -> [ ^ 8 "always a auipc addi/ld sequence" ]).
			([ MoveRR ] -> [ ^ 4 ]).

			"Data movement - Absolute addresses"
			([ MoveAwR ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 0))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveRAw ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 1))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveAbR ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 0))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveRAb ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 1))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).

			"Data Movement - Stores"
			([ MoveRM8r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRMbr ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRM16r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRM32r ] -> [ 
			^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRMwr ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRsM32r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveRdM64r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).

			"Data Movement - Loads"
			([ MoveM8rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveMbrR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveM16rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveM32rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveMwrR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveM32rRs ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).
			([ MoveM64rRd ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]).

			"Data Movement - Relative addresses with multiply"
			([ MoveXbrRR ] -> [ ^ 8 ]).
			([ MoveX32rRR ] -> [ ^ 12 ]).
			([ MoveXwrRR ] -> [ ^ 12 ]).
			([ MoveRX32rR ] -> [ ^ 12 ]).
			([ MoveRXbrR ] -> [ ^ 8 ]).
			([ MoveRXwrR ] -> [ ^ 12 ]).	
			
			"This is a fixed size instruction using a literal. We need exactly 2 instructions to move a literal from a PC relative position, so this takes ALWAYS 2 instructions of 4 bytes"
			([ MovePatcheableC32R ] -> [ ^ 8 ]). 
			
			"SIMD instructions"
			([DupRVr]		 -> [ ^ 0 ]).
			([St1VrRMw]   -> [ ^ 0 ]).
			([Ld1VrRMw]   -> [ ^ 0 ]).
			([AlignedSt1VrRMw ] -> [ ^ 0 ]).
	
			([FaddSRvRvRv] -> [ ^ 0 ]).
			([FsubSRvRvRv] -> [ ^ 0 ]).
			}.
	"Noops & Pseudo Ops"
	^ 0 "to keep C compiler qui Unmatched "
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> computeSignedValue64Bits: aValue [ 

	^ self computeSignedValueOf: aValue ofSize: 64
]

{ #category : 'helpers - size sign' }
CogOutOfLineLiteralsRiscV64Compiler >> computeSignedValueOf: aValue ofSize: aSize [

	"If the number is negative, returns two's complement in given size, otherwise return the value"
	aValue < 0
		ifTrue: [ | mask |
			mask := (1 << aSize) - 1.
			^ mask - aValue abs + 1 ]  "Compute two's complement" 
		ifFalse: [ ^ aValue ]
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddCheckOverflowCqR [
	"Check for the overflow, as according to the example in the book: 
	 add   res,  imm,  src 
    slti  t1,   src,   0       # t1 = (src < 0)
    slt   t2,   res,   imm     # t2 = (src + imm < res)
	 * since res and src are equal we have to res to another result then move back
    bne   t1,   t2,    offset  # overflow if (src < 0) && (src + imm >= res)  case 1 0 (underflow)
                                          || (src >= 0) && (src + imm < t0)   case 0 1 (overflow)

	(look at concretizeAddCheckOverflowRR for info on overflow checking between two registers)"
	<var: #cq type: #sqInt>
	<inline: true>
	| cq srcReg destReg loadOffset |
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Perform the ADD operation"
		self machineCodeAt: 0 put: (self
			addImmediate: cq
			toRegister: srcReg
			inRegister: ConcreteOverflowReg).
		"1. Check if one operand is negative"
		self machineCodeAt: 4 put: (self 
			setOneIn: ConcreteIPReg2 
			ifValueIn: srcReg
			isLessThanImmediate: 0).
		"2. Check if the sum is smaller than one operand"
		self machineCodeAt: 8 put: (self 
			setOneIn: ConcreteIPReg3 
			ifValueIn: ConcreteOverflowReg 
			isLessThanImmediate: cq).
		"3. Move result to destination register"
		self machineCodeAt: 12 put: (self 
			moveRegister: ConcreteOverflowReg toRegister: destReg).
		^ machineCodeSize := 16 ].
	
	"Otherwise, use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the ADD operation"
	self machineCodeAt: loadOffset put: (self
		addRegister: srcReg
		toRegister: ConcreteIPReg
		inRegister: ConcreteOverflowReg).
	"1. Check if one operand is negative"
	self machineCodeAt: loadOffset + 4 put: (self 
		setOneIn: ConcreteIPReg2 
		ifValueIn: ConcreteIPReg
		isLessThanImmediate: 0).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: loadOffset + 8 put: (self 
		setOneIn: ConcreteIPReg3 
		ifValueIn: ConcreteOverflowReg 
		isLessThanValueIn: srcReg).
	"3. Move result to destination register"
	self machineCodeAt: loadOffset + 12 put: (self 
		moveRegister: ConcreteOverflowReg toRegister: destReg).
	^ machineCodeSize := loadOffset + 16
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddCheckOverflowRR [
	"Check for the overflow, as according to the example in the book: 
	 add   res,  src1,  src2 
    slti  t1,   src2,  0       # t1 = (src2 < 0)
    slt   t2,   res,   src1    # t2 = (src1 + src2 < res)
	 * since res and src2 are equal we have to res to another result then move back
    bne   t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 >= res)  case 1 0 (underflow)
                                          || (src2 >= 0) && (src1 + src2 < res)  case 0 1 (overflow)"
	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Perform the ADD operation"
	self machineCodeAt: 0 put: (self
		addRegister: srcReg1
		toRegister: srcReg2
		inRegister: ConcreteOverflowReg).
	"1. Check if one operand is negative"
	self machineCodeAt: 4 put: (self 
		setOneIn: ConcreteIPReg2 
		ifValueIn: srcReg2 
		isLessThanImmediate: 0).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: 8 put: (self 
		setOneIn: ConcreteIPReg3 
		ifValueIn: ConcreteOverflowReg 
		isLessThanValueIn: srcReg1).
	"3. Move result to destination register"
	self machineCodeAt: 12 put: (self 
		moveRegister: ConcreteOverflowReg toRegister: destReg).
	^ machineCodeSize := 16
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddCqR [

	"Perform an add operation between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self 
			addImmediate: cq 
			toRegister: sourceReg
			inRegister: destReg).
		^ machineCodeSize := 4 ].
	"Otherwise, use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddCwR [

	<inline: true>
	| sourceReg destReg loadOffset |
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.
	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddRR [

	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Perform the ADD operation"
	self machineCodeAt: 0 put: (self 
		addRegister: srcReg1 
		toRegister: srcReg2 
		inRegister: destReg).
		
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAddRdRd [

	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self fAddRegister: srcReg1 toRegister: srcReg2 intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAlignmentNops [

	"Fill any empty slots with NOPs"
	<inline: true>
	self assert: machineCodeSize \\ 4 = 0.
	0 to: machineCodeSize - 1 by: 4 do: [ :p | self machineCodeAt: p put: self nop ]
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAndCqR [

	"Perform a bitwise and between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	"Use immediate with quick or literal load"
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		^ machineCodeSize :=  4 ].
	"If the value is a literal, load it in a given register"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the AND operation"
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAndCqRR [

	"Perform a bitwise and between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := operands at: 1.
	destReg := operands at: 2.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		^ machineCodeSize := 4 ].
	"Otherwise, use the literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAndCwR [
	
	<inline: true>
	| sourceReg destReg loadOffset |
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.	
	"Load Cw in register then perform the AND"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
	      	 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 4
			
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAndRR [

	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	destReg := srcReg2 := operands at: 1.
	self machineCodeAt: 0 put: (self bitwiseAndBetweenRegister: srcReg1 andRegister: srcReg2 toRegister: destReg).	
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeArithmeticShiftRightCqR [

	"Perform an arithmetic shift right between the value of register and the value of the operand"
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate ASRLI"
		self machineCodeAt: 0 put: (self
				 arithmeticShiftRightValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		^ machineCodeSize := 4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 arithmeticShiftRightValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeArithmeticShiftRightRR [

	<inline:true>
	| srcReg shiftReg destReg |
	shiftReg := operands at: 0.
	destReg := srcReg := operands at: 1.
	self machineCodeAt: 0 put: (self 
		arithmeticShiftRightValueInRegister: srcReg 
		byShiftAmountInRegister: shiftReg 
		intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeAt: actualAddress [
	"Generate concrete machine code for the instruction at actualAddress,
	 setting machineCodeSize, and answer the following address."

	self assert: actualAddress \\ 4 = 0.
	^ super concretizeAt: actualAddress
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrEqualRR [

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isEqualToRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPEqualRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: left 
		isEqualToRegisterValue: right).
	"Sets one if values equal -> br if ConcreteIPReg is not equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsNotEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPGreaterEqualRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	"left>=right reversed to right<left"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: right 
		isLessThanRegisterValue: left).
	"Sets one if right<left -> NOT left>=right -> br if set is equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPGreaterRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	"left>right reversed to right<=left"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: right 
		isLessThanOrEqualToRegisterValue: left).
	"Sets one if right<left -> br if ConcreteIPReg is equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPLessEqualRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: left 
		isLessThanOrEqualToRegisterValue: right).
	"Sets one if values equal -> br if ConcreteIPReg is not equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsNotEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPLessRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: left 
		isLessThanRegisterValue: right).
	"Sets one if values equal -> br if ConcreteIPReg is not equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsNotEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrFPNotEqualRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 4.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"No direct branching but set one in register if comparison!"
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteIPReg  
		ifRegisterValue: left 
		isEqualToRegisterValue: right).
	"Sets one if values equal -> br if ConcreteIPReg is equal to zero"
	self machineCodeAt: 4 put: (self 
		branchTo: offset 
		ifRegisterValueIsEqualToZero: ConcreteIPReg ).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrLongEqualRR [
	| offset offsetHigh offsetLow leftReg rightReg |
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4. 
	self assert: (self isInLongJumpCallRange: offset).
	
	leftReg := operands at: 1.
	rightReg := operands at: 2.

	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	

	"Branch over the jump if the condition is not met"
	self machineCodeAt: 0 put: (self  branchTo: 12 ifRegisterValue: leftReg isNotEqualToRegisterValue: rightReg).
	"Perform the actual jump"
	self machineCodeAt: 4 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 8 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrLongNotEqualRR [
	| offset offsetHigh offsetLow leftReg rightReg |
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4. 
	self assert: (self isInLongJumpCallRange: offset).
	
	leftReg := operands at: 1.
	rightReg := operands at: 2.

	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	

	"Branch over the jump if the condition is not met"
	self machineCodeAt: 0 put: (self  branchTo: 12 ifRegisterValue: leftReg isEqualToRegisterValue: rightReg).
	"Perform the actual jump"
	self machineCodeAt: 4 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 8 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrNotEqualRR [ 

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isNotEqualToRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrSignedGreaterEqualRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isGreaterThanOrEqualRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrSignedGreaterRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isGreaterThanRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrSignedLessEqualRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isLessThanOrEqualRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrSignedLessRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isLessThanRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrUnsignedGreaterEqualRR [   

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueUnsigned: left isGreaterThanOrEqualRegisterValueUnsigned: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrUnsignedGreaterRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueUnsigned: left isGreaterThanRegisterValueUnsigned: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrUnsignedLessEqualRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueUnsigned: left isLessThanOrEqualRegisterValueUnsigned: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeBrUnsignedLessRR [  

	<inline: true>
	| offset left right |
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueUnsigned: left isLessThanRegisterValueUnsigned: right).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCall [
	"Will get inlined into concretizeAt: switch."

	"Call is used only for calls within code-space, See CallFull for general anywhere in address space calling"
	
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #callsize. "This call can go up to 32 bits!"
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the PC"
   offset := (operands at: 0) signedIntFromLong - address signedIntFromLong.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset  bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: LR).
	^ machineCodeSize := 8

]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCallFull [
	"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| jumpTarget instrOffset |
	self flag: #callsize. "This call can go up to 64 bits"
	jumpTarget := self longJumpTargetAddress.
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self jumpTo: ConcreteIPReg withOffset: 0 andStorePreviousPCPlus4in: LR). 
	^ machineCodeSize := instrOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCmpC32R [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCmpCqR [

	<var: #cq type: #sqInt>
	<inline: true>
	| srcReg cq loadOffset |
	cq := operands at: 0.
	srcReg := operands at: 1.
	"Note: There is no sub immediate"
	dependent 
		ifNil: [ "Move to a register using immediate operations (no subi but will avoid having too much literals)"
			loadOffset := self loadImmediate: cq inRegister: ConcreteIPReg]
		ifNotNil: [ "Literal -> compute the distance, load the actual value then and between the 2 registers" 
			loadOffset := self loadLiteralInRegister: ConcreteIPReg ].
	"Perform the subtraction"
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: srcReg
			 intoRegister: ConcreteZeroReg).

	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCmpCwR [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCmpRR [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeCmpRdRd [
	
	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeConvertRRd [
 
	"Convert an integer value into a double precision float value"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertLongSignedInRegister: srcReg 
	    toDoublePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeConvertRdRs [

	"Convert a double precision float to a single precision float in a register"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertDoublePrecisionInRegister: srcReg 
	    toSinglePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeConvertRsRd [

	"Convert a single precision float to a double precision float in a register"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertSinglePrecisionInRegister: srcReg 
	    toDoublePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeDivRR [ 

	<inline: true>
	| regNumerator regDenominator regDestination |
	regNumerator := operands at: 0.
	regDenominator := operands at: 1.
	regDestination := operands at: 2. 
	self machineCodeAt: 0 put: (self 
		divideRegisterValue: regNumerator 
		byRegisterValue: regDenominator  
		intoRegister: regDestination).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeDivRdRd [

	"FP divide regLHS by regRHS and stick result in regLHS"
	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self fDivideRegister: srcReg2 byRegister: srcReg1 intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeDupRVr [

	"No vector support in RISC-V yet"
	self flag: #vector.
	^self shouldBeImplemented
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeFaddSRvRvRv [

	"No vector support in RISC-V yet"
	self flag: #vector.
	^self shouldBeImplemented
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeFill32 [
	
	"fill with operand 0 according to the processor's endianness, here little-endian"
	self machineCodeAt: 0 put: (operands at: 0).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeFsubSRvRvRv [

	"No vector support in RISC-V yet"
	self flag: #vector.
	^self shouldBeImplemented
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJump [ 

	<inline: true>
	| offset |
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self jumpToOffset: offset).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpAbove [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpAboveOrEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpBelow [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpBelowOrEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPGreater [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPGreaterOrEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPLess [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPLessOrEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFPNotEqual [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpFull [
"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| loadOffset jumpTarget |
	self flag: #jumpsize. "This jump can go up to 64 bits"	
	jumpTarget := self longJumpTargetAddress.
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self jumpToRegisterValue: ConcreteIPReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpGreater [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpGreaterOrEqual [ 

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpLess [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpLessOrEqual [ 

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpLong [

	"JumpLong works the same way as a Call buts does not store the return address"
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #jumpsize. "This jump can go up to 32 bits"
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the address of the first instruction (auipc)"
   offset := (operands at: 0) signedIntFromLong - address signedIntFromLong.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpLongNonZero [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpLongZero [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpNegative [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpNoCarry [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpNoOverflow [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpNonZero [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpOverflow [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpR [

	<inline: true>
	| reg|
	reg := operands at: 0.
	self machineCodeAt: 0 put: (self jumpToRegisterValue: reg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeJumpZero [

	<inline: true>
	"Should be rewritten by noteFollowingConditionalBranch:"
	self unreachable.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLd1VrRMw [

	"No vector support in RISC-V yet"
	self flag: #vector.
	^self shouldBeImplemented
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLiteral [
	"Generate an out-of-line literal.  Copy the value and any annotation from the stand-in in the literals manager."
	| twoComplement literal literalAsInstruction |

	"Process the literal if it is an instruction"
	literalAsInstruction := cogit cCoerceSimple: (operands at: 0) to: #'AbstractInstruction *'.
	literal := (self isAnInstruction: literalAsInstruction)
				ifTrue: [literalAsInstruction address]
				ifFalse: [self cCode: [literalAsInstruction asUnsignedInteger]
							inSmalltalk: [literalAsInstruction]].
	"Get the address"
	self assert: (dependent notNil and: [dependent opcode = Literal]).
	dependent annotation ifNotNil:
	[self assert: annotation isNil.
		 annotation := dependent annotation].
	dependent address ifNotNil: [self assert: dependent address = address].
	dependent address: address.
	"Write the actual literal"
	twoComplement := literal < 0
		ifTrue: [ 16rFFFFFFFFFFFFFFFF - literal abs + 1 ]
		ifFalse: [ literal ].

	self machineCodeAt: 0 put: (twoComplement bitAnd: 16rFFFFFFFF).
	self machineCodeAt: 4 put: (twoComplement >> 32).
	machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLoadEffectiveAddressMwrR [

	"destReg = srcReg (which contains an address) + offset"
	"Is it really the same thing as an AddCqR where cq would be the offset? 
	 Yes but the conditional flags are not affected!"
		
	<inline: true>
	| offset destReg sourceReg loadOffset |
	offset := operands at: 0.
	sourceReg := operands at: 1.
	destReg := operands at: 2.
	dependent ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
					 addImmediate: offset
					 toRegister: sourceReg
					 inRegister: destReg).
			^ machineCodeSize := 4 ].
	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: destReg).
	^ machineCodeSize := loadOffset + 4.
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLogicalShiftLeftCqR [

	"Perform a logical shift left operation between the value of register and the value of the operand."
	<inline: true>
	<var: #cq type: #sqInt>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 shiftLeftValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		^ machineCodeSize :=  4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 shiftLeftValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLogicalShiftLeftRR [
	
	<inline: true>
	| shiftReg srcReg destReg |
	shiftReg := operands at: 0.
	srcReg := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: srcReg 
		byShiftAmountInRegister: shiftReg 
		intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLogicalShiftRightCqR [

	"Perform a logical shift right operation between the value of register and the value of the operand"
	<inline: true>
	<var: #cq type: #sqInt>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate SRLI"
		self machineCodeAt: 0 put: (self
				 shiftRightValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		^ machineCodeSize :=  4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 shiftRightValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLogicalShiftRightRR [
	
	<inline: true>
	| srcReg shiftReg destReg |
	shiftReg := operands at: 0.
	srcReg := destReg := operands at: 1.
	"Perform the SRR operation"
	self machineCodeAt: 0 put: (self
		shiftRightValueInRegister: srcReg 
		byShiftAmountInRegister: shiftReg 
		intoRegister: destReg).
	^ machineCodeSize :=  4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveAbR [

	"Loads a byte (8 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"
	
	<inline: true>
	| srcAddr destReg instrOffset |
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ "Direct encoding as offset"
		self machineCodeAt: 0 put: (self
				 loadUnsignedByteFromAddressInRegister: ConcreteVarBaseReg
				 withOffset: srcAddr - cogit varBaseAddress
				 toRegister: destReg).
		^ machineCodeSize := 4 ].

	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.

	self machineCodeAt: instrOffset put: (self
			 loadUnsignedByteFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveAwR [

	"Loads a word (64 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcAddr destReg instrOffset |
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ "Direct encoding as offset"
		self machineCodeAt: 0 put: (self
				 loadDoubleWordFromAddressInRegister: ConcreteVarBaseReg
				 withOffset: srcAddr - cogit varBaseAddress
				 toRegister: destReg).
		^ machineCodeSize := 4 ].

	"load the address into ConcreteIPReg"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.

	self machineCodeAt: instrOffset put: (self
			 loadDoubleWordFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).

	^ machineCodeSize := instrOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveC32R [
	
	self flag: #TODO.
	self shouldBeImplemented.
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveCqR [

	<inline: true>
	<var: #cq type: #sqInt>
	| cq reg |
	cq := operands at: 0.
	reg := operands at: 1.
	dependent ifNil: [ "Immediate value"
		^ machineCodeSize := self loadImmediate: cq inRegister: reg].
	"use the provided literal"
	^ machineCodeSize := self loadLiteralInRegister: reg
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveCwR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	^ machineCodeSize := self loadCwInto: (operands at: 1)
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveM16rR [

	"Load a half-word (2 bytes) from memory where the address is at a constant offset from an address in a register
	 The offset can be either encoded immediately or loaded 
	 Expands to: lh rs2, offset(rs1)"

	<inline: true>
	| baseReg offset destReg instrOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				loadUnsignedHalfWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			loadUnsignedHalfWordFromAddressInRegister: ConcreteIPReg  
			withOffset: 0 
			toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveM32rR [

	"Load a word (4 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: lw rs2, offset(rs1)"

	<inline: true>
	| baseReg offset destReg instrOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadUnsignedWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset :=  self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			 loadUnsignedWordFromAddressInRegister: ConcreteIPReg 
			 withOffset: 0 
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveM32rRs [
	
	"Load a single-precision float from srcReg+offset into FP destReg"

	<inline: true>
	| baseReg offset destReg instrOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				fLoadWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self 
		fLoadWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0
		toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveM64rRd [
	
	"Load a double-precision float from srcReg+offset into FP destReg"
	<inline: true>
	| baseReg offset destReg instrOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				fLoadDoubleWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ] .
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"	
	self machineCodeAt: instrOffset + 4 put: (self 
		fLoadDoubleWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0
		toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveMbrR [

	"Load a byte (8 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: lb rd, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| baseReg offset destReg loadOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadUnsignedByteFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 loadUnsignedByteFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 8	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveMwrR [

	"Load a vm word (double word 64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: ld rd, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| baseReg offset destReg instrOffset |
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadDoubleWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			 loadDoubleWordFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMovePatcheableC32R [
	
	| literalAddress distance |
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: 0 toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self
	  loadDoubleWordFromAddressInRegister: ConcreteIPReg
	  withOffset: distance
     toRegister: (operands at: 1)).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRAb [

	"Stores a byte (8 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcReg destAddress instrOffset |
	srcReg := operands at: 0.
	destAddress := operands at: 1.
	(self isAddressRelativeToVarBase: destAddress) ifTrue: [ 
		self machineCodeAt: 0 put: (self
				 storeByteFromRegister: srcReg
				 toAddressInRegister: ConcreteVarBaseReg
				 withOffset: destAddress - cogit varBaseAddress).
		^ machineCodeSize := 4 ].
	"Load provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self
			 storeByteFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := instrOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRAw [

	"Stores a word (64 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcReg destAddress instrOffset |
	srcReg := operands at: 0.
	destAddress := operands at: 1.
	(self isAddressRelativeToVarBase: destAddress) ifTrue: [ 
		self machineCodeAt: 0 put: (self
				 storeDoubleWordFromRegister: srcReg
				 toAddressInRegister: ConcreteVarBaseReg
				 withOffset: destAddress - cogit varBaseAddress).
		^ machineCodeSize := 4 ].
	"Load provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := instrOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRM16r [

	"Store a half word (2 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: sh rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				 storeHalfWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			 ^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeHalfWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRM32r [

	"Store a word (4 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: sw rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				 storeWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRMbr [

	"Stores a byte (8 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: sb rs2, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				 storeByteFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ] .
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeByteFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRMwr [

	"Stores a vm word (64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: sd rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				 storeDoubleWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRR [

	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self moveRegister: srcReg toRegister: destReg). 
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRRd [

	"fmv.d.x: Floating point move doubleword from integer
    Copies the double-precision floating-point number in x[rs1] to f[rd]"
	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
			fMoveDoubleWordInXRegister: srcReg 
			toFRegister: destReg 
	).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRX32rR [

	"Write the half word in R(src) into memory at address (base + word size * index)"

	<inline: true>
	| indexReg baseReg srcReg |
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"Shift by 2 (*4) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 2
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 8 put: (self 
		storeWordFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRXbrR [

	"Write the byte in R(src) into memory at address (base + word size * index)"

	<inline: true>
	| indexReg baseReg srcReg |
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"No need to shift for a byte!"
	"Add the offset to the base address register"
	self machineCodeAt: 0 put: (self 
		addRegister: indexReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 4 put: (self 
		storeByteFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRXwrR [

	"Write the word in R(src) into memory at address (base + word size * index)"

		<inline: true>
	| indexReg baseReg srcReg |
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"Shift by 3 (*8) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 3 
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 8 put: (self 
		storeDoubleWordFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRdM64r [

	"Store double-precision floating-point number in register to base+offset"

	<inline: true>
	| offset baseReg srcReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent ifNil: [ 
		self assertValue: offset isContainedIn: 12.
		self machineCodeAt: 0 put: (self
				 fStoreDoubleWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
		^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self
			 addRegister: baseReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 fStoreDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRdR [

	"fmv.x.d: Floating point move doubleword to integer,
    copies the double-precision floating-point number in register f[rs1] to x[rd]"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self
		machineCodeAt: 0
		put: (self fMoveDoubleWordInFRegister: srcReg toXRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveRsM32r [

	"Store single-precision floating-point number in register to base+offset"

	<inline: true>
	| offset baseReg srcReg loadOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent ifNil: [ 
		self assertValue: offset isContainedIn: 12.
		self machineCodeAt: 0 put: (self
				 fStoreWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
		^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self
			 addRegister: baseReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 fStoreWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveX32rRR [

	"Read a half word in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"Shift by 2 (*4) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 2 
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 8 put: (self 
		loadUnsignedWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 12
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveXbrRR [

	"Read a byte in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"No need to shift for a byte!"
	"Add the offset to the base address register"
	self machineCodeAt: 0 put: (self 
		addRegister: indexReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 4 put: (self 
		loadUnsignedByteFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMoveXwrRR [
	
	"Read a word in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"Shift by 3 (*8) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 3
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 8 put: (self 
		loadDoubleWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMulCheckOverflowRR [ 

	<inline:true>
	| srcReg1 srcReg2 destReg | 
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Multiply the two registers and store the higher half in a temp register (here overflow 1)
	 Note that the mul high is performed first to avoid overwriting one operand (2-address code here)"
	self machineCodeAt: 0 put: (self 
		multiplyHighRegisterValue: srcReg1
		byRegisterValue: srcReg2
		inRegister: ConcreteIPReg2).
	
	"Multiply and store the lower part in the destination register"
	self machineCodeAt: 4 put: (self 
		multiplyRegisterValue: srcReg1
		byRegisterValue: srcReg2 
		inRegister: destReg).
			
	"Create a temp register to be either all 0s or all 1s depending on the result sign
	 An arithmetic shift of 63 on the result will produce such a value"
	self machineCodeAt: 8 put: (self
		arithmeticShiftRightValueInRegister: destReg
		byShiftAmount: 63
		intoRegister: ConcreteIPReg3).

	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMulRR [ 

	<inline:true>
	| srcReg1 srcReg2 destReg | 
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self 
		multiplyRegisterValue: srcReg1
		byRegisterValue: srcReg2 
		inRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMulRdRd [

	<inline: true>
	| destReg sourceReg1 sourceReg2 |
	sourceReg1 := operands at: 0.
	sourceReg2 := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self fMultiplyRegister: sourceReg2 fromRegister: sourceReg1 intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeNegateR [

	<inline: true>
	| srcReg destReg |
	srcReg := destReg := operands at: 0.
	"Perform a SUB operation with X0"
	self machineCodeAt: 0 put: (self negateValueInRegister: srcReg intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeNop [

	<inline: true>
	self machineCodeAt: 0 put: self nop.
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeOrCqR [

	"Perform a bitwise or between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseOrBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		^ machineCodeSize := 4 ].
	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 bitwiseOrBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeOrCwR [
	
	<inline: true>
	| sourceReg destReg loadOffset |
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.	
	"Load Cw in register then perform the OR"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
	      	 bitwiseOrBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 4	
			
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeOrRR [

	<inline: true>
	| sourceReg1 sourceReg2 destReg |
	sourceReg1 := operands at: 0.
	sourceReg2 := destReg := operands at: 1.
	"Perform the OR operation"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizePopR [
	
	"Load the content of the stack pointer in the given register then decrease (+8 because downwards) the stack pointer."
	<inline: true>
	| destReg offset |
	destReg := operands at: 0.
	offset := self computeSignedValueOf: 8 ofSize: 12.
	self machineCodeAt: 0 put: (self loadDoubleWordFromAddressInRegister: SPReg withOffset: 0 toRegister: destReg).	
	self machineCodeAt: 4 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizePrefetchAw [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	"No prefetch routine at the point of writing"
	^ machineCodeSize := 0.
	
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizePushCq [

	"Push (store) a double word at the position of the stack pointer if the constant is not a literal
		li  ConcreteIPReg, cq 
		addi sp, sp, -8
		sd  ConcreteIPReg, 0(sp)
	
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
	   addi sp, sp, -8
	   sd  ConcreteIPReg, 0(sp)
		"
	<var: #cq type: #sqInt>
	<inline: true>
	| cq instrOffset offset |
	cq := operands at: 0.
	dependent
		ifNil: [ 
			"No literal -> Direct load into a scratch register, number of instructions depends on immediate size"
			instrOffset := self loadImmediate: cq inRegister: ConcreteIPReg ]
		ifNotNil: [ 
			"Literal -> Compute the distance from the current address and add auipc then ld instructions"
			instrOffset := self loadLiteralInRegister: ConcreteIPReg ].
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: instrOffset put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: instrOffset + 4 put: (self storeDoubleWordFromRegister: ConcreteIPReg toAddressInRegister: SPReg withOffset: 0).
	^ machineCodeSize := instrOffset + 8 
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizePushCw [
	
	"Push (store) a double word at the position of the stack pointer by first loading the value in a register then pushing it"
	<inline: true>
	| word instrOffset offset |
	word := operands at: 0.
	instrOffset := self loadCwInto: ConcreteIPReg.
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: instrOffset put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: instrOffset + 4 put: (self storeDoubleWordFromRegister: ConcreteIPReg toAddressInRegister: SPReg withOffset: 0).
	^ machineCodeSize := instrOffset + 8 
	 
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizePushR [

	"Push (store) a double word in a register at the position of the stack pointer"
	<inline: true>
	| srcReg offset |
	srcReg := operands at: 0.
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: 0 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: 4 put: (self storeDoubleWordFromRegister: srcReg toAddressInRegister: SPReg withOffset: 0).
	^ machineCodeSize := 8
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeRemRR [ 

	<inline: true>
	| regNumerator regDenominator regDestination |
	regNumerator := operands at: 0.
	regDenominator := operands at: 1.
	regDestination := operands at: 2. 
	"Perform the DIV operation (signed division) for the remainder"
	self machineCodeAt: 0 put: (self 
		remainderOfDivisionRegisterValue: regNumerator 
		byRegisterValue: regDenominator  
		inRegister: regDestination).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeRetN [

	"Jumps to the address stored in the Link Register + a given offset. (ret)  jalr, x0, 0(x1)"
	<var: #offset type: #sqInt>
	<inline: true>
	| offset |
	offset := operands at: 0.
	offset = 0 ifTrue: [ self machineCodeAt: 0 put: self ret. ^ machineCodeSize := 4 ].
	self machineCodeAt: 0 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
	self machineCodeAt: 4 put: self ret.
	^ machineCodeSize := 8
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeRotateLeftCqR [

	"Perform a rotate left between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg srcReg loadOffset rotateOffset |
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		rotateOffset := self
			                rotateLeftValueInRegister: srcReg
			                byShiftAmount: cq
			                inRegister: destReg
			                startingAtIndex: 0.
		^ machineCodeSize := rotateOffset ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	rotateOffset := self
		                rotateLeftValueInRegister: srcReg
		                byShiftAmountInRegister: ConcreteIPReg
		                inRegister: destReg
		                startingAtIndex: loadOffset.
	^ machineCodeSize := loadOffset + rotateOffset
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeRotateRightCqR [

	"Perform a rotate right between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg srcReg loadOffset rotateOffset |
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		rotateOffset := self
			                rotateRightValueInRegister: srcReg
			                byShiftAmount: cq
			                inRegister: destReg
			                startingAtIndex: 0.
		^ machineCodeSize := rotateOffset ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the different ROT operations"
	rotateOffset := self
		                rotateRightValueInRegister: srcReg
		                byShiftAmountInRegister: ConcreteIPReg
		                inRegister: destReg
		                startingAtIndex: loadOffset.
	^ machineCodeSize := loadOffset + rotateOffset
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSqrtRd [

	"Square root of FP"
	<inline: true>
	| srcReg destReg |
	srcReg := destReg := operands at: 0.
	self machineCodeAt: 0 put: (self fSquareRootOfRegister: srcReg inRegister: destReg).
	^ machineCodeSize := 4	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSt1VrRMw [

	"No vector support in RISC-V yet"
	^self shouldBeImplemented 
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeStop [
	
	"Generates an ebreak instruction"
	<inline: true>
	self machineCodeAt: 0 put: self stop.
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubCheckOverflowCqR [
	"Check for the overflow, as according to the example in the book: 
	 sub   res,  imm,  src      # res = src - imm
    slti  t1,   src,  0        # t1 = (src2 < 0)
    slt   t2,   res,   imm     # t2 = (src1 - src2 < res)
	 * since res and src are equal we have to res to another result then move back
    be    t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (overflow)
                                          || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (underflow)"
	<inline: true>
	| cq srcReg destReg loadOffset |
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	"Perform the SUB operation"
	dependent ifNil: [ 
		self assertValue: cq negated isContainedIn: 12.
		self machineCodeAt: 0 put: (self
			addImmediate: cq negated
			toRegister:  srcReg
			inRegister: ConcreteOverflowReg).
		"1. Check if one operand is negative, OR EQUAL TO ZERO"
		self machineCodeAt: 4 put: (self 
			setOneIn: ConcreteIPReg2 
			ifValueIn: srcReg
			isLessThanImmediate: 1). 
		"2. Check if the sum is smaller than one operand"
		self machineCodeAt: 8 put: (self 
			setOneIn: ConcreteIPReg3 
			ifValueIn: ConcreteOverflowReg 
			isLessThanImmediate: cq).
		"3. Move result to destination register"
		self machineCodeAt: 12 put: (self 
			moveRegister: ConcreteOverflowReg toRegister: destReg).
		^ machineCodeSize := 16 ].
	"Otherwise, use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the SUB operation"
	self machineCodeAt: loadOffset put: (self
		subtractRegister: ConcreteIPReg
		fromRegister:  srcReg
		intoRegister: ConcreteOverflowReg).
	"1. Check if one operand is negative, OR EQUAL TO ZERO"
	self machineCodeAt: loadOffset + 4 put: (self 
		setOneIn: ConcreteIPReg2 
		ifValueIn: ConcreteIPReg
		isLessThanImmediate: 1). 
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: loadOffset + 8 put: (self 
		setOneIn: ConcreteIPReg3 
		ifValueIn: ConcreteOverflowReg 
		isLessThanValueIn: srcReg).
	"3. Move result to destination register"
	self machineCodeAt: loadOffset + 12 put: (self 
		moveRegister: ConcreteOverflowReg toRegister: destReg).
	^ machineCodeSize := loadOffset + 16
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubCheckOverflowRR [
	"Check for the overflow, as according to the example in the book: 
	 sub   res,  src1,  src2    # res = src1 - src2 
    slti  t1,   src2,  0       # t1 = (src2 < 0)
    slt   t2,   res,   src1    # t2 = (src1 - src2 < res)
    be    t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (overflow)
                                          || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (underflow)"
	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Perform the SUB operation"
	self machineCodeAt: 0 put: (self
		subtractRegister: srcReg1
		fromRegister:  srcReg2
		intoRegister: ConcreteOverflowReg).
	"1. Check if one operand is negative, OR EQUAL TO ZERO"
	self machineCodeAt: 4 put: (self 
		setOneIn: ConcreteIPReg2 
		ifValueIn: srcReg1
		isLessThanImmediate: 1). 
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: 8 put: (self 
		setOneIn: ConcreteIPReg3 
		ifValueIn: ConcreteOverflowReg 
		isLessThanValueIn: srcReg2).
	"3. Move result to destination register"
	self machineCodeAt: 12 put: (self 
		moveRegister: ConcreteOverflowReg toRegister: destReg).
	^ machineCodeSize := 16
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubCqR [

	"Perform a sub operation between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent
		ifNil: [ "Immediate load in a register"
			self assertValue: cq negated isContainedIn: 12.
			"Use the provided immediate instruction"
			self machineCodeAt: 0 put: (self 
				addImmediate: cq negated
				toRegister: sourceReg
				inRegister: destReg).
			^ machineCodeSize := 4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the SUB operation to a temp register (as operands AND result are needed for overflow check)"
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: sourceReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubCwR [

	<inline: true>
	| sourceReg destReg loadOffset |
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.
	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: sourceReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubRR [

	"Perform a sub operation between the value of register and the value of another register.	"
	<inline: true>
	| destReg rightReg leftReg |
	rightReg := operands at: 0.
	leftReg := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
		subtractRegister: rightReg
		fromRegister: leftReg
		intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeSubRdRd [

	"Perform a floating-point double precision sub operation between the value of register and the value of another register.	"

	<inline: true>
	| destReg rightReg leftReg |
	rightReg := operands at: 0.
	leftReg := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self fSubtractRegister: rightReg fromRegister: leftReg intoRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeTstCqR [

	"Perform a tst operation (and discarding the result) between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| srcReg cq loadOffset |
	cq := operands at: 0.
	srcReg := operands at: 1.
	dependent ifNil: [ "If the cq fits in 12 bits, encode it directly"
		self assertValue: cq abs isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: srcReg
				 andImmediate: cq
				 toRegister: ConcreteZeroReg).
		^ machineCodeSize :=  4 ].
	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: srcReg
			 andRegister: ConcreteIPReg
			 toRegister: ConcreteZeroReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeUnimplemented [
	self error: 'Unimplemented RTL instruction'.
	^0
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeXorCqR [

	"Perform a xor operation between the value of register and the value of the operand."
	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset |
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseXorBetweenRegister: sourceReg
				 andImmediate: cq
				 intoRegister: destReg).
		^ machineCodeSize :=  4 ].
	"Literal -> compute the distance, load the actual value then XOR between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 bitwiseXorBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeXorCwR [

	"XOR operation after loading the value in a register"
	<inline: true>
	| destReg sourceReg loadOffset |
	sourceReg := destReg := operands at: 1.
   "Literal -> compute the distance, load the actual value then xor between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
					bitwiseXorBetweenRegister: sourceReg  
					andRegister: ConcreteIPReg 
					intoRegister: destReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeXorRR [ 
	
	<inline: true>
	| srcReg1 srcReg2 destReg |
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	self machineCodeAt: 0 put: (self bitwiseXorBetweenRegister: srcReg1 andRegister: srcReg2 intoRegister: destReg).
	^ machineCodeSize := 4
	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeXorRdRd [
	
	"This concretization is only used in the primitive small float to zero out a register. 
	 Rather than using this, we will convert X0 (hardwired 0) to the corresponding register"
	<inline: true>
	| srcReg1 srcReg2 |
	srcReg1 := operands at: 0.
	srcReg2 := operands at: 1.
	self assert: (srcReg1 = srcReg2).
	self machineCodeAt: 0 put: (self fConvertLongSignedInRegister: X0 toDoublePrecisionInRegister: srcReg1).
	^ machineCodeSize := 4
	
]

{ #category : 'simulation' }
CogOutOfLineLiteralsRiscV64Compiler >> configureStackAlignment [
	
	<doNotGenerate>
	"According to RISC-V ISA description, stack should always be kept 16-byte aligned"
	cogit setStackAlignment: 16 expectedSPOffset: 0 expectedFPOffset: 0.
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> dispatchConcretize [
	"Attempt to generate concrete machine code for the instruction at address.
	 This is the inner dispatch of concretizeAt: actualAddress which exists only
	 to get around the branch size limits in the SqueakV3 (blue book derived)
	 bytecode set."
	<returnTypeC: #void>
	opcode caseOf: {
		"Noops & Pseudo Ops"
		[Label]			 -> [ ^ self concretizeLabel ].
		[Literal]		 	 -> [ ^ self concretizeLiteral ].
		[AlignmentNops]	 -> [ ^ self concretizeAlignmentNops ].
		[Fill32]			 -> [ ^ self concretizeFill32 ].
		[Nop]				 -> [ ^ self concretizeNop ].
		
		"Branches"
		[ BrEqualRR ]                -> [ ^ self concretizeBrEqualRR ].
		[ BrNotEqualRR ]             -> [ ^ self concretizeBrNotEqualRR ].
	   [ BrSignedGreaterRR ]        -> [ ^ self concretizeBrSignedGreaterRR ].
		[ BrSignedGreaterEqualRR ]   -> [ ^ self concretizeBrSignedGreaterEqualRR ].
		[ BrSignedLessRR ]           -> [ ^ self concretizeBrSignedLessRR ].
		[ BrSignedLessEqualRR ]      -> [ ^ self concretizeBrSignedLessEqualRR ].
		[ BrUnsignedLessRR ]         -> [ ^ self concretizeBrUnsignedLessRR ].
	   [ BrUnsignedLessEqualRR ]    -> [ ^ self concretizeBrUnsignedLessEqualRR ].
		[ BrUnsignedGreaterRR ]      -> [ ^ self concretizeBrUnsignedGreaterRR ].
		[ BrUnsignedGreaterEqualRR ] -> [ ^ self concretizeBrUnsignedGreaterEqualRR ].
		[ BrLongEqualRR  ]           -> [ ^ self concretizeBrLongEqualRR ].
		[ BrLongNotEqualRR  ]        -> [ ^ self concretizeBrLongNotEqualRR ].
		[ BrFPEqualRR ]              -> [ ^ self concretizeBrFPEqualRR ].
		[ BrFPNotEqualRR ]           -> [ ^ self concretizeBrFPNotEqualRR ].
		[ BrFPLessRR ]               -> [ ^ self concretizeBrFPLessRR ].
		[ BrFPLessEqualRR ]          -> [ ^ self concretizeBrFPLessEqualRR ].	   
		[ BrFPGreaterRR ]            -> [ ^ self concretizeBrFPGreaterRR ].
		[ BrFPGreaterEqualRR ]       -> [ ^ self concretizeBrFPGreaterEqualRR ].
		
		"Overflow"
		[ AddCheckOverflowRR ]       -> [ ^ self concretizeAddCheckOverflowRR ].
      [ AddCheckOverflowCqR ]      -> [ ^ self concretizeAddCheckOverflowCqR ].
		[ SubCheckOverflowRR ]       -> [ ^ self concretizeSubCheckOverflowRR ].
      [ SubCheckOverflowCqR ]      -> [ ^ self concretizeSubCheckOverflowCqR ].
      [ MulCheckOverflowRR ]       -> [ ^ self concretizeMulCheckOverflowRR ].
		
		"Control"
		[Call]					-> [ ^ self concretizeCall ].     "call code within code space"
		[CallFull]			-> [ ^ self concretizeCallFull ]. "call code anywhere in address space"
		[JumpR]				-> [ ^ self concretizeJumpR ].
		[JumpFull]			-> [ ^ self concretizeJumpFull ]. "jump within address space"
		[JumpLong]			-> [ ^ self concretizeJumpLong ]. "jumps witihn code space"
		[JumpLongZero]	   -> [ ^ self concretizeJumpLongZero ].
		[JumpLongNonZero]	-> [ ^ self concretizeJumpLongNonZero ].
		[Jump]				   -> [ ^ self concretizeJump ].
		[JumpZero]			-> [ ^ self concretizeJumpZero ].
		[JumpNonZero]		-> [ ^ self concretizeJumpNonZero ].
		[JumpNegative]		-> [ ^ self concretizeJumpNegative ].
		[JumpNonNegative]	-> [ ^ self concretizeUnimplemented ].
		[JumpOverflow]		-> [ ^ self concretizeJumpOverflow ].
		[JumpNoOverflow]	-> [ ^ self concretizeJumpNoOverflow ].
		[JumpCarry]			-> [ ^ self concretizeUnimplemented ].
		[JumpNoCarry]		-> [ ^ self concretizeJumpNoCarry ].
		[JumpLess]			-> [ ^ self concretizeJumpLess ].
		[JumpGreaterOrEqual]	-> [ ^ self concretizeJumpGreaterOrEqual ].
		[JumpGreater]			-> [ ^ self concretizeJumpGreater ].
		[JumpLessOrEqual]		-> [ ^ self concretizeJumpLessOrEqual ].
		[JumpBelow]				-> [ ^ self concretizeJumpBelow ]. "unsigned lower"
		[JumpAboveOrEqual]		-> [ ^ self concretizeJumpAboveOrEqual ]. "unsigned greater or equal"
		[JumpAbove]				-> [ ^ self concretizeJumpAbove ].
		[JumpBelowOrEqual]		-> [ ^ self concretizeJumpBelowOrEqual ].
		
		"FP Control"
		[JumpFPEqual]			-> [ ^ self concretizeJumpFPEqual ].
		[JumpFPNotEqual]		-> [ ^ self concretizeJumpFPNotEqual ].
		[JumpFPLess]				-> [ ^ self concretizeJumpFPLess ].
		[JumpFPGreaterOrEqual]	-> [ ^ self concretizeJumpFPGreaterOrEqual ].
		[JumpFPGreater]				-> [ ^ self concretizeJumpFPGreater ].
		[JumpFPLessOrEqual]		-> [ ^ self concretizeJumpFPLessOrEqual ].
		[JumpFPOrdered]				-> [ ^ self concretizeUnimplemented ].
		[JumpFPUnordered]			-> [ ^ self concretizeUnimplemented ].
		[RetN]	 -> [ ^ self concretizeRetN ].
		[Stop]	 -> [ ^ self concretizeStop ].
				
		"Logic"						
		[AndCqR]		-> [ ^ self concretizeAndCqR ].
		[AndCqRR]		-> [ ^ self concretizeAndCqRR ].
		[OrCqR]		-> [ ^ self concretizeOrCqR ].
		[TstCqR]		-> [ ^ self concretizeTstCqR ].
		[XorCqR]		-> [ ^ self concretizeXorCqR ].	
		
		"Arithmetic"				
		[AddCqR]	 -> [ ^ self concretizeAddCqR ].
		[CmpCqR]	 -> [ ^ self concretizeCmpCqR ].
		[SubCqR]	 -> [ ^ self concretizeSubCqR ].
		[CmpC32R]	 -> [ ^ self concretizeCmpC32R ].
		[LoadEffectiveAddressMwrR]	-> [ ^ self concretizeLoadEffectiveAddressMwrR ].

		"Arithmetic with an ensured literal load"
		[AddCwR]	-> [ ^ self concretizeAddCwR ].
		[AndCwR]	-> [ ^ self concretizeAndCwR ].
		[CmpCwR]	-> [ ^ self concretizeCmpCwR ].
		[OrCwR]	-> [ ^ self concretizeOrCwR ].
		[SubCwR]	-> [ ^ self concretizeSubCwR ].
		[XorCwR]	-> [ ^ self concretizeXorCwR].
		
		"Arithmetic Register-only"
		[AddRR]	 -> [ ^ self concretizeAddRR ].
		[AndRR]	 -> [ ^ self concretizeAndRR ].
		[CmpRR]	 -> [ ^ self concretizeCmpRR ].
		[OrRR]		 -> [ ^ self concretizeOrRR ].
		[SubRR]	 -> [ ^ self concretizeSubRR ].
		[XorRR]	 -> [ ^ self concretizeXorRR ].
		[MulRR] 	 -> [ ^ self concretizeMulRR ].
		[DivRR]	 -> [ ^ self concretizeDivRR ].
		[RemRR]  	 -> [ ^ self concretizeRemRR ].
		[NegateR]	 -> [ ^ self concretizeNegateR ].
		
		"Bit shifts"
		[LogicalShiftRightCqR]   	-> [ ^ self concretizeLogicalShiftRightCqR ].
		[LogicalShiftLeftCqR]			-> [ ^ self concretizeLogicalShiftLeftCqR ].
		[LogicalShiftLeftRR]			-> [ ^ self concretizeLogicalShiftLeftRR ].
		[LogicalShiftRightRR]			-> [ ^ self concretizeLogicalShiftRightRR ].
		[ArithmeticShiftRightRR]		-> [ ^ self concretizeArithmeticShiftRightRR ].
		[ArithmeticShiftRightCqR]	-> [ ^ self concretizeArithmeticShiftRightCqR ].

		"Rotates"
		[RotateLeftCqR]  ->	[ ^ self concretizeRotateLeftCqR ].
		[RotateRightCqR] ->	[ ^ self concretizeRotateRightCqR ].
		
		"Floating point operations"
		[AddRdRd] -> [ ^ self concretizeAddRdRd ].
		[CmpRdRd]	 -> [ ^ self concretizeCmpRdRd ].
		[DivRdRd]	 -> [ ^ self concretizeDivRdRd ].
		[MulRdRd]	 -> [ ^ self concretizeMulRdRd ].
		[SubRdRd]	 -> [ ^ self concretizeSubRdRd ].
		[SqrtRd]	 -> [ ^ self concretizeSqrtRd ].
		[XorRdRd]	 -> [ ^ self concretizeXorRdRd ].

		"Data Movement - basic"
		[MoveCqR]			-> [ ^ self concretizeMoveCqR ].
		[MoveCwR]			-> [ ^ self concretizeMoveCwR ].
		[MoveC32R]		-> [ ^ self concretizeMoveC32R ].
		[MoveRR]			-> [ ^ self concretizeMoveRR ].
		
		"Data Movement - Absolute addresses"
		[MoveAwR]			-> [ ^ self concretizeMoveAwR ].
		[MoveRAw]			-> [ ^ self concretizeMoveRAw ].
		[MoveAbR] 		-> [ ^ self concretizeMoveAbR ].
 		[MoveRAb]			-> [ ^ self concretizeMoveRAb ].
			
		"Data Movement - Stores"
		[MoveRM8r]		-> [ ^ self concretizeMoveRMbr ].
		[MoveRMbr]		-> [ ^ self concretizeMoveRMbr ].
		[MoveRM16r]		-> [ ^ self concretizeMoveRM16r ].
		[MoveRM32r]		-> [ ^ self concretizeMoveRM32r ].
		[MoveRMwr]		-> [ ^ self concretizeMoveRMwr ].
		[MoveRsM32r]		-> [ ^ self concretizeMoveRsM32r ].
		[MoveRdM64r]		-> [ ^ self concretizeMoveRdM64r ].
	
		"Data Movement - Loads"
		[MoveM8rR]    	-> [ ^ self concretizeMoveMbrR ].
		[MoveMbrR]		-> [ ^ self concretizeMoveMbrR ].		
		[MoveM16rR]		-> [ ^ self concretizeMoveM16rR ].
		[MoveM32rR]		-> [ ^ self concretizeMoveM32rR ].
		[MoveMwrR]		-> [ ^ self concretizeMoveMwrR ].
		[MoveM32rRs]		-> [ ^ self concretizeMoveM32rRs ].
		[MoveM64rRd]		-> [ ^ self concretizeMoveM64rRd ].
		
		"Data Movement - Relative Addresses with multiply"
		[MoveXbrRR]		-> [ ^ self concretizeMoveXbrRR].
		[MoveX32rRR]		-> [ ^ self concretizeMoveX32rRR].
		[MoveXwrRR]		-> [ ^ self concretizeMoveXwrRR].	
		[MoveRXbrR]		-> [ ^ self concretizeMoveRXbrR].
		[MoveRX32rR]		-> [ ^ self concretizeMoveRX32rR].
		[MoveRXwrR]		-> [ ^ self concretizeMoveRXwrR].
			
		"Pop/Push"
		[PopR]				-> [ ^ self concretizePopR ].
		[PushR]		 	-> [ ^ self concretizePushR ].
		[PushCq]			-> [ ^ self concretizePushCq ].
		[PushCw]			-> [ ^ self concretizePushCw ].
		[PrefetchAw]		-> [ ^ self concretizePrefetchAw ].
			
		"Conversion"
		[ConvertRdRs]	-> [ ^ self concretizeConvertRdRs ].
		[ConvertRsRd]	-> [ ^ self concretizeConvertRsRd ].
		[ConvertRRd]		-> [ ^ self concretizeConvertRRd ].
		[MoveRdR]			-> [ ^ self concretizeMoveRdR ].
		[MoveRRd]			-> [ ^ self concretizeMoveRRd ].
		
		"Patcheable literal instruction"
		[ MovePatcheableC32R ] -> [ ^ self concretizeMovePatcheableC32R ].

		"SIMD Ops"
		[ DupRVr ] -> [ ^ self concretizeDupRVr ].
		[ St1VrRMw ] -> [ ^ self concretizeSt1VrRMw ].
		[ Ld1VrRMw ] -> [ ^ self concretizeLd1VrRMw ].
		[ FaddSRvRvRv ] -> [ ^ self concretizeFaddSRvRvRv ].
		[ FsubSRvRvRv ] -> [ ^ self concretizeFsubSRvRvRv ].
		}
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> divideRegisterValue: srcReg1 byRegisterValue: srcReg2 intoRegister: destReg [

	"div: Divides x[rs1] by x[rs2], rounding towards zero, treating the values as two's complement numbers 
			and writes the quotient to x[rd]

	 31      25 24   20 19    15 14   12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  100  |   rd   |  0110011  |
	"
	
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 

]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> divideRegisterValueUnsigned: srcReg1 byRegisterValueUnsigned: srcReg2 intoRegister: destReg [

	"divu: Divides x[rs1] by x[rs2], rounding towards zero, treating the values as unsigned numbers 
			and writes the quotient to x[rd]

	 31      25 24   20 19    15 14   12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  101  |   rd   |  0110011  |
	"
	self flag: #CLEANUP.
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 

]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> extractOffsetFromAUIPC: instruction [ 

	^ self signExtendValue: ((instruction >> 12) bitAnd: 16rFFFFF) << 12 forSize: 32
]

{ #category : 'instruction extraction' }
CogOutOfLineLiteralsRiscV64Compiler >> extractOffsetFromCall: callAddress [ 

	| instAUIPC offsetAUIPC instJALR offsetJALR |
	"A call consists of auipc (20 upper bits) + jalr (12 lower bits) both sign extended before added"
	"AUIPC"
	instAUIPC := objectMemory long32At: callAddress - 4.
	self assert: (self instructionIsAUIPC: instAUIPC).
	offsetAUIPC := self signExtendValue: ((instAUIPC >> 12) bitAnd: 16rFFFFF) << 12 forSize: 32.
	"JALR"
	instJALR := objectMemory long32At: callAddress.
	self assert: (self instructionIsJALR: instJALR).
	offsetJALR := self signExtendValue: ((instJALR >> 20) bitAnd: 16rFFF) forSize: 12.
	
	^ offsetAUIPC + offsetJALR
]

{ #category : 'instruction extraction' }
CogOutOfLineLiteralsRiscV64Compiler >> extractOffsetFromConditionalBranch: instruction [ 

	"Branch instruction encode the offset from bits 31->25 as 12|10:5 -> offset2
	                                  and from bits 11->7  as 4:1|11  -> offset1"
	| mangledOffset1 mangledOffset2 demangledOffset |
	mangledOffset1 := instruction >> 7 bitAnd: 16r1F.
	mangledOffset2 := instruction >> 25 bitAnd: 16r7F.
	demangledOffset := ((((mangledOffset2 >> 6 bitAnd: 16r1) << 12) "12"
	  bitOr: ((mangledOffset1 bitAnd: 16r1) << 11)) "11"
	  bitOr: ((mangledOffset2 bitAnd: 16r3F) << 5)) "10:5"
	  bitOr: ((mangledOffset1 >> 1 bitAnd: 16rF) << 1). "4:1"
	^  self signExtendValue: demangledOffset forSize: 13 
	
]

{ #category : 'instruction extraction' }
CogOutOfLineLiteralsRiscV64Compiler >> extractOffsetFromLongJump: jumpAddress [ 

	| instLUI offsetLUI instADDIW offsetADDIW |
	"A long jump expands to offset loading + jump register 
	 and the offset loading expands to lui + addiw (we need to go other the jump to reach those"
	"LUI"
	instLUI := objectMemory long32At: jumpAddress - 8.
	self assert: (self instructionIsLUI: instLUI).
	offsetLUI := self signExtendValue: (instLUI >> 12 bitAnd: 16rfffff) << 12 forSize: 20. "20 upper bits"
	"ADDIW"
	instADDIW := objectMemory long32At: jumpAddress - 4.
	self assert: (self instructionIsADDI: instADDIW).
	offsetADDIW := self signExtendValue: (instADDIW >> 20 bitAnd: 16rfff) forSize: 12. "12 lower bits"
	
	^ offsetLUI + offsetADDIW
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fAddRegister: srcReg1 toRegister: srcReg2 intoRegister: destReg [

	"fadd.d: floating point add between registers f[rs1] and f[rs2] and store the sum to f[rd]

	 31      25 24   20 19    15 14  12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  rm  |   rd   |  1010011  |
	rm = 111 by default
	"
	
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fConvertDoublePrecisionInRegister: srcReg toSinglePrecisionInRegister: destReg [

	"fcvt.s.d: Converts the double-precision floating-point number in f[rs1]
	 to a single-precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0100000  |  00001  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r0100000  << 25)
	  bitOr: 2r00001 << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fConvertLongSignedInRegister: srcReg toDoublePrecisionInRegister: destReg [

	"fcvt.d.l: Converts the 64-bit two's complement integer in x[rs1]
	 to a double precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	1101001  |  00010  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r1101001  << 25)
	  bitOr: (2r00010 << 20))
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fConvertSinglePrecisionInRegister: srcReg toDoublePrecisionInRegister: destReg [

	"fcvt.d.s: Converts the single-precision floating-point number in f[rs1]
	 to a double precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0100001  |  00000  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r0100001  << 25)
	  bitOr: 2r00000 << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fDivideRegister: srcReg1 byRegister: srcReg2 intoRegister: destReg [

	"fdiv.d: Divides the double-precision floating point number in register f[rs1] by f[rs2]
	 and writes the rounded double-precision quotient to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0001101  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r0001101 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fLoadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"fld: Loads a double-precision floating-point number from memory 
	 at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  011   |   rd   |   0000111  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r011 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000111) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fLoadWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"flw: Loads a single-precision floating-point number from memory 
	 at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  010   |   rd   |   0000111  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r010 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000111) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fMoveDoubleWordInFRegister: srcFRegister toFRegister: destFRegister [

	"fmv.d: Copies the double-precision floating-point number in f[rs1] to f[rd].
	 expands to fsgnj.d rd, rs1, rs1

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 0010001  |  rs1  |  rs1   |   000  |   rd   |  1010011  |
	"

	self flag: #CLEANUP.
	"Actual bit instruction"
	^ ((((2r0010001 << 25) 
	  bitOr: (srcFRegister bitAnd: 16r1f) << 20)
	  bitOr: (srcFRegister bitAnd: 16r1f) << 15)
	  bitOr: (destFRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fMoveDoubleWordInFRegister: fregister toXRegister: xregister [

	"fmv.x.d: Floating point move doubleword to integer,
    copies the double-precision floating-point number in register f[rs1] to x[rd]

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 1110001  |  00000  |  rs1   |   000  |   rd   |  1010011  |
	"
	
	^ (((2r1110001 << 25) 
	  bitOr: (fregister bitAnd: 16r1f) << 15)
	  bitOr: (xregister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fMoveDoubleWordInXRegister: xregister toFRegister: fregister [

	"fmv.d.x: Floating point move doubleword from integer,
    copies the double-precision floating-point number in register x[rs1] to f[rd]

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 1111001  |  00000  |  rs1   |   000  |   rd   |  1010011  |
	"
	
	"Actual bit instruction"
	^ (((2r1111001 << 25) 
	  bitOr: (xregister bitAnd: 16r1f) << 15)
	  bitOr: (fregister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fMultiplyRegister: srcReg1 fromRegister: srcReg2 intoRegister: destReg [

	"fmul.d: Multiplies the double-precision floating point number in registers f[rs1] and f[rs2]
	 and writes the rounded sdouble-precision difference to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0001001  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r0001001 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isEqualToRegisterValue: srcReg2 [

	"feq.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is equal tot he one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  010   |   rd   |   1010011  |
	"
	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r010 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isLessThanOrEqualToRegisterValue: srcReg2 [

	"fle.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is less than or equal to the one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  000   |   rd   |   1010011  |
	"
	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r000 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isLessThanRegisterValue: srcReg2 [

	"flt.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is less than to the one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  001   |   rd   |   1010011  |
	"
	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r001 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fSquareRootOfRegister: srcReg inRegister: destReg [

	"fsqrt.d: Computes the square root of the double-precision floating-point number in register f[rs1]
	 and writes the rounded double-precision result to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0101101  |  00000  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ ((((2r0101101 << 25)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fStoreDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"fsd: Stores the double-precision floating-point number in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100111  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  signExtendedOffset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20)
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r011 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100111
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fStoreWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"fsw: Stores the single-precision floating-point number in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  010   |   offset[4:0]   |   0100111  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  signExtendedOffset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20)
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r010 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100111
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> fSubtractRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"fsub.d: Substracts the double-precision floating point number in register f[rs2] from register f[rs1] 
	 and writes the rounded sdouble-precision difference to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0000101  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"
	
	^ (((((2r0000101 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> fullCallsAreRelative [
	"Answer if CallFull and/or JumpFull are relative and hence need relocating on method
	 compation. If so, they are annotated with IsRelativeCall in methods and relocated in
	 relocateIfCallOrMethodReference:mcpc:delta:"
	^false
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> genCaptureCStackPointers: captureFramePointer [

	"Save the register to a caller-saved register.
	The caller may have been using the same register for something else.
	So we need to save it and restore it later.
	Make sure to reuse a caller-saved register: we can reuse it freely!
	
	Note: ConcreteIPReg might be used when concretizing MoveCqR, we use ConcreteIPReg2 instead"
	self hasVarBaseRegister ifTrue:
		[cogit
			MoveR: VarBaseReg R: ConcreteIPReg2;
			MoveCq: cogit varBaseAddress R: VarBaseReg].
	captureFramePointer ifTrue:
		[cogit MoveR: FPReg Aw: cogit cFramePointerAddress].

	"Capture the stack pointer prior to the call"
	cogit MoveR: self cStackPointer Aw: cogit cStackPointerAddress.
	
	"Restore the base register for our caller"
	self hasVarBaseRegister ifTrue:
		[cogit MoveR: ConcreteIPReg2 R: VarBaseReg].

	cogit RetN: 0.
]

{ #category : 'abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> genDivR: abstractRegDenominator R: abstractRegNumerator Quo: abstractRegQuotient Rem: abstractRegRemainder [

	"As the two operations will perform a division, one to get the quotient, the other to get the remainder,
	 the quotient reg cannot be the same as the source regs. 
	 The recommended sequence is: 
		DIV rdq, rs1, rs2
		REM rdr, rs1, rs2"
	cogit gen: DivRR operand: abstractRegNumerator operand: abstractRegDenominator operand: ConcreteIPReg.
	cogit gen: RemRR operand: abstractRegNumerator operand: abstractRegDenominator operand: abstractRegRemainder.
	cogit MoveR: ConcreteIPReg R: abstractRegQuotient

]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genLoadCStackPointer [
	"Load the stack pointer register with that of the C stack, effecting
	 a switch to the C stack.  Used when machine code calls into the
	 CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SPReg.
	^0
]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genLoadCStackPointers [
	"Load the frame and stack pointer registers with those of the C stack,
	 effecting a switch to the C stack.  Used when machine code calls into
	 the CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SPReg.
	cogit MoveAw: cogit cFramePointerAddress R: FPReg.
	^0
]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genLoadStackPointers [
	"Switch back to the Smalltalk stack. Assign SPReg first
	 because typically it is used immediately afterwards."
	cogit MoveAw: cogit stackPointerAddress R: SPReg.
	cogit MoveAw: cogit framePointerAddress R: FPReg.
	^0
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> genMarshallNArgs: numArgs arg: regOrConst0 arg: regOrConst1 arg: regOrConst2 arg: regOrConst3 [
	"Generate the code to pass up to four arguments in a C run-time call.  Hack: each argument is
	 either a negative number, which encodes a constant, or a non-negative number, that of a register.

	 Run-time calls have no more than four arguments, so chosen so that on ARM, where in its C ABI the
	 first four integer arguments are passed in registers, all arguments can be passed in registers.  We
	 defer to the back end to generate this code not so much that the back end knows whether it uses
	 the stack or registers to pass arguments (it does, but...). In fact we defer for an extremely evil reason.
	 Doing so allows the x64 (where up to 6 args are passed) to assign the register arguments in an order
	 that allows some of the argument registers to be used for specific abstract  registers, specifically
	 ReceiverResultReg and ClassReg.  This is evil, evil, evil, but also it's really nice to keep using the old
	 register assignments the original author has grown accustomed to."
	<inline: true>
	numArgs = 0 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst0)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst0) R: CArg0Reg]
		ifFalse: [cogit MoveR: regOrConst0 R: CArg0Reg].
	numArgs = 1 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst1)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst1) R: CArg1Reg]
		ifFalse: [cogit MoveR: regOrConst1 R: CArg1Reg].
	numArgs = 2 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst2)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst2) R: CArg2Reg]
		ifFalse: [cogit MoveR: regOrConst2 R: CArg2Reg].
	numArgs = 3 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst3)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst3) R: CArg3Reg]
		ifFalse: [cogit MoveR: regOrConst3 R: CArg3Reg]
]

{ #category : 'abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> genMulR: regSource R: regDest [

	^ cogit gen: MulRR operand: regSource operand: regDest
]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genPushRegisterArgsForAbortMissNumArgs: numArgs [
	"Ensure that the register args are pushed before the outer and
	 inner retpcs at an entry miss for arity <= self numRegArgs.  The
	 outer retpc is that of a call at a send site.  The inner is the call
	 from a method or PIC abort/miss to the trampoline."

	"Putting the receiver and args above the return address means the
	 CoInterpreter has a single machine-code frame format which saves
	 us a lot of work."

	"Iff there are register args convert
		sp		->	outerRetpc			(send site retpc)
		linkReg = innerRetpc			(PIC abort/miss retpc)
	 to
		base	->	receiver
					(arg0)
					(arg1)
		sp		->	outerRetpc			(send site retpc)
		sp		->	linkReg/innerRetpc	(PIC abort/miss retpc)"
	numArgs <= cogit numRegArgs ifTrue:
		[self assert: cogit numRegArgs <= 2.
		 cogit MoveMw: 0 r: SPReg R: TempReg. "Save return address"
		 cogit MoveR: ReceiverResultReg Mw: 0 r: SPReg.
		 numArgs > 0 ifTrue:
			[cogit PushR: Arg0Reg.
			 numArgs > 1 ifTrue:
				[cogit PushR: Arg1Reg]].
		cogit PushR: TempReg]. "push back return address"
	cogit PushR: LinkReg
]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genPushRegisterArgsForNumArgs: numArgs scratchReg: ignored [
	"Ensure that the register args are pushed before the retpc for arity <= self numRegArgs."
	"This is easy on a RISC like ARM because the return address is in the link register.  Putting
	 the receiver and args above the return address means the CoInterpreter has a single
	 machine-code frame format which saves us a lot of work
	NOTA BENE: we do NOT push the return address here, which means it must be dealt with later."
	numArgs <= cogit numRegArgs ifTrue:
		[self assert: cogit numRegArgs <= 2.
		 cogit PushR: ReceiverResultReg.
		numArgs > 0 ifTrue:
			[cogit PushR: Arg0Reg.
			 numArgs > 1 ifTrue:
				[cogit PushR: Arg1Reg]]]
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> genRemoveNArgsFromStack: n [
	"This is a no-op on RISCV since the ABI passes up to 8 args in registers and trampolines currently observe that limit."
	<inline: true>
	self assert: n <= 4.
	^0
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> genRestoreRegs: regMask [
	"Restore the registers in regMask as saved by genSaveRegs:."
	<inline: true>
	| registerCount |
	self assert: (X17 > X10 and: [X17 - X10 + 1 = 8]).
	"self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg))."
	
	registerCount := 0.
	X10 to: X17 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	X10 to: X17 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[cogit PopR: reg]].
	
	"If we are restoring an odd number of registers, this would unalign the stack.
	Then, lets pop the extra thing to force the stack alignment"
	registerCount \\ 2 == 0
		ifFalse: [ 
			cogit PopR: X0  ].
	
	^0
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> genSaveRegForCCall [
	"Save the general purpose registers for a call into the C run-time from a trampoline."
	"Save none, because the ARM ABI only defines callee saved registers, no caller-saved regs."
	"cogit gen: STMFD operand: 16r7F"
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> genSaveRegs: regMask [
	"Save the registers in regMask for a call into the C run-time from a trampoline"
	<inline: true>
	| registerCount |
	self assert: (X17 > X10 and: [X17 - X10 + 1 = 8]).
	self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg)).
	
	registerCount := 0.
	X17 to: X10 by: -1 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	"If we are saving an odd number of registers, this would unalign the stack.
	Then, lets save an extra thing to force the stack alignment"
	registerCount \\ 2 == 0
		ifFalse: [ cogit PushCq: 16rBEEF "Marker smallinteger to generate a valid stack" ].
	
	X17 to: X10 by: -1 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[cogit PushR: reg]].
	^0
]

{ #category : 'smalltalk calling convention' }
CogOutOfLineLiteralsRiscV64Compiler >> genSaveStackPointers [
	"Save the frame and stack pointer registers to the framePointer
	 and stackPointer variables.  Used to save the machine code frame
	 for use by the run-time when calling into the CoInterpreter run-time."
	cogit MoveR: FPReg Aw: cogit framePointerAddress.
	cogit MoveR: SPReg Aw: cogit stackPointerAddress.
	^0
]

{ #category : 'abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> genSubstituteReturnAddress: retpc [
	<inline: true>
	<returnTypeC: #'AbstractInstruction *'>
	^cogit MoveCw: retpc R: LR
]

{ #category : 'printing' }
CogOutOfLineLiteralsRiscV64Compiler >> generalPurposeRegisterMap [
	<doNotGenerate>
	"Answer a Dictionary from register getter to register index."
	^Dictionary newFromPairs:
		{	#r0. X0.
			#r1. X1.
			#r2. X2.
			#r3. X3.
			#r4. X4.
			#r5. X5.
			#r6. X6.
			#r7. X7.
			#r8. X8.
			#r9. X9.
			#r10. X10.
			#r11. X11.
			#r12. X12	}
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasConditionRegister [
	"Answer if the receiver supports, e.g., JumpOverflow after a regular AddRR"
	^true
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasDoublePrecisionFloatingPointSupport [
	"might be true, but is for the forseeable future disabled"
	^true
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasLinkRegister [
	^true "x1/ra"
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasPCDependentInstruction [
	"e.g. B, BL: Branch, Branch and Link"
	^true
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasThreeAddressArithmetic [
	"Answer if the receiver supports three-address arithmetic instructions (currently only AndCqRR)"
	^true
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> hasVarBaseRegister [
	"Answer if the processor has a dedicated callee-saved register to point to
	 the base of commonly-accessed variables. On RISCV we use X26 for this."
	^true "x26/s10"
]

{ #category : 'initialization' }
CogOutOfLineLiteralsRiscV64Compiler >> initialize [
	"This method intializes the Smalltalk instance.  The C instance is merely a struct and doesn't need initialization."
	<doNotGenerate>
	operands := CArrayAccessor on: (Array new: NumOperands).
	machineCode := CArrayAccessor on: (Array new: self machineCodeWords)
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> inlineCacheTagAt: callSiteReturnAddress [

	<inline: true>
	^objectMemory unsignedLongAt: (self pcRelativeAddressAt: 
		"Need to go before the call and at the start of the literal load"
		(callSiteReturnAddress - self callInstructionByteSize - self loadLiteralByteSize) asUnsignedInteger)
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionAddressBefore: followingAddress [
	"Answer the instruction address immediately preceding followingAddress."
	<inline: true>
	^followingAddress -4
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionBeforeAddress: followingAddress [
	"Answer the instruction immediately preceding followingAddress."
	<inline: true>
	<returnTypeC: #'uint32_t'>
	^objectMemory uint32AtPointer: (self instructionAddressBefore: followingAddress)
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsADDI: instruction [

	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r0010011].

]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsADDIW: instruction [

	self flag: #CLEANUP.
	"Check bits 12 to 14 null"
	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r0011011].
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsAUIPC: instruction [

	^ (instruction bitAnd: 16r7F) = 2r0010111.

]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsB: instruction withCondition: condition [

	"Check bits 12 to 14 to the correct condition"
	^ ((instruction >> 12 bitAnd: 16r7) = condition) and: [(instruction bitAnd: 16r7F) = 2r1100011].

]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsConditionalBranch: instruction [
	
	^ (instruction bitAnd: 16r7F) = 2r1100011
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsConditionalZeroBranch: instruction [ 

	self flag: #CLEANUP.
	"Check that the instruction is a conditional branch and that it focuses on the concretezeroreg"
	^ ((instruction bitAnd: 16r7F) = 2r1100011) and: [(instruction >> 15 bitAnd: 16r1F) = ConcreteZeroReg]
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsJAL: instruction [

	^ (instruction bitAnd: 16r7F) = 2r1101111.
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsJALR: instruction [

	"Check bits 12 to 14 null"
	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r1100111].

]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsLD: instruction [ 

	^ ((instruction >> 12 bitAnd: 2r111) = 2r011) and: [(instruction bitAnd: 2r1111111) = 2r0000011]
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsLUI: instruction [

	^ (instruction bitAnd: 16r7F) = 2r0110111.
]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsNOP: instruction [

	self flag: #CLEANUP.
	^ ((instruction >> 7 bitAnd: 16rFFFFFF8) = 0) and: [(instruction bitAnd: 16r7F) = 2r0010011].

]

{ #category : 'instruction detection' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionIsSD: instruction [  

	^ ((instruction >> 12 bitAnd: 16r7) = 2r011) and: [(instruction bitAnd: 16r7F) = 2r0100011].
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> instructionSizeAt: pc [
	"Answer the instruction size at pc"
	^4
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isAddressRelativeToVarBase: varAddress [
	<inline: true>
	<var: #varAddress type: #usqInt>
	"Support for addressing variables off the dedicated VarBaseReg"
	^varAddress notNil
	  and: [varAddress >= cogit varBaseAddress
	  and: [varAddress - cogit varBaseAddress < (1 << 12)]]
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isBigEndian [
	"RISCV is little endian"
	^false
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isCallPrecedingReturnPC: mcpc [
	"There are two types of calls: JAL and JALR"
	| call |
	call := self instructionBeforeAddress: mcpc.
	^(self instructionIsJALR: call) or: (self instructionIsJAL: call)
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isInImmediateBranchRange: operand [
	"RISC-V branches can use immediates of max size 13 bits"
	<var: #operand type: #'usqIntptr_t'>
	^ self value: operand isContainedIn: 13
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isInImmediateCallRange: operand [
	"RISC-V calls can use immediates of max size 32 bits, embedded in two instructions (auipc + jalr)"
	<var: #operand type: #'usqIntptr_t'>
	^ self value: operand isContainedIn: 32
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isInImmediateJumpRange: operand [
	"RISC-V jal and jalr can use immediates of max size 21 bits"
	<var: #operand type: #'usqIntptr_t'>
	^ self value: operand isContainedIn: 21
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isInLongJumpCallRange: offset [
	"RISC-V calls and jumps can use values of max size 32 bits through auipc / jal|jalr"
	^ self value: offset isContainedIn: 32
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> isJump [
	^super isJump or: [opcode between: BrEqualRR and: BrFPGreaterEqualRR]
		"{ BrEqualRR. BrNotEqualRR. 
		BrSignedGreaterRR. BrSignedGreaterEqualRR. 
		BrSignedLessRR. BrSignedLessEqualRR.
		BrUnsignedLessRR. BrUnsignedLessEqualRR. 
		BrUnsignedGreaterRR. BrUnsignedGreaterEqualRR.
		BrLongEqualRR. BrLongNotEqualRR.
		BrFPEqualRR. BrFPNotEqualRR.
		BrFPLessRR. BrFPLessEqualRR.
		BrFPGreaterRR. BrFPGreaterEqualRR } includes: opcode]"
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isJumpAt: pc [
	| instr |
	instr := objectMemory long32At: pc.
	^(self instructionIsJAL: instr)
	  or: [self instructionIsJALR: instr]
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isLiteralLoad: followingAddress [
	"auipc ld"
	^ (self instructionIsAUIPC: (self instructionBeforeAddress: followingAddress - 4)) 
		and: [self instructionIsLD: (self instructionBeforeAddress: followingAddress)]
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> isPCDependent [
	"Answer if the receiver is a pc-dependent instruction.  With out-of-line literals any instruction
	 that refers to a literal depends on the address of the literal, so add them in addition to the jumps."
	^self isJump
	  or: [opcode = AlignmentNops
	  or: [opcode ~= Literal and: [dependent notNil and: [dependent opcode = Literal]]]]
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> isSharable [
	"Hack:  To know if a literal should be unique (not shared) mark the second operand."
	<inline: true>
	self assert: opcode = Literal.
	^operands at: 1
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpLongByteSize [
"	Branch/Call ranges.  Jump[Cond] can be generated as short as possible.  Call/Jump[Cond]Long must be generated
	in the same number of bytes irrespective of displacement since their targets may be updated, but they need only
	span 16Mb, the maximum size of the code zone.  This allows e.g. ARM to use single-word call and jump instructions
	for most calls and jumps.  CallFull/JumpFull must also be generated in the same number of bytes irrespective of
	displacement for the same reason, but they must be able to span the full (32-bit or 64-bit) address space because
	they are used to call code in the C runtime, which may be distant from the code zone"
	
	"Jump long will load a pc-relative offset within 32-bits (enough for the 16mb required for the code space) then jump 
	 using a total of two instructions: auipc + jalr (same as call but does not store the return address)"
	^8
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpLongConditionalByteSize [
	" RISCV-64 does not have conditional long jumps. 
	 Be a short conditional jump (over the long jump instruction) and a long jump "
	^ self jumpLongByteSize + 4
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpLongTargetBeforeFollowingAddress: mcpc [ 
	"Answer the target address for the long jump immediately preceding mcpc"
	^self callTargetFromReturnAddress: mcpc
]

{ #category : 'instruction extraction' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpTargetPCAt: pc [
	<returnTypeC: #usqInt>
	| operand word |
	word := objectMemory long32At: pc.
	operand := word bitAnd: 16rFFFFFF.
	(operand anyMask: 16r800000) ifTrue:
		[operand := operand - 16r1000000].
	^self
		cCode: [operand * 4 + pc + 8]
		inSmalltalk: [operand * 4 + pc + 8 bitAnd: cogit addressSpaceMask]
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpTo: sourceRegisterValueAddress withOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jalr: Sets the pc to x[rs1] + sign-extend(offset), masking off the least-significant bit of the computed address, 
	 then writes the previous pc+4 to x[rd]. If rd is omitted, x1 is assumed.
	
	 31             20  19    15  14   12  11    7  6         0
	|  	offset[11:0]  |   rs1   |  000   |   rd   |   1100111  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ (((((signExtendedOffset bitAnd: 16rfff) << 20)
		bitOr: (sourceRegisterValueAddress bitAnd: 16r1f) << 15)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: 2r1100111)
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpToOffset: offset [
	"j: Pseudo-instruction that writes PC+offset to the PC 
	 Expands to jal, x0, offset
	"
	^ self jumpToOffset: offset andStorePreviousPCPlus4in: X0
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpToOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jal: Writes the address of the next instruction (pc+4) to x[rd],
	 then sets the pc to the current pc plus the sign-extended offset. 
	 If rd is omitted, x1 is assumed
	
	 31                          12 11     7 6         0
	|  	 offset[20|10:1|11|19:12]   |   rd   |   1101111  |
	"

	| signExtendedOffset |
	"Check size and sign"	
	self assertValue: offset isContainedIn: 21.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 21.
	^  (((((((signExtendedOffset >> 20)  bitAnd: 16r1) << 31) 
		bitOr: ((signExtendedOffset >> 1) bitAnd: 16r3ff) << 21)
		bitOr: ((signExtendedOffset >> 11) bitAnd: 16r1) << 20)
		bitOr: ((signExtendedOffset >> 12) bitAnd: 16rff) << 12)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: 2r1101111
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> jumpToRegisterValue: sourceReg [ 
	"jr: Pseudo-instruction that writes x[rs] to the PC 
	 Expands to jalr, x0, 0(rs)
	"
	^ self jumpTo: sourceReg withOffset: 0 andStorePreviousPCPlus4in: X0
]

{ #category : 'private-bit-manipulation' }
CogOutOfLineLiteralsRiscV64Compiler >> leadingOnesOf: aNumber [
	"Return how many leading ones are in the 64bit bitString representation of aNumber.
	That is, how many ones are in the most significant bits before there is a zero.
	For example, the 64bit binary number 2r11101101000110001111...00 has 3 leading ones"
	
	"Calculate it by calculating the leading zeros of the bit-inverted number"
	^ self leadingZerosOf: (aNumber bitXor: 16rFFFFFFFFFFFFFFFF)
]

{ #category : 'private-bit-manipulation' }
CogOutOfLineLiteralsRiscV64Compiler >> leadingZerosOf: aNumber [
	"Return how many leading zeros are in the 64bit bitString representation of aNumber.
	That is, how many zeros are in the most significant bits before there is a one.
	For example, the 64bit binary number 2r00010101000110001111000...00 has 3 trailing zeros.
	
	Uses a bisect method looking at the number by halfs"
	
	"We take a look at the most significant part of the number by ignoring the lower part (shifting it).
	If the non ignored part is not all zeros, continue the procedure with the non-ignored bits.
	On each iteration, ignore less (dividing the shift by two) because there may be more leading zeros.
	"
	| zeroBits currentNumber shift shiftedValue |
	zeroBits := 0.
	currentNumber := aNumber.
	shift := 64"bits" >>1.
	[ shift ~= 0 ] whileTrue: [
		shiftedValue := currentNumber >> shift.
		(shiftedValue ~= 0)
			ifTrue: [ currentNumber := shiftedValue ]
			ifFalse: [ 
				"If we found they are all zeros, record them"
				zeroBits := zeroBits bitOr: shift ].
		shift := shift >> 1.
	].
	^ zeroBits
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> leafCallStackPointerDelta [
	"Answer the delta from the stack pointer after a call to the stack pointer
	 immediately prior to the call.  This is used to compute the stack pointer
	 immediately prior to  call from within a leaf routine, which in turn is used
	 to capture the c stack pointer to use in trampolines back into the C run-time."
	"This might actually be false, since directly after a call, lr, fp and variable registers need be pushed onto the stack. It depends on the implementation of call."
	^0
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literal32BeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 Used for CMP32"
	^ self literalBeforeFollowingAddress: followingAddress 
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literalBeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 If followingAddress points to an ld instruction, it means it is loading a relative using auipc + ld.
	 If not, it is comparing to a given literal and is performing auipc + ld + cmp (expands to several instructions in riscv)"
	^objectMemory long64At: (self pcRelativeAddressAt: 
		((self instructionIsLD: (self instructionBeforeAddress: followingAddress))
			ifTrue: [self instructionAddressBefore: followingAddress - 4] "need to go before auipc + ld"
			ifFalse: [ self instructionAddressBefore: followingAddress + 4 ])) "need to go in the load at the beginning of the cmp"
]

{ #category : 'helpers - size sign' }
CogOutOfLineLiteralsRiscV64Compiler >> literalBeforeInlineCacheTagAt: callSiteReturnAddress [

	self notYetImplemented: 'Should implement access to the class in directed super sends for ARMv8'.
	^ 0
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> literalLoadInstructionBytes [
	"Answer the size of a literal load instruction (which may or may not include the size of the literal).
	 This differs between in-line and out-of-line literal generation."
	<inline: true>
	"Loading a literal will extend to two instructions:
		- auipc: add the pc to the upper 20-bits of the offset  - auipc rd, offsetHigh
		- ld:    load the double word from the computed address - ld    rd, offsetLow(rd)
	 This brings us to two instructions and 8 bits"
	^ 8
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> literalOpcodeIndex [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	^(operands at: 2) asInteger
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadByteFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lb: Loads one byte from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31            20 19    15 14    12 11     7 6         0
	|  	offset[11:0]  |  rs1   |  000   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> loadCwInto: destReg [

	| operand distance offsetLow offsetHigh |
	operand := operands at: 0.
	"self
		cCode: [  ]
		inSmalltalk: [ operand := operand bitAnd: 16rFFFFFFFF ]." "Need to clamp the value to a word size since one or two usages actually generate double sized values and rely upon the C code to narrow it within the running VM"
	(self isAnInstruction: (cogit cCoerceSimple: operand to: #'AbstractInstruction *')) 
		ifTrue: [ operand := (cogit cCoerceSimple: operand to: #'AbstractInstruction *') address ].
	"Try to encode the Cw as a pc-relative first"
	(cogit addressIsInCurrentCompilation: operand)
		ifTrue: [ 
			distance := operand signedIntFromLong - address signedIntFromLong.
			"Check if the absolute distance fits in 12 bits or produce a way to split the distance between the two instructions
		    https://forums.sifive.com/t/bit-11-of-jalr-sign-extened-for-call-auipc-jalr/1950"
			self assertValue: distance isContainedIn: 32.
			"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
			offsetLow := self computeSignedValue64Bits: (distance  bitAnd: 16rFFF).
			offsetHigh := (((self computeSignedValue64Bits: distance) + 16r800) >> 12) bitAnd: 16rFFFFF.
			self machineCodeAt: 0 put: (self addUpperImmediateToPC: offsetHigh toRegister: destReg).
			self machineCodeAt: 4 put: (self addImmediate: offsetLow toRegister: destReg inRegister: destReg).
			^ machineCodeSize := 8 ].
	"Otherwise, load the literal in a register"
	^ self loadLiteralInRegister: destReg
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"ld: Loads eight bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31           20 19     15 14    12 11     7 6          0
	|  	offset[11:0  |   rs1   |  011   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r011 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadHalfWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lh: Loads two bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31           20 19     15 14    12 11     7 6          0
	|  	offset[11:0  |   rs1   |  001   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	self flag: #CLEANUP.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r001 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadImmediate: immediate inRegister: destReg [

	"Uses an addi instruction to load an 11-bit long immediate. If 12 bit long, it will get sign-extended and be incorrect.
	If it is wider than 12 bits, it should be loaded as an out-of-line literal"
	self assertValue: immediate isContainedIn: 11.
	self machineCodeAt: 0 put: (self addImmediate: immediate toRegister: X0 inRegister: destReg).
	^ machineCodeSize := 4
	
	
	
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> loadLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code. On ARM this is a single instruction pc-relative register load - unless we have made a mistake and not turned on the out of line literals manager"
	^8
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadLiteralInRegister: destReg [

	^ self loadLiteralInRegister: destReg startingAtIndex: 0 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadLiteralInRegister: destReg startingAtIndex: index [

	| literalAddress distance |
	"Compute the distance from the current address
	- auipc to get the PC
	- ld    to load relative to the PC"
	self assert: dependent opcode = Literal.
	self assert: (cogit addressIsInCurrentCompilation: dependent address).
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	self assertValue: distance isContainedIn: 12.
	self machineCodeAt: index put: (self addUpperImmediateToPC: 0 toRegister: destReg).
   	self machineCodeAt: index + 4 put: (self loadDoubleWordFromAddressInRegister: destReg withOffset: distance toRegister: destReg).
	^ machineCodeSize := 8

]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> loadPICLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code
	 when the argument is a PIC.  This is for the self-reference at the end of a
	 closed PIC.  On RISC-V this is a two instructions pc-relative register load."
	^8
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadUnsignedByteFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lbu: Loads one byte from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19    15 14    12 11     7 6         0
	|  	offset[11:0]  |  rs1   |  100   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r100 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadUnsignedHalfWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lhu: Loads two bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  101   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r101 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadUnsignedWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lwu: Loads four bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  110   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadUpperImmediate: anImmediate inRegister: destReg [

	"lui: Writes the sign-extended 20-bit immediate, left-shifted by 12 bits,
	 to x[rd], zeroing the lower 12 bits
	
	31                 12 11   7 6         0
	|  	immediate[31:12]  |  rd  |  0110111  |
	"

	| signExtendedImmediate |
	self flag: #CLEANUP.
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 20.	
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 20.
	^ (((signExtendedImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r0110111
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> loadWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lw: Loads four bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  010   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	self flag: #CLEANUP.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r010 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> machineCodeAt: anOffset [

	"read aWord from machineCode, with little endian"

	<inline: true>
	^ machineCode at: anOffset // 4
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> machineCodeAt: anOffset put: aWord [
	"add aWord to machineCode, with little endian"
	<inline: true>
	self haltIf: [ aWord highBit > 32 ].
	machineCode at: anOffset // 4 put: aWord
]

{ #category : 'concretization helpers - mc size' }
CogOutOfLineLiteralsRiscV64Compiler >> machineCodeBytes [
	"Answer the maximum number of bytes of machine code generated for any abstract instruction."
	^ self machineCodeWords * 4
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> machineCodeWords [
	"Answer the maximum number of words of machine code generated for any abstract instruction."
	^ 9
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> mapEntryAddress [
	"Typically map entries apply to the end of an instruction, for two reasons:
	  a)	to cope with literals embedded in variable-length instructions, since, e.g.
		on x86, the literal typically comes at the end of the instruction.
	  b)	in-line cache detection is based on return addresses, which are typically
		to the instruction following a call.
	 But with out-of-line literals it is more convenient to annotate the literal itself."
	<inline: true>
	^opcode = Literal
		ifTrue: [address]
		ifFalse: [address + machineCodeSize]
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> moveRegister: srcReg toRegister: destReg [

	"mv is pseudo instruction that expands to addi rd, rs1, 0"	
	^ self addImmediate: 0 toRegister: srcReg inRegister: destReg
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> multiplyHighRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mulh: multiplies x[rs1] by x[rs2] treating the values as two's complement numbers, 
			 and writes the upper half of the product to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  010  |   rd   |   0110011   |
	"
	
	^ ((((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r001 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> multiplyRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mul: multiplies x[rs1] by x[rs2] treating the values as two's complement numbers, 
			 and writes the upper half of the product to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  000  |   rd   |   0110011   |
	"
	
	^ ((((((2r1 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> multiplyWordRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mulw: multiplies x[rs1] by x[rs2] truncates the product to 32 bits, 
			 and writes the sign-extended value to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  000  |   rd   |   0111011   |
	"

	self flag: #CLEANUP.
	"Actual bit instruction"
	^ ((((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0111011) 


	
]

{ #category : 'printing' }
CogOutOfLineLiteralsRiscV64Compiler >> nameForFPRegister: reg [ "<Integer>"
	<doNotGenerate>
	(reg between: 0 and: 7) ifTrue:
		[^#(D0 D1 D2 D3 D4 D5 D6 D7) at: reg + 1].
	^super nameForFPRegister: reg
]

{ #category : 'printing' }
CogOutOfLineLiteralsRiscV64Compiler >> nameForRegister: reg [ "<Integer>"
	<doNotGenerate>
	| default |
	default := super nameForRegister: reg.
	^default last = $?
		ifTrue:
			[#(LR SP PC CArg0Reg CArg0Reg CArg1Reg CArg2Reg CArg3Reg)
				detect: [:sym| (thisContext method methodClass classPool at: sym) = reg] 
				ifNone: [default]]
		ifFalse:
			[default]
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> negateValueInRegister: srcReg intoRegister: destReg [ 

	"neg: Negate value in register x[rs1] and stores it in x[rd].
	 Expands to sub rd, x0, rs"
	
	^ self subtractRegister: srcReg fromRegister: X0 intoRegister: destReg

	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> nop [
	
	"nop: Pseudoinstruction that expands to addi x0, 0(x0)"
	^ self addImmediate: 0 toRegister: X0 inRegister: X0 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> noteFollowingConditionalBranch: branch [
	"Support for processors without condition codes, such as the MIPS.
	 Answer the branch opcode.  Modify the receiver and the branch to
	 implement a suitable conditional branch that doesn't depend on
	 condition codes being set by the receiver."
	<returnTypeC: #'AbstractInstruction *'>
	<var: #branch type: #'AbstractInstruction *'>
	| newBranchLeft newBranchOpcode newBranchRight |
	
	"Specific for overflow"
	((branch opcode = JumpOverflow) or: [branch opcode = JumpNoOverflow]) 
		ifTrue: [^self noteFollowingOverflowBranch: branch].
	opcode caseOf: {
		[BrEqualRR]	->	["I.e., two jumps after a compare."
			           newBranchLeft := operands at: 1.
			           newBranchRight := operands at: 2].
		[BrUnsignedLessRR]	->	["I.e., two jumps after a compare."
			           newBranchLeft := operands at: 1.
			           newBranchRight := operands at: 2].
		[CmpRR]   -> [newBranchLeft := operands at: 1.
		              newBranchRight := operands at: 0.
		              opcode := Label].
		[CmpRdRd] -> [newBranchLeft := operands at: 0.
		              newBranchRight := operands at: 1.
		              opcode := Label].
		"Todo: The quick constants could be embedded in the branch directly if possible"
		[CmpCqR]	 -> [newBranchLeft := operands at: 1.
						  newBranchRight := ConcreteIPReg.
						  opcode := MoveCqR.
						  operands at: 1 put: ConcreteIPReg].
		[CmpCwR]	 -> [newBranchLeft := operands at: 1.
						  newBranchRight := ConcreteIPReg.
						  opcode := MoveCwR.
						  operands at: 1 put: ConcreteIPReg].
      [CmpC32R]	 -> [newBranchLeft := operands at: 1.
						  newBranchRight := ConcreteIPReg.
						  opcode := MoveCwR.
						  operands at: 1 put: ConcreteIPReg].
		[TstCqR]	 ->	 [newBranchLeft := ConcreteZeroReg. 
						  newBranchRight := X0].
		[AndCqR]	 ->	 [newBranchLeft := operands at: 1.
				        newBranchRight := X0].
		[AndCqRR]	 -> [newBranchLeft := operands at: 2.
						  newBranchRight := X0].
		[OrRR]   	 -> [newBranchLeft := operands at: 1.
						  newBranchRight := X0].
		[XorRR]   -> [newBranchLeft := operands at: 1.
		              newBranchRight := X0].
		[SubCwR]	 ->	 [newBranchLeft := operands at: 1.
						  newBranchRight := X0].
		[SubCqR]	 -> [newBranchLeft := operands at: 1.
						  newBranchRight := X0].
		[ SubRR ] -> [newBranchLeft := operands at: 1.
						  newBranchRight := X0].
		[ArithmeticShiftRightCqR]	->	[newBranchLeft := operands at: 1.
						 newBranchRight := X0].
	} otherwise: [self unreachable].
	
	newBranchOpcode := branch opcode caseOf: {
		[JumpZero]             -> [BrEqualRR].
		[JumpNonZero]          -> [BrNotEqualRR].
		[JumpBelow]            -> [BrUnsignedLessRR].
		[JumpBelowOrEqual]     -> [BrUnsignedLessEqualRR].
		[JumpAbove]            -> [BrUnsignedGreaterRR].
		[JumpAboveOrEqual]     -> [BrUnsignedGreaterEqualRR].
		[JumpLess]             -> [BrSignedLessRR].
		[JumpLessOrEqual]      -> [BrSignedLessEqualRR].
		[JumpGreater]          -> [BrSignedGreaterRR].
		[JumpGreaterOrEqual]   -> [BrSignedGreaterEqualRR].
		[JumpLongZero]         -> [BrLongEqualRR].
		[JumpLongNonZero]      -> [BrLongNotEqualRR].
		[JumpNegative]         -> [BrSignedLessRR].
		[JumpFPEqual]          -> [BrFPEqualRR].
		[JumpFPNotEqual]       -> [BrFPNotEqualRR].
		[JumpFPLess]           -> [BrFPLessRR].
	   [JumpFPLessOrEqual]    -> [BrFPLessEqualRR].
		[JumpFPGreater]        -> [BrFPGreaterRR].
		[JumpFPGreaterOrEqual] -> [BrFPGreaterEqualRR].
	} otherwise: [self unreachable. 0].

	branch rewriteOpcode: newBranchOpcode with: newBranchLeft with: newBranchRight.
	^branch
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> noteFollowingOverflowBranch: branch [
	"Support for processors without condition codes, such as the RISC-V.
	 Answer the branch opcode.  Modify the receiver and the branch to
	 implement a suitable conditional branch that doesn't depend on
	 condition codes being set by the receiver."
	<var: #branch type: #'AbstractInstruction *'>
	| newBranchOpcode |

	(opcode = SubRR or: opcode = SubCqR) ifTrue:
		[opcode := opcode caseOf: {
			[ SubCqR ] -> [ SubCheckOverflowCqR ].
			[ SubRR ] -> [ SubCheckOverflowRR ].
		}.
		 newBranchOpcode := branch opcode caseOf: {
			[JumpOverflow]		-> [BrEqualRR].
			[JumpNoOverflow]	-> [BrNotEqualRR].
		 } otherwise: [self unreachable. 0].
		 branch rewriteOpcode: newBranchOpcode with: ConcreteIPReg2 with: ConcreteIPReg3.
		 ^branch].

	opcode := opcode caseOf: {
		[AddCqR] -> [AddCheckOverflowCqR].
		[AddRR]  -> [AddCheckOverflowRR].
	   [MulRR]  -> [MulCheckOverflowRR].
	} otherwise: [self unreachable. 0].

	newBranchOpcode := branch opcode caseOf: {
		[JumpOverflow]		-> [BrNotEqualRR].
		[JumpNoOverflow]	-> [BrEqualRR].
	} otherwise: [self unreachable. 0].
	branch rewriteOpcode: newBranchOpcode with: ConcreteIPReg2 with: ConcreteIPReg3.
	^branch
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> numICacheFlushOpcodes [
	"ARM needs to do icache flushing when code is written"
	"for now return 0 to skip it and probably blow up"
	^0
	
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> numIntRegArgs [
	^8
]

{ #category : 'compile abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> outOfLineLiteralOpcodeLimit [
	"The maximum offset in a LDR is (1<<12)-1, or (1<<10)-1 instructions.
	 Be conservative.  The issue is that one abstract instruction can emit
	 multiple hardware instructions so we assume a 2 to 1 worst case of
	 hardware instructions to abstract opcodes.."
	^1 << (12 "12-bit offset field"
			- 3 "8 bytes per literal, so 2^3?"
			- 1 "2 hardware instructions to 1 abstract opcode") - 1
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> outputMachineCodeAt: targetAddress [
	"Override to move machine code a word at a time."
	<inline: true>
	0 to: machineCodeSize - 1 by: 4 do:
		[:j|
		objectMemory uint32AtPointer: targetAddress + j put: (machineCode at: j // 4)]
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> padIfPossibleWithStopsFrom: startAddr to: endAddr [
	| nullBytes |
	nullBytes := (endAddr - startAddr + 1) \\ 4.
	self stopsFrom: startAddr to: endAddr - nullBytes.
	endAddr - nullBytes + 1 to: endAddr 
		do: [ :p | objectMemory byteAt: p put: 16rFF]
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> pcRelativeAddressAt: instrAddress [
	"Extract the address out of a pc-relative load (auipc + ld)"
	
	| instAUIPC instLD offsetAUIPC offsetLD |
	instAUIPC := objectMemory long32At: instrAddress.
	instLD := objectMemory long32At: instrAddress + 4.
	self assert: (self instructionIsAUIPC: instAUIPC).
	self assert: (self instructionIsLD: instLD).
	"Each offset is sign-extended then added"
	offsetAUIPC := self computeSignedValueOf: (instAUIPC >> 12 bitAnd: 16rfffff) << 12 ofSize: 32. "20 upper bits"
	offsetLD := self computeSignedValueOf: (instLD >> 20 bitAnd: 16rfff) ofSize: 32. "12 lower bits"
	"((offset allMask: (1 << 12))
						   ifTrue: [offset negated]
							ifFalse: [offset])"
	^instrAddress + offsetAUIPC + offsetLD
]

{ #category : 'calling C function in Smalltalk stack' }
CogOutOfLineLiteralsRiscV64Compiler >> prepareStackToCallCFunctionInSmalltalkStack: anObject [ 

	self flag: #STACK.
	cogit MoveR: SPReg R: Extra2Reg.
	cogit AndCq: ((1 << 64) - 16) R: Extra2Reg. 
	cogit MoveR: Extra2Reg R: SP.
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> pushLinkRegisterByteSize [

	^8
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> relocateCallBeforeReturnPC: retpc by: delta [
	
	| offset |
	self assert: delta \\ 4 = 0.
	delta = 0 ifTrue: [ ^ self ].
   offset := self callTargetFromReturnAddress: retpc.
   self rewriteCallAt: retpc target: offset + delta
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> relocateMethodReferenceBeforeAddress: pc by: delta [
	"If possible we generate the method address using pc-relative addressing.
	 If so we don't need to relocate it in code.  So check if pc-relative code was
	 generated, and if not, adjust a load literal.  There are two cases, a push
	 or a register load.  If a push, then there is a register load, but in the instruction
	 before."
	| pcFollowingLoad reference litAddr |
	"PushCw expands to addi sp -8 then sd rd 0(sp)"
	pcFollowingLoad := ((self instructionIsADDI: (self instructionBeforeAddress: pc - 4)) and: 
								[ self instructionIsSD: (self instructionBeforeAddress: pc) ])
							ifTrue:  [ pc-8 ]
							ifFalse: [ pc ].
	"If the load is not done via pc-relative addressing we have to relocate."
	(self isLiteralLoad: pcFollowingLoad) 
		ifTrue: "auipc + ld"
			[litAddr := self pcRelativeAddressAt: pcFollowingLoad - self loadLiteralByteSize.
		 	 reference := objectMemory long64At: litAddr.
		    objectMemory long64At: litAddr put: reference + delta - 4]
		ifFalse: "auipc + addi"
			[ "no need to relocate"
			  self assert: (self instructionIsAUIPC: (self instructionBeforeAddress: pcFollowingLoad - 4)). 
		     self assert: (self instructionIsADDI: (self instructionBeforeAddress: pcFollowingLoad)) ]
	



]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> remainderOfDivisionRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"rem Divides x[rs1] by x[rs2], rounding towards 0, treating the values as two's complement numbers
	 and writes the remainder to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  110  |   rd   |   0110011   |
	"
	
	"Actual bit instruction"
	^ ((((((2r1 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> ret [
	
	"ret: Pseudoinstruction that expands to jalr, x0, 0(x1)"
   ^ self jumpTo: LR  withOffset: 0 andStorePreviousPCPlus4in: X0
	
]

{ #category : 'calling C function in Smalltalk stack' }
CogOutOfLineLiteralsRiscV64Compiler >> returnFromCallCFunctionInSmalltalkStack: anObject [

	cogit MoveR: Extra2Reg R: SPReg.

]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteBTypeBranchAtAddress: mcpc offset: newOffset withCondition: condition [
	| oldInstruction newInstruction srcReg1 srcReg2 |
	"Extract comparison registers from old instruction"
	oldInstruction := objectMemory uint32AtPointer: mcpc.
	srcReg1 := (oldInstruction bitAnd: (16r1F << 15)) >> 15.
	srcReg2 := (oldInstruction bitAnd: (16r1F << 20)) >> 20.
	
	"Generate new instruction"
	newInstruction := self branchTo: newOffset ifCondition: condition betweenRegister: srcReg1 andRegister: srcReg2.
	
	objectMemory uint32AtPointer: mcpc put: newInstruction.
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteBTypeBranchAtAddress: mcpc target: newTarget withCondition: condition [
	| newOffset oldInstruction newInstruction srcReg1 srcReg2 |
	"Format target"
	newOffset := newTarget - mcpc.
	"Extract comparison registers from old instruction"
	oldInstruction := objectMemory uint32AtPointer: mcpc.
	srcReg1 := (oldInstruction bitAnd: (16r1F << 15)) >> 15.
	srcReg2 := (oldInstruction bitAnd: (16r1F << 20)) >> 20.
	
	"Generate new instruction"
	newInstruction := self branchTo: newOffset ifCondition: condition betweenRegister: srcReg1 andRegister: srcReg2.
	
	objectMemory uint32AtPointer: mcpc put: newInstruction.
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteCallAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a call/jump instruction to call a different target.  This variant is used to link PICs
	 in ceSendMiss et al, and to rewrite call/jumps in CPICs. Answer the extent of the code change 
	 which is used to compute the range of the icache to flush.
	
	 auipc offsetHigh 
	 jalr offsetLow 
	 ... <-- callSiteReturnAddress"
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| callDistance offsetLow offsetHigh |
	callTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].

	callDistance := (callTargetAddress - (callSiteReturnAddress - 8 "return offset")).
	self assert: (self isInImmediateCallRange: callDistance). "we don't support long call updates, yet"

	self assert: (self instructionIsAUIPC: (self instructionBeforeAddress: callSiteReturnAddress - 4)).
	self assert: (self instructionIsJALR: (self instructionBeforeAddress: callSiteReturnAddress)).
	"Need to modify the whole instructions -> auipc + jalr"
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (callDistance bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: callDistance) + 16r800) >> 12) bitAnd: 16rFFFFF.

	"auipc"
	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress - 4)
		put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	"jalr"
	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress)
		put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: LR).

	self assert: (self callTargetFromReturnAddress: callSiteReturnAddress) = callTargetAddress.

	^8
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteCallFullAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a full call instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'blx ip' instruction for the actual call.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."

	"This is the assembled instruction jr ip. 
	 This will break if we change the assignment of registers
	 It can be obtained with 
		CogRiscV64Compiler new jumpTo: ConcreteIPReg withOffset: 0 andStorePreviousPCPlus4in: LR"

	<inline: true>
	^ self
		rewriteFullTransferAt: callSiteReturnAddress 
		target: callTargetAddress
		expectedInstruction: 16r000280E7 "16r000280E7 riscv64Disassembled -> nil:	jalr t0 "
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteConditionalJumpLongAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	self flag: #TODO.
	1halt.
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteFullTransferAt: callSiteReturnAddress target: callTargetAddress expectedInstruction: expectedInstruction [
	"Rewrite a CallFull or JumpFull instruction to transfer to a different target.
	 This variant is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'jr ip' or 'jalr ip' instruction for the actual jump or call.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	self assert: (self instructionBeforeAddress: callSiteReturnAddress) = expectedInstruction.
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 12) put: callTargetAddress.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^0
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheAt: callSiteReturnAddress tag: cacheTag target: callTargetAddress [
	"Rewrite an inline cache to call a different target for a new tag.  This variant is used
	 to link unlinked sends in ceSend:to:numArgs: et al.  Answer the extent of the code
	 change which is used to compute the range of the icache to flush.
	
	 Call:
	 auipc offsetHigh 
	 jalr offsetLow 
	 ... <-- callSiteReturnAddress
	
	 Cache:
	 cacheTag <-- pcRelativeAddress from call"
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| codeChange |
	"Patch call"
	codeChange := self rewriteCallAt: callSiteReturnAddress target: callTargetAddress.
	"Patch tag referenced by earlier call"
	objectMemory
		longAt: (self pcRelativeAddressAt: callSiteReturnAddress - self callInstructionByteSize - self loadLiteralByteSize) 
		put: cacheTag signedIntToLong64.

	self assert: (self inlineCacheTagAt: callSiteReturnAddress) = cacheTag  signedIntToLong64.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^ codeChange
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheTag: cacheTag at: callSiteReturnAddress [
	"Rewrite an inline cache with a new tag.  This variant is used by the garbage collector."
	<inline: true>
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteJumpFullAt: jumpFullReturnAddress target: jumpFullTargetAddress [
	"Rewrite a full jump instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'jr ip' instruction for the actual jump.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	
	"This is the assembled instruction jr ip. 
	 This will break if we change the assignment of registers
	 It can be obtained with 
		CogRiscV64Compiler new jumpToRegisterValue: ConcreteIPReg."
		
	<inline: true>
	^ self
		rewriteFullTransferAt: jumpFullReturnAddress 
		target: jumpFullTargetAddress
		expectedInstruction: 16r00028067 "16r00028067 riscv64Disassembled -> nil:	jr	t0 "

]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteJumpLongAt: jumpReturnAddress target: jumpTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to link PICs 
	 in ceSendMiss et al, and to rewrite jumps in CPICs.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #jumpReturnAddress type: #usqInt>
	<var: #jumpTargetAddress type: #usqInt>
	| jumpDistance offsetLow offsetHigh instr |
	jumpTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].
	jumpDistance := (jumpTargetAddress - (jumpReturnAddress - 8 "return offset")).
	self assert: (self isInLongJumpCallRange: jumpDistance).

	instr := self instructionBeforeAddress: jumpReturnAddress.
	self assert: (self instructionIsJALR: instr).
	"Need to modify the whole instructions -> auipc + jalr"
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (jumpDistance bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: jumpDistance) + 16r800) >> 12) bitAnd: 16rFFFFF.

	"auipc"
	objectMemory
		uint32AtPointer: (self instructionAddressBefore: jumpReturnAddress - 4)
		put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	"jalr"
	objectMemory
		uint32AtPointer: (self instructionAddressBefore: jumpReturnAddress)
		put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).

	self assert: (self jumpLongTargetBeforeFollowingAddress: jumpReturnAddress) = jumpTargetAddress.
	
	^8
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteOpcode: anOpcode with: left with: right [
	<inline: true>
	opcode := anOpcode.
	operands
		"0 is target"
		at: 1 put: left;
		at: 2 put: right
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewritePICJumpAt: addressFollowingJump target: jumpTargetAddr [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the jumps in the prototype PIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	
	<var: #addressFollowingJump type: #usqInt>
	<var: #jumpTargetAddr type: #usqInt>
	| callOffset |
	"self CmpR: ClassReg R: TempReg.
	^self JumpNonZero: 0"
	
	"bne r1, r2, offset
	 .... <-- addressFollowingJump
	 
	 ...  <-- jumpTargetAddress"
	callOffset := jumpTargetAddr - addressFollowingJump + 4.
	self assertValue: callOffset isContainedIn: 12. 
	
 	self assert: (self instructionIsB: (self instructionBeforeAddress: addressFollowingJump) withCondition: NE).
	self rewriteBTypeBranchAtAddress: addressFollowingJump - 4 offset: callOffset withCondition: NE.
	
	self assert: (self instructionIsB: (self instructionBeforeAddress: addressFollowingJump) withCondition: NE).
	self assert: (self extractOffsetFromConditionalBranch: (self instructionBeforeAddress: addressFollowingJump)) = callOffset.

	^4
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> rotateLeftValueInRegister: srcReg byShiftAmount: shamt inRegister: destReg startingAtIndex: index [

	"roli: not defined in RISCV64G but can expand to: 
	slli rd, rs1, shamt           | x[rs1] >> shamt             (1)
	srli temp, rs1, (-shamt & 63) | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp               | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	"https://stackoverflow.com/questions/55394123/how-do-i-write-rotation-operation-for-the-risc-vassembly-language-do-we-have-a"
	self assert: shamt > 0.
	self assertValue: shamt isContainedIn: 6. "6 bits for RV64, 5 or RV32"
	"Notice that srcReg is the same as destReg"
	self machineCodeAt: index put: (self shiftLeftValueInRegister: srcReg byShiftAmount: shamt intoRegister: ConcreteIPReg2).
	self machineCodeAt: index + 4 put: (self shiftRightValueInRegister: srcReg byShiftAmount: (shamt negated bitAnd: 16r3f) intoRegister: destReg). 
	self machineCodeAt: index + 8 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> rotateLeftValueInRegister: srcReg byShiftAmountInRegister: shamtReg inRegister: destReg startingAtIndex: index [

	"rol: not defined in RISCV64G but can expand to: 
	sll rd, rs1, rshamt          | x[rs1] >> shamt             (1)
	sub temp, zero, rshamt       | 
	srl temp, rs1, temp          | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp              | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	
	self machineCodeAt: 0 put: (self shiftLeftValueInRegister: srcReg byShiftAmountInRegister: shamtReg intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self negateValueInRegister: shamtReg intoRegister: destReg).
	self machineCodeAt: 8 put: (self shiftRightValueInRegister: srcReg byShiftAmountInRegister: destReg intoRegister: destReg).
	self machineCodeAt: 12 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 16
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> rotateRightValueInRegister: srcReg byShiftAmount: shamt inRegister: destReg startingAtIndex: index [

	"rori: not defined in RISCV64G but can expand to: 
	srli rd, rs1, shamt           | x[rs1] >> shamt             (1)
	slli temp, rs1, (-shamt & 63) | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp               | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	"https://stackoverflow.com/questions/55394123/how-do-i-write-rotation-operation-for-the-risc-vassembly-language-do-we-have-a"
	
	self assert: shamt > 0.
	self assertValue: shamt isContainedIn: 6. "6 bits for RV64, 5 or RV32"
	self machineCodeAt: 0 put: (self shiftRightValueInRegister: srcReg byShiftAmount: shamt intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self shiftLeftValueInRegister: srcReg byShiftAmount: (shamt negated bitAnd: 16r3f) intoRegister: destReg).
	self machineCodeAt: 8 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> rotateRightValueInRegister: srcReg byShiftAmountInRegister: shamtReg inRegister: destReg startingAtIndex: index [

	"ror: not defined in RISCV64G but can expand to: 
	srl rd, rs1, rshamt          | x[rs1] >> shamt             (1)
	sub temp, zero, rshamt       | 
	sll temp, rs1, temp          | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp              | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	self machineCodeAt: 0 put: (self shiftRightValueInRegister: srcReg byShiftAmountInRegister: shamtReg intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self negateValueInRegister: shamtReg intoRegister: destReg).
	self machineCodeAt: 8 put: (self shiftLeftValueInRegister: srcReg byShiftAmount: destReg intoRegister: destReg).
	self machineCodeAt: 12 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 16
]

{ #category : 'abi' }
CogOutOfLineLiteralsRiscV64Compiler >> saveAndRestoreLinkRegAround: aBlock [
	"If the processor's ABI includes a link register, generate instructions
	 to save and restore it around aBlock, which is assumed to generate code."
	<inline: true>
	| inst |
	inst := cogit PushR: LinkReg.
	aBlock value.
	cogit PopR: LinkReg.
	^inst
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> setLiteralOpcodeIndex: index [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	operands at: 2 put: index
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifUnsignedValueIn: srcReg isLessThanImmediate: anImmediate [

	"sltiu: Compares x[rs1] and the sign-extended immediate as unsigned numbers, 
	       and writes 1 to x[rd] if x[rs1] is smaller or 0 if not.
 	
	 31               20 19   15 14  12 11    7 6        0
	|  immediate[11:0]  |  rs1  |  011  |  rd  |  0010011  |
	"
	
	^ (((((anImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r011 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifUnsignedValueIn: srcReg1 isLessThanUnsignedValueIn: srcReg2 [

	"sltu: Compares x[rs1] and x[rs2] as two's complement numbers, and writes 1 to x[rd]
	      if x[rs1] is smaller or 0 if not.
 	
	 31       25 24   20 19   15 14  12 11    7 6        0
	|  0000000  |  rs2  |  rs1  |  011  |  rd  |  0110011  |
	"
	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r011 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifValueIn: srcReg isLessThanImmediate: anImmediate [

	"slti: Compares x[rs1] and the sign-extended immediate as two's complement numbers, 
	       and writes 1 to x[rd] if x[rs1] is smaller or 0 if not.
 	
	 31               20 19   15 14  12 11    7 6        0
	|  immediate[11:0]  |  rs1  |  010  |  rd  |  0010011  |
	"
	
	^ (((((anImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r010 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifValueIn: srcReg1 isLessThanValueIn: srcReg2 [

	"slt: Compares x[rs1] and x[rs2] as two's complement numbers, and writes 1 to x[rd]
	      if x[rs1] is smaller or 0 if not.
 	
	 31       25 24   20 19   15 14  12 11    7 6        0
	|  0000000  |  rs2  |  rs1  |  010  |  rd  |  0110011  |
	"
	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r010 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifValueInRegisterIsEqualToZero: srcReg [

	"seqz: Writes 1 to x[rd] if x[rs1] is equal to 0, or 0 if not.
	 Expands to sltiu rd, rs1, 1
	"
	
	^ self setOneIn: destReg ifUnsignedValueIn: srcReg isLessThanImmediate: 1
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> setOneIn: destReg ifValueInRegisterIsNotEqualToZero: srcReg [

	"seqz: Writes 0 to x[rd] if x[rs1] is equal to 0, or 1 if not.
	 Expands to sltiu rd, rs1, 1
	"

	self flag: #CLEANUP.	
	^ self setOneIn: destReg ifUnsignedValueIn: X0 isLessThanUnsignedValueIn: srcReg
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> setsConditionCodesFor: aConditionalJumpOpcode [
	<inline: false> "to save Slang from having to be a real compiler (it can't inline switches that return)"
	"Answer if the receiver's opcode sets the condition codes correctly for the given conditional jump opcode.
	ARM has to check carefully since the V flag is not affected by non-comparison instructions"
	^opcode caseOf:
		{	[ArithmeticShiftRightCqR]	->	[false].
			[ArithmeticShiftRightRR]		->	[false].
			[LogicalShiftLeftCqR]			->	[false].
			[LogicalShiftLeftRR]			->	[false].
			[LogicalShiftRightCqR]		->	[false].
			[XorRR]							->	[false]
		}
		otherwise: [self logError: 'unhandled opcode in setsConditionCodesFor:'. self abort. false]
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> shiftLeftValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"slli: Shifts register x[rs1] left by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  001  |  rd  |  0010011  |
	"
	| signExtendedShamt |
	"Check size and sign"
	self assertValue: shiftAmount isContainedIn: 6.
	signExtendedShamt := self computeSignedValueOf: shiftAmount ofSize: 6.
	^ (((((signExtendedShamt bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r001 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> shiftLeftValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"sll: Shifts register x[rs1] left by x[rs2] bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0000000 |  rs2  |  rs1  |  001  |  rd  |  0110011  |
	"
	
	^ ((((2r000000 << 25
	  bitOr: (sourceReg2 bitAnd: 16r1f) << 20) 
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r001 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> shiftRightValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"srli: Shifts register x[rs1] right by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  101  |  rd  |  0010011  |
	"
	| signExtendedShamt |
	"Check size and sign"
	self assertValue: shiftAmount isContainedIn: 6.
	signExtendedShamt := self computeSignedValueOf: shiftAmount ofSize: 6.
	^ (((((signExtendedShamt bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> shiftRightValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"srl: Shifts register x[rs1] right by x[rs2] bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0000000 |  rs2  |  rs1  |  101  |  rd  |  0110011  |
	"
	
	^ (((((sourceReg2 bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> signExtendValue: value forSize: size [

	| mask bitMask signMask |
	"Reverse two's complement"
	signMask := 1 << (size - 1).
	mask := 1 << size - 1.
	^ ((value bitAnd: mask) bitXor: signMask) - signMask
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> sizePCDependentInstructionAt: eventualAbsoluteAddress [
	"Size a jump and set its address.  The target may be another instruction
	 or an absolute address.  On entry the address inst var holds our virtual
	 address. On exit address is set to eventualAbsoluteAddress, which is
	 where this instruction will be output.  The span of a jump to a following
	 instruction is therefore between that instruction's address and this
	 instruction's address ((which are both still their virtual addresses), but the
	 span of a jump to a preceding instruction or to an absolute address is
	 between that instruction's address (which by now is its eventual absolute
	 address) or absolute address and eventualAbsoluteAddress.

	 ARM is simple; the 26-bit call/jump range means no short jumps.  This
	 routine only has to determine the targets of jumps, not determine sizes.

	 This version also deals with out-of-line literals.  If this is the real literal,
	 update the stand-in in literalsManager with the address (because instructions
	 referring to the literal are referring to the stand-in).  If this is annotated with
	 IsObjectReference transfer the annotation to the stand-in, whence it will be
	 transferred to the real literal, simplifying update of literals."

	opcode = AlignmentNops ifTrue:
		[| alignment |
		 address := eventualAbsoluteAddress.
		 alignment := operands at: 0.
		 ^machineCodeSize := (eventualAbsoluteAddress + (alignment - 1) bitAnd: alignment negated)
							   - eventualAbsoluteAddress].
	self assert: (self isJump or: [opcode = Call or: [opcode = CallFull
				or: [dependent notNil and: [dependent opcode = Literal]]]]).
	self isJump ifTrue: [self resolveJumpTarget].
	address := eventualAbsoluteAddress.
	(dependent notNil and: [dependent opcode = Literal]) ifTrue:
		[opcode = Literal ifTrue:
			[dependent address: address].
		 annotation = cogit getIsObjectReference ifTrue:
			[dependent annotation: annotation.
			 annotation := nil]].
	^machineCodeSize := maxSize
]

{ #category : 'accessing' }
CogOutOfLineLiteralsRiscV64Compiler >> stackPageInterruptHeadroomBytes [
	"Return a minimum amount of headroom for each stack page (in bytes).  In a
	 JIT the stack has to have room for interrupt handlers which will run on the stack.
	According to ARM architecture v5 reference manual chapter A2.6, the basic interrupt procedure does not push anything onto the stack. It uses SPSR_err and R14_err to preserve state. Afterwards, it calls an interrupt procedure. So leave some room."
	^128 "32 words"
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> stackPointerAlignment [
	
	<doNotGenerate>
	"As for the RISC-V Architecture Reference Manual:
	In the standard RISC-V calling convention, the stack grows downward and the stack pointer is always kept 16-byte aligned"
	^ 16
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> stop [

	"ebreak: Environment breakpoint, makes a request of the debugger by raising a BREAKPOINT exception"
	^ ((((2r0000000000001 << 20)
	  bitOr: 2r00000 << 15)
	  bitOr: 2r000 << 12)
	  bitOr: 2r00000 << 7)
	  bitOr: 2r1110011
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> stopsFrom: startAddr to: endAddr [

	self assert: endAddr - startAddr + 1 \\ 4 = 0.
	startAddr to: endAddr by: 4 do: 
		[:addr | objectMemory long32At: addr put: self stop].
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> storeByteFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sb: Stores the least-significant byte in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  000   |  offset[4:0]  |   0100011  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r000 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> storeDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sd: Stores the eight bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100011  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  signExtendedOffset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20)
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r011 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> storeHalfWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw: Stores the two lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  001   |  offset[4:0]  |   0100011  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r001 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> storeLiteral32: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal in the instruction immediately preceding followingAddress"
	^ self storeLiteral: literal beforeFollowingAddress: followingAddress
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal referenced by the instruction immediately preceding followingAddress.
	 Two cases lead to this method: either a MoveCwR or PushCw.
	 If followingAddress points to an ld instruction, it means it is loading a relative using auipc + ld."
	
	"Cmp/MoveCwR
	 pc-8 auipc 
	 pc-4 ld"
	(self instructionIsLD: (self instructionBeforeAddress: followingAddress)) ifTrue: [ 
		objectMemory 
			longAt: (self pcRelativeAddressAt: (self instructionAddressBefore: followingAddress - 4))
			put: literal
		 ].
	
	"PushCw
	 pc-16 auipc
	 pc-12 ld
	 pc-8  addi
	 pc-4  sd"
	(self instructionIsSD: (self instructionBeforeAddress: followingAddress)) ifTrue: [ 
		objectMemory 
			longAt: (self pcRelativeAddressAt: (self instructionAddressBefore: followingAddress - 12))
			put: literal
		 ].


]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> storeWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw: Stores the four lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  010   |  offset[4:0]  |   0100011  |
	"

	| signExtendedOffset |
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r010 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> subtractRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"sub: Substracts register x[rs2] from register x[rs1] and writes the result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0110011  |
	"
		
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> subtractWordRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"subw: Substracts register x[rs2] from register x[rs1], truncates the result to 32 bits 
	 and writes the sign-extended result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0111011  |
	"

	self flag: #CLEANUP.
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0111011
]

{ #category : 'private-bit-manipulation' }
CogOutOfLineLiteralsRiscV64Compiler >> trailingZerosOf: aNumber [
	"Return how many trailing zeros are in the 64bit bitString representation of aNumber.
	That is, how many zeros are in the least significant bits before there is a one.
	For example, the 64bit binary number 2r10101000110001111000 has 3 trailing zeros.
	
	Uses a bisect method looking at the number by halfs"
	
	| zeroBits shift mask currentNumber |
	"First two fast cases. If 1 or 0, return some quick constants"
	aNumber = 0
		ifTrue: [ ^ 64 "bits" ].

	(aNumber bitAnd: 1) = 1
		ifTrue: [ ^ 0 ].
 
	"Otherwise calculate trailing zeros by iterating the number with a mask and accumulating a value"
	zeroBits := 0.

	"This is a bisection method to iterate a 64-long bitstring in log2.
	It will first look at the least significant half of the number using a mask of half of its size.
	If they are all zeros, taking the other half of the number by shifting it.
	Of they are not all zeros, continue with this half.
	Then iterate with half the mask and shift sizes."
	shift := 64 "bits" >> 1.
	mask := 16rFFFFFFFFFFFFFFFF >> shift.
	currentNumber := aNumber.
	
	[ shift ~= 0 ] whileTrue: [ 
		(currentNumber bitAnd: mask) = 0 ifTrue: [ 
			"If this half is all zeros, let's take the other half of the number"
			currentNumber := currentNumber >> shift.
			"Also, mark that we found zeros of the size of the current shift"
			zeroBits := zeroBits bitOr: shift.
		].
		"Continue next iterations with masks half the size"
		shift := shift >> 1.
		mask := mask >> shift.
	].

	^ zeroBits
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> updateFlagsADDForSourceReg: srcReg resultReg: resReg andMoveResultTo: destReg startingAtIndex: index [

	self flag: #CLEANUP.
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: resReg isLessThanUnsignedValueIn: srcReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Move result to the destination register"
	self machineCodeAt: index + 8 put: (self moveRegister: resReg toRegister: destReg).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> updateFlagsCMPForSourceReg: srcReg resultReg: resReg startingAtIndex: index [

	self flag: #CLEANUP.
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: srcReg isLessThanUnsignedValueIn: resReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 8 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 12
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> updateFlagsLogicForResultReg: resReg startingAtIndex: index [

	self flag: #CLEANUP.
	"1. Overflow Flag: set to 0"	
	self machineCodeAt: index put: (self moveRegister: X0  toRegister: ConcreteOverflowReg).
	"2. Carry Flag: set to 0"
	self machineCodeAt: index + 4 put: (self moveRegister: X0  toRegister: ConcreteCarryReg).
	"3. Sign Flag: set it as the most significant bit of the result"
	self machineCodeAt: index + 8 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
]

{ #category : 'concretization' }
CogOutOfLineLiteralsRiscV64Compiler >> updateFlagsSUBForSourceReg: srcReg resultReg: resReg andMoveResultTo: destReg startingAtIndex: index [

	self flag: #CLEANUP. 
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: srcReg isLessThanUnsignedValueIn: resReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Move result to the destination register"
	self machineCodeAt: index + 8 put: (self moveRegister: resReg toRegister: destReg).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
	
]

{ #category : 'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> updateLabel: labelInstruction [
	opcode ~= Literal ifTrue:
		[super updateLabel: labelInstruction]
]

{ #category : 'testing' }
CogOutOfLineLiteralsRiscV64Compiler >> usesOutOfLineLiteral [
	"Answer if the receiver uses an out-of-line literal.  Needs only
	 to work for the opcodes created with gen:literal:operand: et al.
	
	 Note that it will provide the 'dependent' in concretization"
	
	opcode
		caseOf: {
		[CallFull]		   -> [^true].
		[JumpFull]		   -> [^true].
		"CqR operations try to constant in an immediate, otherwise fallback in load literal (like Cw)"
		[AddCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		[AddCheckOverflowCqR ] -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		[AndCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[AndCqRR]              -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[CmpCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 11) not]. "uses load immediate"
		[CmpC32R]              -> [^ true]. 
		[OrCqR]                -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[SubCqR]               -> [^ (self value: ((operands at: 0) negated) isContainedIn: 12) not]. 
	   [SubCheckOverflowCqR ] -> [^ (self value: ((operands at: 0) negated) isContainedIn: 12) not]. 
		[TstCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[XorCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[LoadEffectiveAddressMwrR] -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		"CwR operations use a word size value and need a full literal load"
		[AddCwR]		-> [^true].
		[AndCwR]		-> [^true].
		[CmpCwR]		-> [^true].
		[OrCwR]		-> [^true].
		[SubCwR]		-> [^true].
		[XorCwR]		-> [^true].
		"Data Movement - Moves"						
		[MoveCqR]		-> [^ (self value: (operands at: 0) isContainedIn: 11) not]. "11 because uses loadImmediate:inRegister:"
		[MoveC32R]  -> [ self shouldBeImplemented ].
		"Data Movement - Absolute addresses"
		[MoveCwR]		-> [^(self inCurrentCompilation: (operands at: 0)) not].
		[MoveAwR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].
		[MoveRAw]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) not].
		[MoveAbR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].
		[MoveRAb]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) not].
		"Data Movement - Stores"
		[MoveRMbr]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM8r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM16r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM32r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRMwr]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRsM32r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not]. 												
		[MoveRdM64r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not]. 
		"Data Movement - Loads"
		[MoveMbrR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM8rR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM16rR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM32rR] -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveMwrR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM32rRs]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM64rRd]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
								
		[PushCw]		-> [^ (self inCurrentCompilation: (operands at: 0)) not].
		[PushCq]		-> [^(self value: (operands at: 0) isContainedIn: 11) not]. "11 because uses loadImmediate:"
		[PrefetchAw] 	-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].

		"Patcheable instruction. Moves a literal. Uses out of line literal."
		[MovePatcheableC32R] -> [ ^ true ]
		}
		otherwise: [self error: 'We should not be here!!!'].
	^false "to keep C compiler quiet"

]

{ #category : 'helpers - size sign' }
CogOutOfLineLiteralsRiscV64Compiler >> value: value isContainedIn: size [ 

	<inline: true>
	| mask twosComplement |
	mask := (1 << size) - 1.
	twosComplement := mask - value abs + 1.
	(value >= 0)
		ifTrue: [ ^ (value bitAnd: mask) = value ]
		ifFalse: [ ^ (twosComplement >= 0 and: [twosComplement <= mask]) ]	
]

{ #category : 'machine code instruction' }
CogOutOfLineLiteralsRiscV64Compiler >> zeroConditionalBranch: condition withOffset: offset [ 

	"Return a bnez or beqz comparing with the zero flag register"
	self flag: #CLEANUP.
	^ self branchTo: offset ifCondition: condition betweenRegister: ConcreteZeroReg andRegister: X0
]

{ #category : 'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> zoneCallsAreRelative [
	"Answer if Call and JumpLong are relative and hence need to take the caller's
	 relocation delta into account during code compaction, rather than just the
	 callee's delta."
	^true
]
