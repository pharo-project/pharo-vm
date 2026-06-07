Class {
	#name : 'VMImageReaderWriter',
	#superclass : 'VMClass',
	#instVars : [
		'spurImageReader',
		'spurImageWriter',
		'composedImageReader',
		'composedImageWriter',
		'formatToUse'
	],
	#classVars : [
		'AutodetectFormat',
		'ComposedFormatDetected',
		'ComposedFormatForced',
		'SpurFormatDetected',
		'SpurFormatForced'
	],
	#category : 'VMMaker-ImageFormat',
	#package : 'VMMaker',
	#tag : 'ImageFormat'
}

{ #category : 'translation' }
VMImageReaderWriter class >> ancilliaryClasses [ 

	^ { 
	AbstractImageAccess. AbstractComposedImageAccess.
	SpurImageReader. SpurImageWriter. ComposedImageReader. ComposedImageWriter }
]

{ #category : 'translation' }
VMImageReaderWriter class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		removeVariable: 'objectMemory';
		removeVariable: 'interpreter';
		removeVariable: 'segmentManager'.
		
	aCCodeGenerator 
		staticallyResolvedPolymorphicReceiver: #spurImageReader to: SpurImageReader; 
		staticallyResolvedPolymorphicReceiver: #spurImageWriter to: SpurImageWriter;
		staticallyResolvedPolymorphicReceiver: #composedImageReader to: ComposedImageReader; 
		staticallyResolvedPolymorphicReceiver: #composedImageWriter to: ComposedImageWriter.
]

{ #category : 'initialization' }
VMImageReaderWriter class >> initialize [

	AutodetectFormat := 0.
	ComposedFormatDetected := 1.
	SpurFormatDetected := 2. 
	ComposedFormatForced := 3.
	SpurFormatForced := 4.
]

{ #category : 'instance creation' }
VMImageReaderWriter class >> newWithMemory: memory andInterpreter: anInterpreter [

	^ self 
		basicNew
		initWithMemory: memory andInterpreter: anInterpreter;
		yourself
]

{ #category : 'format' }
VMImageReaderWriter >> autodetectFormat: aFileName [

	formatToUse = AutodetectFormat 
		ifTrue: [ 
			(self sqImageIsDirectory: aFileName)
				ifTrue: [ 
					self logDebug: 'Composed Image Format detected'.
					formatToUse := ComposedFormatDetected  ]
				ifFalse: [ 
					self logDebug: 'Spur Image Format detected'.
					formatToUse := SpurFormatDetected  ] ]
]

{ #category : 'format' }
VMImageReaderWriter >> hasToUseComposedFormat [

	formatToUse = AutodetectFormat 
		ifTrue: [ self error: 'I couldn''t detect the format before using it' ].
		
	^ formatToUse = ComposedFormatDetected or: [ formatToUse = ComposedFormatForced ] 
]

{ #category : 'initialization' }
VMImageReaderWriter >> initWithMemory: memory andInterpreter: anInterpreter [

	formatToUse := AutodetectFormat.
	
	spurImageReader := SpurImageReader newWithMemory: memory andInterpreter: anInterpreter.
	spurImageWriter := SpurImageWriter newWithMemory: memory andInterpreter: anInterpreter.
	
	composedImageReader := ComposedImageReader newWithMemory: memory andInterpreter: anInterpreter.
	composedImageWriter := ComposedImageWriter newWithMemory: memory andInterpreter: anInterpreter.	
]

{ #category : 'api' }
VMImageReaderWriter >> loadImageFromFile: aFile withHeader: aSpurImageHeaderStruct [

	^ self hasToUseComposedFormat
		ifTrue: [
			composedImageReader
				doLoadImageFromFile: aFile
				withHeader: aSpurImageHeaderStruct ]
		ifFalse: [
			spurImageReader
				doLoadImageFromFile: aFile
				withHeader: aSpurImageHeaderStruct ]
]

{ #category : 'format' }
VMImageReaderWriter >> logDebug: anString [

	<doNotGenerate>
	anString traceCr.
]

{ #category : 'api' }
VMImageReaderWriter >> readImageNamed: imageName [

	<var: #imageName declareC: 'char *imageName'>
	<api>

	self autodetectFormat: imageName.

	self hasToUseComposedFormat
		ifTrue: [ composedImageReader readImageNamed: imageName ]
		ifFalse: [ spurImageReader readImageNamed: imageName ]
]

{ #category : 'format' }
VMImageReaderWriter >> setFormatToUse: aValue [

	formatToUse := aValue
]

{ #category : 'format' }
VMImageReaderWriter >> sqImageIsDirectory: aFileName [

	<doNotGenerate>
	
	^ aFileName asFileReference isDirectory 
]

{ #category : 'accessing' }
VMImageReaderWriter >> useComposedImageFormatAsDefault: aBoolean [ 
	
	aBoolean ifNil: [ ^ self ].
	formatToUse := aBoolean ifTrue: [ ComposedFormatForced ] ifFalse: [ SpurFormatForced ]
]

{ #category : 'testing' }
VMImageReaderWriter >> validateImage: aString [

	<doNotGenerate>

	^ self hasToUseComposedFormat
		ifTrue: [ composedImageReader validateImage: aString ]
		ifFalse: [ spurImageReader validateImage: aString ]
]

{ #category : 'writing' }
VMImageReaderWriter >> writeImageFile: imageFileName fromHeader: header [

	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #header type: #SpurImageHeaderStruct>


	self hasToUseComposedFormat
		  ifTrue: [
			  ^ composedImageWriter
				  writeImageFile: imageFileName
				  fromHeader: header ]
		  ifFalse: [
			  ^ spurImageWriter
				  writeImageFile: imageFileName
				  fromHeader: header ]
]
