Class {
	#name : #AbstractSTONImageAccess,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'file operations' }
AbstractSTONImageAccess >> headerFile: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ imageFile / 'header.ston'
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> imageFile: imageFileName [

	| imageFile |
	imageFile := imageFileName asFileReference.
	imageFile ensureCreateDirectory.
	
	^ imageFile
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> isSegmentMetadata: file [

	^ file extension = 'ston' and: [ file basename beginsWith: 'seg' ]
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> segmentDataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := 'seg' , segmentIndex asString , '.data'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentDataFile: segmentIndex fromFile: imageFile 
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> segmentMetadataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := 'seg' , segmentIndex asString , '.ston'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractSTONImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentMetadataFile: segmentIndex fromFile: imageFile 
]
