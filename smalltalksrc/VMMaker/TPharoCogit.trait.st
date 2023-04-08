Trait {
	#name : #TPharoCogit,
	#instVars : [
		'objectRepresentation',
		'ceCannotResumeTrampoline',
		'ceSendMustBeBooleanAddFalseTrampoline',
		'ceSendMustBeBooleanAddTrueTrampoline',
		'ceSendMustBeBooleanTrampoline',
		'ceFetchContextInstVarTrampoline',
		'ceStoreContextInstVarTrampoline'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #accessing }
TPharoCogit >> ceCannotResumePC [
	<api>
	<cmacro: '() ((usqInt)ceCannotResumeTrampoline)'>
	<returnTypeC: #usqInt> "for Slang"
	^ceCannotResumeTrampoline
]

{ #category : #accessing }
TPharoCogit >> ceSendMustBeBooleanAddFalseTrampoline: anInteger [

	<doNotGenerate>

	ceSendMustBeBooleanAddFalseTrampoline := anInteger
]

{ #category : #accessing }
TPharoCogit >> ceSendMustBeBooleanAddTrueTrampoline: anInteger [ 

	<doNotGenerate>
	
	ceSendMustBeBooleanAddTrueTrampoline :=	anInteger

]

{ #category : #initialization }
TPharoCogit >> ceSendMustBeBooleanTrampoline: aTrampolineAddress [

	ceSendMustBeBooleanTrampoline := aTrampolineAddress
]

{ #category : #'profiling primitives' }
TPharoCogit >> classForInlineCacheTag: classIndex [

	^ self objectMemory classOrNilAtIndex: classIndex
]

{ #category : #'span functions' }
TPharoCogit >> distanceForShortForwardBranch: pc inMethod: aMethodObj [
	"N.B.  This serves for both BlueBook/V3 and V4 short jumps."
	<var: #descriptor type: #'BytecodeDescriptor *'>
	<inline: true>
	
	^((objectMemory fetchByte: pc ofObject: aMethodObj) bitAnd: 7) + 1
]

{ #category : #'profiling primitives' }
TPharoCogit >> executePrimitiveGenerator: aPrimitiveGenerator [

	<var: #aPrimitiveGenerator declareC: 'sqInt (*aPrimitiveGenerator)(void)'>
	^ objectRepresentation perform: aPrimitiveGenerator
]

{ #category : #'bytecode generators' }
TPharoCogit >> genCallMustBeBooleanFor: boolean [
	"Call ceSendMustBeBooleanTo: via the relevant trampoline."
	^self CallRT: (boolean = self objectMemory falseObject
					ifTrue: [ceSendMustBeBooleanAddFalseTrampoline]
					ifFalse: [ceSendMustBeBooleanAddTrueTrampoline])
]

{ #category : #'primitive generators' }
TPharoCogit >> genDoubleFailIfZeroArgRcvr: rcvrReg arg: argReg [
	<option: #DPFPReg0>
	<var: 'rcvrReg' type: #int>
	<var: 'argReg' type: #int>
	<returnTypeC: #'AbstractInstruction *'>
	self MoveCq: 0 R: TempReg.
	self ConvertR: TempReg Rd: DPFPReg2.
	self CmpRd: DPFPReg2 Rd: argReg.
	^self JumpFPEqual: 0
]

{ #category : #'compile abstract instructions' }
TPharoCogit >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch updatingSlot: index in: objReg [
	"Make sure that the oop in reg is not forwarded, updating the slot in objReg with the value."

	<var: #ok type: #'AbstractInstruction *'>
	<var: #imm type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	| loop imm ok |
	self assert: (reg ~= scratch and: [ objReg ~= scratch ]).
	"Open-code
		self genEnsureOopInRegNotForwarded: reg
			scratchReg: scratch
			updatingMw: index * objectMemory wordSize + objectMemory baseHeaderSize
			r: objReg.
	 to avoid calling the store check unless the receiver is forwarded."
	loop := self Label.
	imm := self genJumpImmediate: reg.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask
			- objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero: 0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self
		MoveR: reg
		Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		r: objReg.

	"Check that we're meeting the contract of ceStoreCheckContextReceiverTrampoline."
	self assert: (reg = Arg0Reg and: [
			 scratch = TempReg and: [ objReg = ReceiverResultReg ] ]).
	self CallRT:
		objectRepresentation ceStoreCheckContextReceiverTrampoline.

	self Jump: loop.
	ok jmpTarget: (imm jmpTarget: self Label).
	^ 0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtJumpIfFalse [
	"244		11110100	i i i i i i i i	Pop and Jump 0n False i i i i i i i i (+ Extend B * 256, where Extend B >= 0)"
	| distance target |
	distance := byte1 + (extB << 8).
	self assert: distance = (self v4: (self generatorAt: byte0)
								LongForward: bytecodePC
								Branch: (extA ~= 0 ifTrue: [1] ifFalse: [0]) + (extB ~= 0 ifTrue: [1] ifFalse: [0])
								Distance: methodObj).
	extB := 0.
	numExtB := 0.
	target := distance + 2 + bytecodePC.
	^self genJumpIf: objectMemory falseObject to: target
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtJumpIfTrue [
	"243		11110011	i i i i i i i i	Pop and Jump 0n True i i i i i i i i (+ Extend B * 256, where Extend B >= 0)"
	| distance target |
	distance := byte1 + (extB << 8).
	self assert: distance = (self v4: (self generatorAt: byte0)
								LongForward: bytecodePC
								Branch: (extA ~= 0 ifTrue: [1] ifFalse: [0]) + (extB ~= 0 ifTrue: [1] ifFalse: [0])
								Distance: methodObj).
	extB := 0.
	numExtB := 0.
	target := distance + 2 + bytecodePC.
	^self genJumpIf: objectMemory trueObject to: target
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtNopBytecode [
	"SistaV1:		 91		01011011'		Nop"
	extA := numExtB := extB := 0.
	^0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushCharacterBytecode [
	"SistaV1:		233		11101001	iiiiiiii		Push Character #iiiiiiii (+ Extend B * 256)"
	| value |
	value := byte1 + (extB << 8).
	extB := 0.
	numExtB := 0.
	^self genPushLiteral: (objectMemory characterObjectOf: value)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushIntegerBytecode [
	"NewsqueakV4:	229		11100101	iiiiiiii	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)
	SistaV1:		232		11101000	iiiiiiii	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| value |
	value := byte1 + (extB << 8).
	extB := 0.
	numExtB := 0.
	^self genPushLiteral: (objectMemory integerObjectOf: value)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushLiteralBytecode [
	"228		11100100	i i i i i i i i	Push Literal #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genPushLiteralIndex: index
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushLiteralVariableBytecode [
	"227		11100011	i i i i i i i i	Push Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genPushLiteralVariable: index
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushPseudoVariable [
	"SistaV1: *	82			01010010			Push thisContext, (then Extend B = 1 => push thisProcess)"
	| ext |
	ext := extB.
	extB := 0.
	numExtB := 0.
	ext caseOf: {
		[0]	->	[^self genPushActiveContextBytecode].
		}
		otherwise:
			[^self unknownBytecode].
	^0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtPushReceiverVariableBytecode [
	"226		11100010	i i i i i i i i	Push Receiver Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isReadMediatedContextInstVarIndex: index)
		ifTrue: [self genPushMaybeContextReceiverVariable: index]
		ifFalse: [self genPushReceiverVariable: index]
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtSendBytecode [
	"238		11101110	i i i i i j j j	Send Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
	| litIndex nArgs |
	litIndex := (byte1 >> 3) + (extA << 5).
	extA := 0.
	nArgs := (byte1 bitAnd: 7) + (extB << 3).
	extB := 0.
	numExtB := 0.
	^self genSend: litIndex numArgs: nArgs
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtSendSuperBytecode [
	"239		11101111	i i i i i j j j	Send To Superclass Literal Selector #iiiii (+ Extend A * 32) with jjj (+ Extend B * 8) Arguments"
	| isDirected litIndex nArgs |
	(isDirected := extB >= 64) ifTrue:
		[extB := extB bitAnd: 63].
	litIndex := (byte1 >> 3) + (extA << 5).
	extA := 0.
	nArgs := (byte1 bitAnd: 7) + (extB << 3).
	extB := 0.
	numExtB := 0.
	^isDirected
		ifTrue: [self genSendDirectedSuper: litIndex numArgs: nArgs]
		ifFalse: [self genSendSuper: litIndex numArgs: nArgs]
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtStoreAndPopLiteralVariableBytecode [
	"236		11101100	i i i i i i i i	Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genStorePop: true LiteralVariable: index
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtStoreAndPopReceiverVariableBytecode [
	"235		11101011	i i i i i i i i	Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isWriteMediatedContextInstVarIndex: index)
		ifTrue: [self genStorePop: true MaybeContextReceiverVariable: index]
		ifFalse: [self genStorePop: true ReceiverVariable: index]
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtStoreLiteralVariableBytecode [
	"233		11101001	i i i i i i i i	Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genStorePop: false LiteralVariable: index
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtStoreReceiverVariableBytecode [
	"232		11101000	i i i i i i i i	Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isWriteMediatedContextInstVarIndex: index)
		ifTrue: [self genStorePop: false MaybeContextReceiverVariable: index]
		ifFalse: [self genStorePop: false ReceiverVariable: index]
]

{ #category : #'bytecode generators' }
TPharoCogit >> genExtUnconditionalJump [
	"242		11110010	i i i i i i i i	Jump i i i i i i i i (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| distance target |
	distance := byte1 + (extB << 8).
	self assert: distance = (self v4: (self generatorAt: byte0)
								Long: bytecodePC
								Branch: (extA ~= 0 ifTrue: [1] ifFalse: [0]) + (extB ~= 0 ifTrue: [1] ifFalse: [0])
								Distance: methodObj).
	extB := 0.
	numExtB := 0.
	target := distance + 2 + bytecodePC.
	distance < 0 ifTrue:
		[^self genJumpBackTo: target].
	self genJumpTo: target.
	"The bytecode must be mapped since it can be either forward or backward, and
	  backwards branches must be mapped. So if forward, we need to map."
	self annotateBytecode: self lastOpcode.
	^0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genGetClassObjectOf: instReg into: destReg scratchReg: scratchReg instRegIsReceiver: instRegIsReceiver [
	"Fetch the instance's class into destReg.  If the instance is not the receiver and is forwarded, follow forwarding."

	<var: #jumpIsImm type: #'AbstractInstruction *'>
	<var: #jumpNotForwarded type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	| jumpIsImm jumpNotForwarded loop |
	(instReg = destReg or: [
		 instReg = scratchReg or: [ destReg = scratchReg ] ]) ifTrue: [
		^ BadRegisterSet ].
	loop := self MoveR: instReg R: scratchReg.
	self AndCq: objectMemory tagMask R: scratchReg.
	jumpIsImm := self JumpNonZero: 0.
	self flag: #endianness.
	"Get least significant half of header word in destReg"
	self MoveMw: 0 r: instReg R: scratchReg.
	"mask off class index"
	self AndCq: objectMemory classIndexMask R: scratchReg.
	instRegIsReceiver ifFalse: [ "if it is forwarded..."
		self
			CmpCq: objectMemory isForwardedObjectClassIndexPun
			R: scratchReg.
		jumpNotForwarded := self JumpNonZero: 0.
		"...follow the forwarding pointer and loop to fetch its classIndex"
		self MoveMw: objectMemory baseHeaderSize r: instReg R: instReg.
		self Jump: loop.
		jumpNotForwarded jmpTarget: self Label ].
	jumpIsImm jmpTarget: (self MoveR: scratchReg R: destReg).
	scratchReg = TempReg
		ifTrue: [
			self PushR: instReg.
			self
				genGetClassObjectOfClassIndex: destReg
				into: instReg
				scratchReg: TempReg.
			self MoveR: instReg R: destReg.
			self PopR: instReg ]
		ifFalse: [
			self
				genGetClassObjectOfClassIndex: destReg
				into: scratchReg
				scratchReg: TempReg.
			self MoveR: scratchReg R: destReg ].
	^ 0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genGetClassObjectOfClassIndex: instReg into: destReg scratchReg: scratchReg [
	"Fetch the class object whose index is in instReg into destReg.
	 It is non-obvious, but the Cogit assumes loading a class does not involve
	 a runtime call, so do not call classAtIndex:"

	self assert: instReg ~= destReg.
	self assert: instReg ~= scratchReg.
	self assert: destReg ~= scratchReg.
	self
		MoveR: instReg R: scratchReg;
		LogicalShiftRightCq: objectMemory classTableMajorIndexShift
		R: scratchReg;
		LogicalShiftLeftCq: objectMemory shiftForWord R: scratchReg.
	self assert:
		(self shouldAnnotateObjectReference: objectMemory classTableRootObj)
			not.
	(self backEnd isWithinMwOffsetRange:
		 objectMemory classTableRootObj + objectMemory baseHeaderSize)
		ifTrue: [
			self
				MoveMw:
				objectMemory classTableRootObj + objectMemory baseHeaderSize
				r: scratchReg
				R: destReg ]
		ifFalse: [
			self
				AddCq: objectMemory classTableRootObj R: scratchReg;
				MoveMw: objectMemory baseHeaderSize r: scratchReg R: destReg ].
	self
		MoveR: instReg R: scratchReg;
		AndCq: objectMemory classTableMinorIndexMask R: scratchReg;
		AddCq: objectMemory baseHeaderSize >> objectMemory shiftForWord
		R: scratchReg;
		MoveXwr: scratchReg R: destReg R: destReg.
	^ 0
]

{ #category : #'compile abstract instructions' }
TPharoCogit >> genGetInlineCacheClassTagFrom: receiverRegister into: destinationRegister forEntry: isEntry [

	<doNotGenerate>
	objectRepresentation
		genGetInlineCacheClassTagFrom: receiverRegister
		into: destinationRegister
		forEntry: isEntry
]

{ #category : #'compile abstract instructions' }
TPharoCogit >> genJumpBaseHeaderImmutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"

	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	self TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpNonZero: 0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genLongPushTemporaryVariableBytecode [
	"230		11100110	i i i i i i i i	Push Temporary Variable #iiiiiiii"
	^self genPushTemporaryVariable: byte1
]

{ #category : #'bytecode generators' }
TPharoCogit >> genLongStoreAndPopTemporaryVariableBytecode [
	"237		11101101	i i i i i i i i	Pop and Store Temporary Variable #iiiiiiii"
	^self genStorePop: true TemporaryVariable: byte1
]

{ #category : #'bytecode generators' }
TPharoCogit >> genLongStoreTemporaryVariableBytecode [
	"234		11101010	i i i i i i i i	Store Temporary Variable #iiiiiiii"
	^self genStorePop: false TemporaryVariable: byte1
]

{ #category : #'primitive generators' }
TPharoCogit >> genLookupForPerformNumArgs: numArgs [
	"Compile the code for a probe of the first-level method cache for a perform primtiive.
	 The selector is assumed to be in Arg0Reg.  Defer to adjustArgumentsForPerform: to
	 adjust the arguments before the jump to the method."
	| jumpSelectorMiss jumpClassMiss jumpInterpret itsAHit cacheBaseReg |
	<var: #jumpSelectorMiss type: #'AbstractInstruction *'>
	<var: #jumpClassMiss type: #'AbstractInstruction *'>
	<var: #jumpInterpret type: #'AbstractInstruction *'>
	<var: #itsAHit type: #'AbstractInstruction *'>

	"N.B.  Can't assume TempReg already contains the tag because a method can
	 of course be invoked via the unchecked entry-point, e.g. as does perform:."
	self genGetInlineCacheClassTagFrom: ReceiverResultReg into: SendNumArgsReg forEntry: false.

	self flag: #lookupInMethodCacheSel:classTag:. "so this method shows up as a sender of lookupInMethodCacheSel:class:"

	cacheBaseReg := NoReg.
	(backEnd isWithinMwOffsetRange: coInterpreter methodCacheAddress) ifFalse:
		[self MoveCq: coInterpreter methodCacheAddress R: (cacheBaseReg := Extra0Reg)].

	"Do first of three probes.  See CoInterpreter>>lookupInMethodCacheSel:classTag:"
	jumpSelectorMiss := self compilePerformMethodCacheProbeFor: Arg0Reg withShift: 0 baseRegOrNone: cacheBaseReg.
	jumpClassMiss := self JumpNonZero: 0.

	"Fetch the method, and check if it is cogged."
	itsAHit := self MoveMw: (cacheBaseReg = NoReg
								ifTrue: [coInterpreter methodCacheAddress asUnsignedInteger + (MethodCacheMethod << objectMemory shiftForWord)]
								ifFalse: [MethodCacheMethod << objectMemory shiftForWord])
					r: ClassReg
					R: SendNumArgsReg.
	"If the method is not compiled fall back on the interpreter primitive."
	self genLoadSlot: HeaderIndex sourceReg: SendNumArgsReg destReg: ClassReg.
	jumpInterpret := self genJumpImmediate: ClassReg.
	"Adjust arguments and jump to the method's unchecked entry-point."
	self AddCq: cmNoCheckEntryOffset R: ClassReg.
	self adjustArgumentsForPerform: numArgs.
	self JumpR: ClassReg.

	"First probe missed.  Do second of three probes.  Shift hash right one and retry."
	jumpSelectorMiss jmpTarget: (jumpClassMiss jmpTarget: self Label).
	jumpSelectorMiss := self compilePerformMethodCacheProbeFor: Arg0Reg withShift: 1 baseRegOrNone: cacheBaseReg.
	self JumpZero: itsAHit.

	"Second probe missed.  Do last probe.  Shift hash right two and retry."
	jumpSelectorMiss jmpTarget: self Label.
	jumpSelectorMiss := self compilePerformMethodCacheProbeFor: Arg0Reg withShift: 2 baseRegOrNone: cacheBaseReg.
	self JumpZero: itsAHit.

	"Last probe missed.  Caller will generate the call to fall back on the interpreter primitive."
	jumpSelectorMiss jmpTarget:
	(jumpInterpret jmpTarget: self Label).
	^0
]

{ #category : #'constant support' }
TPharoCogit >> genMoveFalseR: reg [
	<inline: true>
	^ self genMoveConstant: objectMemory falseObject R: reg
	
]

{ #category : #'constant support' }
TPharoCogit >> genMoveTrueR: reg [
	<inline: true>
	^ self genMoveConstant: objectMemory trueObject R: reg
	
]

{ #category : #initialization }
TPharoCogit >> genMustBeBooleanTrampolineCalled: trampolineName [
	<var: #trampolineName type: #'char *'>
	<inline: false>
	self zeroOpcodeIndex.
	^self genTrampolineFor: #ceSendMustBeBoolean:
		called: trampolineName
		numArgs: 1
		arg: TempReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true
]

{ #category : #initialization }
TPharoCogit >> genMustBeBooleanTrampolineFor: boolean called: trampolineName [
	<var: #trampolineName type: #'char *'>
	<inline: false>
	self zeroOpcodeIndex.
	"If the objectRepresentation does want true & false to be mobile then we need to record these addresses."
	self assert: (self shouldAnnotateObjectReference: boolean) not.
	self AddCq: boolean R: TempReg.
	^self genTrampolineFor: #ceSendMustBeBoolean:
		called: trampolineName
		numArgs: 1
		arg: TempReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true
]

{ #category : #'bytecode generators' }
TPharoCogit >> genNewArrayOfSize: size initialized: initialized [
	
	<doNotGenerate>
	^ objectRepresentation genNewArrayOfSize: size initialized: initialized
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushConstantFalseBytecode [
	^self genPushLiteral: self objectMemory falseObject
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushConstantNilBytecode [
	^self genPushLiteral: self objectMemory nilObject
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushConstantOneBytecode [
	"79			01001111		Push 1"
	^self genPushLiteral: (self objectMemory integerObjectOf: 1)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushConstantTrueBytecode [
	^self genPushLiteral: self objectMemory trueObject
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushConstantZeroBytecode [
	"78			01001110		Push 0"
	^self genPushLiteral: (self objectMemory integerObjectOf: 0)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushLiteralConstantBytecode [
	^self genPushLiteralIndex: (self byte0 bitAnd: 31)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushLiteralVariable16CasesBytecode [
	"16-31		0001 i i i i		Push Literal Variable #iiii"
	^self genPushLiteralVariable: (self byte0 bitAnd: 15)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushLiteralVariableBytecode [
	^self genPushLiteralVariable: (self byte0 bitAnd: 31)
]

{ #category : #'bytecode generator support' }
TPharoCogit >> genPushMaybeContextReceiverVariable: slotIndex [ 
	<inline: false>
	| jmpSingle jmpDone |
	<var: #jmpSingle type: #'AbstractInstruction *'>
	<var: #jmpDone type: #'AbstractInstruction *'>
	self assert: needsFrame.
	"See CoInterpreter>>contextInstructionPointer:frame: for an explanation
	 of the instruction pointer slot handling."
	slotIndex = InstructionPointerIndex ifTrue:
		[self putSelfInReceiverResultReg.
		 self MoveCq: slotIndex R: SendNumArgsReg.
		 self CallRT: ceFetchContextInstVarTrampoline.
		 self PushR: SendNumArgsReg.
		 ^0].
	self MoveMw: FoxMFReceiver r: FPReg R: ReceiverResultReg.
	self
		genLoadSlot: SenderIndex
		sourceReg: ReceiverResultReg
		destReg: TempReg.
	jmpSingle := self genJumpNotSmallInteger: TempReg.
	self MoveCq: slotIndex R: SendNumArgsReg.
	self CallRT: ceFetchContextInstVarTrampoline.
	jmpDone := self Jump: 0.
	jmpSingle jmpTarget: self Label.
	self
		genLoadSlot: slotIndex
		sourceReg: ReceiverResultReg
		destReg: SendNumArgsReg.
	jmpDone jmpTarget: (self PushR: SendNumArgsReg).
	^0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushReceiverVariableBytecode [
	^self genPushReceiverVariable: (self byte0 bitAnd: 15)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genPushTemporaryVariableBytecode [
	^self genPushTemporaryVariable: (self byte0 bitAnd: 15)
]

{ #category : #'primitive generators' }
TPharoCogit >> genQuickReturnConst [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	| constant |
	constant := coInterpreter quickPrimitiveConstantFor: primitiveIndex.
	self genMoveConstant: constant R: ReceiverResultReg.
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'primitive generators' }
TPharoCogit >> genQuickReturnInstVar [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	| index |
	index := coInterpreter quickPrimitiveInstVarIndexFor: primitiveIndex.
	self genLoadSlot: index sourceReg: ReceiverResultReg destReg: ReceiverResultReg.
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'primitive generators' }
TPharoCogit >> genQuickReturnSelf [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'bytecode generators' }
TPharoCogit >> genReturnFalse [
	self genMoveFalseR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
TPharoCogit >> genReturnNil [
	self genMoveNilR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
TPharoCogit >> genReturnNilFromBlock [
	self assert: inBlock > 0.
	self genMoveNilR: ReceiverResultReg.
	^self genBlockReturn
]

{ #category : #'bytecode generators' }
TPharoCogit >> genReturnTrue [
	self genMoveTrueR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSendLiteralSelector0ArgsBytecode [
	^self genSend: (byte0 bitAnd: 15) numArgs: 0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSendLiteralSelector1ArgBytecode [
	^self genSend: (byte0 bitAnd: 15) numArgs: 1
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSendLiteralSelector2ArgsBytecode [

	^self genSend: (byte0 bitAnd: 15) numArgs: 2
]

{ #category : #'bytecode generators' }
TPharoCogit >> genShortJumpIfFalse [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpIf: objectMemory falseObject to: target
]

{ #category : #'bytecode generators' }
TPharoCogit >> genShortJumpIfTrue [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpIf: objectMemory trueObject to: target
]

{ #category : #'bytecode generators' }
TPharoCogit >> genShortUnconditionalJump [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpTo: target
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSpecialSelectorEqualsEquals [
	^ self genInlinedIdenticalOrNotIf: false
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSpecialSelectorNotEqualsEquals [
	^ self genInlinedIdenticalOrNotIf: true
]

{ #category : #'bytecode generators' }
TPharoCogit >> genSpecialSelectorSend [
	| index numArgs |
	index := byte0 - self firstSpecialSelectorBytecodeOffset.
	numArgs := coInterpreter specialSelectorNumArgs: index.
	^self genSend: index negated - 1 numArgs: numArgs
]

{ #category : #'bytecode generators' }
TPharoCogit >> genStoreAndPopReceiverVariableBytecode [
	^self genStorePop: true ReceiverVariable: (byte0 bitAnd: 7)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genStoreAndPopRemoteTempLongBytecode [
	^self genStorePop: true RemoteTemp: byte1 At: byte2
]

{ #category : #'bytecode generators' }
TPharoCogit >> genStoreAndPopTemporaryVariableBytecode [
	^self genStorePop: true TemporaryVariable: (byte0 bitAnd: 7)
]

{ #category : #'bytecode generators' }
TPharoCogit >> genStoreRemoteTempLongBytecode [
	^self genStorePop: false RemoteTemp: byte1 At: byte2
]

{ #category : #'bytecode generators' }
TPharoCogit >> genStoreSourceReg: sourceReg slotIndex: index intoNewObjectInDestReg: destReg [
	"This method is used for unchecked stores in objects after their creation (typically, inlined creation of Array, closures and some temp vectors). 
	Currently there is no need to do the immutability check here"

	self
		MoveR: sourceReg
		Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		r: destReg.
	^ 0
]

{ #category : #'bytecode generators' }
TPharoCogit >> genUnconditionalTrapBytecode [
	"SistaV1: *	217		Trap"
	^EncounteredUnknownBytecode
]

{ #category : #initialization }
TPharoCogit >> generateObjectRepresentationTrampolines [

	<doNotGenerate>
	objectRepresentation generateObjectRepresentationTrampolines
]

{ #category : #accessing }
TPharoCogit >> generateRunTimeTrampolines [

	super generateRunTimeTrampolines.

	"Neither of the context inst var access trampolines save registers.  Their operation could cause
	 arbitrary update of stack frames, so the assumption is that callers flush the stack before calling
	 the context inst var access trampolines, and that everything except the result is dead afterwards."
	ceFetchContextInstVarTrampoline := self
		                                   genTrampolineFor:
		                                   #ceContext:instVar:
		                                   called:
		                                   'ceFetchContextInstVarTrampoline'
		                                   arg: ReceiverResultReg
		                                   arg: SendNumArgsReg
		                                   result: SendNumArgsReg.
	ceStoreContextInstVarTrampoline := self
		                                   genTrampolineFor:
		                                   #ceContext:instVar:value:
		                                   called:
		                                   'ceStoreContextInstVarTrampoline'
		                                   arg: ReceiverResultReg
		                                   arg: SendNumArgsReg
		                                   arg: ClassReg
		                                   result: ReceiverResultReg. "to keep ReceiverResultReg live."

	ceSendMustBeBooleanTrampoline := self
		                                 genMustBeBooleanTrampolineCalled:
		                                 'ceSendMustBeBooleanTrampoline'.
	ceSendMustBeBooleanAddFalseTrampoline := self
		                                         genMustBeBooleanTrampolineFor:
		                                         objectMemory falseObject
		                                         called:
		                                         'ceSendMustBeBooleanAddFalseTrampoline'.
	ceSendMustBeBooleanAddTrueTrampoline := self
		                                        genMustBeBooleanTrampolineFor:
		                                        objectMemory trueObject
		                                        called:
		                                        'ceSendMustBeBooleanAddTrueTrampoline'.

	ceCannotResumeTrampoline := self
		                            genTrampolineFor: #ceCannotResume
		                            called: 'ceCannotResumeTrampoline'
]

{ #category : #'garbage collection' }
TPharoCogit >> markAndTraceCacheTagLiteral: aCacheTag in: aMethod atpc: mcpc [

	<doNotGenerate>
	objectRepresentation
		markAndTraceCacheTagLiteral: aCacheTag
		in: aMethod
		atpc: mcpc
]

{ #category : #initialization }
TPharoCogit >> maybeGenerateSelectorIndexDereferenceRoutine [

	<doNotGenerate>
	objectRepresentation maybeGenerateSelectorIndexDereferenceRoutine
]

{ #category : #'span functions' }
TPharoCogit >> parseV4Exts: nExts priorTo: bcpc in: aMethodObj into: aBinaryBlock [
	"224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)
	 225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)"
	| extAValue extBValue pc byte extByte |

	extAValue := extBValue := 0.
	pc := bcpc - nExts - nExts.
	[pc < bcpc] whileTrue:
		[byte := objectMemory fetchByte: pc ofObject: aMethodObj.
		 pc := pc + 1.
		 extByte := objectMemory fetchByte: pc ofObject: aMethodObj.
		 pc := pc + 1.
		 self assert: (byte = 224 or: [byte = 225]).
		 byte = 224
			ifTrue:
				[extAValue := (extAValue bitShift: 8) + extByte]
			ifFalse:
				[extBValue := (extBValue = 0 and: [extByte > 127])
							ifTrue: [extByte - 256]
							ifFalse: [(extBValue bitShift: 8) + extByte]]].
	aBinaryBlock value: extAValue value: extBValue
]

{ #category : #initialization }
TPharoCogit >> setInterpreter: anInterpreter [

	<doNotGenerate>
	super setInterpreter: anInterpreter.
	objectRepresentation := self objectRepresentationClass
		                        forCogit: self
		                        methodZone: self methodZone
]

{ #category : #'span functions' }
TPharoCogit >> v3: unusedButKeptForPolymorphism ShortForward: pc Branch: unusedButKeptForPolymorphism2 Distance: aMethodObj [
	
	^ self distanceForShortForwardBranch: pc inMethod: aMethodObj
]

{ #category : #'span functions' }
TPharoCogit >> v4: descriptor Long: pc Branch: nExts Distance: aMethodObj [
	"242		11110010	i i i i i i i i	Jump i i i i i i i i (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| extBValue |
	self assert: nExts >= 0.
	self parseV4Exts: nExts priorTo: pc in: aMethodObj into: [:ea :eb| extBValue := eb].
	^(objectMemory fetchByte: pc + 1 ofObject: aMethodObj)
	+ (extBValue << 8)
]

{ #category : #'span functions' }
TPharoCogit >> v4: descriptor LongForward: pc Branch: nExts Distance: aMethodObj [
	"242		11110010	i i i i i i i i	Jump i i i i i i i i (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	"243		11110011	i i i i i i i i	Pop and Jump 0n True i i i i i i i i (+ Extend A * 256)"
	"244		11110100	i i i i i i i i	Pop and Jump 0n False i i i i i i i i (+ Extend A * 256)"
	<var: #descriptor type: #'BytecodeDescriptor *'>
	| extBValue |
	self assert: nExts >= 0.
	self parseV4Exts: nExts priorTo: pc in: aMethodObj into: [:ea :eb| extBValue := eb].
	^(objectMemory fetchByte: pc + 1 ofObject: aMethodObj)
	+ (extBValue << 8)
]
