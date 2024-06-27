Extension { #name : #IRBuilder }

{ #category : #'*StaticSend-Extensions' }
IRBuilder >> sendStatic: aMethod [ 
	
	^self add: (IRInstruction sendStatic: aMethod)
]
