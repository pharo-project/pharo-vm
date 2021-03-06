register allocation
availableRegisterOrNoneFor: liveRegsMask
	"Answer an unused abstract register in the liveRegMask.
	 Subclasses with more registers can override to answer them.
	 N.B. Do /not/ allocate TempReg."
	<returnTypeC: #sqInt>
	(cogit register: Extra5Reg isInMask: liveRegsMask) ifFalse:
		[^Extra5Reg].
	(cogit register: Extra4Reg isInMask: liveRegsMask) ifFalse:
		[^Extra4Reg].
	(cogit register: Extra3Reg isInMask: liveRegsMask) ifFalse:
		[^Extra3Reg].
	(cogit register: Extra2Reg isInMask: liveRegsMask) ifFalse:
		[^Extra2Reg].
	(cogit register: Extra1Reg isInMask: liveRegsMask) ifFalse:
		[^Extra1Reg].
	(cogit register: Extra0Reg isInMask: liveRegsMask) ifFalse:
		[^Extra0Reg].
	^super availableRegisterOrNoneFor: liveRegsMask