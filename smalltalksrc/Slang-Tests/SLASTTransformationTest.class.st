Class {
	#name : 'SLASTTransformationTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#instVars : [
		'sLExpandASTVisitor'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'running' }
SLASTTransformationTest >> setUp [

	super setUp.
	ccg addClass: SLASTTransformationTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes.
	sLExpandASTVisitor := SLExpandASTVisitor new
]

{ #category : 'assignment-transformation' }
SLASTTransformationTest >> testMethodWithBlockInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockInAssignment.

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBlockInAssignment */
static sqInt
methodWithBlockInAssignment(void)
{
	int var;

	{
		emptyMethod();
		var = 5;
	}
	return 0;
}'
]

{ #category : 'send-transformation' }
SLASTTransformationTest >> testMethodWithBlockValue [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValue.

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

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

{ #category : 'assignment-transformation' }
SLASTTransformationTest >> testMethodWithBlockValueInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValueInAssignment.

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBlockValueInAssignment */
static sqInt
methodWithBlockValueInAssignment(void)
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

{ #category : 'send-transformation' }
SLASTTransformationTest >> testMethodWithBlockValueValue [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValueValue.

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

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
SLASTTransformationTest >> testMethodWithBlockValueValueInAssignment [

	| translation tMethod |
	tMethod := ccg methodNamed: #methodWithBlockValueValueInAssignment.

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLASTTransformationTestClass>>#methodWithBlockValueValueInAssignment */
static sqInt
methodWithBlockValueValueInAssignment(void)
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

	sLExpandASTVisitor currentMethod: tMethod.
	sLExpandASTVisitor expandASTInCurrentMethod.

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
