Extension { #name : 'Array' }

{ #category : '*VMMakerTests' }
Array >> forMemory: aMemory inMethod: anObject [

	^ aMemory newArrayWith: (self collect: [ :anElement | 
			   anElement forMemory: aMemory inMethod: nil ])
]

{ #category : '*VMMakerTests' }
Array >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
