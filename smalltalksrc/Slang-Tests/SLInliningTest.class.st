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
			  { "#useExtractedInlining." #useNewInlining };
		  yourself
]

{ #category : 'accessing' }
SLInliningTest >> inliningStrategy: aString [ 
	
	inliningStrategy := aString
]

{ #category : 'inlining-simple' }
SLInliningTest >> test2ChainInlining [

	| method translation |
	method := self addMethodAndMethodCalledBy: #methodC.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodCAssignOnReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #emptyMethodAWithArgumentsInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #emptyMethodAWithSimpleArgumentsInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAWithArgumentsInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithArgumentsInlined */
static sqInt
methodAWithArgumentsInlined(void)
{
	return methodB((/* begin methodCAlwaysInlined */ 3 + 3, /* begin methodA */ 1 + 1, /* begin methodB */ 2 + 2 /* end methodB */ /* end methodA */ /* end methodCAlwaysInlined */));
}'
]

{ #category : 'inline-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithReturningSendArgumentsInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodAWithReturningSendArgumentsInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodAWithReturningSendArgumentsInlined */
static sqInt
methodAWithReturningSendArgumentsInlined(void)
{
	return methodB((/* begin methodCAlwaysInlined */ 3 + 3, /* begin methodA */ 1 + 1, /* begin methodB */ 2 + 2 /* end methodB */ /* end methodA */ /* end methodCAlwaysInlined */));
}'
]

{ #category : 'inlining-returning-arguments' }
SLInliningTest >> test2ChainInliningMethodAWithReturningSendReturningArgumentsInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodAWithReturningSendWithMethodWithMultipleReturnInArgumentsInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAWithSimpleArgumentsInlined.

	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodAMultipleReturn.

	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAMultipleReturnAsAssignmentExpression.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAMultipleReturnAsReturnExpression.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAMultipleReturnAsReturnExpressionAndStatement.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodCReturnOnAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodASimpleReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineIfFalseReturningIfTrueInAssignement.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineMultipleIfFalseReturningIfTrueInAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineMultipleIfFalseReturningIfTrueInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningIfTrueInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningIfTrueIfFalseInAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningIfTrueIfFalseInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningIfTrueInAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningInlinedIfTrueIfFalseInAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningInlinedIfTrueIfFalseInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningInlinedIfTrueInAssignment.
	self doInliningIn: method.

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
	} else {
		a = 0;
	}
	return 0;
}'
]

{ #category : 'inlining-returning-conditional' }
SLInliningTest >> testMethodAInlineReturningInlinedIfTrueInReturn [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineReturningInlinedIfTrueInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAInlineIfFalseReturningIfTrueInReturn.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodAReturnAssignment.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAReturnBlockAssignment.
	self doInliningIn: method.

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

	/* begin methodB */
	return (a = 2 + 2);
	/* end methodB */
}'
]

{ #category : 'inlining-returning-arguments' }
SLInliningTest >> testMethodAWithReturningSendWithReturningIfInArgumentsInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodAWithReturningSendWithReturningIfInArgumentsInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodAWithReturningSendWithReturningIfInSendInArgumentsInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodInlineVariableWithSameName.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithAssignmentOnRepeatInlined.
	self doInliningIn: method.

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
		} else {
			a = 0;
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
	method := self addMethodAndMethodCalledBy:
		          #methodWithAssignmentOnToByDoInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithAssignmentOnToDoInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithAssignmentOnWhileTrueBinaryInlined.
	self doInliningIn: method.

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
		} else {
			a = 0;
			goto l2;
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
	method := self addMethodAndMethodCalledBy:
		          #methodWithAssignmentOnWhileTrueInlined.
	self doInliningIn: method.

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
		} else {
			a = 0;
			goto l2;
		}
	} while (1);
	l2:
	;
	/* end methodWithWhileTrue */
	return 0;
}'
]

{ #category : 'collect-statements-for-inlining' }
SLInliningTest >> testMethodWithAvoidedSelectors [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithAvoidedSelectors.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodWithAvoidedSelectors */
static sqInt
methodWithAvoidedSelectors(void)
{
	/* begin methodB */
	2 + 2;
	/* end methodB */
	method();
	method(methodB(), 2, 3);
	
#  if methodB()
	{
		/* begin methodB */
		2 + 2;
		/* end methodB */
	}
#  else /* methodB() */
	{
		/* begin methodB */
		2 + 2;
		/* end methodB */
	}
#  endif /* methodB() */
	((/* begin methodB */ 2 + 2 /* end methodB */)) && 0;
	0 || (methodB());
	if (methodB()) {
		/* begin methodB */
		2 + 2;
		/* end methodB */
	}
	return 0;
}'
]

{ #category : 'inlining-block' }
SLInliningTest >> testMethodWithBlockArgumentInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithBlockArgumentInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithBlockWithReturningIfArgumentInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithBlockWithReturningIfWithGotoInlinedArgumentInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithBlockWithReturningIfWithInlinedArgumentInlined.
	self doInliningIn: method.

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
			/* begin methodCMultipleReturn */
			if (methodC()) {
				a = 1;
				goto l3;
			}
			a = 3 + 3;
			l3:
			;
			/* end methodCMultipleReturn */
		}
	}
	/* end methodWithBlockArgument: */
	return 0;
}'
]

{ #category : 'inlining-conditional-receiver' }
SLInliningTest >> testMethodWithIfTrueReceiverInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithIfTrueReceiverInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithIfTrueReceiverInlined */
static sqInt
methodWithIfTrueReceiverInlined(void)
{
	/* begin methodWithMultipleBooleanReturn */
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
	/* end methodWithMultipleBooleanReturn */
	/* begin methodB */
	2 + 2;
	/* end methodB */
	l2:
		return 1;
}'
]

{ #category : 'inlining-conditional-receiver' }
SLInliningTest >> testMethodWithReturningIfTrueReceiverInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithReturningIfTrueReceiverInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithReturningIfTrueReceiverInlined */
static sqInt
methodWithReturningIfTrueReceiverInlined(void)
{
	/* begin methodWithMultipleBooleanReturn */
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
	/* end methodWithMultipleBooleanReturn */
	/* begin methodB */
	2 + 2;
	/* end methodB */
	return 0;
	l2:
		return 1;
}'
]

{ #category : 'inlining-jump' }
SLInliningTest >> testMethodWithReturningIfWithReturnPartiallyPushedDownInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithReturningIfWithReturnPartiallyPushedDownInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy:
		          #methodWithReturningIfWithReturnPushedDownInlined.
	self doInliningIn: method.

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
	method := self addMethodAndMethodCalledBy: #methodA.
	self doInliningIn: method.

	sendStatements := method parseTree statements select: #isSend.
	self assert: sendStatements size equals: 2.
	self assert: sendStatements first selector equals: #+.
	self assert: sendStatements second selector equals: #+
]

{ #category : 'inlining-perform-send' }
SLInliningTest >> testmethodWithPerformSend [

	| method translation |
	method := self addMethodAndMethodCalledBy: #methodWithPerformSend.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals: '/* SLMockInliningTestClass>>#methodWithPerformSend */
static sqInt
methodWithPerformSend(void)
{
	return 4;
}'
]

{ #category : 'inlining-perform-send' }
SLInliningTest >> testmethodWithPerformSendAsReceiver [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithPerformSendAsReceiver.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithPerformSendAsReceiver */
static sqInt
methodWithPerformSendAsReceiver(void)
{
	return 4 + 2;
}'
]

{ #category : 'inlining-perform-send' }
SLInliningTest >> testmethodWithPerformSendAsReceiverNotInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithPerformSendAsReceiverNotInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithPerformSendAsReceiverNotInlined */
static sqInt
methodWithPerformSendAsReceiverNotInlined(void)
{
	return (methodB()) + 2;
}'
]

{ #category : 'inlining-perform-send' }
SLInliningTest >> testmethodWithPerformSendNotInlined [

	| method translation |
	method := self addMethodAndMethodCalledBy:
		          #methodWithPerformSendNotInlined.
	self doInliningIn: method.

	translation := self translate: method.
	translation := translation trimBoth.

	self
		assert: translation
		equals:
			'/* SLMockInliningTestClass>>#methodWithPerformSendNotInlined */
static sqInt
methodWithPerformSendNotInlined(void)
{
	return methodB();
}'
]

{ #category : 'parameters' }
SLInliningTest >> useExtractedInlining [
	
	inliner := SLInliner new
]

{ #category : 'parameters' }
SLInliningTest >> useNewInlining [
	
	inliner := SLInlinerWithAnnotation new
]
