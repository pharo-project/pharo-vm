Extension { #name : 'ParametrizedTestMatrix' }

{ #category : '*VMMakerTests' }
ParametrizedTestMatrix >> + aParametrizedTestMatrix [

	| newMatrix |
	newMatrix := ParametrizedTestMatrix new.
	self expandMatrix do: [ :subcase1 | 
		newMatrix addCase: subcase1 ].
	aParametrizedTestMatrix asTestMatrix expandMatrix do: [ :subcase2 |  
		newMatrix addCase: subcase2 ].
	^ newMatrix
]
