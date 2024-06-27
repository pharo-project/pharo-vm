Extension { #name : #IRInstruction }

{ #category : #'*StaticSend-Extensions' }
IRInstruction class >> sendStatic: aMethod [

	^ IRStaticSend new
		  calledMethod: aMethod;
		  yourself
]
