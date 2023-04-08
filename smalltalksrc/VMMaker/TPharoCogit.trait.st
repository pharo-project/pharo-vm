Trait {
	#name : #TPharoCogit,
	#instVars : [
		'objectRepresentation',
		'ceCannotResumeTrampoline',
		'ceSendMustBeBooleanAddFalseTrampoline',
		'ceSendMustBeBooleanAddTrueTrampoline',
		'ceSendMustBeBooleanTrampoline',
		'ceFetchContextInstVarTrampoline',
		'ceStoreContextInstVarTrampoline'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #'profiling primitives' }
TPharoCogit >> classForInlineCacheTag: classIndex [

	^ self objectMemory classOrNilAtIndex: classIndex
]

{ #category : #'profiling primitives' }
TPharoCogit >> executePrimitiveGenerator: aPrimitiveGenerator [

	objectRepresentation perform: aPrimitiveGenerator
]

{ #category : #'compile abstract instructions' }
TPharoCogit >> genGetInlineCacheClassTagFrom: receiverRegister into: destinationRegister forEntry: isEntry [

	objectRepresentation
		genGetInlineCacheClassTagFrom: receiverRegister
		into: destinationRegister
		forEntry: isEntry
]

{ #category : #'bytecode generators' }
TPharoCogit >> genNewArrayOfSize: size initialized: initialized [
	
	<doNotGenerate>
	^ objectRepresentation genNewArrayOfSize: size initialized: initialized
]

{ #category : #initialization }
TPharoCogit >> generateObjectRepresentationTrampolines [

	<doNotGenerate>
	objectRepresentation generateObjectRepresentationTrampolines
]

{ #category : #'garbage collection' }
TPharoCogit >> markAndTraceCacheTagLiteral: aCacheTag in: aMethod atpc: mcpc [
	<doNotGenerate>
	objectRepresentation
		markAndTraceCacheTagLiteral: aCacheTag
		in: aMethod
		atpc: mcpc
]

{ #category : #initialization }
TPharoCogit >> maybeGenerateSelectorIndexDereferenceRoutine [

	objectRepresentation maybeGenerateSelectorIndexDereferenceRoutine
]

{ #category : #initialization }
TPharoCogit >> setInterpreter: anInterpreter [

	<doNotGenerate>
	super setInterpreter: anInterpreter.
	objectRepresentation := self objectRepresentationClass
		                        forCogit: self
		                        methodZone: self methodZone
]
