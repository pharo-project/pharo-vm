inline primitive generators generated code
genLowcodeUint32ToOop
	<option: #LowcodeVM>	"Lowcode instruction generator"
	| value |

	(value := backEnd availableRegisterOrNoneFor: self liveRegisters) = NoReg ifTrue:
		[self ssAllocateRequiredReg:
			(value := optStatus isReceiverResultRegLive
				ifTrue: [Arg0Reg]
				ifFalse: [ReceiverResultReg])].
	value = ReceiverResultReg ifTrue:
		[ optStatus isReceiverResultRegLive: false ].
	self ssNativeTop nativePopToReg: value.
	self ssNativePop: 1.

	self ssFlushAll.
	objectRepresentation genLcUInt32ToOop: value.

	^ 0

