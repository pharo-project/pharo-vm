inline primitive generators generated code
genLowcodeStoreInt8ToMemory
	<option: #LowcodeVM>
	<inline: true>
	"Generated by the Lowcode instruction generator."
	| pointer value |
	self allocateRegistersForLowcodeInteger2: [:pointerValue :valueValue |
		pointer := pointerValue.
		value := valueValue.
	].

	self ssNativeTop nativePopToReg: pointer.
	self ssNativePop: 1.
	self ssNativeTop nativePopToReg: value.
	self ssNativePop: 1.

	self MoveR: value R: TempReg.
	self MoveR: TempReg M8: 0 r: pointer.

	^ 0

