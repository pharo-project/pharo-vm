Extension { #name : #Character }

{ #category : #'*VMMakerTests' }
Character >> forMemory: aMemory inMethod: anObject [

	^ aMemory characterObjectOf: self codePoint
]
