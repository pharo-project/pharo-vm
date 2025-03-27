Class {
	#name : 'SLLocalizationTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'instance-variables' }
SLLocalizationTest >> testGlobalLocalized [

	| tMethod |
	tMethod := ccg methodNamed: #methodWithInstanceVariableToLocalize.

	self assert: (ccg globalsAsSet includes: #instanceVariableToLocalize).
	self assert:
		(tMethod locals includes: #instanceVariableToLocalize) not.

	ccg
		checkForGlobalUsage: (tMethod allReferencedVariablesUsing: ccg)
		in: tMethod.
	ccg localizeGlobalVariables.

	self assert:
		(ccg globalsAsSet includes: #instanceVariableToLocalize) not.
	self assert: (tMethod locals includes: #instanceVariableToLocalize)
]

{ #category : 'instance-variables' }
SLLocalizationTest >> testGlobalMustBeGlobalEvenWithNoUsage [

	ccg localizeGlobalVariables.

	self assert: ccg globalsAsSet size equals: 2.
	self assert: (ccg globalsAsSet includes: #globalMustBeGlobal).
	self assert:
		(ccg globalsAsSet includes: #instanceVariableMustBeGlobal)
]
