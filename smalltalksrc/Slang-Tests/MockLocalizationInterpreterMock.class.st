Class {
	#name : #MockLocalizationInterpreterMock,
	#superclass : #AbstractInterpreter,
	#instVars : [
		'variableToLocalize',
		'sharedVariableToLocalize',
		'sharedVariableToLocalizeBeforeInlining'
	],
	#classVars : [
		'BytecodeTable'
	],
	#category : #'Slang-Tests'
}

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initialize [

	BytecodeTable := Array new: 4.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeToInline)
	(  1  bytecodeUsingLocalizedVariable)
	(  2  bytecodeUsingSharedLocalizedVariable)
	(  3  bytecodeUsingSharedLocalizedVariableBeforeInlining)
	)
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeToInline [

	"Do nothing"
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
