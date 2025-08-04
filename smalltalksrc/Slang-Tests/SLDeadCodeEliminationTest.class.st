Class {
	#name : 'SLDeadCodeEliminationTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#instVars : [
		'sLDeadCodeEliminationVisitor',
		'sLDeadCodeElimination'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'running' }
SLDeadCodeEliminationTest >> setUp [

	super setUp.
	testClass := SLDeadCodeEliminationTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	sLDeadCodeElimination := SLDeadCodeElimination new codeGenerator: ccg
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTest >> testConditionalWithOnlyCommentNoSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #conditionalWithOnlyCommentNoSendInReceiver.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#conditionalWithOnlyCommentNoSendInReceiver */
static void
conditionalWithOnlyCommentNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_conditionalWithOnlyCommentNoSendInReceiver)
{
	return;
}'
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTest >> testConditionalWithOnlyCommentSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #conditionalWithOnlyCommentSendInReceiver.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#conditionalWithOnlyCommentSendInReceiver */
static void
conditionalWithOnlyCommentSendInReceiver(SLDeadCodeEliminationTestClass * self_in_conditionalWithOnlyCommentSendInReceiver)
{
	method(self_in_conditionalWithOnlyCommentSendInReceiver, method(self_in_conditionalWithOnlyCommentSendInReceiver));
	return;
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodAddingCallInCoerce [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodAddingCallInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodAddingCallInCoerce */
static void
methodAddingCallInCoerce(SLDeadCodeEliminationTestClass * self_in_methodAddingCallInCoerce)
{
	((type) ((method(self_in_methodAddingCallInCoerce)) + (method(self_in_methodAddingCallInCoerce))) );
	return;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithBlockValueAssignmentIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithBlockValueAssignmentIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithBlockValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueAssignmentIntoSameVariableInArguments)
{
	sqInt var;

	var = 0;
	method(self_in_methodWithBlockValueAssignmentIntoSameVariableInArguments, var);
	return var;
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithBlockValueAssignmentNotIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithBlockValueAssignmentNotIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueAssignmentNotIntoSameVariableInArguments */
static sqInt
methodWithBlockValueAssignmentNotIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueAssignmentNotIntoSameVariableInArguments)
{
	sqInt var;
	sqInt var2;

	var2 = 0;
	method(self_in_methodWithBlockValueAssignmentNotIntoSameVariableInArguments, var2);
	var = var2;
	return var;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"remove var = var"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithBlockValueValueAssignmentIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithBlockValueValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments)
{
	sqInt var;
	sqInt var2;

	var = 0;
	var2 = 0;
	method(self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments, var2);
	method(self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments, var);
	return var;
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithBlockValueValueAssignmentNotIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments */
static void
methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments)
{
	sqInt var;
	sqInt var2;

	var = 0;
	var2 = 0;
	method(self_in_methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments, var);
	method(self_in_methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments, var2);
	var = var2;
	return;
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodWithCallInCoerce [
	"the cCoerce is unecessary but is kept anyway"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithCallInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithCallInCoerce */
static void
methodWithCallInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithCallInCoerce)
{
	((type) (method(self_in_methodWithCallInCoerce)) );
	return;
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTest >> testMethodWithConstantInAssignment [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithConstantInAssignment.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithConstantInAssignment */
static sqInt
methodWithConstantInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithConstantInAssignment)
{
	int i;

	i = 5;
	return i;
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTest >> testMethodWithConstantInReturn [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithConstantInReturn.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithConstantInReturn */
static sqInt
methodWithConstantInReturn(SLDeadCodeEliminationTestClass * self_in_methodWithConstantInReturn)
{
	return 5;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInRepeat [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithDeadCodeInRepeat.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInRepeat */
static void
methodWithDeadCodeInRepeat(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInRepeat)
{
	while (1) {
		method(self_in_methodWithDeadCodeInRepeat);
	}
	return;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInTimesRepeat [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithDeadCodeInTimesRepeat.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInTimesRepeat */
static SLDeadCodeEliminationTestClass *
methodWithDeadCodeInTimesRepeat(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInTimesRepeat)
{
	sqInt elm;

	elm = 0;
	{
		method(self_in_methodWithDeadCodeInTimesRepeat, elm);
	}
	{
		method(self_in_methodWithDeadCodeInTimesRepeat, elm);
	}
	{
		method(self_in_methodWithDeadCodeInTimesRepeat, elm);
	}
	return self_in_methodWithDeadCodeInTimesRepeat;
}'
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInToByDo [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithDeadCodeInToByDo.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInToByDo */
static SLDeadCodeEliminationTestClass *
methodWithDeadCodeInToByDo(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInToByDo)
{
	sqInt index;

	for (index = 1; index <= 4; index += 2) {
		method(self_in_methodWithDeadCodeInToByDo, index);
	}
	return self_in_methodWithDeadCodeInToByDo;
}'
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInToDo [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithDeadCodeInToDo.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInToDo */
static SLDeadCodeEliminationTestClass *
methodWithDeadCodeInToDo(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInToDo)
{
	sqInt index;

	for (index = 1; index <= 4; index += 1) {
		method(self_in_methodWithDeadCodeInToDo, index);
	}
	return self_in_methodWithDeadCodeInToDo;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileFalse [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileFalseLastExpressionIsLeaf.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileFalseLastExpressionIsLeaf */
static void
methodWithDeadCodeInWhileFalseLastExpressionIsLeaf(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileFalseLastExpressionIsLeaf)
{
	do {
		method(self_in_methodWithDeadCodeInWhileFalseLastExpressionIsLeaf);
	} while (!1);
	return;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileFalseBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver */
static void
methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver)
{
	sqInt var;

	var = 0;
	while (!(var == 1)) {
		method(self_in_methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver);
	}
	return;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileFalseBinarySendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileFalseBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileFalseBinarySendInReceiver */
static void
methodWithDeadCodeInWhileFalseBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileFalseBinarySendInReceiver)
{
	while (!(method(self_in_methodWithDeadCodeInWhileFalseBinarySendInReceiver))) {
		method(self_in_methodWithDeadCodeInWhileFalseBinarySendInReceiver);
	}
	return;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileTrue [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileTrueLastExpressionIsLeaf.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileTrueLastExpressionIsLeaf */
static void
methodWithDeadCodeInWhileTrueLastExpressionIsLeaf(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileTrueLastExpressionIsLeaf)
{
	do {
		method(self_in_methodWithDeadCodeInWhileTrueLastExpressionIsLeaf);
	} while (1);
	return;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileTrueBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver */
static void
methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver)
{
	sqInt var;

	var = 0;
	while (var == 0) {
		method(self_in_methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver);
	}
	return;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithDeadCodeInWhileTrueBinarySendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithDeadCodeInWhileTrueBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithDeadCodeInWhileTrueBinarySendInReceiver */
static void
methodWithDeadCodeInWhileTrueBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithDeadCodeInWhileTrueBinarySendInReceiver)
{
	while (method(self_in_methodWithDeadCodeInWhileTrueBinarySendInReceiver)) {
		method(self_in_methodWithDeadCodeInWhileTrueBinarySendInReceiver);
	}
	return;
}'
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithEmptyCaseOfNoSendInReceiver [
	"we need to use prepareMethodIn to build switch node, we keep the switch because of the default being an error"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithEmptyCaseOfNoSendInReceiver:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyCaseOfNoSendInReceiver: */
static void
methodWithEmptyCaseOfNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyCaseOfNoSendInReceiver, sqInt anInt)
{
	switch (anInt) {
		case 4:
		case 6:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithEmptyCaseOfOtherwiseNoSendInReceiver [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise are empty so the node is suppressed"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyCaseOfOtherwiseNoSendInReceiver:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyCaseOfOtherwiseNoSendInReceiver: */
static void
methodWithEmptyCaseOfOtherwiseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyCaseOfOtherwiseNoSendInReceiver, sqInt anInt)
{
	return;
}'
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithEmptyCaseOfOtherwiseSendInReceiver [
	"we need to use prepareMethodIn to build switch node, we keep the message send but the cases and the otherwise are empty so the node is suppressed "

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyCaseOfOtherwiseSendInReceiver.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyCaseOfOtherwiseSendInReceiver */
static void
methodWithEmptyCaseOfOtherwiseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyCaseOfOtherwiseSendInReceiver)
{
	method(self_in_methodWithEmptyCaseOfOtherwiseSendInReceiver, 2);
	return;
}'
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithEmptyCaseOfSendInReceiver [
	"we need to use prepareMethodIn to build switch node, the cases are empty only the default remains "

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithEmptyCaseOfSendInReceiver.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyCaseOfSendInReceiver */
static void
methodWithEmptyCaseOfSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyCaseOfSendInReceiver)
{
	switch (method(self_in_methodWithEmptyCaseOfSendInReceiver)) {
		case 4:
		case 6:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseIfTrueAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseIfTrueAndNoSendInReceiver.
		
	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseIfTrueAndNoSendInReceiver */
static void
methodWithEmptyIfFalseIfTrueAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseIfTrueAndNoSendInReceiver)
{
	return;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseIfTrueAndSendInReceiver [
	"suppress the send and keep the 4 send in the receiver"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseIfTrueAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseIfTrueAndSendInReceiver */
static void
methodWithEmptyIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver)
{
	method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver);
	method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver, 1);
	method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver);
	method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver, method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver));
	return;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver */
static sqInt
methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (i == 0) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver */
static sqInt
methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver)) > 0) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver */
static sqInt
methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (i == 0) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver */
static sqInt
methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver)) > 0) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNilIfNotNilAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfNilIfNotNilAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNilIfNotNilAndNoSendInReceiver */
static void
methodWithEmptyIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNilIfNotNilAndNoSendInReceiver)
{
	return;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNilIfNotNilAndSendInReceiver [
	"supress the send and keep the send in the receiver"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfNilIfNotNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNilIfNotNilAndSendInReceiver */
static void
methodWithEmptyIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNilIfNotNilAndSendInReceiver)
{
	method(self_in_methodWithEmptyIfNilIfNotNilAndSendInReceiver);
	return;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNotNilIfNilAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfNotNilIfNilAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNotNilIfNilAndNoSendInReceiver */
static void
methodWithEmptyIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNotNilIfNilAndNoSendInReceiver)
{
	return;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNotNilIfNilAndSendInReceiver [
	"supress the send and keep the send in the receiver"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfNotNilIfNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNotNilIfNilAndSendInReceiver */
static void
methodWithEmptyIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNotNilIfNilAndSendInReceiver)
{
	method(self_in_methodWithEmptyIfNotNilIfNilAndSendInReceiver);
	return;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueIfFalseAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueIfFalseAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueIfFalseAndNoSendInReceiver */
static void
methodWithEmptyIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueIfFalseAndNoSendInReceiver)
{
	return;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueIfFalseAndSendInReceiver [
	"supress the send and keep the 4 send in the receiver"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueIfFalseAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueIfFalseAndSendInReceiver */
static void
methodWithEmptyIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver)
{
	method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver);
	method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver, 1);
	method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver);
	method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver, method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver));
	return;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver */
static sqInt
methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (!(i == 0)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver */
static sqInt
methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver)) > 0)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver */
static sqInt
methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (!(i == 0)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver */
static sqInt
methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver)) > 0)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithEmptyWhileFalseNoSendInCondition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyWhileFalseNoSendInCondition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileFalseNoSendInCondition */
static void
methodWithEmptyWhileFalseNoSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileFalseNoSendInCondition)
{
	return;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithEmptyWhileFalseSendInCondition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithEmptyWhileFalseSendInCondition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileFalseSendInCondition */
static void
methodWithEmptyWhileFalseSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileFalseSendInCondition)
{
	method(self_in_methodWithEmptyWhileFalseSendInCondition);
	return;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithEmptyWhileTrueNoSendInCondition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyWhileTrueNoSendInCondition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileTrueNoSendInCondition */
static void
methodWithEmptyWhileTrueNoSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileTrueNoSendInCondition)
{
	return;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithEmptyWhileTrueSendInCondition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithEmptyWhileTrueSendInCondition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileTrueSendInCondition */
static void
methodWithEmptyWhileTrueSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileTrueSendInCondition)
{
	method(self_in_methodWithEmptyWhileTrueSendInCondition);
	return;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver */
static sqInt
methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (!(i == null)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver */
static sqInt
methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver)
{
	int i;

	i = 0;
	if (!((method(self_in_methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver)) == null)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver.
	
	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver */
static sqInt
methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (!(i == null)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver */
static sqInt
methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver)
{
	int i;

	i = 0;
	if (!((method(self_in_methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver)) == null)) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver */
static sqInt
methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (i == null) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver */
static sqInt
methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver)
{
	int i;

	i = 0;
	if ((method(self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver)) == null) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver */
static sqInt
methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver)
{
	int i;

	i = 0;
	if (i == null) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver */
static sqInt
methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver)
{
	int i;

	i = 0;
	if ((method(self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver)) == null) {
		i = 5;
	}
	return i;
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTest >> testMethodWithInstanceVariableInAssignment [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithInstanceVariableInAssignment.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithInstanceVariableInAssignment */
static size_t
methodWithInstanceVariableInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithInstanceVariableInAssignment)
{
	size_t i;

	i = (self_in_methodWithInstanceVariableInAssignment->instancesVariable);
	return i;
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTest >> testMethodWithInstanceVariableInReturn [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithInstanceVariableInReturn.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithInstanceVariableInReturn */
static size_t
methodWithInstanceVariableInReturn(SLDeadCodeEliminationTestClass * self_in_methodWithInstanceVariableInReturn)
{
	return (self_in_methodWithInstanceVariableInReturn->instancesVariable);
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithNeverUsedLocals [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithNeverUsedLocals.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNeverUsedLocals */
static sqInt
methodWithNeverUsedLocals(SLDeadCodeEliminationTestClass * self_in_methodWithNeverUsedLocals)
{
	int var5;
	sqInt var6;

	var5 = 6;
	var6 = var5;
	return var6;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithNeverUsedLocalsFromBlock [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithNeverUsedLocalsFromBlock.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNeverUsedLocalsFromBlock */
static sqInt
methodWithNeverUsedLocalsFromBlock(SLDeadCodeEliminationTestClass * self_in_methodWithNeverUsedLocalsFromBlock)
{
	int var1;

	var1 = 5;
	var1 += 1;
	return var1;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithNeverUsedLocalsFromBlockStatement [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithNeverUsedLocalsFromBlockStatement.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNeverUsedLocalsFromBlockStatement */
static sqInt
methodWithNeverUsedLocalsFromBlockStatement(SLDeadCodeEliminationTestClass * self_in_methodWithNeverUsedLocalsFromBlockStatement)
{
	int var1;
	sqInt var2;

	var1 = 4;
	var2 = var1 + 1;
	return var2;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithNeverUsedLocalsFromBlockWithExpressionInArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithNeverUsedLocalsFromBlockWithExpressionInArguments.


	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNeverUsedLocalsFromBlockWithExpressionInArguments */
static sqInt
methodWithNeverUsedLocalsFromBlockWithExpressionInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithNeverUsedLocalsFromBlockWithExpressionInArguments)
{
	sqInt arg1;
	sqInt var1;

	arg1 = 5 + 1;
	var1 = arg1 + 1;
	return var1;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithNeverUsedLocalsFromBlockasArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithNeverUsedLocalsFromBlockasArguments.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNeverUsedLocalsFromBlockasArguments */
static SLDeadCodeEliminationTestClass *
methodWithNeverUsedLocalsFromBlockasArguments(SLDeadCodeEliminationTestClass * self_in_methodWithNeverUsedLocalsFromBlockasArguments)
{
	method(self_in_methodWithNeverUsedLocalsFromBlockasArguments, 10 + 10);
	return self_in_methodWithNeverUsedLocalsFromBlockasArguments;
}'
]

{ #category : 'redundant-local-definition' }
SLDeadCodeEliminationTest >> testMethodWithNoRedundantLocalDefinition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithNoRedundantLocalDefinition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithNoRedundantLocalDefinition */
static sqInt
methodWithNoRedundantLocalDefinition(SLDeadCodeEliminationTestClass * self_in_methodWithNoRedundantLocalDefinition)
{
	int index;
	sqInt var;

	index = 0;
	var = index;
	{
		sqInt index2;

		if (var == 1) {
			for (index2 = 1; index2 <= 5; index2 += 1) {
				method(self_in_methodWithNoRedundantLocalDefinition, index2);
			}
		}
	}
	return var;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"all of the body is dead code"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments)
{
	sqInt var;

	return var;
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments */
static sqInt
methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments)
{
	sqInt var;
	sqInt var2;

	var2 = 0;
	var = var2;
	return var;
}'
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTest >> testMethodWithOnlyComment [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyComment.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyComment */
static void
methodWithOnlyComment(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyComment)
{
	/* begin method */
	/* end method */
	return;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInRepeat [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyDeadCodeInRepeat.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInRepeat */
static sqInt
methodWithOnlyDeadCodeInRepeat(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInRepeat)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileFalse [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyDeadCodeInWhileFalse.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalse */
static sqInt
methodWithOnlyDeadCodeInWhileFalse(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalse)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedNodesInBranch: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver */
static sqInt
methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver)
{
	sqInt var;

	return var;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver */
static sqInt
methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver)
{
	sqInt var;

	var = 0;
	method(self_in_methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver);
	return var;
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileTrue [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyDeadCodeInWhileTrue.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrue */
static sqInt
methodWithOnlyDeadCodeInWhileTrue(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrue)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver */
static sqInt
methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTest >> testMethodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver */
static sqInt
methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver)
{
	sqInt var;

	var = 0;
	method(self_in_methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver);
	return var;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithOnlyNeverUsedLocals [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyNeverUsedLocals.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyNeverUsedLocals */
static SLDeadCodeEliminationTestClass *
methodWithOnlyNeverUsedLocals(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyNeverUsedLocals)
{
	return self_in_methodWithOnlyNeverUsedLocals;
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationTest >> testMethodWithOnlyUselessAssignment [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithOnlyUselessAssignment.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyUselessAssignment */
static void
methodWithOnlyUselessAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyUselessAssignment)
{
	return;
}'
]

{ #category : 'redundant-local-definition' }
SLDeadCodeEliminationTest >> testMethodWithRedundantLocalDefinition [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithRedundantLocalDefinition.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithRedundantLocalDefinition */
static sqInt
methodWithRedundantLocalDefinition(SLDeadCodeEliminationTestClass * self_in_methodWithRedundantLocalDefinition)
{
	int var;

	var = 0;
	{
		sqInt index;

		if (var == 1) {
			for (index = 1; index <= 5; index += 1) {
				method(self_in_methodWithRedundantLocalDefinition, index);
			}
		}
	}
	return var;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTest >> testMethodWithSelfAssign [
	"happens because of polymorphisme or inlining"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithSelfAssign.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithSelfAssign */
static sqInt
methodWithSelfAssign(SLDeadCodeEliminationTestClass * self_in_methodWithSelfAssign)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodWithSendWithNoSideEffectInCoerce [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithSendWithNoSideEffectInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithSendWithNoSideEffectInCoerce */
static void
methodWithSendWithNoSideEffectInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithSendWithNoSideEffectInCoerce)
{
	return;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstant [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedConstant.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstant */
static void
methodWithUnusedConstant(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstant)
{
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression: */
static void
methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return;
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node."

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantAndReturnInCaseOfSendInExpression */
static sqInt
methodWithUnusedConstantAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantAndReturnInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantAndReturnInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return 2;
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
		}
		break;
		default:
		{
			return 5;
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression */
static sqInt
methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
		}
		break;
		default:
		{
			return 5;
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused constant so the node is suppressed"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression, sqInt anInt)
{
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused constant, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression */
static sqInt
methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression)
{
	method(self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression, 3);
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfNoSendInExpression: */
static sqInt
methodWithUnusedConstantInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfSendInExpression */
static sqInt
methodWithUnusedConstantInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInCoerce [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedConstantInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCoerce */
static sqInt
methodWithUnusedConstantInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCoerce)
{
	return 0;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver */
static sqInt
methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver)
{
	return 0;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfFalseIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfFalseIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedConstantInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver);
	method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfFalseNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseNoSendInReceiver */
static void
methodWithUnusedConstantInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseSendInReceiver */
static void
methodWithUnusedConstantInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver);
	method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver, method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNilIfNotNillSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNilIfNotNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedConstantInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilSendInReceiver */
static void
methodWithUnusedConstantInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNotNilIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNotNilIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfNotNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfNotNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfTrueIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfTrueIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedConstantInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver);
	method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueNoSendInReceiver */
static void
methodWithUnusedConstantInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantInIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantInIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueSendInReceiver */
static void
methodWithUnusedConstantInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver);
	method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver, method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return 2;
		}
		default:
		{
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression */
static sqInt
methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return 2;
		}
		default:
		{
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariable [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedInstanceVariable.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariable */
static void
methodWithUnusedInstanceVariable(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariable)
{
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression: */
static size_t
methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return (self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression->instancesVariable);
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return (self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression->instancesVariable);
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression */
static size_t
methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return (self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression->instancesVariable);
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return (self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression->instancesVariable);
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static size_t
methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		case 6:
		{
		}
		break;
		default:
		{
			return (self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression->instancesVariable);
		}
	}
	return (self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression->instancesVariable);
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression */
static size_t
methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		case 5:
		case 6:
		{
		}
		break;
		default:
		{
			return (self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression->instancesVariable);
		}
	}
	return (self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression->instancesVariable);
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise have unused instance variable, they are all suppressed"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused instance variable, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression */
static sqInt
methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression)
{
	method(self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression, 3);
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfNoSendInExpression: */
static void
methodWithUnusedInstanceVariableInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfSendInExpression */
static void
methodWithUnusedInstanceVariableInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInCoerce [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedInstanceVariableInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCoerce */
static void
methodWithUnusedInstanceVariableInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCoerce)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver);
	method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver);
	method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver.
	
	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfNotNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver);
	method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableInIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableInIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver);
	method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return;
		}
		default:
		{
		}
	}
	return;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression */
static void
methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return;
		}
		default:
		{
		}
	}
	return;
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariable [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedVariable.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariable */
static void
methodWithUnusedVariable(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariable)
{
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression: */
static sqInt
methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression, sqInt anInt)
{
	int i;

	i = 5;
	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return i;
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableAndReturnInCaseOfSendInExpression */
static sqInt
methodWithUnusedVariableAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableAndReturnInCaseOfSendInExpression)
{
	int i;

	i = 5;
	switch (method(self_in_methodWithUnusedVariableAndReturnInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return i;
		}
		default:
		error("Case not found and no otherwise clause");
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	int i;

	i = 5;
	switch (anInt) {
		case 5:
		case 6:
		{
		}
		break;
		default:
		{
			return i;
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression */
static sqInt
methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression)
{
	int i;

	i = 5;
	switch (method(self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		case 5:
		case 6:
		{
		}
		break;
		default:
		{
			return i;
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case and the otherwise all have unused variable, the node is suppressed"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	return;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused variable, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression)
{
	method(self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression, 3);
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfSendInExpression */
static void
methodWithUnusedVariableInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedVariableInCaseOfSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	return;
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInCoerce [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUnusedVariableInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCoerce */
static void
methodWithUnusedVariableInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCoerce)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver */
static void
methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfFalseIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfFalseIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedVariableInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver);
	method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfFalseNoSendInReceiver.
		
	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseNoSendInReceiver */
static void
methodWithUnusedVariableInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseSendInReceiver */
static void
methodWithUnusedVariableInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver);
	method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver, method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNilIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNilIfNotNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedVariableInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilSendInReceiver */
static void
methodWithUnusedVariableInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNotNilIfNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNotNilIfNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNotNilNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfNotNilSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfNotNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNotNilSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfTrueIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfTrueIfFalseSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedVariableInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver);
	method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver, 3);
	method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfTrueNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueNoSendInReceiver */
static void
methodWithUnusedVariableInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueNoSendInReceiver)
{
	return;
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableInIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableInIfTrueSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueSendInReceiver */
static void
methodWithUnusedVariableInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueSendInReceiver)
{
	method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver);
	method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver, 3);
	method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver, method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver));
	return;
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static sqInt
methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	sqInt i;

	switch (anInt) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return i;
		}
		default:
		{
		}
	}
	return 0;
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression */
static sqInt
methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression)
{
	int i;

	i = 5;
	switch (method(self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression, 3)) {
		case 5:
		{
		}
		break;
		case 6:
		{
			return i;
		}
		default:
		{
		}
	}
	return 0;
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationTest >> testMethodWithUselessAssignment [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUselessAssignment.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessAssignment */
static sqInt
methodWithUselessAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithUselessAssignment)
{
	int i;
	sqInt j;

	i = 5;
	j = i;
	return j;
}'
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTest >> testMethodWithUselessCodeInBinaryIterativeNoSendInLimit [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUselessCodeInBinaryIterativeNoSendInLimit.
	tMethod prepareMethodIn: ccg.
	
	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessCodeInBinaryIterativeNoSendInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeNoSendInLimit(SLDeadCodeEliminationTestClass * self_in_methodWithUselessCodeInBinaryIterativeNoSendInLimit)
{
	sqInt i;
	int var1;

	var1 = 0;
	for (i = 2; i <= 5; i += 1) {
		var1 += 1;
	}
	return var1;
}'
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTest >> testMethodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit(SLDeadCodeEliminationTestClass * self_in_methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit)
{
	sqInt i;
	int var1;

	var1 = 0;
	for (i = 2; i <= (5 + 5); i += 1) {
		var1 += 1;
	}
	return var1;
}'
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTest >> testMethodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit [
	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit(SLDeadCodeEliminationTestClass * self_in_methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit)
{
	sqInt i;
	sqInt iLimit;
	int var1;

	var1 = 0;
	for (i = 2, iLimit = method(self_in_methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit); i <= iLimit; i += 1) {
		var1 += 1;
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTest >> testMethodWithUselessLocalsDefinitionsWithSameNameInSubBranches [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUselessLocalsDefinitionsWithSameNameInSubBranches.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessLocalsDefinitionsWithSameNameInSubBranches */
static sqInt
methodWithUselessLocalsDefinitionsWithSameNameInSubBranches(SLDeadCodeEliminationTestClass * self_in_methodWithUselessLocalsDefinitionsWithSameNameInSubBranches)
{
	int subVar1;
	int subVar2;
	int var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar1 = 5;
		var1 = method(self_in_methodWithUselessLocalsDefinitionsWithSameNameInSubBranches, subVar1);
	}
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		var1 = method(self_in_methodWithUselessLocalsDefinitionsWithSameNameInSubBranches, subVar2);
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTest >> testMethodWithUselessLocalsInSubBranches [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithUselessLocalsInSubBranches.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.

	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessLocalsInSubBranches */
static sqInt
methodWithUselessLocalsInSubBranches(SLDeadCodeEliminationTestClass * self_in_methodWithUselessLocalsInSubBranches)
{
	int subVar1;
	int var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar1 = 5;
		var1 = method(self_in_methodWithUselessLocalsInSubBranches, subVar1);
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTest >> testMethodWithUselessLocalsWithSameNameInSubBranches [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy:
		           #methodWithUselessLocalsWithSameNameInSubBranches.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.

	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUselessLocalsWithSameNameInSubBranches */
static sqInt
methodWithUselessLocalsWithSameNameInSubBranches(SLDeadCodeEliminationTestClass * self_in_methodWithUselessLocalsWithSameNameInSubBranches)
{
	int subVar1;
	int subVar2;
	int var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		subVar1 = 5;
		var1 = method(self_in_methodWithUselessLocalsWithSameNameInSubBranches, subVar1);
	}
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		var1 = method(self_in_methodWithUselessLocalsWithSameNameInSubBranches, subVar2);
	}
	return var1;
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTest >> testMethodWithVariableInAssignment [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithVariableInAssignment.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithVariableInAssignment */
static sqInt
methodWithVariableInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithVariableInAssignment)
{
	sqInt i;
	sqInt j;

	i = j;
	return i;
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTest >> testMethodWithVariableInReturn [

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #methodWithVariableInReturn.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithVariableInReturn */
static sqInt
methodWithVariableInReturn(SLDeadCodeEliminationTestClass * self_in_methodWithVariableInReturn)
{
	int i;

	i = 0;
	return i;
}'
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTest >> testSwitchWithOnlyCommentNoSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #switchWithOnlyCommentNoSendInReceiver:.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#switchWithOnlyCommentNoSendInReceiver: */
static void
switchWithOnlyCommentNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_switchWithOnlyCommentNoSendInReceiver, sqInt _anInt)
{
	return;
}'
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTest >> testSwitchWithOnlyCommentSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := self addStructMethodAndMethodCalledBy: #switchWithOnlyCommentSendInReceiver.

	ccg prepareMethods.
	self doInliningIn: tMethod.

	sLDeadCodeElimination currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#switchWithOnlyCommentSendInReceiver */
static void
switchWithOnlyCommentSendInReceiver(SLDeadCodeEliminationTestClass * self_in_switchWithOnlyCommentSendInReceiver)
{
	method(self_in_switchWithOnlyCommentSendInReceiver, method(self_in_switchWithOnlyCommentSendInReceiver));
	return;
}'
]
