Class {
	#name : #UnicornRISCVSimulator,
	#superclass : #UnicornSimulator,
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #registers }
UnicornRISCVSimulator >> arg0Register [

	^ UcRISCVRegisters x10
]

{ #category : #registers }
UnicornRISCVSimulator >> arg1Register [

	^ UcRISCVRegisters x11
]

{ #category : #registers }
UnicornRISCVSimulator >> baseRegister [

	^ UcRISCVRegisters x26
]

{ #category : #'c calling convention' }
UnicornRISCVSimulator >> cResultRegister [

	^ UcRISCVRegisters x12
]

{ #category : #'c calling convention' }
UnicornRISCVSimulator >> carg0Register [

	^ UcRISCVRegisters x12
]

{ #category : #'c calling convention' }
UnicornRISCVSimulator >> carg1Register [

	^ UcRISCVRegisters x13
]

{ #category : #'c calling convention' }
UnicornRISCVSimulator >> carg2Register [

	^ UcRISCVRegisters x14
]

{ #category : #'c calling convention' }
UnicornRISCVSimulator >> carg3Register [

	^ UcRISCVRegisters x15
]

{ #category : #registers }
UnicornRISCVSimulator >> classRegister [

	^ UcRISCVRegisters x23
]

{ #category : #initialization }
UnicornRISCVSimulator >> createUnicorn [

	^ Unicorn riscv64
]

{ #category : #disassembling }
UnicornRISCVSimulator >> disassembler [ 

	^ LLVMRV64Disassembler riscv64
]

{ #category : #'as yet unclassified' }
UnicornRISCVSimulator >> doublePrecisionFloatingPointRegister0 [

	^ UcRISCVRegisters f0
]

{ #category : #'as yet unclassified' }
UnicornRISCVSimulator >> doublePrecisionFloatingPointRegister1 [

	^ UcRISCVRegisters f1
]

{ #category : #'as yet unclassified' }
UnicornRISCVSimulator >> doublePrecisionFloatingPointRegister2 [

	^ UcRISCVRegisters f2
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f0 [

	^ self readRegister: UcRISCVRegisters f0
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f1 [

	^ self readRegister: UcRISCVRegisters f1
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f10 [

	^ self readRegister: UcRISCVRegisters f10
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f11 [

	^ self readRegister: UcRISCVRegisters f11
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f12 [

	^ self readRegister: UcRISCVRegisters f12
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f13 [

	^ self readRegister: UcRISCVRegisters f13
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f14 [

	^ self readRegister: UcRISCVRegisters f14
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f15 [

	^ self readRegister: UcRISCVRegisters f15
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f16 [

	^ self readRegister: UcRISCVRegisters f16
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f17 [

	^ self readRegister: UcRISCVRegisters f17
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f18 [

	^ self readRegister: UcRISCVRegisters f18
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f19 [

	^ self readRegister: UcRISCVRegisters f19
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f2 [

	^ self readRegister: UcRISCVRegisters f2
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f20 [

	^ self readRegister: UcRISCVRegisters f20
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f21 [

	^ self readRegister: UcRISCVRegisters f21
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f22 [

	^ self readRegister: UcRISCVRegisters f22
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f23 [

	^ self readRegister: UcRISCVRegisters f23
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f24 [

	^ self readRegister: UcRISCVRegisters f24
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f25 [

	^ self readRegister: UcRISCVRegisters f25
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f26 [

	^ self readRegister: UcRISCVRegisters f26
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f27 [

	^ self readRegister: UcRISCVRegisters f27
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f28 [

	^ self readRegister: UcRISCVRegisters f28
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f29 [

	^ self readRegister: UcRISCVRegisters f29
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f3 [

	^ self readRegister: UcRISCVRegisters f3
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f30 [

	^ self readRegister: UcRISCVRegisters f30
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f31 [

	^ self readRegister: UcRISCVRegisters f31
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f4 [

	^ self readRegister: UcRISCVRegisters f4
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f5 [

	^ self readRegister: UcRISCVRegisters f5
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f6 [

	^ self readRegister: UcRISCVRegisters f6
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f7 [

	^ self readRegister: UcRISCVRegisters f7
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f8 [

	^ self readRegister: UcRISCVRegisters f8
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> f9 [

	^ self readRegister: UcRISCVRegisters f9
]

{ #category : #registers }
UnicornRISCVSimulator >> framePointerRegister [
	
	"Frame Pointer"
	^ UcRISCVRegisters x8
]

{ #category : #testing }
UnicornRISCVSimulator >> hasLinkRegister [
	
	^ true
]

{ #category : #registers }
UnicornRISCVSimulator >> instructionPointerRegister [

	^ UcRISCVRegisters pc
]

{ #category : #disassembling }
UnicornRISCVSimulator >> linkRegister [ 

	^ UcRISCVRegisters x1
]

{ #category : #registers }
UnicornRISCVSimulator >> receiverRegister [
	
	^ UcRISCVRegisters x24
]

{ #category : #accessing }
UnicornRISCVSimulator >> registerList [

	^ #(lr pc sp fp 
		 x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 
		 x17 x18 x19 x20 x21 x22 x23 x24 x25 x26 x27 x28 x29 x30 x31)
]

{ #category : #registers }
UnicornRISCVSimulator >> sendNumberOfArgumentsRegister [

	^ UcRISCVRegisters x25
]

{ #category : #'as yet unclassified' }
UnicornRISCVSimulator >> simulateLeafCallOf: destinationAddress nextpc: returnAddress memory: anUndefinedObject [ 

	self linkRegisterValue: returnAddress.
	self instructionPointerRegisterValue: destinationAddress
]

{ #category : #registers }
UnicornRISCVSimulator >> smashRegisterAccessors [
	
	"Caller saved registers to smash"
	^#( x1: x5: x6: x7: x10: x11: x12: x13: x14: x15: x16: x17: x28: x29: x30: x31:)
]

{ #category : #registers }
UnicornRISCVSimulator >> stackPointerRegister [
	
	^ UcRISCVRegisters x2
]

{ #category : #registers }
UnicornRISCVSimulator >> temporaryRegister [

	^ self x22
]

{ #category : #accessing }
UnicornRISCVSimulator >> wordSize [
	
	^ 8
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x0 [

	^ self readRegister: UcRISCVRegisters x0
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x1 [

	^ self readRegister: UcRISCVRegisters x1
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x10 [

	^ self readRegister: UcRISCVRegisters x10
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x11 [

	^ self readRegister: UcRISCVRegisters x11
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x12 [

	^ self readRegister: UcRISCVRegisters x12
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x13 [

	^ self readRegister: UcRISCVRegisters x13
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x14 [

	^ self readRegister: UcRISCVRegisters x14
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x15 [

	^ self readRegister: UcRISCVRegisters x15
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x16 [

	^ self readRegister: UcRISCVRegisters x16
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x17 [

	^ self readRegister: UcRISCVRegisters x17
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x18 [

	^ self readRegister: UcRISCVRegisters x18
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x19 [

	^ self readRegister: UcRISCVRegisters x19
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x2 [

	^ self readRegister: UcRISCVRegisters x2
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x20 [

	^ self readRegister: UcRISCVRegisters x20
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x21 [

	^ self readRegister: UcRISCVRegisters x21
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x22 [

	^ self readRegister: UcRISCVRegisters x22
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x23 [

	^ self readRegister: UcRISCVRegisters x23
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x24 [

	^ self readRegister: UcRISCVRegisters x24
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x25 [

	^ self readRegister: UcRISCVRegisters x25
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x26 [

	^ self readRegister: UcRISCVRegisters x26
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x27 [

	^ self readRegister: UcRISCVRegisters x27
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x28 [

	^ self readRegister: UcRISCVRegisters x28
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x29 [

	^ self readRegister: UcRISCVRegisters x29
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x3 [

	^ self readRegister: UcRISCVRegisters x3
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x30 [

	^ self readRegister: UcRISCVRegisters x30
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x31 [

	^ self readRegister: UcRISCVRegisters x31
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x4 [

	^ self readRegister: UcRISCVRegisters x4
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x5 [

	^ self readRegister: UcRISCVRegisters x5
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x6 [

	^ self readRegister: UcRISCVRegisters x6
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x7 [

	^ self readRegister: UcRISCVRegisters x7
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x8 [

	^ self readRegister: UcRISCVRegisters x8
]

{ #category : #'machine registers' }
UnicornRISCVSimulator >> x9 [

	^ self readRegister: UcRISCVRegisters x9
]
