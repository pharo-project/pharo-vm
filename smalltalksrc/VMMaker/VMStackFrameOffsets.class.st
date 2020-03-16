"
I am a shared pool for the constants that define frame layout shared between the stack interpreters and the cogit.
"
Class {
	#name : #VMStackFrameOffsets,
	#superclass : #SharedPool,
	#classVars : [
		'FoxCallerContext',
		'FoxCallerSavedIP',
		'FoxFrameFlags',
		'FoxIFNativeContextFrameBase',
		'FoxIFNativeContextMark',
		'FoxIFNativeContextSize',
		'FoxIFNativeContextStackPointer',
		'FoxIFReceiver',
		'FoxIFSavedIP',
		'FoxIFrameFlags',
		'FoxMFNativeContextFrameBase',
		'FoxMFNativeContextMark',
		'FoxMFNativeContextSize',
		'FoxMFNativeContextStackPointer',
		'FoxMFReceiver',
		'FoxMethod',
		'FoxNativeContextFrameBase',
		'FoxNativeContextMark',
		'FoxNativeContextSize',
		'FoxNativeContextStackPointer',
		'FoxReceiver',
		'FoxSavedFP',
		'FoxThisContext',
		'FrameSlots',
		'IFrameSlots',
		'MFMethodFlagHasContextFlag',
		'MFMethodFlagIsBlockFlag',
		'MFMethodFlagsMask',
		'MFMethodMask',
		'MFrameSlots'
	],
	#category : #'VMMaker-Interpreter'
}
