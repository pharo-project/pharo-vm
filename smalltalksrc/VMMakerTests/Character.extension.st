Extension { #name : 'Character' }

{ #category : '*VMMakerTests' }
Character >> forMemory: memory [

	^ memory characterObjectOf: self codePoint
]

{ #category : '*VMMakerTests' }
Character >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
