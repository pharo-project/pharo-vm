Class {
	#name : #AbstractComposedImageAccess,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'file operations' }
AbstractComposedImageAccess >> headerFile: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ imageFile / 'header.ston'
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> imageFile: imageFileName [

	| imageFile |
	imageFile := imageFileName asFileReference.
	imageFile ensureCreateDirectory.
	
	^ imageFile
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> isSegmentMetadata: file [

	^ file extension = 'ston' and: [ file basename beginsWith: 'seg' ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := 'seg' , segmentIndex asString , '.data'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentDataFile: segmentIndex fromFile: imageFile 
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := 'seg' , segmentIndex asString , '.ston'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentMetadataFile: segmentIndex fromFile: imageFile 
]
