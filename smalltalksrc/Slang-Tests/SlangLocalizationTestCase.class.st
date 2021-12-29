Class {
	#name : #SlangLocalizationTestCase,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #running }
SlangLocalizationTestCase >> applyLocalizationTo: interpreterSelector [

	| interpretMethod autolocalizedVariables |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	autolocalizedVariables := ccg initAutoLocalizationOfVariablesIn:
		                          interpreterSelector.
	ccg inlineDispatchesInMethodNamed: interpreterSelector.
	ccg doBasicInlining: true.
	ccg
		autoLocalizationOfVariablesIn: interpreterSelector
		withVariableBindings: autolocalizedVariables.
	interpretMethod := ccg methodNamed: interpreterSelector.
	ccg currentMethod: interpretMethod.
	^ interpretMethod
]

{ #category : #running }
SlangLocalizationTestCase >> applyLocalizationToInterpretWith: initializationSelector [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	MockLocalizationInterpreterMock perform: initializationSelector.
	^ self applyLocalizationTo: #interpret
]

{ #category : #running }
SlangLocalizationTestCase >> applyManyLocalizationsToInterpretWith: initializationSelector [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	MockLocalizationInterpreterMock perform: initializationSelector.
	^ self applyLocalizationTo: #interpretWithSeveralVariablesToLocalize
]

{ #category : #running }
SlangLocalizationTestCase >> externalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: aVariableName
			expression: (TVariableNode named: #local_, aVariableName))
]

{ #category : #running }
SlangLocalizationTestCase >> internalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: #local_, aVariableName
			expression: (TVariableNode named: aVariableName))
]

{ #category : #running }
SlangLocalizationTestCase >> setUp [

	super setUp.
	MockLocalizationInterpreterMock initialize.
]

{ #category : #'tests - initialization' }
SlangLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariable [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpret.

	self assert: ((ccg methodNamed: #interpret) locals includes: #local_autoLocalizedVariable)
]

{ #category : #'tests - initialization' }
SlangLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariableWhenNameConflict [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpretWithLocalizedVariableConflict.
	self assert: ((ccg methodNamed: #interpretWithLocalizedVariableConflict) locals includes: #local_autoLocalizedVariable1)
]

{ #category : #'tests - initialization' }
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

	| externalizationStatement interpretMethod |
	interpretMethod := self applyLocalizationTo: #interpret.
	externalizationStatement := (interpretMethod statements last: 2) first.

	self assert: (externalizationStatement isSameAs:
			 (self externalizationOf: #autoLocalizedVariable))
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturnReferenchingAutoLocalizedVariable [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod printedString |
	interpretMethod := self applyLocalizationTo: #interpretWithReturnExpressionUpdatingAutoLocalizedVariable.
	printedString := String streamContents: [ :str | 
		                 ((TStatementListNode statements: (interpretMethod statements last: 3)) asCASTIn: ccg) 
			                 prettyPrintOn: str ].
	self assert: printedString equals: '{
	autoLocalizedVariable = local_autoLocalizedVariable;
	autoLocalizedVariable1 = local_autoLocalizedVariable1;
	return (autoLocalizedVariable += 1);
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturns [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod sendNode |
	interpretMethod := self applyLocalizationTo: #interpretWithReturnExpression.

	sendNode := interpretMethod statements fourth.
	self assert: sendNode arguments first statements last isReturn.
	self
		assert: (sendNode arguments first statements first
		isSameAs: (self externalizationOf: #autoLocalizedVariable)).

	self assert: sendNode arguments second statements last isReturn.
	self
		assert: (sendNode arguments second statements first
		isSameAs: (self externalizationOf: #autoLocalizedVariable)).
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableInternalizesAtTheBeginning [

	| internalizationStatement interpretMethod |
	interpretMethod := self applyLocalizationTo: #interpret.

	internalizationStatement := interpretMethod statements first.

	self
		assert: (internalizationStatement isSameAs: (self internalizationOf: #autoLocalizedVariable))
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableReplacesByLocalOnInline [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| interpretMethod variableNode case |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithAutoLocalizedVariableOnly.
	
	"Fail if we find some node inside the case that uses the localized variable"
	case := interpretMethod statements second cases first.
	variableNode := case statements second method statements first variable.

	self assert: (variableNode isVariable and: [ variableNode name = #local_autoLocalizedVariable ]).
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgument [
	
	| interpretMethod case cast printedString inlinedMethod |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithEscapingCallAsArgument.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	cast := inlinedMethod parseTree asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals:
'{
	autoLocalizedVariable = local_autoLocalizedVariable;
	t0 = foo2();
	local_autoLocalizedVariable = autoLocalizedVariable;
	if (1 == t0) {
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgumentOfExternalCall [
	
	| interpretMethod case externalCall cast printedString inlinedMethod |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithEscapingCallAsArgumentOfExternalCall.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	cast := inlinedMethod asCASTIn: ccg.	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '/* MockLocalizationInterpreterMock>>#bytecodeWithEscapingCallAsArgumentOfExternalCall */
static sqInt
bytecodeWithEscapingCallAsArgumentOfExternalCall(void)
{
	{
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		t0 = nonInlinedMethodUsingAutolocalizedVariable1();
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		autoLocalizedVariable2 = local_autoLocalizedVariable2;
		t1 = foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
		local_autoLocalizedVariable2 = autoLocalizedVariable2;
	}
	return 0;
}
'.
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeInInlinedMethod [
	
	| interpretMethod case inlinedMethod cast printedString |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithInlinedMethodCall.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	cast := inlinedMethod asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '/* MockLocalizationInterpreterMock>>#bytecodeUsingInlinedCall */
static sqInt
bytecodeUsingInlinedCall(void)
{
	{
		/* begin inlinedMethodUsingExternalCall */
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		t0 = foo2();
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
	}
	return 0;
}
'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod cast printedString |

	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	cast := inlinedMethod asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '/* MockLocalizationInterpreterMock>>#bytecodeWithEscapingCall */
static sqInt
bytecodeWithEscapingCall(void)
{
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		t0 = foo((local_autoLocalizedVariable += 1));
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
	return 0;
}
'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeExternalizeAndInternalizeOnlyNeededVariables [
	
	| interpretMethod case inlinedMethod externalCall cast printedString |

	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.
	cast := inlinedMethod asCASTIn: ccg.

	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	self assert: printedString equals: '/* MockLocalizationInterpreterMock>>#bytecodeWithEscapingCall */
static sqInt
bytecodeWithEscapingCall(void)
{
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		autoLocalizedVariable2 = local_autoLocalizedVariable2;
		t0 = foo((local_autoLocalizedVariable += 1));
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
		local_autoLocalizedVariable2 = autoLocalizedVariable2;
	}
	return 0;
}
'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod case inlinedMethod cast printedString |
	interpretMethod := self
		applyLocalizationToInterpretWith: #initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements second cases first.
	inlinedMethod := case statements second method.

	cast := inlinedMethod asCASTIn: ccg.
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '/* MockLocalizationInterpreterMock>>#bytecodeUsingExternalizedAutoLocalizedVariableAsExpression */
static sqInt
bytecodeUsingExternalizedAutoLocalizedVariableAsExpression(void)
{
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		t0 = nonInlinedMethodUsingAutolocalizedVariable();
		local_autoLocalizedVariable = autoLocalizedVariable;
		autoLocalizedVariable = local_autoLocalizedVariable;
		t1 = foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
	return 0;
}
'
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeCallsInNestedLexicalScope [

	| methodToLinearize ifBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableInNestedLexicalScope.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		true ifTrue: [
			self foo: self nonInlinedMethodUsingAutolocalizedVariable
		]
	After
		true ifTrue: [
			| t0 t1 |
			t0 := self nonInlinedMethodUsingAutolocalizedVariable.
			t1 := self foo: t0
		] "

	ifBlock := methodToLinearize statements first arguments first.
	
	self assert: (ifBlock statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (ifBlock statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' })))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCalls [

	| methodToLinearize |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpression.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0"

	self assert: (methodToLinearize statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (methodToLinearize statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' })))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCallsDefinesIntermediateVariables [

	| methodToLinearize |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInAssignment.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0
		
		=> both t0 and t1 should be defined in the method"
	
	self assert: (methodToLinearize locals includes: 't0').
	self assert: (methodToLinearize locals includes: 't1')

]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCallsWithAssignment [

	| methodToLinearize |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInAssignment.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		foo := self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		foo := t1"
		
	self assert: (methodToLinearize statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (methodToLinearize statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' }))).
	self assert: (methodToLinearize statements third
			isSameAs: (TAssignmentNode
				variableNamed: 'foo'
				expression: (TVariableNode named: 't1')))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCallsWithReturn [

	| methodToLinearize |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInReturn.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		^ self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		^ t1"
		
	self assert: (methodToLinearize statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (methodToLinearize statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' }))).
	self assert: (methodToLinearize statements third
			isSameAs: (TReturnNode expression: (TVariableNode named: 't1')))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeSingleCalls [

	| methodToLinearize |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingInlinedCall.
	
	ccg prepareMethods.
	ccg linearizeExternalCallsIn: methodToLinearize.

	"Before it was 
		self inlinedMethodUsingExternalCall.
	After
		t0 := self inlinedMethodUsingExternalCall"

	self assert: (methodToLinearize statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #inlinedMethodUsingExternalCall)))
]

{ #category : #'tests - old localization' }
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

{ #category : #'tests - old localization' }
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

{ #category : #'tests - old localization' }
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
	
	| interpretMethod case inlinedMethod externalCall cast printedString |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithSafeEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	case := interpretMethod statements sixth cases first.
	inlinedMethod := case statements second method.

	externalCall := inlinedMethod statements first.
	cast := externalCall asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: 't0 = nonInlinedMethodNotUsingAutolocalizedVariables((local_autoLocalizedVariable += 1))'
]
