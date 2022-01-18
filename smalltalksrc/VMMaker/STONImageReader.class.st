Class {
	#name : #STONImageReader,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #reading }
STONImageReader >> readHeaderFrom: f startingAt: headerStart [ "Unnecesary"

	<var: #f type: #sqImageFile>
	<var: #headerStart type: #squeakFileOffsetType>
	<var: #header type: #SpurImageHeaderStruct>
	<returnTypeC: #SpurImageHeaderStruct>

	^ STON reader on: f; next
]
