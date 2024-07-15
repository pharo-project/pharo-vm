Class {
	#name : 'SlangMethodPrototypeTranslationTest',
	#superclass : 'TestCase',
	#instVars : [
		'generator'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SlangMethodPrototypeTranslationTest >> astTranslate: tMethod inStream: aWriteStream [

	| cAST prettyPrinter |
	cAST := tMethod asCASTFunctionPrototypeIn: generator.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter
]

{ #category : 'test-prototype' }
SlangMethodPrototypeTranslationTest >> testMethodPrototype [
	
	| tMethod translation |
	generator addClass: SlangBasicTranslationTestClass.
	tMethod := generator methodNamed: #first:second:.
	translation := self translate: tMethod.
	self assert: translation trimBoth equals: 'static sqInt firstsecond(sqInt param1, sqInt param2);'
]

{ #category : 'helpers' }
SlangMethodPrototypeTranslationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self astTranslate: tast inStream: str ]
]
