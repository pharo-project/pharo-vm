Extension { #name : #EncoderForSistaV1 }

{ #category : #'*StaticSend-Extensions' }
EncoderForSistaV1 >> genSendStatic: methodLiteralOffset [ 
	
	stream
		nextPut: 246;
		nextPut: methodLiteralOffset
]
