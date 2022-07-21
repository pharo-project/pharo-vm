"
Main entry point to generate the VM code from the command line.
"
Class {
	#name : #PharoVMMaker,
	#superclass : #Object,
	#instVars : [
		'outputDirectory',
		'stopOnErrors'
	],
	#category : #'VMMakerCompatibilityForPharo6-CommandLine'
}

{ #category : #defaults }
PharoVMMaker class >> default32BitsMemoryManagerClass [

	^ Spur32BitCoMemoryManager
]

{ #category : #defaults }
PharoVMMaker class >> default64BitsMemoryManagerClass [

	^ Spur64BitCoMemoryManager
]

{ #category : #defaults }
PharoVMMaker class >> defaultInterpreterClass [

	^ CoInterpreter
]

{ #category : #defaults }
PharoVMMaker class >> defaultMemoryManagerClass [

	^ self default64BitsMemoryManagerClass 
]

{ #category : #generation }
PharoVMMaker class >> defaultOutputDirectory [

	^ FileSystem workingDirectory
]

{ #category : #generation }
PharoVMMaker class >> generate: anInterpreterClass [

	self
		generate: anInterpreterClass
		outputDirectory: self defaultOutputDirectory
]

{ #category : #generation }
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

{ #category : #generation }
PharoVMMaker class >> on: anInterpreterClass [

	^ self
		  on: anInterpreterClass
		  outputDirectory: self defaultOutputDirectory
]

{ #category : #generation }
PharoVMMaker class >> on: anInterpreterClass outputDirectory: aDirectory [

	^ self new
		  outputDirectory: aDirectory;
		  vmMakerOn: anInterpreterClass
]

{ #category : #generation }
PharoVMMaker class >> withCoInterpreter [

	^ self on: CoInterpreter
]

{ #category : #generation }
PharoVMMaker >> generate: interpreterClass memoryManager: memoryManager [

	| platformDirectory |
	
	Author useAuthor: 'vmMaker' during: [
	
		VMMakerConfiguration initializeForPharo.
		(interpreterClass bindingOf: #COGMTVM) value: false.

		platformDirectory := self platformDirectoryFor: memoryManager.

		[ 
		
		(VMMaker
			makerFor: interpreterClass
			and: StackToRegisterMappingCogit
			with: {#COGMTVM. false.
					#ObjectMemory. memoryManager name.
					#MULTIPLEBYTECODESETS. true.
					#bytecodeTableInitializer. #initializeBytecodeTableForSqueakV3PlusClosuresSistaV1Hybrid}
			to: platformDirectory
			platformDir:platformDirectory
			including: #()
			configuration: VMMakerConfiguration)
				stopOnErrors: stopOnErrors;
				internal: #() external: #(FilePlugin SurfacePlugin FloatArrayPlugin);
				generateInterpreterFile;
				generateCogitFiles;
				generateExternalPlugins] valueSupplyingAnswer:true.]
]

{ #category : #generation }
PharoVMMaker >> generateCoInterpreter [

	self generate: CoInterpreter memoryManager: Spur64BitCoMemoryManager.
	self generate: CoInterpreter memoryManager: Spur32BitCoMemoryManager.	
]

{ #category : #generation }
PharoVMMaker >> generateStackVM [

	self generate: StackInterpreter memoryManager: Spur64BitMemoryManager.
	self generate: StackInterpreter memoryManager: Spur32BitMemoryManager.


]

{ #category : #initialization }
PharoVMMaker >> initialize [
	super initialize.
	stopOnErrors := false
]

{ #category : #initialization }
PharoVMMaker >> initializeOutputDirectory [

	^ outputDirectory := self class defaultOutputDirectory
]

{ #category : #accessing }
PharoVMMaker >> outputDirectory [
	^ outputDirectory ifNil: [ self initializeOutputDirectory ]
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

{ #category : #generation }
PharoVMMaker >> vmMakerOn: anInterpreterClass [

	^ self
		  vmMakerWith: self class defaultInterpreterClass
		  memoryManager: self class defaultMemoryManagerClass
]

{ #category : #generation }
PharoVMMaker >> vmMakerWith: interpreterClass memoryManager: memoryManager [

	| platformDirectory |
	VMMakerConfiguration initializeForPharo.
	(interpreterClass bindingOf: #COGMTVM) value: false.

	platformDirectory := self platformDirectoryFor: memoryManager.


	^ (VMMaker
		   makerFor: interpreterClass
		   and: StackToRegisterMappingCogit
		   with: { 
				   #COGMTVM.
				   false.
				   #ObjectMemory.
				   memoryManager name.
				   #MULTIPLEBYTECODESETS.
				   true.
				   #bytecodeTableInitializer.
				   #initializeBytecodeTableForSqueakV3PlusClosuresSistaV1Hybrid }
		   to: platformDirectory
		   platformDir: platformDirectory
		   including: #(  )
		   configuration: VMMakerConfiguration)
		  stopOnErrors: stopOnErrors;
		  yourself
]
