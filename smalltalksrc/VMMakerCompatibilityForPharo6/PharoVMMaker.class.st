"
Main entry point to generate the VM code from the command line.
"
Class {
	#name : 'PharoVMMaker',
	#superclass : 'Object',
	#instVars : [
		'outputDirectory',
		'stopOnErrors',
		'generatePlugins',
		'wordSizesToGenerate'
	],
	#category : 'VMMakerCompatibilityForPharo6-CommandLine',
	#package : 'VMMakerCompatibilityForPharo6',
	#tag : 'CommandLine'
}

{ #category : 'defaults' }
PharoVMMaker class >> default32BitsMemoryManagerClass [

	^ Spur32BitCoMemoryManager
]

{ #category : 'defaults' }
PharoVMMaker class >> default64BitsMemoryManagerClass [

	^ Spur64BitCoMemoryManager
]

{ #category : 'defaults' }
PharoVMMaker class >> defaultInterpreterClass [

	^ CoInterpreter
]

{ #category : 'defaults' }
PharoVMMaker class >> defaultMemoryManagerClass [

	^ self default64BitsMemoryManagerClass 
]

{ #category : 'generation' }
PharoVMMaker class >> defaultOutputDirectory [

	^ FileSystem workingDirectory
]

{ #category : 'generation' }
PharoVMMaker class >> generate: anInterpreterClass [

	self
		generate: anInterpreterClass
		outputDirectory: self defaultOutputDirectory
]

{ #category : 'generation' }
PharoVMMaker class >> generate: anInterpreterClass outputDirectory: aDirectory [

	Transcript
		nextPutAll: 'Generating ';
		nextPutAll: anInterpreterClass printString;
		nextPutAll: ' in ';
		nextPutAll: aDirectory printString;
		nextPutAll: '...';
		newLine;
		flush.

	self new
		outputDirectory: aDirectory;
		perform: #generate , anInterpreterClass asSymbol
]

{ #category : 'generation' }
PharoVMMaker class >> on: anInterpreterClass [

	^ self
		  on: anInterpreterClass
		  outputDirectory: self defaultOutputDirectory
]

{ #category : 'generation' }
PharoVMMaker class >> on: anInterpreterClass outputDirectory: aDirectory [

	^ self new
		  outputDirectory: aDirectory;
		  vmMakerOn: anInterpreterClass
]

{ #category : 'generation' }
PharoVMMaker class >> withCoInterpreter [

	^ self on: CoInterpreter
]

{ #category : 'generation' }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager [

	self generate: interpreterClass memoryManager: memoryManager compilerClass: StackToRegisterMappingCogit
]

{ #category : 'generation' }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager compilerClass: compilerClass [

	self generate: interpreterClass memoryManager: memoryManager compilerClass: compilerClass options: #()
]

{ #category : 'generation' }
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
					 #bytecodeTableInitializer. #initializeBytecodeTableForSistaV1} 
					, options
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

{ #category : 'generation' }
PharoVMMaker >> generateCoInterpreter [

	self generates64Bits ifTrue: [self generate: CoInterpreter memoryManager: Spur64BitCoMemoryManager].
	self generates32Bits ifTrue: [ self generate: CoInterpreter memoryManager: Spur32BitCoMemoryManager ].

]

{ #category : 'accessing' }
PharoVMMaker >> generatePlugins [

	^ generatePlugins
]

{ #category : 'accessing' }
PharoVMMaker >> generatePlugins: anObject [

	generatePlugins := anObject
]

{ #category : 'generation' }
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

{ #category : 'generation' }
PharoVMMaker >> generateStackVM [

	self generates64Bits ifTrue: [self generate: StackInterpreter memoryManager: Spur64BitMemoryManager].
	self generates32Bits ifTrue: [ self generate: StackInterpreter memoryManager: Spur32BitMemoryManager ].

]

{ #category : 'testing' }
PharoVMMaker >> generates32Bits [

	^ wordSizesToGenerate includes: 4
]

{ #category : 'testing' }
PharoVMMaker >> generates64Bits [
	
	^ wordSizesToGenerate includes: 8
]

{ #category : 'initialization' }
PharoVMMaker >> initialize [
	super initialize.
	stopOnErrors := false.
	generatePlugins := true.
	wordSizesToGenerate := #(4 8).

]

{ #category : 'initialization' }
PharoVMMaker >> initializeOutputDirectory [

	^ outputDirectory := self class defaultOutputDirectory
]

{ #category : 'accessing' }
PharoVMMaker >> outputDirectory [
	^ outputDirectory ifNil: [ self initializeOutputDirectory ]
]

{ #category : 'accessing' }
PharoVMMaker >> outputDirectory: anObject [
	outputDirectory := anObject asFileReference
]

{ #category : 'utils' }
PharoVMMaker >> platformDirectoryFor: aMemoryManagerClass [ 
	
	^ self outputDirectory / 'generated' / (aMemoryManagerClass wordSize * 8) asString
]

{ #category : 'accessing' }
PharoVMMaker >> stopOnErrors [
	^ stopOnErrors
]

{ #category : 'accessing' }
PharoVMMaker >> stopOnErrors: anObject [
	stopOnErrors := anObject
]

{ #category : 'generation' }
PharoVMMaker >> vmMakerOn: anInterpreterClass [

	^ self
		  vmMakerWith: self class defaultInterpreterClass
		  memoryManager: self class defaultMemoryManagerClass
]

{ #category : 'generation' }
PharoVMMaker >> vmMakerWith: interpreterClass memoryManager: memoryManager [

	| platformDirectory |
	VMMakerConfiguration initializeForPharo.
	platformDirectory := self platformDirectoryFor: memoryManager.

	^ (VMMaker
		   makerFor: interpreterClass
		   and: StackToRegisterMappingCogit
		   with: {
				   #ObjectMemory . memoryManager name .
				   #MULTIPLEBYTECODESETS . true }
		   to: platformDirectory
		   platformDir: platformDirectory
		   including: #(  )
		   configuration: VMMakerConfiguration)
		  stopOnErrors: stopOnErrors;
		  yourself
]

{ #category : 'accessing' }
PharoVMMaker >> wordSizesToGenerate [

	^ wordSizesToGenerate
]

{ #category : 'accessing' }
PharoVMMaker >> wordSizesToGenerate: anObject [

	wordSizesToGenerate := anObject
]
