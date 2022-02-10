Class {
	#name : #AbstractComposedImageAccess,
	#superclass : #AbstractImageAccess,
	#instVars : [
		'fieldFormat',
		'headFormat'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
AbstractComposedImageAccess class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		addHeaderFile:'<sys/stat.h> /* for e.g. mkdir */'

]

{ #category : #'file operations' }
AbstractComposedImageAccess >> createImageDirectory: imageFileName [

	self
		cCode: [ self mkdir: imageFileName _: 0777 ]
		inSmalltalk: [ imageFileName asFileReference ensureCreateDirectory ]
]

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

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fscanf: file _: format _: varHolder [

	<doNotGenerate>
	^ (format = headFormat)
		  ifTrue: [ 
			  varHolder contents: (file nextLine substrings: ' ') first ];
		  yourself
]

{ #category : #'file primitives' }
AbstractComposedImageAccess >> fscanf: file _: format _: varHolder1 _: varHolder2 [

	<doNotGenerate>
	^ (format = fieldFormat)
		  ifTrue: [ 
			  | dataArray |
			  dataArray := file nextLine substrings: '#:,'.
			  (dataArray first = '}') ifTrue: [ ^false ].
			  varHolder1 contents: dataArray second trimLineSpaces.
			  varHolder2 contents: dataArray third trimLineSpaces asInteger ];
		  yourself
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> headerFileNameinImage: imageFileName into: buffer bufferSize: bufferSize [

	| headerFileName |
	headerFileName := 'header.ston'.

	^ self 
		cCode: [ 
			self snprintf: buffer _: bufferSize _: '%s/%s' _: imageFileName _: headerFileName. 
			buffer ] 
		inSmalltalk: [ imageFileName , '/', headerFileName ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> imageFile: imageFileName [

	<doNotGenerate>
	| imageFile |
	imageFile := imageFileName asFileReference.
	imageFile ensureCreateDirectory.
	
	^ imageFile 
]

{ #category : #initialization }
AbstractComposedImageAccess >> initialize [

	super initialize.
	
	headFormat := '%s {\n'.
	fieldFormat := '\t#%s : %ld'.
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex fromFile: imageFile [

	<doNotGenerate>
	| segmentDataFileName |
	segmentDataFileName := self segmentFileName: segmentIndex withExtension: '.data'.
	
	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].
		
	^ self segmentFileName: segmentIndex withExtension: '.data' inImage: imageFileName into: buffer bufferSize: 255.

]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentFileName: segmentIndex withExtension: extension [


	<doNotGenerate>
	self flag: #TODO. "REMOVE"
	
	^ 'seg', segmentIndex asString , extension
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentFileName: segmentIndex withExtension: extension inImage: imageFileName into: buffer bufferSize: bufferSize [

	^ self 
		cCode: [ 
			self snprintf: buffer _: bufferSize _: '%s/seg%d%s' _: imageFileName _: segmentIndex _: extension. 
			buffer ] 
		inSmalltalk: [ imageFileName , '/seg', segmentIndex asString , extension ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex fromFile: imageFile [

	<doNotGenerate>
	| segmentDataFileName |
	segmentDataFileName := self segmentFileName: segmentIndex withExtension: '.ston'.

	^ imageFile / segmentDataFileName
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].

	^ self segmentFileName: segmentIndex withExtension: '.ston' inImage: imageFileName into: buffer bufferSize: 255. 

]
