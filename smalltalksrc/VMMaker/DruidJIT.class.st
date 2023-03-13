Class {
	#name : #DruidJIT,
	#superclass : #StackToRegisterMappingCogit,
	#instVars : [
		'ceDereferenceSelectorIndex',
		'ceStoreTrampolines',
		'ceNewHashTrampoline',
		'ceInlineNewHashTrampoline',
		'ceStoreCheckTrampoline',
		'ceStoreCheckContextReceiverTrampoline',
		'ceScheduleScavengeTrampoline',
		'ceSmallActiveContextInMethodTrampoline',
		'ceSmallActiveContextInFullBlockTrampoline',
		'ceLargeActiveContextInMethodTrampoline',
		'ceLargeActiveContextInFullBlockTrampoline'
	],
	#classVars : [
		'CheckRememberedInTrampoline',
		'NumStoreTrampolines'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #translation }
DruidJIT class >> declareCVarsIn: aCodeGen [
	"Deal wuth the fact that the number of trampolines depends on IMMUTABILITY
	 and that IMMUTABILITY can be defined at compile time.  Yes, this is a mess."
	| current values |
	current := InitializationOptions at: #IMMUTABILITY ifAbsent: nil.
	values := #(true false) collect:
				[:bool|
				 InitializationOptions at: #IMMUTABILITY put: bool.
				 self initializeNumTrampolines.
				 (Cogit classPool at: #NumTrampolines) printString].
	current
		ifNil: [InitializationOptions removeKey: #IMMUTABILITY]
		ifNotNil: [InitializationOptions at: #IMMUTABILITY put: current].
	values first ~= values last ifTrue:
		[aCodeGen addConstantForBinding: #NumTrampolines -> ('(IMMUTABILITY ? ' , values first , ' : ' , values last , ')')].

	aCodeGen
		var: #ceStoreTrampolines
		declareC: ('#if IMMUTABILITY\sqInt ceStoreTrampolines[', NumStoreTrampolines printString, '];\#endif') withCRs
]

{ #category : #initialization }
DruidJIT class >> initialize [
	
	NumStoreTrampolines := 5
]

{ #category : #'class initialization' }
DruidJIT class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := 10.
	primitiveTable := CArrayAccessor on:
		                  (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray
]

{ #category : #translation }
DruidJIT class >> objectRepresentationAncilliaryClasses [

	^ Array empty
]

{ #category : #'accessing class hierarchy' }
DruidJIT class >> objectRepresentationClass [

]

{ #category : #'class initialization' }
DruidJIT class >> primitiveTableArray [

	<generated>
	^ {
		  { 1. #gen_PrimitiveAdd. 1 }.
		  { 2. #gen_PrimitiveSubtract. 1 }.
		  { 3. #gen_PrimitiveLessThan. 1 }.
		  { 4. #gen_PrimitiveGreaterThan. 1 }.
		  { 5. #gen_PrimitiveLessOrEqual. 1 }.
		  { 6. #gen_PrimitiveGreaterOrEqual. 1 }.
		  { 7. #gen_PrimitiveEqual. 1 }.
		  { 8. #gen_PrimitiveNotEqual. 1 }.
		  { 9. #gen_PrimitiveMultiply. 1 }.
		  { 10. #gen_PrimitiveDivide. 1 } }
]

{ #category : #'trait candidates' }
DruidJIT >> allYoungObjectsAgeInFullGC [
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> bitAndByteOffsetOfIsFullBlockBitInto: aBlock [

	"This supplies the bitmask for the isFullBlock bit, and the offset of the byte containing
	 that bit in a CogMethod header to aBlock.  We don't have named variables holding this
	 offset.  The following assert tests whether the values are correct by creating a surrogate
	 on an empty ByteArray, setting the bit, and checking that the expected values are set
	 in the ByteArray."
	self cCode: [] inSmalltalk:
		[| m |
		m := ByteArray new: 16.
		CogBlockMethodSurrogate64 new
			at: 0 memory: m headerSize: 8 cogit: nil;
			cpicHasMNUCaseOrCMIsFullBlock: true.
		self assert: m = #[0 0 0 0 0 0 0 0 16 0 0 0 0 0 0 0 ].
		self assert: (m at: objectMemory baseHeaderSize + 1) = 16].
	aBlock value: 16 value: objectMemory baseHeaderSize + 1 "zero-relative"
]

{ #category : #'trait candidates' }
DruidJIT >> cacheTagIsMarked: cacheTag [
	"Answer if the cacheTag is not unmarked, i.e. answer true for compact class
	 indices and immediates; only answer false for unmarked objects.  In Spur
	 linked send cache tags are class indices so effectively they're always marked."
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidObjectReference: anOop [
	^(objectMemory isImmediate: anOop) not
	   and: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidOopReference: anOop [
	^(objectMemory isImmediate: anOop)
	   or: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> classForInlineCacheTag: classIndex [
	^objectMemory classOrNilAtIndex: classIndex
]

{ #category : #'trait candidates' }
DruidJIT >> couldBeObject: literal [
	^(objectMemory isNonImmediate: literal)
	  and: [self oop: literal isGreaterThanOrEqualTo: objectMemory startOfMemory]
]

{ #category : #'trait candidates' }
DruidJIT >> genActiveContextTrampolineLarge: isLarge inBlock: isInBlock called: aString [
	<var: #aString type: #'char *'>
	"Create a trampoline to answer the active context that will
	 answer it if a frame is already married, and create it otherwise.
	 Assume numArgs is in SendNumArgsReg and ClassReg is free."
	| startAddress |
	startAddress := self methodZoneBase.
	self zeroOpcodeIndex.
	self genGetActiveContextLarge: isLarge inBlock: isInBlock.
	self outputInstructionsForGeneratedRuntimeAt: startAddress.
	self recordGeneratedRunTime: aString address: startAddress.
	self recordRunTimeObjectReferences.
	^startAddress
]

{ #category : #'trait candidates' }
DruidJIT >> genCheckRememberedBitOf: objReg scratch: scratchReg [
	"Check the remembered bit of the object in objReg; answer the jump taken if the bit is already set.
	 Only need to fetch the byte containing it, which reduces the size of the mask constant."
	| rememberedBitByteOffset mask |
	rememberedBitByteOffset := self backEnd isBigEndian
									ifTrue: [objectMemory baseHeaderSize - 1 - (objectMemory rememberedBitShift // 8)]
									ifFalse:[objectMemory rememberedBitShift // 8].
	mask := 1 << (objectMemory rememberedBitShift \\ 8).
	self MoveMb: rememberedBitByteOffset r: objReg R: scratchReg.
	self TstCq: mask R: scratchReg.
	^self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genConvertIntegerToSmallIntegerInReg: reg [

	self LogicalShiftLeftCq: objectMemory numTagBits R: reg.
	self AddCq: 1 R: reg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genCreateFullClosure: compiledBlock numArgs: numArgs numCopied: numCopied ignoreContext: ignoreContext contextNumArgs: contextNumArgs large: contextIsLarge inBlock: contextIsBlock [
	"Create a full closure with the given values."
	| numSlots byteSize header skip |
	<var: #skip type: #'AbstractInstruction *'>

	"First get thisContext into ReceiverResultReg and thence in ClassReg."
	ignoreContext
		ifTrue: [ self genMoveNilR: ClassReg ]
		ifFalse: 
			[self genGetActiveContextNumArgs: contextNumArgs large: contextIsLarge inBlock: contextIsBlock.
			self MoveR: ReceiverResultReg R: ClassReg ].
	
	numSlots := FullClosureFirstCopiedValueIndex + numCopied.
	byteSize := objectMemory smallObjectBytesForSlots: numSlots.
	self assert: ClassFullBlockClosureCompactIndex ~= 0.
	header := objectMemory
					headerForSlots: numSlots
					format: objectMemory indexablePointersFormat
					classIndex: ClassFullBlockClosureCompactIndex.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	self
		LoadEffectiveAddressMw: byteSize r: ReceiverResultReg R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	skip := self JumpBelow: 0.
	self CallRT: ceScheduleScavengeTrampoline.
	skip jmpTarget: self Label.

	self
		MoveR: ClassReg Mw: FullClosureOuterContextIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg;
		genMoveConstant: compiledBlock R: TempReg;
		MoveR: TempReg Mw: FullClosureCompiledBlockIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg;
		MoveCq: (objectMemory integerObjectOf: numArgs) R: TempReg;
		MoveR: TempReg Mw: FullClosureNumArgsIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureObjInRegNotForwarded: reg scratchReg: scratch [
	"Make sure that the object in reg is not forwarded.  This routine assumes the object will
	 never be forwarded to an immediate, as it is used to unforward  literal variables (associations). 
	 Use the fact that isForwardedObjectClassIndexPun is a power of two to save an instruction."
	| loop ok |
	<var: #ok type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	self assert: reg ~= scratch.
	loop := self Label.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero:  0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self Jump: loop.
	ok jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch [
	^ self 
		genEnsureOopInRegNotForwarded: reg 
		scratchReg: scratch 
		jumpBackTo: self Label "label is just before the forwarder check"
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch ifForwarder: fwdJumpTarget ifNotForwarder: nonFwdJumpTargetOrZero [
	"Make sure that the oop in reg is not forwarded.  
	 Use the fact that isForwardedObjectClassIndexPun is a power of two to save an instruction."
	| imm ok finished |
	self assert: reg ~= scratch.
	imm := self genJumpImmediate: reg.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero: 0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self Jump: fwdJumpTarget.
	finished := nonFwdJumpTargetOrZero asUnsignedInteger = 0
					ifTrue: [self Label]
					ifFalse: [nonFwdJumpTargetOrZero].
	imm jmpTarget: (ok jmpTarget: finished).
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch jumpBackTo: instruction [
	<var: #instruction type: #'AbstractInstruction *'>
	<inline: true>
	^ self 
		genEnsureOopInRegNotForwarded: reg 
		scratchReg: scratch 
		ifForwarder: instruction
		ifNotForwarder: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch updatingSlot: index in: objReg [
	"Make sure that the oop in reg is not forwarded, updating the slot in objReg with the value."
	| loop imm ok |
	<var: #ok type: #'AbstractInstruction *'>
	<var: #imm type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	"Open-code
		self genEnsureOopInRegNotForwarded: reg
			scratchReg: scratch
			updatingMw: index * objectMemory wordSize + objectMemory baseHeaderSize
			r: objReg.
	 to avoid calling the store check unless the receiver is forwarded."
	self assert: (reg ~= scratch and: [objReg ~= scratch]).
	loop := self Label.
	imm := self genJumpImmediate: reg.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero:  0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self MoveR: reg Mw: index * objectMemory wordSize + objectMemory baseHeaderSize r: objReg.

	"Check that we're meeting the contract of ceStoreCheckContextReceiverTrampoline."
	self assert: (reg = Arg0Reg and: [scratch = TempReg and: [objReg = ReceiverResultReg]]).
	self CallRT: ceStoreCheckContextReceiverTrampoline.

	self Jump: loop.
	ok jmpTarget: (imm jmpTarget: self Label).
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetActiveContextLarge: isLarge inBlock: isInBlock [
	"Create a trampoline to answer the active context that will
	 answer it if a frame is already married, and create it otherwise.
	 Assume numArgs is in SendNumArgsReg and ClassReg is free."
	| header slotSize jumpSingle loopHead jumpNeedScavenge continuation exit |
	<var: #jumpNeedScavenge type: #'AbstractInstruction *'>
	<var: #continuation type: #'AbstractInstruction *'>
	<var: #jumpSingle type: #'AbstractInstruction *'>
	<var: #loopHead type: #'AbstractInstruction *'>
	<var: #exit type: #'AbstractInstruction *'>
	self "load the flag; stash it in both TempReg & ClassReg; do the compare (a prime candidated for use of AndCq:R:R:)"
		MoveMw: FoxMethod r: FPReg R: ClassReg;
		AndCq: MFMethodFlagHasContextFlag R: ClassReg R: TempReg.
	jumpSingle := self JumpZero: 0. "jump if flag bit not set"
	self "since the flag bit was set, get the context in the receiver reg and return"
		MoveMw: FoxThisContext r: FPReg R: ReceiverResultReg;
		RetN: 0.
	jumpSingle jmpTarget: self Label.

	"OK, it doesn't exist; instantiate and initialize it"
	"set the hasContext flag; See CoInterpreter class>>initializeFrameIndices"
	self
		OrCq: MFMethodFlagHasContextFlag R: ClassReg;
		MoveR: ClassReg Mw: FoxMethod r: FPReg.
	"now get the home CogMethod into ClassReg and save for post-instantiation."
	isInBlock caseOf: {
	[InFullBlock]	-> [self SubCq: 3 R: ClassReg]. "-3 is -(hasContext+isBlock) flags"
	[0]				-> [self SubCq: 1 R: ClassReg]. "-1 is hasContext flag" }.

	"instantiate the context..."
	slotSize := isLarge ifTrue: [LargeContextSlots] ifFalse: [SmallContextSlots].
	header := objectMemory
					headerForSlots: slotSize
					format: objectMemory indexablePointersFormat
					classIndex: ClassMethodContextCompactIndex.
	self flag: #endianness.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	self
		MoveR: ReceiverResultReg R: TempReg;
		AddCq: (objectMemory smallObjectBytesForSlots: slotSize) R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	jumpNeedScavenge := self JumpAboveOrEqual: 0.

	"Now initialize the fields of the context.  See CoInterpreter>>marryFrame:SP:copyTemps:"
	"sender gets frame pointer as a SmallInteger"
	continuation :=
	self MoveR: FPReg R: TempReg.
	self genSetSmallIntegerTagsIn: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (SenderIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"pc gets frame caller as a SmallInteger"
	self MoveMw: FoxSavedFP r: FPReg R: TempReg.
	self genSetSmallIntegerTagsIn: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (InstructionPointerIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set the method field, freeing up ClassReg again, and frame's context field,"
	self
		MoveMw: (self offset: CogMethod of: #methodObject) r: ClassReg R: TempReg;
		MoveR: TempReg Mw: objectMemory baseHeaderSize + (MethodIndex * objectMemory wordSize) r: ReceiverResultReg;
		MoveR: ReceiverResultReg Mw: FoxThisContext r: FPReg.

	"Now compute stack pointer; this is stackPointer (- 1 for return pc if a CISC) - framePointer - wordSize (1 each for saved pc, method, context, receiver) + 1 (1-relative) + numArgs"
	"TPR note - the code here is actually doing
	context stackPointer := ((((fp - sp) / wordSize) - [3|4]) + num args) asSmallInteger"
	self
		MoveR: FPReg R: TempReg;
		SubR: SPReg R: TempReg;
		LogicalShiftRightCq: self log2BytesPerWord R: TempReg;
		SubCq: (self backEnd hasLinkRegister ifTrue: [3] ifFalse: [4]) R: TempReg;
		AddR: SendNumArgsReg R: TempReg.
	self genConvertIntegerToSmallIntegerInReg: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (StackPointerIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set closureOrNil to either the stacked receiver or nil"
	isInBlock > 0
		ifTrue:
			[self
				MoveR: SendNumArgsReg R: TempReg;
				AddCq: 2 R: TempReg; "+2 for saved fp and saved pc"
				MoveXwr: TempReg R: FPReg R: TempReg]
		ifFalse:
			[self genMoveNilR: TempReg].
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (ClosureIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set the receiver"
	self
		MoveMw: FoxMFReceiver r: FPReg R: TempReg;
		MoveR: TempReg Mw: objectMemory baseHeaderSize + (ReceiverIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Now copy the arguments.  This is tricky because of the shortage of registers,.  ClassReg ranges
	 from 1 to numArgs (SendNumArgsReg), and from ReceiverIndex + 1 to ReceiverIndex + numArgs.
	 1 to: numArgs do:
		[:i|
		temp := longAt(FPReg + ((SendNumArgs - i + 2) * wordSize)). +2 for saved pc and savedfp
		longAtput(FPReg + FoxMFReceiver + (i * wordSize), temp)]"
	"TPR note: this is a prime candidate for passing off to the backend to do at least faintly optimal code"
	self MoveCq: 1 R: ClassReg.
	loopHead := self CmpR: SendNumArgsReg R: ClassReg.
	exit := self JumpGreater: 0.
	self
		MoveR: SendNumArgsReg R: TempReg;
		SubR: ClassReg R: TempReg;
		AddCq: 2 R: TempReg; "+2 for saved fp and saved pc"
		MoveXwr: TempReg R: FPReg R: TempReg;
		AddCq: ReceiverIndex + (objectMemory baseHeaderSize / objectMemory wordSize) R: ClassReg; "Now convert ClassReg from frame index to context index"
		MoveR: TempReg Xwr: ClassReg R: ReceiverResultReg;
		SubCq: ReceiverIndex + (objectMemory baseHeaderSize / objectMemory wordSize) - 1 R: ClassReg; "convert back adding 1 ;-)"
		Jump: loopHead.
	exit jmpTarget: self Label.

	"Finally nil or copy the non-argument temps.
	 ClassReg := FPReg + FoxMFReceiver.
	 SendNumArgsReg := SendNumArgsReg+ReceiverIndex.
	 [ClassReg := ClassReg - wordSize.
	  backEnd hasLinkRegister
			ifTrue: [ClassReg > SPReg]
			ifFalse: [ClassReg >= SPReg]] whileTrue:
		[receiver[SendNumArgsReg] := *ClassReg.
		 SendNumArgsReg := SendNumArgsReg + 1]]"
	coInterpreter marryFrameCopiesTemps ifFalse:
		[self MoveCq: objectMemory nilObject R: TempReg].
	self
		MoveR: FPReg R: ClassReg;
		AddCq: FoxMFReceiver R: ClassReg;
		AddCq: ReceiverIndex + 1 + (objectMemory baseHeaderSize / objectMemory wordSize) R: SendNumArgsReg.
	loopHead :=
	self SubCq: objectMemory wordSize R: ClassReg.
	self CmpR: SPReg R: ClassReg.
	"If on a CISC there's a retpc for the trampoline call on top of stack; if on a RISC there isn't."
	exit := self backEnd hasLinkRegister
				ifTrue: [self JumpBelow: 0]
				ifFalse: [self JumpBelowOrEqual: 0].
	coInterpreter marryFrameCopiesTemps ifTrue:
		[self MoveMw: 0 r: ClassReg R: TempReg].
	self
		MoveR: TempReg Xwr: SendNumArgsReg R: ReceiverResultReg;
		AddCq: 1 R: SendNumArgsReg;
		Jump: loopHead.
	exit jmpTarget: self Label.

	self RetN: 0.
	
	jumpNeedScavenge jmpTarget: self Label.
	self backEnd saveAndRestoreLinkRegAround:
		[self
			CallRT: ceScheduleScavengeTrampoline
			registersToBeSavedMask: (self registerMaskFor: ReceiverResultReg and: SendNumArgsReg and: ClassReg)].
	self Jump: continuation.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetActiveContextNumArgs: numArgs large: isLargeContext inBlock: isInBlock [
	"Get the active context into ReceiverResultReg, creating it if necessary."
	| routine |
	routine := isLargeContext
				ifFalse: [isInBlock caseOf: {
						[0]				-> [ceSmallActiveContextInMethodTrampoline].
						[InFullBlock]	-> [ceSmallActiveContextInFullBlockTrampoline] }]
				ifTrue: [isInBlock caseOf: {
						[0]				-> [ceLargeActiveContextInMethodTrampoline].
						[InFullBlock]	-> [ceLargeActiveContextInFullBlockTrampoline] }].
	self
		MoveCq: numArgs R: SendNumArgsReg;
		CallRT: routine.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassObjectOf: instReg into: destReg scratchReg: scratchReg instRegIsReceiver: instRegIsReceiver [
	"Fetch the instance's class into destReg.  If the instance is not the receiver and is forwarded, follow forwarding."
	| jumpIsImm jumpNotForwarded loop |
	<var: #jumpIsImm type: #'AbstractInstruction *'>
	<var: #jumpNotForwarded type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	(instReg = destReg or: [instReg = scratchReg or: [destReg = scratchReg]]) ifTrue:
		[^BadRegisterSet].
	loop := self MoveR: instReg R: scratchReg.
	self AndCq: objectMemory tagMask R: scratchReg.
	jumpIsImm := self JumpNonZero: 0.
	self flag: #endianness.
	"Get least significant half of header word in destReg"
	self MoveMw: 0 r: instReg R: scratchReg.
	"mask off class index"
	self AndCq: objectMemory classIndexMask R: scratchReg.
	instRegIsReceiver ifFalse:
		["if it is forwarded..."
		self CmpCq: objectMemory isForwardedObjectClassIndexPun R: scratchReg.
		jumpNotForwarded := self JumpNonZero: 0.
		"...follow the forwarding pointer and loop to fetch its classIndex"
		self MoveMw: objectMemory baseHeaderSize r: instReg R: instReg.
		self Jump: loop.
		jumpNotForwarded jmpTarget: self Label].
	jumpIsImm jmpTarget:
	(self MoveR: scratchReg R: destReg).
	scratchReg = TempReg
		ifTrue:
			[self PushR: instReg.
			 self genGetClassObjectOfClassIndex: destReg into: instReg scratchReg: TempReg.
			 self MoveR: instReg R: destReg.
			 self PopR: instReg]
		ifFalse:
			[self genGetClassObjectOfClassIndex: destReg into: scratchReg scratchReg: TempReg.
			 self MoveR: scratchReg R: destReg].
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassObjectOfClassIndex: instReg into: destReg scratchReg: scratchReg [
	"Fetch the class object whose index is in instReg into destReg.
	 It is non-obvious, but the Cogit assumes loading a class does not involve
	 a runtime call, so do not call classAtIndex:"
	self assert: instReg ~= destReg.
	self assert: instReg ~= scratchReg.
	self assert: destReg ~= scratchReg.
	self
		MoveR: instReg R: scratchReg;
		LogicalShiftRightCq: objectMemory classTableMajorIndexShift R: scratchReg;
		LogicalShiftLeftCq: objectMemory shiftForWord R: scratchReg.
	self assert: (self shouldAnnotateObjectReference: objectMemory classTableRootObj) not.
	(self backEnd isWithinMwOffsetRange: objectMemory classTableRootObj + objectMemory baseHeaderSize)
		ifTrue: [self MoveMw: objectMemory classTableRootObj + objectMemory baseHeaderSize r: scratchReg R: destReg]
		ifFalse: [self
					AddCq: objectMemory classTableRootObj R: scratchReg;
					MoveMw: objectMemory baseHeaderSize r: scratchReg R: destReg].
	self
		MoveR: instReg R: scratchReg;
		AndCq: objectMemory classTableMinorIndexMask R: scratchReg;
		AddCq: objectMemory baseHeaderSize >> objectMemory shiftForWord R: scratchReg;
		MoveXwr: scratchReg R: destReg R: destReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassTagOf: instReg into: destReg scratchReg: scratchReg [
	^self genGetInlineCacheClassTagFrom: instReg into: destReg forEntry: true
]

{ #category : #'trait candidates' }
DruidJIT >> genGetInlineCacheClassTagFrom: sourceReg into: destReg forEntry: forEntry [
	"Extract the inline cache tag for the object in sourceReg into destReg. The inline
	 cache tag for a given object is the value loaded in inline caches to distinguish
	 objects of different classes.  In Spur this is either the tags for immediates, or
	 the receiver's classIndex.  Answer the label for the start of the sequence."
	| jumpImm entryLabel |
	<var: #jumpImm type: #'AbstractInstruction *'>
	<var: #entryLabel type: #'AbstractInstruction *'>
	forEntry ifTrue:
		[ self AlignmentNops: objectMemory wordSize].
	entryLabel := self Label.
	self AndCq: objectMemory tagMask R: sourceReg R: destReg.
	jumpImm := self JumpNonZero: 0.
	"Get least significant half of header word in destReg"
	self flag: #endianness.
	self MoveMw: 0 r: sourceReg R: destReg.
	self AndCq: objectMemory classIndexMask R: destReg.

	"The entry and the noCheckEntry (that will generated after) need to be aligned differently.
	We do that by forcing some odd number of extra Nop operations here.
	One Nop is not enough because that causes x86-64 entries to have the same allignment.
	
	In ARM64 all instructions are 4 byte long, thus 3 Nops make 
	   - the entry to be aligned to 8 bytes and
	   - the no check entry aligned to 4 bytes.
	
	In x86-64 instruction size is variable, and 3 Nops take 3 bytes."
	forEntry ifTrue: [ 
		self Nop.
		self Nop.
		self Nop.
	].

	jumpImm jmpTarget: self Label.
	^entryLabel
]

{ #category : #'trait candidates' }
DruidJIT >> genInlinedIdenticalOrNotIfGuts: orNot [
	<inline: true>

	^ self genForwardersInlinedIdenticalOrNotIf: orNot
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpBaseHeaderImmutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	
	self  TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpBaseHeaderMutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	self TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpImmediate: aRegister [
	<returnTypeC: #'AbstractInstruction *'>

	self TstCq: objectMemory tagMask R: aRegister.
	^ self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpImmutable: sourceReg scratchReg: scratchReg [
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	self MoveMw: 0 r: sourceReg R: scratchReg. 
	^ self genJumpBaseHeaderImmutable: scratchReg
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpInOldSpace: reg [
	"Jump if reg is old."
	<inline: true>
	^ self
		CmpCq: objectMemory storeCheckBoundary R: reg; "N.B. FLAGS := destReg - scratchReg"
		JumpAboveOrEqual: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpMutable: sourceReg scratchReg: scratchReg [
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>

	self MoveMw: 0 r: sourceReg R: scratchReg. 
	^ self genJumpBaseHeaderMutable: scratchReg
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallInteger: reg [
	"Generate a compare and branch to test if aRegister contains other than a SmallInteger."
	^ self
		TstCq: objectMemory smallIntegerTag R: reg;
		JumpZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallIntegerInScratchReg: aRegister [
	<inline: true>
	^self genJumpNotSmallInteger: aRegister
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallIntegersIn: aRegister and: bRegister scratch: scratchRegister [
	"Generate a compare and branch to test if aRegister and bRegister contains other than SmallIntegers,
	 i.e. don't branch if both aRegister and bRegister contain SmallIntegers.
	 Answer the jump.  Destroy scratchRegister if required."
	<returnTypeC: #'AbstractInstruction *'>
	<inline: true>
	self
		MoveR: aRegister R: scratchRegister;
		AndR: bRegister R: scratchRegister.
	^self genJumpNotSmallIntegerInScratchReg: scratchRegister
]

{ #category : #'trait candidates' }
DruidJIT >> genLoadSlot: index sourceReg: sourceReg destReg: destReg [
	
	self
		MoveMw: index * objectMemory wordSize + objectMemory baseHeaderSize
		r: sourceReg
		R: destReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genNewArrayOfSize: size initialized: initialized [
	"Generate a call to code that allocates a new Array of size.
	 The Array should be initialized with nils iff initialized is true.
	 The size arg is passed in SendNumArgsReg, the result
	 must come back in ReceiverResultReg."
	| header skip |
	<var: #skip type: #'AbstractInstruction *'>
	self assert: size < objectMemory numSlotsMask.
	header := objectMemory
					headerForSlots: size
					format: objectMemory arrayFormat
					classIndex: ClassArrayCompactIndex.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	(initialized and: [size > 0]) ifTrue:
		[self genMoveConstant: objectMemory nilObject R: TempReg.
		 0 to: size - 1 do:
			[:i| self MoveR: TempReg
					Mw: i * objectMemory wordSize + objectMemory baseHeaderSize
					r: ReceiverResultReg]].
	self
		LoadEffectiveAddressMw: (objectMemory smallObjectBytesForSlots: size) r: ReceiverResultReg R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	skip := self JumpBelow: 0.
	self CallRT: ceScheduleScavengeTrampoline.
	skip jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genNewHashTrampoline: saveRegs called: name [
	"In non sista VM this is used only from the identityHash primitive, hence only the result of the trampoline, the hash, should be in ReceiverResultReg, other registers can just be ignored.
	In the sista VM, the inlined hash operation requires registers to be saved"
	<inline: true>
	^ self
		genTrampolineFor: #ceNewHashOf:
		called: name
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (saveRegs
						ifTrue: [CallerSavedRegisterMask bitClear: (self registerMaskFor: ReceiverResultReg)]
						ifFalse: [self emptyRegisterMask])
		pushLinkReg: true
		resultReg: ReceiverResultReg
		appendOpcodes: false
]

{ #category : #'trait candidates' }
DruidJIT >> genRemoveSmallIntegerTagsInScratchReg: scratchReg [

	self SubCq: 1 R: scratchReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genSetSmallIntegerTagsIn: scratchReg [
	self OrCq: 1 R: scratchReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckContextReceiverTrampoline [
	"Create a trampoline to store-check the update of the receiver in a closure's
	 outerContext in compileBlockFrameBuild:."
	| startAddress |
	startAddress := self methodZoneBase.
	self zeroOpcodeIndex.
	self genStoreCheckReceiverReg: ReceiverResultReg valueReg: Arg0Reg scratchReg: TempReg inFrame: false.
	self RetN: 0.
	self outputInstructionsForGeneratedRuntimeAt: startAddress.
	self recordGeneratedRunTime: 'ceStoreCheckContextReceiver' address: startAddress.
	self recordRunTimeObjectReferences.
	^startAddress
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckReceiverReg: destReg valueReg: valueReg scratchReg: scratchReg inFrame: inFrame [
	"Generate the code for a store check of valueReg into destReg."
	| jmpImmediate jmpDestYoung jmpSourceOld jmpAlreadyRemembered |
	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpSourceOld type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>
	"Is value stored an immediate?  If so we're done"
	jmpImmediate := self genJumpImmediate: valueReg.
	"Get the old/new boundary in scratchReg"
	self MoveCw: objectMemory storeCheckBoundary R: scratchReg.
	"Is target young?  If so we're done"
	self CmpR: scratchReg R: destReg. "N.B. FLAGS := destReg - scratchReg"
	jmpDestYoung := self JumpBelow: 0.
	"Is value stored old?  If so we're done."
	self CmpR: scratchReg R: valueReg. "N.B. FLAGS := valueReg - scratchReg"
	jmpSourceOld := self JumpAboveOrEqual: 0.
	"value is young and target is old.
	 Need to remember this only if the remembered bit is not already set."
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered := self genCheckRememberedBitOf: destReg scratch: scratchReg].
	"Remembered bit is not set.  Call store check to insert dest into remembered table."
	self assert: destReg = ReceiverResultReg.
	self 
		evaluateTrampolineCallBlock: [self CallRT: ceStoreCheckTrampoline]
		protectLinkRegIfNot: inFrame.
	jmpImmediate jmpTarget:
	(jmpDestYoung jmpTarget:
	(jmpSourceOld jmpTarget:
		self Label)).
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpSourceOld getJmpTarget].
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckTrampoline [
	| jumpSC |
	<var: #jumpSC type: #'AbstractInstruction *'>
	<inline: true>
	CheckRememberedInTrampoline ifTrue:
		[ self zeroOpcodeIndex.
		 jumpSC := self genCheckRememberedBitOf: ReceiverResultReg scratch: self backEnd cResultRegister.
		 self assert: jumpSC opcode = JumpNonZero.
		 jumpSC opcode: JumpZero.
		 self RetN: 0.
		 jumpSC jmpTarget: self Label].
	^ self
		genTrampolineFor: #remember:
		called: 'ceStoreCheckTrampoline'
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (CallerSavedRegisterMask bitClear: (self registerMaskFor: ReceiverResultReg))
		pushLinkReg: true
		resultReg: self returnRegForStoreCheck
		appendOpcodes: CheckRememberedInTrampoline
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreHeader: header intoNewInstance: rcvrReg using: scratchReg [
	"Generate the instructions to move the constant header into a new instance pointed to by rcvrReg."
	<inline: true>
	self
		MoveCq: header R: scratchReg;
		MoveR: scratchReg Mw: 0 r: rcvrReg
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg inFrame: inFrame [
	<inline: true>
	self 
		cppIf: IMMUTABILITY
		ifTrue:
			[ ^ self 
				genStoreWithImmutabilityCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needsStoreCheck: true 
				needRestoreRcvr: false "RcvrResultReg doesn't need to be live across the instructions" ]
		ifFalse: 
			[ ^ self 
				genStoreSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				inFrame: inFrame 
				needsStoreCheck: true ]
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg inFrame: inFrame needsStoreCheck: needsStoreCheck [
	
	self genTraceStores.
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	"now the check. needStoreCheck is false if the JIT has figured out that the value stored does not need the check (immediate, nil, true, false)"
	needsStoreCheck ifTrue: 
		[ ^ self 
			genStoreCheckReceiverReg: destReg 
			valueReg: sourceReg 
			scratchReg: scratchReg 
			inFrame: inFrame ].
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index intoNewObjectInDestReg: destReg [
	"This method is used for unchecked stores in objects after their creation (typically, inlined creation of Array, closures and some temp vectors). 
	Currently there is no need to do the immutability check here"

	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreTrampolineCall: instVarIndex [
	<inline: true>
	self assert: IMMUTABILITY.
	instVarIndex >= (NumStoreTrampolines - 1)
		ifTrue: 
			[ self MoveCq: instVarIndex R: TempReg.
			  self CallRT: (ceStoreTrampolines at: NumStoreTrampolines - 1) ]
		ifFalse: 
			[ self CallRT: (ceStoreTrampolines at: instVarIndex) ].
	 self annotateBytecode: self Label
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreTrampolineCalled: trampolineName instVarIndex: instVarIndex [
	"Convention:
	- RcvrResultReg holds the object mutated.
	If immutability failure:
	- TempReg holds the instance variable index mutated 
		if instVarIndex > numDedicatedStoreTrampoline
	- ClassReg holds the value to store
	Registers are not lived across this trampoline as the 
	immutability failure may need new stack frames."
	
	| jumpSC jumpRC |
	<option: #IMMUTABILITY>
	<var: #trampolineName type: #'char *'>
	<var: #jumpSC type: #'AbstractInstruction *'>
	<var: #jumpRC type: #'AbstractInstruction *'>
	<inline: false>
	self zeroOpcodeIndex.
	"SendNumArgsReg is mutated but we don't care as register are not live across the trampoline.
	 There is no reason why registers cannot be saved over the remember: call, but since the
	 immutability check is a suspension point, registers cannot remain live."
	jumpSC := self genJumpMutable: ReceiverResultReg scratchReg: SendNumArgsReg.
	self
		compileTrampolineFor: #ceCannotAssignTo:withIndex:valueToAssign:
		numArgs: 3
		arg: ReceiverResultReg
		arg: (instVarIndex < (NumStoreTrampolines - 1)
				ifTrue: [self trampolineArgConstant: instVarIndex]
				ifFalse: [TempReg])
		arg: ClassReg
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg.
		
	"Store check"
	jumpSC jmpTarget: self Label.
	"If on 64-bits and doing the remembered bit test here, we can combine the tests to fetch the header once."
	CheckRememberedInTrampoline ifTrue:
		[objectMemory wordSize = 8
			ifTrue:
				[self TstCq: 1 << objectMemory rememberedBitShift R: SendNumArgsReg.
				 jumpRC := self JumpZero: 0.
				 self RetN: 0]
			ifFalse:
				[jumpRC := self genCheckRememberedBitOf: ReceiverResultReg scratch: SendNumArgsReg.
				 self assert: jumpRC opcode = JumpNonZero.
				 jumpRC opcode: JumpZero.
				 self RetN: 0].
		 jumpRC jmpTarget: self Label].
	^ self genTrampolineFor: #remember:
		called: trampolineName
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityAndStoreCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needRestoreRcvr: needRestoreRcvr [ 
	"Store check code is duplicated to use a single trampoline"
	<option: #IMMUTABILITY>
	| immutableJump jmpImmediate jmpDestYoung jmpSourceOld jmpAlreadyRemembered |
	<var: #immutableJump type: #'AbstractInstruction *'>
	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpSourceOld type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>

	immutableJump := self genJumpImmutable: destReg scratchReg: scratchReg.
	
	self genTraceStores.
	
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	
	"store check"
	jmpImmediate := self genJumpImmediate: sourceReg.
	"Get the old/new boundary in scratchReg"
	self MoveCw: objectMemory storeCheckBoundary R: scratchReg.
	"Is target young?  If so we're done"
	self CmpR: scratchReg R: destReg. "N.B. FLAGS := destReg - scratchReg"
	jmpDestYoung := self JumpBelow: 0.
	"Is value stored old?  If so we're done."
	self CmpR: scratchReg R: sourceReg. "N.B. FLAGS := valueReg - scratchReg"
	jmpSourceOld := self JumpAboveOrEqual: 0.
	"value is young and target is old.
	 Need to remember this only if the remembered bit is not already set."
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered := self genCheckRememberedBitOf: destReg scratch: scratchReg].
	"Set the inst var index for the benefit of the immutability check. The trampoline will
	 repeat the check to choose between the immutbality violation and the store check."
	immutableJump jmpTarget: self Label.
	self genStoreTrampolineCall: index.
	self voidReceiverOptStatus.
	needRestoreRcvr ifTrue:
		[self putSelfInReceiverResultReg].

	jmpImmediate jmpTarget:
	(jmpDestYoung jmpTarget:
	(jmpSourceOld jmpTarget:
		self Label)).
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpSourceOld getJmpTarget].
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityButNoStoreCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needRestoreRcvr: needRestoreRcvr [
	"Gen an immutability check with no store check (e.g. assigning an immediate literal)"
	<option: #IMMUTABILITY>
	<var: #mutableJump type: #'AbstractInstruction *'>
	<var: #immutabilityFailure type: #'AbstractInstruction *'>
	| immutabilityFailure mutableJump |
	
	"imm check has its own trampoline"
	mutableJump := self genJumpMutable: destReg scratchReg: scratchReg.
	self genStoreTrampolineCall: index.
	self voidReceiverOptStatus.
	needRestoreRcvr ifTrue:
		[self putSelfInReceiverResultReg].
	immutabilityFailure := self Jump: 0.
	mutableJump jmpTarget: self Label.

	self genTraceStores.
	
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
		
	immutabilityFailure jmpTarget: self Label.

	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needsStoreCheck: needsStoreCheck needRestoreRcvr: needRestoreRcvr [
	<option: #IMMUTABILITY>
	"We know there is a frame as immutability check requires a frame"
	"needRestoreRcvr has to be true to keep RcvrResultReg live with the receiver in it across the trampoline"
	
	"Trampoline convention..."
	self assert: destReg == ReceiverResultReg.
	self assert: scratchReg == TempReg.
  	self assert: sourceReg == ClassReg.
	
	"The two paths are very different as the trampoline is shared in 1 case so we split here"
	needsStoreCheck
		ifTrue: 
			[ self 
				genStoreWithImmutabilityAndStoreCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needRestoreRcvr: needRestoreRcvr ]
		ifFalse: 
			[ self 
				genStoreWithImmutabilityButNoStoreCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needRestoreRcvr: needRestoreRcvr ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAdd [
	"AutoGenerated by Druid"

	| jump1 jump2 currentBlock |
	self mclassIsSmallInteger ifFalse: [ ^ UnimplementedPrimitive ].
	self TstCq: 1 R: Arg0Reg.
	jump1 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self SubCq: 1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AddR: ClassReg R: TempReg.
	jump2 := self JumpOverflow: 0.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveDivide [
	"AutoGenerated by Druid"

	| jump5 jump3 jump1 currentBlock jump4 jump2 |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump4 := self JumpNonZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self ArithmeticShiftRightCq: 60 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self AndCq: 15 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump5 := self JumpGreater: 0.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpZero: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreaterOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreater: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLessOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLess: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveMultiply [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self MoveR: Arg0Reg R: ClassReg.
	self SubCq: 1 R: ClassReg.
	self MulR: ClassReg R: TempReg.
	jump3 := self JumpMultiplyOverflow: 0.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNotEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpNonZero: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSubtract [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self SubCq: 1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self SubR: TempReg R: ClassReg.
	jump3 := self JumpOverflow: 0.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #'trait candidates' }
DruidJIT >> generateObjectRepresentationTrampolines [
	"Do the store check.  Answer the argument for the benefit of the code generator;
	 ReceiverResultReg may be caller-saved and hence smashed by this call.  Answering
	 it allows the code generator to reload ReceiverResultReg cheaply.
	 In Spur the only thing we leave to the run-time is adding the receiver to the
	 remembered set and setting its isRemembered bit."
	self 
		cppIf: IMMUTABILITY
		ifTrue: [
			self 
				cCode: [] 
				inSmalltalk: [ ceStoreTrampolines := CArrayAccessor on: (Array new: NumStoreTrampolines) ].
				
			 0 to: NumStoreTrampolines - 1 do:
				[:instVarIndex |
				 ceStoreTrampolines
					at: instVarIndex
					put: (self 
							genStoreTrampolineCalled: (self 
															trampolineName: 'ceStoreTrampoline' 
															numArgs: instVarIndex 
															limit: NumStoreTrampolines - 2) 
							instVarIndex: instVarIndex)]].
	ceNewHashTrampoline := self genNewHashTrampoline: false called: 'ceNewHash'.
	SistaVM ifTrue: [ceInlineNewHashTrampoline := self genNewHashTrampoline: true  called: 'ceInlineNewHash'].
	ceStoreCheckTrampoline := self genStoreCheckTrampoline.
	ceStoreCheckContextReceiverTrampoline := self genStoreCheckContextReceiverTrampoline.
	ceScheduleScavengeTrampoline := self
											genTrampolineFor: #ceScheduleScavenge
											called: 'ceScheduleScavengeTrampoline'
											regsToSave: CallerSavedRegisterMask.
	ceSmallActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: false inBlock: 0 called: 'ceSmallMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceSmallActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: false inBlock: InFullBlock called: 'ceSmallFullBlockContext'].
	ceLargeActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: true inBlock: 0 called: 'ceLargeMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceLargeActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: true inBlock: InFullBlock called: 'ceLargeFullBlockContext'].
]

{ #category : #'trait candidates' }
DruidJIT >> getActiveContextAllocatesInMachineCode [
	"Make sure SendNumArgsReg and ClassReg are available in addition to
	 ReceiverResultReg and TempReg in genGetActiveContextNumArgs:large:inBlock:."
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> hasValidHeaderPostGC: cogMethod [
	<var: #cogMethod type: #'CogMethod *'>
	<inline: true>
	^cogMethod objectHeader = objectMemory nullHeaderForMachineCodeMethod
]

{ #category : #'trait candidates' }
DruidJIT >> initialize [

	<doNotGenerate>
	super initialize.
	
	ceStoreTrampolines := (CArrayAccessor on: (Array new: NumStoreTrampolines))
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagForInstance: oop [
	"Answer the relevant inline cache tag for an instance.
	 c.f. getInlineCacheClassTagFrom:into: & inlineCacheTagForClass:"
	^(objectMemory isImmediate: oop)
		ifTrue: [oop bitAnd: objectMemory tagMask]
		ifFalse: [objectMemory classIndexOf: oop]
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagIsYoung: cacheTag [
	"Since all cache tags in Spur are class indices none of
	 them are young or have to be updated in a scavenge."
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> isUnannotatableConstant: simStackEntry [
	<inline: true>
	<var: 'simStackEntry' type: #'CogSimStackEntry *'>
	^simStackEntry type = SSConstant
	  and: [(objectMemory isImmediate: simStackEntry constant)
		or: [(self shouldAnnotateObjectReference: simStackEntry constant) not]]
]

{ #category : #'trait candidates' }
DruidJIT >> log2BytesPerWord [
	^3
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceCacheTagLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in an inline cache preceding address in cogMethodOrNil.
	 Answer if code was modified.  In 64-bit Spur, cache tags are either selector
	 indices or class indices and so this is a noop."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	<inline: true>
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethod at: address [
	"Mark and trace a literal in a sqInt variable of cogMethod."
	<var: #cogMethod type: #'CogMethod *'>
	<var: #address type: #'sqInt *'>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^self].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^self].
	objOop := objectMemory followForwarded: literal.
	address at: 0 put: objOop.
	self markAndTraceUpdatedLiteral: objOop in: cogMethod
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in a machine code instruction preceding address in cogMethodOrNil.
	 Answer if code was modified."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^false].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^false].
	objOop := objectMemory followForwarded: literal.
	self backEnd storeLiteral: objOop beforeFollowingAddress: address.
	self markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil.
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil [
	"Common code to mark a literal in cogMethod and add
	 the cogMethod to youngReferrers if the literal is young."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	(objectMemory isNonImmediate: objOop) ifTrue:
		[(cogMethodOrNil notNil
		  and: [objectMemory isYoungObject: objOop]) ifTrue:
			[methodZone ensureInYoungReferrers: cogMethodOrNil].
		 objectMemory markAndTrace: objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> maybeCompileRetryOnPrimitiveFail: primIndex [
	"If primIndex has an accessorDepth and fails, or it is external and fails with PrimErrNoMemory,
	 call ceCheckAndMaybeRetryPrimitive if so  If ceCheck.... answers true, retry the primitive."
	| jmp |
	<var: #jmp type: #'AbstractInstruction *'>
	(coInterpreter accessorDepthForPrimitiveIndex: primIndex) >= 0
		ifTrue:
			[jmp := self
				MoveAw: coInterpreter primFailCodeAddress R: TempReg;
				CmpCq: 0 R: TempReg;
				JumpZero: 0]
		ifFalse:
			[coInterpreter primNumberExternalCall ~= primIndex ifTrue:
				[^0].
			 jmp := self
				MoveAw: coInterpreter primFailCodeAddress R: TempReg;
				CmpCq: PrimErrNoMemory R: TempReg;
				JumpNonZero: 0].
	self
		compileCallFor: #ceCheckAndMaybeRetryPrimitive:
		numArgs: 1
		arg: (self trampolineArgConstant: primIndex)
		arg: nil
		arg: nil
		arg: nil
		resultReg: TempReg
		regsToSave: self emptyRegisterMask.
	jmp jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> maybeGenerateSelectorIndexDereferenceRoutine [
	"Generate the routine that converts selector indices into selector objects.
	 It is called from the send trampolines.
	 If the selector index is negative, convert it into a positive index into the
	 special selectors array and index that.  Otherwise, index the current method.
	 The routine uses Extra0Reg & Extra1Reg, which are available, since they
	 are not live at point of send."
	| jumpNegative jumpNotBlock jumpFullBlock |
	<var: 'jumpNegative' type: #'AbstractInstruction *'>
	<var: 'jumpNotBlock' type: #'AbstractInstruction *'>
	<var: 'jumpFullBlock' type: #'AbstractInstruction *'>
	self zeroOpcodeIndex.
	self CmpCq: 0 R: ClassReg.
	jumpNegative := self JumpLess: 0.
	self
		MoveMw: FoxMethod r: FPReg R: Extra0Reg;
		AddCq: 2 R: ClassReg; "Change selector index to 1-relative, skipping the method header"
		TstCq: MFMethodFlagIsBlockFlag R: Extra0Reg.
	jumpNotBlock := self JumpZero: 0.
	"If in a block, need to find the home method...  If using full blocks, need to test the cpicHasMNUCaseOrCMIsFullBlock bit"
	self AndCq: methodZone zoneAlignment negated R: Extra0Reg.
	SistaV1BytecodeSet ifTrue:
		[self bitAndByteOffsetOfIsFullBlockBitInto:
			[:bitmask :byteOffset|
			jumpFullBlock := self
				MoveMb: byteOffset r: Extra0Reg R: Extra1Reg;
				TstCq: bitmask R: Extra1Reg;
				JumpNonZero: 0]].
	self 
		MoveM16: 0 r: Extra0Reg R: Extra1Reg;
		SubR: Extra1Reg R: Extra0Reg.
	jumpNotBlock jmpTarget: self Label.
	SistaV1BytecodeSet ifTrue:
		[jumpFullBlock jmpTarget: jumpNotBlock getJmpTarget].
	self "Now fetch the method object and index with the literal index to retrieve the selector"
		AndCq: methodZone zoneAlignment negated R: Extra0Reg;
		MoveMw: (self offset: CogMethod of: #methodObject) r: Extra0Reg R: Extra1Reg;
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	jumpNegative jmpTarget: self Label.
	self
		NegateR: ClassReg;
		LogicalShiftLeftCq: 1 R: ClassReg;
		MoveAw: objectMemory specialObjectsArrayAddress R: Extra0Reg;
		SubCq: 1 R: ClassReg;
		MoveMw: SpecialSelectors + 1 * objectMemory wordSize r: Extra0Reg R: Extra1Reg; "Index, including header size"
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	ceDereferenceSelectorIndex := self methodZoneBase.
	self
		outputInstructionsForGeneratedRuntimeAt: ceDereferenceSelectorIndex;
		recordGeneratedRunTime: 'ceDereferenceSelectorIndex' address: ceDereferenceSelectorIndex;
		recordRunTimeObjectReferences
]

{ #category : #'trait candidates' }
DruidJIT >> maybeShiftClassTagRegisterForMethodCacheProbe: classTagReg [
	"Generate a shift of the register containing the class tag in a method cache probe.
	 c.f. SpurMemoryManager>>methodCacheHashOf:with:"

	self LogicalShiftLeftCq: 2 R: classTagReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> numRegArgs [
	"Define how many register arguments a StackToRegisterMappingCogit can
	 and should use with the receiver.  The value must be 0, 1 or 2.  Note that a
	 SimpleStackBasedCogit always has 0 register args (although the receiver is
	 passed in a register).  The Spur object representation is simple enough that
	 implementing at:put: is straight-forward and hence 2 register args are worth
	 while.  The method must be inlined in CoInterpreter, and dead code eliminated
	 so that the register-popping enilopmarts such as enterRegisterArgCogMethod:-
	 at:receiver: do not have to be implemented in SimpleStackBasedCogit."
	<api>
	<option: #StackToRegisterMappingCogit>
	^2
]

{ #category : #'trait candidates' }
DruidJIT >> remapObject: objOop [
	self assert: (objectMemory addressCouldBeObj: objOop).
	^(objectMemory shouldRemapObj: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> remapOop: objOop [
	^(objectMemory shouldRemapOop: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> selectorIndexDereferenceRoutine [
	"If the object representation is 64-bits, selectors must be accessed via indices in the inline caches.
	 Answer the routine that will map from indices to selector objects if so, otherwise nil."
	^ceDereferenceSelectorIndex
]

{ #category : #'trait candidates' }
DruidJIT >> shouldAnnotateObjectReference: anOop [
	"Objects in newSpace or oldSpace except nil, true, false & classTableRootObj need to be annotated."
	^(objectMemory isNonImmediate: anOop)
	  and: [(self oop: anOop isGreaterThan: objectMemory classTableRootObj)
		or: [self oop: anOop isLessThan: objectMemory nilObject]]
]

{ #category : #'trait candidates' }
DruidJIT >> slotOffsetOfInstVarIndex: index [
	^index * objectMemory wordSize + objectMemory baseHeaderSize
]

{ #category : #'trait candidates' }
DruidJIT >> validInlineCacheTag: classIndexOrTagPattern [
	"The three valid tag patterns are 1 (SmallInteger), 2 (Character) and 3 (SmallFloat64)."
	^(classIndexOrTagPattern >= 1
	  and: [classIndexOrTagPattern <= 3])
	  or: [(objectMemory classAtIndex: classIndexOrTagPattern) notNil]
]

{ #category : #'trait candidates' }
DruidJIT >> valueOfAssociation: associationOop [
	| association |
	association := associationOop.
	(objectMemory isForwarded: association) ifTrue:
		[association := objectMemory followForwarded: association].
	^objectMemory fetchPointer: ValueIndex ofObject: association
]
