Extension { #name : #SmallInteger }

{ #category : #'*VMMakerTests' }
SmallInteger >> forMemory: memory [
	
	(self > memory maxSmallInteger or: [ self < memory minSmallInteger ]) ifTrue: [ self halt ].
	
	^ memory integerObjectOf: self
]

{ #category : #'*VMMakerTests' }
SmallInteger >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
