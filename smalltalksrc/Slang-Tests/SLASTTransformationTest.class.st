Class {
	#name : 'SLASTTransformationTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'running' }
SLASTTransformationTest >> setUp [

	super setUp.
	ccg addClass: SLASTTransformationTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes
]

{ #category : 'send-transformation' }
SLASTTransformationTest >> testMethodWithBlockValue [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValue.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLASTTransformationTestClass>>#methodWithBlockValue */
static sqInt
methodWithBlockValue(void)
{
	sqInt arg;

	{
		2 + 1;
	}
	return 0;
}'
]

{ #category : 'send-transformation' }
SLASTTransformationTest >> testMethodWithBlockValueValue [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValueValue.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBlockValueValue */
static sqInt
methodWithBlockValueValue(void)
{
	sqInt arg1;
	sqInt arg2;

	{
		2 + 3;
	}
	return 0;
}'
]

{ #category : 'assignment-transformation' }
SLASTTransformationTest >> testMethodWithBockInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBockInAssignment.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBockInAssignment */
static sqInt
methodWithBockInAssignment(void)
{
	int var;

	{
		emptyMethod();
		var = 5;
	}
	return 0;
}'
]

{ #category : 'assignment-transformation' }
SLASTTransformationTest >> testMethodWithBockValueInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBockValueInAssignment.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBockValueInAssignment */
static sqInt
methodWithBockValueInAssignment(void)
{
	sqInt arg;
	sqInt var;

	{
		emptyMethod(1);
		var = 5;
	}
	return 0;
}'
]

{ #category : 'assignment-transformation' }
SLASTTransformationTest >> testMethodWithBockValueValueInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBockValueValueInAssignment.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBockValueValueInAssignment */
static sqInt
methodWithBockValueValueInAssignment(void)
{
	sqInt arg1;
	sqInt arg2;
	sqInt var;

	{
		emptyMethod(1);
		emptyMethod(2);
		var = 5;
	}
	return 0;
}'
]

{ #category : 'send-transformation' }
SLASTTransformationTest >> testMethodWithFPrintF [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithFPrintF.

	tMethod expandAST.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLASTTransformationTestClass>>#methodWithFPrintF */
static sqInt
methodWithFPrintF(void)
{
	fprintf(something, "%d %d %d %d %d %d", 1, 2, 3, 4, 5, 6);
	return 0;
}'
]
