Class {
	#name : #SlangLocalizationTestCase,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #tests }
SlangLocalizationTestCase >> externalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: aVariableName
			expression: (TVariableNode named: #local_, aVariableName))
]

{ #category : #tests }
SlangLocalizationTestCase >> internalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: #local_, aVariableName
			expression: (TVariableNode named: aVariableName))
]

{ #category : #tests }
SlangLocalizationTestCase >> setUp [

	super setUp.
	MockLocalizationInterpreterMock initialize.
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariable [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.

	self assert: ((ccg methodNamed: #interpret) locals includes: #local_autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesAtTheEnd [

	| internalizationStatement |

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.

	internalizationStatement := (ccg methodNamed: #interpret) statements last.

	self
		assert: internalizationStatement
		equals: (self externalizationOf: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableInternalizesAtTheBeginning [

	| internalizationStatement |
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.

	internalizationStatement := (ccg methodNamed: #interpret) statements first.

	self
		assert: internalizationStatement
		equals: (self internalizationOf: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableReplacesByLocalOnInline [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| interpretMethod variableNode case |
	MockLocalizationInterpreterMock initializeWithAutoLocalizedVariableOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Fail if we find some node inside the case that uses the localized variable"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	variableNode := case statements second method statements first variable.

	self assert: (variableNode isVariable and: [ variableNode name = #local_autoLocalizedVariable ]).
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableWrapsSendsWithExternalSendNodes [
	
	| interpretMethod case inlinedMethod |
	MockLocalizationInterpreterMock initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	self assert: inlinedMethod statements first isExternalSend
]

{ #category : #tests }
SlangLocalizationTestCase >> testLocalizeSharedVariableShouldFail [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.

	[ ccg localizeVariables: #( sharedVariableToLocalize ) inMethod: (ccg methodNamed: #interpret).
		
		"This should not arrive here"
		self fail
		] on: Error do: [ :error |
		self assert: error messageText equals: 'Cannot localize Shared Variables in the interpreter loop: sharedVariableToLocalize' ].
]

{ #category : #tests }
SlangLocalizationTestCase >> testLocalizeSharedVariableShouldFailIfAllInlinedUsesAreNotInlined [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg retainMethods: #( interpret ).
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.
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
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg retainMethods: #( interpret ).
	ccg prepareMethods.
	ccg doBasicInlining: true.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg pruneUnreachableMethods.
	
	"This should not fail"
	ccg localizeVariables: #( sharedVariableToLocalizeBeforeInlining ) inMethod: (ccg methodNamed: #interpret)
]
