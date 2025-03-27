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
	"Even if the variable can be localized or have no sender in Slang, it should remain a global.
	Happens because some cases are undetected by Slang.
	See the 'sendTrace' case and 'generatorTable' cases (only use in macros) or 'aMethodLabel' (only use to set up other globals)"

	instanceVariableMustBeGlobal.
	instanceVariableWithUsage
]

{ #category : 'instance-variables' }
SLLocalizationTestClass >> methodWithInstanceVariableMustBeGlobalBis [
	"Even if the variable can be localized or have no sender in Slang, it should remain a global.
	Happens because some cases are undetected by Slang.
	See the 'sendTrace' case and 'generatorTable' cases (only use in macros) or 'aMethodLabel' (only use to set up other globals)"

	instanceVariableMustBeGlobal.
	instanceVariableWithUsage
]

{ #category : 'instance-variables' }
SLLocalizationTestClass >> methodWithInstanceVariableToLocalize [
	"Only user of instanceVariableToLocalize the definition should be localize to this method"

	instanceVariableToLocalize.
	instanceVariableWithUsage
]
