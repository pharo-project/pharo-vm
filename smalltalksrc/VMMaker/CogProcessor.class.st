Class {
	#name : #CogProcessor,
	#superclass : #Object,
	#category : #'VMMaker-Processor'
}

{ #category : #'as yet unclassified' }
CogProcessor class >> findProcessorForISA: isa [
	self allSubclassesDo: [ :cls |
		cls isa ifNotNil: [ :clsISA |
			clsISA == clsISA ifTrue: [^ cls]
		]
	].

	^ CogDummyProcessor
]

{ #category : #'as yet unclassified' }
CogProcessor class >> isa [
	^ nil
]

{ #category : #'inline cacheing' }
CogProcessor >> flushICacheFrom: startAddress to: endAddress [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
CogProcessor >> fp [
	^ self subclassResponsibility
]

{ #category : #initialization }
CogProcessor >> initializeStackFor: aCogit [
	self subclassResponsibility
]

{ #category : #initialization }
CogProcessor >> setFramePointer: framePointer stackPointer: stackPointer [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
CogProcessor >> sp [
	^ self subclassResponsibility
]
