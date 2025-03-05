Class {
	#name : 'SLDeadCodeElimination2Test',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLDeadCodeEliminationVisitor',
		'sLDeadCodeElimination'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLDeadCodeElimination2Test >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'running' }
SLDeadCodeElimination2Test >> setUp [

	super setUp.
	ccg addStructClass: SLDeadCodeEliminationTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes.
	sLDeadCodeElimination := SLDeadCodeElimination new codeGenerator: ccg.

]

{ #category : 'only-comment' }
SLDeadCodeElimination2Test >> testConditionalWithOnlyCommentNoSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #conditionalWithOnlyCommentNoSendInReceiver.

	ccg doBasicInlining: true.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'only-comment' }
SLDeadCodeElimination2Test >> testConditionalWithOnlyCommentSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #conditionalWithOnlyCommentSendInReceiver.

	ccg doBasicInlining: true.
	
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		method(self_in_conditionalWithOnlyCommentSendInReceiver, method(self_in_conditionalWithOnlyCommentSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodAddingCallInCoerce [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodAddingCallInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithBlockValueAssignmentIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueAssignmentIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueAssignmentIntoSameVariableInArguments */
static void
methodWithBlockValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueAssignmentIntoSameVariableInArguments)
{
	sqInt var;

	var = 0;
	{
		method(self_in_methodWithBlockValueAssignmentIntoSameVariableInArguments, var);
	}
	{
		return;
	}
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithBlockValueAssignmentNotIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueAssignmentNotIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueAssignmentNotIntoSameVariableInArguments */
static void
methodWithBlockValueAssignmentNotIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueAssignmentNotIntoSameVariableInArguments)
{
	sqInt var2;

	var2 = 0;
	{
		method(self_in_methodWithBlockValueAssignmentNotIntoSameVariableInArguments, var2);
	}
	{
		return;
	}
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"remove var = var"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueValueAssignmentIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithBlockValueValueAssignmentIntoSameVariableInArguments */
static void
methodWithBlockValueValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments)
{
	sqInt var;
	sqInt var2;

	var = 0;
	var2 = 0;
	{
		method(self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments, var2);
		method(self_in_methodWithBlockValueValueAssignmentIntoSameVariableInArguments, var);
	}
	{
		return;
	}
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithBlockValueValueAssignmentNotIntoSameVariableInArguments [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		method(self_in_methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments, var);
		method(self_in_methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments, var2);
		var = var2;
	}
	{
		return;
	}
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodWithCallInCoerce [
	"the cCoerce is unecessary but is kept anyway"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithCallInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeElimination2Test >> testMethodWithConstantInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithConstantInAssignment.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
SLDeadCodeElimination2Test >> testMethodWithConstantInReturn [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithConstantInReturn.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInRepeat [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithDeadCodeInRepeat.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInTimesRepeat [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithDeadCodeInTimesRepeat.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInToByDo [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithDeadCodeInToByDo.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInToDo [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithDeadCodeInToDo.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileFalse [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileFalseLastExpressionIsLeaf.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileFalseBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileFalseBinarySendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileFalseBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileTrue [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileTrueLastExpressionIsLeaf.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileTrueBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithDeadCodeInWhileTrueBinarySendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithDeadCodeInWhileTrueBinarySendInReceiver.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithEmptyCaseOfNoSendInReceiver [
	"we need to use prepareMethodIn to build switch node, we keep the switch because of the default being an error"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyCaseOfNoSendInReceiver:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithEmptyCaseOfOtherwiseNoSendInReceiver [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise are empty so the node is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyCaseOfOtherwiseNoSendInReceiver:.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithEmptyCaseOfOtherwiseSendInReceiver [
	"we need to use prepareMethodIn to build switch node, we keep the message send but the cases and the otherwise are empty so the node is suppressed "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyCaseOfOtherwiseSendInReceiver.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		method(self_in_methodWithEmptyCaseOfOtherwiseSendInReceiver, 2);
	}
	{
		return;
	}
}'
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithEmptyCaseOfSendInReceiver [
	"we need to use prepareMethodIn to build switch node, the cases are empty only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyCaseOfSendInReceiver.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseIfTrueAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseIfTrueAndNoSendInReceiver.
		
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseIfTrueAndSendInReceiver [
	"suppress the send and keep the 4 send in the receiver"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseIfTrueAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseIfTrueAndSendInReceiver */
static void
methodWithEmptyIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver)
{
	{
		method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver);
		method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver, 1);
		method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver);
		method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver, method(self_in_methodWithEmptyIfFalseIfTrueAndSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver */
static void
methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver)
{
	int i;

	{
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver */
static void
methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver)) > 0) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver */
static void
methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver)
{
	int i;

	{
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [
	"reduce the conditional to an ifTrue"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver */
static void
methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver)) > 0) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfNilIfNotNilAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfNilIfNotNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNilIfNotNilAndNoSendInReceiver */
static void
methodWithEmptyIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNilIfNotNilAndNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfNilIfNotNilAndSendInReceiver [
	"supress the send and keep the send in the receiver"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfNilIfNotNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNilIfNotNilAndSendInReceiver */
static void
methodWithEmptyIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNilIfNotNilAndSendInReceiver)
{
	{
		method(self_in_methodWithEmptyIfNilIfNotNilAndSendInReceiver);
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfNotNilIfNilAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfNotNilIfNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNotNilIfNilAndNoSendInReceiver */
static void
methodWithEmptyIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNotNilIfNilAndNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfNotNilIfNilAndSendInReceiver [
	"supress the send and keep the send in the receiver"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfNotNilIfNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfNotNilIfNilAndSendInReceiver */
static void
methodWithEmptyIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfNotNilIfNilAndSendInReceiver)
{
	{
		method(self_in_methodWithEmptyIfNotNilIfNilAndSendInReceiver);
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueIfFalseAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueIfFalseAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueIfFalseAndNoSendInReceiver */
static void
methodWithEmptyIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueIfFalseAndNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueIfFalseAndSendInReceiver [
	"supress the send and keep the 4 send in the receiver"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueIfFalseAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueIfFalseAndSendInReceiver */
static void
methodWithEmptyIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver)
{
	{
		method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver);
		method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver, 1);
		method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver);
		method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver, method(self_in_methodWithEmptyIfTrueIfFalseAndSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver */
static void
methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver)
{
	int i;

	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver */
static void
methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver)) > 0)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver */
static void
methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver)
{
	int i;

	{
		return;
	}
}'
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [
	"reduce the conditional to an ifFalse"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver */
static void
methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver)) > 0)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithEmptyWhileFalseNoSendInCondition [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyWhileFalseNoSendInCondition.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileFalseNoSendInCondition */
static void
methodWithEmptyWhileFalseNoSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileFalseNoSendInCondition)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithEmptyWhileFalseSendInCondition [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyWhileFalseSendInCondition.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileFalseSendInCondition */
static void
methodWithEmptyWhileFalseSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileFalseSendInCondition)
{
	{
		method(self_in_methodWithEmptyWhileFalseSendInCondition);
	}
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithEmptyWhileTrueNoSendInCondition [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyWhileTrueNoSendInCondition.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileTrueNoSendInCondition */
static void
methodWithEmptyWhileTrueNoSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileTrueNoSendInCondition)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithEmptyWhileTrueSendInCondition [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyWhileTrueSendInCondition.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyWhileTrueSendInCondition */
static void
methodWithEmptyWhileTrueSendInCondition(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyWhileTrueSendInCondition)
{
	{
		method(self_in_methodWithEmptyWhileTrueSendInCondition);
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver */
static void
methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver)
{
	int i;

	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver */
static void
methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver)) == null)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver */
static void
methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver)
{
	int i;

	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [
	"reduce the conditional to an ifNotNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver */
static void
methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver)
{
	int i;

	if (!((method(self_in_methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver)) == null)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver */
static void
methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver)
{
	int i;

	{
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver */
static void
methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver)) == null) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver */
static void
methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver)
{
	int i;

	{
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [
	"reduce the conditional to an ifNil"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver */
static void
methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver)
{
	int i;

	if ((method(self_in_methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver)) == null) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeElimination2Test >> testMethodWithInstanceVariableInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithInstanceVariableInAssignment.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithInstanceVariableInAssignment */
static void
methodWithInstanceVariableInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithInstanceVariableInAssignment)
{
	size_t i;

	i = (self_in_methodWithInstanceVariableInAssignment->instancesVariable);
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeElimination2Test >> testMethodWithInstanceVariableInReturn [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithInstanceVariableInReturn.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

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

{ #category : 'variable-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"all of the body is dead code"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationTestClass>>#methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments */
static void
methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments)
{
	{
		return;
	}
}'
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments [
	
	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLDeadCodeEliminationTestClass>>#methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments */
static void
methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments)
{
	sqInt arg;
	sqInt var;
	sqInt var2;

	var2 = 0;
	{
		var = var2;
	}
	{
		return;
	}
}'
]

{ #category : 'only-comment' }
SLDeadCodeElimination2Test >> testMethodWithOnlyComment [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyComment.
	ccg doBasicInlining: true.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

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
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInRepeat [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyDeadCodeInRepeat.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInRepeat */
static void
methodWithOnlyDeadCodeInRepeat(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInRepeat)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileFalse [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyDeadCodeInWhileFalse.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalse */
static void
methodWithOnlyDeadCodeInWhileFalse(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalse)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver */
static void
methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver */
static void
methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver)
{
	{
		method(self_in_methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver);
	}
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileTrue [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyDeadCodeInWhileTrue.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrue */
static void
methodWithOnlyDeadCodeInWhileTrue(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrue)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver */
static void
methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeElimination2Test >> testMethodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver */
static void
methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver)
{
	{
		method(self_in_methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver);
	}
	{
		return;
	}
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeElimination2Test >> testMethodWithSelfAssign [
	"happens because of polymorphisme or inlining"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithSelfAssign.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithSelfAssign */
static void
methodWithSelfAssign(SLDeadCodeEliminationTestClass * self_in_methodWithSelfAssign)
{
	{
		return;
	}
}'
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodWithSendWithNoSideEffectInCoerce [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithSendWithNoSideEffectInCoerce.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
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
	{
		return;
	}
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstant [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedConstant.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstant */
static void
methodWithUnusedConstant(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstant)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused constant is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node. the empty case disappear"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantAndReturnInCaseOfSendInExpression */
static void
methodWithUnusedConstantAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantAndReturnInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantAndReturnInCaseOfSendInExpression, 3)) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases with unused constant are suppressed and the otherwise remains"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static void
methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused constant, they are suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression */
static void
methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused constant so the node is suppressed "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: */
static void
methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression, sqInt anInt)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused constant, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression */
static void
methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression)
{
	{
		method(self_in_methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression, 3);
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases with unused variable are suppressed "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfNoSendInExpression: */
static void
methodWithUnusedConstantInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases are empty only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCaseOfSendInExpression */
static void
methodWithUnusedConstantInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantInCaseOfSendInExpression, 3)) {
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInCoerce [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedConstantInCoerce.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInCoerce */
static void
methodWithUnusedConstantInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInCoerce)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver */
static void
methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfFalseIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfFalseIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedConstantInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver);
		method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedConstantInIfFalseIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseNoSendInReceiver */
static void
methodWithUnusedConstantInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfFalseSendInReceiver */
static void
methodWithUnusedConstantInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver);
		method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver, method(self_in_methodWithUnusedConstantInIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNilIfNotNillSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNilIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedConstantInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNilIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNilSendInReceiver */
static void
methodWithUnusedConstantInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNotNilIfNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNotNilIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNotNilIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNotNilNoSendInReceiver.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilNoSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfNotNilSendInReceiver */
static void
methodWithUnusedConstantInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfNotNilSendInReceiver, method(self_in_methodWithUnusedConstantInIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfTrueIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfTrueIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedConstantInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver);
		method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedConstantInIfTrueIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueNoSendInReceiver */
static void
methodWithUnusedConstantInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantInIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantInIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantInIfTrueSendInReceiver */
static void
methodWithUnusedConstantInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantInIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver);
		method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver, method(self_in_methodWithUnusedConstantInIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case and the otherwise with unused constant are suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: */
static void
methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused constant is supressed and the otherwise is kept empty"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression */
static void
methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression, 3)) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariable [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedInstanceVariable.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariable */
static void
methodWithUnusedInstanceVariable(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariable)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused instance variable is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression: */
static void
methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused instance variable is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression */
static void
methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression, 3)) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused instance variable they are suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static void
methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused instance variable, they are suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression */
static void
methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise have unused instance variable, they are all suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused instance variable, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression */
static void
methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression, 3);
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases with unused instance variable are suppressed, only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases are empty only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInCoerce [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedInstanceVariableInCoerce.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInCoerce */
static void
methodWithUnusedInstanceVariableInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInCoerce)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver);
		method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfFalseSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver);
		method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfNotNilSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfNotNilSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver);
		method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfTrueNoSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableInIfTrueSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableInIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedInstanceVariableInIfTrueSendInReceiver */
static void
methodWithUnusedInstanceVariableInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver);
		method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver, method(self_in_methodWithUnusedInstanceVariableInIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused instance variable is suppressed and the otherwise with instance variable is kept empty"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused instance variable is supressed and the otherwise is kept empty"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariable [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedVariable.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariable */
static void
methodWithUnusedVariable(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariable)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableAndReturnInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused variable is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression: */
static void
methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableAndReturnInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused variable is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableAndReturnInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableAndReturnInCaseOfSendInExpression */
static void
methodWithUnusedVariableAndReturnInCaseOfSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableAndReturnInCaseOfSendInExpression)
{
	switch (method(self_in_methodWithUnusedVariableAndReturnInCaseOfSendInExpression, 3)) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused variable, they are suppressed and the otherwise remains."

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused variable, they are suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression */
static void
methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression, 3)) {
		default:
		{
			{
				return;
			}
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case and the otherwise all have unused variable, the node is suppressed"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases and the otherwise all have unused variable, the node is suppressed but the message call is kept"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression)
{
	{
		method(self_in_methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression, 3);
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases all have unused variable, only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCaseOfSendInExpression [
	"we need to use prepareMethodIn to build switch node, the cases are empty only the default remains "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInCaseOfSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


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
		default:
		error("Case not found and no otherwise clause");
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInCoerce [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedVariableInCoerce.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInCoerce */
static void
methodWithUnusedVariableInCoerce(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInCoerce)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver */
static void
methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfFalseIfTrueSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfFalseIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseIfTrueSendInReceiver */
static void
methodWithUnusedVariableInIfFalseIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver);
		method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver, method(self_in_methodWithUnusedVariableInIfFalseIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfFalseNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseNoSendInReceiver */
static void
methodWithUnusedVariableInIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfFalseSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfFalseSendInReceiver */
static void
methodWithUnusedVariableInIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver);
		method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver, method(self_in_methodWithUnusedVariableInIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNilIfNotNilSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNilIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilIfNotNilSendInReceiver */
static void
methodWithUnusedVariableInIfNilIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNilIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNilNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNilSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNilSendInReceiver */
static void
methodWithUnusedVariableInIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNotNilIfNilSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNotNilIfNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilIfNilSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilIfNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNotNilIfNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNotNilNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"


	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNotNilNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilNoSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfNotNilSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfNotNilSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfNotNilSendInReceiver */
static void
methodWithUnusedVariableInIfNotNilSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfNotNilSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfNotNilSendInReceiver, method(self_in_methodWithUnusedVariableInIfNotNilSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver */
static void
methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfTrueIfFalseSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfTrueIfFalseSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueIfFalseSendInReceiver */
static void
methodWithUnusedVariableInIfTrueIfFalseSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver);
		method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver, 3);
		method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver, method(self_in_methodWithUnusedVariableInIfTrueIfFalseSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfTrueNoSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfTrueNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueNoSendInReceiver */
static void
methodWithUnusedVariableInIfTrueNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueNoSendInReceiver)
{
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableInIfTrueSendInReceiver [
	"in case of variable, the definition is still here after the supression process, we need to use removeUnusedTempsAndNilIfRequiredIn: to clean the ast"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableInIfTrueSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableInIfTrueSendInReceiver */
static void
methodWithUnusedVariableInIfTrueSendInReceiver(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableInIfTrueSendInReceiver)
{
	{
		method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver);
		method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver, 3);
		method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver, method(self_in_methodWithUnusedVariableInIfTrueSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused variable is suppressed, the default is kept empty "

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression, sqInt anInt)
{
	switch (anInt) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeElimination2Test >> testMethodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression [
	"we need to use prepareMethodIn to build switch node, the case with unused variable is supressed and the otherwise is kept empty"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression.
	tMethod prepareMethodIn: ccg.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression */
static void
methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression)
{
	switch (method(self_in_methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression, 3)) {
		case 6:
		{
			{
				return;
			}
		}
		break;
		default:
		{
		}
	}
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeElimination2Test >> testMethodWithVariableInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithVariableInAssignment.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithVariableInAssignment */
static void
methodWithVariableInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithVariableInAssignment)
{
	sqInt i;
	sqInt j;

	i = j;
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeElimination2Test >> testMethodWithVariableInReturn [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithVariableInReturn.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithVariableInReturn */
static sqInt
methodWithVariableInReturn(SLDeadCodeEliminationTestClass * self_in_methodWithVariableInReturn)
{
	sqInt i;

	return i;
}'
]

{ #category : 'only-comment' }
SLDeadCodeElimination2Test >> testSwitchWithOnlyCommentNoSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := ccg methodNamed: #switchWithOnlyCommentNoSendInReceiver:.
	tMethod prepareMethodIn: ccg.
	ccg doBasicInlining: true.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#switchWithOnlyCommentNoSendInReceiver: */
static void
switchWithOnlyCommentNoSendInReceiver(SLDeadCodeEliminationTestClass * self_in_switchWithOnlyCommentNoSendInReceiver, sqInt anInt)
{
	{
		return;
	}
}'
]

{ #category : 'only-comment' }
SLDeadCodeElimination2Test >> testSwitchWithOnlyCommentSendInReceiver [
	"currently the only way to get comments in a methods is through inlining, having only comments is equivalent to being empty so it shouldn't change the behavior of the dead code elimination process"

	| translation tMethod |
	tMethod := ccg methodNamed: #switchWithOnlyCommentSendInReceiver.
	tMethod prepareMethodIn: ccg.
	ccg doBasicInlining: true.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#switchWithOnlyCommentSendInReceiver */
static void
switchWithOnlyCommentSendInReceiver(SLDeadCodeEliminationTestClass * self_in_switchWithOnlyCommentSendInReceiver)
{
	{
		method(self_in_switchWithOnlyCommentSendInReceiver, method(self_in_switchWithOnlyCommentSendInReceiver));
	}
	{
		return;
	}
}'
]

{ #category : 'helpers' }
SLDeadCodeElimination2Test >> translate: tast [

	^ String streamContents: [ :str | 
		self astTranslate: tast inStream: str ]
]
