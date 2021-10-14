Class {
	#name : #SlangBasicTranslationTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #accessing }
SlangBasicTranslationTestClass class >> initializationOptions [

	^ nil
]

{ #category : #accessing }
SlangBasicTranslationTestClass class >> interpreterClass [

	^ nil
]

{ #category : #accessing }
SlangBasicTranslationTestClass class >> objectMemoryClass [

	^ nil
]

{ #category : #inline }
SlangBasicTranslationTestClass >> first: param1 second: param2 [
	"Method with several parameters"
]

{ #category : #inline }
SlangBasicTranslationTestClass >> increment: x [

	^ x + 1
]

{ #category : #accessing }
SlangBasicTranslationTestClass >> initializationOptions [

	^ nil
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodDefiningSingleExternVariable [

	<var: 'foo' type: #'extern int' >
	| foo |
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodDefiningSingleStaticVariable [

	<var: 'foo' type: #'static int' >
	| foo |
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodDefiningSingleVariable [

	| foo |
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodUsingSingleArrayVariable [

	<var: 'foo' type: #'int[17]' >
	| foo bar |
	bar := foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodUsingSingleExternalVariable [

	<var: 'foo' type: #'external int' >
	| foo bar |
	bar := foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodUsingSingleInitializedVariable [

	<var: 'foo' type: #'int foo = 17' >
	| foo bar |
	bar := foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodUsingSingleNonInitializedVariable [

	| foo bar |
	bar := foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodUsingSingleStaticVariable [

	<var: 'foo' type: #'static int' >
	| foo bar |
	bar := foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithAnOptionPragma [

	<option: #OPTION>
	
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithLocalVariables [

	<var: #foo declareC: 'float foo'>
	| a b foo |
	foo := 1.2.
	a := 1.
	b := 1.
	^ a + b + foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithMultilineComment [
	"This function is doing nothing, and this comment is useless. Not that useless finaly, because used to test method comments :D"
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithOptionPragma [

	<option: #OPTION1>
	<notOption: #OPTION2>
	<option: #OPTION3>
	
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithSharedCase [

	<sharedCodeInCase: 'sharedCase'>
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithSharedLabelInCase [

	<sharedCodeNamed: 'sharedLabel' inCase: 'sharedCase'>
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithUnsortedTemps [

	| foo bar zzz aaa ddd |
	bar := aaa.
	ddd := zzz + foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithVolatileLocalVariables [

	<volatile>
	<var: #foo declareC: 'float foo'>
	| a b foo |
	foo := 1.2.
	a := 1.
	b := 1.
	^ a + b + foo
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithVolatilePragma [

	<volatile>
	
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithoutReturn [

	<returnTypeC: #sqInt>
]
