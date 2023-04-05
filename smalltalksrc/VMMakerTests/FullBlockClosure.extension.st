Extension { #name : #FullBlockClosure }

{ #category : #'*VMMakerTests' }
FullBlockClosure >> forMemory: aMemory inMethod: builder [

	| closure |
	closure := aMemory
		           allocateSlotsInOldSpace: self class allSlots size
		           format: aMemory nonIndexablePointerFormat
		           classIndex: aMemory classFullBlockClosureCompactIndex.

	{
		nil.
		compiledBlock.
		numArgs.
		nil } doWithIndex: [ :value :index |
		aMemory
			storePointer: index - 1
			ofObject: closure
			withValue: (value forMemory: aMemory inMethod: builder) ].

	^ closure
]
