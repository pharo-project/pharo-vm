Class {
	#name : 'VMStackPagesMSB',
	#superclass : 'VMStackPages',
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}

{ #category : 'memory access' }
VMStackPagesMSB >> byteAt: byteAddress [
	| lowBits bpwMinus1 |
	bpwMinus1 := objectMemory wordSize - 1.
	lowBits := byteAddress bitAnd: bpwMinus1.
	^((self unsignedLongAt: byteAddress - lowBits)
		bitShift: (lowBits - bpwMinus1) * 8)
		bitAnd: 16rFF
]
