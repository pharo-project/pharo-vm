Class {
	#name : 'VMStackPagesLSB',
	#superclass : 'VMStackPages',
	#category : 'VMMaker-Interpreter',
	#package : 'VMMaker',
	#tag : 'Interpreter'
}

{ #category : 'memory access' }
VMStackPagesLSB >> byteAt: byteAddress put: byte [

	^ objectMemory byteAt: byteAddress put: byte
]

{ #category : 'memory access' }
VMStackPagesLSB >> uint8At: anAddress [

	^ objectMemory uint8At: anAddress
]
