Class {
	#name : #MockLocalizationInterpreterMock,
	#superclass : #AbstractInterpreter,
	#instVars : [
		'variableToLocalize',
		'sharedVariableToLocalize'
	],
	#classVars : [
		'BytecodeTable'
	],
	#category : #'Slang-Tests'
}

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initialize [

	BytecodeTable := Array new: 3.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeToInline)
	(  1  bytecodeUsingLocalizedVariable)
	(  2  bytecodeUsingSharedLocalizedVariable)
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
MockLocalizationInterpreterMock >> interpret [

	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonBytecodeUsingSharedLocalizedVariable [

	sharedVariableToLocalize := 17
]
