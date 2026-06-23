Class {
	#name : 'CogCompileTimeState',
	#superclass : 'VMStructType',
	#instVars : [
		'deadCode',
		'methodOrBlockNumTemps',
		'prevBCDescriptor',
		'regArgsHaveBeenPushed',
		'simStackState',
		'useTwoPaths'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'translation' }
CogCompileTimeState class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"Enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeFixup struct."

	"self withAllSubclasses collect: [:ea| self typedef]"

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn first ~= $# ifTrue: [
				 ivn caseOf: {
						 ([ 'deadCode' ] -> [ #sqInt ]).
						 ([ 'methodOrBlockNumTemps' ] -> [ #sqInt ]).
						 ([ 'prevBCDescriptor' ] -> [ #'BytecodeDescriptor *' ]).
						 ([ 'regArgsHaveBeenPushed' ] -> [ #sqInt ]).
						 ([ 'simStackState' ] -> [ #CogCompileTimeStackState ]).
						 ([ 'useTwoPaths' ] -> [ #sqInt ]) } ]) ]
]

{ #category : 'accessing' }
CogCompileTimeState >> deadCode [

	^ deadCode
]

{ #category : 'accessing' }
CogCompileTimeState >> deadCode: anObject [

	deadCode := anObject
]

{ #category : 'accessing' }
CogCompileTimeState >> methodOrBlockNumTemps [

	^ methodOrBlockNumTemps
]

{ #category : 'accessing' }
CogCompileTimeState >> methodOrBlockNumTemps: anObject [

	methodOrBlockNumTemps := anObject
]

{ #category : 'accessing' }
CogCompileTimeState >> prevBCDescriptor [

	^ prevBCDescriptor
]

{ #category : 'accessing' }
CogCompileTimeState >> prevBCDescriptor: anObject [

	prevBCDescriptor := anObject
]

{ #category : 'accessing' }
CogCompileTimeState >> regArgsHaveBeenPushed [

	^ regArgsHaveBeenPushed
]

{ #category : 'accessing' }
CogCompileTimeState >> regArgsHaveBeenPushed: anObject [

	regArgsHaveBeenPushed := anObject
]

{ #category : 'accessing' }
CogCompileTimeState >> simStackState [

	^ simStackState
]

{ #category : 'accessing' }
CogCompileTimeState >> simStackState: anObject [

	simStackState := anObject
]

{ #category : 'accessing' }
CogCompileTimeState >> useTwoPaths [

	^ useTwoPaths
]

{ #category : 'accessing' }
CogCompileTimeState >> useTwoPaths: anObject [

	useTwoPaths := anObject
]
