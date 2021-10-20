Class {
	#name : #UnicornSimulator,
	#superclass : #Object,
	#instVars : [
		'unicorn',
		'stopReason',
		'memory',
		'registerAliases',
		'invalidAccessHandler'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #'instance creation' }
UnicornSimulator class >> ARMv5 [

	^ UnicornARMv5Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> ARMv8 [

	^ UnicornARMv8Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> IA32 [

	^ UnicornI386Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> X64 [

	^ UnicornX64Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> aarch64 [

	^ UnicornARMv8Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> riscv64 [

	"TODO: Add riscv32 and possibly two subclasses for the RISCV simulator"
	^ UnicornRISCVSimulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> supportsISA: isa [

	^ #( #ARMv5 #ARMv8 #IA32 #X64 #aarch64 #riscv64 ) includes: isa
]

{ #category : #initialization }
UnicornSimulator >> createUnicorn [

	self subclassResponsibility
]

{ #category : #disassembling }
UnicornSimulator >> disassembleCurrentInstruction [

	^ (self disassembleFrom: self instructionPointerValue opcodes: 1) first
]

{ #category : #disassembling }
UnicornSimulator >> disassembleFrom: anIndex opcodes: numberOfInstructions [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: numberOfInstructions
		instructionsIn: (memory memoryManager copyFrom: anIndex to: anIndex + (numberOfInstructions * 50) "rough estimate")
		startAddress: anIndex
		pc: self instructionPointerValue
]

{ #category : #disassembling }
UnicornSimulator >> disassembleFrom: start to: stop [

	^ self disassembler
		printImmediatesInHexa;
		disassembleNext: 1000
		instructionsIn: (memory memory copyFrom: start to: stop)
		startAddress: start
		pc: self instructionPointerValue
]

{ #category : #disassembling }
UnicornSimulator >> disassembler [
	self subclassResponsibility
]

{ #category : #executing }
UnicornSimulator >> doStartAt: startAddress until: until timeout: timeout count: count [

	| result error startTime currentTime remainingTimeout remainingCount |

	self instructionPointerRegisterValue: startAddress.
	startTime := Time millisecondClockValue.
	remainingTimeout := timeout.
	remainingCount := count.

	[ true ]
		whileTrue: [
			[result :=  simulator
				startAt: self instructionPointerRegisterValue
				until: until
				timeout: remainingTimeout
				count: remainingCount.

				stopReason ifNotNil: [
						error := stopReason.
						stopReason := nil.
						error signal ].

			"If execution did not stop because of a stop reason, verify the error code"
			unicorn verifyErrorCode: result]
				on: UnicornInvalidMemoryAccess do: [ :invalidAccess |

					self instructionPointerRegisterValue = until ifTrue: [ ^ 0 ].

					(self handleInvalidAccess: invalidAccess)
						ifFalse: [ ^ result ]].

			stopReason ifNotNil: [ ^ result ].

			count ~= 0 ifTrue: [ | lastCount |
				lastCount := unicorn lastInstructionCount.
				remainingCount := remainingCount - lastCount.
				remainingCount <= 0 ifTrue: [ ^ result ]].

			timeout ~= 0 ifTrue: [
				currentTime := Time millisecondClockValue.
				remainingTimeout := remainingTimeout - (currentTime - startTime).

				remainingTimeout <= 0
					ifTrue: [
						UnicornTimeout new
								target: until;
								signal ]].

			self instructionPointerRegisterValue = until
				ifTrue: [ ^ result ]]
]

{ #category : #'stack-access' }
UnicornSimulator >> finishMappingMemory [

	"Do nothing in the case of Unicorn, is useful if the simulator used has to map memory by hand"
]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> handleInvalidAccess: invalidAccess [

	| previousInstructionPointer hasToContinue |
	previousInstructionPointer := self instructionPointerRegisterValue.

	"If the called handler want to resume execution but it has not set a next instruction pointer to execute I will calculate it"

	(hasToContinue := invalidAccessHandler value: invalidAccess)
		ifTrue: [ previousInstructionPointer = self instructionPointerRegisterValue
			ifTrue: [
					self instructionPointerRegisterValue:
						self lastExecutedInstructionAddress + self lastExecutedInstructionSize
				] ].

	^ hasToContinue
]

{ #category : #testing }
UnicornSimulator >> hasLinkRegister [
	^ false
]

{ #category : #initialization }
UnicornSimulator >> initialize [

	super initialize.
	unicorn := self createUnicorn.
	self initializeUnicorn.

	registerAliases := Dictionary new.
	self initializeRegisterAliases.

	invalidAccessHandler := [ :invalidAccess |
		self cogit handleSimulationTrap: (UnicornSimulationTrap simulator: self error: invalidAccess).
		true]
]

{ #category : #initialization }
UnicornSimulator >> initializeRegisterAliases [

	"Hook for subclasses"
]

{ #category : #initialization }
UnicornSimulator >> initializeUnicorn [

	unicorn
		registerInvalidMemoryAccessHook: UcHookType invalidMemoryAccess value
		doing: [ :type :address :size :value |
			unicorn stop.
			stopReason := UnicornInvalidMemoryAccess new
				type: type;
				address: address;
				size: size;
				value: value;
				yourself.
			false ]
]

{ #category : #registers }
UnicornSimulator >> instructionPointerRegister [

	^ self subclassResponsibility
]

{ #category : #registers }
UnicornSimulator >> instructionPointerValue [

	^ self readRegister: self instructionPointerRegister
]

{ #category : #registers }
UnicornSimulator >> instructionPointerValue: aValue [

	^ self writeRegister: self instructionPointerRegister value: aValue
]

{ #category : #'as yet unclassified' }
UnicornSimulator >> integerRegisterState [

	self subclassResponsibility
]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> invalidAccessHandler: aFullBlockClosure [
	invalidAccessHandler := aFullBlockClosure
]

{ #category : #initialization }
UnicornSimulator >> registerHook: aBlock atAddress: anAddress [

	unicorn
		registerInvalidMemoryAccessHook: UcHookType fetchingAccess value
		doing: [ :type :address :size :value | address = anAddress ifTrue: aBlock ]
]

{ #category : #executing }
UnicornSimulator >> startAt: begin until: until timeout: timeout count: count [

	^ self doStartAt: begin until: until timeout: timeout count: count.

]
