inline primitive generators generated code
genLowcodeFloat32Div
	<option: #LowcodeVM>
	<inline: true>
	"Generated by the Lowcode instruction generator."
	| second first |
	self allocateRegistersForLowcodeFloat2: [:secondValue :firstValue |
		second := secondValue.
		first := firstValue.
	].

	self ssNativeTop nativePopToReg: second.
	self ssNativePop: 1.
	self ssNativeTop nativePopToReg: first.
	self ssNativePop: 1.

	self DivRs: second Rs: first.
	self ssPushNativeRegisterSingleFloat: first.

	^ 0

