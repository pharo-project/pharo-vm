Class {
	#name : #CogDummyProcessor,
	#superclass : #CogProcessor,
	#instVars : [
		'framePointer',
		'stackPointer'
	],
	#category : #'VMMaker-Processor'
}

{ #category : #'inline cacheing' }
CogDummyProcessor >> flushICacheFrom: startAddress to: endAddress [
]

{ #category : #'as yet unclassified' }
CogDummyProcessor >> fp [
	^ framePointer
]

{ #category : #initialization }
CogDummyProcessor >> initializeStackFor: aCogit [
	aCogit objectMemory wordSize = 8 ifTrue: [
		"X64 System V"
		aCogit setStackAlignment: 32 expectedSPOffset: 0 expectedFPOffset: 16.
	] ifFalse: [ 
		"IA32"
		aCogit setStackAlignment: 16 expectedSPOffset: 0 expectedFPOffset: 8.
	].
]

{ #category : #initialization }
CogDummyProcessor >> setFramePointer: theFramePointer stackPointer: theStackPointer [
	framePointer := theFramePointer.
	stackPointer := theStackPointer.
]

{ #category : #'as yet unclassified' }
CogDummyProcessor >> sp [
	^ stackPointer
]
