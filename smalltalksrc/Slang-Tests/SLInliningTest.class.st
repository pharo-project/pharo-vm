Class {
	#name : #SLInliningTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #helpers }
SLInliningTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : #running }
SLInliningTest >> setUp [
	super setUp.
	ccg addClass: SLInliningTestClass.
	ccg inferTypes.
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithAssignmentReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCalledMethodWithAssignmentReturnConstant.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCalledMethodWithAssignmentReturnConstant */
static sqInt
methodCalledMethodWithAssignmentReturnConstant(void)
{
	int i;

	/* begin methodWithAssignmentReturnConstant */
	i = 5;
	return 0;
}'
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithAssignmentReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCalledMethodWithAssignmentReturnConstantInIf.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCalledMethodWithAssignmentReturnConstantInIf */
static sqInt
methodCalledMethodWithAssignmentReturnConstantInIf(void)
{
	int i;

	/* begin methodWithAssignmentReturnConstantInIf */
	if (1) {
		i = 5;
		goto l1;
	}
	l1:
	;
	return 0;
}'
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstant [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCalledMethodWithUnusedVariableReturnConstant.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstant */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstant(void)
{
	return 0;
}'
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstantInIf [

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCalledMethodWithUnusedVariableReturnConstantInIf.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstantInIf */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstantInIf(void)
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

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstantInIfElse [
	
	| translation tMethod |
	tMethod := ccg methodNamed: #methodCalledMethodWithUnusedVariableReturnConstantInIfElse.
	ccg doBasicInlining: true.
	self halt.

	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/*    SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstantInIfElse */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstantInIfElse(void)
{
	/* begin methodReturnConstantInIfElse */
	{
		goto l1;
	}
	l1:
	;   
	return 0;
}'
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstantInIfElseNeedToBeTransformed [
	"after the inlining, one of the branches can become empty, it is eluded by Slang"

	| translation tMethod |
	tMethod := ccg methodNamed:
		           #methodCalledMethodWithUnusedVariableReturnConstantInIfElseNeedToBeTransformed.
	ccg doBasicInlining: true.

	translation := self translate: tMethod.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstantInIfElseNeedToBeTransformed */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstantInIfElseNeedToBeTransformed(void)
{
	int i;

	/* begin methodReturnConstantInIfElseNeedToBeTransformed */
	if (1) {
		goto l1;
	} else {
		i = 5;
		goto l1;
	}
	l1:
	;
	return 0;
}'
]

{ #category : #helpers }
SLInliningTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (#astTranslate , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]
