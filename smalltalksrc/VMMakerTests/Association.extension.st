Extension { #name : #Association }

{ #category : #'*VMMakerTests' }
Association >> forMemory: aMemory inMethod: aMethod [

	| association |
	association := aMemory
		             allocateSlotsInOldSpace: 2
		             format: aMemory nonIndexablePointerFormat
		             classIndex: self class hash.

	aMemory
		storePointer: 0
		ofObject: association
		withValue: (key forMemory: aMemory inMethod: aMethod).
	aMemory
		storePointer: 1
		ofObject: association
		withValue: (value forMemory: aMemory inMethod: aMethod).

	^ association
]
