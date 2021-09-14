Class {
	#name : #MockLocalizationInterpreterMock,
	#superclass : #AbstractInterpreter,
	#instVars : [
		'variableToLocalize',
		'sharedVariableToLocalize',
		'sharedVariableToLocalizeBeforeInlining',
		'autoLocalizedVariable'
	],
	#classVars : [
		'BytecodeTable'
	],
	#category : #'Slang-Tests'
}

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initialize [

	BytecodeTable := Array new: 5.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeToInline)
	(  1  bytecodeUsingLocalizedVariable)
	(  2  bytecodeUsingSharedLocalizedVariable)
	(  3  bytecodeUsingSharedLocalizedVariableBeforeInlining)
	(  4  bytecodeUsingAutoLocalizedVariable)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithAutoLocalizedVariableOnly [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingAutoLocalizedVariable)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithExternalizedAutoLocalizedVariableOnly [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingExternalizedAutoLocalizedVariable)
	)
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeToInline [

	"Do nothing"
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingAutoLocalizedVariable [

	autoLocalizedVariable := 17
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariable [

	autoLocalizedVariable := 17.
	self nonInlinedMethodUsingAutolocalizedVariable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingLocalizedVariable [

	variableToLocalize := 42
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingSharedLocalizedVariable [

	sharedVariableToLocalize := 42
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingSharedLocalizedVariableBeforeInlining [

	sharedVariableToLocalizeBeforeInlining := 42.
	self methodAlsoSharedLocalizedVariableBeforeInlining
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> interpret [
	<localizedVariable: #autoLocalizedVariable>

	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> methodAlsoSharedLocalizedVariableBeforeInlining [

	sharedVariableToLocalizeBeforeInlining := 17
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonBytecodeUsingSharedLocalizedVariable [

	sharedVariableToLocalize := 17
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonInlinedMethodUsingAutolocalizedVariable [

	<inline:false>
	^ autoLocalizedVariable
]
