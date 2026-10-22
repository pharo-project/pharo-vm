"
self ensureClassPool.
#(CtxtTempFrameStart LargeContextBit LargeContextSize SmallContextSize) do:
	[:k|
	self classPool declare: k from: ObjectMemory classPool]
"
Class {
	#name : 'VMBytecodeConstants',
	#superclass : 'SharedPool',
	#classVars : [
		'CtxtTempFrameStart',
		'LargeContextBit',
		'LargeContextSlots',
		'SmallContextSlots'
	],
	#pools : [
		'VMBasicConstants'
	],
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}
