Class {
	#name : 'SLInliningTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLInliningTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'running' }
SLInliningTest >> setUp [
	super setUp.
	ccg addClass: SLInliningTestClass.
	ccg inferTypes.
]

{ #category : 'inline-in-send' }
SLInliningTest >> testInlineMethodCallInIfMethodWithReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInIfMethodWithReturnConstant.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallInIfMethodWithReturnConstantInIfWithoutReturn [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInIfMethodWithReturnConstantInIfWithoutReturn.
	ccg doBasicInlining: true.
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
SLInliningTest >> testInlineMethodCallInIfMethodWithReturnConstantWithoutReturn [
	"in this case the empty if is not eluded, the reason if that one of the method that does inlining need refactoring"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallInIfMethodWithReturnConstantWithoutReturn.
	ccg doBasicInlining: true.
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

	if (i == 5) {
	}
	return 0;
}'
]

{ #category : 'inline-in-return' }
SLInliningTest >> testInlineMethodCallInRetunMethodWithAssignmentAndReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithAssignmentAndReturnConstantInIf.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallInReturnMethodWithAssignmentAndReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithAssignmentAndReturnConstant.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallInReturnMethodWithReturnConstant [
	"doesn't get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithReturnConstant.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallInReturnMethodWithReturnConstantInIf [
	"doesn't get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallInReturnMethodWithReturnConstantInIf.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallMethodWithAssignmentAndReturnConstant [
	"get rid off the ^ 5 and keep the assignment"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallMethodWithAssignmentAndReturnConstant.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallMethodWithAssignmentAndReturnConstantInIf [
	"get rid off the ^ -1 and keep the assignment"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallMethodWithAssignmentAndReturnConstantInIf.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallMethodWithReturnConstant [
	"get rid off the ^ 5"

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithReturnConstant.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodCallMethodWithReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodCallMethodWithReturnConstantInIf.
	ccg doBasicInlining: true.

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
SLInliningTest >> testInlineMethodWithExpression [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCallMethodWithExpression.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCallMethodWithExpression */
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
SLInliningTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
