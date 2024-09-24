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
		'BytecodeSetHasDirectedSuperSend',
		'CtxtTempFrameStart',
		'LargeContextBit',
		'LargeContextSlots',
		'SistaV1BytecodeSet',
		'SmallContextSlots'
	],
	#pools : [
		'VMBasicConstants'
	],
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}

{ #category : 'simulator initialization' }
VMBytecodeConstants class >> falsifyBytecodeSetFlags: initializationOptions [
	SistaV1BytecodeSet.
	classPool keys do:
		[:k|
		(k endsWith: 'BytecodeSet') ifTrue:
			[classPool at: k put: false.
			 initializationOptions at: k put: false]]

	"classPool keys select: [:k| k endsWith: 'BytecodeSet']"
]
