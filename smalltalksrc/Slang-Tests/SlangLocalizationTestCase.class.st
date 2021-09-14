Class {
	#name : #SlangLocalizationTestCase,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #tests }
SlangLocalizationTestCase >> testLocalizeSharedVariableShouldFail [

	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.

	[ ccg localizeVariables: #( sharedVariableToLocalize ) inMethod: (ccg methodNamed: #interpret).
		
		"This should not arrive here"
		self fail
		] on: Error do: [ :error |
		self assert: error messageText equals: 'Cannot localize Shared Variables in the interpreter loop: sharedVariableToLocalize' ].
]

{ #category : #tests }
SlangLocalizationTestCase >> testLocalizeSharedVariableShouldFailIfAllInlinedUsesAreNotInlined [

	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg retainMethods: #( interpret ).
	ccg prepareMethods.
	ccg pruneUnreachableMethods.

	"This should not fail"
	[ ccg localizeVariables: #( sharedVariableToLocalizeBeforeInlining ) inMethod: (ccg methodNamed: #interpret).
		
		"This should not arrive here"
		self fail
		] on: Error do: [ :error |
		self assert: error messageText equals: 'Cannot localize Shared Variables in the interpreter loop: sharedVariableToLocalizeBeforeInlining' ]
]

{ #category : #tests }
SlangLocalizationTestCase >> testLocalizeSharedVariableShouldNotFailIfAllUsesAreInlined [

	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg retainMethods: #( interpret ).
	ccg prepareMethods.
	ccg doBasicInlining: true.
	ccg pruneUnreachableMethods.
	
	"This should not fail"
	ccg localizeVariables: #( sharedVariableToLocalizeBeforeInlining ) inMethod: (ccg methodNamed: #interpret)
]
