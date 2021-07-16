Class {
	#name : #SlangMethodPrototypeTranslationTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'generator',
		'translationStrategy'
	],
	#category : #'Slang-Tests'
}

{ #category : #'building suites' }
SlangMethodPrototypeTranslationTest class >> testParameters [ 

	^ ParametrizedTestMatrix new
		forSelector: #translationStrategy addOptions: { #slangTranslate . #astTranslate }
]

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
		resetUsedVariablesCache;
		yourself).
]

{ #category : #helpers }
SlangMethodPrototypeTranslationTest >> slangTranslate: tMethod inStream: aWriteStream [

	tMethod emitCFunctionPrototype: aWriteStream generator: generator
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
		self
			perform: (translationStrategy , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]

{ #category : #accessing }
SlangMethodPrototypeTranslationTest >> translationStrategy [

	^ translationStrategy
]

{ #category : #accessing }
SlangMethodPrototypeTranslationTest >> translationStrategy: anObject [

	translationStrategy := anObject
]
