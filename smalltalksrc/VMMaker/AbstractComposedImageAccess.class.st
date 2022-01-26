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
AbstractComposedImageAccess >> segmentDataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := (self segmentFileNameWithoutExtension: segmentIndex) , '.data'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentDataFile: segmentIndex fromFile: imageFile 
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentFileNameWithoutExtension: segmentIndex [

	^ 'seg' , segmentIndex asString
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex fromFile: imageFile [

	| segmentDataFileName |
	segmentDataFileName := (self segmentFileNameWithoutExtension: segmentIndex) , '.ston'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	| imageFile |
	imageFile := self imageFile: imageFileName.

	^ self segmentMetadataFile: segmentIndex fromFile: imageFile 
]
