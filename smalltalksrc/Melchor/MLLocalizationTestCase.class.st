Class {
	#name : #MLLocalizationTestCase,
	#superclass : #SlangAbstractTestCase,
	#category : #Melchor
}

{ #category : #running }
MLLocalizationTestCase >> applyLocalizationTo: interpreterSelector [

	| interpretMethod |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg prepareMethods.
	ccg inlineDispatchesInMethodNamed: interpreterSelector.
	ccg doBasicInlining: true.

	SLAutomaticLocalization new
		codeGenerator: ccg;
		applyMethodNamed: interpreterSelector.
	
	interpretMethod := ccg methodNamed: interpreterSelector.
	ccg currentMethod: interpretMethod.
	^ interpretMethod
]

{ #category : #running }
MLLocalizationTestCase >> applyLocalizationToInterpretWith: initializationSelector [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	MockLocalizationInterpreterMock perform: initializationSelector.
	^ self applyLocalizationTo: #interpret
]

{ #category : #running }
MLLocalizationTestCase >> applyManyLocalizationsToInterpretWith: initializationSelector [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	MockLocalizationInterpreterMock perform: initializationSelector.
	^ self applyLocalizationTo: #interpretWithSeveralVariablesToLocalize
]

{ #category : #helpers }
MLLocalizationTestCase >> assert: aTStatementListNode isRewrittenAs: aString [ 
	
	self assert: (aTStatementListNode isSameAs: (self tastFor: aString))
]

{ #category : #running }
MLLocalizationTestCase >> externalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: aVariableName
			expression: (TVariableNode named: #local_, aVariableName))
]

{ #category : #running }
MLLocalizationTestCase >> internalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: #local_, aVariableName
			expression: (TVariableNode named: aVariableName))
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> linearise: aMethod [

	| methodToLinearize |
	ccg addClass: aMethod methodClass.
	methodToLinearize := ccg methodNamed: aMethod selector.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	SLAutomaticLocalization new
		codeGenerator: ccg;
		linearizeExternalCallsIn: methodToLinearize
		withVariableBindings: ((ccg initAutoLocalizationOfVariablesIn: #interpret) asDictionary
			collect: [:n| TVariableNode named: n]).

	^ methodToLinearize
]

{ #category : #helpers }
MLLocalizationTestCase >> linearizedBlockOfCaseMethod: aTMethod [ 

	| case inlinedMethod |
	case := (aTMethod detect: [ :e | e isCaseStmt ]) cases first.
	inlinedMethod := (case detect: [ :e | e isInline ]) method.
	"Return the first non label, to avoid the labels introduced by inlining"
	^ inlinedMethod statements detect: [ :e | e isLabel not and: [ e isStatementList not or: [ e first isLabel not ]] ]
]

{ #category : #running }
MLLocalizationTestCase >> setUp [

	super setUp.
	MockLocalizationInterpreterMock initialize.
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> tastFor: someCode [

	"Parse the expression as a method with a single expression.
	Transform it to TAST and get the first statement of the TMethod.
	
	Expected: the first statement of the TMethod should correspond to the first statement of the RMethod"
	^ ((RBParser parseExpression: '[', someCode, '] value') methodNode
		compilationContext: CompilationContext new;
		asTranslationMethodOfClass: TMethod)
			parseTree first receiver
]

{ #category : #'tests - initialization' }
MLLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariable [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpret.

	self assert: ((ccg methodNamed: #interpret) locals includes: #local_autoLocalizedVariable)
]

{ #category : #'tests - initialization' }
MLLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariableWhenNameConflict [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpretWithLocalizedVariableConflict.
	self assert: ((ccg methodNamed: #interpretWithLocalizedVariableConflict) locals includes: #local_autoLocalizedVariable1)
]

{ #category : #'tests - initialization' }
MLLocalizationTestCase >> testAutoLocalizeVariableDefinesNewLocalVariables [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| method |
	ccg addClass: MockLocalizationInterpreterMock.
	ccg initAutoLocalizationOfVariablesIn: #interpretWithSeveralVariablesToLocalize.
	method := (ccg methodNamed: #interpretWithSeveralVariablesToLocalize).
	self assert: ( method locals includes: #local_autoLocalizedVariable1).
	self assert: (method locals includes: #local_autoLocalizedVariable)
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableDoesNotLineariseUnnecessaryStatements [

	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"

	| interpretMethod printedString block |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithoutAutoLocalizedVariable.
	block := self linearizedBlockOfCaseMethod: interpretMethod.

	printedString := String streamContents: [ :str | (block asCASTIn: ccg) prettyPrintOn: str ].

	self assert: printedString equals: 'nonInlinedMethodNotUsingAutolocalizedVariables(nonInlinedMethodNotUsingAutolocalizedVariables())'
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableExternalizesAtTheEnd [

	| externalizationStatement interpretMethod |
	interpretMethod := self applyLocalizationTo: #interpret.
	externalizationStatement := interpretMethod statements last first first.

	self assert: (externalizationStatement isSameAs:
			 (self externalizationOf: #autoLocalizedVariable))
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturnReferenchingAutoLocalizedVariable [

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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableExternalizesBeforeReturns [

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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableInternalizesAtTheBeginning [

	| internalizationStatement interpretMethod |
	interpretMethod := self applyLocalizationTo: #interpret.

	internalizationStatement := interpretMethod statements first.

	self
		assert: (internalizationStatement isSameAs: (self internalizationOf: #autoLocalizedVariable))
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testAutoLocalizeVariableReplacesByLocalOnInline [
	
	"Prepare methods will replace the bytecode dispatch instruction into a dispatch switch"
	| interpretMethod variableNode case |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithAutoLocalizedVariableOnly.
	
	"Fail if we find some node inside the case that uses the localized variable"
	case := (interpretMethod detect: [:e | e isCaseStmt ]) cases first.
	variableNode := (case detect: [ :e | e isAssignment ]) variable.

	self assert: (variableNode isVariable and: [ variableNode name = #local_autoLocalizedVariable ]).
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalEscapingAsArgument [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithEscapingCallAsArgument.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock parent asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals:
'{
	{
		sqInt t0;

		{
			autoLocalizedVariable = local_autoLocalizedVariable;
			t0 = foo2();
			local_autoLocalizedVariable = autoLocalizedVariable;
		}
		if (1 == t0) {
		}
	}
}'
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalEscapingAsArgumentOfExternalCall [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalEscapingSendNodeInInlinedMethod [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalEscapingSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalEscapingStatementInConditionalBody [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyLocalizationToInterpretWith: #initializeWithIfStatement.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock parent asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	"The if statement should not be wrapped. Only the inner statements"
	self assert: printedString equals:
'{
	{
		if (1) {
			{
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
			}
		}
	}
}'
]

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalPerform [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalSendNodeExternalizeAndInternalizeOnlyNeededVariables [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testExternalSendNodeShouldBeTranslatedWithExternalizationAndInternalization [
	
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
MLLocalizationTestCase >> testLinearizeCallsInNestedLexicalScope [

	| methodToLinearize ifBlock expected |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableInNestedLexicalScope.

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

	ifBlock := methodToLinearize statements first statements first
		           arguments first statements first.

	expected := self tastFor: '[| t0 |
			t0 := self nonInlinedMethodUsingAutolocalizedVariable.
			self foo: t0]'.

	self assert: (ifBlock isSameAs: expected)
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeNestedCalls [

	| methodToLinearize replacementBlock expected |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableAsExpression.

	"Before it was 
		self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		self foo: t0"

	replacementBlock := methodToLinearize statements first.
	
	expected := self tastFor: '[| t0 |
			t0 := self nonInlinedMethodUsingAutolocalizedVariable.
			self foo: t0]'.

	self assert: (replacementBlock isSameAs: expected)
]

{ #category : #'tests - initialization' }
MLLocalizationTestCase >> testLinearizeNestedCallsWithAssignment [

	| methodToLinearize replacementBlock |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInAssignment.
	
	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	SLAutomaticLocalization new
		codeGenerator: ccg;
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
MLLocalizationTestCase >> testLinearizeNestedCallsWithReturn [

	| methodToLinearize replacementBlock expected |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >>  #bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInReturn.

	"Before it was 
		^ self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		^ t1"
	
	replacementBlock := methodToLinearize statements first.
	
	expected := self tastFor: '[| t0 t1 |
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := self foo: t0.
		^ t1]'.

	self assert: (replacementBlock isSameAs: expected)
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeReceiverOfConditional [

	| methodToLinearize replacementBlock expected |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableAsIfReceiver.

	"Before it was 
		self nonInlinedMethodUsingAutolocalizedVariable ifTrue: [].
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t0 ifTrue: []"

	replacementBlock := methodToLinearize statements first.
	
	expected := self tastFor: '[| t0 t1 |
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t0 ifTrue: []]'.

	self assert: (replacementBlock isSameAs: expected)
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeReceiverOfConditionalAnd [

	| methodToLinearize replacementBlock |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableAsIfReceiverWithAnd.

	"Before it was 
		(self nonInlinedMethodUsingAutolocalizedVariable and: [ 
			 self nonInlinedMethodUsingAutolocalizedVariable ]) ifTrue: [  ]"

	replacementBlock := methodToLinearize statements first.

	"We have an extra nested code because the linearisation algorithm does not flatten..."
	self assert: replacementBlock isRewrittenAs: '
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t0 ifTrue: [ [t1 := self nonInlinedMethodUsingAutolocalizedVariable] ] ifFalse: [ t1 := t0 ].
		t1 ifTrue: []'.
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeReceiverOfConditionalOr [

	| methodToLinearize replacementBlock |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableAsIfReceiverWithOr.

	"Before it was 
		(self nonInlinedMethodUsingAutolocalizedVariable or: [ 
			 self nonInlinedMethodUsingAutolocalizedVariable ]) ifTrue: [  ]"

	replacementBlock := methodToLinearize statements first.

	"We have an extra nested code because the linearisation algorithm does not flatten..."
	self assert: replacementBlock isRewrittenAs: '
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t0 ifTrue: [ t1 := t0 ] ifFalse: [ [t1 := self nonInlinedMethodUsingAutolocalizedVariable] ].
		t1 ifTrue: []'.
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeReceiverOfNestedConditional [

	| methodToLinearize replacementBlock |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingExternalizedAutoLocalizedVariableAsIfReceiverWithNestedConditional.

	"Before it was 
		(self nonInlinedMethodUsingAutolocalizedVariable ifTrue: [ 
		 self nonInlinedMethodUsingAutolocalizedVariable ])
			ifTrue: [  ]
	After
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := t0 ifTrue: [ [self nonInlinedMethodUsingAutolocalizedVariable] ].
		(t0 and: [t1]) ifTrue: []"

	replacementBlock := methodToLinearize statements first.

	"We have an extra nested code because the linearisation algorithm does not flatten..."
	self assert: replacementBlock isRewrittenAs: '
		t0 := self nonInlinedMethodUsingAutolocalizedVariable.
		t1 := t0 ifTrue: [ [self nonInlinedMethodUsingAutolocalizedVariable] ].
		t1 ifTrue: []'.
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testLinearizeSingleCalls [

	| methodToLinearize replacementBlock |
	methodToLinearize := self linearise:
		MockLocalizationInterpreterMock >> #bytecodeUsingInlinedCall.

	"Before it was 
		self inlinedMethodUsingExternalCall.
	After
		self inlinedMethodUsingExternalCall"

	replacementBlock := methodToLinearize statements first.
	
	self assert: replacementBlock isRewrittenAs: 'self inlinedMethodUsingExternalCall'
]

{ #category : #'tests - old localization' }
MLLocalizationTestCase >> testLocalizeSharedVariableShouldFail [
	
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
MLLocalizationTestCase >> testLocalizeSharedVariableShouldFailIfAllInlinedUsesAreNotInlined [
	
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
MLLocalizationTestCase >> testLocalizeSharedVariableShouldNotFailIfAllUsesAreInlined [
	
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

{ #category : #'tests - localisation' }
MLLocalizationTestCase >> testNoExternalSendNodeOnSafeExternalCall [
	
	| interpretMethod cast printedString linearizedBlock |
	interpretMethod := self applyManyLocalizationsToInterpretWith: #initializeWithSafeEscapingCall.

	"Assert that the send node is preceded by variable externalization"
	linearizedBlock := self linearizedBlockOfCaseMethod: interpretMethod.
	cast := linearizedBlock asCASTIn: ccg.
	
	printedString := String streamContents: [ :str | cast prettyPrintOn: str ].
	
	self assert: printedString equals: 'nonInlinedMethodNotUsingAutolocalizedVariables((local_autoLocalizedVariable += 1))'
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testShouldLineariseExpressionUsingAutolocalizedVariable [

	| methodToLinearize localization localizationBindings |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed:
		                     #bytecodeUsingExternalizedAutoLocalizedVariable.

	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	localization := SLAutomaticLocalization new codeGenerator: ccg.
	localizationBindings := (ccg initAutoLocalizationOfVariablesIn:
		                         #interpret) collect: [ :e | e key ].

	self assert: (localization
			 shouldLinearizeStatement: methodToLinearize statements second
			 withVariableBindings: localizationBindings)
]

{ #category : #'tests - linearization' }
MLLocalizationTestCase >> testShouldLineariseIfReceiverExpressionUsingAutolocalizedVariable [

	| methodToLinearize localization localizationBindings |
	ccg addClass: MockLocalizationInterpreterMock.
	methodToLinearize := ccg methodNamed: #bytecodeUsingExternalizedAutoLocalizedVariableAsIfReceiver.

	ccg prepareMethods.
	ccg currentMethod: methodToLinearize.
	localization := SLAutomaticLocalization new codeGenerator: ccg.
	localizationBindings := (ccg initAutoLocalizationOfVariablesIn:
		                         #interpret) collect: [ :e | e key ].

	self assert: (localization
			 shouldLinearizeStatement: methodToLinearize statements second
			 withVariableBindings: localizationBindings)
]
