Class {
	#name : #PharoSimpleCogit,
	#superclass : #SimpleStackBasedCogit,
	#traits : 'TPharoCogit',
	#classTraits : 'TPharoCogit classTrait',
	#category : #'VMMaker-JIT'
}

{ #category : #accessing }
PharoSimpleCogit >> ceCannotResumePC [
	<api>
	<cmacro: '() ((usqInt)ceCannotResumeTrampoline)'>
	<returnTypeC: #usqInt> "for Slang"
	^ceCannotResumeTrampoline
]

{ #category : #accessing }
PharoSimpleCogit >> ceSendMustBeBooleanAddFalseTrampoline: anInteger [

	<doNotGenerate>

	ceSendMustBeBooleanAddFalseTrampoline := anInteger
]

{ #category : #accessing }
PharoSimpleCogit >> ceSendMustBeBooleanAddTrueTrampoline: anInteger [ 

	<doNotGenerate>
	
	ceSendMustBeBooleanAddTrueTrampoline :=	anInteger

]

{ #category : #initialization }
PharoSimpleCogit >> ceSendMustBeBooleanTrampoline: aTrampolineAddress [

	ceSendMustBeBooleanTrampoline := aTrampolineAddress
]

{ #category : #'span functions' }
PharoSimpleCogit >> distanceForShortForwardBranch: pc inMethod: aMethodObj [
	"N.B.  This serves for both BlueBook/V3 and V4 short jumps."
	<var: #descriptor type: #'BytecodeDescriptor *'>
	<inline: true>
	
	^((objectMemory fetchByte: pc ofObject: aMethodObj) bitAnd: 7) + 1
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> doubleExtendedDoAnythingBytecode [
	"Replaces the Blue Book double-extended send [132], in which the first byte was wasted on 8 bits of argument count. 
	Here we use 3 bits for the operation sub-type (opType),  and the remaining 5 bits for argument count where needed. 
	The last byte give access to 256 instVars or literals. 
	See also secondExtendedSendBytecode"
	| opType |
	opType := byte1 >> 5.
	opType = 0 ifTrue:
		[^self genSend: byte2 numArgs: (byte1 bitAnd: 31)].
	opType = 1 ifTrue:
		[^self genSendSuper: byte2 numArgs: (byte1 bitAnd: 31)].
	"We need a map entry for this bytecode for correct parsing.
	 The sends will get an IsSend entry anyway.  The other cases need a fake one."
	opType caseOf: {
			[2]	->	[(coInterpreter isReadMediatedContextInstVarIndex: byte2)
						ifTrue: [self genPushMaybeContextReceiverVariable: byte2]
						ifFalse: [self genPushReceiverVariable: byte2]].
			[3]	->	[self genPushLiteralIndex: byte2].
			[4]	->	[self genPushLiteralVariable: byte2].
			[7]	->	[self genStorePop: false LiteralVariable: byte2.
					 self cppIf: IMMUTABILITY ifTrue: ["genStorePop:LiteralVariable: annotates; don't annotate twice" ^0]] }
		otherwise: "5 & 6"
			[(coInterpreter isWriteMediatedContextInstVarIndex: byte2)
				ifTrue: [self genStorePop: opType = 6 MaybeContextReceiverVariable: byte2]
				ifFalse: [self genStorePop: opType = 6 ReceiverVariable: byte2].
			 self cppIf: IMMUTABILITY ifTrue: ["genStorePop:...ReceiverVariable: annotate; don't annotate twice" ^0]].
	"We need a map entry for this bytecode for correct parsing (if the method builds a frame)."
	needsFrame ifTrue:
		[self annotateBytecode: self Label].
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> duplicateTopBytecode [
	self MoveMw: 0 r: SPReg R: TempReg.
	self PushR: TempReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> extendedPushBytecode [
	| variableType variableIndex |
	variableType := (byte1 >> 6) bitAnd: 16r3.
	variableIndex := byte1 bitAnd: 16r3F.
	variableType = 0 ifTrue:
		[^self genPushReceiverVariable: variableIndex].
	variableType = 1 ifTrue:
		[^self genPushTemporaryVariable: variableIndex].
	variableType = 2 ifTrue:
		[^self genPushLiteralIndex: variableIndex].
	^self genPushLiteralVariable: variableIndex
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> extendedStoreAndPopBytecode [
	| variableType variableIndex |
	variableType := byte1 >> 6 bitAnd: 3.
	variableIndex := byte1 bitAnd: 63.
	variableType = 0 ifTrue:
		[^self genStorePop: true ReceiverVariable: variableIndex].
	variableType = 1 ifTrue:
		[self genStorePop: true TemporaryVariable: variableIndex.
		"needs a fake map entry if Immutability is ON..."
		self cppIf: IMMUTABILITY ifTrue: [ self annotateBytecode: self Label. ].
		^ 0].
	variableType = 3 ifTrue:
		[^self genStorePop: true LiteralVariable: variableIndex].
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> extendedStoreBytecode [
	| variableType variableIndex |
	variableType := byte1 >> 6 bitAnd: 3.
	variableIndex := byte1 bitAnd: 63.
	variableType = 0 ifTrue:
		[^self genStorePop: false ReceiverVariable: variableIndex].
	variableType = 1 ifTrue:
		[self genStorePop: false TemporaryVariable: variableIndex.
		"needs a fake map entry if Immutability is ON..."
		self cppIf: IMMUTABILITY ifTrue: [ self annotateBytecode: self Label. ].
		^ 0].
	variableType = 3 ifTrue:
		[^self genStorePop: false LiteralVariable: variableIndex].
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genCallMappedInlinedPrimitive [
	"Implemented with SistaCogit only"
	^EncounteredUnknownBytecode
]

{ #category : #'trampoline support' }
PharoSimpleCogit >> genCallMustBeBooleanFor: boolean [
	"Call ceSendMustBeBooleanTo: via the relevant trampoline."
	^self CallRT: (boolean = objectMemory falseObject
					ifTrue: [ceSendMustBeBooleanAddFalseTrampoline]
					ifFalse: [ceSendMustBeBooleanAddTrueTrampoline])
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genCallPrimitiveBytecode [
	"V3PlusClosures:	139 10001011	iiiiiiii   jjjjjjjj  Call Primitive #iiiiiiii + (jjjjjjjj * 256)
	 NewsqueakV4:		249 11111001	iiiiiiii   jjjjjjjj  Call Primitive #iiiiiiii + (jjjjjjjj * 256)
	 SistaV1:			248 11111000 iiiiiiii mjjjjjjj  Call Primitive #iiiiiiii + ( jjjjjjj * 256)
							m=1 means inlined primitive, no hard return after execution."
	(bytecodePC = initialPC and: [byte2 < 128]) ifFalse: [^EncounteredUnknownBytecode].
	^0
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genDoubleFailIfZeroArgRcvr: rcvrReg arg: argReg [
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
PharoSimpleCogit >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch updatingSlot: index in: objReg [
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
PharoSimpleCogit >> genExtJumpIfFalse [
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
PharoSimpleCogit >> genExtJumpIfTrue [
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
PharoSimpleCogit >> genExtNopBytecode [
	"SistaV1:		 91		01011011'		Nop"
	extA := numExtB := extB := 0.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushCharacterBytecode [
	"SistaV1:		233		11101001	iiiiiiii		Push Character #iiiiiiii (+ Extend B * 256)"
	| value |
	value := byte1 + (extB << 8).
	extB := 0.
	numExtB := 0.
	^self genPushLiteral: (objectMemory characterObjectOf: value)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushFullClosureBytecode [
	"Full Block creation compilation. The block's actual code will be compiled separatedly."
	"*	255		11111111	xxxxxxxx	siyyyyyy	push Closure Compiled block literal index xxxxxxxx (+ Extend A * 256) numCopied yyyyyy receiverOnStack: s = 1 ignoreOuterContext: i = 1"
	| numCopied ignoreContext receiverIsOnStack compiledBlock |
	self assert: needsFrame.
	compiledBlock := self getLiteral: byte1 + (extA << 8).
	extA := 0.
	numCopied := byte2 bitAnd: 1<< 6 - 1.
	receiverIsOnStack := byte2 anyMask: 1 << 7.
	ignoreContext := byte2 anyMask: 1 << 6.
	objectRepresentation
		genCreateFullClosure: compiledBlock
		numArgs: (coInterpreter argumentCountOf: compiledBlock)
		numCopied: numCopied
		ignoreContext: ignoreContext
		contextNumArgs: methodOrBlockNumArgs
		large: (coInterpreter methodNeedsLargeContext: methodObj)
		inBlock: inBlock.
	"Closure in ReceiverResultReg"
	1 to: numCopied do:
		[:i|
		self
			PopR: TempReg;
			MoveR: TempReg
				Mw: numCopied - i + FullClosureFirstCopiedValueIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize
					r: ReceiverResultReg].
	receiverIsOnStack
		ifTrue: [self PopR: TempReg]
		ifFalse: [ self MoveMw: FoxMFReceiver r: FPReg R: TempReg].
	self
		MoveR: TempReg
		Mw: FullClosureReceiverIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize
		r: ReceiverResultReg.
	self PushR: ReceiverResultReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushIntegerBytecode [
	"NewsqueakV4:	229		11100101	iiiiiiii	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)
	SistaV1:		232		11101000	iiiiiiii	Push Integer #iiiiiiii (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| value |
	value := byte1 + (extB << 8).
	extB := 0.
	numExtB := 0.
	^self genPushLiteral: (objectMemory integerObjectOf: value)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushLiteralBytecode [
	"228		11100100	i i i i i i i i	Push Literal #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genPushLiteralIndex: index
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushLiteralVariableBytecode [
	"227		11100011	i i i i i i i i	Push Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genPushLiteralVariable: index
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushPseudoVariable [
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
PharoSimpleCogit >> genExtPushReceiverVariableBytecode [
	"226		11100010	i i i i i i i i	Push Receiver Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isReadMediatedContextInstVarIndex: index)
		ifTrue: [self genPushMaybeContextReceiverVariable: index]
		ifFalse: [self genPushReceiverVariable: index]
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtPushRemoteTempOrInstVarLongBytecode [
	| index |
	^ (byte2 noMask: coInterpreter remoteIsInstVarAccess)
		ifTrue: [ self genPushRemoteTempLongBytecode ]
		ifFalse: 
			[ index := byte1 + (extA << 8).
			extA := 0.
			extB := 0. "don't use flags in the simple cogit"
			numExtB := 0.
			(coInterpreter isReadMediatedContextInstVarIndex: index)
				ifTrue: [self 
							genPushMaybeContextRemoteInstVar: index 
							inObjectAt: byte2 - coInterpreter remoteIsInstVarAccess]
				ifFalse: [self 
							genPushRemoteInstVar: index 
							inObjectAt: byte2 - coInterpreter remoteIsInstVarAccess]]
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtReturnTopFromBlock [
	"218		11011010		Return Stack Top From Block [* return from enclosing block N, N = Extend A]
	 If extA is zero, return to the caller of the current block activation.
	 If extA is non-zero return to the caller of the Nth enclosing block activation."
	extA = 0 ifTrue:
		[^self genReturnTopFromBlock].
	self shouldBeImplemented.
	extA := 0.
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtSendBytecode [
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
PharoSimpleCogit >> genExtSendSuperBytecode [
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
PharoSimpleCogit >> genExtStoreAndPopLiteralVariableBytecode [
	"236		11101100	i i i i i i i i	Pop and Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genStorePop: true LiteralVariable: index
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtStoreAndPopReceiverVariableBytecode [
	"235		11101011	i i i i i i i i	Pop and Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isWriteMediatedContextInstVarIndex: index)
		ifTrue: [self genStorePop: true MaybeContextReceiverVariable: index]
		ifFalse: [self genStorePop: true ReceiverVariable: index]
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtStoreLiteralVariableBytecode [
	"233		11101001	i i i i i i i i	Store Literal Variable #iiiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^self genStorePop: false LiteralVariable: index
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtStoreReceiverVariableBytecode [
	"232		11101000	i i i i i i i i	Store Receiver Variable #iiiiiii (+ Extend A * 256)"
	| index |
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isWriteMediatedContextInstVarIndex: index)
		ifTrue: [self genStorePop: false MaybeContextReceiverVariable: index]
		ifFalse: [self genStorePop: false ReceiverVariable: index]
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtTrapIfNotInstanceOfBehaviorsBytecode [
	"SistaV1: *	236		11101100	iiiiiiii		Trap If Not Instance Of Behavior/Array Of Behavior #iiiiiiii (+ Extend A * 256, where Extend A >= 0)"
	"This really only makes sense for the optimizing JITs"
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtUnconditionalJump [
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
PharoSimpleCogit >> genExtendedSendBytecode [
	"Can use any of the first 32 literals for the selector and pass up to 7 arguments."

	^self genSend: (byte1 bitAnd: 16r1F) numArgs: byte1 >> 5
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genExtendedSuperBytecode [
	^self genSendSuper: (byte1 bitAnd: 16r1F) numArgs: byte1 >> 5
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genGetClassObjectOf: instReg into: destReg scratchReg: scratchReg instRegIsReceiver: instRegIsReceiver [
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
PharoSimpleCogit >> genGetClassObjectOfClassIndex: instReg into: destReg scratchReg: scratchReg [
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

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genInlinedIdenticalOrNotIf: orNot [
	| jumpNotEqual jumpPush |
	<var: #jumpNotEqual type: #'AbstractInstruction *'>
	<var: #jumpPush type: #'AbstractInstruction *'>
	self PopR: Arg0Reg.
	self
		genEnsureOopInRegNotForwarded: Arg0Reg
		scratchReg: TempReg.
	self MoveMw: 0 r: SPReg R: ClassReg.
	self
		genEnsureOopInRegNotForwarded: ClassReg
		scratchReg: TempReg.
	self CmpR: Arg0Reg R: ClassReg.
	jumpNotEqual := self genConditionalBranch: (orNot ifTrue: [JumpZero] ifFalse: [JumpNonZero]) operand: 0.
	self annotate: (self genMoveTrueR: Arg0Reg)
		objRef: objectMemory trueObject.
	jumpPush := self Jump: 0.
	jumpNotEqual jmpTarget: (self genMoveFalseR: Arg0Reg).
	jumpPush jmpTarget: (self MoveR: Arg0Reg Mw: 0 r: SPReg).
	^0
]

{ #category : #'compile abstract instructions' }
PharoSimpleCogit >> genJumpBaseHeaderImmutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"

	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	self TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpNonZero: 0
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genJumpIf: boolean to: targetBytecodePC [
	<inline: false>
	"Cunning trick by LPD.  If true and false are contiguous subtract the smaller.
	 Correct result is either 0 or the distance between them.  If result is not 0 or
	 their distance send mustBeBoolean."
	| ok |
	<var: #ok type: #'AbstractInstruction *'>
	extA := 0.
	self assert: (objectMemory objectAfter: objectMemory falseObject) = objectMemory trueObject.
	self PopR: TempReg.
	self genSubConstant: boolean R: TempReg.
	self JumpZero: (self ensureFixupAt: targetBytecodePC).
	self CmpCq: (boolean = objectMemory falseObject
					ifTrue: [objectMemory trueObject - objectMemory falseObject]
					ifFalse: [objectMemory falseObject - objectMemory trueObject])
		R: TempReg.
	ok := self JumpZero: 0.
	self genCallMustBeBooleanFor: boolean.
	ok jmpTarget: (self annotateBytecode: self Label).
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongJumpIfFalse [
	| distance target |
	distance := self v3: (self generatorAt: byte0) LongForward: bytecodePC Branch: 0 Distance: methodObj.
	target := distance + 2 + bytecodePC.
	^self genJumpIf: objectMemory falseObject to: target
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongJumpIfTrue [
	| distance target |
	distance := self v3: (self generatorAt: byte0) LongForward: bytecodePC Branch: 0 Distance: methodObj.
	target := distance + 2 + bytecodePC.
	^self genJumpIf: objectMemory trueObject to: target
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongPushTemporaryVariableBytecode [
	"230		11100110	i i i i i i i i	Push Temporary Variable #iiiiiiii"
	^self genPushTemporaryVariable: byte1
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongStoreAndPopTemporaryVariableBytecode [
	"237		11101101	i i i i i i i i	Pop and Store Temporary Variable #iiiiiiii"
	^self genStorePop: true TemporaryVariable: byte1
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongStoreTemporaryVariableBytecode [
	"234		11101010	i i i i i i i i	Store Temporary Variable #iiiiiiii"
	^self genStorePop: false TemporaryVariable: byte1
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongUnconditionalBackwardJump [
	| distance |
	distance := self v3: (self generatorAt: byte0)
					Long: bytecodePC
					Branch: 0
					Distance: methodObj.
	self assert: distance < 0.
	^self genJumpBackTo: distance + 2 + bytecodePC
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genLongUnconditionalForwardJump [
	| distance targetpc |
	distance := self v3: (self generatorAt: byte0)
					Long: bytecodePC
					Branch: 0
					Distance: methodObj.
	self assert: distance >= 0.
	targetpc := distance + 2 + bytecodePC.
	^self genJumpTo: targetpc
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genLookupForPerformNumArgs: numArgs [
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
PharoSimpleCogit >> genMoveFalseR: reg [
	<inline: true>
	^ self genMoveConstant: objectMemory falseObject R: reg
	
]

{ #category : #'constant support' }
PharoSimpleCogit >> genMoveTrueR: reg [
	<inline: true>
	^ self genMoveConstant: objectMemory trueObject R: reg
	
]

{ #category : #initialization }
PharoSimpleCogit >> genMustBeBooleanTrampolineCalled: trampolineName [
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
PharoSimpleCogit >> genMustBeBooleanTrampolineFor: boolean called: trampolineName [
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
PharoSimpleCogit >> genPopStackBytecode [
	self AddCq: objectMemory wordSize R: SPReg.
	^0
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genPrimitiveHashMultiply [
	"Implement 28-bit hashMultiply for SmallInteger and LargePositiveInteger receivers."
	| jmpFailImm jmpFailNonImm jmpNotSmallInt reenter |
	jmpNotSmallInt := self genJumpNotSmallInteger: ReceiverResultReg.

	objectRepresentation genConvertSmallIntegerToIntegerInReg: ReceiverResultReg.
	reenter :=
	self MoveCq: HashMultiplyConstant R: TempReg.
	self MulR: TempReg R: ReceiverResultReg.
	self AndCq: HashMultiplyMask R: ReceiverResultReg.
	objectRepresentation genConvertIntegerToSmallIntegerInReg: ReceiverResultReg.
	self RetN: 0.

	jmpNotSmallInt jmpTarget: self Label.
	jmpFailImm := self genJumpImmediate: ReceiverResultReg.
	objectRepresentation genGetCompactClassIndexNonImmOf: ReceiverResultReg into: ClassReg.
	self CmpCq: ClassLargePositiveIntegerCompactIndex R: ClassReg.
	jmpFailNonImm := self JumpNonZero: 0.
	self genLoadSlot: 0 sourceReg: ReceiverResultReg destReg: ReceiverResultReg.
	self Jump: reenter.

	jmpFailImm jmpTarget: (jmpFailNonImm jmpTarget: self Label).
	^0
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genPrimitivePerform [
	"Generate an in-line perform primitive.  The lookup code requires the selector to be in Arg0Reg.
	 adjustArgumentsForPerform: adjusts the arguments once genLookupForPerformNumArgs:
	 has generated the code for the lookup."
	self MoveMw: (backEnd hasLinkRegister
					ifTrue: [methodOrBlockNumArgs - 1]
					ifFalse: [methodOrBlockNumArgs]) * self wordSize
		r: SPReg
		R: Arg0Reg.
	^self genLookupForPerformNumArgs: methodOrBlockNumArgs
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushActiveContextBytecode [
	self assert: needsFrame.
	objectRepresentation
		genGetActiveContextNumArgs: methodOrBlockNumArgs
		large: (coInterpreter methodNeedsLargeContext: methodObj)
		inBlock: inBlock.
	self PushR: ReceiverResultReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushConstantFalseBytecode [
	^self genPushLiteral: objectMemory falseObject
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushConstantNilBytecode [
	^self genPushLiteral: objectMemory nilObject
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushConstantOneBytecode [
	"79			01001111		Push 1"
	^self genPushLiteral: (objectMemory integerObjectOf: 1)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushConstantTrueBytecode [
	^self genPushLiteral: objectMemory trueObject
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushConstantZeroBytecode [
	"78			01001110		Push 0"
	^self genPushLiteral: (objectMemory integerObjectOf: 0)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushLiteralConstantBytecode [
	^self genPushLiteralIndex: (byte0 bitAnd: 31)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushLiteralVariable16CasesBytecode [
	"16-31		0001 i i i i		Push Literal Variable #iiii"
	^self genPushLiteralVariable: (byte0 bitAnd: 15)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushLiteralVariableBytecode [
	^self genPushLiteralVariable: (byte0 bitAnd: 31)
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genPushMaybeContextReceiverVariable: slotIndex [ 
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

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genPushMaybeContextRemoteInstVar: slotIndex inObjectAt: objectIndex [
	| jmpSingle jmpDone |
	<var: #jmpSingle type: #'AbstractInstruction *'>
	<var: #jmpDone type: #'AbstractInstruction *'>
	self assert: needsFrame.
	"See CoInterpreter>>contextInstructionPointer:frame: for an explanation
	 of the instruction pointer slot handling."
	self MoveMw: (self frameOffsetOfTemporary: objectIndex) r: FPReg R: ReceiverResultReg.
	self 
		genEnsureOopInRegNotForwarded: ReceiverResultReg 
		scratchReg: TempReg.
	slotIndex = InstructionPointerIndex ifTrue:
		[self MoveCq: slotIndex R: SendNumArgsReg.
		 self CallRT: ceFetchContextInstVarTrampoline.
		 self PushR: SendNumArgsReg.
		 ^0].
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
PharoSimpleCogit >> genPushNewArrayBytecode [
	| size popValues |
	self assert: needsFrame.
	popValues := byte1 > 127.
	size := byte1 bitAnd: 127.
	self genNewArrayOfSize: size initialized: popValues not.
	popValues ifTrue:
		[size - 1 to: 0 by: -1 do:
			[:i|
			self PopR: TempReg.
			self
				genStoreSourceReg: TempReg
				slotIndex: i
				intoNewObjectInDestReg: ReceiverResultReg]].
	self PushR: ReceiverResultReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushQuickIntegerConstantBytecode [
	^self genPushLiteral: (objectMemory integerObjectOf: byte0 - 117)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushReceiverBytecode [
	needsFrame
		ifTrue:
			[self MoveMw: FoxMFReceiver r: FPReg R: TempReg.
			 self PushR: TempReg]
		ifFalse:
			[self PushR: ReceiverResultReg].
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushReceiverVariableBytecode [
	^self genPushReceiverVariable: (byte0 bitAnd: 15)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushRemoteTempLongBytecode [
	self MoveMw: (self frameOffsetOfTemporary: byte2) r: FPReg R: ClassReg.
	TempVectReadBarrier
		ifTrue: [self
				genEnsureObjInRegNotForwarded: ClassReg
				scratchReg: TempReg].
	self
		genLoadSlot: byte1
		sourceReg: ClassReg
		destReg: TempReg.
	self PushR: TempReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genPushTemporaryVariableBytecode [
	^self genPushTemporaryVariable: (byte0 bitAnd: 15)
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genQuickReturnConst [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	| constant |
	constant := coInterpreter quickPrimitiveConstantFor: primitiveIndex.
	self genMoveConstant: constant R: ReceiverResultReg.
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genQuickReturnInstVar [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	| index |
	index := coInterpreter quickPrimitiveInstVarIndexFor: primitiveIndex.
	self genLoadSlot: index sourceReg: ReceiverResultReg destReg: ReceiverResultReg.
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'primitive generators' }
PharoSimpleCogit >> genQuickReturnSelf [
	<api> "because selected by CoInterpreter>>quickPrimitiveGeneratorFor:"
	self genUpArrowReturn.
	^UnfailingPrimitive
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnFalse [
	self genMoveFalseR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnNil [
	self genMoveNilR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnNilFromBlock [
	self assert: inBlock > 0.
	self genMoveNilR: ReceiverResultReg.
	^self genBlockReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnReceiver [
	"Frameless method activation looks like
				receiver
				args
		sp->	ret pc.
	 Return pops receiver and arguments off the stack.  Callee pushes the result."
	needsFrame ifTrue:
		[self putSelfInReceiverResultReg].
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnTopFromBlock [
	self assert: inBlock > 0.
	self PopR: ReceiverResultReg.
	^self genBlockReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnTopFromMethod [
	"Return pops receiver and arguments off the stack.  Callee pushes the result."
	self PopR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genReturnTrue [
	self genMoveTrueR: ReceiverResultReg.
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSecondExtendedSendBytecode [
	"Can use any of the first 64 literals for the selector and pass up to 3 arguments."

	^self genSend: (byte1 bitAnd: 16r3F) numArgs: byte1 >> 6
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSendLiteralSelector0ArgsBytecode [
	^self genSend: (byte0 bitAnd: 15) numArgs: 0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSendLiteralSelector1ArgBytecode [
	^self genSend: (byte0 bitAnd: 15) numArgs: 1
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSendLiteralSelector2ArgsBytecode [

	^self genSend: (byte0 bitAnd: 15) numArgs: 2
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genShortJumpIfFalse [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpIf: objectMemory falseObject to: target
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genShortJumpIfTrue [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpIf: objectMemory trueObject to: target
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genShortUnconditionalJump [

	| distance target |
	distance := self
		            distanceForShortForwardBranch: bytecodePC
		            inMethod: methodObj.
	target := distance + 1 + bytecodePC.
	^ self genJumpTo: target
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreAndPopLiteralVariableBytecode [
	^ self genSistaExtStoreLiteralVariableBytecodePopBoolean: true
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreAndPopReceiverVariableBytecode [
	^ self genSistaExtStoreAndPopReceiverVariableBytecodePopBoolean: true
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreAndPopReceiverVariableBytecodePopBoolean: boolean [
	| index |
	extB := 0. "Simple cogit don't use the extra flags"
	numExtB := 0.
	index := byte1 + (extA << 8).
	extA := 0.
	^(coInterpreter isWriteMediatedContextInstVarIndex: index)
		ifTrue: [self genStorePop: boolean MaybeContextReceiverVariable: index ]
		ifFalse: [self genStorePop: boolean ReceiverVariable: index ]
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreLiteralVariableBytecode [
	^ self genSistaExtStoreLiteralVariableBytecodePopBoolean: false
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreLiteralVariableBytecodePopBoolean: boolean [
	| index |
	extB := 0. "SimpleCogit don't use the extra flags"
	numExtB := 0.
	index := byte1 + (extA << 8).
	extA := 0.
	^ self genStorePop: boolean LiteralVariable: index
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSistaExtStoreReceiverVariableBytecode [
	^ self genSistaExtStoreAndPopReceiverVariableBytecodePopBoolean: false
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSpecialSelectorClass [
	self MoveMw: 0 r: SPReg R: SendNumArgsReg.
	self
		genGetClassObjectOf: SendNumArgsReg
		into: ClassReg
		scratchReg: TempReg
		instRegIsReceiver: false.
	self MoveR: ClassReg Mw: 0 r: SPReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSpecialSelectorEqualsEquals [
	^ self genInlinedIdenticalOrNotIf: false
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSpecialSelectorNotEqualsEquals [
	^ self genInlinedIdenticalOrNotIf: true
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genSpecialSelectorSend [
	| index numArgs |
	index := byte0 - self firstSpecialSelectorBytecodeOffset.
	numArgs := coInterpreter specialSelectorNumArgs: index.
	^self genSend: index negated - 1 numArgs: numArgs
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genStoreAndPopReceiverVariableBytecode [
	^self genStorePop: true ReceiverVariable: (byte0 bitAnd: 7)
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genStoreAndPopRemoteTempLongBytecode [
	^self genStorePop: true RemoteTemp: byte1 At: byte2
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genStoreAndPopTemporaryVariableBytecode [
	^self genStorePop: true TemporaryVariable: (byte0 bitAnd: 7)
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean LiteralVariable: litVarIndex [
	<inline: false>
	| association |
	"The only reason we assert needsFrame here is that in a frameless method
	 ReceiverResultReg must and does contain only self, but the ceStoreCheck
	 trampoline expects the target of the store to be in ReceiverResultReg.  So
	 in a frameless method we would have a conflict between the receiver and
	 the literal store, unless we we smart enough to realise that ReceiverResultReg
	 was unused after the literal variable store, unlikely given that methods
	 return self by default."
	self assert: needsFrame.
	association := self getLiteral: litVarIndex.
	self genMoveConstant: association R: ReceiverResultReg.
	self
		genEnsureObjInRegNotForwarded: ReceiverResultReg
		scratchReg: TempReg.
	popBoolean
		ifTrue: [self PopR: ClassReg]
		ifFalse: [self MoveMw: 0 r: SPReg R: ClassReg].
	self
		genStoreSourceReg: ClassReg 
		slotIndex: ValueIndex 
		destReg: ReceiverResultReg 
		scratchReg: TempReg 
		inFrame: needsFrame.
	^0
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean MaybeContextReceiverVariable: slotIndex [
	<inline: false>
	| jmpSingle jmpDone |
	<var: #jmpSingle type: #'AbstractInstruction *'>
	<var: #jmpDone type: #'AbstractInstruction *'>
	"The reason we need a frame here is that assigning to an inst var of a context may
	 involve wholesale reorganization of stack pages, and the only way to preserve the
	 execution state of an activation in that case is if it has a frame."
	self assert: needsFrame.
	self putSelfInReceiverResultReg.
	self
		genLoadSlot: SenderIndex
		sourceReg: ReceiverResultReg
		destReg: TempReg.
	self MoveMw: 0 r: SPReg R: ClassReg.
	jmpSingle := self genJumpNotSmallInteger: TempReg.
	self MoveCq: slotIndex R: SendNumArgsReg.
	self CallRT: ceStoreContextInstVarTrampoline.
	jmpDone := self Jump: 0.
	jmpSingle jmpTarget: self Label.
	popBoolean ifTrue:
		[self AddCq: self wordSize R: SPReg].
	self
		genStoreSourceReg: ClassReg 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		scratchReg: TempReg 
		inFrame: needsFrame.
	jmpDone jmpTarget: self Label.
	^0
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean MaybeContextRemoteInstVar: slotIndex ofObjectAt: objectIndex [
	<inline: false>
	| jmpSingle jmpDone |
	<var: #jmpSingle type: #'AbstractInstruction *'>
	<var: #jmpDone type: #'AbstractInstruction *'>
	"The reason we need a frame here is that assigning to an inst var of a context may
	 involve wholesale reorganization of stack pages, and the only way to preserve the
	 execution state of an activation in that case is if it has a frame."
	self assert: needsFrame.
	self MoveMw: (self frameOffsetOfTemporary: objectIndex) r: FPReg R: ReceiverResultReg.
	self 
		genEnsureOopInRegNotForwarded: ReceiverResultReg 
		scratchReg: TempReg.
	self
		genLoadSlot: SenderIndex
		sourceReg: ReceiverResultReg
		destReg: TempReg.
	self MoveMw: 0 r: SPReg R: ClassReg.
	jmpSingle := self genJumpNotSmallInteger: TempReg.
	self MoveCq: slotIndex R: SendNumArgsReg.
	self CallRT: ceStoreContextInstVarTrampoline.
	jmpDone := self Jump: 0.
	jmpSingle jmpTarget: self Label.
	popBoolean ifTrue:
		[self AddCq: self wordSize R: SPReg].
	self
		genStoreSourceReg: ClassReg 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		scratchReg: TempReg 
		inFrame: needsFrame.
	jmpDone jmpTarget: self Label.
	^0
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean ReceiverVariable: slotIndex [
	<inline: false>
	needsFrame ifTrue:
		[self putSelfInReceiverResultReg].
	popBoolean
		ifTrue: [self PopR: ClassReg]
		ifFalse: [self MoveMw: 0 r: SPReg R: ClassReg].
	objectRepresentation
		genStoreSourceReg: ClassReg 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		scratchReg: TempReg 
		inFrame: needsFrame.
	^0
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean RemoteTemp: slotIndex At: remoteTempIndex [
	<inline: false>
	"The only reason we assert needsFrame here is that in a frameless method
	 ReceiverResultReg must and does contain only self, but the ceStoreCheck
	 trampoline expects the target of the store to be in ReceiverResultReg.  So
	 in a frameless method we would have a conflict between the receiver and
	 the temote temp store, unless we we smart enough to realise that
	 ReceiverResultReg was unused after the literal variable store, unlikely given
	 that methods return self by default."
	self assert: needsFrame.
	popBoolean
		ifTrue: [self PopR: ClassReg]
		ifFalse: [self MoveMw: 0 r: SPReg R: ClassReg].
	self MoveMw: (self frameOffsetOfTemporary: remoteTempIndex) r: FPReg R: ReceiverResultReg.
	TempVectReadBarrier
		ifTrue: [self
				genEnsureObjInRegNotForwarded: ReceiverResultReg
				scratchReg: TempReg].
	^objectRepresentation
		genStoreSourceReg: ClassReg
		slotIndex: slotIndex
		destReg: ReceiverResultReg
		scratchReg: TempReg
		inFrame: needsFrame
]

{ #category : #'bytecode generator support' }
PharoSimpleCogit >> genStorePop: popBoolean TemporaryVariable: tempIndex [
	<inline: false>
	popBoolean
		ifTrue: [self PopR: TempReg]
		ifFalse: [self MoveMw: 0 r: SPReg R: TempReg].
	self MoveR: TempReg
		Mw: (self frameOffsetOfTemporary: tempIndex)
		r: FPReg.
	^0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genStoreRemoteTempLongBytecode [
	^self genStorePop: false RemoteTemp: byte1 At: byte2
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genStoreSourceReg: sourceReg slotIndex: index intoNewObjectInDestReg: destReg [
	"This method is used for unchecked stores in objects after their creation (typically, inlined creation of Array, closures and some temp vectors). 
	Currently there is no need to do the immutability check here"

	self
		MoveR: sourceReg
		Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		r: destReg.
	^ 0
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genUnconditionalTrapBytecode [
	"SistaV1: *	217		Trap"
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> genUpArrowReturn [
	"Generate a method return from within a method or a block.
	 Frameless method activation looks like
				receiver
				args
		sp->	ret pc.
	 Return pops receiver and arguments off the stack.  Callee pushes the result."
	inBlock > 0 ifTrue:
		[self assert: needsFrame.
		 self CallRT: ceNonLocalReturnTrampoline.
		 self annotateBytecode: self Label.
		 ^0].
	needsFrame ifTrue:
		[self MoveR: FPReg R: SPReg.
		 self PopR: FPReg.
		 backEnd hasLinkRegister ifTrue:
			[self PopR: LinkReg]].
	self RetN: methodOrBlockNumArgs + 1 * objectMemory wordSize.
	^0
]

{ #category : #accessing }
PharoSimpleCogit >> generateRunTimeTrampolines [

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

{ #category : #'in-line cacheing' }
PharoSimpleCogit >> inlineCacheTagForInstance: oop [
	"Answer the relevant inline cache tag for an instance.
	 c.f. getInlineCacheClassTagFrom:into: & inlineCacheTagForClass:"
	^ objectMemory fetchClassTagOf: oop
]

{ #category : #'bytecode generators' }
PharoSimpleCogit >> marshallAbsentReceiverSendArguments: numArgs [
	self assert: needsFrame.
	self putSelfInReceiverResultReg.

	"Shuffle arguments if necessary and push receiver."
	numArgs = 0
		ifTrue:
			[self PushR: ReceiverResultReg]
		ifFalse:
			[self MoveMw: 0 r: SPReg R: TempReg.
			self PushR: TempReg.
			2 to: numArgs do:
				[:index|
				self MoveMw: index * objectMemory wordSize r: SPReg R: TempReg.
				self MoveR: TempReg Mw: index - 1 * BytesPerWord r: SPReg].
			self MoveR: ReceiverResultReg Mw: numArgs * BytesPerWord r: SPReg].
]

{ #category : #'span functions' }
PharoSimpleCogit >> parseV4Exts: nExts priorTo: bcpc in: aMethodObj into: aBinaryBlock [
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

{ #category : #'span functions' }
PharoSimpleCogit >> v3: descriptor Long: pc Branch: nExts Distance: aMethodObj [
	"Answer the distance of a two byte forward long jump."
	<var: #descriptor type: #'BytecodeDescriptor *'>
	self assert: nExts = 0.
	^(((objectMemory fetchByte: pc ofObject: aMethodObj) bitAnd: 7) - 4 << 8)
	 + (objectMemory fetchByte: pc + 1 ofObject: aMethodObj)
]

{ #category : #'span functions' }
PharoSimpleCogit >> v3: descriptor LongForward: pc Branch: nExts Distance: aMethodObj [
	"Answer the distance of a two byte forward long jump."
	<var: #descriptor type: #'BytecodeDescriptor *'>
	self assert: nExts = 0.
	^(((objectMemory fetchByte: pc ofObject: aMethodObj) bitAnd: 3) << 8)
	 + (objectMemory fetchByte: pc + 1 ofObject: aMethodObj)
]

{ #category : #'span functions' }
PharoSimpleCogit >> v3: unusedButKeptForPolymorphism ShortForward: pc Branch: unusedButKeptForPolymorphism2 Distance: aMethodObj [
	
	^ self distanceForShortForwardBranch: pc inMethod: aMethodObj
]

{ #category : #'span functions' }
PharoSimpleCogit >> v4: descriptor Long: pc Branch: nExts Distance: aMethodObj [
	"242		11110010	i i i i i i i i	Jump i i i i i i i i (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	| extBValue |
	self assert: nExts >= 0.
	self parseV4Exts: nExts priorTo: pc in: aMethodObj into: [:ea :eb| extBValue := eb].
	^(objectMemory fetchByte: pc + 1 ofObject: aMethodObj)
	+ (extBValue << 8)
]

{ #category : #'span functions' }
PharoSimpleCogit >> v4: descriptor LongForward: pc Branch: nExts Distance: aMethodObj [
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
