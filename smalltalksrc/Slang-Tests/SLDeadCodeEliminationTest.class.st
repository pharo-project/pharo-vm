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
	ccg addClass: SLDeadCodeEliminationTestClass.
	ccg inferTypes.
	sLDeadCodeEliminationVisitor := SLDeadCodeEliminationVisitor new codeGenerator: ccg
	
]

{ #category : 'inline-in-send' }
SLDeadCodeEliminationTest >> testInlineMethodCallInIfMethodWithReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInIfMethodWithReturnConstant.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCallInIfMethodWithReturnConstant */
static sqInt
methodCallInIfMethodWithReturnConstant(void)
{
	sqInt i;

	if (i == 5) {
		return 5;
	}
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
			'/* SLInliningTestClass>>#methodCallInIfMethodWithReturnConstantInIfWithoutReturn */
static sqInt
methodCallInIfMethodWithReturnConstantInIfWithoutReturn(void)
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
			'/* SLInliningTestClass>>#methodCallInIfMethodWithReturnConstantWithoutReturn */
static sqInt
methodCallInIfMethodWithReturnConstantWithoutReturn(void)
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
			'/* SLInliningTestClass>>#methodCallInReturnMethodWithAssignmentAndReturnConstantInIf */
static sqInt
methodCallInReturnMethodWithAssignmentAndReturnConstantInIf(void)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstantInIf */
	if (1) {
		i = 5;
		return -1;
	}
	return null;
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
			'/* SLInliningTestClass>>#methodCallInReturnMethodWithAssignmentAndReturnConstant */
static sqInt
methodCallInReturnMethodWithAssignmentAndReturnConstant(void)
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
			'/* SLInliningTestClass>>#methodCallInReturnMethodWithReturnConstant */
static sqInt
methodCallInReturnMethodWithReturnConstant(void)
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
			'/* SLInliningTestClass>>#methodCallInReturnMethodWithReturnConstantInIf */
static sqInt
methodCallInReturnMethodWithReturnConstantInIf(void)
{
	/* begin methodReturnConstantInIf */
	if (1) {
		return -1;
	}
	return null;
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
			'/* SLInliningTestClass>>#methodCallMethodWithAssignmentAndReturnConstant */
static sqInt
methodCallMethodWithAssignmentAndReturnConstant(void)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstant */
	i = 5;
	return 0;
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
			'/* SLInliningTestClass>>#methodCallMethodWithAssignmentAndReturnConstantInIf */
static sqInt
methodCallMethodWithAssignmentAndReturnConstantInIf(void)
{
	int i;

	/* begin methodWithAssignmentAndReturnConstantInIf */
	if (1) {
		i = 5;
		goto l1;
	}
	l1:
	;
	return 0;
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
			'/* SLInliningTestClass>>#methodCallMethodWithReturnConstant */
static sqInt
methodCallMethodWithReturnConstant(void)
{
	return 0;
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
			'/* SLInliningTestClass>>#methodCallMethodWithReturnConstantInIf */
static sqInt
methodCallMethodWithReturnConstantInIf(void)
{
	/* begin methodReturnConstantInIf */
	if (1) {
		goto l1;
	}
	l1:
	;
	return 0;
}'
]

{ #category : 'unused-variable' }
SLDeadCodeEliminationTest >> testInlineMethodWithExpression [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithExpression.
	ccg doBasicInlining: true.
	sLDeadCodeEliminationVisitor visit: tMethod parseTree.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLInliningTestClass>>#methodCallMethodWithExpression */
static sqInt
methodCallMethodWithExpression(void)
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
	return 0;
}'
]

{ #category : 'helpers' }
SLDeadCodeEliminationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
