Class {
	#name : 'CogSistaMethodSurrogate32',
	#superclass : 'CogMethodSurrogate32',
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
CogSistaMethodSurrogate32 class >> alignedByteSize [
	^28 + self baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 class >> offsetOf: aByteSymbol [
	"These should be generated!!"
	^aByteSymbol == #counters
		ifTrue: [23 + self objectMemoryClass baseHeaderSize]
		ifFalse: [super offsetOf: aByteSymbol]
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 >> counters [
	^memory unsignedLong32At: address + 23 + baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 >> counters: aValue [
	^memory
		unsignedLong32At: address + baseHeaderSize + 23
		put: aValue
]
