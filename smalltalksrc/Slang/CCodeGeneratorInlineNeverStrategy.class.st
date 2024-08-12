Class {
	#name : 'CCodeGeneratorInlineNeverStrategy',
	#superclass : 'CCodeGeneratorAbsoluteInlineStrategy',
	#category : 'Slang-CodeGeneration',
	#package : 'Slang',
	#tag : 'CodeGeneration'
}

{ #category : 'asserting' }
CCodeGeneratorInlineNeverStrategy >> shouldInlineMethod: aMethod [

	^ false
]
