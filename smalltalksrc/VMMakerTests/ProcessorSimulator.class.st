Class {
	#name : #ProcessorSimulator,
	#superclass : #Object,
	#instVars : [
		'simulator',
		'registerAliases',
		'registerSmalltalkAliases',
		'memory'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #'instance creation' }
ProcessorSimulator class >> ARMv5 [

	^ UnicornARMv5Simulator new
]

{ #category : #'instance creation' }
ProcessorSimulator class >> ARMv8 [

	^ UnicornARMv8Simulator new
]

{ #category : #'instance creation' }
ProcessorSimulator class >> IA32 [

	^ UnicornI386Simulator new
]

{ #category : #'instance creation' }
ProcessorSimulator class >> X64 [

	^ UnicornX64Simulator new
]

{ #category : #'instance creation' }
ProcessorSimulator class >> aarch64 [

	^ UnicornARMv8Simulator new
]

{ #category : #'instance creation' }
ProcessorSimulator class >> riscv64 [

	"TODO: Add riscv32 and possibly two subclasses for the RISCV simulator"
	^ UnicornRISCVSimulator new
	"^ SpikeRISCVSimulator new"
]

{ #category : #'instance creation' }
ProcessorSimulator class >> simulatorFor: isa [

	^ (self subclasses detect: [ :each | each supportsISA: isa ]) perform: isa asSymbol
]

{ #category : #accessing }
ProcessorSimulator >> aliasForRegister: aRegisterName [

	^ registerAliases at: aRegisterName ifAbsent: [ '' ]
]

{ #category : #accessing }
ProcessorSimulator >> aliasSmalltalkForRegister: aRegisterName [

	^ registerSmalltalkAliases at: aRegisterName ifAbsent: [ '' ]
]

{ #category : #registers }
ProcessorSimulator >> arg0Register [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> arg0RegisterValue [

	^ self readRegister: self arg0Register
]

{ #category : #registers }
ProcessorSimulator >> arg0RegisterValue: aValue [

	^ self writeRegister: self arg0Register value: aValue
]

{ #category : #registers }
ProcessorSimulator >> arg1Register [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> arg1RegisterValue [

	^ self readRegister: self arg1Register
]

{ #category : #registers }
ProcessorSimulator >> baseRegister [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> baseRegisterValue [

	^ self readRegister: self baseRegister
]

{ #category : #registers }
ProcessorSimulator >> baseRegisterValue: aValue [

	^ self writeRegister: self baseRegister value: aValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> cResultRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> cResultRegisterValue [

	^ self readRegister: self cResultRegister
]

{ #category : #'c calling convention' }
ProcessorSimulator >> cResultRegisterValue: aValue [

	self writeRegister: self cResultRegister value: aValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg0 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg0RegisterValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg0Register [

	^ self subclassResponsibility
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg0RegisterValue [

	^ self readRegister: self carg0Register
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg1 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg1RegisterValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg1Register [

	^ self subclassResponsibility
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg1RegisterValue [

	^ self readRegister: self carg1Register
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg2 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg2RegisterValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg2Register [

	^ self subclassResponsibility
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg2RegisterValue [

	^ self readRegister: self carg2Register
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg3 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg3RegisterValue
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg3Register [

	^ self subclassResponsibility
]

{ #category : #'c calling convention' }
ProcessorSimulator >> carg3RegisterValue [

	^ self readRegister: self carg3Register
]

{ #category : #registers }
ProcessorSimulator >> classRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> classRegisterValue [

	^ self readRegister: self classRegister
]

{ #category : #registers }
ProcessorSimulator >> classRegisterValue: aValue [

	^ self writeRegister: self classRegister value: aValue
]

{ #category : #accessing }
ProcessorSimulator >> cogit [

	^ memory interpreter cogit
]

{ #category : #disassembling }
ProcessorSimulator >> disassembleCurrentInstruction [

	^ (self disassembleFrom: self instructionPointerRegisterValue opcodes: 1) first
]

{ #category : #disassembling }
ProcessorSimulator >> disassembleFrom: anIndex opcodes: numberOfInstructions [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: numberOfInstructions
		instructionsIn: (memory memoryManager copyFrom: anIndex to: anIndex + (numberOfInstructions * 50) "rough estimate")
		startAddress: anIndex
		pc: self instructionPointerRegisterValue
]

{ #category : #disassembling }
ProcessorSimulator >> disassembleFrom: start to: stop [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: 1000
		instructionsIn: (memory memory copyFrom: start to: stop)
		startAddress: start
		pc: self instructionPointerRegisterValue
]

{ #category : #disassembling }
ProcessorSimulator >> disassembler [
	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0 [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister0 value: aValue
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister0
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1 [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister1 value: aValue
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister1
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2 [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister2 value: aValue
]

{ #category : #registers }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister2
]

{ #category : #disassembling }
ProcessorSimulator >> extractDestinationRegisterFromAssembly: aLLVMInstruction [

	^  (aLLVMInstruction assemblyCodeString substrings: String tab, ',') second trimBoth
]

{ #category : #memory }
ProcessorSimulator >> finishMappingMemory [

	self subclassResponsibility
]

{ #category : #shortcut }
ProcessorSimulator >> fp [

	^ self framePointerRegisterValue
]

{ #category : #shortcut }
ProcessorSimulator >> fp: aValue [

	^ self framePointerRegisterValue: aValue
]

{ #category : #registers }
ProcessorSimulator >> framePointerRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> framePointerRegisterValue [

	^ self readRegister: self framePointerRegister
]

{ #category : #registers }
ProcessorSimulator >> framePointerRegisterValue: aValue [

	self writeRegister: self framePointerRegister value: aValue
]

{ #category : #accessing }
ProcessorSimulator >> getLastAddress: abstractInstructions [ 
	
	| last |
	last := (abstractInstructions reject: [ :e | e isLiteral ]) last.
	^ last address + last machineCodeSize 
]

{ #category : #testing }
ProcessorSimulator >> hasLinkRegister [

	^ false
]

{ #category : #initialization }
ProcessorSimulator >> initialize [ 

	super initialize.
	registerAliases := Dictionary new.
	registerSmalltalkAliases := Dictionary new.
	self initializeRegisterAliases.
	self initializeRegisterSmalltalkAliases.
]

{ #category : #initialization }
ProcessorSimulator >> initializeRegisterAliases [

	"Hook for subclasses"
]

{ #category : #initialization }
ProcessorSimulator >> initializeRegisterSmalltalkAliases [

	"Hook for subclasses"
]

{ #category : #registers }
ProcessorSimulator >> instructionPointerRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> instructionPointerRegisterValue [

	^ self readRegister: self instructionPointerRegister
]

{ #category : #registers }
ProcessorSimulator >> instructionPointerRegisterValue: aValue [

	^ self writeRegister: self instructionPointerRegister value: aValue
]

{ #category : #registers }
ProcessorSimulator >> integerRegisterState [

	^ {  }
]

{ #category : #accessing }
ProcessorSimulator >> lastExecutedInstructionAddress [

	^ simulator lastExecutedInstructionAddress
]

{ #category : #accessing }
ProcessorSimulator >> lastExecutedInstructionSize [

	^ simulator lastExecutedInstructionSize
]

{ #category : #accessing }
ProcessorSimulator >> lastInstructionCount [

	^ simulator lastInstructionCount
]

{ #category : #registers }
ProcessorSimulator >> linkRegister [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> linkRegisterValue [

	^ self readRegister: self linkRegister
]

{ #category : #registers }
ProcessorSimulator >> linkRegisterValue: aValue [

	^ self writeRegister: self linkRegister value: aValue
]

{ #category : #shortcut }
ProcessorSimulator >> lr [

	^ self linkRegisterValue
]

{ #category : #shortcut }
ProcessorSimulator >> lr: aValue [

	^ self linkRegisterValue: aValue
]

{ #category : #memory }
ProcessorSimulator >> mapMemory: aMemory at: anAddress [

	simulator
		mapHostMemory: aMemory
		atAddress: anAddress
		withPermissions: UnicornConstants permissionAll.
]

{ #category : #memory }
ProcessorSimulator >> mapMemoryInManager: aSlangMemoryManager [

	aSlangMemoryManager regionsDo: [ :startAddress :region |
		self mapMemory: region at: startAddress
	].
	self finishMappingMemory.
]

{ #category : #accessing }
ProcessorSimulator >> memory [
	^ memory
]

{ #category : #accessing }
ProcessorSimulator >> memory: aSpur64BitMMLECoSimulator [

	memory := aSpur64BitMMLECoSimulator
]

{ #category : #memory }
ProcessorSimulator >> memoryAt: address readNext: byteSize [

	^ simulator memoryAt: address readNext: byteSize
]

{ #category : #memory }
ProcessorSimulator >> memoryAt: address write: bytes size: size [

	simulator memoryAt: address write: bytes size: size
]

{ #category : #shortcut }
ProcessorSimulator >> pc [

	^ self instructionPointerRegisterValue
]

{ #category : #shortcut }
ProcessorSimulator >> pc: aValue [

	^ self instructionPointerRegisterValue: aValue
]

{ #category : #'helpers - stack' }
ProcessorSimulator >> peek [

	| stackAddressIntegerValue peekedByteArray |

	"Getting address from stack register"
	stackAddressIntegerValue := self stackPointerRegisterValue.

	"Putting the value in the stack memory"
	peekedByteArray := self memoryAt: stackAddressIntegerValue readNext: self wordSize.

	^ peekedByteArray
]

{ #category : #'helpers - stack' }
ProcessorSimulator >> peekAddress [

	^ self peek integerAt: 1 size: self wordSize signed: false
]

{ #category : #'helpers - stack' }
ProcessorSimulator >> popBytes [

	| stackAddressIntegerValue aByteArray |

	"Getting address from stack register"
	stackAddressIntegerValue := self stackPointerRegisterValue.
	"Putting the value from the stack memory"
	aByteArray := self memoryAt: stackAddressIntegerValue readNext: self wordSize.

	"Updating SP"
	stackAddressIntegerValue := stackAddressIntegerValue + self wordSize.
	self stackPointerRegisterValue: stackAddressIntegerValue.

	^ aByteArray
]

{ #category : #'helpers - stack' }
ProcessorSimulator >> popWord [

	| aByteArray |
	aByteArray := self popBytes.
	^ aByteArray integerAt: 1 size: self wordSize signed: false.
]

{ #category : #'helpers - stack' }
ProcessorSimulator >> pushBytes: aByteArray [

	| stackAddressIntegerValue |
	self assert: aByteArray size = self wordSize.

	"Getting address from stack register"
	stackAddressIntegerValue := self stackPointerRegisterValue.

	"Updating SP"
	stackAddressIntegerValue := stackAddressIntegerValue - self wordSize.
	self stackPointerRegisterValue: stackAddressIntegerValue.

	"Putting the value in the stack memory"
	self
		memoryAt: stackAddressIntegerValue
		write: aByteArray
		size: self wordSize

]

{ #category : #'helpers - stack' }
ProcessorSimulator >> pushWord: anInteger [

	| aByteArray |
	aByteArray := ByteArray new: self wordSize.
	aByteArray integerAt: 1 put: anInteger size: self wordSize signed: false.
	self pushBytes: aByteArray
]

{ #category : #registers }
ProcessorSimulator >> readFloat64Register: aRegisterID [

	| registerValue |
	registerValue := ByteArray new: 8.
	simulator register: aRegisterID value readInto: registerValue.

	^ registerValue doubleAt: 1
]

{ #category : #registers }
ProcessorSimulator >> readRegister: aRegisterID [

	| registerValue |
	registerValue := ByteArray new: self wordSize.
	simulator register: aRegisterID value readInto: registerValue.
	^ registerValue integerAt: 1 size: self wordSize signed: false
]

{ #category : #registers }
ProcessorSimulator >> receiverRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> receiverRegisterValue [

	^ self readRegister: self receiverRegister
]

{ #category : #registers }
ProcessorSimulator >> receiverRegisterValue: anInteger [

	self writeRegister: self receiverRegister value: anInteger
]

{ #category : #registers }
ProcessorSimulator >> register: anIndex readInto: aByteArray [

	simulator register: anIndex readInto: aByteArray
]

{ #category : #registers }
ProcessorSimulator >> register: aRegisterIndex write: aByteArray [

	simulator register: aRegisterIndex readInto: aByteArray
]

{ #category : #registers }
ProcessorSimulator >> registerAliases [

	^ registerAliases
]

{ #category : #registers }
ProcessorSimulator >> registerDescriptors [

	^ self registerList collect: [ :reg |
		RegisterDescriptor new
			simulator: self;
			alias: (self aliasForRegister: reg);
			smalltalkAlias: (self aliasSmalltalkForRegister: reg);
			name: reg;
			yourself ]
]

{ #category : #registers }
ProcessorSimulator >> registerList [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> sendNumberOfArgumentsRegister [

	^ SpikeRISCVRegisters x25
]

{ #category : #registers }
ProcessorSimulator >> sendNumberOfArgumentsRegister: anInteger [
	self shouldBeImplemented.
]

{ #category : #registers }
ProcessorSimulator >> sendNumberOfArgumentsRegisterValue [

	^ self readRegister: self sendNumberOfArgumentsRegister
]

{ #category : #registers }
ProcessorSimulator >> sendNumberOfArgumentsRegisterValue: aValue [

	^ self writeRegister: self sendNumberOfArgumentsRegister value: aValue
]

{ #category : #actions }
ProcessorSimulator >> simulateLeafCallOf: address nextpc: nextpc memory: aMemory [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> smalltalkStackPointerRegister [
	"By default they are the same"
	^ self stackPointerRegister
]

{ #category : #registers }
ProcessorSimulator >> smalltalkStackPointerRegisterValue [

	^ self readRegister: self smalltalkStackPointerRegister
]

{ #category : #registers }
ProcessorSimulator >> smalltalkStackPointerRegisterValue: aValue [

	self writeRegister: self smalltalkStackPointerRegister value: aValue
]

{ #category : #registers }
ProcessorSimulator >> smashRegisterAccessors [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> smashRegistersWithValuesFrom: base by: step [

	self smashRegisterAccessors withIndexDo: [:accessor :index|
		self perform: accessor with: index - 1 * step + base]
]

{ #category : #shortcut }
ProcessorSimulator >> sp [

	^ self stackPointerRegisterValue
]

{ #category : #shortcut }
ProcessorSimulator >> sp: aValue [

	^ self stackPointerRegisterValue: aValue
]

{ #category : #registers }
ProcessorSimulator >> stackPointerRegister [

	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> stackPointerRegisterValue [

	^ self readRegister: self stackPointerRegister
]

{ #category : #registers }
ProcessorSimulator >> stackPointerRegisterValue: aValue [

	self writeRegister: self stackPointerRegister value: aValue
]

{ #category : #'stack-access' }
ProcessorSimulator >> stackValueAt: anInteger [

	"Get a value from the stack at a 0-base position"
	| aByteArray |
	aByteArray := self stackValueBytesAt: anInteger.
	^ aByteArray integerAt: 1 size: self wordSize signed: false
]

{ #category : #'stack-access' }
ProcessorSimulator >> stackValueBytesAt: position [

	"Get the bytes from the stack at a 0-base position"
	| stackAddressIntegerValue aByteArray |

	"Getting address from stack register"
	stackAddressIntegerValue := self stackPointerRegisterValue.

	"Putting the value from the stack memory.
	Remember, stack grows down, so we add the offset"
	aByteArray := self
		memoryAt: stackAddressIntegerValue + (position * self wordSize)
		readNext: self wordSize.

	^ aByteArray
]

{ #category : #accessing }
ProcessorSimulator >> stackValues [

	| initialValue |
	initialValue := self smalltalkStackPointerRegisterValue.

	^ (1 to: 30) collect: [ :anIndex |
		VMMachineCodeDebuggerStackItem address: initialValue + (memory wordSize * (anIndex - 1)) on: self.
	]
]

{ #category : #actions }
ProcessorSimulator >> startAt: begin until: until timeout: timeout count: count [

	self subclassResponsibility

]

{ #category : #actions }
ProcessorSimulator >> step [

	self
		startAt: self instructionPointerRegisterValue
		until: 0
		timeout: 0
		count: 1
]

{ #category : #registers }
ProcessorSimulator >> temporaryRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> temporaryRegisterValue [

	^ self readRegister: self temporaryRegister
]

{ #category : #registers }
ProcessorSimulator >> temporaryRegisterValue: anInteger [

	^ self writeRegister: self temporaryRegister value: anInteger
]

{ #category : #accessing }
ProcessorSimulator >> wordAt: anInteger [

	^ memory longAt: anInteger
]

{ #category : #accessing }
ProcessorSimulator >> wordSize [
	self subclassResponsibility
]

{ #category : #registers }
ProcessorSimulator >> writeFloat64Register: aRegister value: aDouble [

	| value |
	value := ByteArray new: 8.
	value integerAt: 1 put: aDouble size: 8 signed: false.
	simulator register: aRegister value write: value.

]

{ #category : #registers }
ProcessorSimulator >> writeRegister: aRegister value: anInteger [

	| value |
	value := ByteArray new: self wordSize.
	value integerAt: 1 put: anInteger size: self wordSize signed: false.
	simulator register: aRegister value write: value.

]
