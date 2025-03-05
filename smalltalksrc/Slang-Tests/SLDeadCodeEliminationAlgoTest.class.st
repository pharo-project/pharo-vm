Class {
	#name : 'SLDeadCodeEliminationAlgoTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLDeadCodeElimination'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'running' }
SLDeadCodeEliminationAlgoTest >> setUp [

	super setUp.
	ccg addClass: SLDeadCodeEliminationAlgoTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes.
	sLDeadCodeElimination := SLDeadCodeElimination new codeGenerator: ccg
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTest >> testInlineInSwitchRemovesReturnStatement [

	| method codeGenerator methodToBeInlined translation |
	method := (Spur64BitMemoryManager lookupSelector:
		           #numSlotsForShortening:toIndexableSize:)
		          asTranslationMethodOfClass: TMethod.
	methodToBeInlined := (Spur64BitMemoryManager lookupSelector:
		                      #arrayFormat) asTranslationMethodOfClass:
		                     TMethod.

	codeGenerator := CCodeGeneratorGlobalStructure new.
	codeGenerator addMethod: method.
	codeGenerator addMethod: methodToBeInlined.
	codeGenerator prepareMethods.
	codeGenerator inferTypes.
	codeGenerator doInlining: true.
	
	sLDeadCodeElimination currentMethod: method.
	ccg currentMethod: method.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.


	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* Spur64BitMemoryManager>>#numSlotsForShortening:toIndexableSize: */
static sqInt
numSlotsForShorteningtoIndexableSize(sqInt _objOop, sqInt _indexableSize)
{
	switch (formatOf(_objOop)) {
		case 2:
		{
			return _indexableSize;
		}
		case firstLongFormat():
		case (firstLongFormat()) + 1:
		{
			return numSlotsForBytes(_indexableSize * 4);
		}
		default:
		error("Case not found and no otherwise clause");
		return -1;
	}
}'
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTest >> testIsValidObjStackPageMyIndex [

	| translation tMethod |
	tMethod := ccg methodNamed: #isValidObjStackPage:myIndex:.
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
			'/*	Just check the page itself. */
/* SLDeadCodeEliminationAlgoTestClass>>#isValidObjStackPage:myIndex: */
static sqInt
isValidObjStackPagemyIndex(sqInt objStackPage, sqInt myx)
{
	sqInt marking;
	sqInt ObjStackMyx;
	sqInt ObjStackPageSlots;

	ObjStackMyx = 0;
	ObjStackPageSlots = 0;
	marking = 0;
	if (!((classIndexOf(objStackPage)) == (wordSizeClassIndexPun()))) {
		return 0;
	}
	if (!((formatOf(objStackPage)) == (wordIndexableFormat()))) {
		return 0;
	}
	if (!((numSlotsOfAny(objStackPage)) == ObjStackPageSlots)) {
		return 0;
	}
	if (!(myx == (fetchPointerofObject(ObjStackMyx, objStackPage)))) {
		return 0;
	}
	if (marking && (!(isMarked(objStackPage)))) {
		return 0;
	}
	return 1;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTest >> testMethodWithBlockValueAssignmentIntoSameVariableInArguments [
	
	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueAssignmentIntoSameVariableInArguments.
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
'/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationAlgoTestClass>>#methodWithBlockValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithBlockValueAssignmentIntoSameVariableInArguments(void)
{
	sqInt var;

	{
		method(var);
	}
	return var;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTest >> testMethodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"remove var = var"
	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithBlockValueValueAssignmentIntoSameVariableInArguments.
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationAlgoTestClass>>#methodWithBlockValueValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithBlockValueValueAssignmentIntoSameVariableInArguments(void)
{
	sqInt var;
	sqInt var2;

	{
		method(var2);
		method(var);
	}
	return var;
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testMethodWithCCoerceInExpression [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithCCoerceInExpression.
	tMethod prepareMethodIn: ccg.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.
	ccg doBasicInlining: true.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithCCoerceInExpression */
static char *
methodWithCCoerceInExpression(void)
{
	char *i;

	i = 5;
	return i;
}'
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTest >> testMethodWithEmptyCaseOfSendInReceiver [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithEmptyCaseOfSendInReceiver.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithEmptyCaseOfSendInReceiver */
static void
methodWithEmptyCaseOfSendInReceiver(void)
{
	switch (method()) {
		case 4:
		{
			{
				return;
			}
		}
		break;
		case 6:
		{
		}
		break;
		default:
		error("Case not found and no otherwise clause");
	}
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithNeverUsedLocals [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithNeverUsedLocals.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithNeverUsedLocals */
static sqInt
methodWithNeverUsedLocals(void)
{
	int var5;
	sqInt var6;

	var5 = 6;
	var6 = var5;
	return var6;
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithNeverUsedLocalsFromBlock [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithNeverUsedLocalsFromBlock.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithNeverUsedLocalsFromBlock */
static sqInt
methodWithNeverUsedLocalsFromBlock(void)
{
	int var1;

	var1 = 5;
	{
		var1 += 1;
	}
	return var1;
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithNeverUsedLocalsFromBlockWithExpressionInArguments [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithNeverUsedLocalsFromBlockWithExpressionInArguments.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithNeverUsedLocalsFromBlockWithExpressionInArguments */
static sqInt
methodWithNeverUsedLocalsFromBlockWithExpressionInArguments(void)
{
	sqInt arg1;
	sqInt var1;

	{
		arg1 = 5 + 1;
		var1 = arg1 + 1;
	}
	return var1;
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithNeverUsedLocalsFromBlockasArguments [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithNeverUsedLocalsFromBlockasArguments.
	tMethod prepareMethodIn: ccg.
	ccg doBasicInlining: true.

	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.


	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithNeverUsedLocalsFromBlockasArguments */
static sqInt
methodWithNeverUsedLocalsFromBlockasArguments(void)
{
	method(10 + 10);
	return 0;
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithNeverUsedLocalsFromBlocktatement [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithNeverUsedLocalsFromBlockStatement.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithNeverUsedLocalsFromBlockStatement */
static sqInt
methodWithNeverUsedLocalsFromBlockStatement(void)
{
	int var1;
	sqInt var2;

	var1 = 4;
	{
		var2 = var1 + 1;
	}
	return var2;
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTest >> testMethodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"all of the body is dead code"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments.
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.

	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/*	produce a self assignation at translation time */
/* SLDeadCodeEliminationAlgoTestClass>>#methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments */
static sqInt
methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments(void)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTest >> testMethodWithOnlyNeverUsedLocals [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyNeverUsedLocals.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithOnlyNeverUsedLocals */
static sqInt
methodWithOnlyNeverUsedLocals(void)
{
	return 0;
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testMethodWithOnlyUselessAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithOnlyUselessAssignment.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithOnlyUselessAssignment */
static void
methodWithOnlyUselessAssignment(void)
{
}'
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTest >> testMethodWithSelfAssign [
	"happens because of polymorphisme or inlining"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithSelfAssign.
	sLDeadCodeElimination currentMethod: tMethod.
	ccg currentMethod: tMethod.
	sLDeadCodeElimination removeDeadCodeInCurrentMethod.
	tMethod removeUnusedTempsAndNilIfRequiredIn: ccg.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithSelfAssign */
static sqInt
methodWithSelfAssign(void)
{
	sqInt var;

	var = 0;
	return var;
}'
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression:.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: */
static void
methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression(sqInt anInt)
{
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessAssignment.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessAssignment */
static sqInt
methodWithUselessAssignment(void)
{
	int i;
	sqInt j;

	i = 5;
	j = i;
	return j;
}'
]

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessCodeInBinaryIterativeNoSendInLimit [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessCodeInBinaryIterativeNoSendInLimit.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessCodeInBinaryIterativeNoSendInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeNoSendInLimit(void)
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

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit(void)
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

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit [
	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit */
static sqInt
methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit(void)
{
	sqInt i;
	sqInt iLimit;
	int var1;

	var1 = 0;
	for (i = 2, iLimit = method(); i <= iLimit; i += 1) {
		var1 += 1;
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessLocalsDefinitionsWithSameNameInSubBranches [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessLocalsDefinitionsWithSameNameInSubBranches.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessLocalsDefinitionsWithSameNameInSubBranches */
static sqInt
methodWithUselessLocalsDefinitionsWithSameNameInSubBranches(void)
{
	int subVar1;
	int subVar2;
	sqInt var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar1 = 5;
		var1 = method(subVar1);
	}
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		var1 = method(subVar2);
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessLocalsInSubBranches [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessLocalsInSubBranches.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessLocalsInSubBranches */
static sqInt
methodWithUselessLocalsInSubBranches(void)
{
	int subVar1;
	sqInt var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar1 = 5;
		var1 = method(subVar1);
	}
	return var1;
}'
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationAlgoTest >> testMethodWithUselessLocalsWithSameNameInSubBranches [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUselessLocalsWithSameNameInSubBranches.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#methodWithUselessLocalsWithSameNameInSubBranches */
static sqInt
methodWithUselessLocalsWithSameNameInSubBranches(void)
{
	int subVar1;
	int subVar2;
	sqInt var1;

	var1 = 0;
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		subVar1 = 5;
		var1 = method(subVar1);
	}
	if (!(var1 == 1)) {
		subVar2 = 5 + 5;
		var1 = method(subVar2);
	}
	return var1;
}'
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTest >> testPopThenPushBool [

	| translation tMethod |
	tMethod := ccg methodNamed: #pop:thenPushBool:.
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
			'/* SLDeadCodeEliminationAlgoTestClass>>#pop:thenPushBool: */
static sqInt
popthenPushBool(sqInt nItems, sqInt boolean)
{
	sqInt falseObj;
	sqInt trueObj;

	falseObj = 0;
	trueObj = 0;
	pop(nItems);
	push(((boolean)
		 ? trueObj
		 : falseObj));
	return 0;
}'
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTest >> translate: tast [

	^ String streamContents: [ :str |
		  self astTranslate: tast inStream: str ]
]
