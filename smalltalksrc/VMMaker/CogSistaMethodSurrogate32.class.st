Class {
	#name : 'CogSistaMethodSurrogate32',
	#superclass : 'CogMethodSurrogate32',
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
CogSistaMethodSurrogate32 class >> alignedByteSize [
	^24 + self baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 class >> offsetOf: aByteSymbol [
	"These should be generated!!"
	^aByteSymbol == #counters
		ifTrue: [20 + self objectMemoryClass baseHeaderSize]
		ifFalse: [super offsetOf: aByteSymbol]
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 >> counters [
	^memory unsignedLong32At: address + 20 + baseHeaderSize
]

{ #category : 'accessing' }
CogSistaMethodSurrogate32 >> counters: aValue [
	^memory
		unsignedLong32At: address + baseHeaderSize + 20
		put: aValue
]
