Class {
	#name : #UnicornI386Simulator,
	#superclass : #UnicornSimulator,
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #registers }
UnicornI386Simulator >> arg0Register [
	
	^ UcX86Registers esi
]

{ #category : #registers }
UnicornI386Simulator >> baseRegister [

	^ UcX86Registers ebx
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> cResultRegister [

	^ UcX86Registers eax
]

{ #category : #'c calling convention' }
UnicornI386Simulator >> carg0 [

	"Stack value 0 is return address"
	^ self stackValueAt: 1
]

{ #category : #'c calling convention' }
UnicornI386Simulator >> carg1 [

	"Stack value 0 is return address"
	^ self stackValueAt: 2
]

{ #category : #'c calling convention' }
UnicornI386Simulator >> carg2 [

	"Stack value 0 is return address"
	^ self stackValueAt: 3
]

{ #category : #'c calling convention' }
UnicornI386Simulator >> carg3 [

	"Stack value 0 is return address"
	^ self stackValueAt: 4
]

{ #category : #registers }
UnicornI386Simulator >> classRegister [

	^ UcX86Registers ecx
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> createUnicorn [

	^ Unicorn x86
]

{ #category : #disassembling }
UnicornI386Simulator >> disassembler [
	
	^ LLVMDisassembler i386
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> doublePrecisionFloatingPointRegister0 [

	^ UcX86Registers xmm0
]

{ #category : #accessing }
UnicornI386Simulator >> eax [
	
	^ self readRegister: UcX86Registers eax
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> eax: anInteger [ 

	self writeRegister: UcX86Registers eax value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> ebp [
	^ self readRegister: UcX86Registers ebp
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> ebp: anInteger [ 
	
	self framePointerRegisterValue: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> ebx [
	
	^ self readRegister: UcX86Registers ebx
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> ebx: anInteger [ 

	self writeRegister: UcX86Registers ebx value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> ecx [
	^ self readRegister: UcX86Registers ecx
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> ecx: anInteger [ 

	self writeRegister: UcX86Registers ecx value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> edi [
	
	^ self readRegister: UcX86Registers edi
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> edi: anInteger [ 
	
	self writeRegister: UcX86Registers edi value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> edx [
	^ self readRegister: UcX86Registers edx
]

{ #category : #registers }
UnicornI386Simulator >> edx: anInteger [ 
	
	^ self writeRegister: UcX86Registers edx value: anInteger
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> eflags [
	
	^ self readRegister: UcX86Registers eflags
]

{ #category : #registers }
UnicornI386Simulator >> eip [
	
	^ self readRegister: UcX86Registers eip
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> eip: anInteger [ 
	
	self writeRegister: UcX86Registers eip value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> esi [
	
	^ self readRegister: UcX86Registers esi
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> esi: anInteger [ 
	
	self writeRegister: UcX86Registers esi value: anInteger
]

{ #category : #accessing }
UnicornI386Simulator >> esp [
	
	^ self readRegister: UcX86Registers esp
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> esp: anInteger [ 
	
	self stackPointerRegisterValue: anInteger
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> extractDestinationRegisterFromAssembly: aLLVMInstruction [ 
	
	| registerName |
	registerName := (aLLVMInstruction assemblyCodeString substrings: ',') last trimBoth.
	(registerName beginsWith: '%')
		ifTrue: [ registerName := registerName allButFirst ].
	^ registerName
]

{ #category : #registers }
UnicornI386Simulator >> framePointerRegister [
	
	^ UcX86Registers ebp
]

{ #category : #accessing }
UnicornI386Simulator >> getReturnAddress [
	
	^ self peekAddress
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> hasLinkRegister [ 

	^ false
]

{ #category : #registers }
UnicornI386Simulator >> instructionPointerRegister [
	
	^ UcX86Registers eip
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> integerRegisterState [

	^{	self eax. self ebx. self ecx. self edx. self esp. self ebp. self esi. self edi.
		self eip. self eflags }
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> postCallArgumentsNumArgs: numArgs in: aMemory [
	"Answer an argument vector of the requested size after a vanilla
	 ABI call.  On IA32 this typically means accessing stacked arguments
	 beyond the pushed return address and saved frame pointer.
	 For compatibility with Cog/Slang we answer unsigned values."

	^ (8 to: numArgs * 4 + 4 by: 4) collect: [ :i | 
		  memory longAt: self ebp + i ]
]

{ #category : #registers }
UnicornI386Simulator >> receiverRegister [
	
	^ UcX86Registers edx
]

{ #category : #accessing }
UnicornI386Simulator >> registerList [
	
	^ #(eip eax ebx ecx edx esp ebp esi edi)
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> retpcIn: aMemory [

	^ memory longAt: self ebp + 4
]

{ #category : #registers }
UnicornI386Simulator >> sendNumberOfArgumentsRegister [

	^ UcX86Registers ebx
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> simulateJumpCallOf: address memory: aMemory [
	"Simulate a frame-building jump call of address (i.e. do not push the return pc
	 as this has already been done).  Build a frame since
	a) this is used for calls into the run-time which are unlikely to be leaf-calls, and
	b) stack alignment needs to be realistic for assert checking for platforms such as Mac OS X"

	self pushWord: self ebp.
	self ebp: self esp.
	self eip: address
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> simulateLeafCallOf: address nextpc: nextpc memory: aMemory [

	self pushWord: nextpc.
	self eip: address
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> simulateReturnIn: aMemory [

	self ebp: self popWord.
	self eip: self popWord
]

{ #category : #'as yet unclassified' }
UnicornI386Simulator >> smashCallerSavedRegistersWithValuesFrom: base by: step in: aMemory [
	#(eax: ecx: edx:)
	   withIndexDo:
		[:accessor :index|
		self perform: accessor with: index - 1 * step + base]
]

{ #category : #registers }
UnicornI386Simulator >> smashRegisterAccessors [

	^#(eax: ebx: ecx: edx: esi: edi:)
]

{ #category : #registers }
UnicornI386Simulator >> stackPointerRegister [
	
	^ UcX86Registers esp
]

{ #category : #registers }
UnicornI386Simulator >> temporaryRegister [
	
	"Assume SysV"
	^ UcX86Registers eax
]

{ #category : #accessing }
UnicornI386Simulator >> wordSize [
	
	^ 4
]
