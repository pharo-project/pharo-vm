initialization
genTrampolineFor: aRoutine called: trampolineName numArgs: numArgs floatArg: regOrConst0 floatArg: regOrConst1 floatArg: regOrConst2 floatArg: regOrConst3 regsToSave: regMask pushLinkReg: pushLinkReg resultReg: resultRegOrNone appendOpcodes: appendBoolean
	"Generate a trampoline with up to four arguments.  Generate either a call or a jump to aRoutineOrNil
	 as requested by callJumpBar.  If generating a call and resultRegOrNone is not NoReg pass the C result
	 back in resultRegOrNone.
	 Hack: a negative value indicates an abstract register, a non-negative value indicates a constant."
	<option: #LowcodeVM>
	<var: #aRoutine type: #'void *'>
	<var: #trampolineName type: #'char *'>
	| startAddress |
	<inline: false>
	startAddress := methodZoneBase.
	appendBoolean ifFalse:
		[self zeroOpcodeIndex].
	self compileTrampolineFor: aRoutine
		numArgs: numArgs
		floatArg: regOrConst0
		floatArg: regOrConst1
		floatArg: regOrConst2
		floatArg: regOrConst3
		regsToSave: regMask
		pushLinkReg: pushLinkReg
		resultReg: resultRegOrNone.
	self outputInstructionsForGeneratedRuntimeAt: startAddress.
	self recordGeneratedRunTime: trampolineName address: startAddress.
	self recordRunTimeObjectReferences.
	^startAddress