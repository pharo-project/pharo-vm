Class {
	#name : #VMSpurMemoryManagerTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'memory',
		'interpreter',
		'oldSpaceSize',
		'nextIndex',
		'zeroSizedObjectClassIndex',
		'stackBuilder',
		'rumpCStackSize',
		'wordSize',
		'methodBuilder',
		'edenSize',
		'imageReaderClass',
		'imageWriterClass',
		'environmentBuilder'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMClassIndices',
		'VMObjectIndices'
	],
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #'building suites' }
VMSpurMemoryManagerTest class >> imageFormatParameters [ 

	^ { 
		{ #imageReaderClass -> ComposedImageReader. #imageWriterClass -> ComposedImageWriter }.
		{ #imageReaderClass -> SpurImageReader. #imageWriterClass -> SpurImageWriter }.
	}
]

{ #category : #'building suites' }
VMSpurMemoryManagerTest class >> testParameters [ 

	^ self wordSizeParameters * self imageFormatParameters 
]

{ #category : #'building suites' }
VMSpurMemoryManagerTest class >> wordSizeParameters [ 

	^ ParametrizedTestMatrix new
			forSelector: #wordSize addOptions: { 8 . 4 };
			yourself
]

{ #category : #configuring }
VMSpurMemoryManagerTest >> configureEnvironmentBuilder [

	environmentBuilder
		interpreterClass: self interpreterClass;
		objectMemoryClass: self memoryClass;
		initializationOptions: self initializationOptions;
		wordSize: self wordSize;
		initialCodeSize: self initialCodeSize;
		primitiveTraceLogSize: self primitiveTraceLogSize
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> createActiveProcess [

	| processorOopAssociation processorOop processorListsArray priorities |

	"The ScheduleAssocation should be initialized to a valid Processor object"
	processorOopAssociation := self newObjectWithSlots: 2.
	processorOop := self newObjectWithSlots: 2.
	priorities := 2.
	processorListsArray := self newArrayWithSlots: priorities.
	1 to: priorities do: [ :index |
		"Put an empty linked list in each"
		memory storePointer: index - 1 ofObject: processorListsArray withValue: (self newObjectWithSlots: 2) ].
	
	memory splObj: SchedulerAssociation put: processorOopAssociation.
	memory storePointer: ValueIndex ofObject: processorOopAssociation withValue: processorOop.
	memory storePointer: ProcessListsIndex ofObject: processorOop withValue: processorListsArray.
	
	"Create a new process with the 4 mandatory instance variables and set it as active process"
	memory storePointer: ActiveProcessIndex ofObject: processorOop withValue:  (self newArrayWithSlots: 4).
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> createMethodOopFromPharoMethod: aPharoCompiledMethod [

	| methodOop |
	methodOop := methodBuilder
		             fillFromPharoMethod: aPharoCompiledMethod;
		             buildMethod.
	^ methodOop
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> emptyObjectSize [ 

	"It is the header plus a word, padded to 8 bytes alignment"
	^ self objectHeaderSize + "memory wordSize" 8
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> imageReaderClass [

	^ imageReaderClass
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> imageReaderClass: anObject [

	imageReaderClass := anObject
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> imageWriterClass [

	^ imageWriterClass
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> imageWriterClass: anObject [

	imageWriterClass := anObject
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> initialCodeSize [
	^ 0
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> initializationOptions [

	^ { 
		  #BytesPerWord.
		  self wordSize.
		  #ObjectMemory.
		  self memoryClass name.
		  #ImageReader.
		  imageReaderClass name.
		  #ImageWriter.
		  imageWriterClass name }
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> initializeOldSpaceForFullGC [

	| ourArrayClass |

	memory markStack: memory nilObject.
	memory weaklingStack: memory nilObject.
	
	ourArrayClass := self newArrayWithSlots: 3.
	memory
		storePointer: "InstanceSpecificationIndex" 2
		ofObject: ourArrayClass
		withValue: (memory integerObjectOf: Array format).
	memory ensureBehaviorHash: ourArrayClass.
	
	memory storePointer: 16 ofObject: memory classTableFirstPage withValue: ourArrayClass.
	memory shrinkThreshold: 0.
	memory growHeadroom: 10*1024*1024.
	
	memory flushNewSpace.
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> initializeOldSpaceForScavenger [

	| freeListOop firstClassTablePage |

	"Initialize old space with free list, class table, hidden roots and remembered set to be able to scavenge"
	memory initializeFreeList.

	memory segmentManager collapseSegmentsPostSwizzle.
	memory segmentManager plantBridgeAtTheEndOfMemory.
	memory segmentManager assertBridge.

	memory updateFreeLists.
	memory initializeOldSpaceFirstFree: memory freeOldSpaceStart.

	"Create a nil object required to initialize several fields"
	memory nilObject: (self newOldSpaceObjectWithSlots: 0).
	"Create false object required to initialize several fields"
	memory falseObject: (self newOldSpaceObjectWithSlots: 0).
	"Create true object required to initialize several fields"
	memory trueObject: (self newOldSpaceObjectWithSlots: 0).

	"Initialize Stack"
	memory coInterpreter desiredNumStackPages: 8.
	memory coInterpreter initStackPages.

	"Initialize Special Root objects"
	memory coInterpreter method: memory nilObject.
	memory coInterpreter instructionPointer: memory nilObject.
	memory coInterpreter newMethod: memory nilObject.
	memory coInterpreter profileProcess: memory nilObject.
	memory coInterpreter profileMethod: memory nilObject.
	memory coInterpreter profileSemaphore: memory nilObject.
	memory mournQueue: memory nilObject.
	memory specialObjectsOop: memory nilObject.
		
	freeListOop := memory initializeFreeListInOldSpace: true.
	memory initializeFreeSpacePostLoad: freeListOop.
	memory computeFreeSpacePostSwizzle.
		
	memory getMemoryMap setOldSpaceEnd: memory getMemoryMap oldSpaceEnd + memory bridgeSize.
	
	memory initializeOldSpaceFirstFree: (memory addressAfter: freeListOop).
	
	memory allocateClassTable.
	
	firstClassTablePage := memory fetchPointer: 0 ofObject: memory hiddenRootsObject.
	
	memory scavenger initializeRememberedSet.
	memory scavenger remember: memory hiddenRootsObject.
	memory scavenger remember: firstClassTablePage. 
	memory specialObjectsOop: (self newObjectWithSlots: 60).
	
	memory scavengingGCTenuringIf: 1.
	self deny: memory needGCFlag.
]

{ #category : #running }
VMSpurMemoryManagerTest >> initializeSpecialSelectors [

	| specialSelectorsArrayOop |
	specialSelectorsArrayOop := self newOldSpaceArrayWithSlots:
		                            Smalltalk specialSelectors size.

	Smalltalk specialSelectors withIndexDo: [ :anElement :anIndex | 
		memory
			storePointer: anIndex - 1
			ofObject: specialSelectorsArrayOop
			withValue: (anElement forMemory: memory inMethod: nil) ].

	memory splObj: SpecialSelectors put: specialSelectorsArrayOop
]

{ #category : #accessor }
VMSpurMemoryManagerTest >> interpreter [
	^ interpreter
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> interpreterClass [ 
	^ StackInterpreterSimulatorLSB
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keepObjectInVMVariable1: anOop [
	interpreter newMethod: anOop
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keepObjectInVMVariable2: anOop [
	interpreter profileSemaphore: anOop
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keepObjectInVMVariable3: anOop [
	interpreter profileMethod: anOop
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keptObjectInVMVariable1 [
	^ interpreter newMethod
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keptObjectInVMVariable2 [
	^ interpreter profileSemaphore
]

{ #category : #tests }
VMSpurMemoryManagerTest >> keptObjectInVMVariable3 [
	^ interpreter profileMethod
]

{ #category : #accessor }
VMSpurMemoryManagerTest >> memory [
	^ memory
]

{ #category : #running }
VMSpurMemoryManagerTest >> memoryClass [

	^ self wordSize = 4
		ifTrue: [ Spur32BitMemoryManager ]
		ifFalse: [ Spur64BitMemoryManager ]
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newArrayWithSlots: slots [
	
	^ self newArrayWithSlots: slots classIndex: memory arrayClassIndexPun
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newArrayWithSlots: slots classIndex: anIndex [
	
	^ self newObjectWithSlots: slots format: memory arrayFormat classIndex: anIndex
]

{ #category : #'helpers - classes' }
VMSpurMemoryManagerTest >> newClassInOldSpaceWithSlots: numberOfSlots instSpec: format [
	| newClass formatWithSlots |

	newClass := memory
		allocateSlotsInOldSpace: 3
		format: memory nonIndexablePointerFormat
		classIndex: memory arrayClassIndexPun.
	
	memory storePointer: 0 ofObject: newClass withValue: memory nilObject.
	memory storePointer: 1 ofObject: newClass withValue: memory nilObject.
	
	formatWithSlots := format << 16 + numberOfSlots. 
	memory storePointer: 2 ofObject: newClass withValue: (memory integerObjectOf: formatWithSlots ).
		
	^ newClass	
]

{ #category : #'helpers - methods' }
VMSpurMemoryManagerTest >> newMethodWithSmallContext: isSmall WithArguments: arguments [
	
	| method methodHeader |

	"Create a bytecode compiled method object containing the given literal at the given index"
	
	method := self
		newOldSpaceObjectWithSlots: 0 "# of literals" + 1 "one extra for the header"
		format: (memory compiledMethodFormatForNumBytes: 0)
		classIndex: 16r10.
	methodHeader := (arguments bitShift: 24)
						+ (0 "nTemps" bitShift: 18)
						+ ((isSmall ifTrue: [ 0 "small frame" ] ifFalse: [ 1 "small frame" ]) bitShift: 17)
						+ 0 "number of literaps"
						+ 0 "primitive".
	memory storePointer: 0 ofObject: method withValue: (memory integerObjectOf: methodHeader).

	^ method
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newObjectWithSlots: slots [
	
	^ self newObjectWithSlots: slots classIndex: memory arrayClassIndexPun
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newObjectWithSlots: slots classIndex: anIndex [

	| format |
	format := slots = 0
		          ifTrue: [ memory zeroSlotsNonIndexablePointerFormat ]
		          ifFalse: [ memory nonIndexablePointerFormat ].

	^ self newObjectWithSlots: slots format: format classIndex: anIndex
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newObjectWithSlots: slots format: aFormat classIndex: anIndex [
	
	| oop |
	oop := memory
			allocateSlots: slots
			format: aFormat
			classIndex: anIndex.
	oop ifNotNil: [ memory fillObj: oop numSlots: slots with: memory nilObject ].
	^ oop
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newOldSpaceArrayWithSlots: slots [

	^ self
		  newOldSpaceObjectWithSlots: slots format: memory arrayFormat
		  classIndex: memory arrayClassIndexPun
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newOldSpaceObjectWithSlots: slots [
	
	^ self newOldSpaceObjectWithSlots: slots classIndex: memory arrayClassIndexPun
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newOldSpaceObjectWithSlots: slots classIndex: anIndex [
	
	| format |
	format := slots = 0 ifTrue: [ memory zeroSlotsNonIndexablePointerFormat ] ifFalse: [ memory arrayFormat ].
	
	^ self
		newOldSpaceObjectWithSlots: slots
		format: format
		classIndex: anIndex
]

{ #category : #'helpers - objects' }
VMSpurMemoryManagerTest >> newOldSpaceObjectWithSlots: slots format: aFormat classIndex: anIndex [
	
	| oop |
	oop := memory
			allocateSlotsInOldSpace: slots
			format: aFormat
			classIndex: anIndex.
	oop ifNotNil: [ memory fillObj: oop numSlots: slots with: memory nilObject ].
	^ oop
]

{ #category : #'helpers - frames' }
VMSpurMemoryManagerTest >> newSmallContextReceiver: anOop method: aMethodOop arguments: aCollectionOfArgumentsOop temporaries: aCollectionOfTemporariesOop ip: anIp [

	| newCtx numArgs numTemps |
	newCtx := memory eeInstantiateMethodContextSlots: SmallContextSlots.

	numArgs := aCollectionOfArgumentsOop size.
	numTemps := aCollectionOfTemporariesOop size.

	memory storePointerUnchecked: SenderIndex
		ofObject: newCtx
		withValue: memory nilObject.
		
	memory storePointerUnchecked: InstructionPointerIndex
		ofObject: newCtx
		withValue: (memory integerObjectOf: anIp).

	memory storePointerUnchecked: StackPointerIndex
		ofObject: newCtx
		withValue: (memory integerObjectOf: numArgs + numTemps).
		
	memory storePointerUnchecked: MethodIndex
		ofObject: newCtx
		withValue: aMethodOop.

	memory storePointerUnchecked: ClosureIndex ofObject: newCtx withValue: memory nilObject.

	memory storePointerUnchecked: ReceiverIndex
		ofObject: newCtx
		withValue: anOop.
	
	1 to: numArgs do:
		[:i|
		memory storePointerUnchecked: ReceiverIndex + i
			ofObject: newCtx
			withValue: (aCollectionOfArgumentsOop at: i)].

	1 to: numTemps do:
			[:i|
			memory storePointerUnchecked: ReceiverIndex + i + numArgs
				ofObject: newCtx
				withValue: (aCollectionOfTemporariesOop at: i)].
	
	^ newCtx
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> newString: aString [
	| vmString |
	
	vmString := self
		newOldSpaceObjectWithSlots: aString size
		format: memory firstByteFormat
		classIndex: (memory fetchClassTagOf: memory classString).

	aString
		doWithIndex: [ :char :index | 
			memory
				storeByte: index - 1
				ofObject: vmString
				withValue: char asInteger ].

	^ vmString
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> newZeroSizedObject [
	
	^ memory
		allocateNewSpaceSlots: 0
		format: 0 "zero sized object"
		classIndex: self zeroSizedObjectClassIndex.
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> nextOrdinaryClassIndex [
	
	^ nextIndex
		ifNil: [ nextIndex := memory classTablePageSize ]
		ifNotNil: [ nextIndex := nextIndex + 1 ]
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> objectHeaderSize [

	^ memory baseHeaderSize 
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> primitiveTraceLogSize [
	^ 0
]

{ #category : #running }
VMSpurMemoryManagerTest >> setContextClassIntoClassTable [
	| aClass |
	aClass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: Array instSpec.
	memory setHashBitsOf: aClass to: ClassMethodContextCompactIndex.
	memory
		storePointer: ClassMethodContextCompactIndex
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : #running }
VMSpurMemoryManagerTest >> setMethodClassIntoClassTable [
	| aClass |
	aClass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: CompiledMethod instSpec.
	memory setHashBitsOf: aClass to: 16 "not necessarily ok, this is not enforced by the VM".
	memory
		storePointer: 16 "not necessarily ok, this is not enforced by the VM"
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : #running }
VMSpurMemoryManagerTest >> setUp [
	super setUp.

	environmentBuilder := VMSimulatedEnvironmentBuilder new.
	self configureEnvironmentBuilder.

	environmentBuilder build.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
		
	methodBuilder := VMCompiledCodeBuilder new
		interpreter: interpreter; 
		memory: memory;
		yourself.

	stackBuilder := VMStackBuilder new
		interpreter: interpreter; 
		memory: memory;
		methodBuilder: methodBuilder;
		yourself.
		
	oldSpaceSize := environmentBuilder oldSpaceSize
]

{ #category : #running }
VMSpurMemoryManagerTest >> setUpScheduler [
	
	"The ScheduleAssocation should be initialized to a valid Processor object"
	| processorOopAssociation processorOop processorListArray processorListPriority1 processorListPriority2 activeProcessOop |
	processorOopAssociation := self newObjectWithSlots: 2.
	processorOop := self newObjectWithSlots: 2.
	processorListArray := self newArrayWithSlots: 2.
	
	processorListPriority1 := self newObjectWithSlots: 2.
	processorListPriority2 := self newObjectWithSlots: 2.
	
	memory storePointer: 0 ofObject: processorListArray withValue: processorListPriority1. 
	memory storePointer: 1 ofObject: processorListArray withValue: processorListPriority2.
	
	memory splObj: SchedulerAssociation put: processorOopAssociation.
	memory storePointer: ValueIndex ofObject: processorOopAssociation withValue: processorOop.
	memory storePointer: ProcessListsIndex ofObject: processorOop withValue: processorListArray.
	memory lastHash: 1.
	
	activeProcessOop := self newObjectWithSlots: 4 "Creates the active process".
	memory 
		storePointer: PriorityIndex 
		ofObject: activeProcessOop 
		withValue: (memory integerObjectOf: 0).
	
	memory memoryActiveProcess: activeProcessOop.
]

{ #category : #running }
VMSpurMemoryManagerTest >> setUpUsingImage [
	"/!\ Only runnable with a wordsize equals to your image's (needs disabling parametizing of wordsize) /!\"
	
	"This is an alternate setUp using an image to correctly initialize memory/interpreter.
	Currently not used by default, as some tests still fails, but is usable.
	For example, we could test that all test are working on both a specific setup, and image load one.
	Or we could design tests using the image setUp, which should have everything ready to use, and do the specific on after, to refine the requirements of a setUp for a test."
	super setUp.
	interpreter := self newInterpreter 
		pluginList: { }.
		
	"You currently have to setup the path by hand, I do not rememeber/know how to get the directory from a repository, to do a correct relative path
	Sorry :3"
	interpreter openOn: 'YourImageHere.image'.
	interpreter initStackPages.
	interpreter loadInitialContext.
		
	oldSpaceSize := memory oldSpaceSize.
	
	methodBuilder := VMCompiledCodeBuilder new
		interpreter: interpreter; 
		memory: memory;
		yourself.

	stackBuilder := VMStackBuilder new
		interpreter: interpreter; 
		memory: memory;
		methodBuilder: methodBuilder;
		yourself.
		
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> sizeOfObjectWithSlots: slots [

	^ self objectHeaderSize + ((slots min: 1 "at least one for the forwarder pointer") * memory wordSize "bytes")
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> wordSize [
	
	^ wordSize ifNil: [ 8 ]
]

{ #category : #accessing }
VMSpurMemoryManagerTest >> wordSize: aWordSize [

	wordSize := aWordSize
]

{ #category : #helpers }
VMSpurMemoryManagerTest >> zeroSizedObjectClassIndex [

	^ zeroSizedObjectClassIndex ifNil: [ self nextOrdinaryClassIndex ]
]
