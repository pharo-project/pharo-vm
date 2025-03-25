Class {
	#name : 'SlangInliningTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

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
