"
StackToRegisterMappingCogit is an optimizing code generator that eliminates a lot of stack operations and inlines some special selector arithmetic.  It does so by a simple stack-to-register mapping scheme based on deferring the generation of code to produce operands until operand-consuming operations.  The operations that consume operands are sends, stores and returns.  This scheme was first conceived by L. Peter Deutch in the HPS Smalltalk VM (the VisualWorks VM).  Thank you, Peter.

See methods in the class-side documentation protocol for more detail.

Instance Variables
	compilationPass:								<Integer>
	currentCallCleanUpSize:						<Integer>
	ceCall0ArgsPIC:									<Integer>
	ceCall1ArgsPIC:									<Integer>
	ceCall2ArgsPIC:									<Integer>
	ceCallCogCodePopReceiverArg0Regs:			<Integer>
	ceCallCogCodePopReceiverArg1Arg0Regs:		<Integer>
	deadCode										<Boolean>
	debugBytecodePointers:						<Set of Integer>
	debugFixupBreaks:								<Set of Integer>
	debugStackPointers:							<CArrayAccessor of (Integer|nil)>
	hasNativeFrame								<Boolean>
	methodAbortTrampolines:						<CArrayAccessor of Integer>
	methodOrBlockNumTemps:						<Integer>
	numPushNilsFunction:							<Symbol>
	picAbortTrampolines:							<CArrayAccessor of Integer>
	picMissTrampolines:							<CArrayAccessor of Integer>
	pushNilSizeFunction:							<Symbol>
	realCECallCogCodePopReceiverArg0Regs:		<Integer>
	realCECallCogCodePopReceiverArg1Arg0Regs:	<Integer>
	regArgsHaveBeenPushed:						<Boolean>
	simNativeSpillBase:								<Integer>
	simNativeStack:								<CArrayAccessor of CogSimStackNativeEntry>
	simNativeStackPtr:								<Integer>
	simNativeStackSize:							<Integer>
	simSpillBase:									<Integer>
	simStack:										<CArrayAccessor of CogSimStackEntry>
	simStackPtr:									<Integer>
	traceSimStack:									<Integer>
	useTwoPaths									<Boolean>

compilationPass
	- counter indicating whether on the first pass through bytecodes in a V3-style embedded block or not.  The V3 closure implementation uses pushNil to initialize temporary variables and this makes an initial pushNil ambiguous.  With the V3 bytecode set, the JIT must compile to the end of the block to discover if a pushNil is for initializing a temp or to produce an operand.

currentCallCleanUpSize
	- the number of bytes to remove from the stack in a Lowcode call.

ceCall0ArgsPIC ceCall1ArgsPIC ceCall2ArgsPIC
	- the trampoline for entering an N-arg PIC

ceCallCogCodePopReceiverArg0Regs ceCallCogCodePopReceiverArg1Arg0Regs
	- the trampoline for invokinging a method with N register args
	
debugBytecodePointers
	- a Set of bytecode pcs for setting breakpoints (simulation only)

deadCode
	- set to true to indicate that the next bytecode (up to the next fixup) is not reachable.  Used to avoid generating dead code.

debugFixupBreaks
	- a Set of fixup indices for setting breakpoints (simulation only)

debugStackPointers
	- an Array of stack depths for each bytecode for code verification (simulation only)

hasNativeFrame
	- set to true when Lowcode creates a native stack frame for Lowcode callouts.

methodAbortTrampolines
	- a CArrayAccessor of abort trampolines for 0, 1, 2 and N args

methodOrBlockNumTemps
	- the number of method or block temps (including args) in the current compilation unit (method or block)

numPushNilsFunction
	- the function used to determine the number of push nils at the beginning of a block.  This abstracts away from the specific bytecode set(s).

picAbortTrampolines
	- a CArrayAccessor of abort trampolines for 0, 1, 2 and N args

picMissTrampolines
	- a CArrayAccessor of abort trampolines for 0, 1, 2 and N args

pushNilSizeFunction
	- the function used to determine the number of bytes in the push nils bytecode(s) at the beginning of a block.  This abstracts away from the specific bytecode set(s).

realCECallCogCodePopReceiverArg0Regs realCECallCogCodePopReceiverArg1Arg0Regs
	- the real trampolines for invoking machine code with N reg args when in the Debug regime

regArgsHaveBeenPushed
	- whether the register args have been pushed before frame build (e.g. when an interpreter primitive is called)

simNativeSpillBase
	- the variable tracking how much of the Lowcode simulation stack has been spilled to the real stack

simNativeStack
	- the Lowcode simulation stack itself

simNativeStackPtr
	- the pointer to the top of the Lowcode simulation stack

simNativeStackSize
	- the size of the Lowcode stack so far

simSpillBase
	- the variable tracking how much of the simulation stack has been spilled to the real stack

simStack
	- the simulation stack itself, comprising the receiver, arguments, temporaries, and volatile stack contents.  The receiver is the 0'th entry, and the 1st is that of the first argument, etc.

simStackPtr
	- the pointer to the top of the simulation stack

useTwoPaths
	- a variable controlling whether to create two paths through a method based on the existence of inst var stores.  With immutability this causes a frameless path to be generated if an otherwise frameless method is frameful simply because of inst var stores.  In this case the test to take the first frameless path is if the receiver is not immutable.  Without immutability, if a frameless method contains two or more inst var stores, the first path will be code with no store check, chosen by a single check for the receiver being in new space.

"
Class {
	#name : #StackToRegisterMappingCogit,
	#superclass : #SimpleStackBasedCogit,
	#instVars : [
		'prevBCDescriptor',
		'numPushNilsFunction',
		'pushNilSizeFunction',
		'methodOrBlockNumTemps',
		'regArgsHaveBeenPushed',
		'simStack',
		'simStackPtr',
		'simSpillBase',
		'ceCallCogCodePopReceiverArg0Regs',
		'ceCallCogCodePopReceiverArg1Arg0Regs',
		'methodAbortTrampolines',
		'picAbortTrampolines',
		'picMissTrampolines',
		'ceCall0ArgsPIC',
		'ceCall1ArgsPIC',
		'ceCall2ArgsPIC',
		'debugStackPointers',
		'debugFixupBreaks',
		'realCECallCogCodePopReceiverArg0Regs',
		'realCECallCogCodePopReceiverArg1Arg0Regs',
		'deadCode',
		'useTwoPaths',
		'counterIndex'
	],
	#classVars : [
		'NeedsMergeFixupFlag',
		'NeedsNonMergeFixupFlag'
	],
	#pools : [
		'CogCompilationConstants',
		'VMMethodCacheConstants',
		'VMObjectIndices',
		'VMStackFrameOffsets'
	],
	#classInstVars : [
		'numPushNilsFunction',
		'pushNilSizeFunction'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #translation }
StackToRegisterMappingCogit class >> ancilliaryClasses [
	^super ancilliaryClasses,
	  { self basicNew simStackEntryClass. self basicNew bytecodeFixupClass. CogSSOptStatus }
]

{ #category : #documentation }
StackToRegisterMappingCogit class >> callingConvention [
	"The Smalltalk-to-Smalltalk calling convention aims to trade simplicity of compilation against
	 effectiveness of optimization.  Most Smalltalk methods, and certainly most performance-
	 critical primitives have two or less arguments.  So arranging that the receiver and up to two
	 args are in registers means that performance-critical primitives can access their arguments
	 in registers.  So if the argument count is <= numRegArgs nothing is passed on the stack and
	 everything is passed in ReceiverResultReg, Arg0Reg et al.  Above numRegArgs everything is
	 passed on the stack.

	 To save the CoInterpreter from change we shuffle the retpc and push the register args in
	 the prolog so that the frame format is unchanged by register args.  Also, the trampolines for
	 unlinked sends do the same, as does the code preceding an interpreter primitive.  It turns
	 out that this protocol is faster than always pushing arguments.  Comparing benchFib with the
	 shuffling protocol against an always-push protocol on a 2.66 GHz Core i7 (MacBook Pro) , the
	 shuffling protocol is 6.3% faster than the always push protocol.

	 Not shuffling the stack and pushing register arguments after frame build is faster yet again,
	 5.8% faster that the stack shuffle.  So it might be worth-while to change the CoInterpreter's
	 frame management to allow numArgs <= numRegArgs frames to push receiver and arguments
	 after saving the return pc.  This implies changes in stack-to-context mapping, GC,
	 interpreter-to-machine code frame conversion and no doubt else where.

	 Hence the calling convention is

		- if the number of arguments is less than or equal to numRegArgs then the receiver and
		  arguments are passed in registers.  numRegArgs is 1 for V3, and 2 for Spur.  The receiver
		  is passed in ReceiverResultReg, the first argument in Arg0Reg (esi on x86) and the second
		  argument (if numRegArgs = 2) in Arg1Reg (edi on x86).

		- if the number of arguments is greater than numRegArgs then the calling convention is as
		  for SimpleStackBasedCogIt; ReceiverResultReg contains the receiver, and the receiver and
		  arguments are all on the stack, receiver furthest from top-of-stack.  If the argument count
		  is > 2 then argument count is passed in SendNumArgsReg (for the benefit of the run-time
		  linking routines; it is ignored in linked sends).

		On return the result is in ReceiverResultReg.  The callee removes arguments from the stack
		(Pascal convention).

		Note that if a machine code method contains a call to an interpreter primitive it will push any
		register arguments (and if on a RISC, the return pc from the LinReg) on the stack before calling
		the primitive so that to the primitive the stack looks the same as it does in the interpreter.

		Within all machine code primitives except genPrimitiveClosureValue and genPrimitivePerform all
		arguments are taken from registers since no machine code primitive has more than numRegArgs
		arguments.  genPrimitiveClosureValue pushes its register arguments immedately only for laziness
		to be able to reuse SimpleStackBasedCogit's code.  genPrimitivePerform adjusts its arguments
		as required by special-purpose code.

		Within machine code methods with interpreter primitives the register arguments are pushed
		before calling the interpreter primitive.  In normal methods and if not already done so in primitive
		code, the register arguments are pushed during frame build.  If a method is compiled frameless
		it will access its arguments in registers."
]

{ #category : #translation }
StackToRegisterMappingCogit class >> declareCVarsIn: aCodeGen [
	aCodeGen
		var: #methodAbortTrampolines
			declareC: 'sqInt methodAbortTrampolines[4]';
		var: #picAbortTrampolines
			declareC: 'sqInt picAbortTrampolines[4]';
		var: #picMissTrampolines
			declareC: 'sqInt picMissTrampolines[4]';
		var: 'ceCall0ArgsPIC'
			declareC: 'void (*ceCall0ArgsPIC)(void)';
		var: 'ceCall1ArgsPIC'
			declareC: 'void (*ceCall1ArgsPIC)(void)';
		var: 'ceCall2ArgsPIC'
			declareC: 'void (*ceCall2ArgsPIC)(void)';
		var: #ceCallCogCodePopReceiverArg0Regs
			declareC: 'void (*ceCallCogCodePopReceiverArg0Regs)(void)';
		var: #realCECallCogCodePopReceiverArg0Regs
			declareC: 'void (*realCECallCogCodePopReceiverArg0Regs)(void)';
		var: #ceCallCogCodePopReceiverArg1Arg0Regs
			declareC: 'void (*ceCallCogCodePopReceiverArg1Arg0Regs)(void)';
		var: #realCECallCogCodePopReceiverArg1Arg0Regs
			declareC: 'void (*realCECallCogCodePopReceiverArg1Arg0Regs)(void)';
		var: 'simStack'
			declareC: 'SimStackEntry simStack[', self simStackSlots asString, ']';
		var: 'simSelf'
			type: #CogSimStackEntry;
		var: #optStatus
			type: #CogSSOptStatus;
		var: 'prevBCDescriptor'
			type: #'BytecodeDescriptor *'.

	self numPushNilsFunction ifNotNil:
		[aCodeGen
			var: 'numPushNilsFunction'
				declareC: 'sqInt (* const numPushNilsFunction)(struct _BytecodeDescriptor *,sqInt,sqInt,sqInt) = ', (aCodeGen cFunctionNameFor: self numPushNilsFunction);
			var: 'pushNilSizeFunction'
				declareC: 'sqInt (* const pushNilSizeFunction)(sqInt,sqInt) = ', (aCodeGen cFunctionNameFor: self pushNilSizeFunction)].

	aCodeGen
		addSelectorTranslation: #register to: (aCodeGen cFunctionNameFor: 'registerr');
		addSelectorTranslation: #register: to: (aCodeGen cFunctionNameFor: 'registerr:')
]

{ #category : #'class initialization' }
StackToRegisterMappingCogit class >> initializeSimStackConstants [
	"The simulation stack is used to delay code generation until operands are consumed by
	 some operation, thereby avoiding pushing operands to the real stack and enabling
	 mapping stack contents to registers, and cheaply apply various peephole optimizations.
	 The simulation stack is an array of CogSimStackEntry structs.  Each entry defines the
	 object on the virtual stack (Smalltalk context stack) as compilation proceeds.  See
	 stackToRegisterMapping in this class for documentation."

	SSBaseOffset := 1.
	SSConstant := 2.
	SSRegister := 3.
	SSSpill := 4.
	
	SSVectorRegister := 18.
]

{ #category : #'class initialization' }
StackToRegisterMappingCogit class >> initializeWithOptions: optionsDictionary [

	super initializeWithOptions: optionsDictionary.
	self initializeSimStackConstants
]

{ #category : #translation }
StackToRegisterMappingCogit class >> isAcceptableAncilliaryClass: aClass [
	^(aClass includesBehavior: CogBytecodeFixup)
		ifTrue: [aClass == self basicNew bytecodeFixupClass]
		ifFalse:
			[(aClass includesBehavior: CogSimStackEntry)
				ifTrue: [aClass == self basicNew simStackEntryClass]
				ifFalse: [true]]
]

{ #category : #translation }
StackToRegisterMappingCogit class >> mustBeGlobal: var [
	"Answer if a variable must be global and exported.  Used for inst vars that are accessed from VM support code."

	^(super mustBeGlobal: var)
	   or: [#('ceCallCogCodePopReceiverArg0Regs' 'ceCallCogCodePopReceiverArg1Arg0Regs'
			'realCECallCogCodePopReceiverArg0Regs' 'realCECallCogCodePopReceiverArg1Arg0Regs'
			'ceCall0ArgsPIC' 'ceCall1ArgsPIC' 'ceCall2ArgsPIC') includes: var]
]

{ #category : #accessing }
StackToRegisterMappingCogit class >> numPushNilsFunction [
	"Answer the value of numPushNilsFunction"

	^numPushNilsFunction
]

{ #category : #accessing }
StackToRegisterMappingCogit class >> numTrampolines [
	^super numTrampolines + 12 "includes register args aborts"

	"Cogit withAllSubclasses collect: [:c| {c. (c instVarNames select: [:ea| ea beginsWith: 'ce']) size}]"
	"self instVarNames select: [:ea| ea beginsWith: 'ce']"
]

{ #category : #accessing }
StackToRegisterMappingCogit class >> pushNilSizeFunction [
	"Answer the value of pushNilSizeFunction"

	^ pushNilSizeFunction
]

{ #category : #translation }
StackToRegisterMappingCogit class >> requiredMethodNames: options [
	^(super requiredMethodNames: options)
		add: self numPushNilsFunction;
		add: self pushNilSizeFunction;
		yourself
]

{ #category : #translation }
StackToRegisterMappingCogit class >> shouldGenerateTypedefFor: aStructClass [
	"Hack to work-around mutliple definitions.  Sometimes a type has been defined in an include."
	^aStructClass ~~ CogBytecodeFixup "overridden by CogSSBytecodeFixup"
	  and: [super shouldGenerateTypedefFor: aStructClass]
]

{ #category : #translation }
StackToRegisterMappingCogit class >> simNativeStackSlots [
	^ self basicNew simNativeStackSlots
]

{ #category : #translation }
StackToRegisterMappingCogit class >> simStackSlots [
	^ self basicNew simStackSlots
]

{ #category : #documentation }
StackToRegisterMappingCogit class >> stackToRegisterMapping [
	"Stack to register mapping is enabled via a simulation stack { simStack. simStackPtr, simSpillBase } of
	 operand descriptors (CogSimStackEntry) which serve
		- to avoid pushing operands to the actual stack by deferring operand manipulation until an
		  operand-consuming operation (send, store, run-time call)
		- to record operand type information for constants to avoid unnecessary type checks (e.g. tag checks)
		- as a simple register allocator since any live registers are recorded in descriptors on the stack.

	The operand types are
		SSBaseOffset - a value in memory at an offset relative to some register.  For method receiver args
						 and temps the base register is  FPReg (in a frameful method).  For indirect temps
						 the register could be any unassigned register.
		SSConstant - a method literal, hence a Smalltalk object
		SSRegister - the result of an expression assigned to a register
		SSSpill - a value spilled to the actual stack
	The special descriptor simSelf defines self in the current method, relative to FPReg in frameful
	 methods and  in a register in frameless methods.

	The register allocator aspect allocates registers by searching for SSBaseOffset and SSRegister
	 descriptors, computing the set of live registers, and then enumerating to find unused ones.
	 Simulation stack contents must be spilled to the actual stack
		- at a send (since at a suspension point the actual stack must be valid),
		- to make a register available if the code generator needs it
		- at a control flow join (since the two control flows could compute different stack contents and
		  we choose to avoid the complexity of saving stack contents to allow merging at join points).

	At a control-flow join we must discard type information for values pushed to the stack in either
	arm of the control-flow, but need /not/ for items pushed before the control flow diverged.  e.g. in
		self at: 1 put: (expr ifTrue: [v1] ifFalse: [v2]).
	the 1 is still valid after the control flow join for (expr ifTrue: [v1] ifFalse: [v2]).  So at a conditional
	branch we record simStackPtr in the target fixup and only void types between it and the
	simStackPtr at the join point.  This type voiding operation is called merge:.  For now we simply throw
	away all type info but would like to implement the baove scheme soon.

	 We can determine the stack depth at a conditional branch (if), but how do we determine the stack
	 depth following an unconditional jump (else)?  There are essentially three cases
		e ifTrue: [u] ifFalse: [v],
		e ifTrue: [^u] ifFalse: [v],
		e ifTrue: [u] ifFalse: [^v]

		1		expr
		2		jumpCond L1
		3		push
		4		jump L2
		5	L1:
		6		push
		7	L2:

		1		expr
		2		jumpCond L1
		3		ret
		4	L1:
		5		push

		1		expr
		2		jumpCond L1
		3		push
		4		jump L2
		5	L1:
		6		ret
		7	L2:

	In the first case we can know the merge base at L2 by propagating the merge base from 4 jump L2, which
	precedes the target of 2 jumpCond L1.  i.e. the merge base at 7 L2 is the stack pointer at 4 jump L2, which
	precedes the target of 2 jumpCond L1.  So at 2 jumpCond L1 we copy the stack pointer to the merge base
	at 5 L1, /and/ to the preceding 4 jump L2, and when we reach 4 jump L2, propagate the merge base to 7 L2.

	 Since we're conscious of JIT performance we restrict the live register search range by maintaining
	 simSpillBase, which is the index of the unspilled entry furthest from the end of simulation stack.
	 Only entries from simSpillBase to simStackPtr can contain unspilled, and hence live and volatile
	 registers (the FPReg is not volatile).

	 We further optimize by maintaining a simple optimization status for register contents.
	 We record whether ReceiverResultReg contains the receiver or an indirect temp vector
	 and merge this status at control-flow joins."
]

{ #category : #'primitive generators' }
StackToRegisterMappingCogit >> adjustArgumentsForPerform: numArgs [
	"Generate code to adjust the possibly stacked arguments immediately
	 before jumping to a method looked up by a perform primitive."
	self assert: self numRegArgs <= 2.
	self assert: numArgs >= 1.
	numArgs <= self numRegArgs ifTrue:
		[numArgs = 2 ifTrue:
			[self MoveR: Arg1Reg R: Arg0Reg].
		 ^self].

	"If the arity is one more than the max numRegArgs, the receiver and all arguments have to be removed from the stack."
	self numRegArgs + 1 = numArgs ifTrue:
		[backEnd hasLinkRegister
			ifTrue:
				[self numRegArgs = 2
					ifTrue:
						[self MoveMw: 0 r: SPReg R: Arg1Reg.
						 self MoveMw: self wordSize r: SPReg R: Arg0Reg]
					ifFalse:
						[self MoveMw: 0 r: SPReg R: Arg0Reg].
				 self AddCq: numArgs + 1 * self wordSize R: SPReg]
			ifFalse:
				[self MoveMw: 0 r: SPReg R: TempReg. "save retpc"
				 self numRegArgs = 2
					ifTrue:
						[self MoveMw: self wordSize r: SPReg R: Arg1Reg.
						 self MoveMw: self wordSize * 2 r: SPReg R: Arg0Reg]
					ifFalse:
						[self MoveMw: self wordSize r: SPReg R: Arg0Reg].
				 self AddCq: numArgs + 1 * self wordSize R: SPReg.
				 self MoveR: TempReg Mw: 0 r: SPReg "Overwrite pushed receiver; ReceiverResultReg already contains receiver."].
		 ^self].

	"e.g.	Receiver				Receiver
			Selector/Arg0	=>		Arg1
			Arg1					Arg2
	 		Arg2			sp->	Arg3
	 sp->	Arg3"
	super adjustArgumentsForPerform: numArgs
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateFloatRegNotConflictingWith: regMask [
	| reg |
	"if there's a free register, use it"
	reg := backEnd availableFloatRegisterOrNoneFor: (self liveFloatRegisters bitOr: regMask).
	reg = NoReg ifTrue: "No free register, choose one that does not conflict with regMask"
		[reg := self freeAnyFloatRegNotConflictingWith: regMask].
	^ reg
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateRegForStackEntryAt: index [
	"If the stack entry is already in a register, answers it,
	else allocate a new register for it"
	<inline: true>
	^ self allocateRegForStackEntryAt: index notConflictingWith: 0
	
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateRegForStackEntryAt: index notConflictingWith: regMask [
	"If the stack entry is already in a register not conflicting with regMask, answers it,
	else allocate a new register not conflicting with reg mask"
	<var: #stackEntry type: #'CogSimStackEntry *'>
	| stackEntry mask |
	stackEntry := self ssValue: index.
	mask := stackEntry registerMaskOrNone.
	(mask ~= 0 and: [mask noMask: regMask]) ifTrue: 
		[self flag: #TODO.
		"When one does pushDup on a SSRegister
		 followed by an operation reusing the register 
		 but mutating the value of the register, then the value that was 
		 dup is now refering to the register with a mutated value which
		 is incorrect. This problem is serious as it can happen also with 
		 multiple unsafe instructions (no dup involved)
		 This is not a problem if the operation reusing the register is not 
		 mutating the value of if all the dup values are used in the same 
		 operation.
		 => I think we should introduce allocateRegMutatingStackEntryAt:
		notConflictingWith:upThrough:, used by operations mutating the reg
		value and flushing partially the stack if somewhere between simSpill
		and the ssEntries used by the operation someone uses also the same
		register."
		 ^stackEntry registerOrNone].
	^self allocateRegNotConflictingWith: regMask
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateRegForStackTopThreeEntriesInto: trinaryBlock thirdIsReceiver: thirdIsReceiver [
	"Answers registers for the 3 top values on stack. If the values are already in registers, answers
	these registers, else allocate registers not conflicting with each others.
	If thirdIsReceiver is true, allocate ReceiverResultReg for stackTop - 2 (for ceStoreCheck)."
	<inline: true>
	| topRegistersMask rTop rNext rThird |
	
	topRegistersMask := 0.
	rTop := rNext := rThird := NoReg.
	
	(self ssTop registerOrNone ~= NoReg and: [ thirdIsReceiver not or: [ self ssTop registerOrNone ~= ReceiverResultReg ] ]) ifTrue: 
		[ topRegistersMask := self registerMaskFor: (rTop := self ssTop registerOrNone)].
	((self ssValue: 1) registerOrNone ~= NoReg and: [ thirdIsReceiver not or: [ (self ssValue: 1) registerOrNone ~= ReceiverResultReg ] ]) ifTrue: 
		[ topRegistersMask := topRegistersMask bitOr: (self registerMaskFor: (rNext := (self ssValue: 1) registerOrNone))].
	((self ssValue: 2) registerOrNone ~= NoReg and: [thirdIsReceiver not or: [ (self ssValue: 2) registerOrNone = ReceiverResultReg ] ]) ifTrue: 
		[ topRegistersMask := topRegistersMask bitOr: (self registerMaskFor: (rThird := (self ssValue: 2) registerOrNone))].
	
	rThird = NoReg ifTrue:
		[ thirdIsReceiver 
			ifTrue:
				[ rThird := ReceiverResultReg.  "Free ReceiverResultReg if it was not free"
				self ssAllocateRequiredReg: ReceiverResultReg.
				self voidReceiverResultRegContainsSelf ]
			ifFalse: [ rThird := self allocateRegNotConflictingWith: topRegistersMask ].
		topRegistersMask := topRegistersMask bitOr: (self registerMaskFor: rThird) ].
	
	rTop = NoReg ifTrue:
		[ rTop := self allocateRegNotConflictingWith: topRegistersMask.
		  topRegistersMask := topRegistersMask bitOr: (self registerMaskFor: rTop) ].
	
	rNext = NoReg ifTrue:
		[ rNext := self allocateRegNotConflictingWith: topRegistersMask ].

	self deny: (rTop = NoReg or: [rNext = NoReg or: [rThird = NoReg]]).

	^ trinaryBlock value: rTop value: rNext value: rThird
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateRegForStackTopTwoEntriesInto: binaryBlock [
	"Answers registers for the 2 top values on stack. If the values are already in registers, answers
	these registers, else allocate registers not conflicting with each others."

	| topRegistersMask rTop rNext |
	
	topRegistersMask := 0.
	rTop := rNext := NoReg.
	
	self ssTop  registerOrNone ~= NoReg ifTrue: 
		[ rTop := self ssTop registerOrNone].
	(self ssValue: 1)  registerOrNone ~= NoReg ifTrue: 
		[ topRegistersMask := self registerMaskFor: (rNext := (self ssValue: 1) registerOrNone)].
	
	rTop = NoReg ifTrue:
		[ rTop := self allocateRegNotConflictingWith: topRegistersMask ].
	
	rNext = NoReg ifTrue:
		[ rNext := self allocateRegNotConflictingWith: (self registerMaskFor: rTop) ].

	self deny: (rTop = NoReg or: [rNext = NoReg]).

	^ binaryBlock value: rTop value: rNext
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateRegNotConflictingWith: regMask [
	| reg |
	"if there's a free register, use it"
	reg := backEnd availableRegisterOrNoneFor: (self liveRegisters bitOr: regMask).
	reg = NoReg ifTrue: "No free register, choose one that does not conflict with regMask"
		[reg := self freeAnyRegNotConflictingWith: regMask].
	reg = ReceiverResultReg ifTrue: "If we've allocated RcvrResultReg, it's not live anymore"
		[self voidReceiverResultRegContainsSelf].
	^ reg
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateVectorRegForStackEntryAt: index notConflictingWith: regMask [
	"If the stack entry is already in a register not conflicting with regMask, answers it,
	else allocate a new register not conflicting with reg mask"
	<var: #stackEntry type: #'CogSimStackEntry *'>
	| stackEntry mask |
	stackEntry := self ssValue: index.
	mask := stackEntry registerMaskOrNone.
	(mask ~= 0 and: [mask noMask: regMask]) ifTrue: 
		[self flag: #TODO.
		"When one does pushDup on a SSRegister
		 followed by an operation reusing the register 
		 but mutating the value of the register, then the value that was 
		 dup is now refering to the register with a mutated value which
		 is incorrect. This problem is serious as it can happen also with 
		 multiple unsafe instructions (no dup involved)
		 This is not a problem if the operation reusing the register is not 
		 mutating the value of if all the dup values are used in the same 
		 operation.
		 => I think we should introduce allocateRegMutatingStackEntryAt:
		notConflictingWith:upThrough:, used by operations mutating the reg
		value and flushing partially the stack if somewhere between simSpill
		and the ssEntries used by the operation someone uses also the same
		register."
		 ^stackEntry registerOrNone].
	^self allocateVectorRegNotConflictingWith: regMask
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> allocateVectorRegNotConflictingWith: regMask [
	| reg |
	"if there's a free register, use it"
	reg := backEnd availableVectorRegisterOrNoneFor: (self liveVectorRegisters bitOr: regMask).
	"reg = NoReg ifTrue: ""No free register, choose one that does not conflict with regMask""
		[reg := self freeAnyRegNotConflictingWith: regMask]."
	^ reg
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> annotateInstructionForBytecode [
	"Annotate the current instruction as having a bytecode pc.  If the current instruction
	 is already annotated, insert a nop and annotate that.  We cannot have the same instruction
	 address carry multiple annotations."
	<inline: true>
	self annotateBytecode: (self prevInstIsPCAnnotated
								ifTrue: [self Nop]
								ifFalse: [self Label]).
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> anyReferencesToRegister: reg inAllButTopNItems: n [
	| regMask |
	regMask := self registerMaskFor: reg.
	simStackPtr - n to: 0 by: -1 do:
		[:i|
		((self simStackAt: i) registerMask anyMask: regMask) ifTrue:
			[^true]].
	^false
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> anyReferencesToRegister: reg inTopNItems: n [
	| regMask |
	regMask := self registerMaskFor: reg.
	simStackPtr to: simStackPtr - n + 1 by: -1 do:
		[:i|
		((self simStackAt: i) registerMask anyMask: regMask) ifTrue:
			[^true]].
	^false
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> assertCorrectSimStackPtr [
	<inline: true>
	"Would like to assert simply simSpillBase > methodOrBlockNumTemps but can't because
	 of the initialNils hack for nested blocks in SqueakV3PlusClosures"
	self assert: (simSpillBase >= methodOrBlockNumTemps).
	(needsFrame and: [simSpillBase > 0]) ifTrue:
		[self assert: (self simStackAt: simSpillBase - 1) spilled == true.
		 self assert: (simSpillBase > simStackPtr or: [(self simStackAt: simSpillBase) spilled == false])].
 	self cCode: '' inSmalltalk:
		[deadCode ifFalse:
			[self assert: simStackPtr + (needsFrame ifTrue: [0] ifFalse: [1])
						= (self debugStackPointerFor: bytecodePC)]].
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> availableRegOrNoneNotConflictingWith: regMask [
	<inline: true>
	"If there's a free register, answer it, otherwise answer NoReg."
	^backEnd availableRegisterOrNoneFor: (self liveRegisters bitOr: regMask)
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> bytecodeFixupClass [
	<doNotGenerate>
	^CogSSBytecodeFixup
]

{ #category : #trampolines }
StackToRegisterMappingCogit >> cPICMissTrampolineFor: numArgs [
	^picMissTrampolines at: (numArgs min: self numRegArgs + 1)
]

{ #category : #debugging }
StackToRegisterMappingCogit >> callCogCodePopReceiverArg0Regs [
	"This is a static version of ceCallCogCodePopReceiverArg0Regs
	 for break-pointing when debugging in C."
	<api>
	<inline: false>
	"This exists only for break-pointing."
	self cCode: [self realCECallCogCodePopReceiverArg0Regs]
		inSmalltalk: [self ceCallCogCodePopReceiverArg0Regs]
]

{ #category : #debugging }
StackToRegisterMappingCogit >> callCogCodePopReceiverArg1Arg0Regs [
	"This is a static version of ceCallCogCodePopReceiverArg1Arg0Regs
	 for break-pointing when debugging in C."
	<api>
	<inline: false>
	"This exists only for break-pointing."
	self cCode: [self realCECallCogCodePopReceiverArg1Arg0Regs]
		inSmalltalk: [self ceCallCogCodePopReceiverArg1Arg0Regs]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceCall0ArgsPIC [
	<api: 'extern void (*ceCall0ArgsPIC)()'>
	<doNotGenerate>
	self simulateEnilopmart: ceCall0ArgsPIC numArgs: 1
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceCall1ArgsPIC [
	<api: 'extern void (*ceCall1ArgsPIC)()'>
	<doNotGenerate>
	self simulateEnilopmart: ceCall1ArgsPIC numArgs: 1
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceCall2ArgsPIC [
	<api: 'extern void (*ceCall2ArgsPIC)()'>
	<doNotGenerate>
	self simulateEnilopmart: ceCall2ArgsPIC numArgs: 1
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceCallCogCodePopReceiverArg0Regs [
	<api: 'extern void (*ceCallCogCodePopReceiverArg0Regs)()'>
	<doNotGenerate>
	self simulateEnilopmart: ceCallCogCodePopReceiverArg0Regs numArgs: 2
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceCallCogCodePopReceiverArg1Arg0Regs [
	<api: 'extern void (*ceCallCogCodePopReceiverArg1Arg0Regs)()'>
	<doNotGenerate>
	self simulateEnilopmart: ceCallCogCodePopReceiverArg1Arg0Regs numArgs: 3
]

{ #category : #accessing }
StackToRegisterMappingCogit >> ceMethodAbortTrampoline: trampoline [

	<doNotGenerate>
	super ceMethodAbortTrampoline: trampoline.
	^ methodAbortTrampolines at: 0 put: trampoline
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> ceShortCutTraceStore: aProcessorSimulationTrap [
	<doNotGenerate>
	self shortcutTrampoline: aProcessorSimulationTrap
		to: [coInterpreter
				ceTraceStoreOf: (processor registerAt: TempReg)
				into: (processor registerAt: ReceiverResultReg)]
]

{ #category : #accessing }
StackToRegisterMappingCogit >> ceStoreCheckTrampoline [
	<doNotGenerate>
	^ self objectRepresentation ceStoreCheckTrampoline
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileAbstractInstructionsFrom: start through: end [
	"Loop over bytecodes, dispatching to the generator for each bytecode, handling fixups in due course."
	| nextOpcodeIndex descriptor nExts fixup result |
	<var: #descriptor type: #'BytecodeDescriptor *'>
	<var: #fixup type: #'BytecodeFixup *'>
	self traceSimStack.
	bytecodePC := start.
	nExts := result := 0.
	descriptor := nil.
	deadCode := false.
	[self maybeHaltIfDebugPC.
	 self mergeWithFixupIfRequired: (fixup := self fixupAt: bytecodePC).
	 descriptor := self loadBytesAndGetDescriptor.
	 nextOpcodeIndex := opcodeIndex.
	 result := deadCode
				ifTrue: [self mapDeadDescriptorIfNeeded: descriptor]
				ifFalse: [self perform: descriptor generator].
	 result = 0 ifTrue: [self assertExtsAreConsumed: descriptor].
	 self traceDescriptor: descriptor; traceSimStack.
	 self patchFixupTargetIfNeeded: fixup nextOpcodeIndex: nextOpcodeIndex.
	 self maybeDumpLiterals: descriptor.
	 bytecodePC := self nextBytecodePCFor: descriptor exts: nExts.
	 result = 0 and: [bytecodePC <= end]] whileTrue:
		[nExts := descriptor isExtension ifTrue: [nExts + 1] ifFalse: [0]].
	self checkEnoughOpcodes.
	^result
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileCogFullBlockMethod: numCopied [
	<option: #SistaV1BytecodeSet>
	methodOrBlockNumTemps := coInterpreter tempCountOf: methodObj.
	self cCode: '' inSmalltalk:
		[debugStackPointers := coInterpreter debugStackPointersFor: methodObj].
	^super compileCogFullBlockMethod: numCopied
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileCogMethod: selector [
	methodOrBlockNumTemps := coInterpreter tempCountOf: methodObj.
	self cCode: '' inSmalltalk:
		[debugStackPointers := coInterpreter debugStackPointersFor: methodObj].
	^super compileCogMethod: selector
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileEntireMethod [
	"Compile the abstract instructions for the entire method, including blocks."
	regArgsHaveBeenPushed := false.
	^super compileEntireMethod
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileFrameBuild [
	"Build a frame for a CogMethod activation.  See CoInterpreter class>>initializeFrameIndices.
	 Override to push the register receiver and register arguments, if any."
	self cppIf: IMMUTABILITY ifTrue: 
		[useTwoPaths ifTrue: 
			[self compileTwoPathFrameBuild.
		 	^self]].
	needsFrame ifFalse:
		[useTwoPaths ifTrue: 
			[self compileTwoPathFramelessInit].
		 self initSimStackForFramelessMethod: initialPC.
		 ^self].
	self deny: useTwoPaths.
	self genPushRegisterArgs.
	super compileFrameBuild.
	self initSimStackForFramefulMethod: initialPC
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileFullBlockFramelessEntry: numCopied [
	"Make sure ReceiverResultReg holds the receiver, loaded from
	 the closure, which is what is initially in ReceiverResultReg"
	self initSimStackForFramelessBlock: initialPC.
	super compileFullBlockFramelessEntry: numCopied
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileFullBlockMethodFrameBuild: numCopied [
	<option: #SistaV1BytecodeSet>
	useTwoPaths ifTrue: 
		[ "method with only inst var store, we compile only slow path for now" 
		 useTwoPaths := false.
		 self cppIf: IMMUTABILITY ifTrue: [ needsFrame := true ] ].
	needsFrame ifFalse:
		[self assert: numCopied = 0.
		 self compileFullBlockFramelessEntry: numCopied.
		 self initSimStackForFramelessBlock: initialPC.
		 ^self].
	super compileFullBlockMethodFrameBuild: numCopied.
	self initSimStackForFramefulMethod: initialPC
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileTwoPathFrameBuild [
	"We are in a method where the frame is needed *only* for instance variable store, typically a setter method.
	This case has 20% overhead with Immutability compared to setter without immutability because of the stack
	frame creation. We compile two path, one where the object is immutable, one where it isn't. At the beginning 
	of the frame build, we take one path or the other depending on the receiver mutability.
	
	Note: this specific case happens only where there are only instance variabel stores. We could do something
	similar for literal variable stores, but we don't as it's too uncommon."
	<option: #IMMUTABILITY>
	| jumpImmutable jumpOld |
	self assert: useTwoPaths.
	jumpImmutable := self genJumpImmutable: ReceiverResultReg scratchReg: TempReg.
	jumpOld := self genJumpInOldSpace: ReceiverResultReg.
	"first path. The receiver is mutable"
	self assert: needsFrame not.
	self initSimStackForFramelessMethod: initialPC.
	self compileMethodBody.
	"second path. The receiver is mutable"
	useTwoPaths := false. "reset because it impacts inst var store compilation"
	needsFrame := true.
	jumpOld jmpTarget: (jumpImmutable jmpTarget: self Label).
	self genPushRegisterArgs.
	super compileFrameBuild.
	self initSimStackForFramefulMethod: initialPC
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> compileTwoPathFramelessInit [
	"We are in a frameless method with at least two inst var stores. We compile two paths,
	 one where the object is in new space, and one where it isn't. At the beginning 
	 of the method, we take one path or the other depending on the receiver being in newSpace."
	| jumpOld |
	self deny: IMMUTABILITY.
	self deny: needsFrame.
	self assert: useTwoPaths.
	jumpOld := self genJumpInOldSpace: ReceiverResultReg.
	"first path. The receiver is young"
	self initSimStackForFramelessMethod: initialPC.
	self compileMethodBody.
	"second path. The receiver is old"
	useTwoPaths := false. "reset because it impacts inst var store compilation"
	jumpOld jmpTarget: self Label
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> debugStackPointerFor: bcpc [
	<doNotGenerate>
	^(debugStackPointers at: bcpc) + (needsFrame ifTrue: [0] ifFalse: [1])
]

{ #category : #accessing }
StackToRegisterMappingCogit >> debugStackPointers: aCArrayAccessor [ 
	
	debugStackPointers := aCArrayAccessor
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> ensureFixupAt: targetPC [
	"Make sure there's a flagged fixup at the target pc in fixups.
	 Initially a fixup's target is just a flag.  Later on it is replaced with a proper instruction."
	<returnTypeC: #'BytecodeFixup *'>
	| fixup |
	<var: #fixup type: #'BytecodeFixup *'>
	fixup := self fixupAt:  targetPC.
	self traceFixup: fixup merge: true.
	self cCode: '' inSmalltalk:
		[self assert: simStackPtr = (self debugStackPointerFor: targetPC).
		 (fixup isMergeFixupOrIsFixedUp
		  and: [fixup isBackwardBranchFixup not]) ifTrue: "ignore backward branch targets"
			[self assert: fixup simStackPtr = simStackPtr]].
	fixup isNonMergeFixupOrNotAFixup
		ifTrue: "convert a non-merge into a merge"
			[fixup becomeMergeFixup.
			 fixup simStackPtr: simStackPtr ]
		ifFalse:
			[fixup isBackwardBranchFixup
				ifTrue: "this is the target of a backward branch and
						 so doesn't have a simStackPtr assigned yet."
					[fixup simStackPtr: simStackPtr ]
				ifFalse:
					[self assert: fixup simStackPtr = simStackPtr ]].
	fixup recordBcpc: bytecodePC.
	^fixup
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> ensureNonMergeFixupAt: targetPC [
	"Make sure there's a flagged fixup at the target pc in fixups.
	 Initially a fixup's target is just a flag.  Later on it is replaced with a proper instruction."
	<returnTypeC: #'BytecodeFixup *'>
	| fixup |
	<var: #fixup type: #'BytecodeFixup *'>
	fixup := self fixupAt:  targetPC.
	self traceFixup: fixup merge: true.
	fixup notAFixup ifTrue:
		[fixup becomeNonMergeFixup].
	self cCode: '' inSmalltalk:
		[fixup isMergeFixupOrIsFixedUp ifTrue:
			[self assert:
					(fixup isBackwardBranchFixup
					 or: [fixup simStackPtr = (self debugStackPointerFor: targetPC)])]].
	fixup recordBcpc: bytecodePC.
	^fixup
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> ensureReceiverResultRegContainsSelf [
	needsFrame
		ifTrue:
			[self receiverIsInReceiverResultReg ifFalse:
				[self ssAllocateRequiredReg: ReceiverResultReg.
				 self putSelfInReceiverResultReg.
				 self simSelf liveRegister: ReceiverResultReg]]
		ifFalse:
			[self assert: (self simSelf type = SSRegister
						  and: [self simSelf register = ReceiverResultReg
						  and: [self receiverIsInReceiverResultReg]])]
]

{ #category : #'peephole optimizations' }
StackToRegisterMappingCogit >> evaluate: descriptor at: pc [
	<var: #descriptor type: #'BytecodeDescriptor *'>
	byte0 := objectMemory fetchByte: pc ofObject: methodObj.
	self assert: descriptor = (self generatorAt: byte0).
	self loadSubsequentBytesForDescriptor: descriptor at: pc.
	self perform: descriptor generator
]

{ #category : #'peephole optimizations' }
StackToRegisterMappingCogit >> eventualTargetOf: targetBytecodePC [
	"Attempt to follow a branch to a pc.  Handle branches to unconditional jumps and
	 branches to push: aBoolean; conditional branch pairs.  If the branch cannot be
	 followed answer targetBytecodePC. It is not possible to follow jumps to conditional
	 branches because the stack changes depth.  That following is left to the genJumpIf:to:
	 clients."

	| currentTarget nextPC nExts descriptor span cond |
	<var: #descriptor type: #'BytecodeDescriptor *'>
	nextPC := currentTarget := targetBytecodePC.
	[ nExts := 0.
	 [descriptor := self generatorForPC: nextPC.
	  descriptor isReturn ifTrue: [^currentTarget]. "avoid stepping off the end of methods"
	  descriptor isExtension]
		whileTrue:
			[nExts := nExts + 1.
			 nextPC := nextPC + descriptor numBytes].
	 descriptor isUnconditionalBranch
		ifTrue:
			[span := self spanFor: descriptor at: nextPC exts: nExts in: methodObj.
			 span < 0 ifTrue: "Do *not* follow backward branches; these are interrupt points and should not be elided."
				[^currentTarget].
			 nextPC := nextPC + descriptor numBytes + span]
		ifFalse:
			[descriptor generator == #genPushConstantTrueBytecode ifTrue: [ cond := true ]
			 ifFalse: [ descriptor generator == #genPushConstantFalseBytecode ifTrue: [ cond := false ]
			 ifFalse: [ ^currentTarget ] ].
			 "Don't step into loops across a pushTrue; jump:if: boundary, so as not to confuse stack depth fixup."
			 (self fixupAt: nextPC) isBackwardBranchFixup ifTrue:
				[^currentTarget].
			 nextPC := self eventualTargetOf: nextPC + descriptor numBytes.
			 nExts := 0.
			 [descriptor := self generatorForPC: nextPC.
			  descriptor isReturn ifTrue: [^currentTarget]. "avoid stepping off the end of methods"
			  descriptor isExtension]
				whileTrue:
					[nExts := nExts + 1.
					 nextPC := nextPC + descriptor numBytes].
			 descriptor isBranch ifFalse:
				[^currentTarget].
			 descriptor isUnconditionalBranch ifTrue:
				[^currentTarget].
			 nextPC := cond == descriptor isBranchTrue
									ifTrue: [nextPC
											+ descriptor numBytes
											+ (self spanFor: descriptor at: nextPC exts: nExts in: methodObj)]
									ifFalse: [nextPC + descriptor numBytes]].
	 currentTarget := nextPC]
		repeat
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> extractMaybeBranchDescriptorInto: fourArgBlock [
	"Looks one instruction ahead of the current bytecodePC and answers its bytecode descriptor and its pc.
	 If the instruction found is a branch, also answers the pc after the branch and the pc targeted by the branch.
	 For convenience, avoiding duplication in the senders, it follows those two pcs to their eventual targets."
	| primDescriptor nextPC nExts branchDescriptor targetBytecodePC postBranchPC |

	<var: #primDescriptor type: #'BytecodeDescriptor *'>
	<var: #branchDescriptor type: #'BytecodeDescriptor *'>
	
	primDescriptor := self generatorAt: byte0.

	nextPC := bytecodePC + primDescriptor numBytes.
	nExts := 0.
	[[branchDescriptor := self generatorForPC: nextPC.
	  branchDescriptor isExtension] whileTrue:
		[nExts := nExts + 1.
		 nextPC := nextPC + branchDescriptor numBytes].
	 branchDescriptor isUnconditionalBranch]
		whileTrue:
			[nextPC := self eventualTargetOf: nextPC
											+ branchDescriptor numBytes
											+ (self spanFor: branchDescriptor at: nextPC exts: nExts in: methodObj)].

	targetBytecodePC := postBranchPC := 0.

	(branchDescriptor isBranchTrue or: [branchDescriptor isBranchFalse])
		ifTrue: 
			[targetBytecodePC := self eventualTargetOf: nextPC
														+ branchDescriptor numBytes
														+ (self spanFor: branchDescriptor at: nextPC exts: nExts in: methodObj).
			 postBranchPC := self eventualTargetOf: nextPC + branchDescriptor numBytes]
		ifFalse:
			[nextPC := bytecodePC + primDescriptor numBytes].

	fourArgBlock value: branchDescriptor value: nextPC value: postBranchPC value: targetBytecodePC
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> fixupAtIndex: index [
	"The fixups Array maps to bytecode pcs such that initialPC maps to index 0.
	 fixupAt: does the conversion.  Override to add breakpointing for fixups of bytecode PCs."
	<cmacro: '(index) (&fixups[index])'>
	<returnTypeC: #'BytecodeFixup *'>
	((debugFixupBreaks includes: index + initialPC)
	 and: [breakMethod isNil or: [methodObj = breakMethod]]) ifTrue:
		[self halt].
	^self addressOf: (fixups at: index)
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> freeAnyFloatRegNotConflictingWith: regMask [
	"Spill the closest register on stack not conflicting with regMask. 
	Assertion Failure if regMask has already all the registers"
	<var: #desc type: #'CogSimStackEntry *'>
	| reg index |
	self assert: needsFrame.
	reg := NoReg.
	index := simSpillBase max: 0.
	self deny: reg = NoReg.
	self ssAllocateRequiredFloatReg: reg.
	^reg
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> freeAnyRegNotConflictingWith: regMask [
	"Spill the closest register on stack not conflicting with regMask. 
	Assertion Failure if regMask has already all the registers"
	<var: #desc type: #'CogSimStackEntry *'>
	| reg index |
	self assert: needsFrame.
	reg := NoReg.
	index := simSpillBase max: 0.
	[reg = NoReg and: [index < simStackPtr]] whileTrue: 
		[ | desc |
		 desc := self simStackAt: index.
		 desc type = SSRegister ifTrue:
			[(regMask anyMask: (self registerMaskFor: desc register)) ifFalse: 
				[reg := desc register]].
		 index := index + 1].
	self deny: reg = NoReg.
	self ssAllocateRequiredReg: reg.
	^reg
]

{ #category : #'bytecode generators' }
StackToRegisterMappingCogit >> genBlockReturn [
	"Return from block, assuming result already loaded into ReceiverResultReg."
	super genBlockReturn.
	deadCode := true. "can't fall through"
	^0
]

{ #category : #initialization }
StackToRegisterMappingCogit >> genCallPICEnilopmartNumArgs: numArgs [
	"Generate special versions of the ceCallCogCodePopReceiverAndClassRegs
	 enilopmart that also pop register args from the stack to undo the pushing of
	 register args in the abort/miss trampolines."
	<returnTypeC: 'void (*genCallPICEnilopmartNumArgs(sqInt numArgs))(void)'>
	| size endAddress enilopmart |
	self zeroOpcodeIndex.
	backEnd hasVarBaseRegister ifTrue:
		[self MoveCq: self varBaseAddress R: VarBaseReg]. "Must happen first; value may be used in genLoadStackPointers"
	backEnd genLoadStackPointers.
	self PopR: ClassReg. "cacheTag"
	self PopR: TempReg. "entry-point"
	self PopR: (backEnd hasLinkRegister ifTrue: [LinkReg] ifFalse: [SendNumArgsReg]). "retpc"
	numArgs > 0 ifTrue:
		[numArgs > 1 ifTrue:
			[self PopR: Arg1Reg.
			 self assert: self numRegArgs = 2].
		 self PopR: Arg0Reg].
	self PopR: ReceiverResultReg.
	backEnd hasLinkRegister ifFalse: [self PushR: SendNumArgsReg]. "retpc"
	self JumpR: TempReg.
	self computeMaximumSizes.
	size := self generateInstructionsAt: methodZoneBase.
	endAddress := self outputInstructionsAt: methodZoneBase.
	self assert: methodZoneBase + size = endAddress.
	enilopmart := methodZoneBase.
	methodZoneBase := self alignUptoRoutineBoundary: endAddress.
	backEnd stopsFrom: endAddress to: methodZoneBase - 1.
	self recordGeneratedRunTime: (self trampolineName: 'ceCallPIC' numRegArgs: numArgs) address: enilopmart.
	^self cCoerceSimple: enilopmart to: #'void (*)(void)'
]

{ #category : #'trampoline support' }
StackToRegisterMappingCogit >> genExternalizePointersForPrimitiveCall [
	" Override to push the register receiver and register arguments, if any."
	self genPushRegisterArgs.
	^super genExternalizePointersForPrimitiveCall
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genJumpBackTo: targetBytecodePC [
	self ssFlushTo: simStackPtr.
	deadCode := true. "can't fall through"
	^super genJumpBackTo: targetBytecodePC
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> genJumpImmutable: sourceReg scratchReg: scratchReg [
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	self MoveMw: 0 r: sourceReg R: scratchReg. 
	^ self genJumpBaseHeaderImmutable: scratchReg
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> genJumpInOldSpace: reg [
	"Jump if reg is old."

	<inline: true>
	^ self
		  CmpCq: objectMemory storeCheckBoundary R: reg;
		  "N.B. FLAGS := destReg - scratchReg"JumpAboveOrEqual: 0
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genJumpTo: targetBytecodePC [
	| eventualTarget generator fixup |
	eventualTarget := self eventualTargetOf: targetBytecodePC.
	(eventualTarget > bytecodePC
	 and: [self stackTopIsBoolean
	 and: [(generator := self generatorForPC: eventualTarget) isConditionalBranch]])
		ifTrue:
			[eventualTarget := eventualTarget
							  + generator numBytes
							  + (generator isBranchTrue == (self ssTop constant = objectMemory trueObject)
									ifTrue: [self spanFor: generator at: eventualTarget exts: 0 in: methodObj]
									ifFalse: [0]).
			self ssPop: 1.
			self ssFlushTo: simStackPtr.
			fixup := self ensureFixupAt: eventualTarget.
			self ssPop: -1]
		ifFalse:
			[self ssFlushTo: simStackPtr.
			fixup := self ensureFixupAt: eventualTarget].
	deadCode := true. "can't fall through"
	self Jump: fixup.
	^0
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genLoadLiteralVariable: litVarIndex in: destReg [
	<inline: true>
	| association |
	association := self getLiteral: litVarIndex.
	destReg = ReceiverResultReg ifTrue: [self voidReceiverResultRegContainsSelf].
	self ssAllocateRequiredReg: destReg.
	self genMoveConstant: association R: destReg.
	self genEnsureObjInRegNotForwarded: destReg scratchReg: TempReg.
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genLoadTemp: objectIndex in: destReg [
	destReg = ReceiverResultReg ifTrue: [self voidReceiverResultRegContainsSelf].
	self ssAllocateRequiredReg: destReg. 
	self MoveMw: (self frameOffsetOfTemporary: objectIndex) r: FPReg R: destReg.
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genMarshalledSend: selectorIndex numArgs: numArgs sendTable: sendTable [
	<inline: false>
	<var: #sendTable type: #'sqInt *'>
	| annotation |
	self assert: needsFrame.
	annotation := self annotationForSendTable: sendTable.
	"Deal with stale super sends; see SpurMemoryManager's class comment."
	(self annotationIsForUncheckedEntryPoint: annotation) ifTrue:
		[self genEnsureOopInRegNotForwarded: ReceiverResultReg scratchReg: TempReg].
	"0 through (NumSendTrampolines - 2) numArgs sends have the arg count implciti in the trampoline.
	 The last send trampoline (NumSendTrampolines - 1) passes numArgs in SendNumArgsReg."
	numArgs >= (NumSendTrampolines - 1) ifTrue:
		[self MoveCq: numArgs R: SendNumArgsReg].
	(BytecodeSetHasDirectedSuperSend
	 and: [annotation
			between: IsDirectedSuperSend
			and: IsDirectedSuperBindingSend]) ifTrue:
		[self genMoveConstant: tempOop R: TempReg].
	self genLoadInlineCacheWithSelector: selectorIndex.
	(self Call: (sendTable at: (numArgs min: NumSendTrampolines - 1))) annotation: annotation.
	self voidReceiverOptStatus.
	^self ssPushRegister: ReceiverResultReg
]

{ #category : #initialization }
StackToRegisterMappingCogit >> genMethodAbortTrampolineFor: numArgs [
	"Generate the abort for a method.  This abort performs either a call of ceSICMiss:
	 to handle a single-in-line cache miss or a call of ceStackOverflow: to handle a
	 stack overflow.  It distinguishes the two by testing ResultReceiverReg.  If the
	 register is zero then this is a stack-overflow because a) the receiver has already
	 been pushed and so can be set to zero before calling the abort, and b) the
	 receiver must always contain an object (and hence be non-zero) on SIC miss."
	| jumpSICMiss |
	<var: #jumpSICMiss type: #'AbstractInstruction *'>
	self zeroOpcodeIndex.
	self CmpCq: 0 R: ReceiverResultReg.
	jumpSICMiss := self JumpNonZero: 0.

	"The abort sequence has pushed the LinkReg a second time - because a stack
	 overflow can only happen after building a frame, which pushes LinkReg anyway, and
	 we still need to push LinkReg in case we get to this routine from a sendMissAbort.
	 (On ARM there is a simpler way; use two separate abort calls since all instructions are 32-bits
	  but on x86 the zero receiver reg, call methodAbort sequence is smaller; we may fix this one day).
	 Overwrite that duplicate with the right one - the return address for the call to the abort trampoline.
	 The only reason it matters is an assert in ceStackOverflow: uses it"
	backEnd hasLinkRegister ifTrue:
		[self MoveR: LinkReg Mw: 0 r: SPReg].
	self compileTrampolineFor: #ceStackOverflow:
		numArgs: 1
		arg: SendNumArgsReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: false "The LinkReg has already been set above."
		resultReg: NoReg.
	jumpSICMiss jmpTarget: self Label.
	backEnd genPushRegisterArgsForAbortMissNumArgs: numArgs.
	^self genTrampolineFor: #ceSICMiss:
		called: (self trampolineName: 'ceMethodAbort' numRegArgs: numArgs)
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: false "The LinkReg will have been pushed in genPushRegisterArgsForAbortMissNumArgs: above."
		resultReg: NoReg
		appendOpcodes: true
]

{ #category : #initialization }
StackToRegisterMappingCogit >> genPICAbortTrampolineFor: numArgs [
	"Generate the abort for a PIC.  This abort performs either a call of
	 ceInterpretMethodFromPIC:receiver: to handle invoking an uncogged
	 target or a call of ceMNUFromPICMNUMethod:receiver: to handle an
	 MNU dispatch in a closed PIC.  It distinguishes the two by testing
	 ClassReg.  If the register is zero then this is an MNU."
	self zeroOpcodeIndex. 
	backEnd genPushRegisterArgsForAbortMissNumArgs: numArgs.
	^self genInnerPICAbortTrampoline: (self trampolineName: 'cePICAbort' numRegArgs: numArgs)
]

{ #category : #initialization }
StackToRegisterMappingCogit >> genPICMissTrampolineFor: numArgs [
	<inline: false>
	| startAddress |
	startAddress := methodZoneBase.
	self zeroOpcodeIndex.
	"N.B. a closed PIC jumps to the miss routine, not calls it, so there is only one retpc on the stack."
	backEnd genPushRegisterArgsForNumArgs: numArgs scratchReg: SendNumArgsReg.
	self genTrampolineFor: #ceCPICMiss:receiver:
		called: (self trampolineName: 'cePICMiss' numRegArgs: numArgs)
		numArgs: 2
		arg: ClassReg
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true.
	^startAddress
]

{ #category : #'primitive generators' }
StackToRegisterMappingCogit >> genPrimReturn [
	"Generate a return that cuts back the stack to remove the receiver
	 and arguments after an invocation of a primitive with nargs arguments.
	 Since all primitives that succeed in the normal way (i.e. don't execute a
	 method as do genPrimitiveClosureValue and genPrimitivePerform) take only
	 register arguments, there is nothing to do."
	<inline: true>
	^methodOrBlockNumArgs <= self numRegArgs
		ifTrue: [self RetN: 0]
		ifFalse: [super genPrimReturn]
]

{ #category : #'primitive generators' }
StackToRegisterMappingCogit >> genPrimitiveFullClosureValue [
	"Override to push the register args first."
	<option: #SistaV1BytecodeSet>
	self genPushRegisterArgs.
	^super genPrimitiveFullClosureValue
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> genPushRegisterArgs [
	"Ensure that the register args are pushed before the retpc for methods with arity <= self numRegArgs."
	"This won't be as clumsy on a RISC.  But putting the receiver and
	 args above the return address means the CoInterpreter has a
	 single machine-code frame format which saves us a lot of work."
	(regArgsHaveBeenPushed
	 or: [methodOrBlockNumArgs > self numRegArgs]) ifFalse:
		[backEnd genPushRegisterArgsForNumArgs: methodOrBlockNumArgs scratchReg: SendNumArgsReg.
		regArgsHaveBeenPushed := true]
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genPushTemporaryVariable: index [
	"If a frameless method (not a block), only argument temps can be accessed.
	 This is assured by the use of needsFrameIfMod16GENumArgs: in pushTemp."
	self assert: (inBlock > 0 or: [needsFrame or: [index < methodOrBlockNumArgs]]).
	^self ssPushDesc: (simStack at: index + 1)
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genSend: selectorIndex numArgs: numArgs [
	self marshallSendArguments: numArgs.
	^self genMarshalledSend: selectorIndex numArgs: numArgs sendTable: ordinarySendTrampolines
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genSendDirectedSuper: selectorIndex numArgs: numArgs [
	| result |
	self assert: self ssTop type = SSConstant.
	tempOop := self ssTop constant.
	self ssPop: 1.
	self marshallSendArguments: numArgs.
	result := self
				genMarshalledSend: selectorIndex
				numArgs: numArgs
				sendTable: (directedSendUsesBinding
								ifTrue: [directedSuperBindingSendTrampolines]
								ifFalse: [directedSuperSendTrampolines]).
	directedSendUsesBinding := false.
	^result
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> genSendSuper: selectorIndex numArgs: numArgs [
	self marshallSendArguments: numArgs.
	^self genMarshalledSend: selectorIndex numArgs: numArgs sendTable: superSendTrampolines
]

{ #category : #initialization }
StackToRegisterMappingCogit >> generateEnilopmarts [
	"Enilopmarts transfer control from C into machine code (backwards trampolines).
	 Override to add version for generic and PIC-specific entry with reg args."
	super generateEnilopmarts.

	self cppIf: Debug
		ifTrue:
			[realCECallCogCodePopReceiverArg0Regs :=
				self genEnilopmartFor: ReceiverResultReg
					and: Arg0Reg
					forCall: true
					called: 'realCECallCogCodePopReceiverArg0Regs'.
			 ceCallCogCodePopReceiverArg0Regs := #callCogCodePopReceiverArg0Regs.
			 realCECallCogCodePopReceiverArg1Arg0Regs :=
				self genEnilopmartFor: ReceiverResultReg
					and: Arg0Reg
					and: Arg1Reg
					forCall: true
					called: 'realCECallCogCodePopReceiverArg1Arg0Regs'.
			 ceCallCogCodePopReceiverArg1Arg0Regs := #callCogCodePopReceiverArg1Arg0Regs]
		ifFalse:
			[ceCallCogCodePopReceiverArg0Regs :=
				self genEnilopmartFor: ReceiverResultReg
					and: Arg0Reg
					forCall: true
					called: 'ceCallCogCodePopReceiverArg0Regs'.
			 ceCallCogCodePopReceiverArg1Arg0Regs :=
				self genEnilopmartFor: ReceiverResultReg
					and: Arg0Reg
					and: Arg1Reg
					forCall: true
					called: 'ceCallCogCodePopReceiverArg1Arg0Regs'].

	"These are special versions of the ceCallCogCodePopReceiverAndClassRegs enilopmart that also
	 pop register args from the stack to undo the pushing of register args in the abort/miss trampolines."
	ceCall0ArgsPIC := self genCallPICEnilopmartNumArgs: 0.
	self numRegArgs >= 1 ifTrue:
		[ceCall1ArgsPIC := self genCallPICEnilopmartNumArgs: 1.
		 self numRegArgs >= 2 ifTrue:
			[ceCall2ArgsPIC := self genCallPICEnilopmartNumArgs: 2.
			 self assert: self numRegArgs = 2]]
]

{ #category : #'generate machine code' }
StackToRegisterMappingCogit >> generateInstructionsAt: eventualAbsoluteAddress [
	"Size pc-dependent instructions and assign eventual addresses to all instructions.
	 Answer the size of the code.
	 Compute forward branches based on virtual address (abstract code starts at 0),
	 assuming that any branches branched over are long.
	 Compute backward branches based on actual address.
	 Reuse the fixups array to record the pc-dependent instructions that need to have
	 their code generation postponed until after the others.

	 Override to andd handling for null branches (branches to the immediately following
	 instruction) occasioned by StackToRegisterMapping's following of jumps."
	| absoluteAddress pcDependentIndex abstractInstruction fixup |
	<var: #abstractInstruction type: #'AbstractInstruction *'>
	<var: #fixup type: #'BytecodeFixup *'>
	absoluteAddress := eventualAbsoluteAddress.
	pcDependentIndex := 0.
	0 to: opcodeIndex - 1 do:
		[:i|
		self maybeBreakGeneratingAt: absoluteAddress.
		abstractInstruction := self abstractInstructionAt: i.
		abstractInstruction isPCDependent
			ifTrue:
				[abstractInstruction sizePCDependentInstructionAt: absoluteAddress.
				 (abstractInstruction isJump
				  and: [(i + 1 < opcodeIndex
				  		and: [abstractInstruction getJmpTarget == (self abstractInstructionAt: i + 1)])
					or: [i + 2 < opcodeIndex
						and: [abstractInstruction getJmpTarget == (self abstractInstructionAt: i + 2)
						and: [(self abstractInstructionAt: i + 1) opcode = Nop]]]])
					ifTrue:
						[abstractInstruction
							opcode: Nop;
							concretizeAt: absoluteAddress]
					ifFalse:
						[fixup := self fixupAtIndex: pcDependentIndex.
						 pcDependentIndex := pcDependentIndex + 1.
						 fixup instructionIndex: i].
				 absoluteAddress := absoluteAddress + abstractInstruction machineCodeSize]
			ifFalse:
				[absoluteAddress := abstractInstruction concretizeAt: absoluteAddress]].
	0 to: pcDependentIndex - 1 do:
		[:j|
		fixup := self fixupAtIndex: j.
		abstractInstruction := self abstractInstructionAt: fixup instructionIndex.
		self maybeBreakGeneratingAt: abstractInstruction address.
		abstractInstruction concretizeAt: abstractInstruction address].
	^absoluteAddress - eventualAbsoluteAddress
]

{ #category : #initialization }
StackToRegisterMappingCogit >> generateMissAbortTrampolines [
	"Generate the run-time entries for the various method and PIC entry misses and aborts.
	 Read the class-side method trampolines for documentation on the various trampolines"
	0 to: self numRegArgs + 1 do:
		[:numArgs|
		methodAbortTrampolines
			at: numArgs
			put: (self genMethodAbortTrampolineFor: numArgs)].
	0 to: self numRegArgs + 1 do:
		[:numArgs|
		picAbortTrampolines
			at: numArgs
			put: (self genPICAbortTrampolineFor: numArgs)].
	0 to: self numRegArgs + 1 do:
		[:numArgs|
		picMissTrampolines
			at: numArgs
			put: (self genPICMissTrampolineFor: numArgs)].
	ceReapAndResetErrorCodeTrampoline := self genTrampolineFor: #ceReapAndResetErrorCodeFor:
												called: 'ceReapAndResetErrorCodeTrampoline'
												arg: ClassReg
]

{ #category : #initialization }
StackToRegisterMappingCogit >> generateSendTrampolines [
	"Override to generate code to push the register arg(s) for <= numRegArg arity sends."
	0 to: NumSendTrampolines - 1 do:
		[:numArgs|
		ordinarySendTrampolines
			at: numArgs
			put: (self genSendTrampolineFor: #ceSend:super:to:numArgs:
					  numArgs: numArgs
					  called: (self trampolineName: 'ceSend' numArgs: numArgs)
					  arg: ClassReg
					  arg: (self trampolineArgConstant: false)
					  arg: ReceiverResultReg
					  arg: (self numArgsOrSendNumArgsReg: numArgs))].

	"Generate these in the middle so they are within [firstSend, lastSend]."
	BytecodeSetHasDirectedSuperSend ifTrue: [
		0 to: NumSendTrampolines - 1 do: [:numArgs|
			self
				generateSuperSendTrampolineTo: #ceSend:above:to:numArgs:
				named: 'ceDirectedSuperSend'
				numArgs: numArgs
				in: directedSuperSendTrampolines.
			self
				generateSuperSendTrampolineTo: #ceSend:aboveClassBinding:to:numArgs:
				named: 'ceDirectedSuperBindingSend'
				numArgs: numArgs
				in: directedSuperBindingSendTrampolines ] ].

	0 to: NumSendTrampolines - 1 do:
		[:numArgs|
		superSendTrampolines
			at: numArgs
			put: (self genSendTrampolineFor: #ceSend:super:to:numArgs:
					  numArgs: numArgs
					  called: (self trampolineName: 'ceSuperSend' numArgs: numArgs)
					  arg: ClassReg
					  arg: (self trampolineArgConstant: true)
					  arg: ReceiverResultReg
					  arg: (self numArgsOrSendNumArgsReg: numArgs))].
	firstSend := ordinarySendTrampolines at: 0.
	lastSend := superSendTrampolines at: NumSendTrampolines - 1
]

{ #category : #initialization }
StackToRegisterMappingCogit >> generateSuperSendTrampolineTo: function named: name numArgs: numArgs in: table [
	
	<var: #table type: #'sqInt *'>
	| trampoline |
	trampoline := self genSendTrampolineFor: function
		numArgs: numArgs
		called: (self trampolineName: name numArgs: numArgs)
		arg: ClassReg
		arg: TempReg
		arg: ReceiverResultReg
		arg: (self numArgsOrSendNumArgsReg: numArgs).
	table at: numArgs put: trampoline.
	^ trampoline
]

{ #category : #initialization }
StackToRegisterMappingCogit >> generateTracingTrampolines [
	"Generate trampolines for tracing.  In the simulator we can save a lot of time
	 and avoid noise instructions in the lastNInstructions log by short-cutting these
	 trampolines, but we need them in the real vm."
	ceTraceLinkedSendTrampoline :=
		self genTrampolineFor: #ceTraceLinkedSend:
			called: 'ceTraceLinkedSendTrampoline'
			arg: ReceiverResultReg
			regsToSave: CallerSavedRegisterMask..
	ceTraceBlockActivationTrampoline :=
		self genTrampolineFor: #ceTraceBlockActivation
			called: 'ceTraceBlockActivationTrampoline'
			regsToSave: CallerSavedRegisterMask..
	ceTraceStoreTrampoline :=
		self genTrampolineFor: #ceTraceStoreOf:into:
			called: 'ceTraceStoreTrampoline'
			arg: TempReg
			arg: ReceiverResultReg
			regsToSave: CallerSavedRegisterMask..
	self cCode: [] inSmalltalk:
		[ceTraceLinkedSendTrampoline := self simulatedTrampolineFor: #ceShortCutTraceLinkedSend:.
		 ceTraceBlockActivationTrampoline := self simulatedTrampolineFor: #ceShortCutTraceBlockActivation:.
		 ceTraceStoreTrampoline := self simulatedTrampolineFor: #ceShortCutTraceStore:]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> initSimStackForFramefulMethod: startpc [
	<var: #desc type: #'CogSimStackEntry *'>
	simStackPtr := methodOrBlockNumTemps. "N.B. Includes num args"
	simSpillBase := methodOrBlockNumTemps + 1.
	self simSelf
		type: SSBaseOffset;
		spilled: true;
		register: FPReg;
		offset: FoxMFReceiver;
		liveRegister: NoReg.
	"args"
	1 to: methodOrBlockNumArgs do:
		[:i| | desc |
		desc := self simStackAt: i.
		desc
			type: SSBaseOffset;
			spilled: true;
			register: FPReg;
			offset: FoxCallerSavedIP + ((methodOrBlockNumArgs - i + 1) * objectMemory wordSize);
			bcptr: startpc].
	"temps"
	methodOrBlockNumArgs + 1 to: simStackPtr do:
		[:i| | desc |
		desc := self simStackAt: i.
		desc
			type: SSBaseOffset;
			spilled: true;
			register: FPReg;
			offset: FoxMFReceiver - (i - methodOrBlockNumArgs * objectMemory wordSize);
			bcptr: startpc]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> initSimStackForFramelessBlock: startpc [
	"The register receiver (the closure itself) and args are pushed by the closure value primitive(s)
	 and hence a frameless block has all arguments and copied values pushed to the stack.  However,
	 the method receiver (self) is put in the ReceiverResultReg by the block entry."
	<var: #desc type: #'CogSimStackEntry *'>
	self simSelf
		type: SSRegister;
		spilled: false;
		register: ReceiverResultReg;
		liveRegister: ReceiverResultReg.
	self assert: methodOrBlockNumTemps >= methodOrBlockNumArgs.
	1 to: methodOrBlockNumTemps do:
		[:i| | desc |
		desc := self simStackAt: i.
		desc
			type: SSBaseOffset;
			spilled: true;
			register: SPReg;
			offset: ((backEnd hasLinkRegister
								ifTrue: [methodOrBlockNumArgs - i]
								ifFalse: [methodOrBlockNumArgs + 1 - i]) * objectMemory wordSize);
			bcptr: startpc].
	simStackPtr := methodOrBlockNumTemps. "N.B. Includes num args"
	simSpillBase := methodOrBlockNumTemps + 1.
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> initSimStackForFramelessMethod: startpc [
	| desc |
	<var: #desc type: #'CogSimStackEntry *'>
	self simSelf
		type: SSRegister;
		spilled: false;
		register: ReceiverResultReg;
		liveRegister: ReceiverResultReg.
	self assert: methodOrBlockNumTemps = methodOrBlockNumArgs.
	self assert: self numRegArgs <= 2.
	(methodOrBlockNumArgs between: 1 and: self numRegArgs)
		ifTrue:
			[desc := self simStackAt: 1.
			 desc
				type: SSRegister;
				spilled: false;
				register: Arg0Reg;
				bcptr: startpc.
			 methodOrBlockNumArgs > 1 ifTrue:
				[desc := self simStackAt: 2.
				 desc
					type: SSRegister;
					spilled: false;
					register: Arg1Reg;
					bcptr: startpc]]
		ifFalse:
			[1 to: methodOrBlockNumArgs do:
				[:i|
				desc := self simStackAt: i.
				desc
					type: SSBaseOffset;
					register: SPReg;
					spilled: true;
					offset: ((backEnd hasLinkRegister
								ifTrue: [methodOrBlockNumArgs - i]
								ifFalse: [methodOrBlockNumArgs + 1 - i]) * objectMemory wordSize);
					bcptr: startpc]].
	simStackPtr := methodOrBlockNumArgs.
	simSpillBase := methodOrBlockNumArgs + 1.
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> initializeFixup: fixup [
	"Initialize a fixup.  These are the targets of backward branches.  A backward branch fixup's
	 simStackPtr needs to be set when generating the code for the bytecode at the targetPC.
	 Initially a fixup's target is just a flag.  Later on it is replaced with a proper instruction."
	<var: #fixup type: #'BytecodeFixup *'>
	<inline: true>
	fixup
		becomeMergeFixup;
		setIsBackwardBranchFixup
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> initializeFixupAt: targetPC [
	"Make sure there's a flagged fixup at the targetPC in fixups.
	 These are the targets of backward branches.  A backward branch fixup's simStackPtr
	 needs to be set when generating the code for the bytecode at the targetPC.
	 Initially a fixup's target is just a flag.  Later on it is replaced with a proper instruction."
	<inline: true>
	| fixup |
	fixup := self fixupAt: targetPC.
	self initializeFixup: fixup
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> liveFloatRegisters [
	| regsSet |
	regsSet := 0.
	(simSpillBase max: 0) to: simStackPtr do:
		[:i|
		regsSet := regsSet bitOr: (self simStackAt: i) floatRegisterMask].
	^regsSet
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> liveRegisters [
	| regsSet |
	needsFrame
		ifTrue: [regsSet := 0]
		ifFalse:
			[regsSet := self registerMaskFor: ReceiverResultReg.
			 (methodOrBlockNumArgs <= self numRegArgs
			  and: [methodOrBlockNumArgs > 0]) ifTrue:
				[regsSet := regsSet bitOr: (self registerMaskFor: Arg0Reg).
				 (self numRegArgs > 1 and: [methodOrBlockNumArgs > 1]) ifTrue:
					[regsSet := regsSet bitOr: (self registerMaskFor: Arg1Reg)]]].
	(simSpillBase max: 0) to: simStackPtr do:
		[:i|
		regsSet := regsSet bitOr: (self simStackAt: i) registerMask].
	^regsSet
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> liveVectorRegisters [

	| regsSet |
	regsSet := 0.
	(simSpillBase max: 0) to: simStackPtr do: [ :i | 
		| ssEntry |
		ssEntry := self simStackAt: i.
		(ssEntry type = SSVectorRegister) ifTrue: [ 
			regsSet := regsSet bitOr: ssEntry registerMask ] ].
	^ regsSet
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> mapDeadDescriptorIfNeeded: descriptor [ 
	"insert nops for dead code that is mapped so that bc 
	 to mc mapping is not many to one"
	<var: #descriptor type: #'BytecodeDescriptor *'>
	self flag: #annotateInstruction .
	(descriptor isMapped
		or: [inBlock > 0 and: [descriptor isMappedInBlock]]) 
		ifTrue: [self annotateBytecode: self Nop].
	^ 0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> marshallSendArguments: numArgs [ 
	"Spill everything on the simulated stack that needs spilling (that below receiver and arguments).
	 Marshall receiver and arguments to stack and/or registers depending on arg count.
	 If the args don't fit in registers push receiver and args (spill everything), but still assign
	 the receiver to ReceiverResultReg."
	self ssFlushTo: simStackPtr - numArgs - 1.
	numArgs > self numRegArgs
		ifTrue:
			"If there are no spills and no references to ReceiverResultReg
			 the fetch of ReceiverResultReg from the stack can be avoided
			 by assigning directly to ReceiverResultReg and pushing it."
			[| numSpilled anyRefs |
			numSpilled := self numberOfSpillsInTopNItems: numArgs + 1.
			anyRefs := self anyReferencesToRegister: ReceiverResultReg inTopNItems: numArgs + 1.
			(numSpilled > 0 or: [anyRefs])
				ifTrue:
					[self ssFlushTo: simStackPtr.
					 (self simStackAt: simStackPtr - numArgs)
						storeToReg: ReceiverResultReg]
				ifFalse:
					[(self simStackAt: simStackPtr - numArgs)
						storeToReg: ReceiverResultReg;
					 	type: SSRegister;
						register: ReceiverResultReg.
					 self ssFlushTo: simStackPtr]]
		ifFalse:
			"Move the args to the register arguments, being careful to do
			 so last to first so e.g. previous contents don't get overwritten.
			 Also check for any arg registers in use by other args."
			[numArgs > 0 ifTrue:
				[(self numRegArgs > 1 and: [numArgs > 1])
					ifTrue:
						[self ssAllocateRequiredReg: Arg0Reg upThrough: simStackPtr - 2.
						 self ssAllocateRequiredReg: Arg1Reg upThrough: simStackPtr - 1]
					ifFalse:
						[self ssAllocateRequiredReg: Arg0Reg upThrough: simStackPtr - 1]].
			 (self numRegArgs > 1 and: [numArgs > 1]) ifTrue:
				[(self simStackAt: simStackPtr) moveToReg: Arg1Reg].
			 numArgs > 0 ifTrue:
				[(self simStackAt: simStackPtr - numArgs + 1)
					moveToReg: Arg0Reg].
			 (self simStackAt: simStackPtr - numArgs)
				moveToReg: ReceiverResultReg].
	self ssPop: numArgs + 1
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeCountCounter [
	"This is a hook for SistaCogit"
	<inline: true>
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeCountFixup: descriptor [
	"This is a hook for RegisterAllocatingCogit"
	<inline: true>
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeCounterIndex [
	"Hook for SistaCogit to allow it to reuse compileBlockBodies"
	<inline: true>
	^0
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeInitNumCounters [
	"This is a hook for SistaCogit"
	<inline: true>
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeInitNumFixups [
	"This is a hook for RegisterAllocatingCogit"
	<inline: true>
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> maybeSetCounterIndex: value [
	"Hook for SistaCogit to allow it to reuse compileBlockBodies"
	<inline: true>
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> mergeWithFixupIfRequired: fixup [
	"If this bytecode has a fixup, some kind of merge needs to be done. There are 4 cases:
		1) the bytecode has no fixup (fixup isNotAFixup)
			do nothing
		2) the bytecode has a non merge fixup
			the fixup has needsNonMergeFixup.
			The code generating non merge fixup (currently only special selector code) is responsible
				for the merge so no need to do it.
			We set deadCode to false as the instruction can be reached from jumps.
		3) the bytecode has a merge fixup, but execution flow *cannot* fall through to the merge point.
			the fixup has needsMergeFixup and deadCode = true.
			ignores the current simStack as it does not mean anything 
			restores the simStack to the state the jumps to the merge point expects it to be.
		4) the bytecode has a merge fixup and execution flow *can* fall through to the merge point.
			the fixup has needsMergeFixup and deadCode = false.
			flushes the stack to the stack pointer so the fall through execution path simStack is 
				in the state the merge point expects it to be. 
			restores the simStack to the state the jumps to the merge point expects it to be.
			
	In addition, if this is a backjump merge point, we patch the fixup to hold the current simStackPtr 
	for later assertions."
	<var: #fixup type: #'BytecodeFixup *'>

	self assertCorrectSimStackPtr.

	"case 1"
	fixup notAFixup ifTrue:
		[^0].

	"case 2"
	fixup isNonMergeFixup ifTrue:
		[deadCode := false. ^0].

	"cases 3 and 4"
	self assert: fixup isMergeFixup.
	self traceMerge: fixup.
	deadCode
		ifTrue: "case 3"
			["Would like to assert fixup simStackPtr >= methodOrBlockNumTemps
			   but can't because of the initialNils hack."
			 self assert: (fixup simStackPtr >= methodOrBlockNumTemps).
			 simStackPtr := fixup simStackPtr ]
		ifFalse: "case 4"
			[self ssFlushTo: simStackPtr].

	"cases 3 and 4"
	deadCode := false.
	fixup isBackwardBranchFixup ifTrue:
		[fixup simStackPtr: simStackPtr ].
	fixup targetInstruction: self Label.
	self assert: simStackPtr = fixup simStackPtr.
	self cCode: '' inSmalltalk:
		[self assert: fixup simStackPtr = (self debugStackPointerFor: bytecodePC)].
	self restoreSimStackAtMergePoint: fixup.

	^0
]

{ #category : #trampolines }
StackToRegisterMappingCogit >> methodAbortTrampolineFor: numArgs [
	^methodAbortTrampolines at: (numArgs min: self numRegArgs + 1)
]

{ #category : #accessing }
StackToRegisterMappingCogit >> methodAbortTrampolines [
	<doNotGenerate>
	^ methodAbortTrampolines
]

{ #category : #testing }
StackToRegisterMappingCogit >> methodFoundInvalidPostScan [
	"Frameless methods with local temporaries cause problems,
	 mostly in asserts, and yet they matter not at all for performance.
	 Shun them."
	needsFrame ifFalse:
		[^methodOrBlockNumTemps > methodOrBlockNumArgs].
	^super methodFoundInvalidPostScan
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> needsFrameIfExtBGT2: stackDelta [
	^extB < 0 or: [extB > 2]
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> needsFrameIfFollowsSend: stackDelta [
	"As of August 2013, the code generator can't deal with spills in frameless methods (the
	 issue is to do with the stack offset to get at an argument, which is changed when there's a spill).
	 The only context in a spill is needed in a frameless method that I can think of is sends
	 following sends as in e.g. TextColor>>#dominates: other ^other class == self class.
	 Only need to check for the frameless sends since all other sends will force a frame."

	self assert: (prevBCDescriptor notNil and: [prevBCDescriptor needsFrameFunction notNil]).
	^prevBCDescriptor generator == #genSpecialSelectorEqualsEquals
	  or: [prevBCDescriptor generator == #genSpecialSelectorClass]
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> needsFrameIfMod16GENumArgs: stackDelta [
	^byte0 \\ 16 >= methodOrBlockNumArgs
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> needsFrameIfStackGreaterThanOne: stackDelta [
	"As of August 2013, the code generator can't deal with spills in frameless methods (the
	 issue is to do with the stack offset to get at an argument, which is changed when there's a spill).
	 In e.g. TextColor>>#dominates: other ^other class == self class the second send of class
	 needs also rto allocate a register that the first one used, but the first one's register can't be
	 spilled.  So avoid this by only allowing class to be sent if the stack contains a single element."

	^stackDelta > 1
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> numRegArgs [
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

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> numberOfSpillsInTopNItems: n [
	simStackPtr to: simStackPtr - n + 1 by: -1 do:
		[:i| (self simStackAt: i) type = SSSpill ifTrue:
			[^n - (simStackPtr - i)]].
	^0
]

{ #category : #trampolines }
StackToRegisterMappingCogit >> picAbortTrampolineFor: numArgs [
	^picAbortTrampolines at: (numArgs min: self numRegArgs + 1)
]

{ #category : #accessing }
StackToRegisterMappingCogit >> picAbortTrampolines [

	<doNotGenerate>
	^ picAbortTrampolines
]

{ #category : #accessing }
StackToRegisterMappingCogit >> picMissTrampolines [
	
	<doNotGenerate>
	^ picMissTrampolines 	

]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> populate: tuple withPICInfoFor: cPIC firstCacheTag: firstCacheTag [
	"Populate tuple (which must be large enough) with the ClosedPIC's target method class pairs.
	 The first entry in tuple contains the bytecode pc for the send, so skip the tuple's first field."
	<var: #cPIC type: #'CogMethod *'>
	| picCaseMachineCodePC cacheTag classOop entryPoint targetMethod value |
	<var: #targetMethod type: #'CogMethod *'>

	1 to: cPIC cPICNumCases do: [:i|
		picCaseMachineCodePC := self addressOfEndOfCase: i inCPIC: cPIC.
		cacheTag := i = 1
						ifTrue: [firstCacheTag]
						ifFalse: [backEnd literalBeforeFollowingAddress: picCaseMachineCodePC - backEnd jumpLongConditionalByteSize].
		
		classOop := self classForInlineCacheTag: cacheTag.
		objectMemory storePointer: i * 2 - 1 ofObject: tuple withValue: classOop.
		entryPoint := i = 1
						ifTrue: [backEnd jumpLongTargetBeforeFollowingAddress: picCaseMachineCodePC]
						ifFalse: [backEnd jumpLongConditionalTargetBeforeFollowingAddress: picCaseMachineCodePC].
		"Find target from jump.  A jump to the MNU entry-point should collect #doesNotUnderstand:"
		(cPIC containsAddress: entryPoint)
			ifTrue: [ value := objectMemory splObj: SelectorDoesNotUnderstand ]
			ifFalse: [
				targetMethod := self cCoerceSimple: entryPoint - cmNoCheckEntryOffset to: #'CogMethod *'.
				self assert: targetMethod cmType = CMMethod.
				value := targetMethod methodObject ].
		objectMemory storePointer: i * 2 ofObject: tuple withValue: value ]
]

{ #category : #testing }
StackToRegisterMappingCogit >> prevInstIsPCAnnotated [
	| prevIndex prevInst |
	<var: #prevInst type: #'AbstractInstruction *'>
	opcodeIndex > 0 ifFalse:
		[^false].
	prevIndex := opcodeIndex - 1.
	[prevIndex <= 0 ifTrue: [^false].
	 prevInst := self abstractInstructionAt: prevIndex.
	 (self isPCMappedAnnotation: (prevInst annotation ifNil: [0])) ifTrue:
		[^true].
	 prevInst opcode = Label]
		whileTrue:
			[prevIndex := prevIndex - 1].
	^false
]

{ #category : #'debug printing' }
StackToRegisterMappingCogit >> printRegisterMask: registerMask [
	<doNotGenerate>
	^String streamContents: [:s| self printRegisterMask: registerMask on: s]
]

{ #category : #'debug printing' }
StackToRegisterMappingCogit >> printRegisterMask: registerMask on: aStream [
	<doNotGenerate>
	| first |
	aStream nextPut: ${.
	registerMask = 0
		ifTrue:
			[aStream nextPutAll: 'NoReg']
		ifFalse:
			[first := true.
			 0 to: 31 do:
				[:reg|
				(registerMask anyMask: 1 << reg) ifTrue:
					[first ifFalse: [aStream space].
					 first := false.
					 aStream nextPutAll: (backEnd nameForRegister: reg)]]].
	aStream nextPut: $}; flush
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> printSimStack [
	<doNotGenerate>
	self printSimStack: simStack toDepth: simStackPtr spillBase: simSpillBase on: coInterpreter transcript
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> printSimStack: aSimStackOrFixup [
	<doNotGenerate>
	(aSimStackOrFixup isKindOf: CogRASSBytecodeFixup)
		ifTrue:
			[self printSimStack: aSimStackOrFixup mergeSimStack toDepth: aSimStackOrFixup simStackPtr spillBase: -1 on: coInterpreter transcript]
		ifFalse:
			[self printSimStack: aSimStackOrFixup toDepth: simStackPtr spillBase: simSpillBase on: coInterpreter transcript]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> printSimStack: aSimStack toDepth: limit spillBase: spillBase on: aStream [
	<doNotGenerate>
	| tempNames width tabWidth |
	aStream newLine.
	limit < 0 ifTrue:
		[^aStream nextPutAll: 'simStackEmpty'; cr; flush].
	aSimStack ifNil:
		[^aStream nextPutAll: 'nil simStack'; cr; flush].
	(self class initializationOptions at: #tempNames ifAbsent: nil) ifNotNil:
		[:tempNamesDictOrNil |	 | tab longest |
		 tempNames := tempNamesDictOrNil at: (self class initializationOptions at: #startpc ifAbsent: [initialPC]) + 1.
		 longest := tempNames inject: '' into: [:m :t| m size >= t size ifTrue: [m] ifFalse: [t]].
		 tabWidth := self widthInDefaultFontOf: (tab := String with: Character tab).
		 width := self widthInDefaultFontOf: longest, tab.
		 width <= ((self widthInDefaultFontOf: longest, (String with: Character space)) + 4) ifTrue:
			[width := width + tabWidth]].
	0 to: limit do:
		[:i|
		width ifNotNil:
			[self put: (tempNames at: i ifAbsent: [i = 0 ifTrue: ['self'] ifFalse: ['']]) paddedTo: width tabWidth: tabWidth on: aStream].
		aStream print: i.
		i = simStackPtr ifTrue:
			[aStream nextPutAll: '<-' ].
		i = spillBase ifTrue:
			[aStream nextPutAll: '(sb)'].
		aStream tab: (i = spillBase ifTrue: [1] ifFalse: [2]).
		(aSimStack at: i) printStateOn: aStream.
		aStream cr; flush].
	simSpillBase > limit ifTrue:
		[aStream nextPutAll: '(sb: '; print: simSpillBase; nextPut: $); cr; flush]
]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> profilingDataFor: descriptor Annotation: isBackwardBranchAndAnnotation Mcpc: mcpc Bcpc: bcpc Method: cogMethodArg [
	<var: #descriptor type: #'BytecodeDescriptor *'>
	<var: #mcpc type: #'char *'>
	<var: #cogMethodArg type: #'void *'>
	<var: #methodClassIfSuper type: #'sqInt'>
	| annotation entryPoint tuple counter |
	"N.B. Counters are always 32-bits, having two 16-bit halves for the reached and taken counts."
	<var: #counter type: #'unsigned int'>

	descriptor ifNil:
		[^0].
	descriptor isBranch ifTrue:
		["it's a branch; conditional?"
		 (descriptor isBranchTrue or: [descriptor isBranchFalse]) ifTrue: [ | counters | 
			counters := self
							cCoerce: ((self
											cCoerceSimple: cogMethodArg
											to: #'CogMethod *') counters)
							to: #'usqInt *'.
			"If no counters are available, do not record counters"
			counters = 0 ifTrue: [ ^ 0 ].
			
			counter := counters at: counterIndex.
			tuple := self profilingDataForCounter: counter at: bcpc + 1.
			tuple = 0 ifTrue: [^PrimErrNoMemory].
			objectMemory
				storePointer: introspectionDataIndex
				ofObject: introspectionData
				withValue: tuple.
			introspectionDataIndex := introspectionDataIndex + 1.
			counterIndex := counterIndex + 1].
		 ^0].

	annotation := isBackwardBranchAndAnnotation >> 1.
	((self isPureSendAnnotation: annotation)
	 and: [entryPoint := backEnd callTargetFromReturnAddress: mcpc asUnsignedInteger.
		 entryPoint > methodZoneBase]) ifFalse: "send is not linked, or is not a send"
		[^0].

	"It's a linked send; find which kind."
	self targetMethodAndSendTableFor: entryPoint
		annotation: annotation
		into: [:targetCogCode :sendTable| | methodClassIfSuper association |
			methodClassIfSuper := nil.
			sendTable = superSendTrampolines ifTrue: [
				methodClassIfSuper := coInterpreter methodClassOf: (self cCoerceSimple: cogMethodArg to: #'CogMethod *') methodObject.
			].
			sendTable = directedSuperSendTrampolines ifTrue: [
				association := backEnd literalBeforeInlineCacheTagAt: mcpc asUnsignedInteger.
				methodClassIfSuper := self valueOfAssociation: association ].
			tuple := self profilingDataForSendTo: targetCogCode
						methodClassIfSuper: methodClassIfSuper
						at: mcpc
						bcpc: bcpc + 1].

	tuple = 0 ifTrue: [^PrimErrNoMemory].
	objectMemory
		storePointer: introspectionDataIndex
		ofObject: introspectionData
		withValue: tuple.
	introspectionDataIndex := introspectionDataIndex + 1.
	^0
]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> profilingDataFor: cogMethod into: arrayObj [

	"Collect the branch and send data for cogMethod, storing it into arrayObj."

	<api>
	<var: #cogMethod type: #'CogMethod *'>
	| errCode |
	"If the method is frameless, it has no message sends. No need to continue."
	cogMethod stackCheckOffset = 0 ifTrue: [ ^ 0 ].

	introspectionDataIndex := counterIndex := 0.
	introspectionData := arrayObj.
	errCode := self
		           mapFor: (self cCoerceSimple: cogMethod to: #'CogBlockMethod *')
		           bcpc: (coInterpreter startPCOfMethod: cogMethod methodObject)
		           performUntil: #profilingDataFor:Annotation:Mcpc:Bcpc:Method:
		           arg: cogMethod asVoidPointer.
	errCode ~= 0 ifTrue: [ 
		self assert: errCode = PrimErrNoMemory.
		^ -1 ].
	^ introspectionDataIndex
]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> profilingDataForCounter: counter at: bcpc [
	"Undefined by now, do nothing"

	^ 0
]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> profilingDataForSendTo: cogCodeSendTarget methodClassIfSuper: methodClassOrNil at: sendMcpc bcpc: sendBcpc [
	"Answer a tuple with the send data for a linked send to cogMethod.
	 If the target is a CogMethod (monomorphic send) answer
		{ bytecode pc, inline cache class, target method }
	 If the target is an open PIC (megamorphic send) answer
		{ bytecode pc, nil, send selector }
	If the target is a closed PIC (polymorphic send) answer
		{ bytecode pc, first class, target method, second class, second target method, ... }"
	<var: #cogCodeSendTarget type: #'CogMethod *'>
	<var: #sendMcpc type: #'char *'>
	| tuple class |
	tuple := objectMemory
					eeInstantiateClassIndex: ClassArrayCompactIndex
					format: objectMemory arrayFormat
					numSlots: (cogCodeSendTarget cmType = CMPolymorphicIC
								ifTrue: [2 * cogCodeSendTarget cPICNumCases + 1]
								ifFalse: [3]).
	tuple = 0 ifTrue:
		[^0].

	objectMemory storePointerUnchecked: 0 ofObject: tuple withValue: (objectMemory integerObjectOf: sendBcpc).
	
	"Monomorphic - linked against a single method"
	cogCodeSendTarget cmType = CMMethod ifTrue: [
		"If it is not a super send, we don't have a class, let's extract it from the call site"
		class := methodClassOrNil ifNil: [
			self classForInlineCacheTag: (backEnd inlineCacheTagAt: sendMcpc asUnsignedInteger)].
		 objectMemory
			storePointer: 1 ofObject: tuple withValue: class;
			storePointer: 2 ofObject: tuple withValue: cogCodeSendTarget methodObject.
		^tuple ].

	cogCodeSendTarget cmType = CMPolymorphicIC ifTrue: [
		self
			populate: tuple
			withPICInfoFor: cogCodeSendTarget
			firstCacheTag: (backEnd inlineCacheTagAt: sendMcpc asUnsignedInteger).
		^tuple ].

	cogCodeSendTarget cmType = CMMegamorphicIC ifTrue: [
		objectMemory
			storePointerUnchecked: 1 ofObject: tuple withValue: objectMemory nilObject;
			storePointer: 2 ofObject: tuple withValue: cogCodeSendTarget selector.
		^tuple ].

	self error: 'invalid method type'.
	^0 "to get Slang to type this method as answering sqInt"
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> put: aString paddedTo: compositionWidth tabWidth: tabWidth on: aStream [
	<doNotGenerate>
	| fittedString size width |
	fittedString := aString.
	size := fittedString size.
	[(width := self widthInDefaultFontOf: fittedString) > compositionWidth] whileTrue:
		[size := size - 2.
		 fittedString := aString contractTo: size].
	aStream
		nextPutAll: fittedString;
		tab: compositionWidth - width + (width \\ tabWidth) // tabWidth + 1
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> putSelfInReceiverResultReg [
	<inline: true>
	 self simSelf storeToReg: ReceiverResultReg
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> receiverIsInReceiverResultReg [
	"Used to mark ReceiverResultReg as dead or not containing simSelf.
	 Used when the simStack has already been flushed, e.g. for sends."
	<inline: true>
	^self simSelf liveRegister = ReceiverResultReg
]

{ #category : #accessing }
StackToRegisterMappingCogit >> regArgsHaveBeenPushed: aBoolean [
	regArgsHaveBeenPushed := aBoolean
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> restoreSimStackAtMergePoint: fixup [
	<inline: true>
	"All the execution paths reaching a merge point expect everything
	 to be spilled on stack. Throw away all simStack optimization state."
	self voidReceiverOptStatus.
	methodOrBlockNumTemps + 1 to: simStackPtr do:
		[:i|
		 (self simStackAt: i)
			type: SSSpill;
			offset: FoxMFReceiver - (i - methodOrBlockNumArgs * objectMemory bytesPerOop);
			register: FPReg;
			spilled: true].
	simSpillBase := simStackPtr + 1.
	^ 0
]

{ #category : #'compile abstract instructions' }
StackToRegisterMappingCogit >> scanMethod [
	"Scan the method (and all embedded blocks) to determine
		- what the last bytecode is; extra bytes at the end of a method are used to encode things like source pointers or temp names
		- if the method needs a frame or not
		- what are the targets of any backward branches"
	| latestContinuation nExts descriptor pc distance targetPC framelessStackDelta seenInstVarStore |
	<var: #descriptor type: #'BytecodeDescriptor *'>
	needsFrame := useTwoPaths := seenInstVarStore := false.
	self maybeInitNumFixups.
	self maybeInitNumCounters.
	prevBCDescriptor := nil.
	(primitiveIndex > 0
	 and: [coInterpreter isQuickPrimitiveIndex: primitiveIndex]) ifTrue:
		[^0].
	pc := latestContinuation := initialPC.
	framelessStackDelta := nExts := extA := numExtB := extB := 0.
	[pc <= endPC] whileTrue:
		[byte0 := objectMemory fetchByte: pc ofObject: methodObj.
		 descriptor := self generatorAt: byte0.
		 descriptor isExtension ifTrue:
			[descriptor opcode = Nop ifTrue: "unknown bytecode tag; see Cogit class>>#generatorTableFrom:"
				[^EncounteredUnknownBytecode].
			 self loadSubsequentBytesForDescriptor: descriptor at: pc.
			 self perform: descriptor generator].
		 (descriptor isReturn
		  and: [pc >= latestContinuation]) ifTrue:
			[endPC := pc].
		
		  needsFrame ifFalse:
			[(descriptor needsFrameFunction isNil
			  or: [self perform: descriptor needsFrameFunction with: framelessStackDelta])
					ifTrue:
						["With immutability we win simply by avoiding a frame build if the receiver is young and not immutable."
						 self cppIf: IMMUTABILITY
							ifTrue: [descriptor is1ByteInstVarStore
									ifTrue: [useTwoPaths := true]
									ifFalse: [needsFrame := true. useTwoPaths := false]]
							ifFalse: [needsFrame := true. useTwoPaths := false]]
					ifFalse:
						[framelessStackDelta := framelessStackDelta + descriptor stackDelta.
						 "Without immutability we win if there are two or more stores and the receiver is new."
						 self cppIf: IMMUTABILITY
							ifTrue: []
							ifFalse:
								[descriptor is1ByteInstVarStore ifTrue:
									[seenInstVarStore
										ifTrue: [useTwoPaths := true]
										ifFalse: [seenInstVarStore := true]]]]].

		 descriptor isBranch ifTrue:
			[distance := self spanFor: descriptor at: pc exts: nExts in: methodObj.
			 targetPC := pc + descriptor numBytes + distance.
			 self maybeCountFixup: descriptor.
			 (self isBackwardBranch: descriptor at: pc exts: nExts in: methodObj)
				ifTrue: [self initializeFixupAt: targetPC]
				ifFalse:
					[latestContinuation := latestContinuation max: targetPC.
					 self maybeCountCounter]].
			
		 latestContinuation := self 
			maybeDealWithUnsafeJumpForDescriptor: descriptor 
			pc: pc 
			latestContinuation: latestContinuation.

		 pc := pc + descriptor numBytes.
		 nExts := descriptor isExtension ifTrue: [nExts + 1] ifFalse: [extA := numExtB := extB := 0].
		 prevBCDescriptor := descriptor].
	
	"ok"
	^ 0
]

{ #category : #initialization }
StackToRegisterMappingCogit >> setInterpreter: aCoInterpreter [
	"Initialization of the code generator in the simulator.
	 These objects already exist in the generated C VM
	 or are used only in the simulation."
	<doNotGenerate>
	super setInterpreter: aCoInterpreter.

	methodAbortTrampolines := CArrayAccessor on: (Array new: self numRegArgs + 2).
	picAbortTrampolines := CArrayAccessor on: (Array new: self numRegArgs + 2).
	picMissTrampolines := CArrayAccessor on: (Array new: self numRegArgs + 2).

	simStack := CArrayAccessor on: ((1 to: self class simStackSlots) collect: [:i| self simStackEntryClass new cogit: self]).
	debugFixupBreaks := self class initializationOptions at: #debugFixupBreaks ifAbsent: [Set new].

	numPushNilsFunction := self class numPushNilsFunction.
	pushNilSizeFunction := self class pushNilSizeFunction
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> simNativeStackSlots [
	"Answer the number of slots toinclude in a simulated stack.
	 This needs to be big enough to include all slots in a context
	 plus some overflow for safety."
	<inline: true>
	^((LargeContextSlots - CtxtTempFrameStart max: 64) * 11 // 10)
]

{ #category : #accessing }
StackToRegisterMappingCogit >> simSelf [
	<cmacro: '() simStack'>
	<returnTypeC: #'CogSimStackEntry *'>
	^self simStackAt: 0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> simStackAt: index [
	<cmacro: '(index) (simStack + (index))'>
	<returnTypeC: #'CogSimStackEntry *'>
	^self addressOf: (simStack at: index)
]

{ #category : #initialization }
StackToRegisterMappingCogit >> simStackEntryClass [
	<doNotGenerate>
	^CogSimStackEntry
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> simStackPrintString [
	<doNotGenerate>
	^String streamContents: [:s| self printSimStack: simStack toDepth: simStackPtr spillBase: simSpillBase on: s]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> simStackSlots [
	"Answer the number of slots to include in a simulated stack.
	 This needs to be big enough to include all stack slots in a context
	 plus a slot for the receiver and some overflow for safety."
	<inline: true>
	^((LargeContextSlots - CtxtTempFrameStart + 1 max: 64) * 11 // 10)
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> slotOffsetOfInstVarIndex: index [
	
	self subclassResponsibility
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateCallReg: requiredReg [
	"Allocate a register needed in a run-time call (i.e. flush uses of the
	 register to the real stack).  Since the run-time can smash any and
	 all caller-saved registers also flush all caller-saved registers."
	<inline: true>
	self ssAllocateRequiredRegMask: (CallerSavedRegisterMask
										bitOr: (self registerMaskFor: requiredReg))
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateCallReg: requiredReg1 and: requiredReg2 [
	"Allocate registers needed in a run-time call (i.e. flush uses of the
	 registers to the real stack).  Since the run-time can smash any and
	 all caller-saved registers also flush all caller-saved registers."
	<inline: true>
	self ssAllocateRequiredRegMask: (CallerSavedRegisterMask
										bitOr: ((self registerMaskFor: requiredReg1)
										bitOr: (self registerMaskFor: requiredReg2)))
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateCallReg: requiredReg1 and: requiredReg2 and: requiredReg3 [
	"Allocate registers needed in a run-time call (i.e. flush uses of the
	 registers to the real stack).  Since the run-time can smash any and
	 all caller-saved registers also flush all caller-saved registers."
	<inline: true>
	self ssAllocateRequiredRegMask: (CallerSavedRegisterMask bitOr:
										(self registerMaskFor: requiredReg1 and: requiredReg2 and: requiredReg3))
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateCallReg: requiredReg1 and: requiredReg2 and: requiredReg3 and: requiredReg4 [
	"Allocate registers needed in a run-time call (i.e. flush uses of the
	 registers to the real stack).  Since the run-time can smash any and
	 all caller-saved registers also flush all caller-saved registers."
	<inline: true>
	self ssAllocateRequiredRegMask: (CallerSavedRegisterMask
										bitOr: ((self registerMaskFor: requiredReg1)
										bitOr: ((self registerMaskFor: requiredReg2)
										bitOr: ((self registerMaskFor: requiredReg3)
										bitOr: (self registerMaskFor: requiredReg4)))))
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredFloatReg: requiredReg [
	self ssAllocateRequiredFloatRegMask: (self registerMaskFor: requiredReg)
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredFloatRegMask: requiredRegsMask upThrough: stackPtr [
	| lastRequired lastRequiredNative liveRegs |
	lastRequired := -1.
	lastRequiredNative := -1.
	"compute live regs while noting the last occurrence of required regs.
	 If these are not free we must spill from simSpillBase to last occurrence.
	 Note we are conservative here; we could allocate FPReg in frameless methods."
	liveRegs := NoReg.
	(simSpillBase max: 0) to: stackPtr do:
		[:i|
		liveRegs := liveRegs bitOr: (self simStackAt: i) registerMask.
		((self simStackAt: i) floatRegisterMask bitAnd: requiredRegsMask) ~= 0 ifTrue:
			[lastRequired := i]].

	"If any of requiredRegsMask are live we must spill."
	(liveRegs bitAnd: requiredRegsMask) = 0 ifFalse:
		["Some live, must spill"
		self ssFlushTo: lastRequired.
		self assert: (self liveFloatRegisters bitAnd: requiredRegsMask) = 0]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredReg: requiredReg [
	<inline: true>
	self ssAllocateRequiredRegMask: (self registerMaskFor: requiredReg)
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredReg: requiredReg1 and: requiredReg2 [
	<inline: true>
	self ssAllocateRequiredRegMask: ((self registerMaskFor: requiredReg1)
										bitOr: (self registerMaskFor: requiredReg2))
		upThrough: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredReg: requiredReg upThrough: stackPtr [
	<inline: true>
	self ssAllocateRequiredRegMask: (self registerMaskFor: requiredReg)
		upThrough: stackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssAllocateRequiredRegMask: requiredRegsMask upThrough: stackPtr [
	| lastRequired lastRequiredNative liveRegs |
	lastRequired := -1.
	lastRequiredNative := -1.
	"compute live regs while noting the last occurrence of required regs.
	 If these are not free we must spill from simSpillBase to last occurrence.
	 Note we are conservative here; we could allocate FPReg in frameless methods."
	liveRegs := self registerMaskFor: FPReg and: SPReg.
	(simSpillBase max: 0) to: stackPtr do:
		[:i|
		liveRegs := liveRegs bitOr: (self simStackAt: i) registerMask.
		((self simStackAt: i) registerMask anyMask: requiredRegsMask) ifTrue:
			[lastRequired := i]].
	"If any of requiredRegsMask are live we must spill."
	(liveRegs anyMask: requiredRegsMask) ifTrue:
		[self ssFlushTo: lastRequired.
		 self deny: (self liveRegisters anyMask: requiredRegsMask)]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssDescriptorAt: index [
	"Return the descriptor at an index relative from the top.
	0 is top, |size| - 1 is the bottom"
	<returnTypeC: #SimStackEntry>
	<inline: true>
	^simStack at: simStackPtr - index
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssFlushTo: index [
	<inline: true>
	self assert: self tempsValidAndVolatileEntriesSpilled.
	simSpillBase <= index ifTrue:
		[(((simSpillBase max: methodOrBlockNumTemps + 1) min: simStackPtr) min: index) to: index do:
			[:i|
			self assert: needsFrame.
			(self simStackAt: i)
				ensureSpilledAt: (self frameOffsetOfTemporary: i - 1) "frameOffsetOfTemporary: is 0-relative"
				from: FPReg].
		 simSpillBase := index + 1]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssFlushUpThrough: unaryBlock [
	"Any occurrences on the stack of the value being stored (which is the top of stack)
	 must be flushed, and hence any values colder than them stack."

	self assert: simSpillBase >= 0.
	simStackPtr - 1 to: simSpillBase by: -1 do:
		[ :index |
		(unaryBlock value: (self simStackAt: index)) ifTrue: [ ^ self ssFlushTo: index ] ]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssFlushUpThroughReceiverVariable: slotIndex [
	"Any occurrences on the stack of the value being stored (which is the top of stack)
	 must be flushed, and hence any values colder than them stack."
	<var: #desc type: #'CogSimStackEntry *'>
	self ssFlushUpThrough: 
		[ :desc |  
			desc type = SSBaseOffset
			 and: [desc register = ReceiverResultReg
			 and: [desc offset = (self slotOffsetOfInstVarIndex: slotIndex) ] ] ]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssFlushUpThroughRegister: reg [
	"Any occurrences on the stack of the register must be
	 flushed, and hence any values colder than them stack."
	<var: #desc type: #'CogSimStackEntry *'>
	self ssFlushUpThrough: [ :desc | desc type = SSRegister and: [ desc register = reg ] ]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssFlushUpThroughTemporaryVariable: tempIndex [
	"Any occurrences on the stack of the value being stored (which is the top of stack)
	 must be flushed, and hence any values colder than them stack."
	<var: #desc type: #'CogSimStackEntry *'>
	| offset |
	offset := (self simStackAt: tempIndex + 1) offset.
	self assert: offset = (self frameOffsetOfTemporary: tempIndex).
	self ssFlushUpThrough: 
		[ :desc |
			desc type = SSBaseOffset
		 	and: [desc register = FPReg
		 	and: [desc offset = offset ] ] ]
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPop: n [
	self assert: (simStackPtr - n >= methodOrBlockNumTemps
				or: [(needsFrame not and: [simStackPtr - n >= 0])]).
	simStackPtr := simStackPtr - n.
	self updateSimSpillBase
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPush: n [ 
	simStackPtr := simStackPtr + n
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushAnnotatedConstant: literal [
	self ssPushConstant: literal.
	self annotateInstructionForBytecode.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushBase: reg offset: offset [
	self ssPush: 1.
	self ssTop
		type: SSBaseOffset;
		spilled: false;
		register: reg;
		offset: offset;
		bcptr: bytecodePC.
	self updateSimSpillBase.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushConstant: literal [
	self ssPush: 1.
	self ssTop
		type: SSConstant;
		spilled: false;
		constant: literal;
		bcptr: bytecodePC.
	self updateSimSpillBase.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushDesc: simStackEntry [
	<var: #simStackEntry type: #SimStackEntry>
	self cCode:
			[simStackEntry type = SSSpill ifTrue:
				[simStackEntry type: SSBaseOffset].
			simStackEntry
				spilled: false;
				bcptr: bytecodePC.
			 simStack
				at: (simStackPtr := simStackPtr + 1)
				put: simStackEntry]
		inSmalltalk:
			[(simStack at: (simStackPtr := simStackPtr + 1))
				copyFrom: simStackEntry;
				type: (simStackEntry type = SSSpill
						ifTrue: [SSBaseOffset]
						ifFalse: [simStackEntry type]);
				spilled: false;
				bcptr: bytecodePC].
	self updateSimSpillBase.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushR: reg [
1halt.
	^ self ssPushRegister: reg
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushRegister: reg [
	self ssPush: 1.
	self ssTop
		type: SSRegister;
		spilled: false;
		register: reg;
		bcptr: bytecodePC.
	self updateSimSpillBase.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssPushVectorRegister: reg [
	self ssPush: 1.
	self ssTop
		type: SSVectorRegister;
		spilled: false;
		register: reg;
		bcptr: bytecodePC.
	self ssTop.
	self updateSimSpillBase.
	^0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssSelfDescriptor [
	<returnTypeC: #SimStackEntry>
	<inline: true>
	^simStack at: 0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssStoreAndReplacePop: popBoolean toReg: reg [
	"In addition to ssStorePop:toReg:, if this is a store and not
	a popInto I change the simulated stack to use the register 
	for the top value"
	| topSpilled |
	topSpilled := self ssTop spilled.
	self ssStorePop: (popBoolean or: [topSpilled]) toReg: reg.
	popBoolean ifFalse: 
		[ topSpilled ifFalse: [self ssPop: 1].
		self ssPushRegister: reg ].
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssStorePop: popBoolean toPreferredReg: preferredReg [
	"Store or pop the top simulated stack entry to a register.
	 Use preferredReg if the entry is not itself a register.
	 Answer the actual register the result ends up in."
	| actualReg |
	actualReg := preferredReg.
	self ssTop type = SSRegister ifTrue: 
		[self assert: self ssTop spilled not.
		 actualReg := self ssTop register].
	self ssStorePop: popBoolean toReg: actualReg. "generates nothing if ssTop is already in actualReg"
	^ actualReg
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssStorePop: popBoolean toReg: reg [
	"Store or pop the top simulated stack entry to a register.
	N.B.: popToReg: and storeToReg: does not generate anything if 
	it moves a register to the same register."	
	popBoolean
		ifTrue: [self ssTop moveToReg: reg.
				self ssPop: 1]
		ifFalse: [self ssTop storeToReg: reg].
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssTop [
	<returnTypeC: #'CogSimStackEntry *'>
	^self simStackAt: simStackPtr
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssTopDescriptor [
	<returnTypeC: #SimStackEntry>
	<inline: true>
	^ self ssDescriptorAt: 0
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> ssValue: n [
	<returnTypeC: #'CogSimStackEntry *'>
	^self simStackAt: simStackPtr - n
]

{ #category : #testing }
StackToRegisterMappingCogit >> stackEntryIsBoolean: simStackEntry [

	self subclassResponsibility
]

{ #category : #testing }
StackToRegisterMappingCogit >> stackTopIsBoolean [
	<inline: true>
	^simStackPtr >= methodOrBlockNumArgs and: [self stackEntryIsBoolean: self ssTop]
]

{ #category : #debugging }
StackToRegisterMappingCogit >> tempsValidAndVolatileEntriesSpilled [
	"Answer if the stack is valid up to, but not including, simSpillBase."
	| culprit |
	1 to: methodOrBlockNumTemps do:
		[:i|
		 ((self simStackAt: i) type = SSBaseOffset) ifFalse:
			[culprit ifNil: [culprit := i].
			 ^false]].
	methodOrBlockNumTemps + 1 to: simSpillBase - 1 do:
		[:i|
		 (self simStackAt: i) spilled ifFalse:
			[culprit ifNil: [culprit := i].
			 ^false]].
	^true
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> traceDescriptor: descriptor [
	<cmacro: '(ign) 0'>
	(compilationTrace anyMask: 2) ifTrue:
		[coInterpreter transcript cr; print: bytecodePC; space; nextPutAll: descriptor generator.
		 deadCode ifTrue: [coInterpreter transcript nextPutAll: ' => deadCode'].
		 coInterpreter flush]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> traceFixup: fixup merge: isMerge [
	<cmacro: '(igu,ana) 0'>
	| index |
	(compilationTrace anyMask: 32) ifTrue:
		[index := (fixups object identityIndexOf: fixup) - 1.
		 coInterpreter transcript
			newLine;
			print: bytecodePC; nextPutAll: ' -> '; print: index; nextPut: $/; print: index + initialPC;
			nextPut: $:; space.
		 isMerge
			ifTrue: [fixup printStateOn: coInterpreter transcript]
			ifFalse: [coInterpreter transcript nextPutAll: 'non-merge'].
		 coInterpreter transcript cr; flush]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> traceMerge: fixup [
	<cmacro: '(ign) 0'>
	| index |
	(compilationTrace anyMask: 16) ifTrue:
		[index := (fixups object identityIndexOf: fixup) - 1.
		 coInterpreter transcript
			newLine;
			print: index; nextPut: $/; print: index + initialPC;
			nextPut: $:; space.
			fixup printStateOn: coInterpreter transcript.
			coInterpreter transcript cr; flush]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> traceSimStack [
	<cmacro: '() 0'>
	(compilationTrace anyMask: 4) ifTrue:
		[self printSimStack]
]

{ #category : #'simulation only' }
StackToRegisterMappingCogit >> traceSpill: simStackEntry [
	<cmacro: '(ign) 0'>
	(compilationTrace anyMask: 8) ifTrue:
		[coInterpreter transcript cr; print: bytecodePC; space; print: simStackEntry; flush]
]

{ #category : #'peephole optimizations' }
StackToRegisterMappingCogit >> tryCollapseTempVectorInitializationOfSize: slots [
	"If the sequence of bytecodes is
		push: (Array new: 1)
		popIntoTemp: tempIndex
		pushConstant: const or pushTemp: n
		popIntoTemp: 0 inVectorAt: tempIndex
	 collapse this into
		tempAt: tempIndex put: {const or temp}
	 and answer true, otherwise answer false.
	 One might think that we should look for a sequence of more than
	 one pushes and pops but this is extremely rare.
	 Exclude pushRcvr: n to avoid potential complications with context inst vars."
	| pushArrayDesc storeArrayDesc pushValueDesc storeValueDesc tempIndex remoteTempIndex reg |
	<var: #pushArrayDesc type: #'BytecodeDescriptor *'>
	<var: #pushValueDesc type: #'BytecodeDescriptor *'>
	<var: #storeArrayDesc type: #'BytecodeDescriptor *'>
	<var: #storeValueDesc type: #'BytecodeDescriptor *'>
	slots ~= 1 ifTrue:
		[^false].
	pushArrayDesc := self generatorForPC: bytecodePC.
	self assert: pushArrayDesc generator == #genPushNewArrayBytecode.
	storeArrayDesc := self generatorForPC: bytecodePC + pushArrayDesc numBytes.
	storeArrayDesc generator == #genStoreAndPopTemporaryVariableBytecode
		ifTrue:
			[tempIndex := (objectMemory
								fetchByte: bytecodePC + pushArrayDesc numBytes
								ofObject: methodObj) bitAnd: 16r7]
		ifFalse:
			[storeArrayDesc generator == #genLongStoreAndPopTemporaryVariableBytecode ifFalse:
				[^false].
			 tempIndex := objectMemory
								fetchByte: bytecodePC + pushArrayDesc numBytes + 1
								ofObject: methodObj].
	pushValueDesc := self generatorForPC: bytecodePC
										+ pushArrayDesc numBytes
										+ storeArrayDesc numBytes.
	(pushValueDesc generator == #genPushLiteralConstantBytecode
	 or: [pushValueDesc generator == #genPushTemporaryVariableBytecode]) ifFalse:
		[^false].
	storeValueDesc := self generatorForPC: bytecodePC
											+ pushArrayDesc numBytes
											+ storeArrayDesc numBytes
											+ pushValueDesc numBytes.
	remoteTempIndex := objectMemory
									fetchByte: bytecodePC
											+ pushArrayDesc numBytes
											+ storeArrayDesc numBytes
											+ pushValueDesc numBytes
											+ 2
									ofObject: methodObj.
	(storeValueDesc generator == #genStoreAndPopRemoteTempLongBytecode
	 and: [tempIndex = remoteTempIndex]) ifFalse:
		[^false].

	self genNewArrayOfSize: 1 initialized: false.
	self evaluate: pushValueDesc at: bytecodePC + pushArrayDesc numBytes + storeArrayDesc numBytes.
	reg := self ssStorePop: true toPreferredReg: TempReg.
	self
		genStoreSourceReg: reg
		slotIndex: 0
		intoNewObjectInDestReg: ReceiverResultReg.
	self ssPushRegister: ReceiverResultReg.
	self evaluate: storeArrayDesc at: bytecodePC + pushArrayDesc numBytes.
	bytecodePC := bytecodePC
					"+ pushArrayDesc numBytes this gets added by nextBytecodePCFor:at:exts:in:"
					+ storeArrayDesc numBytes
					+ pushValueDesc numBytes
					+ storeValueDesc numBytes.
	^true
]

{ #category : #'simulation stack' }
StackToRegisterMappingCogit >> updateSimSpillBase [
	"Something volatile has been pushed on the stack; update simSpillBase accordingly."
	<inline: true>
	self assert: ((simSpillBase > methodOrBlockNumTemps
				and: [simStackPtr >= methodOrBlockNumTemps])).
	simSpillBase > simStackPtr
		ifTrue:
			[simSpillBase := simStackPtr + 1.
			 [simSpillBase - 1 > methodOrBlockNumTemps
			   and: [(self simStackAt: simSpillBase - 1) spilled not]] whileTrue:
				[simSpillBase := simSpillBase - 1]]
		ifFalse:
			[[(self simStackAt: simSpillBase) spilled
			   and: [simSpillBase <= simStackPtr]] whileTrue:
				[simSpillBase := simSpillBase + 1]].
	methodOrBlockNumTemps + 1 to: (simSpillBase - 1 min: simStackPtr) do:
		[:i|
		self assert: (self simStackAt: i) spilled == true].
	self assert: (simSpillBase > simStackPtr or: [(self simStackAt: simSpillBase) spilled == false])
]

{ #category : #'method introspection' }
StackToRegisterMappingCogit >> valueOfAssociation: associationOop [
	| association |
	association := associationOop.
	(objectMemory isForwarded: association) ifTrue:
		[association := objectMemory followForwarded: association].
	^objectMemory fetchPointer: ValueIndex ofObject: association
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> voidReceiverOptStatus [
	"Used to mark ReceiverResultReg as dead or not containing simSelf.
	 Used when the simStack has already been flushed, e.g. for sends."
	<inline: true>
	self simSelf liveRegister: NoReg
]

{ #category : #'bytecode generator support' }
StackToRegisterMappingCogit >> voidReceiverResultRegContainsSelf [
	"Used when ReceiverResultReg is allocated for other than simSelf, and
	 there may be references to ReceiverResultReg which need to be spilled."
	| spillIndex |
	self voidReceiverOptStatus.
	spillIndex := 0.
	(methodOrBlockNumTemps + 1 max: simSpillBase) to: simStackPtr do:
		[:i|
		(self simStackAt: i) registerOrNone = ReceiverResultReg ifTrue:
			[spillIndex := i]].
	spillIndex > 0 ifTrue:
		[self ssFlushTo: spillIndex]
]
