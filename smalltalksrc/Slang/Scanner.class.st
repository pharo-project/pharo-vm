Class {
	#name : #Scanner,
	#superclass : #Object,
	#category : #'Slang-ToRemove'
}

{ #category : #scanning }
Scanner >> scanTokens: aString [ 

	^ (RBScanner on: aString readStream) contents
]
