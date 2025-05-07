Class {
	#name : 'SlangInliningTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#instVars : [
		'sLInliner'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'simple-inlining' }
SlangInliningTest >> test2ChainInlining [

	| method translation  |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodC.
	
	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodC */
static sqInt
methodC(void)
{
	3 + 3;
	/* begin methodA */
	1 + 1;
	/* begin methodB */
	2 + 2;
	/* end methodB */
	/* end methodA */
	return self;
}'
]

{ #category : 'collect-statements-for-inlining' }
SlangInliningTest >> testCollectStatementsForInliningInMethodWithAvoidedSelector [
	"this method collect statements list for inlining, some specific selectors have special comportment regarding inlining strategy like avoiding inlining he receiver or the some arguments"

	| method statementsForInlining |
	method := ccg methodNamed: #methodWithAvoidedSelectors.
	sLInliner currentMethod: method.
	sLInliner codeGenerator: ccg.

	statementsForInlining := sLInliner
		                         statementsListsForInliningInCurrentMethod.
	self assert: statementsForInlining size equals: 6.
]

{ #category : 'simple-inlining' }
SlangInliningTest >> testInlineInSwitchRemovesReturnStatement [

	| method codeGenerator methodToBeInlined theSwitch firstCaseConstantExpression firstCase firstCaseLabels |
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

	theSwitch := method parseTree children first expression.
	firstCase := theSwitch cases first.
	firstCaseLabels := firstCase first.
	"The first case should have a single label"
	self assert: firstCaseLabels size equals: 1.
	firstCaseConstantExpression := firstCaseLabels first.
	self assert: firstCaseConstantExpression parent equals: theSwitch
]

{ #category : 'simple-inlining' }
SlangInliningTest >> testSimpleInlining [

	| method sendStatements |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodA.
	
	sendStatements := method parseTree statements select: #isSend.
	self assert: sendStatements size equals: 2.
	self assert: sendStatements first selector equals: #+.
	self assert: sendStatements second selector equals: #+
		

]
