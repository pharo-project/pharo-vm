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

{ #category : #helpers }
SlangLocalizationTestCase >> linearizedBlockOfCaseMethod: aTMethod [ 

	| case inlinedMethod |
	case := (aTMethod detect: [ :e | e isCaseStmt ]) cases first.
	inlinedMethod := (case detect: [ :e | e isInline ]) method.
	"Return the first non label, to avoid the labels introduced by inlining"
	^ inlinedMethod statements detect: [ :e | e isLabel not and: [ e isStatementList not or: [ e first isLabel not ]] ]
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
SlangLocalizationTestCase >> testAutoLocalizeVariableDoesNotLineariseUnnecessaryStatements [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod printedString block |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithoutAutoLocalizedVariable.
	block := self linearizedBlockOfCaseMethod: interpretMethod.

	printedString := String streamContents: [ :str | (block asCASTIn: ccg) prettyPrintOn: str ].

	self assert: printedString equals: 'nonInlinedMethodNotUsingAutolocalizedVariables(nonInlinedMethodNotUsingAutolocalizedVariables())'
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesAtTheEnd [

	| externalizationStatement interpretMethod |
	interpretMethod := self applyLocalizationTo: #interpret.
	externalizationStatement := interpretMethod statements last first first.

	self assert: (externalizationStatement isSameAs:
			 (self externalizationOf: #autoLocalizedVariable))
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturnReferenchingAutoLocalizedVariable [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod printedString |
	interpretMethod := self applyLocalizationTo: #interpretWithReturnExpressionUpdatingAutoLocalizedVariable.
	printedString := String streamContents: [ :str | 
		                 ((TStatementListNode statements: interpretMethod statements last) asCASTIn: ccg) 
			                 prettyPrintOn: str ].
	self assert: printedString equals: '{
	{
		sqInt t0;

		t0 = (local_autoLocalizedVariable += 1);
		{
			autoLocalizedVariable = local_autoLocalizedVariable;
			autoLocalizedVariable1 = local_autoLocalizedVariable1;
			return t0;
		}
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturns [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod sendNode |
	interpretMethod := self applyLocalizationTo: #interpretWithReturnExpression.

	sendNode := interpretMethod last first.
	self assert: sendNode arguments first first first last isReturn.
	self
		assert: (sendNode arguments first first first first
		isSameAs: (self externalizationOf: #autoLocalizedVariable)).

	self assert: sendNode arguments second first first last isReturn.
	self
		assert: (sendNode arguments second first first first
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
	case := (interpretMethod detect: [:e | e isCaseStmt ]) cases first.
	variableNode := (case detect: [ :e | e isAssignment ]) variable.

	self assert: (variableNode isVariable and: [ variableNode name = #local_autoLocalizedVariable ]).
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgument [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithEscapingCallAsArgument.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals:
'{
	sqInt t0;

	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		t0 = foo2();
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
	if (1 == t0) {
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingAsArgumentOfExternalCall [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithEscapingCallAsArgumentOfExternalCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.

	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	sqInt t0;

	{
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		t0 = nonInlinedMethodUsingAutolocalizedVariable1();
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
	}
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		autoLocalizedVariable2 = local_autoLocalizedVariable2;
		foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
		local_autoLocalizedVariable2 = autoLocalizedVariable2;
	}
}'.
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeInInlinedMethod [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithInlinedMethodCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		foo2();
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod cast printedString linearizedBlock |

	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.

	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	sqInt t0;

	t0 = (local_autoLocalizedVariable += 1);
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalPerform [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithPerform.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals:
'{
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo();
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeExternalizeAndInternalizeOnlyNeededVariables [
	
	| interpretMethod cast printedString linearizedBlock |

	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.

	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	self assert: printedString equals: '{
	sqInt t0;

	t0 = (local_autoLocalizedVariable += 1);
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		autoLocalizedVariable1 = local_autoLocalizedVariable1;
		autoLocalizedVariable2 = local_autoLocalizedVariable2;
		foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
		local_autoLocalizedVariable1 = autoLocalizedVariable1;
		local_autoLocalizedVariable2 = autoLocalizedVariable2;
	}
}'
]

{ #category : #tests }
SlangLocalizationTestCase >> testExternalSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self
		applyLocalizationToInterpretWith: #initializeWithExternalizedAutoLocalizedVariableInExpressionOnly.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	
	cast := linearizedBlock asCASTIn: ccg.
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: '{
	sqInt t0;

	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		t0 = nonInlinedMethodUsingAutolocalizedVariable();
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
	{
		autoLocalizedVariable = local_autoLocalizedVariable;
		foo(t0);
		local_autoLocalizedVariable = autoLocalizedVariable;
	}
}'
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeCallsInNestedLexicalScope [

	| methodToLinearize ifBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableInNestedLexicalScope.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	ccg
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	"Before it was 
		true ifTrue: [
			self foo: self nonInlinedMethodUsingAutolocalizedVariable
		]
	After
		true ifTrue: [
			| t0 |
			t0 := self nonInlinedMethodUsingAutolocalizedVariable.
			self foo: t0
		] "

	ifBlock := methodToLinearize statements first statements first arguments first statements first.
	
	self assert: (ifBlock statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (ifBlock statements second
			isSameAs: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' }))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCalls [

	| methodToLinearize replacementBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpression.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	ccg
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	"Before it was 
		self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		self foo: t0"

	replacementBlock := methodToLinearize statements first.
	self assert: (replacementBlock statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (replacementBlock statements second
			isSameAs: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' })).
	self assert: replacementBlock statements size equals: 2.
]

{ #category : #'tests - initialization' }
SlangLocalizationTestCase >> testLinearizeNestedCallsWithAssignment [

	| methodToLinearize replacementBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInAssignment.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	ccg
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	"Before it was 
		foo := self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		foo := t1"
	
	replacementBlock := methodToLinearize statements first.
	self assert: (replacementBlock statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (replacementBlock statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' }))).
	self assert: (replacementBlock statements third
			isSameAs: (TAssignmentNode
				variableNamed: 'foo'
				expression: (TVariableNode named: 't1')))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeNestedCallsWithReturn [

	| methodToLinearize replacementBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInReturn.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	ccg
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	"Before it was 
		^ self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		^ t1"
	
	replacementBlock := methodToLinearize statements first.
	self assert: (replacementBlock statements first
			isSameAs: (TAssignmentNode
				variableNamed: 't0'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #nonInlinedMethodUsingAutolocalizedVariable))).
	self assert: (replacementBlock statements second
			isSameAs: (TAssignmentNode
				variableNamed: 't1'
				expression: (TSendNode
					receiver: TVariableNode selfNode
					selector: #foo:
					arguments: { TVariableNode named: 't0' }))).
	self assert: (replacementBlock statements third
			isSameAs: (TReturnNode expression: (TVariableNode named: 't1')))
]

{ #category : #'tests - linearization' }
SlangLocalizationTestCase >> testLinearizeSingleCalls [

	| methodToLinearize replacementBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingInlinedCall.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	ccg
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	"Before it was 
		self inlinedMethodUsingExternalCall.
	After
		self inlinedMethodUsingExternalCall"

	replacementBlock := methodToLinearize statements first.
	self assert: (replacementBlock first
			isSameAs: (TSendNode
					receiver: TVariableNode selfNode
					selector: #inlinedMethodUsingExternalCall))
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
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithSafeEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: 'nonInlinedMethodNotUsingAutolocalizedVariables((local_autoLocalizedVariable += 1))'
]
