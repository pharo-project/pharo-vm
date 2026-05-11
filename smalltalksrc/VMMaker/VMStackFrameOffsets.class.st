"
I am a shared pool for the constants that define frame layout shared between the stack interpreters and the cogit.
"
Class {
	#name : 'VMStackFrameOffsets',
	#superclass : 'SharedPool',
	#classVars : [
		'FoxCallerSavedIP',
		'FoxIFReceiver',
		'FoxIFSavedIP',
		'FoxIFrameFlags',
		'FoxMFReceiver',
		'FoxMethod',
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
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}
