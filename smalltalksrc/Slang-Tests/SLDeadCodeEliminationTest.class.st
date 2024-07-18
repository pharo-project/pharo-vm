Class {
	#name : 'SLDeadCodeEliminationTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLDeadCodeEliminationVisitor'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLDeadCodeEliminationTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'running' }
SLDeadCodeEliminationTest >> setUp [
	super setUp.
	ccg addStructClass: SLDeadCodeEliminationTestClass.
	ccg inferTypes.
	sLDeadCodeEliminationVisitor := SLDeadCodeEliminationVisitor new codeGenerator: ccg
	
]

{ #category : 'inline-in-send' }
SLDeadCodeEliminationTest >> testInlineMethodCallInIfMethodWithReturnConstant [
	"the temporay variable is still here"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInIfMethodWithReturnConstant.
	ccg doBasicInlining: true.

	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInIfMethodWithReturnConstant */
static sqInt
methodCallInIfMethodWithReturnConstant(SLDeadCodeEliminationTestClass * self_in_methodCallInIfMethodWithReturnConstant)
{
	sqInt i;

	return 0;
}'
]

{ #category : 'inline-unused-in-conditional' }
SLDeadCodeEliminationTest >> testInlineMethodCallInIfMethodWithReturnConstantInIfWithoutReturn [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInIfMethodWithReturnConstantInIfWithoutReturn.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInIfMethodWithReturnConstantInIfWithoutReturn */
static sqInt
methodCallInIfMethodWithReturnConstantInIfWithoutReturn(SLDeadCodeEliminationTestClass * self_in_methodCallInIfMethodWithReturnConstantInIfWithoutReturn)
{
	sqInt i;

	if (i == 5) {
		/* begin methodReturnConstantInIf */
		if (1) {
			goto l1;
		}
		l1:
		;
	}
	return 0;
}'
]

{ #category : 'inline-unused-in-conditional' }
SLDeadCodeEliminationTest >> testInlineMethodCallInIfMethodWithReturnConstantWithoutReturn [
	"the temporary variable is still here"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInIfMethodWithReturnConstantWithoutReturn.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInIfMethodWithReturnConstantWithoutReturn */
static sqInt
methodCallInIfMethodWithReturnConstantWithoutReturn(SLDeadCodeEliminationTestClass * self_in_methodCallInIfMethodWithReturnConstantWithoutReturn)
{
	sqInt i;

	return 0;
}'
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTest >> testInlineMethodCallInRetunMethodWithAssignmentAndReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithAssignmentAndReturnConstantInIf.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.	
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInReturnMethodWithAssignmentAndReturnConstantInIf */
static sqInt
methodCallInReturnMethodWithAssignmentAndReturnConstantInIf(SLDeadCodeEliminationTestClass * self_in_methodCallInReturnMethodWithAssignmentAndReturnConstantInIf)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstantInIf */
	if (1) {
		i = 5;
		return -1;
	}
	return self_in_methodCallInReturnMethodWithAssignmentAndReturnConstantInIf;
}'
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTest >> testInlineMethodCallInReturnMethodWithAssignmentAndReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithAssignmentAndReturnConstant.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.
	
	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInReturnMethodWithAssignmentAndReturnConstant */
static sqInt
methodCallInReturnMethodWithAssignmentAndReturnConstant(SLDeadCodeEliminationTestClass * self_in_methodCallInReturnMethodWithAssignmentAndReturnConstant)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstant */
	i = 5;
	return 5;
}'
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTest >> testInlineMethodCallInReturnMethodWithReturnConstant [
	"doesn't get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInReturnMethodWithReturnConstant.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInReturnMethodWithReturnConstant */
static sqInt
methodCallInReturnMethodWithReturnConstant(SLDeadCodeEliminationTestClass * self_in_methodCallInReturnMethodWithReturnConstant)
{
	return 5;
}'
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTest >> testInlineMethodCallInReturnMethodWithReturnConstantInIf [
	"doesn't get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInReturnMethodWithReturnConstantInIf.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallInReturnMethodWithReturnConstantInIf */
static sqInt
methodCallInReturnMethodWithReturnConstantInIf(SLDeadCodeEliminationTestClass * self_in_methodCallInReturnMethodWithReturnConstantInIf)
{
	/* begin methodReturnConstantInIf */
	if (1) {
		return -1;
	}
	return self_in_methodCallInReturnMethodWithReturnConstantInIf;
}'
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTest >> testInlineMethodCallMethodWithAssignmentAndReturnConstant [
	"get rid off the ^ 5 and keep the assignment"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallMethodWithAssignmentAndReturnConstant.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallMethodWithAssignmentAndReturnConstant */
static SLDeadCodeEliminationTestClass *
methodCallMethodWithAssignmentAndReturnConstant(SLDeadCodeEliminationTestClass * self_in_methodCallMethodWithAssignmentAndReturnConstant)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstant */
	i = 5;
	return self_in_methodCallMethodWithAssignmentAndReturnConstant;
}'
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTest >> testInlineMethodCallMethodWithAssignmentAndReturnConstantInIf [
	"get rid off the ^ -1 and keep the assignment"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallMethodWithAssignmentAndReturnConstantInIf.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallMethodWithAssignmentAndReturnConstantInIf */
static SLDeadCodeEliminationTestClass *
methodCallMethodWithAssignmentAndReturnConstantInIf(SLDeadCodeEliminationTestClass * self_in_methodCallMethodWithAssignmentAndReturnConstantInIf)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstantInIf */
	if (1) {
		i = 5;
		goto l1;
	}
	l1:
	;
	return self_in_methodCallMethodWithAssignmentAndReturnConstantInIf;
}'
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTest >> testInlineMethodCallMethodWithReturnConstant [
	"get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithReturnConstant.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallMethodWithReturnConstant */
static SLDeadCodeEliminationTestClass *
methodCallMethodWithReturnConstant(SLDeadCodeEliminationTestClass * self_in_methodCallMethodWithReturnConstant)
{
	return self_in_methodCallMethodWithReturnConstant;
}'
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTest >> testInlineMethodCallMethodWithReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithReturnConstantInIf.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallMethodWithReturnConstantInIf */
static SLDeadCodeEliminationTestClass *
methodCallMethodWithReturnConstantInIf(SLDeadCodeEliminationTestClass * self_in_methodCallMethodWithReturnConstantInIf)
{
	/* begin methodReturnConstantInIf */
	if (1) {
		goto l1;
	}
	l1:
	;
	return self_in_methodCallMethodWithReturnConstantInIf;
}'
]

{ #category : 'inline-unused-variable' }
SLDeadCodeEliminationTest >> testInlineMethodWithExpression [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithExpression.
	ccg doBasicInlining: true.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodCallMethodWithExpression */
static SLDeadCodeEliminationTestClass *
methodCallMethodWithExpression(SLDeadCodeEliminationTestClass * self_in_methodCallMethodWithExpression)
{
	sqInt i;

	/* begin methodWithExpression */
	if (i == 1) {
		goto l1;
	}
	if (i == 2) {
		goto l1;
	}
	if (i == 3) {
		goto l1;
	}
	l1:
	;
	return self_in_methodCallMethodWithExpression;
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTest >> testMethodWithConstantInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithConstantInAssignment.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithConstantInAssignment */
static void
methodWithConstantInAssignment(SLDeadCodeEliminationTestClass * self_in_methodWithConstantInAssignment)
{
	int i;

	i = 5;
	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTest >> testMethodWithConstantInReturn [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithConstantInReturn.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

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

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseIfTrueAndNoSendInReceiver [
	"supress the send"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodWithEmptyIfFalseIfTrueAndNoSendInReceiver.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

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

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseIfTrueAndSendInReceiver [
	"suppress the send and keep the send in the receiver"

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
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [
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

	if (1) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [
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

	if (method(self_in_methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [
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

	if (1) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [
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

	if (method(self_in_methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNilIfNotNilAndNoSendInReceiver [
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

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNilIfNotNilAndSendInReceiver [
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
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNotNilIfNilAndNoSendInReceiver [
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

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfNotNilIfNilAndSendInReceiver [
	"supress the send"

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
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueIfFalseAndNoSendInReceiver [
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

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueIfFalseAndSendInReceiver [
	"supress the send and keep the send in the receiver"

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
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [
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

	if (!1) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [
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

	if (!(method(self_in_methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver))) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [
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

	if (!1) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [
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

	if (!(method(self_in_methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver))) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [
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

	if (!(null == null)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [
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

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [
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

	if (!(null == null)) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [
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

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [
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

	if (null == null) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [
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

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [
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

	if (null == null) {
		i = 5;
	}
	{
		return;
	}
}'
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTest >> testMethodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [
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
SLDeadCodeEliminationTest >> testMethodWithInstanceVariableInAssignment [

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
SLDeadCodeEliminationTest >> testMethodWithInstanceVariableInReturn [

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

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedConstant [

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

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedInstanceVariable [

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

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTest >> testMethodWithUnusedVariable [
	"with variables, the definition will not be removed"
	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithUnusedVariable.
	ccg currentMethod: tMethod.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLDeadCodeEliminationTestClass>>#methodWithUnusedVariable */
static void
methodWithUnusedVariable(SLDeadCodeEliminationTestClass * self_in_methodWithUnusedVariable)
{
	sqInt i;

	{
		return;
	}
}'
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTest >> testMethodWithVariableInAssignment [

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
SLDeadCodeEliminationTest >> testMethodWithVariableInReturn [

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

{ #category : 'helpers' }
SLDeadCodeEliminationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
