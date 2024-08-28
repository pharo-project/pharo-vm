Class {
	#name : 'CogSistaMethodSurrogate64',
	#superclass : 'CogMethodSurrogate64',
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
CogSistaMethodSurrogate64 class >> alignedByteSize [
	^40 + self baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate64 class >> offsetOf: aByteSymbol [
	"These should be generated!!"
	^aByteSymbol == #counters
		ifTrue: [32 + self objectMemoryClass baseHeaderSize]
		ifFalse: [super offsetOf: aByteSymbol]
]

{ #category : 'accessing' }
CogSistaMethodSurrogate64 >> counters [
	^memory unsignedLong64At: address + 32 + baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate64 >> counters: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 32
		put: aValue
]
