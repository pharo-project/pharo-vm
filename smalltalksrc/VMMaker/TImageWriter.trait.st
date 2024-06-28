Trait {
	#name : 'TImageWriter',
	#category : 'VMMaker-ImageFormat',
	#package : 'VMMaker',
	#tag : 'ImageFormat'
}

{ #category : 'translation' }
TImageWriter classSide >> staticallyResolvedSelectors [

	^ super staticallyResolvedSelectors
	  , #( #writeImageFile:fromHeader: )
]
