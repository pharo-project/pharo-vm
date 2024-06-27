Extension { #name : #IRBytecodeGenerator }

{ #category : #'*StaticSend-Extensions' }
IRBytecodeGenerator >> sendStatic: aMethod [

	| nArgs |
	nArgs := aMethod numArgs.
	stack pop: nArgs.
	encoder genSendStatic: (self literalIndexOf: aMethod)
]
