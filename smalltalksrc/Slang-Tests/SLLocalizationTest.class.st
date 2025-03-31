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
SLLocalizationTest >> testGlobalMustBeGlobaWithMultipleUsage [

	| tMethod1 tMethod2 |
	tMethod1 := ccg methodNamed: #methodWithInstanceVariableMustBeGlobal.
	tMethod2 := ccg methodNamed:
		            #methodWithInstanceVariableMustBeGlobalBis.

	ccg
		checkForGlobalUsage: (tMethod1 allReferencedVariablesUsing: ccg)
		in: tMethod1.
	ccg
		checkForGlobalUsage: (tMethod2 allReferencedVariablesUsing: ccg)
		in: tMethod2.

	ccg localizeGlobalVariables.

	self assert: ccg globalsAsSet size equals: 3.
	self assert: (ccg globalsAsSet includes: #globalMustBeGlobal).
	self assert:
		(ccg globalsAsSet includes: #instanceVariableMustBeGlobal).
	self assert: (ccg globalsAsSet includes: #instanceVariableWithUsage)
]

{ #category : 'instance-variables' }
SLLocalizationTest >> testGlobalMustBeGlobalEvenIfOnlyOneUsage [

	| tMethod |
	tMethod := ccg methodNamed: #methodWithInstanceVariableMustBeGlobal.

	ccg
		checkForGlobalUsage: (tMethod allReferencedVariablesUsing: ccg)
		in: tMethod.

	ccg localizeGlobalVariables.

	self assert: ccg globalsAsSet size equals: 2.
	self assert: (ccg globalsAsSet includes: #globalMustBeGlobal).
	self assert:
		(ccg globalsAsSet includes: #instanceVariableMustBeGlobal)
]

{ #category : 'instance-variables' }
SLLocalizationTest >> testGlobalMustBeGlobalEvenWithNoUsage [

	ccg localizeGlobalVariables.

	self assert: ccg globalsAsSet size equals: 2.
	self assert: (ccg globalsAsSet includes: #globalMustBeGlobal).
	self assert:
		(ccg globalsAsSet includes: #instanceVariableMustBeGlobal)
]
