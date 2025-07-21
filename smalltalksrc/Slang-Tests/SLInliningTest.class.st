Class {
	#name : 'SLInliningTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#instVars : [
		'sLInliner',
		'inliningStrategy',
		'inliner'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'building suites' }
SLInliningTest class >> testParameters [

	^ ParametrizedTestMatrix new
		  forSelector: #inliningStrategy
		  addOptions:
			  { "#useOldInlining. #useExtractedInlining." #useNewInlining };
		  yourself
]

{ #category : 'accessing' }
SLInliningTest >> inliningStrategy: aString [ 
	
	inliningStrategy := aString
]

{ #category : 'inlining-simple' }
SLInliningTest >> test2ChainInlining [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodC.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodC */
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
	return 0;
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> test2ChainInliningAssignOnReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodCAssignOnReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodCAssignOnReturn */
static sqInt
methodCAssignOnReturn(void)
{
	sqInt a;

	3 + 3;
	/* begin methodAAssignOnReturn */
	1 + 1;
	a = 2 + 2;
	/* end methodAAssignOnReturn */
	return 0;
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningEmptyMethodAWithArgumentsInlined [
	"a bug present since old version, vm works but it would be nice to fix it one day"

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #emptyMethodAWithArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#emptyMethodAWithArgumentsInlined */
static sqInt
emptyMethodAWithArgumentsInlined(void)
{
	sqInt arg;

	/* begin emptyMethod: */
	/* begin methodCAlwaysInlined */
	3 + 3;
	/* begin methodA */
	1 + 1;
	/* begin methodB */
	arg = 2 + 2;
	/* end methodB */
	/* end methodA */
	/* end methodCAlwaysInlined */
	/* end emptyMethod: */
	return 0;
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningEmptyMethodAWithSimpleArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #emptyMethodAWithSimpleArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#emptyMethodAWithSimpleArgumentsInlined */
static sqInt
emptyMethodAWithSimpleArgumentsInlined(void)
{
	sqInt arg;

	/* begin emptyMethod: */
	arg = 2 + 2;
	/* end emptyMethod: */
	return 0;
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAWithArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithArgumentsInlined */
static sqInt
methodAWithArgumentsInlined(void)
{
	return methodB((3 + 3, /* begin methodA */ 1 + 1, /* begin methodB */ 2 + 2 /* end methodB */ /* end methodA */));
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithReturningSendArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAWithReturningSendArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithReturningSendArgumentsInlined */
static sqInt
methodAWithReturningSendArgumentsInlined(void)
{
	return methodB((3 + 3, /* begin methodA */ 1 + 1, /* begin methodB */ 2 + 2 /* end methodB */ /* end methodA */));
}'
]

{ #category : 'inlining-returning-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithReturningSendReturningArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAWithReturningSendWithMethodWithMultipleReturnInArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithReturningSendWithMethodWithMultipleReturnInArgumentsInlined */
static sqInt
methodAWithReturningSendWithMethodWithMultipleReturnInArgumentsInlined(void)
{
	return methodB(methodAMultipleReturnInlined());
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithSimpleArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAWithSimpleArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithSimpleArgumentsInlined */
static sqInt
methodAWithSimpleArgumentsInlined(void)
{
	methodB(2 + 2);
	return 0;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> test2ChainInliningMultipleReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAMultipleReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodAMultipleReturn */
static sqInt
methodAMultipleReturn(void)
{
	/* begin methodBMultipleReturn */
	if (methodB()) {
		goto l3;
	}
	/* begin methodCMultipleReturn */
	if (methodC()) {
		goto l2;
	}
	3 + 3;
	l2:
	;
	/* end methodCMultipleReturn */
	2 + 2;
	l3:
	;
	/* end methodBMultipleReturn */
	return 1 + 1;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> test2ChainInliningMultipleReturnAsAssignmentExpression [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAMultipleReturnAsAssignmentExpression.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAMultipleReturnAsAssignmentExpression */
static sqInt
methodAMultipleReturnAsAssignmentExpression(void)
{
	sqInt x;

	/* begin methodBMultipleReturn */
	if (methodB()) {
		x = 0;
		goto l3;
	}
	/* begin methodCMultipleReturn */
	if (methodC()) {
		goto l2;
	}
	3 + 3;
	l2:
	;
	/* end methodCMultipleReturn */
	x = 2 + 2;
	l3:
	;
	/* end methodBMultipleReturn */
	return 0;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> test2ChainInliningMultipleReturnAsReturnExpression [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAMultipleReturnAsReturnExpression.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAMultipleReturnAsReturnExpression */
static sqInt
methodAMultipleReturnAsReturnExpression(void)
{
	/* begin methodBMultipleReturn */
	if (methodB()) {
		return 0;
	}
	/* begin methodCMultipleReturn */
	if (methodC()) {
		goto l2;
	}
	3 + 3;
	l2:
	;
	/* end methodCMultipleReturn */
	return 2 + 2;
	/* end methodBMultipleReturn */
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> test2ChainInliningMultipleReturnAsReturnExpressionAndStatement [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAMultipleReturnAsReturnExpressionAndStatement.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAMultipleReturnAsReturnExpressionAndStatement */
static sqInt
methodAMultipleReturnAsReturnExpressionAndStatement(void)
{
	if (methodB()) {
		return 2;
	} else {
		/* begin methodCMultipleReturn */
		if (methodC()) {
			return 1;
		}
		return 3 + 3;
		/* end methodCMultipleReturn */
	}
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> test2ChainInliningReturnOnAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodCReturnOnAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodCReturnOnAssignment */
static sqInt
methodCReturnOnAssignment(void)
{
	sqInt var;
	int var2;
	sqInt x;

	3 + 3;
	/* begin methodAReturnOnAssignment */
	1 + 1;
	/* begin methodBReturnOnAssignment: */
	var2 = 2 + 2;
	return (var = var2);
	/* end methodBReturnOnAssignment: */
	/* end methodAReturnOnAssignment */
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> test2ChainInliningSimpleReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodASimpleReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodASimpleReturn */
static sqInt
methodASimpleReturn(void)
{
	/* begin methodBSimpleReturn */
	3 + 3;
	2 + 2;
	/* end methodBSimpleReturn */
	return 1 + 1;
}'
]

{ #category : 'collect-statements-for-inlining' }
SLInliningTest >> testCollectStatementsForInliningInMethodWithAvoidedSelector [
	"this method collect statements list for inlining, some specific selectors have special comportment regarding inlining strategy like avoiding inlining he receiver or the some arguments"

	| method statementsForInlining |
	method := ccg methodNamed: #methodWithAvoidedSelectors.
	sLInliner currentMethod: method.
	sLInliner codeGenerator: ccg.

	statementsForInlining := sLInliner
		                         statementsListsForInliningInCurrentMethod.
	self assert: statementsForInlining size equals: 6.
]

{ #category : 'inlining-simple' }
SLInliningTest >> testInlineInSwitchRemovesReturnStatement [

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

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineIfFalseReturningIfTrueInAssignement [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineIfFalseReturningIfTrueInAssignement.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineIfFalseReturningIfTrueInAssignement */
static sqInt
methodAInlineIfFalseReturningIfTrueInAssignement(void)
{
	sqInt a;

	/* begin methodBIfFalseReturningIfTrue */
	if (methodB()) {
		a = 0;
		goto l2;
	} else {
	}
	a = 1;
	l2:
	;
	/* end methodBIfFalseReturningIfTrue */
	return 0;
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineMultipleIfFalseReturningIfTrueInAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineMultipleIfFalseReturningIfTrueInAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineMultipleIfFalseReturningIfTrueInAssignment */
static sqInt
methodAInlineMultipleIfFalseReturningIfTrueInAssignment(void)
{
	sqInt a;

	if (methodB()) {
		/* begin methodBIfFalseReturningIfTrue */
		if (methodB()) {
			a = 0;
			goto l3;
		} else {
		}
		a = 1;
		l3:
		;
		/* end methodBIfFalseReturningIfTrue */
	}
 else {
		/* begin methodBIfFalseReturningIfTrue */
		if (methodB()) {
			a = 0;
			goto l2;
		} else {
		}
		a = 1;
		l2:
		;
		/* end methodBIfFalseReturningIfTrue */
	}
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineMultipleIfFalseReturningIfTrueInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineMultipleIfFalseReturningIfTrueInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineMultipleIfFalseReturningIfTrueInReturn */
static sqInt
methodAInlineMultipleIfFalseReturningIfTrueInReturn(void)
{
	if (methodB()) {
		/* begin methodBIfFalseReturningIfTrue */
		if (methodB()) {
			return 0;
		} else {
		}
		return 1;
		/* end methodBIfFalseReturningIfTrue */
	}
 else {
		/* begin methodBIfFalseReturningIfTrue */
		if (methodB()) {
			return 0;
		} else {
		}
		return 1;
		/* end methodBIfFalseReturningIfTrue */
	}
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineReturningIfTrue [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAInlineReturningIfTrueInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningIfTrueInReturn */
static sqInt
methodAInlineReturningIfTrueInReturn(void)
{
	return ((methodB())
		 ? 1
		 : 0);
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineReturningIfTrueIfFalseInAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningIfTrueIfFalseInAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningIfTrueIfFalseInAssignment */
static sqInt
methodAInlineReturningIfTrueIfFalseInAssignment(void)
{
	sqInt a;

	a = ((methodB())
		 ? 1
		 : 2);
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineReturningIfTrueIfFalseInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningIfTrueIfFalseInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningIfTrueIfFalseInReturn */
static sqInt
methodAInlineReturningIfTrueIfFalseInReturn(void)
{
	return ((methodB())
		 ? 1
		 : 2);
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineReturningIfTrueInAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningIfTrueInAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningIfTrueInAssignment */
static sqInt
methodAInlineReturningIfTrueInAssignment(void)
{
	sqInt a;

	a = ((methodB())
		 ? 1
		 : 0);
	return 0;
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineReturningInlinedIfTrueIfFalseInAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningInlinedIfTrueIfFalseInAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningInlinedIfTrueIfFalseInAssignment */
static sqInt
methodAInlineReturningInlinedIfTrueIfFalseInAssignment(void)
{
	sqInt a;

	if (methodB()) {
		/* begin methodB */
		a = 2 + 2;
		/* end methodB */
	} else {
		/* begin methodA */
		1 + 1;
		/* begin methodB */
		a = 2 + 2;
		/* end methodB */
		/* end methodA */
	}
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineReturningInlinedIfTrueIfFalseInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningInlinedIfTrueIfFalseInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningInlinedIfTrueIfFalseInReturn */
static sqInt
methodAInlineReturningInlinedIfTrueIfFalseInReturn(void)
{
	if (methodB()) {
		/* begin methodB */
		return 2 + 2;
		/* end methodB */
	} else {
		/* begin methodA */
		1 + 1;
		/* begin methodB */
		return 2 + 2;
		/* end methodB */
		/* end methodA */
	}
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAInlineReturningInlinedIfTrueInAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningInlinedIfTrueInAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningInlinedIfTrueInAssignment */
static sqInt
methodAInlineReturningInlinedIfTrueInAssignment(void)
{
	sqInt a;

	if (methodB()) {
		/* begin methodB */
		a = 2 + 2;
		/* end methodB */
	}
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineReturningInlinedIfTrueInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineReturningInlinedIfTrueInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineReturningInlinedIfTrueInReturn */
static sqInt
methodAInlineReturningInlinedIfTrueInReturn(void)
{
	if (methodB()) {
		/* begin methodB */
		return 2 + 2;
		/* end methodB */
	}
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineifFalseReturningIfTrueInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineIfFalseReturningIfTrueInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineIfFalseReturningIfTrueInReturn */
static sqInt
methodAInlineIfFalseReturningIfTrueInReturn(void)
{
	/* begin methodBIfFalseReturningIfTrue */
	if (methodB()) {
		return 0;
	} else {
	}
	return 1;
	/* end methodBIfFalseReturningIfTrue */
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAReturnAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAReturnAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodAReturnAssignment */
static sqInt
methodAReturnAssignment(void)
{
	sqInt a;

	return (a = methodB());
}'
]

{ #category : 'inlining-assignment' }
SLInliningTest >> testMethodAReturnBlockAssignment [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodAReturnBlockAssignment.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAReturnBlockAssignment */
static sqInt
methodAReturnBlockAssignment(void)
{
	sqInt a;

	return (/* begin methodB */ (a = 2 + 2) /* end methodB */);
}'
]

{ #category : 'inlining-returning-arguments' }
SLInliningTest >> testMethodAWithReturningSendWithReturningIfInArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAWithReturningSendWithReturningIfInArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithReturningSendWithReturningIfInArgumentsInlined */
static sqInt
methodAWithReturningSendWithReturningIfInArgumentsInlined(void)
{
	return methodB(((methodB())
		 ? 1
		 : 2));
}'
]

{ #category : 'inlining-returning-arguments' }
SLInliningTest >> testMethodAWithReturningSendWithReturningIfInSendInArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAWithReturningSendWithReturningIfInSendInArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithReturningSendWithReturningIfInSendInArgumentsInlined */
static sqInt
methodAWithReturningSendWithReturningIfInSendInArgumentsInlined(void)
{
	return methodB(methodB(((methodB())
		 ? 1
		 : 2)));
}'
]

{ #category : 'inlining-variable' }
SLInliningTest >> testMethodInlineVariableWithSameName [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodInlineVariableWithSameName.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodInlineVariableWithSameName */
static sqInt
methodInlineVariableWithSameName(void)
{
	sqInt a;
	int a2;

	/* begin methodWithVariableA */
	a2 = 2;
	a = 3;
	/* end methodWithVariableA */
	return 0;
}'
]

{ #category : 'inlining-iterative' }
SLInliningTest >> testMethodWithAssignmentOnRepeatInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithAssignmentOnRepeatInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithAssignmentOnRepeatInlined */
static sqInt
methodWithAssignmentOnRepeatInlined(void)
{
	sqInt a;

	/* begin methodWithRepeat */
	while (1) {
		if (methodB()) {
			a = 5;
			goto l2;
		}
	}
	l2:
	;
	/* end methodWithRepeat */
	return 0;
}'
]

{ #category : 'inlining-iterative' }
SLInliningTest >> testMethodWithAssignmentOnToByDoInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithAssignmentOnToByDoInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithAssignmentOnToByDoInlined */
static sqInt
methodWithAssignmentOnToByDoInlined(void)
{
	sqInt a;
	sqInt i;

	/* begin methodWithToByDo */
	for (i = 1; i <= 4; i += 2) {
		if (methodB(i)) {
			/* begin methodB */
			a = 2 + 2;
			goto l2;
			/* end methodB */
		}
	}
	l2:
	;
	/* end methodWithToByDo */
	return 0;
}'
]

{ #category : 'inlining-iterative' }
SLInliningTest >> testMethodWithAssignmentOnToDoInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithAssignmentOnToDoInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithAssignmentOnToDoInlined */
static sqInt
methodWithAssignmentOnToDoInlined(void)
{
	sqInt a;
	sqInt i;

	/* begin methodWithToDo */
	for (i = 1; i <= 2; i += 1) {
		if (methodB(i)) {
			/* begin methodB */
			a = 2 + 2;
			goto l2;
			/* end methodB */
		}
	}
	l2:
	;
	/* end methodWithToDo */
	return 0;
}'
]

{ #category : 'inlining-iterative' }
SLInliningTest >> testMethodWithAssignmentOnWhileTrueBinaryInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithAssignmentOnWhileTrueBinaryInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithAssignmentOnWhileTrueBinaryInlined */
static sqInt
methodWithAssignmentOnWhileTrueBinaryInlined(void)
{
	sqInt a;

	/* begin methodWithWhileTrueBinary */
	while (1) {
		if (methodB()) {
			/* begin methodB */
			a = 2 + 2;
			goto l2;
			/* end methodB */
		}
	}
	l2:
	;
	/* end methodWithWhileTrueBinary */
	return 0;
}'
]

{ #category : 'inlining-iterative' }
SLInliningTest >> testMethodWithAssignmentOnWhileTrueInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithAssignmentOnWhileTrueInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithAssignmentOnWhileTrueInlined */
static sqInt
methodWithAssignmentOnWhileTrueInlined(void)
{
	sqInt a;

	/* begin methodWithWhileTrue */
	do {
		if (methodB()) {
			a = 5;
			goto l2;
		}
	} while (1);
	l2:
	;
	/* end methodWithWhileTrue */
	return 0;
}'
]

{ #category : 'inlining-block' }
SLInliningTest >> testMethodWithBlockArgumentInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithBlockArgumentInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithBlockArgumentInlined */
static sqInt
methodWithBlockArgumentInlined(void)
{
	sqInt a;

	/* begin methodWithBlockArgument: */
	{
		a = 2;
	}
	/* end methodWithBlockArgument: */
	return 0;
}'
]

{ #category : 'inlining-block' }
SLInliningTest >> testMethodWithBlockWithReturningIfArgumentInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithBlockWithReturningIfArgumentInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithBlockWithReturningIfArgumentInlined */
static sqInt
methodWithBlockWithReturningIfArgumentInlined(void)
{
	sqInt a;

	/* begin methodWithBlockArgument: */
	{
		if (methodB()) {
			/* begin methodB */
			a = 2 + 2;
			/* end methodB */
		} else {
			/* begin methodA */
			1 + 1;
			/* begin methodB */
			a = 2 + 2;
			/* end methodB */
			/* end methodA */
		}
	}
	/* end methodWithBlockArgument: */
	return 0;
}'
]

{ #category : 'inlining-block' }
SLInliningTest >> testMethodWithBlockWithReturningIfWithGotoInlinedArgumentInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithBlockWithReturningIfWithGotoInlinedArgumentInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithBlockWithReturningIfWithGotoInlinedArgumentInlined */
static sqInt
methodWithBlockWithReturningIfWithGotoInlinedArgumentInlined(void)
{
	sqInt a;

	/* begin methodWithBlockArgument: */
	{
		/* begin methodBMultipleReturn */
		if (methodB()) {
			a = 0;
			goto l4;
		}
		/* begin methodCMultipleReturn */
		if (methodC()) {
			goto l5;
		}
		3 + 3;
		l5:
		;
		/* end methodCMultipleReturn */
		a = 2 + 2;
		l4:
		;
		/* end methodBMultipleReturn */
	}
	/* end methodWithBlockArgument: */
	return 0;
}'
]

{ #category : 'inlining-block' }
SLInliningTest >> testMethodWithBlockWithReturningIfWithInlinedArgumentInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithBlockWithReturningIfWithInlinedArgumentInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithBlockWithReturningIfWithInlinedArgumentInlined */
static sqInt
methodWithBlockWithReturningIfWithInlinedArgumentInlined(void)
{
	sqInt a;

	/* begin methodWithBlockArgument: */
	{
		if (methodB()) {
			a = 2;
		} else {
			a = methodCMultipleReturn();
		}
	}
	/* end methodWithBlockArgument: */
	return 0;
}'
]

{ #category : 'inlining-conditional-receiver' }
SLInliningTest >> testMethodWithIfTrueReceiverInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithIfTrueReceiverInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithIfTrueReceiverInlined */
static sqInt
methodWithIfTrueReceiverInlined(void)
{
	{
		if (methodB()) {
			goto l2;
		}
		/* begin methodCMultipleReturn */
		if (methodC()) {
			goto l3;
		}
		3 + 3;
		l3:
		;
		/* end methodCMultipleReturn */
		/* end methodWithMultipleBooleanReturn; fall through */
		/* begin methodB */
		2 + 2;
		/* end methodB */
		l2:
		;
	}
	return 1;
}'
]

{ #category : 'inlining-conditional-receiver' }
SLInliningTest >> testMethodWithReturningIfTrueReceiverInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodWithReturningIfTrueReceiverInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithReturningIfTrueReceiverInlined */
static sqInt
methodWithReturningIfTrueReceiverInlined(void)
{
	{
		if (methodB()) {
			goto l2;
		}
		/* begin methodCMultipleReturn */
		if (methodC()) {
			goto l3;
		}
		3 + 3;
		l3:
		;
		/* end methodCMultipleReturn */
		/* end methodWithMultipleBooleanReturn; fall through */
		/* begin methodB */
		2 + 2;
		/* end methodB */
		return 0;
		l2:
		;
	}
	return 1;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> testMethodWithReturningIfWithReturnPartiallyPushedDownInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithReturningIfWithReturnPartiallyPushedDownInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithReturningIfWithReturnPartiallyPushedDownInlined */
static sqInt
methodWithReturningIfWithReturnPartiallyPushedDownInlined(void)
{
	methodB(((methodB())
		 ? 2
		 : 3));
	return 0;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> testMethodWithReturningIfWithReturnPushedDownInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodWithReturningIfWithReturnPushedDownInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithReturningIfWithReturnPushedDownInlined */
static sqInt
methodWithReturningIfWithReturnPushedDownInlined(void)
{
	methodB(((methodB())
		 ? 2
		 : 3));
	return 0;
}'
]

{ #category : 'inlining-simple' }
SLInliningTest >> testSimpleInlining [

	| method sendStatements |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodA.
	
	sendStatements := method parseTree statements select: #isSend.
	self assert: sendStatements size equals: 2.
	self assert: sendStatements first selector equals: #+.
	self assert: sendStatements second selector equals: #+
		

]

{ #category : 'parameters' }
SLInliningTest >> useExtractedInlining [
	
	inliner := SLInliner new
]

{ #category : 'parameters' }
SLInliningTest >> useNewInlining [
	
	inliner := SLInlinerWithAnnotation new
]

{ #category : 'parameters' }
SLInliningTest >> useOldInlining [
	
	inliner := SLOldInlineStrategy new
]
