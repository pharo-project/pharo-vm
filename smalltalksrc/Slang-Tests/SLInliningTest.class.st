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
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstant [
	
	| translation tMethod |
	tMethod := ccg methodNamed: #methodCalledMethodWithUnusedVariableReturnConstant.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.
	self halt.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstant */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstant(void)
{
	return 0;
}'
]

{ #category : #'unused-variables' }
SLInliningTest >> testInlineMethodWithUnusedVariableReturnConstantInIf [
	
	| translation tMethod |
	tMethod := ccg methodNamed: #methodCalledMethodWithUnusedVariableReturnConstantInIf.
	tMethod recordDeclarationsIn: ccg.
	ccg doBasicInlining: true.
	self halt.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SLInliningTestClass>>#methodCalledMethodWithUnusedVariableReturnConstantInIf */
static sqInt
methodCalledMethodWithUnusedVariableReturnConstantInIf(void)
{
	/* begin methodReturnConstantInIf */
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
