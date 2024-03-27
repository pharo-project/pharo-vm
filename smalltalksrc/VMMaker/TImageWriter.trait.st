Trait {
	#name : #TImageWriter,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
TImageWriter classSide >> staticallyResolvedSelectors [

	^ super staticallyResolvedSelectors
	  , #( #writeImageFile:fromHeader: )
]
