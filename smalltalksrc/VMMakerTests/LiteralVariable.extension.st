Extension { #name : #LiteralVariable }

{ #category : #'*VMMakerTests' }
LiteralVariable >> forMemory: memory [

	| aVariable |
	aVariable := memory
			allocateSlotsInOldSpace: 2
			format: memory nonIndexablePointerFormat 
			classIndex: self class hash.
			
	memory storePointer: 0 ofObject: aVariable withValue: (name forMemory: memory).
	memory storePointer: 1 ofObject: aVariable withValue: memory nilObject.
	 
	^ aVariable
]

{ #category : #'*VMMakerTests' }
LiteralVariable >> forMethodBuilder: aBuilder [

	^ self forMemory: aBuilder memory
]
