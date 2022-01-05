Class {
	#name : #SlangMethodPrototypeTranslationTest,
	#superclass : #TestCase,
	#instVars : [
		'generator'
	],
	#category : #'Slang-Tests'
}

{ #category : #helpers }
SlangMethodPrototypeTranslationTest >> astTranslate: tMethod inStream: aWriteStream [

	| cAST prettyPrinter |
	cAST := tMethod asCASTFunctionPrototypeIn: generator.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter
]

{ #category : #running }
SlangMethodPrototypeTranslationTest >> setUp [

	super setUp.

	generator := MLVMCCodeGenerator new.
	generator vmMaker: VMMaker new.
	generator vmMaker vmmakerConfiguration: VMMakerConfiguration.
	generator currentMethod: (TMethod new
		labels: Set new;
		yourself).
]

{ #category : #'test-prototype' }
SlangMethodPrototypeTranslationTest >> testMethodPrototype [
	
	| tMethod translation |
	generator addClass: SlangBasicTranslationTestClass.
	tMethod := generator methodNamed: #first:second:.
	translation := self translate: tMethod.
	self assert: translation trimBoth equals: 'static sqInt firstsecond(sqInt param1, sqInt param2);'
]

{ #category : #helpers }
SlangMethodPrototypeTranslationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self astTranslate: tast inStream: str ]
]
