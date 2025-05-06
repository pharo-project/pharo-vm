Class {
	#name : 'SlangInliningTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SlangInliningTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'tests' }
SlangInliningTest >> test2ChainInlining [

	| method sends sendStatements translation  |
	ccg addClass: SLMockInliningTestClass.
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

{ #category : 'tests' }
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

{ #category : 'tests' }
SlangInliningTest >> testSimpleInlining [

	| method sends sendStatements |
	ccg addClass: SLMockInliningTestClass.
	ccg doBasicInlining: true.

	method := ccg methodNamed: #methodA.
	
	method parseTree collectSendInSelf: (sends := OrderedCollection new).
	sendStatements := method parseTree statements select: #isSend.
	self assert: sendStatements size equals: 2.
	self assert: sendStatements first selector equals: #+.
	self assert: sendStatements second selector equals: #+
		

]

{ #category : 'helpers' }
SlangInliningTest >> translate: tast [

	^ String streamContents: [ :str |
		  self astTranslate: tast inStream: str ]
]
