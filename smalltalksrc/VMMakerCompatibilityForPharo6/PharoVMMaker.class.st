"
Main entry point to generate the VM code from the command line.
"
Class {
	#name : #PharoVMMaker,
	#superclass : #Object,
	#instVars : [
		'outputDirectory',
		'stopOnErrors',
		'generatePlugins',
		'wordSizesToGenerate'
	],
	#category : #'VMMakerCompatibilityForPharo6-CommandLine'
}

{ #category : #generation }
PharoVMMaker class >> generate: aClassName [

	self generate: aClassName outputDirectory: FileSystem workingDirectory
]

{ #category : #generation }
PharoVMMaker class >> generate: aClassName outputDirectory: aDirectory [

	Transcript 
		nextPutAll: 'Generating ';
	 	nextPutAll: aClassName printString;
		nextPutAll: ' in ';
		nextPutAll: aDirectory printString;
		nextPutAll: '...';
		newLine;
		flush.
	
	self new
		outputDirectory: aDirectory;
		perform: #generate , aClassName asSymbol
]

{ #category : #generation }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager [

	self generate: interpreterClass memoryManager: memoryManager compilerClass: StackToRegisterMappingCogit
]

{ #category : #generation }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager compilerClass: compilerClass [

	self generate: interpreterClass memoryManager: memoryManager compilerClass: compilerClass options: #()
]

{ #category : #generation }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager compilerClass: compilerClass options: options [

	| platformDirectory vmmaker |
	
	Author useAuthor: 'vmMaker' during: [
	
		VMMakerConfiguration initializeForPharo.

		platformDirectory := self platformDirectoryFor: memoryManager.

		[ 
		
		vmmaker := VMMaker
			makerFor: interpreterClass
			and: compilerClass
			with: {#ObjectMemory. memoryManager name.
					 #bytecodeTableInitializer. #initializeBytecodeTableForSistaV1} , options
			to: platformDirectory
			platformDir:platformDirectory
			including: #()
			configuration: VMMakerConfiguration.

		vmmaker
				stopOnErrors: stopOnErrors;
				internal: #() external: #(FilePlugin SurfacePlugin FloatArrayPlugin);
				generateInterpreterFile;
				generateCogitFiles.
		generatePlugins ifTrue: [ vmmaker generateExternalPlugins ]] valueSupplyingAnswer:true.]
]

{ #category : #generation }
PharoVMMaker >> generateCoInterpreter [

	self generates64Bits ifTrue: [self generate: CoInterpreter memoryManager: Spur64BitCoMemoryManager].
	self generates32Bits ifTrue: [ self generate: CoInterpreter memoryManager: Spur32BitCoMemoryManager ].

]

{ #category : #accessing }
PharoVMMaker >> generatePlugins [

	^ generatePlugins
]

{ #category : #accessing }
PharoVMMaker >> generatePlugins: anObject [

	generatePlugins := anObject
]

{ #category : #generation }
PharoVMMaker >> generateSistaVM [

	self generates64Bits ifTrue: [	
			self
				generate: CoInterpreter
				memoryManager: Spur64BitCoMemoryManager
				compilerClass: SistaCogit
				options: #( SistaVM true )].
	
	
	self generates32Bits ifTrue: [
			self
				generate: CoInterpreter
				memoryManager: Spur32BitCoMemoryManager
				compilerClass: SistaCogit
				options: #( SistaVM true )].


]

{ #category : #generation }
PharoVMMaker >> generateStackVM [

	self generates64Bits ifTrue: [self generate: StackInterpreter memoryManager: Spur64BitMemoryManager].
	self generates32Bits ifTrue: [ self generate: StackInterpreter memoryManager: Spur32BitMemoryManager ].

]

{ #category : #testing }
PharoVMMaker >> generates32Bits [

	^ wordSizesToGenerate includes: 4
]

{ #category : #testing }
PharoVMMaker >> generates64Bits [
	
	^ wordSizesToGenerate includes: 8
]

{ #category : #accessing }
PharoVMMaker >> initialize [
	super initialize.
	stopOnErrors := false.
	generatePlugins := true.
	wordSizesToGenerate := #(4 8).
]

{ #category : #accessing }
PharoVMMaker >> outputDirectory [
	^ outputDirectory
]

{ #category : #accessing }
PharoVMMaker >> outputDirectory: anObject [
	outputDirectory := anObject asFileReference
]

{ #category : #utils }
PharoVMMaker >> platformDirectoryFor: aMemoryManagerClass [ 
	
	^ self outputDirectory / 'generated' / (aMemoryManagerClass wordSize * 8) asString
]

{ #category : #accessing }
PharoVMMaker >> stopOnErrors [
	^ stopOnErrors
]

{ #category : #accessing }
PharoVMMaker >> stopOnErrors: anObject [
	stopOnErrors := anObject
]

{ #category : #accessing }
PharoVMMaker >> wordSizesToGenerate [

	^ wordSizesToGenerate
]

{ #category : #accessing }
PharoVMMaker >> wordSizesToGenerate: anObject [

	wordSizesToGenerate := anObject
]
