Class {
	#name : 'SLLocalizationTestClass',
	#superclass : 'SlangClass',
	#instVars : [
		'instanceVariableWithNoUsage',
		'instanceVariableWithUsage',
		'instanceVariableToLocalize',
		'instanceVariableMustBeGlobal'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'instance-variables' }
SLLocalizationTestClass >> methodWithInstanceVariableMustBeGlobal [
	"even if the variable can be localized or have no sender in Slang, it should remain a global.
	See the 'sendTrace' case or 'generatorTable' cases (only use in macros)"

	instanceVariableMustBeGlobal.
	instanceVariableWithUsage
]

{ #category : 'instance-variables' }
SLLocalizationTestClass >> methodWithInstanceVariableMustBeGlobalBis [
	"even if the variable can be localized or have no sender in Slang, it should remain a global.
	See the 'sendTrace' case or 'generatorTable' cases (only use in macros)"

	instanceVariableMustBeGlobal.
	instanceVariableWithUsage
]

{ #category : 'instance-variables' }
SLLocalizationTestClass >> methodWithInstanceVariableToLocalize [
	"Only user of instanceVariableToLocalize the definition should be localize to this method"

	instanceVariableToLocalize.
	instanceVariableWithUsage
]
