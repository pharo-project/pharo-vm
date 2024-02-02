Class {
	#name : #VMImageReaderWriter,
	#superclass : #VMClass,
	#instVars : [
		'spurImageReader',
		'spurImageWriter',
		'composedImageReader',
		'composedImageWriter',
		'useComposedAsDefault'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
VMImageReaderWriter class >> ancilliaryClasses [ 

	^ { 
	AbstractImageAccess. AbstractComposedImageAccess.
	SpurImageReader. SpurImageWriter. ComposedImageReader. ComposedImageWriter }
]

{ #category : #translation }
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

{ #category : #'instance creation' }
VMImageReaderWriter class >> newWithMemory: memory andInterpreter: anInterpreter [

	^ self 
		basicNew
		initWithMemory: memory andInterpreter: anInterpreter;
		yourself
]

{ #category : #initialization }
VMImageReaderWriter >> initWithMemory: memory andInterpreter: anInterpreter [

	useComposedAsDefault := false.
	
	spurImageReader := SpurImageReader newWithMemory: memory andInterpreter: anInterpreter.
	spurImageWriter := SpurImageWriter newWithMemory: memory andInterpreter: anInterpreter.
	
	composedImageReader := ComposedImageReader newWithMemory: memory andInterpreter: anInterpreter.
	composedImageWriter := ComposedImageWriter newWithMemory: memory andInterpreter: anInterpreter.	
]

{ #category : #api }
VMImageReaderWriter >> loadImageFromFile: aFile withHeader: aSpurImageHeaderStruct [

	^ useComposedAsDefault
		ifTrue: [
			composedImageReader
				doLoadImageFromFile: aFile
				withHeader: aSpurImageHeaderStruct ]
		ifFalse: [
			spurImageReader
				doLoadImageFromFile: aFile
				withHeader: aSpurImageHeaderStruct ]
]

{ #category : #api }
VMImageReaderWriter >> readImageNamed: imageName [

	<var: #imageName declareC: 'char *imageName'>
	<api>

	useComposedAsDefault
		ifTrue: [ composedImageReader readImageNamed: imageName ]
		ifFalse: [ spurImageReader readImageNamed: imageName ]
]

{ #category : #accessing }
VMImageReaderWriter >> useComposedImageFormatAsDefault: aBoolean [ 
	
	useComposedAsDefault := aBoolean
]

{ #category : #testing }
VMImageReaderWriter >> validateImage: aString [

	^ useComposedAsDefault
		ifTrue: [ composedImageReader validateImage: aString ]
		ifFalse: [ spurImageReader validateImage: aString ]
]

{ #category : #writing }
VMImageReaderWriter >> writeImageFile: imageFileName fromHeader: header [

	<var: #imageFileName declareC: 'char *imageFileName'>
	<var: #header type: #SpurImageHeaderStruct>


	useComposedAsDefault
		  ifTrue: [
			  ^ composedImageWriter
				  writeImageFile: imageFileName
				  fromHeader: header ]
		  ifFalse: [
			  ^ spurImageWriter
				  writeImageFile: imageFileName
				  fromHeader: header ]
]
