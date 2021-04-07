Extension { #name : #Array }

{ #category : #'*VMMakerTests' }
Array >> forMemory: aMemory [

	^ aMemory newArrayWith:
		  (self collect: [ :anElement | anElement forMethodBuilder: aMemory ])
]

{ #category : #'*VMMakerTests' }
Array >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
