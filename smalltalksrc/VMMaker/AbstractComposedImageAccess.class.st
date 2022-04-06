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
		cCode: [ 
			self
				cppIf: ((self defined: #_WIN32) or: [(self defined: #_WIN64)])
				ifTrue: [ self mkdir: imageFileName ]
				ifFalse: [ self mkdir: imageFileName _: 0777 ] ]
		inSmalltalk: [ imageFileName asFileReference ensureCreateDirectory ]
]

{ #category : #'file operations' }
AbstractComposedImageAccess >> existSegment: segmentIndex inImage: imageFileName [

	<var: #buffer declareC: 'char buffer[255]'>
	<var: #sb declareC: 'struct stat sb'>
	| buffer fileName sb |
	self simulationOnly: [ 
		buffer := nil.
		sb := nil ].

	fileName := self
		            segmentFileName: segmentIndex
		            withExtension: '.data'
		            inImage: imageFileName
		            into: buffer
		            bufferSize: 255.

	^ self
		  cCode: [ self stat: fileName _: (self addressOf: sb) ]
		  inSmalltalk: [ fileName asFileReference exists ]
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
			  | line dataArray |
			  line := file nextLine.
			  dataArray := line substrings: '#:, '.
			  dataArray first = '}' ifTrue: [ ^ false ].
			  varHolder1 contents: dataArray second.
			  varHolder2 contents: dataArray third asInteger.
			  file position: file position - 1. "Not consume '\n' "
			  (line last = $,) ifTrue: [ file position: file position - 1 ] "Not consume ',' " ];
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

{ #category : #initialization }
AbstractComposedImageAccess >> initialize [

	super initialize.
	
	headFormat := '%s {\n'.
	fieldFormat := '\t#%s : %lld'.
]

{ #category : #'perm - space' }
AbstractComposedImageAccess >> permSpaceDataFileInImage: imageFileName [ 

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].
	
	^ self permSpaceFileName: 'permSpace.data' inImage: imageFileName into: buffer bufferSize: 255
]

{ #category : #'perm - space' }
AbstractComposedImageAccess >> permSpaceFileName: fileName inImage: imageFileName into: buffer bufferSize: bufferSize [

	^ self 
		cCode: [ 
			self snprintf: buffer _: bufferSize _: '%s/%s' _: imageFileName _: fileName. 
			buffer ] 
		inSmalltalk: [ imageFileName , '/', fileName ].
]

{ #category : #'perm - space' }
AbstractComposedImageAccess >> permSpaceMetadataFileNameInImage: imageFileName [

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].
	
	^ self permSpaceFileName: 'permSpace.ston' inImage: imageFileName into: buffer bufferSize: 255
]

{ #category : #segments }
AbstractComposedImageAccess >> segmentDataFile: segmentIndex inImage: imageFileName [

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].
		
	^ self segmentFileName: segmentIndex withExtension: '.data' inImage: imageFileName into: buffer bufferSize: 255.

]

{ #category : #segments }
AbstractComposedImageAccess >> segmentFileName: segmentIndex withExtension: extension inImage: imageFileName into: buffer bufferSize: bufferSize [

	^ self 
		cCode: [ 
			self snprintf: buffer _: bufferSize _: '%s/seg%d%s' _: imageFileName _: segmentIndex _: extension. 
			buffer ] 
		inSmalltalk: [ imageFileName , '/seg', segmentIndex asString , extension ]
]

{ #category : #segments }
AbstractComposedImageAccess >> segmentMetadataFile: segmentIndex inImage: imageFileName [

	<inline: true>
	<var: #buffer declareC: 'char buffer[255]'>

	| buffer |
		
	self simulationOnly: [ buffer := nil ].

	^ self segmentFileName: segmentIndex withExtension: '.ston' inImage: imageFileName into: buffer bufferSize: 255. 

]
