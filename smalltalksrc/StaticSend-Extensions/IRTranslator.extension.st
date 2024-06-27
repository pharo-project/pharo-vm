Extension { #name : #IRTranslator }

{ #category : #'*StaticSend-Extensions' }
IRTranslator >> visitStaticSend: anIRStaticSend [ 
	
	gen sendStatic: anIRStaticSend calledMethod
]
