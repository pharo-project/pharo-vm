Extension { #name : 'VMClass' }

{ #category : '*VMMaker' }
VMClass class >> initializeForPlugins: optionsDictionaryOrArray [
	"Do a default initialization, suitable for generating plugin sources."
	StackInterpreterSimulator
		initializeWithOptions: optionsDictionaryOrArray

]

{ #category : '*VMMaker' }
VMClass class >> initializeMiscConstants [

	"Falsify the `what type of VM is this?' flags that are defined in the various interp.h files.
	 Subclass implementations need to include a super initializeMiscConstants"

	| omc |
	VMBIGENDIAN class. "Mention this for the benefit of CCodeGenerator>>emitCConstantsOn:"
	STACKVM := COGVM := false.


	InitializationOptions ifNil: [ 
		InitializationOptions := Dictionary new ].
	omc := InitializationOptions
		       at: #ObjectMemory
		       ifAbsent: [ self error: 'Please specify an object memory' ].

	InitializationOptions at: #SpurObjectMemory ifAbsentPut: (omc
			 ifNil: [ false ]
			 ifNotNil: [ 
			 (Smalltalk at: omc) includesBehavior: SpurMemoryManager ]). "the new contender"

	"Use ifAbsentPut: so that they will get copied back to the
	 VMMaker's options and dead code will likely be eliminated."
	PharoVM := InitializationOptions at: #PharoVM ifAbsentPut: [ false ].
	FEATURE_FFI := InitializationOptions
		               at: #FEATURE_FFI
		               ifAbsentPut: [ false ].
	FEATURE_THREADED_FFI := InitializationOptions
		                        at: #FEATURE_THREADED_FFI
		                        ifAbsentPut: [ false ].

	SistaVM := InitializationOptions at: #SistaVM ifAbsentPut: [ false ].
	TempVectReadBarrier := InitializationOptions
		                       at: #TempVectReadBarrier
		                       ifAbsentPut: [ false ].
	"Simulation only; on by default..."
	CloneOnGC := InitializationOptions
		             at: #CloneOnGC
		             ifAbsentPut: [ true ].
	CloneOnScavenge := InitializationOptions
		                   at: #CloneOnScavenge
		                   ifAbsentPut: [ true ].

	"These must be set only if specified, not defaulted, because they are set on the command line or in include files."
	InitializationOptions
		at: #VMBIGENDIAN ifPresent: [ :value | VMBIGENDIAN := value ];
		at: #STACKVM ifPresent: [ :value | STACKVM := value ];
		at: #COGVM
		ifPresent: [ :value | COGVM := InitializationOptions at: #COGVM ].

	"consistency checks"
	(TempVectReadBarrier not and: [ 
		 { SpurMemoryManager compactorClass }
		 , SpurMemoryManager compactorClass ancilliaryClasses anySatisfy: [ 
			 :c | c == SpurSelectiveCompactor ] ]) ifTrue: [ 
		self error: 'Selective compactor requires read barrier' ].

	"And not these; they're compile-time"
	IMMUTABILITY := InitializationOptions
		                at: #IMMUTABILITY
		                ifAbsent: [ true ].
	WIN32 := InitializationOptions at: #WIN32 ifAbsent: [false].
	PRIdSQINT := InitializationOptions at: #FormatSqInt ifAbsent: [ 'ld' ]
]

{ #category : '*VMMaker' }
VMClass >> isEndOfLine: aCharacter [

	<inline: true>
	
	^ self 
		cCode: [ aCharacter = 13 or: [ aCharacter = 10 ] ] 
		inSmalltalk: [ Character cr = aCharacter or: [ Character lf = aCharacter ] ]
]
