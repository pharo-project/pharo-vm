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

{ #category : 'unused-in-conditional' }
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

{ #category : 'unused-in-conditional' }
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

{ #category : 'unused-constant' }
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

{ #category : 'unused-constant' }
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

{ #category : 'unused-constant' }
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

{ #category : 'unused-constant' }
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

{ #category : 'unused-variable' }
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

{ #category : 'helpers' }
SLDeadCodeEliminationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
