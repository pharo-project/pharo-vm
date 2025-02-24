Class {
	#name : 'Scanner',
	#superclass : 'Object',
	#category : 'Slang-ToRemove',
	#package : 'Slang',
	#tag : 'ToRemove'
}

{ #category : 'scanning' }
Scanner >> scanTokens: aString [ 

	^ (RBScanner on: aString readStream) contents
]
