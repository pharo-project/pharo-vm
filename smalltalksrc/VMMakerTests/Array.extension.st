Extension { #name : #Array }

{ #category : #'*VMMakerTests' }
Array >> forMemory: aMemory inMethod: anObject [

	^ aMemory newArrayWith: (self collect: [ :anElement | 
			   anElement forMemory: aMemory inMethod: nil ])
]
