Trait {
	#name : 'TVMSpurMemoryManagerSimulator',
	#category : 'VMMaker-SpurMemoryManagerSimulation',
	#package : 'VMMaker',
	#tag : 'SpurMemoryManagerSimulation'
}

{ #category : 'object format' }
TVMSpurMemoryManagerSimulator >> firstIndexableField: objOop [
	"NOTE: overridden from SpurMemoryManager to add coercion to CArray, so please duplicate any changes.
	 There are only two important cases, both for objects with named inst vars, i.e. formats 2,3 & 5.
	 The first indexable field for formats 2 & 5 is the slot count (by convention, even though that's off the end
	 of the object).  For 3 we must go to the class."
	| fmt classFormat |
	<returnTypeC: #'void *'>
	fmt := self formatOf: objOop.
	fmt <= self lastPointerFormat ifTrue: "pointer; may need to delve into the class format word"
		[(fmt between: self indexablePointersFormat and: self weakArrayFormat) ifTrue:
			[classFormat := self formatOfClass: (self fetchClassOfNonImm: objOop).
			 ^self cCoerce: (self pointerForOop: objOop
												+ self baseHeaderSize
												+ ((self fixedFieldsOfClassFormat: classFormat) << self shiftForWord))
					to: #'oop *'].
		^self cCoerce: (self pointerForOop: objOop + self baseHeaderSize)
				to: #'oop *'].
	"All bit objects, and indeed CompiledMethod, though this is a no-no, start at 0"
	self assert: (fmt >= self sixtyFourBitIndexableFormat and: [fmt < self firstCompiledMethodFormat]).
	^self
		cCoerce: (self pointerForOop: objOop + self baseHeaderSize)
		to: (fmt < self firstByteFormat
				ifTrue:
					[fmt = self sixtyFourBitIndexableFormat
						ifTrue: ["64 bit field objects" #'long long *']
						ifFalse:
							[fmt < self firstShortFormat
								ifTrue: ["32 bit field objects" #'int *']
								ifFalse: ["16-bit field objects" #'short *']]]
				ifFalse: ["byte objects (including CompiledMethod" #'char *'])
]

{ #category : 'growing/shrinking memory' }
TVMSpurMemoryManagerSimulator >> growOldSpaceByAtLeast: minAmmount callingOperation: aString [
	"Attempt to grow memory by at least minAmmount.
	 Answer the size of the new segment, or nil if the attempt failed.
	 Override to not grow during the Spur image bootstrap."

	^ self bootstrapping ifFalse: [
		  super
			  growOldSpaceByAtLeast: minAmmount
			  callingOperation: aString ]
]
