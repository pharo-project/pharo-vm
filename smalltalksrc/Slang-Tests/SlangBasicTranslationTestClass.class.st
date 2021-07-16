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
SlangBasicTranslationTestClass >> methodDefiningSingleVariable [

	| foo |
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithAnOptionPragma [

	<option: #OPTION>
	
]

{ #category : #inline }
SlangBasicTranslationTestClass >> methodWithLocalVariables [

		| a b foo |
		<var: #foo declareC: 'float foo'>
		foo := 1.2.
		a := 1.
		b :=1.
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
SlangBasicTranslationTestClass >> methodWithVolatileLocalVariables [

		| a b foo |
		<volatile>
		<var: #foo declareC: 'float foo'>
		foo := 1.2.
		a := 1.
		b :=1.
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
