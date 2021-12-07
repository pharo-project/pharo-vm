Extension { #name : #UndefinedObject }

{ #category : #'*VMMakerTests' }
UndefinedObject >> forMemory: memory [

	^ memory nilObject
]

{ #category : #'*VMMakerTests' }
UndefinedObject >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
