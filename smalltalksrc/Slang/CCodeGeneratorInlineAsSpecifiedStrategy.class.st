Class {
	#name : #CCodeGeneratorInlineAsSpecifiedStrategy,
	#superclass : #CCodeGeneratorInlineStrategy,
	#instVars : [
		'selectorsOfMethodsNotToInline'
	],
	#category : #'Slang-CodeGeneration'
}

{ #category : #'as yet unclassified' }
CCodeGeneratorInlineAsSpecifiedStrategy >> initialize [

	super initialize.
	selectorsOfMethodsNotToInline := Set new.
]

{ #category : #asserting }
CCodeGeneratorInlineAsSpecifiedStrategy >> isSelectiveInlineStrategy [

	^ true
]

{ #category : #asserting }
CCodeGeneratorInlineAsSpecifiedStrategy >> shouldInlineMethod: aMethod [

	^ (super shouldInlineMethod: aMethod) and: [ self wantsInline: aMethod ]
]
