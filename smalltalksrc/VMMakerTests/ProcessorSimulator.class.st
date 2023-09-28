Class {
	#name : 'ProcessorSimulator',
	#superclass : 'Object',
	#instVars : [
		'simulator',
		'registerAliases',
		'registerSmalltalkAliases',
		'memory'
	],
	#category : 'VMMakerTests-Unicorn',
	#package : 'VMMakerTests',
	#tag : 'Unicorn'
}

{ #category : 'instance creation' }
ProcessorSimulator class >> ARMv5 [

	^ UnicornARMv5Simulator new
]

{ #category : 'instance creation' }
ProcessorSimulator class >> ARMv8 [

	^ UnicornARMv8Simulator new
]

{ #category : 'instance creation' }
ProcessorSimulator class >> IA32 [

	^ UnicornI386Simulator new
]

{ #category : 'instance creation' }
ProcessorSimulator class >> X64 [

	^ UnicornX64Simulator new
]

{ #category : 'instance creation' }
ProcessorSimulator class >> aarch64 [

	^ UnicornARMv8Simulator new
]

{ #category : 'instance creation' }
ProcessorSimulator class >> riscv64 [

	"TODO: Add riscv32 and possibly two subclasses for the RISCV simulator"
	^ UnicornRISCVSimulator new
	"^ SpikeRISCVSimulator new"
]

{ #category : 'instance creation' }
ProcessorSimulator class >> simulatorFor: isa [

	^ (self subclasses detect: [ :each | each supportsISA: isa ]) perform: isa asSymbol
]

{ #category : 'accessing' }
ProcessorSimulator >> aliasForRegister: aRegisterName [

	^ registerAliases at: aRegisterName ifAbsent: [ '' ]
]

{ #category : 'accessing' }
ProcessorSimulator >> aliasSmalltalkForRegister: aRegisterName [

	^ registerSmalltalkAliases at: aRegisterName ifAbsent: [ '' ]
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg0Register [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg0RegisterValue [

	^ self readRegister: self arg0Register
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg0RegisterValue: aValue [

	^ self writeRegister: self arg0Register value: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg1Register [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg1RegisterValue [

	^ self readRegister: self arg1Register
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> arg1RegisterValue: aValue [

	^ self writeRegister: self arg1Register value: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> baseRegister [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> baseRegisterValue [

	^ self readRegister: self baseRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> baseRegisterValue: aValue [

	^ self writeRegister: self baseRegister value: aValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> cResultRegister [

	^ self subclassResponsibility
]

{ #category : 'c calling convention' }
ProcessorSimulator >> cResultRegisterValue [

	^ self readRegister: self cResultRegister
]

{ #category : 'c calling convention' }
ProcessorSimulator >> cResultRegisterValue: aValue [

	self writeRegister: self cResultRegister value: aValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg0 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg0RegisterValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg0Register [

	^ self subclassResponsibility
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg0RegisterValue [

	^ self readRegister: self carg0Register
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg1 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg1RegisterValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg1Register [

	^ self subclassResponsibility
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg1RegisterValue [

	^ self readRegister: self carg1Register
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg2 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg2RegisterValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg2Register [

	^ self subclassResponsibility
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg2RegisterValue [

	^ self readRegister: self carg2Register
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg3 [

	"By default fetch values from registers, override in platforms that don't (e.g. IA32)"
	^ self carg3RegisterValue
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg3Register [

	^ self subclassResponsibility
]

{ #category : 'c calling convention' }
ProcessorSimulator >> carg3RegisterValue [

	^ self readRegister: self carg3Register
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> classRegister [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> classRegisterValue [

	^ self readRegister: self classRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> classRegisterValue: aValue [

	^ self writeRegister: self classRegister value: aValue
]

{ #category : 'accessing' }
ProcessorSimulator >> cogit [

	^ memory interpreter cogit
]

{ #category : 'disassembling' }
ProcessorSimulator >> disassembleCurrentInstruction [

	^ (self disassembleFrom: self instructionPointerRegisterValue opcodes: 1) first
]

{ #category : 'disassembling' }
ProcessorSimulator >> disassembleFrom: anIndex opcodes: numberOfInstructions [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: numberOfInstructions
		instructionsIn: (memory memoryManager copyFrom: anIndex to: anIndex + (numberOfInstructions * 50) "rough estimate")
		startAddress: anIndex
		pc: self instructionPointerRegisterValue
]

{ #category : 'disassembling' }
ProcessorSimulator >> disassembleFrom: start to: stop [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: 1000
		instructionsIn: (memory memory copyFrom: start to: stop)
		startAddress: start
		pc: self instructionPointerRegisterValue
]

{ #category : 'disassembling' }
ProcessorSimulator >> disassembler [
	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0 [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister0
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister0Value: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister0 value: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1 [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister1
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister1Value: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister1 value: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2 [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2Value [

	^ self readFloat64Register: self doublePrecisionFloatingPointRegister2
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> doublePrecisionFloatingPointRegister2Value: aValue [

	^ self writeFloat64Register: self doublePrecisionFloatingPointRegister2 value: aValue
]

{ #category : 'disassembling' }
ProcessorSimulator >> extractDestinationRegisterFromAssembly: aLLVMInstruction [

	^  self subclassResponsibility
]

{ #category : 'memory' }
ProcessorSimulator >> finishMappingMemory [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> flushICacheFrom: startAddress to: endAddress [

	simulator removeInstructionCacheFrom: startAddress to: endAddress
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> fp [

	^ self framePointerRegisterValue
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> fp: aValue [

	^ self framePointerRegisterValue: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> framePointerRegister [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> framePointerRegisterValue [

	^ self readRegister: self framePointerRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> framePointerRegisterValue: aValue [

	self writeRegister: self framePointerRegister value: aValue
]

{ #category : 'accessing' }
ProcessorSimulator >> getLastAddress: abstractInstructions [ 
	
	| last |
	last := (abstractInstructions reject: [ :e | e isLiteral ]) last.
	^ last address + last machineCodeSize 
]

{ #category : 'testing' }
ProcessorSimulator >> hasLinkRegister [

	^ false
]

{ #category : 'initialization' }
ProcessorSimulator >> initialize [ 

	super initialize.
	registerAliases := Dictionary new.
	registerSmalltalkAliases := Dictionary new.
	self initializeRegisterAliases.
	self initializeRegisterSmalltalkAliases.
]

{ #category : 'initialization' }
ProcessorSimulator >> initializeRegisterAliases [

	"Hook for subclasses"
]

{ #category : 'initialization' }
ProcessorSimulator >> initializeRegisterSmalltalkAliases [

	"Hook for subclasses"
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> instructionPointerRegister [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> instructionPointerRegisterValue [

	^ self readRegister: self instructionPointerRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> instructionPointerRegisterValue: aValue [

	^ self writeRegister: self instructionPointerRegister value: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> integerRegisterState [

	^ {  }
]

{ #category : 'accessing' }
ProcessorSimulator >> lastExecutedInstructionAddress [

	^ simulator lastExecutedInstructionAddress
]

{ #category : 'accessing' }
ProcessorSimulator >> lastExecutedInstructionSize [

	^ simulator lastExecutedInstructionSize
]

{ #category : 'accessing' }
ProcessorSimulator >> lastInstructionCount [

	^ simulator lastInstructionCount
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> linkRegister [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> linkRegisterValue [

	^ self readRegister: self linkRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> linkRegisterValue: aValue [

	^ self writeRegister: self linkRegister value: aValue
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> lr [

	^ self linkRegisterValue
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> lr: aValue [

	^ self linkRegisterValue: aValue
]

{ #category : 'memory' }
ProcessorSimulator >> mapMemory: aMemory at: anAddress [

	simulator
		mapHostMemory: aMemory
		atAddress: anAddress
		withPermissions: UnicornConstants permissionAll.
]

{ #category : 'memory' }
ProcessorSimulator >> mapMemoryInManager: aSlangMemoryManager [

	aSlangMemoryManager regionsDo: [ :startAddress :region |
		self mapMemory: region at: startAddress
	].
	aSlangMemoryManager machineSimulator: self.
	self finishMappingMemory.
]

{ #category : 'accessing' }
ProcessorSimulator >> memory [
	^ memory
]

{ #category : 'accessing' }
ProcessorSimulator >> memory: aSpur64BitMMLECoSimulator [

	memory := aSpur64BitMMLECoSimulator
]

{ #category : 'memory' }
ProcessorSimulator >> memoryAt: address readNext: byteSize [

	^ simulator memoryAt: address readNext: byteSize
]

{ #category : 'memory' }
ProcessorSimulator >> memoryAt: address write: bytes size: size [

	simulator memoryAt: address write: bytes size: size
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> pc [

	^ self instructionPointerRegisterValue
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> pc: aValue [

	^ self instructionPointerRegisterValue: aValue
]

{ #category : 'accessing-stack' }
ProcessorSimulator >> peek [

	| stackAddressIntegerValue peekedByteArray |

	"Getting address from stack register"
	stackAddressIntegerValue := self stackPointerRegisterValue.

	"Putting the value in the stack memory"
	peekedByteArray := self memoryAt: stackAddressIntegerValue readNext: self wordSize.

	^ peekedByteArray
]

{ #category : 'accessing-stack' }
ProcessorSimulator >> peekAddress [

	^ self peek integerAt: 1 size: self wordSize signed: false
]

{ #category : 'accessing-stack' }
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

{ #category : 'accessing-stack' }
ProcessorSimulator >> popWord [

	| aByteArray |
	aByteArray := self popBytes.
	^ aByteArray integerAt: 1 size: self wordSize signed: false.
]

{ #category : 'accessing-stack' }
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

{ #category : 'accessing-stack' }
ProcessorSimulator >> pushWord: anInteger [

	| aByteArray |
	aByteArray := ByteArray new: self wordSize.
	aByteArray integerAt: 1 put: anInteger size: self wordSize signed: false.
	self pushBytes: aByteArray
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> readFloat64Register: aRegisterID [

	| registerValue |
	registerValue := ByteArray new: 8.
	simulator register: aRegisterID value readInto: registerValue.

	^ registerValue doubleAt: 1
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> readRawRegister: aRegisterID size: aSize [

	| registerValue |
	registerValue := ByteArray new: aSize.
	simulator register: aRegisterID value readInto: registerValue.
	^ registerValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> readRegister: aRegisterID [

	| registerValue size |
	size := self wordSize.
	registerValue := self readRawRegister: aRegisterID size: size.
	^ registerValue integerAt: 1 size: size signed: false
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> receiverRegister [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> receiverRegisterValue [

	^ self readRegister: self receiverRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> receiverRegisterValue: anInteger [

	self writeRegister: self receiverRegister value: anInteger
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> register: anIndex readInto: aByteArray [

	simulator register: anIndex readInto: aByteArray
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> registerAliases [

	^ registerAliases
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> registerDescriptors [

	^ self registerList collect: [ :reg |
		RegisterDescriptor new
			simulator: self;
			alias: (self aliasForRegister: reg);
			smalltalkAlias: (self aliasSmalltalkForRegister: reg);
			name: reg;
			yourself ]
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> registerList [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> sendNumberOfArgumentsRegister [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> sendNumberOfArgumentsRegisterValue [

	^ self readRegister: self sendNumberOfArgumentsRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> sendNumberOfArgumentsRegisterValue: aValue [

	^ self writeRegister: self sendNumberOfArgumentsRegister value: aValue
]

{ #category : 'simulation-support' }
ProcessorSimulator >> simulateLeafCallOf: address nextpc: nextpc memory: aMemory [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> smalltalkStackPointerRegister [
	"By default they are the same"
	^ self stackPointerRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> smalltalkStackPointerRegisterValue [

	^ self readRegister: self smalltalkStackPointerRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> smalltalkStackPointerRegisterValue: aValue [

	self writeRegister: self smalltalkStackPointerRegister value: aValue
]

{ #category : 'simulation-support' }
ProcessorSimulator >> smashRegisterAccessors [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> smashRegistersWithValuesFrom: base by: step [

	self smashRegisterAccessors withIndexDo: [:accessor :index|
		self perform: accessor with: index - 1 * step + base]
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> sp [

	^ self stackPointerRegisterValue
]

{ #category : 'accessing-registers-shortcuts' }
ProcessorSimulator >> sp: aValue [

	^ self stackPointerRegisterValue: aValue
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> stackPointerRegister [

	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> stackPointerRegisterValue [

	^ self readRegister: self stackPointerRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> stackPointerRegisterValue: aValue [

	self writeRegister: self stackPointerRegister value: aValue
]

{ #category : 'accessing-stack' }
ProcessorSimulator >> stackValueAt: anInteger [

	"Get a value from the stack at a 0-base position"
	| aByteArray |
	aByteArray := self stackValueBytesAt: anInteger.
	^ aByteArray integerAt: 1 size: self wordSize signed: false
]

{ #category : 'accessing-stack' }
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

{ #category : 'accessing' }
ProcessorSimulator >> stackValues [

	| initialValue |
	initialValue := self smalltalkStackPointerRegisterValue.

	^ (1 to: 30) collect: [ :anIndex |
		VMMachineCodeDebuggerStackItem address: initialValue + (memory wordSize * (anIndex - 1)) on: self.
	]
]

{ #category : 'simulation-support' }
ProcessorSimulator >> startAt: begin until: until timeout: timeout count: count [

	self subclassResponsibility

]

{ #category : 'simulation-support' }
ProcessorSimulator >> step [

	self
		startAt: self instructionPointerRegisterValue
		until: 0
		timeout: 0
		count: 1
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> temporaryRegister [

	^ self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> temporaryRegisterValue [

	^ self readRegister: self temporaryRegister
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> temporaryRegisterValue: anInteger [

	^ self writeRegister: self temporaryRegister value: anInteger
]

{ #category : 'accessing' }
ProcessorSimulator >> wordAt: anInteger [

	^ memory longAt: anInteger
]

{ #category : 'accessing' }
ProcessorSimulator >> wordSize [
	self subclassResponsibility
]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> writeFloat64Register: aRegister value: aDouble [

	| value |
	value := ByteArray new: 8.
	value integerAt: 1 put: aDouble size: 8 signed: false.
	simulator register: aRegister value write: value.

]

{ #category : 'accessing-registers-abstract' }
ProcessorSimulator >> writeRegister: aRegister value: anInteger [

	| value |
	value := ByteArray new: self wordSize.
	value integerAt: 1 put: anInteger size: self wordSize signed: false.
	simulator register: aRegister value write: value.

]
