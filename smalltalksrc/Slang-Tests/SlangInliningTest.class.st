Class {
	#name : 'SlangInliningTest',
	#superclass : 'SLAbstractTranslationTestCase',
	#instVars : [
		'sLInliner'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'inlining-simple' }
SlangInliningTest >> test2ChainInlining [

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
SlangInliningTest >> test2ChainInliningAssignOnReturn [

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
SlangInliningTest >> test2ChainInliningEmptyMethodAWithArgumentsInlined [
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
SlangInliningTest >> test2ChainInliningEmptyMethodAWithSimpleArgumentsInlined [

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
SlangInliningTest >> test2ChainInliningMethodAWithArgumentsInlined [

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
SlangInliningTest >> test2ChainInliningMethodAWithReturningSendArgumentsInlined [

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
SlangInliningTest >> test2ChainInliningMethodAWithReturningSendReturningArgumentsInlined [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAWithReturningSendReturningArgumentsInlined.

	translation := self translate: method.
	translation := translation trimBoth.

	self assert: translation equals: 'incorrect?
			/* SLMockInliningTestClass>>#methodAWithReturningSendReturningArgumentsInlined */
static sqInt
methodAWithReturningSendReturningArgumentsInlined(void)
{
	return methodB((/* begin methodBMultipleReturn */ ((methodB())
		 ? (goto l3;
)
		 : 0), /* begin methodCMultipleReturn */ ((methodC())
		 ? (goto l2;
)
		 : 0), 3 + 3, l2:
	;
	/* end methodCMultipleReturn */
, 2 + 2, l3:
	;
	/* end methodBMultipleReturn */
, 1 + 1));
}'
]

{ #category : 'inline-arguments' }
SlangInliningTest >> test2ChainInliningMethodAWithSimpleArgumentsInlined [

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
SlangInliningTest >> test2ChainInliningMultipleReturn [

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
SlangInliningTest >> test2ChainInliningMultipleReturnAsAssignmentExpression [

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
SlangInliningTest >> test2ChainInliningMultipleReturnAsReturnExpression [

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
SlangInliningTest >> test2ChainInliningMultipleReturnAsReturnExpressionAndStatement [

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
SlangInliningTest >> test2ChainInliningReturnOnAssignment [

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
SlangInliningTest >> test2ChainInliningSimpleReturn [

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

{ #category : 'inlining-simple' }
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

{ #category : 'inlining-assignment' }
SlangInliningTest >> testMethodAInlineIfFalseReturningIfTrueInAssignement [

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
SlangInliningTest >> testMethodAInlineMultipleIfFalseReturningIfTrueInAssignment [

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
SlangInliningTest >> testMethodAInlineMultipleIfFalseReturningIfTrueInReturn [

	| method translation |
	ccg doBasicInlining: true.

	method := ccg methodNamed:
		          #methodAInlineMultipleIfFalseReturningIfTrueInReturn.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAInlineMultipleIfFalseReturningIfTrue */
static sqInt
methodAInlineMultipleIfFalseReturningIfTrue(void)
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
SlangInliningTest >> testMethodAInlineReturningIfTrue [

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
SlangInliningTest >> testMethodAInlineReturningIfTrueIfFalseInAssignment [

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
SlangInliningTest >> testMethodAInlineReturningIfTrueIfFalseInReturn [

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
SlangInliningTest >> testMethodAInlineReturningIfTrueInAssignment [

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
SlangInliningTest >> testMethodAInlineReturningInlinedIfTrueIfFalseInAssignment [

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
SlangInliningTest >> testMethodAInlineReturningInlinedIfTrueIfFalseInReturn [

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
	return ((methodB())
		 ? (/* begin methodB */ 2 + 2 /* end methodB */)
		 : (/* begin methodA */ 1 + 1, /* begin methodB */ 2 + 2 /* end methodB */ /* end methodA */));
}'
]

{ #category : 'inlining-assignment' }
SlangInliningTest >> testMethodAInlineReturningInlinedIfTrueInAssignment [

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

	a = ((methodB())
		 ? (/* begin methodB */ 2 + 2 /* end methodB */)
		 : 0);
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SlangInliningTest >> testMethodAInlineReturningInlinedIfTrueInReturn [

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
	return ((methodB())
		 ? (/* begin methodB */ 2 + 2 /* end methodB */)
		 : 0);
}'
]

{ #category : 'inlining-returning-conditional' }
SlangInliningTest >> testMethodAInlineifFalseReturningIfTrueInReturn [

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
SlangInliningTest >> testMethodAReturnAssignment [

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
SlangInliningTest >> testMethodAReturnBlockAssignment [

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

{ #category : 'inlining-simple' }
SlangInliningTest >> testSimpleInlining [

	| method sendStatements |
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodA.
	
	sendStatements := method parseTree statements select: #isSend.
	self assert: sendStatements size equals: 2.
	self assert: sendStatements first selector equals: #+.
	self assert: sendStatements second selector equals: #+
		

]
