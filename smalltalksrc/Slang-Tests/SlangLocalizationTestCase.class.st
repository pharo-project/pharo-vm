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
	ccg initAutoLocalizationOfVariablesIn: #interpret.

	self assert: ((ccg methodNamed: #interpret) locals includes: #local_autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariableWhenNameConflict [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpretWithLocalizedVariableConflict.
	self assert: ((ccg methodNamed: #interpretWithLocalizedVariableConflict) locals includes: #local_autoLocalizedVariable1)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariables [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| method |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	method := (ccg methodNamed: #interpretWithSeveralVariablesToLocalize).
	self assert: ( method locals includes: #local_autoLocalizedVariable1).
	self assert: (method locals includes: #local_autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesAtTheEnd [

	| externalizationStatement autolocalizedVariables |

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.

	externalizationStatement := (ccg methodNamed: #interpret) statements last statements first.

	self
		assert: externalizationStatement
		equals: (self externalizationOf: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturnReferenchingAutoLocalizedVariable [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod printedString autolocalizedVariables |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithReturnExpressionUpdatingAutoLocalizedVariable.
	ccg inlineDispatchesInMethodNamed:
		#interpretWithReturnExpressionUpdatingAutoLocalizedVariable.
		ccg autoLocalizationOfVariablesIn: #interpretWithReturnExpressionUpdatingAutoLocalizedVariable withVariableBindings: autolocalizedVariables.
	interpretMethod := ccg methodNamed:
		                   #interpretWithReturnExpressionUpdatingAutoLocalizedVariable.
	ccg currentMethod: interpretMethod.
	printedString := String streamContents: [ :str | 
		                 (interpretMethod statements last asCASTIn: ccg) 
			                 prettyPrintOn: str ].

	self assert: printedString equals: '{
	autoLocalizedVariable1 = local_autoLocalizedVariable1;
	autoLocalizedVariable = local_autoLocalizedVariable;
	return (autoLocalizedVariable += 1);
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturns [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod autolocalizedVariables |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithReturnExpression.
	ccg inlineDispatchesInMethodNamed: #interpretWithReturnExpression.
	ccg autoLocalizationOfVariablesIn: #interpretWithReturnExpression withVariableBindings: autolocalizedVariables. 
	interpretMethod := ccg methodNamed: #interpretWithReturnExpression.
	self assert:
		interpretMethod statements last arguments first statements last statements last
			isReturn.
	self
		assert:
		interpretMethod statements last arguments first statements last statements first
		equals: (self externalizationOf: #autoLocalizedVariable).
	self assert:
		interpretMethod statements last arguments second statements first statements last
			isReturn.
	self
		assert:
		interpretMethod statements last arguments second statements first statements first
		equals: (self externalizationOf: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableInternalizesAtTheBeginning [

	| internalizationStatement autolocalizedVariables |
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.
	internalizationStatement := (ccg methodNamed: #interpret) statements first.

	self
		assert: (internalizationStatement isSameAs: (self internalizationOf: #autoLocalizedVariable))
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableReplacesByLocalOnInline [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| interpretMethod variableNode case autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithAutoLocalizedVariableOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.

	"Fail if we find some node inside the case that uses the localized variable"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	variableNode := case statements second method statements first variable.

	self assert: (variableNode isVariable and: [ variableNode name = #local_autoLocalizedVariable ]).
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableWrapsSendsWithExternalSendNodes [
	
	| interpretMethod case inlinedMethod autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	self assert: inlinedMethod statements first isExternalSend
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgument [
	
	| interpretMethod case externalCall cast printedString autolocalizedVariables inlinedMethod |
	MockLocalizationInterpreterMock initializeWithEscapingCallAsArgument.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg doBasicInlining: true.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: 'autoLocalizedVariable = local_autoLocalizedVariable;
arg = foo2();
local_autoLocalizedVariable = autoLocalizedVariable;
if (1 == r) {
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgumentOfExternalCall [
	
	| interpretMethod case externalCall cast printedString autolocalizedVariables inlinedMethod |
	MockLocalizationInterpreterMock initializeWithEscapingCallAsArgumentOfExternalCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	ccg inlineDispatchesInMethodNamed: #interpretWithSeveralVariablesToLocalize.
	ccg doBasicInlining: true.
	ccg autoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpretWithSeveralVariablesToLocalize.
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	autoLocalizedVariable1 = local_autoLocalizedVariable1;
	autoLocalizedVariable = local_autoLocalizedVariable;
	autoLocalizedVariable2 = local_autoLocalizedVariable2;
	foo(nonInlinedMethodUsingAutolocalizedVariable1());
	local_autoLocalizedVariable1 = autoLocalizedVariable1;
	local_autoLocalizedVariable = autoLocalizedVariable;
	local_autoLocalizedVariable2 = autoLocalizedVariable2;
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeInInlinedMethod [
	
	| interpretMethod case inlinedMethod externalCall cast printedString autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithInlinedMethodCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	ccg inlineDispatchesInMethodNamed: #interpretWithSeveralVariablesToLocalize.
	ccg doBasicInlining: true.
	ccg autoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpretWithSeveralVariablesToLocalize.
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements second.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	autoLocalizedVariable1 = local_autoLocalizedVariable1;
	autoLocalizedVariable = local_autoLocalizedVariable;
	foo2();
	local_autoLocalizedVariable1 = autoLocalizedVariable1;
	local_autoLocalizedVariable = autoLocalizedVariable;
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod externalCall cast printedString autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	autoLocalizedVariable = local_autoLocalizedVariable;
	foo((autoLocalizedVariable += 1));
	local_autoLocalizedVariable = autoLocalizedVariable;
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalizationOutOfDispatch [
	
	| interpretMethod autolocalizedVariables |
	MockLocalizationInterpreterMock.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithExternalCallBeforeDispatch.
	ccg inlineDispatchesInMethodNamed: #interpretWithExternalCallBeforeDispatch.
	ccg autoLocalizationOfVariablesIn: #interpretWithExternalCallBeforeDispatch withVariableBindings: autolocalizedVariables.

	self assert: externalCall wrappedSendNode arguments first equals: argumentStatement variable.
	self
		assert: (argumentStatement expression isSameAs: (TAssignmentNode
			variableNamed: 'local_autoLocalizedVariable'
			expression:(TSendNode
				receiver: (TVariableNode named: 'local_autoLocalizedVariable')
				selector: #+
				arguments: { TConstantNode value: 1 } )))
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeExternalizeAndInternalizeOnlyNeededVariables [
	
	| interpretMethod case inlinedMethod externalCall cast printedString autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	ccg inlineDispatchesInMethodNamed: #interpretWithSeveralVariablesToLocalize.
	ccg autoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpretWithSeveralVariablesToLocalize.
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	autoLocalizedVariable1 = local_autoLocalizedVariable1;
	autoLocalizedVariable = local_autoLocalizedVariable;
	autoLocalizedVariable2 = local_autoLocalizedVariable2;
	foo((autoLocalizedVariable += 1));
	local_autoLocalizedVariable1 = autoLocalizedVariable1;
	local_autoLocalizedVariable = autoLocalizedVariable;
	local_autoLocalizedVariable2 = autoLocalizedVariable2;
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeKnowsVariablesToExternalizeAndInternalize [
	
	| interpretMethod case inlinedMethod autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	self assert: (inlinedMethod statements first localizedVariables includes: #autoLocalizedVariable)
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod externalCall cast printedString autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpret.
	ccg inlineDispatchesInMethodNamed: #interpret.
	ccg doBasicInlining: true.
	ccg autoLocalizationOfVariablesIn: #interpret withVariableBindings: autolocalizedVariables.



	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpret.
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	autoLocalizedVariable = local_autoLocalizedVariable;
	foo(nonInlinedMethodUsingAutolocalizedVariable());
	local_autoLocalizedVariable = autoLocalizedVariable;
}'
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

{ #category : #tests }
SlangLocalizationTestCase >> testNoExternalSendNodeOnSafeExternalCall [
	
	| interpretMethod case inlinedMethod externalCall cast printedString autolocalizedVariables |
	MockLocalizationInterpreterMock initializeWithSafeEscapingCall.
	ccg addClass: MockLocalizationInterpreterMock.
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	ccg inlineDispatchesInMethodNamed: #interpretWithSeveralVariablesToLocalize.
	ccg autoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize withVariableBindings: autolocalizedVariables.


	"Assert that the send node is preceded by variable externalization"
	interpretMethod := ccg methodNamed: #interpretWithSeveralVariablesToLocalize.
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: 'nonInlinedMethodNotUsingAutolocalizedVariables((local_autoLocalizedVariable += 1))'
]
