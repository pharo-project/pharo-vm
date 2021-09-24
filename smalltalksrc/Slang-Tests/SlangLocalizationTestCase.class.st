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

	self assert: inlinedMethod statements first statements last isExternalSend
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod externalCall cast printedString |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	arg1 = (local_autoLocalizedVariable += 1);
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo(arg1);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeKnowsVariablesToExternalizeAndInternalize [
	
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

	self assert: (inlinedMethod statements first statements last localizedVariables includes: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod externalCall cast printedString |
	MockLocalizationInterpreterMock initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	arg1 = nonInlinedMethodUsingAutolocalizedVariable();
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo(arg1);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testLinearizationOfExternalCalls [
	
	| interpretMethod case inlinedMethod externalCall argumentStatement replacementBlock |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	replacementBlock := inlinedMethod statements first.
	argumentStatement := replacementBlock statements first.
	externalCall := replacementBlock statements second.

	self assert: externalCall wrappedSendNode arguments first equals: argumentStatement variable.
	self
		assert: argumentStatement expression
		equals: (TAssignmentNode
			variableNamed: 'local_autoLocalizedVariable'
			expression:(TSendNode
				receiver: (TVariableNode named: 'local_autoLocalizedVariable')
				selector: #+
				arguments: { TConstantNode value: 1 } ))
]

{ #category : #tests }
SlangLocalizationTestCase >> testLinearizationShouldBeTranslatedWithExternalizationAndInternalizations [
	
	| interpretMethod case inlinedMethod externalCall cast printedString |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	arg1 = (local_autoLocalizedVariable += 1);
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo(arg1);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testLinearizationShouldDeclareArgumentVariables [
	
	| interpretMethod case inlinedMethod |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpret.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	self assert: (interpretMethod locals includes: 'arg1')
]

{ #category : #tests }
SlangLocalizationTestCase >> testLinearizationShouldRenameArgumentVariablesWhenConflicts [
	
	| interpretMethod case inlinedMethod |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: #interpretWithConflict.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpretWithConflict.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	"Conflicts are resolved by automatically renaming the conflicting definitions with a suffix underscore"
	self assert: (interpretMethod locals includes: 'arg1_')
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
	
	self assert: (ccg methodNamed: #methodAlsoSharedLocalizedVariableBeforeInlining) notNil.

	"This should not fail"
	[
	ccg localizeVariables: #( sharedVariableToLocalizeBeforeInlining ) inMethod: (ccg methodNamed: #interpret).
		
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
