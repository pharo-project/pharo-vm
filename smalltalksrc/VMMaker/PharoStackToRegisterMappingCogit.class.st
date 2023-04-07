Class {
	#name : #PharoStackToRegisterMappingCogit,
	#superclass : #PharoSimpleCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> doubleExtendedDoAnythingBytecode [
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
						ifFalse: [self genPushReceiverVariable: byte2.
								self annotateInstructionForBytecode.
								^0]].
			[3]	->	[self genPushLiteralIndex: byte2.
					 self annotateInstructionForBytecode.
					 ^0].
			[4]	->	[self genPushLiteralVariable: byte2.].
			[7]	->	[self genStorePop: false LiteralVariable: byte2.
					self cppIf: IMMUTABILITY ifTrue: [ "genStorePop:LiteralVariable: annotates; don't annotate twice" ^0 ] ] }
		otherwise: "5 & 6"
			[(coInterpreter isWriteMediatedContextInstVarIndex: byte2)
				ifTrue: [self genStorePop: opType = 6 MaybeContextReceiverVariable: byte2]
				ifFalse: [self genStorePop: opType = 6 ReceiverVariable: byte2].
			self cppIf: IMMUTABILITY ifTrue: [ "genStorePop:...ReceiverVariable: annotate; don't annotate twice" ^0 ]].
	"We need a map entry for this bytecode for correct parsing (if the method builds a frame)."
	self assert: needsFrame.
	"genPushMaybeContextInstVar, pushLitVar, store & storePop all generate code"
	self assert: self prevInstIsPCAnnotated not.
	self annotateBytecode: self Label.
	^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> duplicateTopBytecode [
	| desc |
	<var: #desc type: #SimStackEntry>
	desc := self ssTopDescriptor.
	^self ssPushDesc: desc
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genBlockReturn [
	"Return from block, assuming result already loaded into ReceiverResultReg."
	super genBlockReturn.
	deadCode := true. "can't fall through"
	^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genCallMappedInlinedPrimitive [
	"SistaV1:	236		11101100	iiiiiiii		callMappedInlinedPrimitive"
	^ self genMappedInlinePrimitive: byte1
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genCallPrimitiveBytecode [
	"SistaV1: 248		11111000 	iiiiiiii		mjjjjjjj		Call Primitive #iiiiiiii + (jjjjjjj * 256) m=1 means inlined primitive, no hard return after execution.
	 See EncoderForSistaV1's class comment and StackInterpreter>>#inlinePrimitiveBytecode:"
	| prim primSet |
	byte2 < 128 ifTrue:
		[^bytecodePC = initialPC
			ifTrue: [0]
			ifFalse: [EncounteredUnknownBytecode]].
	prim := byte2 - 128 << 8 + byte1.
	primSet := prim >> 13 bitAnd: 3.
	prim := prim bitAnd: 8191.
	^EncounteredUnknownBytecode
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genExtPushFullClosureBytecode [
	"Full Block creation compilation. The block's actual code will be compiled separatedly."
	"*	255		11111111	xxxxxxxx	siyyyyyy	push Closure Compiled block literal index xxxxxxxx (+ Extend A * 256) numCopied yyyyyy receiverOnStack: s = 1 ignoreOuterContext: i = 1"
	| numCopied ignoreContext receiverIsOnStack compiledBlock reg |
	self assert: needsFrame.
	compiledBlock := self getLiteral: byte1 + (extA << 8).
	extA := 0.
	numCopied := byte2 bitAnd: 1<< 6 - 1.
	receiverIsOnStack := byte2 anyMask: 1 << 7.
	ignoreContext := byte2 anyMask: 1 << 6.
	self voidReceiverResultRegContainsSelf.
	self ssAllocateCallReg: ReceiverResultReg
		and: SendNumArgsReg
		and: ClassReg.
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
		reg := self ssStorePop: true toPreferredReg: TempReg.
		 self
			genStoreSourceReg: reg
			slotIndex: FullClosureFirstCopiedValueIndex + numCopied - i
			intoNewObjectInDestReg: ReceiverResultReg].
	receiverIsOnStack
		ifTrue: [reg := self ssStorePop: true toPreferredReg: TempReg]
		ifFalse: [self simSelf storeToReg: (reg := TempReg)].
	self
			genStoreSourceReg: reg
			slotIndex: FullClosureReceiverIndex
			intoNewObjectInDestReg: ReceiverResultReg.
	self ssPushRegister: ReceiverResultReg.
	^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genExtPushRemoteTempOrInstVarLongBytecode [
	| index maybeContext |
	^ (byte2 noMask: coInterpreter remoteIsInstVarAccess)
		ifTrue: [ self genPushRemoteTempLongBytecode ]
		ifFalse: 
			[ maybeContext := self extBSpecifiesMaybeContext.
			index := byte1 + (extA << 8).
			extA := 0.
			extB := 0.
			numExtB := 0.
			((coInterpreter isReadMediatedContextInstVarIndex: index) and: [ maybeContext ])
				ifTrue: [ self genPushMaybeContextRemoteInstVar: index inObjectAt: byte2 - coInterpreter remoteIsInstVarAccess ]
				ifFalse: [ self genPushRemoteInstVar: index inObjectAt: byte2 - coInterpreter remoteIsInstVarAccess ] ]
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genExtStorePopRemoteTempOrInstVarLongBytecodePopBoolean: boolean [
	| index maybeContext needsStoreCheck needsImmCheck |
	needsStoreCheck := self sistaNeedsStoreCheck.
	maybeContext := self extBSpecifiesMaybeContext.
	needsImmCheck := self extBSpecifiesImmCheck.
	extB := 0.
	numExtB := 0.
	(byte2 noMask: coInterpreter remoteIsInstVarAccess)
		ifTrue: 
			[ self 
				genStorePop: boolean 
				RemoteTemp: byte1 
				At: byte2 
				needsStoreCheck: needsStoreCheck.
			self cppIf: IMMUTABILITY ifTrue: [ self annotateBytecode: self Label ] ]
		ifFalse: 
			[index := byte1 + (extA << 8).
			 extA := 0.
			 ((coInterpreter isWriteMediatedContextInstVarIndex: index) and: [ maybeContext ])
				ifTrue: [self 
						genStorePop: boolean 
						MaybeContextRemoteInstVar: index 
						ofObjectAt: byte2 - coInterpreter remoteIsInstVarAccess 
						needsStoreCheck: needsStoreCheck
						needsImmutabilityCheck: needsImmCheck ]
				ifFalse: [self 
						genStorePop: boolean 
						RemoteInstVar: index 
						ofObjectAt: byte2 - coInterpreter remoteIsInstVarAccess 
						needsStoreCheck: needsStoreCheck
						needsImmutabilityCheck: needsImmCheck ].
			self cppIf: IMMUTABILITY ifTrue: [ needsImmCheck ifFalse: [self annotateBytecode: self Label ] ] ].
	^ 0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genForwardersInlinedIdenticalOrNotIf: orNot [
	| nextPC branchDescriptor unforwardRcvr argReg targetBytecodePC
	  unforwardArg  rcvrReg postBranchPC label fixup |
	<var: #branchDescriptor type: #'BytecodeDescriptor *'>
	<var: #label type: #'AbstractInstruction *'>
	
	self extractMaybeBranchDescriptorInto: [ :descr :next :postBranch :target | 
		branchDescriptor := descr. nextPC := next. postBranchPC := postBranch. targetBytecodePC := target ].

	"If an operand is an annotable constant, it may be forwarded, so we need to store it into a 
	register so the forwarder check can jump back to the comparison after unforwarding the constant.
	However, if one of the operand is an unnanotable constant, does not allocate a register for it 
	(machine code will use operations on constants) and does not generate forwarder checks."
	unforwardRcvr := (objectRepresentation isUnannotatableConstant: (self ssValue: 1)) not.
	unforwardArg := (objectRepresentation isUnannotatableConstant: self ssTop) not.

	self 
		allocateEqualsEqualsRegistersArgNeedsReg: unforwardArg 
		rcvrNeedsReg: unforwardRcvr 
		into: [ :rcvr :arg | rcvrReg:= rcvr. argReg := arg ].

	"If not followed by a branch, resolve to true or false."
	(branchDescriptor isBranchTrue or: [branchDescriptor isBranchFalse]) ifFalse:
		[^ self 
			genIdenticalNoBranchArgIsConstant: unforwardArg not
			rcvrIsConstant: unforwardRcvr not
			argReg: argReg 
			rcvrReg: rcvrReg 
			orNotIf: orNot].
	
	"If branching the stack must be flushed for the merge"
	self ssFlushTo: simStackPtr - 2.
	
	label := self Label.
	self genCmpArgIsConstant: unforwardArg not rcvrIsConstant: unforwardRcvr not argReg: argReg rcvrReg: rcvrReg.
	self ssPop: 2.

	"Since there is a following conditional jump bytecode (unless there is deadCode),
	 define non-merge fixups and leave the cond bytecode to set the mergeness."
	(self fixupAt: nextPC) notAFixup
		ifTrue: "The next instruction is dead.  we can skip it."
			[deadCode := true.
		 	 self ensureFixupAt: targetBytecodePC.
			 self ensureFixupAt: postBranchPC]
		ifFalse:
			[self deny: deadCode]. "push dummy value below"

	self assert: (unforwardArg or: [unforwardRcvr]).
	orNot == branchDescriptor isBranchTrue "orNot is true for ~~"
		ifFalse: "a == b ifTrue: ... or a ~~ b ifFalse: ... jump on equal to target pc"
			[fixup := self ensureNonMergeFixupAt: postBranchPC.
			 self JumpZero:  (self ensureNonMergeFixupAt: targetBytecodePC)]
		ifTrue: "a == b ifFalse: ... or a ~~ b ifTrue: ... jump on equal to post-branch pc"
			[fixup := self ensureNonMergeFixupAt: targetBytecodePC.
			 self JumpZero: (self ensureNonMergeFixupAt: postBranchPC)].
		
	"The forwarders checks need to jump back to the comparison (label) if a forwarder is found, else 
	 jump forward either to the next forwarder check or to the postBranch or branch target (fixup)."
	(unforwardArg and: [unforwardRcvr]) ifTrue:
		[self genEnsureOopInRegNotForwarded: argReg scratchReg: TempReg jumpBackTo: label].
	self 
		genEnsureOopInRegNotForwarded: (unforwardRcvr ifTrue: [rcvrReg] ifFalse: [argReg]) 
		scratchReg: TempReg 
		ifForwarder: label
		ifNotForwarder: fixup.
		
	"Not reached, execution flow has jumped to fixup"
	deadCode ifFalse:
		[self ssPushConstant: objectMemory trueObject]. "dummy value"
	^0
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genGenericStorePop: popBoolean MaybeContextSlotIndex: slotIndex needsStoreCheck: needsStoreCheck needsRestoreRcvr: needsRestoreReceiver needsImmutabilityCheck: needsImmCheck [
	"Generates a store into an object that *may* be a context.
	Multiple settings:
	- needsStoreCheck (young into old object check)
	- needRestoreRcvr (ensures the recevier is live across the store)
	- needsImmCheck (do the call-back if the receiver is immutable)"
	<inline: true>
	<var: #mutableJump type: #'AbstractInstruction *'>
	<var: #immutabilityFailure type: #'AbstractInstruction *'>
	| immutabilityFailure mutableJump |
	"The reason we need a frame here is that assigning to an inst var of a context may
	 involve wholesale reorganization of stack pages, and the only way to preserve the
	 execution state of an activation in that case is if it has a frame."
	self assert: needsFrame.
	self 
		cppIf: IMMUTABILITY
		ifTrue:
			[needsImmCheck
				ifTrue: 
					[mutableJump := objectRepresentation genJumpMutable: ReceiverResultReg scratchReg: TempReg.
					 objectRepresentation genStoreTrampolineCall: slotIndex.
					 needsRestoreReceiver ifTrue: [ self putSelfInReceiverResultReg ].
					 immutabilityFailure := self Jump: 0.
					 mutableJump jmpTarget: self Label.]].
	self ssPop: 1.
	self ssAllocateCallReg: ClassReg and: SendNumArgsReg. "for ceStoreContextInstVarTrampoline"
	self ssPush: 1.
	self
		genLoadSlot: SenderIndex
		sourceReg: ReceiverResultReg
		destReg: TempReg.
	self ssStoreAndReplacePop: popBoolean toReg: ClassReg.
	self ssFlushTo: simStackPtr.
	self MoveCq: slotIndex R: SendNumArgsReg.
	self CallRT: ceStoreContextInstVarTrampoline.
	self 
		cppIf: IMMUTABILITY
		ifTrue:
			[needsImmCheck ifTrue:[immutabilityFailure jmpTarget: self Label]].
	^0
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genGenericStorePop: popBoolean slotIndex: slotIndex destReg: destReg needsStoreCheck: needsStoreCheck needsRestoreRcvr: needsRestoreReceiver needsImmutabilityCheck: needsImmCheck [
	"Generates a store into an object that *cannot* be a context.
	 This code is common between multiple stores (litVar, instVar, remoteInstVar, RemoteTemp)
	 Multiple settings:
	- needsStoreCheck (young into old object check)
	- needRestoreRcvr (ensures the receiver is live across the store)
	- needsImmCheck (do the call-back if the receiver is immutable)"
	"We have two very different paths as only the immutability path requires a specific register 
	for the value on top of stack as well as the stack flush.
	N.B. If IMMUTABILITY then ReceiverResultReg/destReg will be smashed if needsImmCheck.
		If not IMMUTABILITY then ReceiverResultReg will be preserved by the ceStoreCheck trampoline."
	| topReg |
	<inline: true>
	self cppIf: IMMUTABILITY ifTrue:
		[needsImmCheck ifTrue: 
			[self ssAllocateRequiredReg: ClassReg upThrough: simStackPtr - 1. "If already classReg don't spill it"
			 "we replace the top value for the flush"
			 self ssStoreAndReplacePop: popBoolean toReg: ClassReg.
			 self ssFlushTo: simStackPtr.
			 ^objectRepresentation 
				genStoreWithImmutabilityCheckSourceReg: ClassReg 
				slotIndex: slotIndex 
				destReg: destReg 
				scratchReg: TempReg 
				needsStoreCheck: needsStoreCheck 
				needRestoreRcvr: needsRestoreReceiver]].
	topReg := self 
				allocateRegForStackEntryAt: 0 
				notConflictingWith: (self registerMaskFor: destReg). 
	self ssStorePop: popBoolean toReg: topReg.
	^objectRepresentation
		genStoreSourceReg: topReg
		slotIndex: slotIndex
		destReg: destReg
		scratchReg: TempReg
		inFrame: needsFrame
		needsStoreCheck: needsStoreCheck
]

{ #category : #'bytecode generator support' }
PharoStackToRegisterMappingCogit >> genIdenticalNoBranchArgIsConstant: argIsConstant rcvrIsConstant: rcvrIsConstant argReg: argReg rcvrReg: rcvrRegOrNone orNotIf: orNot [
	"Generates the machine code for #== in the case where the instruction is not followed by a branch"
	| label jumpEqual jumpNotEqual resultReg |
	<var: #label type: #'AbstractInstruction *'>
	<var: #jumpEqual type: #'AbstractInstruction *'>
	<var: #jumpNotEqual type: #'AbstractInstruction *'>
	label := self Label.
	self genCmpArgIsConstant: argIsConstant rcvrIsConstant: rcvrIsConstant argReg: argReg rcvrReg: rcvrRegOrNone.
	self ssPop: 2.
	resultReg := rcvrRegOrNone = NoReg ifTrue: [argReg] ifFalse: [rcvrRegOrNone].
	jumpEqual := self JumpZero: 0.
	 argIsConstant ifFalse:
		[self genEnsureOopInRegNotForwarded: argReg scratchReg: TempReg jumpBackTo: label].
	 rcvrIsConstant ifFalse:
		[objectRepresentation genEnsureOopInRegNotForwarded: rcvrRegOrNone scratchReg: TempReg jumpBackTo: label].
	 orNot ifFalse: [self genMoveFalseR: resultReg] ifTrue: [self genMoveTrueR: resultReg].
	 jumpNotEqual := self Jump: 0.
	 jumpEqual jmpTarget: (orNot ifFalse: [self genMoveTrueR: resultReg] ifTrue: [self genMoveFalseR: resultReg]).
	 jumpNotEqual jmpTarget: self Label.
	 self ssPushRegister: resultReg.
	 ^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genInlinedIdenticalOrNotIf: orNot [
	"Decompose code generation for #== into a common constant-folding version,
	 followed by a double dispatch throguh the objectRepresentation to a version
	 that doesn't deal with forwarders and a version that does."
	| primDescriptor result |
	<var: #primDescriptor type: #'BytecodeDescriptor *'>
	primDescriptor := self generatorAt: byte0.
	
	((objectRepresentation isUnannotatableConstant: self ssTop)
	 and: [ objectRepresentation isUnannotatableConstant: (self ssValue: 1) ]) ifTrue:
		[self assert: primDescriptor isMapped not.
		 result := (orNot
					ifFalse: [self ssTop constant = (self ssValue: 1) constant]
					ifTrue: [self ssTop constant ~= (self ssValue: 1) constant])
									ifTrue: [objectMemory trueObject]
									ifFalse: [objectMemory falseObject].
		 self ssPop: 2.
		 ^self ssPushConstant: result].

	^objectRepresentation genInlinedIdenticalOrNotIfGuts: orNot
]

{ #category : #'primitive generators' }
PharoStackToRegisterMappingCogit >> genLoadArgAtDepth: n into: reg [
	"All machine code primitives apart from perform: have only
	 register arguments, hence no arg load code is necessary."
	<inline: true>
	self assert: n < objectRepresentation numRegArgs
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genPopStackBytecode [
	self ssTop spilled ifTrue:
		[self AddCq: objectMemory wordSize R: SPReg].
	self ssPop: 1.
	^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genPushActiveContextBytecode [
	self assert: needsFrame.
	self voidReceiverResultRegContainsSelf.

	self ssAllocateCallReg: ReceiverResultReg
			and: SendNumArgsReg
			and: ClassReg.
			
	objectRepresentation
		genGetActiveContextNumArgs: methodOrBlockNumArgs
		large: (coInterpreter methodNeedsLargeContext: methodObj)
		inBlock: inBlock.
	^self ssPushRegister: ReceiverResultReg
]

{ #category : #'bytecode generator support' }
PharoStackToRegisterMappingCogit >> genPushLiteralVariable: literalIndex [
	<inline: false>
	| association freeReg |
	association := self getLiteral: literalIndex.
	"If followed by a directed super send bytecode, avoid generating any code yet.
	 The association will be passed to the directed send trampoline in a register
	 and fully dereferenced only when first linked.  It will be ignored in later sends."
	BytecodeSetHasDirectedSuperSend ifTrue:
		[self deny: directedSendUsesBinding.
		 self nextDescriptorExtensionsAndNextPCInto:
			[:descriptor :exta :extb :followingPC|
			(self isDirectedSuper: descriptor extA: exta extB: extb) ifTrue:
				[self ssPushConstant: association.
				 directedSendUsesBinding := true.
				 ^0]]].
	freeReg := self allocateRegNotConflictingWith: 0.
	"N.B. Do _not_ use ReceiverResultReg to avoid overwriting receiver in assignment in frameless methods."
	"So far descriptors are not rich enough to describe the entire dereference so generate the register
	 load but don't push the result.  There is an order-of-evaluation issue if we defer the dereference."
	self genMoveConstant: association R: TempReg.
	self
		genEnsureObjInRegNotForwarded: TempReg
		scratchReg: freeReg.
	objectRepresentation
		genLoadSlot: ValueIndex
		sourceReg: TempReg
		destReg: freeReg.
	self ssPushRegister: freeReg.
	^0
]

{ #category : #'bytecode generator support' }
PharoStackToRegisterMappingCogit >> genPushMaybeContextSlotIndex: slotIndex [
	<inline: true>
	"This method expects ReceiverResultReg to hold the object read"
	| jmpSingle jmpDone |
	<var: #jmpSingle type: #'AbstractInstruction *'>
	<var: #jmpDone type: #'AbstractInstruction *'>
	self assert: needsFrame.
	(self isCallerSavedReg: ReceiverResultReg) ifTrue:
		["We have no way of reloading ReceiverResultReg since we need the inst var value as the result."
		self voidReceiverResultRegContainsSelf].
	"See CoInterpreter>>contextInstructionPointer:frame: for an explanation
	 of the instruction pointer slot handling."
	slotIndex = InstructionPointerIndex ifTrue:
		[self MoveCq: slotIndex R: SendNumArgsReg.
		 self CallRT: ceFetchContextInstVarTrampoline.
		 ^self ssPushRegister: SendNumArgsReg].
	objectRepresentation
		genLoadSlot: SenderIndex
		sourceReg: ReceiverResultReg
		destReg: TempReg.
	jmpSingle := self genJumpNotSmallInteger: TempReg.
	self MoveCq: slotIndex R: SendNumArgsReg.
	self CallRT: ceFetchContextInstVarTrampoline.
	jmpDone := self Jump: 0.
	jmpSingle jmpTarget: self Label.
	objectRepresentation
		genLoadSlot: slotIndex
		sourceReg: ReceiverResultReg
		destReg: SendNumArgsReg.
	jmpDone jmpTarget: self Label.
	^self ssPushRegister: SendNumArgsReg
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genPushNewArrayBytecode [
	| size popValues |
	self assert: needsFrame.
	self voidReceiverResultRegContainsSelf.
	(popValues := byte1 > 127)
		ifTrue: [self ssFlushTo: simStackPtr]
		ifFalse: [self ssAllocateCallReg: SendNumArgsReg and: ReceiverResultReg].
	size := byte1 bitAnd: 127.
	popValues ifFalse:
		[(self tryCollapseTempVectorInitializationOfSize: size) ifTrue:
			[^0]].
	self genNewArrayOfSize: size initialized: popValues not.
	popValues ifTrue:
		[size - 1 to: 0 by: -1 do:
			[:i|
			self PopR: TempReg.
			self
				genStoreSourceReg: TempReg
				slotIndex: i
				intoNewObjectInDestReg: ReceiverResultReg].
		 self ssPop: size].
	^self ssPushRegister: ReceiverResultReg
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genPushReceiverBytecode [
	self receiverIsInReceiverResultReg ifTrue:
		[^self ssPushRegister: ReceiverResultReg].
	^self ssPushDesc: self ssSelfDescriptor
]

{ #category : #'bytecode generator support' }
PharoStackToRegisterMappingCogit >> genPushReceiverVariable: index [
	<inline: false>
	self ensureReceiverResultRegContainsSelf.
	^self ssPushBase: ReceiverResultReg
			offset: (objectRepresentation slotOffsetOfInstVarIndex: index)
]

{ #category : #'bytecode generator support' }
PharoStackToRegisterMappingCogit >> genPushRemoteInstVar: index inObjectAt: objectIndex [
	<inline: false>
	| objectReg resultReg |
	self assert: needsFrame.
	objectReg := self allocateRegNotConflictingWith: 0.
	self genLoadTemp: objectIndex in: objectReg.
	resultReg := self availableRegOrNoneNotConflictingWith: (self registerMaskFor: objectReg). 
	resultReg = NoReg ifTrue: [resultReg := objectReg].
	objectRepresentation
		genLoadSlot: byte1
		sourceReg: objectReg
		destReg: resultReg.
	^self ssPushRegister: resultReg
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genPushRemoteTempLongBytecode [
	| tempVectReg remoteTempReg |
	tempVectReg := self allocateRegNotConflictingWith: 0.
	self MoveMw: (self frameOffsetOfTemporary: byte2) r: FPReg R: tempVectReg.
	remoteTempReg := self availableRegOrNoneNotConflictingWith: (self registerMaskFor: tempVectReg). 
	remoteTempReg = NoReg ifTrue: [remoteTempReg := tempVectReg].
	TempVectReadBarrier
		ifTrue: [self
				genEnsureObjInRegNotForwarded: tempVectReg
				scratchReg: TempReg].
	objectRepresentation
		genLoadSlot: byte1
		sourceReg: tempVectReg
		destReg: remoteTempReg.
	^self ssPushRegister: remoteTempReg
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genReturnReceiver [
	"In a frameless method ReceiverResultReg already contains self.
	 In a frameful method, ReceiverResultReg /may/ contain self."
	needsFrame ifTrue:
		[self receiverIsInReceiverResultReg ifFalse:
			[self putSelfInReceiverResultReg]].
	^self genUpArrowReturn
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genReturnTopFromBlock [
	self assert: inBlock > 0.
	self ssTop moveToReg: ReceiverResultReg.
	self ssPop: 1.
	^self genBlockReturn
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genReturnTopFromMethod [
	self ssTop moveToReg: ReceiverResultReg.
	self ssPop: 1.
	^self genUpArrowReturn
]

{ #category : #initialization }
PharoStackToRegisterMappingCogit >> genSendTrampolineFor: aRoutine numArgs: numArgs called: aString arg: regOrConst0 arg: regOrConst1 arg: regOrConst2 arg: regOrConst3 [
	"Generate a trampoline with four arguments.
	 Hack: a negative value indicates an abstract register, a non-negative value indicates a constant."
	<var: #aRoutine type: #'void *'>
	<var: #aString type: #'char *'>
	| startAddress |
	<inline: false>
	startAddress := methodZoneBase.
	self zeroOpcodeIndex.
	backEnd genPushRegisterArgsForNumArgs: numArgs scratchReg: SendNumArgsReg.
	objectRepresentation selectorIndexDereferenceRoutine ifNotNil: [:routine| 
		backEnd hasLinkRegister ifTrue: [self PushR: LinkReg].
		self Call: routine.
		backEnd hasLinkRegister ifTrue: [self PopR: LinkReg]. ].
	self genTrampolineFor: aRoutine
		called: aString
		numArgs: 4
		arg: regOrConst0
		arg: regOrConst1
		arg: regOrConst2
		arg: regOrConst3
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true.
	^startAddress
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genSistaExtStoreAndPopReceiverVariableBytecodePopBoolean: popBoolean [
	<inline: true>
	| index needsStoreCheck needsImmCheck maybeContext result |
	needsStoreCheck := self sistaNeedsStoreCheck.
	needsImmCheck := self extBSpecifiesImmCheck.
	"Long form and short form exist for popInto. Only the long form exists for store.
	Store have an explicit flag to mark context accessing, while popInto context accessing are done through the long form,
	hence generate the context form if the flag is set or if this is a popInto."
	maybeContext := popBoolean or: [self extBSpecifiesMaybeContext].
	extB := 0.
	numExtB := 0.
	index := byte1 + (extA << 8).
	extA := 0.
	result := ((coInterpreter isWriteMediatedContextInstVarIndex: index) and: [maybeContext])
		ifTrue: [self 
				genStorePop: popBoolean 
				MaybeContextReceiverVariable: index 
				needsStoreCheck: needsStoreCheck 
				needsImmutabilityCheck: needsImmCheck]
		ifFalse: [self 
				 genStorePop: popBoolean 
				 ReceiverVariable: index 
				 needsStoreCheck: needsStoreCheck 
				 needsImmutabilityCheck: needsImmCheck].
	self cppIf: IMMUTABILITY ifTrue: [ needsImmCheck ifFalse: [self annotateBytecode: self Label ] ].
	^result
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genSistaExtStoreLiteralVariableBytecodePopBoolean: boolean [
	<inline: true>
	| index needsStoreCheck needsImmCheck |
	needsStoreCheck := self sistaNeedsStoreCheck.
	needsImmCheck := self extBSpecifiesImmCheck.
	index := byte1 + (extA << 8).
	extA := numExtB := extB := 0.
	^self 
		genStorePop: boolean 
		LiteralVariable: index 
		needsStoreCheck: needsStoreCheck 
		needsImmutabilityCheck: needsImmCheck
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genSpecialSelectorArithmetic [
	| primDescriptor rcvrIsConst argIsConst rcvrIsInt argIsInt rcvrInt argInt result
	 jumpNotSmallInts jumpContinue index |
	<var: #jumpContinue type: #'AbstractInstruction *'>
	<var: #primDescriptor type: #'BytecodeDescriptor *'>
	<var: #jumpNotSmallInts type: #'AbstractInstruction *'>
	primDescriptor := self generatorAt: byte0.

	argIsInt := ((argIsConst := self ssTop type = SSConstant)
				 and: [objectMemory isIntegerObject: (argInt := self ssTop constant)])
				 or: [self mclassIsSmallInteger and: [self ssTop isSameEntryAs: self simSelf]].

	rcvrIsInt := ((rcvrIsConst := (self ssValue: 1) type = SSConstant)
				  and: [objectMemory isIntegerObject: (rcvrInt := (self ssValue: 1) constant)])
				or: [self mclassIsSmallInteger and: [(self ssValue: 1) isSameEntryAs: self simSelf]].

	(argIsInt and: [argIsConst and: [rcvrIsInt and: [rcvrIsConst]]]) ifTrue:
		[rcvrInt := objectMemory integerValueOf: rcvrInt.
		 argInt := objectMemory integerValueOf: argInt.
		 primDescriptor opcode caseOf: {
			[AddRR]	-> [result := rcvrInt + argInt].
			[SubRR]	-> [result := rcvrInt - argInt].
			[AndRR]	-> [result := rcvrInt bitAnd: argInt].
			[OrRR]	-> [result := rcvrInt bitOr: argInt] }.
		(objectMemory isIntegerValue: result) ifTrue:
			["Must annotate the bytecode for correct pc mapping."
			^self ssPop: 2; ssPushAnnotatedConstant: (objectMemory integerObjectOf: result)].
		^self genSpecialSelectorSend].

	"If there's any constant involved other than a SmallInteger don't attempt to inline."
	((rcvrIsConst and: [rcvrIsInt not])
	 or: [argIsConst and: [argIsInt not]]) ifTrue:
		[^self genSpecialSelectorSend].

	"If we know nothing about the types then better not to inline as the inline cache and
	 primitive code is not terribly slow so wasting time on duplicating tag tests is pointless."
	(argIsInt or: [rcvrIsInt]) ifFalse:
		[^self genSpecialSelectorSend].

	argIsConst
		ifTrue:
			[self ssFlushTo: simStackPtr - 2.
			 (self ssValue: 1) moveToReg: ReceiverResultReg.
			 self ssPop: 2]
		ifFalse:
			[self marshallSendArguments: 1].
	jumpNotSmallInts := (rcvrIsInt and: [argIsInt]) ifFalse:
							[argIsInt
								ifTrue: [self genJumpNotSmallInteger: ReceiverResultReg]
								ifFalse:
									[rcvrIsInt
										ifTrue: [self genJumpNotSmallInteger: Arg0Reg]
										ifFalse: [objectRepresentation genJumpNotSmallIntegersIn: ReceiverResultReg and: Arg0Reg scratch: TempReg]]].
	primDescriptor opcode caseOf: {
		[AddRR] -> [argIsConst
						ifTrue:
							[self AddCq: argInt - ConstZero R: ReceiverResultReg.
							 jumpContinue := self JumpNoOverflow: 0.
							 "overflow; must undo the damage before continuing"
							 self SubCq: argInt - ConstZero R: ReceiverResultReg]
						ifFalse:
							[objectRepresentation genRemoveSmallIntegerTagsInScratchReg: ReceiverResultReg.
							 self AddR: Arg0Reg R: ReceiverResultReg.
							jumpContinue := self JumpNoOverflow: 0.
							"overflow; must undo the damage before continuing"
							 (rcvrIsInt and: [rcvrIsConst])
								ifTrue: [self MoveCq: rcvrInt R: ReceiverResultReg]
								ifFalse:
									[self SubR: Arg0Reg R: ReceiverResultReg.
									 objectRepresentation genSetSmallIntegerTagsIn: ReceiverResultReg]]].
		[SubRR] -> [argIsConst
						ifTrue:
							[self SubCq: argInt - ConstZero R: ReceiverResultReg.
							 jumpContinue := self JumpNoOverflow: 0.
							 "overflow; must undo the damage before continuing"
							 self AddCq: argInt - ConstZero R: ReceiverResultReg]
						ifFalse:
							[objectRepresentation genRemoveSmallIntegerTagsInScratchReg: Arg0Reg.
							 self SubR: Arg0Reg R: ReceiverResultReg.
							 jumpContinue := self JumpNoOverflow: 0.
							 "overflow; must undo the damage before continuing"
							 self AddR: Arg0Reg R: ReceiverResultReg.
							 objectRepresentation genSetSmallIntegerTagsIn: Arg0Reg]].
		[AndRR] -> [argIsConst
						ifTrue: [self AndCq: argInt R: ReceiverResultReg]
						ifFalse: [self AndR: Arg0Reg R: ReceiverResultReg].
					jumpContinue := jumpNotSmallInts ifNotNil: [self Jump: 0]].
		[OrRR]	-> [argIsConst
						ifTrue: [self OrCq: argInt R: ReceiverResultReg]
						ifFalse: [self OrR: Arg0Reg R: ReceiverResultReg].
					jumpContinue := jumpNotSmallInts ifNotNil: [self Jump: 0]] }.
	jumpNotSmallInts
		ifNil: [jumpContinue ifNil: "overflow cannot happen"
				[self annotateInstructionForBytecode.
				 self ssPushRegister: ReceiverResultReg.
				 ^0]]
		ifNotNil:
			[jumpNotSmallInts jmpTarget: self Label].
	argIsConst ifTrue:
		[self MoveCq: argInt R: Arg0Reg].
	index := byte0 - self firstSpecialSelectorBytecodeOffset.
	self genMarshalledSend: index negated - 1 numArgs: 1 sendTable: ordinarySendTrampolines.
	jumpContinue jmpTarget: self Label.
	^0
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genSpecialSelectorClass [
	| topReg |
	topReg := self ssTop registerOrNone.
	self ssPop: 1.
	(topReg = NoReg or: [topReg = ClassReg])
		ifTrue: [self ssAllocateRequiredReg: (topReg := SendNumArgsReg) and: ClassReg]
		ifFalse: [self ssAllocateRequiredReg: ClassReg].
	self ssPush: 1.
	self ssTop moveToReg: topReg.
	self
		genGetClassObjectOf: topReg
		into: ClassReg
		scratchReg: TempReg
		instRegIsReceiver: false.
	^self ssPop: 1; ssPushRegister: ClassReg
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genSpecialSelectorComparison [
	| nextPC postBranchPC targetPC primDescriptor branchDescriptor
	  rcvrIsInt rcvrIsConst argIsIntConst argInt jumpNotSmallInts inlineCAB index |
	<var: #primDescriptor type: #'BytecodeDescriptor *'>
	<var: #branchDescriptor type: #'BytecodeDescriptor *'>
	<var: #jumpNotSmallInts type: #'AbstractInstruction *'>
	self ssFlushTo: simStackPtr - 2.
	primDescriptor := self generatorAt: byte0.
	argIsIntConst := self ssTop type = SSConstant
				 and: [objectMemory isIntegerObject: (argInt := self ssTop constant)].
	rcvrIsInt := ((rcvrIsConst := (self ssValue: 1) type = SSConstant)
				  and: [objectMemory isIntegerObject: (self ssValue: 1) constant])
				or: [self mclassIsSmallInteger and: [(self ssValue: 1) isSameEntryAs: self simSelf]].

	(argIsIntConst and: [rcvrIsInt and: [rcvrIsConst]]) ifTrue:
		[^ self genStaticallyResolvedSpecialSelectorComparison].

	self extractMaybeBranchDescriptorInto: [ :descr :next :postBranch :target | 
		branchDescriptor := descr. nextPC := next. postBranchPC := postBranch. targetPC := target ].

	"Only interested in inlining if followed by a conditional branch."
	inlineCAB := branchDescriptor isBranchTrue or: [branchDescriptor isBranchFalse].
	"Further, only interested in inlining = and ~= if there's a SmallInteger constant involved.
	 The relational operators successfully statically predict SmallIntegers; the equality operators do not."
	(inlineCAB and: [primDescriptor opcode = JumpZero or: [primDescriptor opcode = JumpNonZero]]) ifTrue:
		[inlineCAB := argIsIntConst or: [rcvrIsInt]].
	inlineCAB ifFalse:
		[^self genSpecialSelectorSend].

	argIsIntConst
		ifTrue:
			[(self ssValue: 1) moveToReg: ReceiverResultReg.
			 self ssPop: 2]
		ifFalse:
			[self marshallSendArguments: 1].
	jumpNotSmallInts := (rcvrIsInt and: [argIsIntConst]) ifFalse:
							[argIsIntConst
								ifTrue: [self genJumpNotSmallInteger: ReceiverResultReg]
								ifFalse:
									[rcvrIsInt
										ifTrue: [self genJumpNotSmallInteger: Arg0Reg]
										ifFalse: [objectRepresentation genJumpNotSmallIntegersIn: ReceiverResultReg and: Arg0Reg scratch: TempReg]]].
	argIsIntConst
		ifTrue: [self CmpCq: argInt R: ReceiverResultReg]
		ifFalse: [self CmpR: Arg0Reg R: ReceiverResultReg].
	"Cmp is weird/backwards so invert the comparison.  Further since there is a following conditional
	 jump bytecode define non-merge fixups and leave the cond bytecode to set the mergeness."
	self genConditionalBranch: (branchDescriptor isBranchTrue
				ifTrue: [primDescriptor opcode]
				ifFalse: [self inverseBranchFor: primDescriptor opcode])
		operand: (self ensureNonMergeFixupAt: targetPC) asUnsignedInteger.
	self Jump: (self ensureNonMergeFixupAt: postBranchPC).
	jumpNotSmallInts ifNil:
		[self annotateInstructionForBytecode.
		 self ensureFixupAt: postBranchPC.
		 self ensureFixupAt: targetPC.
		 deadCode := true.
		 ^0].
	jumpNotSmallInts jmpTarget: self Label.
	argIsIntConst ifTrue:
		[self MoveCq: argInt R: Arg0Reg].
	index := byte0 - self firstSpecialSelectorBytecodeOffset.
	^self genMarshalledSend: index negated - 1 numArgs: 1 sendTable: ordinarySendTrampolines
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean LiteralVariable: litVarIndex [
	<inline: true>
	^self 
		genStorePop: popBoolean 
		LiteralVariable: litVarIndex 
		needsStoreCheck: self ssTopNeedsStoreCheck
		needsImmutabilityCheck: true "The generic store checks for IMMUTABILITY flag"
		
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean LiteralVariable: litVarIndex needsStoreCheck: needsStoreCheck needsImmutabilityCheck: needsImmCheck [
	<inline: false>
	"We need a frame because the association has to be in ReceiverResultReg for the various trampolines
	and ReceiverResultReg holds only the receiver in frameless methods."
	self assert: needsFrame.
	self genLoadLiteralVariable: litVarIndex in: ReceiverResultReg.
	^self 
		genGenericStorePop: popBoolean 
		slotIndex: ValueIndex 
		destReg: ReceiverResultReg
		needsStoreCheck: needsStoreCheck
		needsRestoreRcvr: false
		needsImmutabilityCheck: needsImmCheck
		
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean MaybeContextReceiverVariable: slotIndex [ 
	<inline: true>
	^self 
		genStorePop: popBoolean 
		MaybeContextReceiverVariable: slotIndex 
		needsStoreCheck: self ssTopNeedsStoreCheck
		needsImmutabilityCheck: true "The generic store checks for IMMUTABILITY flag"
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean MaybeContextReceiverVariable: slotIndex needsStoreCheck: needsStoreCheck needsImmutabilityCheck: needsImmCheck [
	<inline: false>
	"The reason we need a frame here is that assigning to an inst var of a context may
	 involve wholesale reorganization of stack pages, and the only way to preserve the
	 execution state of an activation in that case is if it has a frame."
	self assert: needsFrame.
	self ssFlushUpThroughReceiverVariable: slotIndex.
	self ensureReceiverResultRegContainsSelf.
	^self 
		genGenericStorePop: popBoolean 
		MaybeContextSlotIndex: slotIndex 
		needsStoreCheck: needsStoreCheck
		needsRestoreRcvr: true
		needsImmutabilityCheck: needsImmCheck
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean MaybeContextRemoteInstVar: slotIndex ofObjectAt: objectIndex needsStoreCheck: needsStoreCheck needsImmutabilityCheck: needsImmCheck [
	<inline: false>
	"The reason we need a frame here is that assigning to an inst var of a context may
	 involve wholesale reorganization of stack pages, and the only way to preserve the
	 execution state of an activation in that case is if it has a frame."
	self assert: needsFrame.
	self genLoadTemp: objectIndex in: ReceiverResultReg.
	^self 
		genGenericStorePop: popBoolean 
		MaybeContextSlotIndex: slotIndex 
		needsStoreCheck: needsStoreCheck
		needsRestoreRcvr: false
		needsImmutabilityCheck: needsImmCheck
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean ReceiverVariable: slotIndex [
	<inline: true>
	^self 
		genStorePop: popBoolean 
		ReceiverVariable: slotIndex 
		needsStoreCheck: self ssTopNeedsStoreCheck
		needsImmutabilityCheck: true "The generic store checks for IMMUTABILITY flag"
		
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean ReceiverVariable: slotIndex needsStoreCheck: needsStoreCheck needsImmutabilityCheck: needsImmCheck [
	<inline: false>
	self ssFlushUpThroughReceiverVariable: slotIndex.
	self ensureReceiverResultRegContainsSelf.
	"In two path compilation the receiver is young AND mutable, hence no store check nor immutability check is needed"
	^self 
		genGenericStorePop: popBoolean 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		needsStoreCheck: (useTwoPaths not and: [needsStoreCheck])
		needsRestoreRcvr: true "ReceiverResultReg is kept live with the receiver across the operation"
		needsImmutabilityCheck: (needsImmCheck and: [useTwoPaths not])
		
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean RemoteInstVar: slotIndex ofObjectAt: objectIndex needsStoreCheck: needsStoreCheck needsImmutabilityCheck: needsImmCheck [
	<inline: false>
	self assert: needsFrame.
	self genLoadTemp: objectIndex in: ReceiverResultReg.
	^self 
		genGenericStorePop: popBoolean 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		needsStoreCheck: needsStoreCheck
		needsRestoreRcvr: false
		needsImmutabilityCheck: needsImmCheck
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean RemoteTemp: slotIndex At: remoteTempIndex [
	<inline: true>
	^ self genStorePop: popBoolean RemoteTemp: slotIndex At: remoteTempIndex needsStoreCheck: self ssTopNeedsStoreCheck
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean RemoteTemp: slotIndex At: remoteTempIndex needsStoreCheck: needsStoreCheck [
	<inline: false>
	"The only reason we assert needsFrame here is that in a frameless method
	 ReceiverResultReg must and does contain only self, but the ceStoreCheck
	 trampoline expects the target of the store to be in ReceiverResultReg.  So
	 in a frameless method we would have a conflict between the receiver and
	 the temote temp store, unless we we smart enough to realise that
	 ReceiverResultReg was unused after the literal variable store, unlikely given
	 that methods return self by default."
	self assert: needsFrame.
	"N.B.  No need to check the stack for references because we generate code for
	 remote temp loads that stores the result in a register, deferring only the register push."
	self ssAllocateRequiredReg: ReceiverResultReg. 
	self voidReceiverResultRegContainsSelf.
	self MoveMw: (self frameOffsetOfTemporary: remoteTempIndex) r: FPReg R: ReceiverResultReg.
	TempVectReadBarrier
		ifTrue: [self
				genEnsureObjInRegNotForwarded: ReceiverResultReg
				scratchReg: TempReg].
	^self 
		genGenericStorePop: popBoolean 
		slotIndex: slotIndex 
		destReg: ReceiverResultReg 
		needsStoreCheck: needsStoreCheck
		needsRestoreRcvr: false "We don't keep ReceiverResultReg live with the receiver across this operation"
		needsImmutabilityCheck: false "never do immutability check on temp vectors"
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genStorePop: popBoolean TemporaryVariable: tempIndex [
	<inline: false>
	| reg |
	self ssFlushUpThroughTemporaryVariable: tempIndex.
	reg := self ssStorePop: popBoolean toPreferredReg: TempReg.
	self MoveR: reg
		Mw: (self frameOffsetOfTemporary: tempIndex)
		r: FPReg.
	(self simStackAt: tempIndex + 1) bcptr: bytecodePC. "for debugging"
	^0
]

{ #category : #'bytecode generator stores' }
PharoStackToRegisterMappingCogit >> genTraceStores [
	<inline: true>
	traceStores > 0 ifTrue: 
		[ self MoveR: ClassReg R: TempReg.
		self CallRT: ceTraceStoreTrampoline ].
]

{ #category : #'bytecode generators' }
PharoStackToRegisterMappingCogit >> genUpArrowReturn [
	"Generate a method return from within a method or a block.
	 Frameless method activation looks like
	 CISCs (x86):
				receiver
				args
		sp->	ret pc.
	 RISCs (ARM):
				receiver
				args
				ret pc in LR.
	 A fully framed activation is described in CoInterpreter class>initializeFrameIndices.
	 Return pops receiver and arguments off the stack.  Callee pushes the result."
	deadCode := true. "can't fall through"
	inBlock > 0 ifTrue:
		[self assert: needsFrame.
		 self ssFlushTo: simStackPtr.
		 self CallRT: ceNonLocalReturnTrampoline.
		 self annotateBytecode: self Label.
		 ^0].
	(self cppIf: IMMUTABILITY ifTrue: [needsFrame and: [useTwoPaths not]] ifFalse: [needsFrame])
		ifTrue:
			[ self MoveR: FPReg R: SPReg.
			 self PopR: FPReg.
			 backEnd hasLinkRegister ifTrue:
				[self PopR: LinkReg].
			 self RetN: methodOrBlockNumArgs + 1 * objectMemory wordSize]
		ifFalse:
			[self RetN: ((methodOrBlockNumArgs > self numRegArgs
						"A method with an interpreter prim will push its register args for the prim.  If the failure
						 body is frameless the args must still be popped, see e.g. Behavior>>nextInstance."
						or: [regArgsHaveBeenPushed])
							ifTrue: [methodOrBlockNumArgs + 1 * objectMemory wordSize]
							ifFalse: [0])].
	^0
]

{ #category : #testing }
PharoStackToRegisterMappingCogit >> isUnannotatableConstant: simStackEntry [
	<inline: true>
	<var: 'simStackEntry' type: #'CogSimStackEntry *'>
	^simStackEntry type = SSConstant 
	  and: [(objectMemory isImmediate: simStackEntry constant)
		or: [(self shouldAnnotateObjectReference: simStackEntry constant) not]]
]

{ #category : #'compile abstract instructions' }
PharoStackToRegisterMappingCogit >> slotOffsetOfInstVarIndex: index [

	^ index * objectMemory wordSize + objectMemory baseHeaderSize
]
