Class {
	#name : #AbstractComposedImageAccess,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fprintf: aStream _: format [ 

	<doNotGenerate>
	^ self fprintf: aStream format: format arguments: { }
]

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fprintf: aStream _: format _: aValue [ 

	<doNotGenerate>
	^ self fprintf: aStream format: format arguments: { aValue }
]

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fprintf: aStream _: format _: aValue _: otherValue [

	<doNotGenerate>
	^ self fprintf: aStream format: format arguments: { aValue. otherValue }
]

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fprintf: aStream format: aFormat arguments: arguments [

	<doNotGenerate>
	| printf |
	printf := PrintfFormatString new setFormat: aFormat.
	
	aStream nextPutAll: (printf
			 printf: arguments;
			 string)
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> headerFile: imageFileName [

	| headerFileName |
	headerFileName := 'header.ston'.

	^ self
		  cCode: [ self vmConcatPath: imageFileName File: headerFileName ]
		  inSmalltalk: [ | imageFile |
			  imageFile := self imageFile: imageFileName.
			  imageFile / headerFileName ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> imageFile: imageFileName [

	<doNotGenerate>
	| imageFile |
	imageFile := imageFileName asFileReference.
	imageFile ensureCreateDirectory.
	
	^ imageFile
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex fromFile: imageFile [

	<doNotGenerate>
	| segmentDataFileName |
	segmentDataFileName := self segmentDataFileName: segmentIndex.
	
	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	^ self
		  cCode: [ | segmentFileName fullSegmentPath |
			  segmentFileName := self segmentDataFileName: segmentIndex.
			  fullSegmentPath := self
				                     vmConcatPath: imageFileName
				                     File: segmentFileName.
			  self free: segmentFileName.
			  fullSegmentPath ]
		  inSmalltalk: [ | imageFile |
			  imageFile := self imageFile: imageFileName.
			  self segmentDataFile: segmentIndex fromFile: imageFile ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFileName: segmentIndex [

	| fileName extension dataFileName |
	fileName := self segmentFileNameWithoutExtension: segmentIndex.
	extension := '.data'.
	dataFileName := self stretch: fileName cat: extension.
	self free: fileName.
	^ dataFileName

]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentFileNameWithoutExtension: segmentIndex [

	^ self stretch: 'seg' cat: segmentIndex asString.
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex fromFile: imageFile [

	<doNotGenerate>
	| segmentDataFileName |
	segmentDataFileName := (self segmentFileNameWithoutExtension: segmentIndex) , '.ston'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	^ self
		  cCode: [ | segmentFileName fullSegmentPath |
			  segmentFileName := self segmentMetadataFileName: segmentIndex.
			  fullSegmentPath := self
				                     vmConcatPath: imageFileName
				                     File: segmentFileName.
			  self free: segmentFileName.
			  fullSegmentPath ]
		  inSmalltalk: [ | imageFile |
			  imageFile := self imageFile: imageFileName.
			  self segmentMetadataFile: segmentIndex fromFile: imageFile ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFileName: segmentIndex [

	| fileName extension metadataFileName |
	fileName := self segmentFileNameWithoutExtension: segmentIndex.
	extension := '.ston'.
	metadataFileName := self stretch: fileName cat: extension.
	self free: fileName.
	^ metadataFileName

]

{ #category : #'string manipulation' }
AbstractComposedImageAccess >> vmConcatPath: dirPath File: fileName [

	| prefix fullPath |
	self flag: #TODO. "implement sprint"
	prefix := self stretch: dirPath cat: '/'.
	fullPath := self stretch: prefix cat: fileName.
	self free: prefix.
	^ fullPath
]
