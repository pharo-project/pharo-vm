Class {
	#name : 'CogStackToRegisterCompilationState',
	#superclass : 'VMStructType',
	#instVars : [
		'deadCode',
		'methodOrBlockNumTemps',
		'prevBCDescriptor',
		'regArgsHaveBeenPushed',
		'useTwoPaths',
		'simStackStateField'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'translation' }
CogStackToRegisterCompilationState class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"Enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeFixup struct."

	"self withAllSubclasses collect: [:ea| self typedef]"

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn first ~= $# ifTrue: [
				 ivn caseOf: {
						 ([ 'deadCode' ] -> [ #sqInt ]).
						 ([ 'methodOrBlockNumTemps' ] -> [ #sqInt ]).
						 ([ 'prevBCDescriptor' ] -> [ #'BytecodeDescriptor *' ]).
						 ([ 'regArgsHaveBeenPushed' ] -> [ #sqInt ]).
						 ([ 'simStackStateField' ] -> [ #CogCompileTimeStackState ]).
						 ([ 'useTwoPaths' ] -> [ #sqInt ]) } ]) ]
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> deadCode [

	^ deadCode
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> deadCode: anObject [

	deadCode := anObject
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> methodOrBlockNumTemps [

	^ methodOrBlockNumTemps
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> methodOrBlockNumTemps: anObject [

	methodOrBlockNumTemps := anObject
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> prevBCDescriptor [

	^ prevBCDescriptor
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> prevBCDescriptor: anObject [

	prevBCDescriptor := anObject
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> regArgsHaveBeenPushed [

	^ regArgsHaveBeenPushed
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> regArgsHaveBeenPushed: anObject [

	regArgsHaveBeenPushed := anObject
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> simStackState [

	^ self addressOf: self simStackStateField
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> simStackStateField [

	^ simStackStateField
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> simStackStateField: anObject [

	simStackStateField := anObject
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> useTwoPaths [

	^ useTwoPaths
]

{ #category : 'accessing' }
CogStackToRegisterCompilationState >> useTwoPaths: anObject [

	useTwoPaths := anObject
]
