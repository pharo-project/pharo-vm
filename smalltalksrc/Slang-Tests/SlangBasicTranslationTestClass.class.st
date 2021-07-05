Class {
	#name : #SlangBasicTranslationTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #inline }
SlangBasicTranslationTestClass >> foo: x [
	
	| a |
	x > 10
		ifTrue: [ a := true ]
		ifFalse: [ a := false ].
	[ true ] whileTrue: [ a = false ].
	^ a
]
