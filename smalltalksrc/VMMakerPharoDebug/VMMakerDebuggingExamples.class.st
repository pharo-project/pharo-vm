Class {
	#name : #VMMakerDebuggingExamples,
	#superclass : #Object,
	#category : #'VMMakerPharoDebug-Examples'
}

{ #category : #'as yet unclassified' }
VMMakerDebuggingExamples class >> exampleCompileAndDisassemblyMethod [
	| method cogMethod |
	method := self class >> #sampleMethod.
	cogMethod := StackToRegisterMappingCogit cog: method options: #(COGMTVM false
		ObjectMemory Spur64BitCoMemoryManager
		MULTIPLEBYTECODESETS true
		bytecodeTableInitializer initializeBytecodeTableForSqueakV3PlusClosuresSistaV1Hybrid
	).
	cogMethod third inspect
]

{ #category : #'test-help' }
VMMakerDebuggingExamples class >> sampleMethod [
	^ 1 + 2
]

{ #category : #'see class side' }
VMMakerDebuggingExamples >> seeClassSide [
]
