Class {
	#name : 'SLAbstractTranslationTestCase',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'testClass'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> addMethodAndMethodCalledBy: aSelector [

	^ self
		  addMethodAndMethodCalledBy: aSelector
		  structOrNotBlock: [ :selector |
		  ccg addMethodFor: testClass selector: selector ]
]

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> addMethodAndMethodCalledBy: aSelector structOrNotBlock: aBlock [

	| requiredCalls visited previousSize tMethod classMethodSelectors |
	classMethodSelectors := testClass methodDictionary keys.
	tMethod := aBlock value: aSelector.
	(visited := Set new) add: aSelector.
	(requiredCalls := tMethod allCalls) add: tMethod selector.
	previousSize := requiredCalls size.

	[
	requiredCalls do: [ :selector |
		((classMethodSelectors includes: selector) and: [
			 (visited includes: selector) not ]) ifTrue: [
			tMethod := aBlock value: selector.
			visited add: selector.
			requiredCalls addAll: tMethod allCalls ] ].
	requiredCalls size > previousSize ] whileTrue: [
		previousSize := requiredCalls size ].

	ccg inferTypes.
	^ ccg methodNamed: aSelector
]

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> addStructMethodAndMethodCalledBy: aSelector [

	^ self
		  addMethodAndMethodCalledBy: aSelector
		  structOrNotBlock: [ :selector |
		  ccg addStructMethodFor: testClass selector: selector ]
]

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: ccg.
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> doInliningIn: aTMethod [

	ccg doBasicInlining: true
]

{ #category : 'helpers' }
SLAbstractTranslationTestCase >> translate: tast [

	^ String streamContents: [ :str |
		  self astTranslate: tast inStream: str ]
]
