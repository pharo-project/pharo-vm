Class {
	#name : #CoInterpreterWithLiveTyping,
	#superclass : #CoInterpreterPrimitives,
	#category : #'VMMaker-JIT'
}

{ #category : #trampolines }
CoInterpreterWithLiveTyping >> cePrintHello [ 
	<api>
	self cCode: 'printf("hello trampoline!");'.

]

{ #category : #trampolines }
CoInterpreterWithLiveTyping >> cePrintReceiver: receiver [ 
	<api>
	self printReceiver: receiver.

]

{ #category : #'stack bytecodes' }
CoInterpreterWithLiveTyping >> extendedStoreBytecodePop: popBoolean [
	"Override to use itemporary:in:put:"
	| descriptor variableType variableIndex value |
	<inline: true>
	descriptor := self fetchByte.
	variableType := descriptor >> 6 bitAnd: 3.
	variableIndex := descriptor bitAnd: 63.
	value := self internalStackTop.
	popBoolean ifTrue: [ self internalPop: 1 ].
	variableType = 0 ifTrue:
		[objectMemory storePointerImmutabilityCheck: variableIndex ofObject: self receiver withValue: value.
		"self printHello."
		self printReceiver: self receiver.
		^ self fetchNextBytecode.].
	variableType = 1 ifTrue:
		[ self fetchNextBytecode.
		^self itemporary: variableIndex in: localFP put: value].
	variableType = 3 ifTrue:
		[self storeLiteralVariable: variableIndex withValue: value.
		^ self fetchNextBytecode.].
	self error: 'illegal store'
]
