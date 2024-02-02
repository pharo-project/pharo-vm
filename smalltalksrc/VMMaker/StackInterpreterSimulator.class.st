"
This class defines basic memory access and primitive simulation so that the StackInterpreter can run simulated in the Squeak environment.  It also defines a number of handy object viewing methods to facilitate pawing around in the object memory.

To see the thing actually run, you could (after backing up this image and changes), execute

	(StackInterpreterSimulator new openOn: Smalltalk imageName) test

	((StackInterpreterSimulator newWithOptions: #(NewspeakVM true MULTIPLEBYTECODESETS true))
		openOn: 'ns101.image') test

and be patient both to wait for things to happen, and to accept various things that may go wrong depending on how large or unusual your image may be.  We usually do this with a small and simple benchmark image.

Here's an example of what Eliot uses to launch the simulator in a window.  The bottom-right window has a menu packed with useful stuff:

| vm |
vm := StackInterpreterSimulator newWithOptions: #().
vm openOn: '/Users/eliot/Squeak/Squeak4.4/trunk44.image'.
vm setBreakSelector: #&.
vm openAsMorph; run
"
Class {
	#name : #StackInterpreterSimulator,
	#superclass : #StackInterpreterPrimitives,
	#traits : 'TVMSimulator',
	#classTraits : 'TVMSimulator classTrait',
	#instVars : [
		'parent',
		'bootstrapping',
		'byteCount',
		'breakCount',
		'sendCount',
		'lookupCount',
		'printSends',
		'printReturns',
		'traceOn',
		'myBitBlt',
		'filesOpen',
		'imageName',
		'pluginList',
		'mappedPluginEntries',
		'quitBlock',
		'transcript',
		'eventTransformer',
		'printFrameAtEachStep',
		'printBytecodeAtEachStep',
		'systemAttributes',
		'startMicroseconds',
		'lastYieldMicroseconds',
		'externalSemaphoreSignalRequests',
		'externalSemaphoreSignalResponses',
		'extSemTabSize',
		'atEachStepBlock',
		'disableBooleanCheat',
		'performFilters',
		'eventQueue',
		'assertVEPAES',
		'primTraceLog'
	],
	#category : #'VMMaker-InterpreterSimulation'
}

{ #category : #'class initialization' }
StackInterpreterSimulator class >> initializeWithOptions: optionsDictionaryOrArray objectMemoryClass: objectMemoryClassOrNil [
	"The relevant ObjectMemory and Interpreter classes must be initialized in order.
	 This happens notionally every time we start the simulator,
	 but in fact happens when ever we instantiate a simulator."
	InitializationOptions := optionsDictionaryOrArray isArray
							ifTrue: [Dictionary newFromPairs: optionsDictionaryOrArray]
							ifFalse: [optionsDictionaryOrArray].

	(objectMemoryClassOrNil ifNil: [self objectMemoryClass])
		initializeWithOptions: InitializationOptions.

	self initializeWithOptions: InitializationOptions
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> isNonArgumentImplicitReceiverVariableName: aName [

	^ (self localSlots collect: [ :e | e name ]) includes: aName

]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> new [
	^self onObjectMemory: nil options: #()
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> newBasicWithOptions: optionsDictionaryOrArray [

	^ self
		  onObjectMemory: nil
		  options: optionsDictionaryOrArray
		  initializer: [ :interpreter | interpreter basicInitialize ]
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> newWithOptions: optionsDictionaryOrArray [
	^self onObjectMemory: nil options: optionsDictionaryOrArray
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> onObjectMemory: anObjectMemory [
	^self onObjectMemory: anObjectMemory options: #()
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> onObjectMemory: anObjectMemory options: optionsDictionaryOrArray [

	^ self
		  onObjectMemory: anObjectMemory
		  options: optionsDictionaryOrArray
		  initializer: [ :interpreter | interpreter initialize ]
]

{ #category : #'instance creation' }
StackInterpreterSimulator class >> onObjectMemory: anObjectMemory options: optionsDictionaryOrArray initializer: initializer [
	| simulatorClass |
	^self == StackInterpreterSimulator
		ifTrue:
			[simulatorClass := SmalltalkImage current endianness == #big
								ifTrue: [self notYetImplemented"StackInterpreterSimulatorMSB"]
								ifFalse: [StackInterpreterSimulatorLSB].
			simulatorClass initializeWithOptions: optionsDictionaryOrArray
				objectMemoryClass: (anObjectMemory ifNotNil: [anObjectMemory class]).
			 simulatorClass
				onObjectMemory: (anObjectMemory ifNil:
										[self objectMemoryClass simulatorClass new])
				options: optionsDictionaryOrArray]
		ifFalse: [initializer value: (super basicNew objectMemory: anObjectMemory)]
]

{ #category : #'debug support' }
StackInterpreterSimulator >> allObjectsSelect: objBlock [
	"self allObjectsSelect: [:oop | (self baseHeader: oop) = 1234]"

	| selected |
	selected := OrderedCollection new.
	objectMemory allObjectsDo:
		[:obj|
		(objBlock value: obj) ifTrue: [selected addLast: obj]].
	^selected
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> argumentCount: n [
	argumentCount := n
]

{ #category : #'debug support' }
StackInterpreterSimulator >> assertValidExecutionPointers [
	assertVEPAES ifTrue:
		[super assertValidExecutionPointers]
]

{ #category : #accessing }
StackInterpreterSimulator >> assertValidExecutionPointersAtEachStep [
	^assertVEPAES
]

{ #category : #accessing }
StackInterpreterSimulator >> assertValidExecutionPointersAtEachStep: aBoolean [
	assertVEPAES := aBoolean
]

{ #category : #testing }
StackInterpreterSimulator >> atEachStepBlock: aBlock [
	atEachStepBlock := aBlock
]

{ #category : #initialization }
StackInterpreterSimulator >> basicInitialize [
	"Initialize the StackInterpreterSimulator when running the interpreter
	 inside Smalltalk. The primary responsibility of this method is to allocate
	 Smalltalk Arrays for variables that will be declared as statically-allocated
	 global arrays in the translated code."
	super initialize.

	bootstrapping := false.
	transcript := Transcript.

	objectMemory ifNil:
		[objectMemory := self class objectMemoryClass simulatorClass new].
	objectMemory coInterpreter: self.

	self assert: ConstMinusOne = (objectMemory integerObjectOf: -1).

	methodCache := Array new: MethodCacheSize.
	atCache := Array new: AtCacheTotalSize.
	self flushMethodCache.
	gcSemaphoreIndex := 0.
	externalSemaphoreSignalRequests := externalSemaphoreSignalResponses := #().
	externalPrimitiveTable := CArrayAccessor on: (Array
		new: MaxExternalPrimitiveTableSize
		withAll: 0).
	externalPrimitiveTableFirstFreeIndex := 0.
	primitiveTable := self class primitiveTable copy.
	desiredNumStackPages := desiredEdenBytes := 0.
	"This is initialized on loading the image, but convenient for testing stack page values..."
	numStackPages := self defaultNumStackPages. 
	startMicroseconds := lastYieldMicroseconds := self ioUTCStartMicroseconds.

	"initialize InterpreterSimulator variables used for debugging"
	byteCount := sendCount := lookupCount := 0.
	quitBlock := [^self close].
	traceOn := true.
	printSends := printReturns := printFrameAtEachStep := printBytecodeAtEachStep := false.
	myBitBlt := BitBltSimulator new setInterpreter: self.
	eventQueue := SharedQueue new.
	suppressHeartbeatFlag := false.
	systemAttributes := Dictionary new.
	extSemTabSize := 256.
	disableBooleanCheat := false.
	assertVEPAES := false. "a flag so the assertValidExecutionPointers can be disabled for simulation speed and enabled when necessary."
	
	"This will be overriden when calling initializePluginEntries"
	mappedPluginEntries := OrderedCollection new.
	
	imageReaderWriter := VMImageReaderWriter newWithMemory: objectMemory andInterpreter: self.

]

{ #category : #utilities }
StackInterpreterSimulator >> booleanCheat: cond [
	disableBooleanCheat
		ifTrue: [self pop: 2
					thenPush: (cond
								ifTrue: [objectMemory trueObject]
								ifFalse: [objectMemory falseObject]).
				self fetchNextBytecode]
		ifFalse: [super booleanCheat: cond]
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> bootstrapping [
	^bootstrapping
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> bootstrapping: aBoolean [
	bootstrapping := aBoolean.
	objectMemory ifNotNil:
		[objectMemory bootstrapping: aBoolean]
]

{ #category : #accessing }
StackInterpreterSimulator >> breakCount [
	^breakCount
]

{ #category : #'memory access' }
StackInterpreterSimulator >> byteAt: byteAddress [
	"This is really only for the C library simulations memcpy:_:_: et al in VMClass.
	 Use objectMemory byteAt: directly where possible."
	^objectMemory byteAt: byteAddress
]

{ #category : #'memory access' }
StackInterpreterSimulator >> byteAt: byteAddress put: byte [
	self deprecated.
	^objectMemory byteAt: byteAddress put: byte
]

{ #category : #'debug support' }
StackInterpreterSimulator >> byteCount [
	"So you can call this from temp debug statements in, eg, Interpreter, such as
	self byteCount = 12661 ifTrue: [self halt].
	"

	^ byteCount
]

{ #category : #UI }
StackInterpreterSimulator >> byteCountText [
	^ byteCount asStringWithCommas asText
]

{ #category : #'indexing primitives' }
StackInterpreterSimulator >> bytecodePrimAtPut [
	"self halt."
	^super bytecodePrimAtPut
]

{ #category : #'translation support' }
StackInterpreterSimulator >> cCoerceSimple: value to: cTypeString [
	"Type coercion for translation only; just return the value when running in Smalltalk."

	^value
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> callExternalPrimitive: mapIndex [

	| entry |
	entry := self pluginEntryFor: mapIndex.
	"Spur needs the primitiveFunctionPointer to be set correctly
	 for accurate following of forwarders on primitive failure."
	primitiveFunctionPointer := entry at: 2.
	^ (entry at: 1) perform: (entry at: 2)
]

{ #category : #'object memory support' }
StackInterpreterSimulator >> checkStackIntegrity [
	"Override to deal with incomplete initialization."
	stackPages ifNil: [^true].
	^super checkStackIntegrity
]

{ #category : #'debug support' }
StackInterpreterSimulator >> classAndSelectorOfMethod: meth forReceiver: rcvr [
	| mClass dict length methodArray |
	mClass := objectMemory fetchClassOf: rcvr.
	[dict := objectMemory fetchPointer: MethodDictionaryIndex ofObject: mClass.
	length := objectMemory numSlotsOf: dict.
	methodArray := objectMemory fetchPointer: MethodArrayIndex ofObject: dict.
	0 to: length-SelectorStart-1 do: 
		[:index | 
		meth = (objectMemory fetchPointer: index ofObject: methodArray) 
			ifTrue: [^ Array
				with: mClass
				with: (objectMemory fetchPointer: index + SelectorStart ofObject: dict)]].
	mClass := self superclassOf: mClass.
	mClass = objectMemory nilObject]
		whileFalse.
	^ Array
		with: (objectMemory fetchClassOf: rcvr)
		with: (objectMemory splObj: SelectorDoesNotUnderstand)
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> classNameOf: aClass Is: className [
	"Check if aClass' name is className"
	| name |
	(objectMemory lengthOf: aClass) <= classNameIndex ifTrue:
		[^false]. "Not a class but maybe behavior" 
	name := objectMemory fetchPointer: classNameIndex ofObject: aClass.
	(objectMemory isBytes: name) ifFalse:
		[^false].
	^ className = (self stringOf: name)
]

{ #category : #'I/O primitives' }
StackInterpreterSimulator >> clipboardRead: sz Into: actualAddress At: zeroBaseIndex [
	| str |
	str := Clipboard clipboardText.
	1 to: sz do:
		[:i | objectMemory byteAt: actualAddress + zeroBaseIndex + i - 1 put: (str at: i) asciiValue]
]

{ #category : #'I/O primitives' }
StackInterpreterSimulator >> clipboardSize [

	^ Clipboard clipboardText size
]

{ #category : #'debug support' }
StackInterpreterSimulator >> cloneSimulation [

	| savedAtEachStepBlock savedQuitBlock savedTranscript |
	savedAtEachStepBlock := atEachStepBlock.
	atEachStepBlock := nil.
	savedQuitBlock := quitBlock.
	quitBlock := nil.
	savedTranscript := transcript.
	transcript := nil.

	^ [ 
	  | theClone |
	  Smalltalk garbageCollect.
	  theClone := self veryDeepCopy.
	  theClone
		  parent: self;
		  transcript: Transcript.
	  theClone objectMemory parent: objectMemory.
	  theClone ] ensure: [ 
		  atEachStepBlock := savedAtEachStepBlock.
		  quitBlock := savedQuitBlock.
		  transcript := savedTranscript ]
]

{ #category : #initialization }
StackInterpreterSimulator >> close [  "close any files that ST may have opened, etc"
	pluginList do: [:assoc| | plugin | plugin := assoc value. plugin ~~ self ifTrue: [plugin close]]
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> codeGeneratorToComputeAccessorDepth [

	^ codeGeneratorToComputeAccessorDepth ifNil: [
		^(VMMaker new
			vmmakerConfiguration: VMMakerConfiguration;
			buildCodeGeneratorForInterpreter: self class primitivesClass
			includeAPIMethods: false
			initializeClasses: false)
				logger: self transcript;
				yourself ]
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> cogit [
	"We don't have a cogit; try and get by on our own devices."
	^self
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> copyBits [

	^ myBitBlt copyBits
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> cr [

	traceOn ifTrue: [ transcript cr; flush ].
]

{ #category : #accessing }
StackInterpreterSimulator >> currentBytecode: anInteger [ 
	currentBytecode := anInteger
]

{ #category : #UI }
StackInterpreterSimulator >> desiredDisplayExtent [
	^(savedWindowSize
		ifNil: [640@480]
		ifNotNil: [savedWindowSize >> 16 @ (savedWindowSize bitAnd: 16rFFFF)])
			min: Display extent * 2 // 3
]

{ #category : #initialization }
StackInterpreterSimulator >> desiredEdenBytes: anInteger [
	desiredEdenBytes := anInteger
]

{ #category : #initialization }
StackInterpreterSimulator >> desiredNumStackPages: anInteger [
	desiredNumStackPages := anInteger
]

{ #category : #testing }
StackInterpreterSimulator >> disableBooleanCheat: aBoolean [
	disableBooleanCheat := aBoolean
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> dispatchCurrentBytecode [
	self dispatchOn: currentBytecode in: BytecodeTable.
]

{ #category : #'plugin primitive support' }
StackInterpreterSimulator >> dispatchMappedPluginEntry: n [ 
	^(mappedPluginEntries at: n) first
		perform: (mappedPluginEntries at: n) second
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> dispatchOn: anInteger in: selectorArray [
	"Simulate a case statement via selector table lookup.
	The given integer must be between 0 and selectorArray size-1, inclusive.
	For speed, no range test is done, since it is done by the at: operation.
	Note that, unlike many other arrays used in the Interpreter, this method expect NO CArrayAccessor wrapping - it would duplicate the +1. Maybe this would be better updated to make it all uniform"
	self perform: (selectorArray at: (anInteger + 1)).
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> divorceFrame: theFP andContext: ctxt [
	"(theFP = -208 or: [ctxt = 22189568]) ifTrue:
		[self halt]."
	^super divorceFrame: theFP andContext: ctxt
]

{ #category : #'process primitive support' }
StackInterpreterSimulator >> doSignalExternalSemaphores: minTableSize [
	"This is a non-thread-safe simulation.  See platforms/Cross/vm/sqExternalSemaphores.c
	 for the real code.  For the benefit of the SocketPluginSimulator, do a yield every 100
	 virtual microseconds."
	| now switched |
	now := self ioUTCMicroseconds.
	now - lastYieldMicroseconds >= 100 ifTrue:
		[lastYieldMicroseconds := now.
		 Processor yield].

	switched := false.
	1 to: (minTableSize min: externalSemaphoreSignalRequests size) do:
		[:i| | responses |
		responses := externalSemaphoreSignalResponses at: i.
		[responses < (externalSemaphoreSignalRequests at: i)] whileTrue:
			[(self doSignalSemaphoreWithIndex: i) ifTrue:
				[switched := true].
			 externalSemaphoreSignalResponses at: i put: (responses := responses + 1)]].
	^switched
]

{ #category : #'error handling' }
StackInterpreterSimulator >> doesNotUnderstand: aMessage [
	"If this is a doit and the objectMemory understands, pass it on."
	(thisContext findContextSuchThat: [:ctxt| ctxt selector == #evaluate:in:to:notifying:ifFail:logged:]) ifNotNil:
		[(objectMemory class whichClassIncludesSelector: aMessage selector) ifNotNil:
			[:implementingClass|
			(implementingClass inheritsFrom: Object) ifTrue: "i.e. VMClass and below"
				[thisContext sender selector ~~ #DoIt ifTrue:
					[Transcript nextPutAll: 'warning: redirecting ', aMessage selector, ' in ', thisContext sender printString, ' to objectMemory'; cr; flush].
				 aMessage lookupClass: nil.
				^aMessage sentTo: objectMemory]]].
	^super doesNotUnderstand: aMessage
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> drawLoopX: xDelta Y: yDelta [

	^ myBitBlt drawLoopX: xDelta Y: yDelta
]

{ #category : #'debug support' }
StackInterpreterSimulator >> dumpMethodHeader: hdr [
	^ String streamContents:
		[:strm |
		strm nextPutAll: '<nArgs=', ((hdr >> 25) bitAnd: 16r1F) printString , '>'.
		strm nextPutAll: '<nTemps=', ((hdr >> 19) bitAnd: 16r3F) printString , '>'.
		strm nextPutAll: '<lgCtxt=', ((hdr >> 18) bitAnd: 16r1) printString , '>'.
		strm nextPutAll: '<nLits=', ((hdr >> 10) bitAnd: 16rFF) printString , '>'.
		strm nextPutAll: '<prim=', ((hdr >> 1) bitAnd: 16r1FF) printString , '>'.
		]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> elementsPerPrintOopLine [
	^4
]

{ #category : #'compiled methods' }
StackInterpreterSimulator >> endPCOf: aMethod [
	"Determine the endPC of a method in the heap using interpretation that looks for returns and uses branches to skip intervening bytecodes."
	| pc end farthestContinuation prim encoderClass inst is |
	(prim := self primitiveIndexOf: aMethod) > 0 ifTrue:
		[(self isQuickPrimitiveIndex: prim) ifTrue:
			[^(self startPCOfMethod: aMethod) - 1]].
	encoderClass := self encoderClassForHeader: (objectMemory methodHeaderOf: aMethod).
	is := (InstructionStream
			on: (VMCompiledMethodProxy new
					for: aMethod
					coInterpreter: self
					objectMemory: objectMemory)).
	pc := farthestContinuation := self startPCOfMethod: aMethod.
	end := objectMemory numBytesOf: aMethod.
	is pc: pc + 1.
	[pc <= end] whileTrue:
		[inst := encoderClass interpretNextInstructionFor: MessageCatcher new in: is.
		 inst selector
			caseOf: {
				 [#pushClosureCopyNumCopiedValues:numArgs:blockSize:]	
											->	[is pc: is pc + inst arguments last.
												 farthestContinuation := farthestContinuation max: pc].
				 [#jump:]					->	[farthestContinuation := farthestContinuation max: pc + inst arguments first].
				 [#jump:if:]					->	[farthestContinuation := farthestContinuation max: pc + inst arguments first].
				 [#methodReturnConstant:]	->	[pc >= farthestContinuation ifTrue: [end := pc]].
				 [#methodReturnReceiver]	->	[pc >= farthestContinuation ifTrue: [end := pc]].
				 [#methodReturnTop]		->	[pc >= farthestContinuation ifTrue: [end := pc]].
				"This is for CompiledBlock/FullBlockClosure.  Since the response to pushClosure... above
				 skips over all block bytecoes, we will only see a blockReturnTop if it is at the top level,
				 and so it must be a blockReturnTop in a CompiledBlock for a FullBlockClosure."
				 [#blockReturnTop]			->	[pc >= farthestContinuation ifTrue: [end := pc]].
				 [#branchIfInstanceOf:distance:]
											->	[farthestContinuation := farthestContinuation max: pc + inst arguments last].
				 [#branchIfNotInstanceOf:distance:]
											->	[farthestContinuation := farthestContinuation max: pc + inst arguments last] }
			otherwise: [].
		 pc := is pc - 1].
	^end
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> fetchByte [
	^objectMemory byteAt: (instructionPointer := instructionPointer + 1).
]

{ #category : #'control primitives' }
StackInterpreterSimulator >> filterPerformOf: selector to: receiver [
	"This is to allow simulator to filter start-up items to avoid as-yet unsimulatable plugins."
	performFilters ifNil: [^false].
	(performFilters at: (self shortPrint: receiver) ifAbsent: []) ifNotNil:
		[:messages|
		^messages includes: (self stringOf: selector)].
	^false
]

{ #category : #'memory access' }
StackInterpreterSimulator >> firstIndexableField: oop [
	"This is in ObjectMemory and overridden in the obj mem simulators"
	self shouldNotImplement
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> flush [
	traceOn ifTrue: [transcript flush]
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> flushExternalPrimitives [
	self initializePluginEntries.
	super flushExternalPrimitives
]

{ #category : #'control primitives' }
StackInterpreterSimulator >> forShortPrintString: shortPrintString filterPerformMessages: aCollection [
	performFilters ifNil:
		[performFilters := Dictionary new].
	performFilters at: shortPrintString put: aCollection
]

{ #category : #'frame access' }
StackInterpreterSimulator >> frameOfMarriedContext: aContext [ 
	| senderOop |
	senderOop := objectMemory fetchPointer: SenderIndex ofObject: aContext.
	self assert: (objectMemory isIntegerObject: senderOop).
	^self withoutSmallIntegerTags: senderOop
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> framePointer [
	^framePointer
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> functionPointerFor: primIndex inClass: lookupClass [
	"Override Interpreter to handle the external primitives caching.  See also
	 internalExecuteNewMethod."

	^(primIndex between: 1 and: MaxPrimitiveIndex)
		ifTrue: [primitiveTable at: primIndex + 1]
		ifFalse: [0]
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> getErrorObjectFromPrimFailCode [
	(primFailCode > 1 and: [(#(primitiveNew primitiveNewWithArg primitiveFetchNextMourner primitiveAdoptInstance) includes: primitiveFunctionPointer) not]) ifTrue: [self halt].
	^super getErrorObjectFromPrimFailCode
]

{ #category : #'memory access' }
StackInterpreterSimulator >> halfWordHighInLong32: long32 [
	^self subclassResponsibility
]

{ #category : #'memory access' }
StackInterpreterSimulator >> halfWordLowInLong32: long32 [
	^self subclassResponsibility
]

{ #category : #'debug support' }
StackInterpreterSimulator >> headerStart: oop [

	^ (objectMemory extraHeaderBytes: oop) negated
]

{ #category : #'image save/restore' }
StackInterpreterSimulator >> imageName [
	^imageName
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> imageName: aString [
	imageName := aString
]

{ #category : #'file primitives' }
StackInterpreterSimulator >> imageNameGet: p Length: sz [
	1 to: sz  do:
		[:i |
		objectMemory
			byteAt:  p + i - 1
			put: (imageName at: i) asInteger]
]

{ #category : #'file primitives' }
StackInterpreterSimulator >> imageNamePut: p Length: sz [

	| newName |
	newName := ByteString new: sz.
	1 to: sz do: [ :i | 
		newName
			at: i
			put: (Character value: (objectMemory byteAt: p + i - 1)) ].
	imageName := newName
]

{ #category : #'file primitives' }
StackInterpreterSimulator >> imageNameSize [
	^imageName size
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> incrementByteCount [
	(byteCount := byteCount + 1) = breakCount ifTrue:
		[ self halt: 'breakCount reached' ].
	byteCount \\ 1000 = 0 ifTrue:
		[ self forceInterruptCheck ]
]

{ #category : #initialization }
StackInterpreterSimulator >> initialize [
	"Initialize the StackInterpreterSimulator when running the interpreter
	 inside Smalltalk. The primary responsibility of this method is to allocate
	 Smalltalk Arrays for variables that will be declared as statically-allocated
	 global arrays in the translated code."
	self basicInitialize.	
	self initializePluginEntries.
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> initializePluginEntries [

	mappedPluginEntries := OrderedCollection new.
	primitiveAccessorDepthTable := Array new: primitiveTable size.
	pluginList := {  }.
	self loadNewPlugin: ''
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> insufficientMemorySpecifiedError [
	self error: 'Insufficient memory for this image'
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> interpret [

	"This is the main interpreter loop. It normally loops forever, fetching and executing bytecodes.
	 When running in the context of a web browser plugin VM, however, it must return control to the
	 web browser periodically. This should done only when the state of the currently running Squeak
	 thread is safely stored in the object heap. Since this is the case at the moment that a check for
	 interrupts is performed, that is when we return to the browser if it is time to do so.  Interrupt
	 checks happen quite frequently.

	Override for simulation to insert bytecode breakpoint support."

	"If stacklimit is zero then the stack pages have not been initialized."

	<inline: false>
	stackLimit = 0 ifTrue: [ ^ self initStackPagesAndInterpret ].
	self initExtensions.
	self fetchNextBytecode.
	[ true ] whileTrue: [
		self assertValidExecutionPointers.
		atEachStepBlock value. "N.B. may be nil"
		self dispatchCurrentBytecode.
		self incrementByteCount ].
	instructionPointer := instructionPointer - 1.  "undo the pre-increment of IP before returning"
	^ nil
]

{ #category : #'stack pages' }
StackInterpreterSimulator >> interpreterAllocationReserveBytes [
	^bootstrapping
		ifTrue: [0]
		ifFalse: [super interpreterAllocationReserveBytes]
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> invalidCompactClassError: name [
	self error: 'Class ', name, ' does not have the required compact class index'
]

{ #category : #security }
StackInterpreterSimulator >> ioCanRenameImage [
	^true
]

{ #category : #security }
StackInterpreterSimulator >> ioCanWriteImage [
	^true
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> ioExit [

	quitBlock value  "Cause return from #test"
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> ioExitWithErrorCode: ec [

	quitBlock value  "Cause return from #test"
]

{ #category : #'process primitive support' }
StackInterpreterSimulator >> ioGetMaxExtSemTableSize [
	^extSemTabSize
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioHeartbeatMilliseconds [
	^1
]

{ #category : #initialization }
StackInterpreterSimulator >> ioInitHeartbeat [
	"No-op in the simulator.  We cause a poll every 1000 bytecodes instead."
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> ioLoadFunction: functionString From: pluginString [
	"Load and return the requested function from a module"
	| firstTime plugin fnSymbol |
	firstTime := false.
	fnSymbol := functionString asSymbol.
	transcript
		cr;
		show: '(', byteCount printString, ') Looking for ', functionString, ' in ',
				(pluginString isEmpty ifTrue: ['vm'] ifFalse: [pluginString]).
	(breakSelector notNil
	 and: [(pluginString size = breakSelector size
			and: [(self strncmp: pluginString _: breakSelector _: pluginString size) = 0])
		or: [functionString size = breakSelector size
			and: [(self strncmp: functionString _: breakSelector _: functionString size) = 0]]]) ifTrue:
		[self halt: pluginString, '>>', functionString].
	plugin := pluginList 
				detect: [:any| any key = pluginString asString]
				ifNone:
					[firstTime := true.
					 self loadNewPlugin: pluginString].
	plugin ifNil:
		[firstTime ifTrue: [transcript cr; show: '... FAILED; no plugin found'].
		 ^0].
	plugin := plugin value.
	mappedPluginEntries withIndexDo:
		[:pluginAndName :index|
		((pluginAndName at: 1) == plugin 
		and:[(pluginAndName at: 2) == fnSymbol]) ifTrue:
			[^index]].
	(plugin respondsTo: fnSymbol) ifFalse:
		[firstTime ifTrue: [transcript cr; show: '... FAILED; primitive not in plugin'].
		 ^0].
	mappedPluginEntries addLast: { plugin. fnSymbol }.
	transcript show: ' ... okay'.
	^mappedPluginEntries size
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> ioLoadFunction: functionString From: pluginString AccessorDepthInto: accessorDepthPtr [
	"Load and return the requested function from a module.
	 Assign the accessor depth through accessorDepthPtr.
	 N.B. The actual code lives in platforms/Cross/vm/sqNamedPrims.h"
	| firstTime plugin fnSymbol |
	firstTime := false.
	fnSymbol := functionString asSymbol.
	transcript
		cr;
		show: '(', byteCount printString, ') Looking for ', functionString, ' in ',
				(pluginString isEmpty ifTrue: ['vm'] ifFalse: [pluginString]).
	(breakSelector notNil
	 and: [(pluginString size = breakSelector size
			and: [(self strncmp: pluginString _: breakSelector _: pluginString size) = 0])
		or: [functionString size = breakSelector size
			and: [(self strncmp: functionString _: breakSelector _: functionString size) = 0]]]) ifTrue:
		[self halt: pluginString, '>>', functionString].
	plugin := pluginList 
				detect: [:any| any key = pluginString asString]
				ifNone:
					[firstTime := true.
					 self loadNewPlugin: pluginString].
	plugin ifNil:
		[firstTime ifTrue: [transcript show: '... FAILED; no plugin found'].
		 ^0].
	plugin := plugin value.
	mappedPluginEntries withIndexDo:
		[:pluginAndName :index|
		 ((pluginAndName at: 1) == plugin 
		  and:[(pluginAndName at: 2) == fnSymbol]) ifTrue:
			[firstTime ifTrue: [transcript show: ' ... okay'].
			 accessorDepthPtr at: 0 put: (pluginAndName at: 4).
			 ^index]].
	firstTime ifTrue: [transcript show: '... FAILED; primitive not in plugin'].
	^0
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioMSecs [
	"Return the value of the millisecond clock."
	"NOT.  Actually, we want something a lot slower and, for exact debugging,
	something more repeatable than real time.  I have an idea: use the byteCount... (di 7/1/2004 13:55)"

	^self microsecondsToMilliseconds: self ioUTCMicroseconds
	
"At 20k bytecodes per second, this gives us about 200 ticks per second, or about 1/5 of what you'd expect for the real time clock.  This should still service events at one or two per second"
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioMicroMSecs [
	"Answer the value of the high-resolution millisecond clock."

	^ Time millisecondClockValue

]

{ #category : #'I/O primitives' }
StackInterpreterSimulator >> ioProcessEvents [
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioRelinquishProcessorForMicroseconds: microseconds [
	"In the simulator give an indication that we're idling and check for input."

	Processor activeProcess == UIManager default uiProcess ifTrue:
		[World doOneCycle].
	microseconds >= 1000
		ifTrue: [(Delay forMilliseconds: microseconds + 999 // 1000) wait]
		ifFalse: [Processor yield].
	"And increase the byteCount form which the microsecond clock is derived..."
	byteCount := byteCount + microseconds - 1.
	self incrementByteCount
]

{ #category : #'I/O primitives' }
StackInterpreterSimulator >> ioScreenDepth [
	^DisplayScreen actualScreenDepth.
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioScreenScaleFactor [
	^ 1.0
]

{ #category : #'process primitive support' }
StackInterpreterSimulator >> ioSetMaxExtSemTableSize: anInteger [
	"Inform the VM of the maximum size the image will grow the exernal semaphore table (specialObjectsArray at: 39) to.
	 This allows the VM to allocate storage such that external semaphores can be signalled without locking."
	extSemTabSize := anInteger
]

{ #category : #'process primitive support' }
StackInterpreterSimulator >> ioSynchronousCheckForEvents [
	"Hook allowing the platform to do anything it needs to do synchronously."
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioUTCMicroseconds [
	"Return the value of the microsecond clock."
	"NOT.  Actually, we want something a lot slower and, for exact debugging,
	something more repeatable than real time.  Dan had an idea: use the byteCount..."

	^(byteCount // 50) + startMicroseconds
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> ioUTCStartMicroseconds [
	"Answer the value of the microsecond clock at startup."

	^startMicroseconds ifNil:
		[self class initializationOptions
			at: #startMicroseconds
			ifAbsent: [[Time utcMicrosecondClock] on: Error do: [Time totalSeconds * 1000000]]]
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> isPrimitiveFunctionPointerAnIndex [
	"We save slots in the method cache by using the primitiveFunctionPointer
	 to hold either a function pointer or the index of a quick primitive. Since
	 quick primitive indices are small they can't be confused with function
	 addresses.  But since we use 1001 and up for external primitives that
	 would be functions in the C VM but are indices under simulation we treat
	 values above 1000 as if they were pointers (actually indices into the
	 externalPrimitiveTable)"

	^primitiveFunctionPointer isInteger
	  and: [primitiveFunctionPointer ~= 0
	  and: [primitiveFunctionPointer <= MaxQuickPrimitiveIndex]]
]

{ #category : #'compiled methods' }
StackInterpreterSimulator >> literal: offset [
	"trap pushes of forwarded literals to help debug following forwarded primitive args.
	 it is not an error to push a forwarded literal, but we'd like to step through any resulting
	 primtive failure code.
	 Use #literalMaybeForwarder: for resolve forwarders if nedeed
	"
	| lit |
	lit := super literal: offset.
	(objectMemory isOopForwarded: lit) ifTrue:
		[self halt: 'forwarded literal in ', thisContext selector].
	^lit
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> loadNewPlugin: pluginString [
	breakSelector ifNotNil:
		[(self strncmp: pluginString _: breakSelector _: pluginString size) = 0 ifTrue:
			[self halt: pluginString]].
	^(self tryLoadNewPlugin: pluginString pluginEntries: mappedPluginEntries) ifNotNil:
		[:entry|
		 pluginList := pluginList copyWith: entry.
		 entry]
]

{ #category : #'memory access' }
StackInterpreterSimulator >> longAt: byteAddress [
	self deprecated.
	^objectMemory longAt: byteAddress
]

{ #category : #'memory access' }
StackInterpreterSimulator >> longAt: byteAddress put: a32BitValue [
	self deprecated.
	^objectMemory longAt: byteAddress put: a32BitValue
]

{ #category : #'callback support' }
StackInterpreterSimulator >> lookupOrdinaryNoMNUEtcInClass: class [
	lookupCount := lookupCount + 1.
	^super lookupOrdinaryNoMNUEtcInClass: class
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> mappedPluginEntries [
	^mappedPluginEntries
]

{ #category : #'frame access' }
StackInterpreterSimulator >> markContextAsDead: oop [
	"(self withoutSmallIntegerTags: (objectMemory fetchPointer: SenderIndex ofObject: oop)) = -16r26824 ifTrue:
		[self halt]."
	^super markContextAsDead: oop
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> methodForContext: aContextOop [
	self assert: (objectMemory isContext: aContextOop).
	^objectMemory fetchPointer: MethodIndex ofObject: aContextOop
]

{ #category : #'debug support' }
StackInterpreterSimulator >> nameOfClass: classOop [
	| numSlots maybeThisClassOop maybeNameOop name |
	classNameIndex ifNil: [^'??nil cnidx??'].
	numSlots := objectMemory numSlotsOf: classOop.
	numSlots = metaclassNumSlots ifTrue:
		[maybeThisClassOop := objectMemory fetchPointer: thisClassIndex ofObject: classOop.
		(self addressCouldBeClassObj: maybeThisClassOop) ifTrue:
			[name := self nameOfClass: maybeThisClassOop.
			 (name beginsWith: 'bad ') ifFalse:
				[^name, ' class']].
		 ^'bad class'].
	(numSlots > classNameIndex
	 and: [maybeNameOop := objectMemory fetchPointer: classNameIndex ofObject: classOop.
		objectMemory isBytes: maybeNameOop]) ifFalse:
		[^'bad class'].
	^self stringOf: maybeNameOop
]

{ #category : #initialization }
StackInterpreterSimulator >> nextShortFrom: aStream [
	"Read a 16-bit quantity from the given (binary) stream."
	^self subclassResponsibility
]

{ #category : #accessing }
StackInterpreterSimulator >> parent [

	^ parent
]

{ #category : #accessing }
StackInterpreterSimulator >> parent: anObject [

	parent := anObject
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> pluginEntryFor: mapIndex [
	^mappedPluginEntries at: (mapIndex > 1000
								ifTrue: [externalPrimitiveTable at: mapIndex - 1001]
								ifFalse: [mapIndex])
]

{ #category : #'as yet unclassified' }
StackInterpreterSimulator >> pluginList: aCollection [ 
	pluginList := aCollection
]

{ #category : #'object memory support' }
StackInterpreterSimulator >> preBecomeAction [
	"((objectMemory instVarNamed: 'becomeEffectsFlags') anyMask: BecameCompiledMethodFlag) ifTrue:
		[self halt]."
	super preBecomeAction
]

{ #category : #'other primitives' }
StackInterpreterSimulator >> primStringcomparewithcollated [
	^ self primitiveFail
]

{ #category : #'other primitives' }
StackInterpreterSimulator >> primStringfindSubstringinstartingAtmatchTable [
	^self primitiveFail
]

{ #category : #'other primitives' }
StackInterpreterSimulator >> primStringindexOfAsciiinStringstartingAt [
	^ self primitiveFail
]

{ #category : #'other primitives' }
StackInterpreterSimulator >> primStringtranslatefromtotable [
	^ self primitiveFail
]

{ #category : #'indexing primitives' }
StackInterpreterSimulator >> primitiveAtPut [
	"16r1510B8 = (self stackValue: 2) ifTrue:
		[self halt]."
	^super primitiveAtPut
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveContextAt [
	"self halt."
	^super primitiveContextAt
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveDoPrimitiveWithArgs [
	self halt.
	^super primitiveDoPrimitiveWithArgs
]

{ #category : #'control primitives' }
StackInterpreterSimulator >> primitiveExecuteMethod [
	self halt: thisContext selector.
	^super primitiveExecuteMethod
]

{ #category : #'control primitives' }
StackInterpreterSimulator >> primitiveExecuteMethodArgsArray [
	self halt: thisContext selector.
	"(objectMemory isOopCompiledMethod: self stackTop) ifFalse:
		[self halt]."
	^super primitiveExecuteMethodArgsArray
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveFailFor: reasonCode [
	"self halt."
	^super primitiveFailFor: reasonCode
]

{ #category : #'other primitives' }
StackInterpreterSimulator >> primitiveGetAttribute [
	"Fetch the system attribute with the given integer ID. The result is a string, which will be empty if the attribute is not defined."

	| index s attribute |
	index := self stackIntegerValue: 0.
	self successful ifTrue: [
		attribute := systemAttributes at: index ifAbsent: [Smalltalk vm getSystemAttribute: index].
		attribute ifNil: [ ^self primitiveFail ].
		s := objectMemory instantiateClass: (objectMemory splObj: ClassByteString) indexableSize: attribute size.
		1 to: attribute size do: [ :i |
			objectMemory storeByte: i-1 ofObject: s withValue: (attribute at: i) asciiValue].
		self pop: 2 "rcvr, attr" thenPush: s]
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveIdentityHash [
	"| oop |
	oop := self stackTop.
	((objectMemory isBytes: oop)
	and: [(objectMemory lengthOf: oop) = 'smallSelect' size
	and: [(self stringOf: oop) = 'smallSelect']]) ifTrue:
		[self halt]."
	^super primitiveIdentityHash
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveNewWithArg [
	"(objectMemory hasSpurMemoryManagerAPI
	 and: [self classNameOf: (self stackValue: 1) Is: 'MethodDictionary']) ifTrue:
		[self halt]."
	"| hash |
	hash := objectMemory rawHashBitsOf: (self stackValue: 1)."
	"| format |
	format := objectMemory instSpecOfClass: (self stackValue: 1)."
	"(objectMemory numSlotsOf: (self stackValue: 1)) = 3 ifTrue:
		[self halt]."
	super primitiveNewWithArg.
	"self successful ifTrue:
		[(Smalltalk at: #Counts ifAbsentPut: [Bag new]) add: format]."
	"(self successful and: [objectMemory hasSpurMemoryManagerAPI]) ifTrue:
		[(Smalltalk at: #Counts ifAbsentPut: [Bag new]) add: hash]"
	"Smalltalk removeKey: #Counts"
	"Counts sortedCounts collect: [:assoc|
		assoc key -> ((SpurMemoryManager organization listAtCategoryNamed: #'header formats') detect:
										[:f| (SpurMemoryManager basicNew perform: f) = assoc value])]
		{3251->#arrayFormat.
		 1685->#firstByteFormat.
		 1533->#firstLongFormat.
		 110->#weakArrayFormat.
		 35->#indexablePointersFormat.
		 5->#nonIndexablePointerFormat}"
	"Counts sortedCounts collect: [:assoc|
		assoc value = 0
			ifTrue: [assoc]
			ifFalse: [assoc key -> {(self nameOfClass: (objectMemory classAtIndex: assoc value)).
									(SpurMemoryManager organization listAtCategoryNamed: #'header formats') detect:
										[:f| (objectMemory perform: f)
											= (objectMemory instSpecOfClass: (objectMemory classAtIndex: assoc value))]}]]
	{1062->#('Array' #arrayFormat).
	 777->#('Bitmap' #firstLongFormat).
	 395->#('Float' #firstLongFormat).
	 345->#('ByteString' #firstByteFormat).
	 237->#('MatrixTransform2x3' #firstLongFormat).
	 233->#('LargePositiveInteger' #firstByteFormat).
	 103->#('WordArray' #firstLongFormat).
	 58->#('WeakArray' #weakArrayFormat).
	 52->#('WeakMessageSend' #weakArrayFormat).
	 9->#('MethodContext' #indexablePointersFormat).
	 4->#('DirectoryEntry' #nonIndexablePointerFormat).
	 3->#('BalloonBuffer' #firstLongFormat).
	 1->#('ByteArray' #firstByteFormat).
	 1->0}"
]

{ #category : #'control primitives' }
StackInterpreterSimulator >> primitiveObject: actualReceiver perform: selector withArguments: argumentArray lookedUpIn: lookupClass [
	"Override to allow simulator to filter start-up items to avoid as-yet unsimulatable plugins."

	(self filterPerformOf: selector to: actualReceiver) ifTrue:
		[^self pop: argumentCount + 1 thenPush: actualReceiver].
	^super primitiveObject: actualReceiver perform: selector withArguments: argumentArray lookedUpIn: lookupClass
]

{ #category : #'object access primitives' }
StackInterpreterSimulator >> primitiveObjectPointsTo [
	"self halt."
	^super primitiveObjectPointsTo
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitivePerform [
	| selector |
	selector := self stackValue: argumentCount - 1.
	self sendBreakpoint: selector receiver: (self stackValue: argumentCount).
	(self filterPerformOf: selector to: (self stackValue: argumentCount)) ifTrue:
		[^self pop: argumentCount].
	^super primitivePerform
]

{ #category : #'object access primitives' }
StackInterpreterSimulator >> primitiveStoreStackp [
	"self printContext: (self stackValue: 1).
	self halt."
	super primitiveStoreStackp.
	"self printContext: self stackTop"
]

{ #category : #'system control primitives' }
StackInterpreterSimulator >> primitiveVMParameter [
	
	(self stackTop = (objectMemory integerObjectOf: 9)
	 or: [self stackTop = (objectMemory integerObjectOf: 52)]) ifTrue:
		[self halt].
	^super primitiveVMParameter
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> primitiveWait [
	"Catch errors before we start the whole morphic error process"

	"byteCount > 1000000 ifTrue: [self halt]."  "Ignore early process activity"
	^ super primitiveWait
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> print: it [

	traceOn ifTrue:
		[it isString ifTrue: [transcript nextPutAll: it] ifFalse: [it printOn: transcript]]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printChar: aByte [

	traceOn ifTrue: [ transcript nextPut: aByte asCharacter ].
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printCurrentBytecodeOn: aStream [
	| code |
	code := currentBytecode radix: 16.
	aStream newLine; print: instructionPointer - method - 3; tab.
	aStream
		nextPut: (code size < 2
					ifTrue: [$0]
					ifFalse: [code at: 1]);
		nextPut: code last; space;
		nextPutAll: (BytecodeTable at: currentBytecode + 1);
		space;
		nextPut: $(; print: byteCount + 1; nextPut: $)
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printECS [
	self printCallStackFP: framePointer
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printFrameFlagsForFP: theFP [
	| address it |
	<inline: false>
	<var: #theFP type: #'char *'>
	<var: #address type: #'char *'>
	address := theFP + FoxFrameFlags.
	it := stackPages unsignedLongAt: address.
	self printHex: address;
		printChar: $/;
		printNum: (stackPages memIndexFor: address);
		print: ':       flags: ';
		printHex: it.
	it ~= 0 ifTrue:
		[self printChar: $=; printNum: it].
	self print: '  numArgs: '; printNum: (self frameNumArgs: theFP);
		print: '  hasContext: '; printNum: (self frameHasContext: theFP);
		print: '  isBlock: '; printNum: (self frameIsBlockActivation: theFP);
		cr
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printFrameOop: name at: address [
	| it |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages unsignedLongAt: address.
	self printHex: address;
		printChar: $/;
		printNum: (stackPages memIndexFor: address);
		printChar: $:.
	1 to: 12 - (self strlen: name) do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	self tab;
		print: (self shortPrint: it);
		cr
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printFrameThing: name andFrame: theFP at: address [
	<var: #theFP type: #'char *'>
	| it |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages unsignedLongAt: address.
	self printHex: address;
		printChar: $/;
		printNum: (stackPages memIndexFor: address);
		printChar: $:.
	1 to: 12 - (self strlen: name) do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	it ~= 0 ifTrue:
		[self printChar: $=; printNum: it].
	self print: ' frame: '; printHex: theFP; cr
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printFrameThing: name at: address [
	| it |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages unsignedLongAt: address.
	self printHex: address;
		printChar: $/;
		printNum: (stackPages memIndexFor: address);
		printChar: $:.
	1 to: 12 - (self strlen: name) do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	it ~= 0 ifTrue:
		[self printChar: $=; printNum: it].
	self cr
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printHex: anInteger [

	traceOn ifTrue:
		[| it16 |
		 it16 := anInteger radix: 16.
		 transcript
			next: 8 - it16 size put: Character space;
			nextPutAll: (anInteger storeStringBase: 16)]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printHexnp: anInteger [

	traceOn ifTrue:
		[transcript nextPutAll: ((anInteger ifNil: [0]) storeStringBase: 16)]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printHexnpnp: anInteger [
	"Print n in hex, in the form '1234', unpadded"
	traceOn ifTrue:
		[transcript nextPutAll: ((anInteger ifNil: [0]) printStringBase: 16)]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printLCS [
	self printCallStackFP: framePointer
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printNum: anInteger [

	traceOn ifTrue: [ transcript print: anInteger ].
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printSends [
	^printSends or: [printBytecodeAtEachStep]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printSends: aBoolean [
	printSends := aBoolean
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printStringForCurrentBytecode [
	^String streamContents: [:str| self printCurrentBytecodeOn: str]
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> printStringOf: oop [

	super printStringOf: oop.
	traceOn ifTrue: [transcript flush]
]

{ #category : #testing }
StackInterpreterSimulator >> profile: nBytecodes [
	"(InterpreterSimulator new openOn: 'clonex.image') profile: 60000"
	transcript clear.
	byteCount := 0.
	MessageTally spyOn: [self runForNBytes: nBytecodes].
	self close
]

{ #category : #testing }
StackInterpreterSimulator >> profileSends: nBytecodes [
	"(InterpreterSimulator new openOn: 'clonex.image') profileSends: 5000"
	MessageTally tallySendsTo: self
		inBlock: [self runForNBytes: nBytecodes]
		showTree: true.
	self close
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> pushMaybeContextReceiverVariable: index [
	"(index = SenderIndex or: [index = ClosureIndex]) ifTrue: [self halt]."
	^super pushMaybeContextReceiverVariable: index
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> queueForwardedEvent: event [
	eventQueue ifNil:
		[eventQueue := SharedQueue new].
	eventQueue nextPut: event
]

{ #category : #'debug support' }
StackInterpreterSimulator >> redirectTranscriptToHost [
	"Sometimes you need the capability to see the transcript output of the image into the 
	 local transcript (for debugging when bootstrapping, for example). "
	transcript := Transcript
]

{ #category : #'image save/restore' }
StackInterpreterSimulator >> reverseBytesInImage [
	UIManager default
		informUser: 'Swapping bytes of foreign image...'
		during: [super reverseBytesInImage]
]

{ #category : #testing }
StackInterpreterSimulator >> run [
	"Just run"

	quitBlock := [ ^ self close ].
	self initStackPages.
	self loadInitialContext.
	self initialEnterSmalltalkExecutive.
	instructionPointer := instructionPointer - 1
	"undo the pre-increment of IP before returning"
]

{ #category : #testing }
StackInterpreterSimulator >> runAtEachStep: aBlock [
	self initStackPages.
	self loadInitialContext.
	self fetchNextBytecode.
	[true] whileTrue:
		[self assertValidExecutionPointers.
		 aBlock value: currentBytecode.
		 self dispatchOn: currentBytecode in: BytecodeTable.
		 self incrementByteCount].
	instructionPointer := instructionPointer - 1.
	"undo the pre-increment of IP before returning"
]

{ #category : #testing }
StackInterpreterSimulator >> runAtEachStep: aBlock breakCount: aBreakCount [

	self initStackPages.
	self loadInitialContext.
	self fetchNextBytecode.
	[ true ] whileTrue: [
		self assertValidExecutionPointers.
		aBlock value: currentBytecode.
		self dispatchOn: currentBytecode in: BytecodeTable.
		self incrementByteCount.
		byteCount = aBreakCount ifTrue: [ self halt ] ].
	instructionPointer := instructionPointer - 1
	"undo the pre-increment of IP before returning"
]

{ #category : #testing }
StackInterpreterSimulator >> runForNBytes: nBytecodes [
	"Do nByteCodes more bytecode dispatches.
	Keep byteCount up to date.
	This can be run repeatedly."

	| endCount |
	self initStackPages.
	self loadInitialContext.
	endCount := byteCount + nBytecodes.
	self fetchNextBytecode.
	[ byteCount < endCount ] whileTrue: [
		self dispatchOn: currentBytecode in: BytecodeTable.
		self incrementByteCount ].
	instructionPointer := instructionPointer - 1
	"undo the pre-increment of IP before returning"
]

{ #category : #'I/O primitives' }
StackInterpreterSimulator >> savedWindowSize [
	^savedWindowSize ifNil: [0]
]

{ #category : #accessing }
StackInterpreterSimulator >> setBreakCount: anInteger [
	breakCount := anInteger
]

{ #category : #accessing }
StackInterpreterSimulator >> setImageName: aString [ 
	imageName := aString
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> shortPrintContext: aContext [
	transcript newLine.
	^super shortPrintContext: aContext
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> shortPrintFrame: theFP [
	self transcript newLine.
	^super shortPrintFrame: theFP
]

{ #category : #'process primitive support' }
StackInterpreterSimulator >> signalSemaphoreWithIndex: index [
	"This is a simulation.  See platforms/Cross/vm/sqExternalSemaphores.c for the real code.
	 Thanks to Levente Uzoni for making this version almost thread-safe (in Smalltalk)"
	<doNotGenerate>
	| originalResponses newRequests newResponses |
	index <= 0 ifTrue: [^false].
	index > externalSemaphoreSignalRequests size ifTrue:
		[newRequests := Array new: 1 << index highBit withAll: 0.
		 newResponses := newRequests shallowCopy].
	"This is a lock-free thread-safe grow...; thanks Levente"
	originalResponses := externalSemaphoreSignalResponses.
	[index > externalSemaphoreSignalRequests size] whileTrue:
		[newRequests
			replaceFrom: 1
			to: externalSemaphoreSignalRequests size
			with: externalSemaphoreSignalRequests
			startingAt: 1.
		 newResponses
			replaceFrom: 1
			to: externalSemaphoreSignalResponses size
			with: externalSemaphoreSignalResponses
			startingAt: 1.
		 externalSemaphoreSignalResponses == originalResponses "This should always be true."
			ifTrue:
				[externalSemaphoreSignalRequests := newRequests.
				 externalSemaphoreSignalResponses := newResponses]
			ifFalse:
				[originalResponses := externalSemaphoreSignalResponses]].
	"This is not thread-safe however..."
	externalSemaphoreSignalRequests
		at: index
		put: (externalSemaphoreSignalRequests at: index) + 1.
	^true
]

{ #category : #testing }
StackInterpreterSimulator >> singleStep [
	self assertValidExecutionPointers.
	atEachStepBlock value. "N.B. may be nil"
	self dispatchOn: currentBytecode in: BytecodeTable.
	self incrementByteCount
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> slowPrimitiveResponse [
	primTraceLog ifNotNil:
		[primTraceLog size > 127 ifTrue:
			[primTraceLog removeFirst].
		 primTraceLog addLast: primitiveFunctionPointer].
	^super slowPrimitiveResponse
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> space [

	traceOn ifTrue: [ transcript space ]
]

{ #category : #'special objects' }
StackInterpreterSimulator >> splObj: anInteger [ 
	<doNotGenerate>
	^objectMemory splObj: anInteger 
]

{ #category : #'plugin support' }
StackInterpreterSimulator >> sqGetInterpreterProxy [
	"I am basically my own proxy..."
	^self
]

{ #category : #'memory access' }
StackInterpreterSimulator >> sqMemoryExtraBytesLeft: includingSwap [
	^0
]

{ #category : #'memory access' }
StackInterpreterSimulator >> sqShrinkMemory: oldLimit By: delta [
	transcript show: 'shrink memory from ', oldLimit printString, ' by ', delta printString, ' remember it doesn''t actually shrink in simulation'; cr.

	^ oldLimit
]

{ #category : #'spur bootstrap' }
StackInterpreterSimulator >> stackPage [
	^stackPage
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> stackPages [
	^stackPages
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> startInContextSuchThat: aBlock [
	"Change the active process's suspendedContext to its sender, which short-cuts the
	 initialization of the system.  This can be a short-cut to running code, e.g. when doing
		Smalltalk saveAs.
		Compiler recompileAll
	 via e.g.
		vm startInContextSuchThat: [:ctxt| (vm stringOf: (vm penultimateLiteralOf: (vm methodForContext: ctxt))) = 'DoIt']"
	<doNotGenerate>
	| context activeProc |
	activeProc := self activeProcess.
	context := objectMemory fetchPointer: SuspendedContextIndex ofObject: activeProc.
	[context = objectMemory nilObject ifTrue:
		[self error: 'no context found'].
	 aBlock value: context] whileFalse:
		[context := objectMemory fetchPointer: SenderIndex ofObject: context].
	objectMemory storePointer: SuspendedContextIndex ofObject: activeProc withValue: context.
	"Now push a dummy return value."
	objectMemory
		storePointer: (self fetchStackPointerOf: context) + CtxtTempFrameStart
		ofObject: context
		withValue: objectMemory nilObject.
	self storeInteger: StackPointerIndex
		ofObject: context
		withValue: (self fetchStackPointerOf: context) + 1
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> startInSender [
	"Change the active process's suspendedContext to its sender, which short-cuts the
	 initialization of the system.  This can be a short-cut to running code, e.g. when doing
		Smalltalk saveAs.
		Compiler recompileAll"
	
	| activeContext activeProc senderContext |
	activeProc := self activeProcess.
	activeContext := objectMemory fetchPointer: SuspendedContextIndex ofObject: activeProc.
	senderContext := objectMemory fetchPointer: SenderIndex ofObject: activeContext.
	objectMemory storePointer: SuspendedContextIndex ofObject: activeProc withValue: senderContext.
	"Now push a dummy return value."
	objectMemory
		storePointer: (self fetchStackPointerOf: senderContext) + CtxtTempFrameStart
		ofObject: senderContext
		withValue: objectMemory nilObject.
	self storeInteger: StackPointerIndex
		ofObject: senderContext
		withValue: (self fetchStackPointerOf: senderContext) + 1
]

{ #category : #'debugging traps' }
StackInterpreterSimulator >> success: successBoolean [
	"successBoolean ifFalse:
		[self halt]."
	^super success: successBoolean
]

{ #category : #'simulation only' }
StackInterpreterSimulator >> systemAttributes [
	^systemAttributes
]

{ #category : #'debug printing' }
StackInterpreterSimulator >> tab [

	traceOn ifTrue: [ transcript tab ].
]

{ #category : #testing }
StackInterpreterSimulator >> testBecome [
	"Become some young things.  AA testBecome    "
	| array list1 list2 p1 p2 p3 p4 |
	array := objectMemory splObj: ClassArray.
	list1 := objectMemory instantiateClass: array indexableSize: 2.
	list2 := objectMemory instantiateClass: array indexableSize: 2.
	p1 := objectMemory instantiateClass: (objectMemory splObj: ClassPoint) indexableSize: 0.
	self push: p1.
	objectMemory storePointer: 0 ofObject: list1 withValue: p1.
	p2 := objectMemory instantiateClass: (objectMemory splObj: ClassPoint) indexableSize: 0.
	self push: p2.
	objectMemory storePointer: 1 ofObject: list1 withValue: p2.
	p3 := objectMemory instantiateClass: (objectMemory splObj: ClassMessage) indexableSize: 0.
	self push: p3.
	objectMemory storePointer: 0 ofObject: list2 withValue: p3.
	p4 := objectMemory instantiateClass: (objectMemory splObj: ClassMessage) indexableSize: 0.
	self push: p4.
	objectMemory storePointer: 1 ofObject: list2 withValue: p4.
	(objectMemory become: list1 with: list2 twoWay: true copyHash: true) ifFalse: [self error: 'failed'].
	self popStack = p2 ifFalse: [self halt].
	self popStack = p1 ifFalse: [self halt].
	self popStack = p4 ifFalse: [self halt].
	self popStack = p3 ifFalse: [self halt].
	(objectMemory fetchPointer: 0 ofObject: list1) = p3 ifFalse: [self halt].
	(objectMemory fetchPointer: 1 ofObject: list1) = p4 ifFalse: [self halt].
	(objectMemory fetchPointer: 0 ofObject: list2) = p1 ifFalse: [self halt].
	(objectMemory fetchPointer: 1 ofObject: list2) = p2 ifFalse: [self halt].
]

{ #category : #testing }
StackInterpreterSimulator >> testWithFramePrint [
	printFrameAtEachStep := printBytecodeAtEachStep := true.
	self test
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> time: ignored [
	"Simulate the glibc time() function"

	^ DateAndTime now asUnixTime 
]

{ #category : #accessing }
StackInterpreterSimulator >> transcript [
	^transcript
]

{ #category : #accessing }
StackInterpreterSimulator >> transcript: aTranscript [
	transcript := aTranscript
]

{ #category : #accessing }
StackInterpreterSimulator >> turnOnPrimTraceLog [
	primTraceLog ifNil:
		[primTraceLog := OrderedCollection new: 512]
]

{ #category : #'interpreter shell' }
StackInterpreterSimulator >> unableToReadImageError [
	self error:  'Read failed or premature end of image file'
]

{ #category : #'debug support' }
StackInterpreterSimulator >> veryDeepCopyWith: deepCopier [

	"Override to short-circuit the copying of any VMPluginCodeGenerators referenced from mappedPluginEntries.
	 These can in turn hold onto Monticello state, resulting in a huge ammount of unnecessary copying."

	deepCopier references
		at: mappedPluginEntries
		ifAbsentPut: [ mappedPluginEntries ].
	mappedPluginEntries do: [ :tuple | 
		| block |
		block := tuple third.
		deepCopier references at: block ifAbsentPut: [ block ] ].
	^ super veryDeepCopyWith: deepCopier
]

{ #category : #'file primitives' }
StackInterpreterSimulator >> vmPathGet: stringBase Length: stringSize [
	| pathName stringOop |
	pathName := self vmPath.
	stringOop := stringBase - objectMemory baseHeaderSize. "Due to C call in Interp"
	1 to: stringSize do:
		[:i | objectMemory storeByte: i-1 ofObject: stringOop
			withValue: (pathName at: i) asciiValue].

]

{ #category : #'debug support' }
StackInterpreterSimulator >> warning: aString [
	transcript cr; nextPutAll: aString; flush
]

{ #category : #'I/O primitives support' }
StackInterpreterSimulator >> warpBits [

	^ myBitBlt warpBits
]

{ #category : #UI }
StackInterpreterSimulator >> windowColorToUse [
	^Color lightBlue
]

{ #category : #'primitive support' }
StackInterpreterSimulator >> windowIsClosing [
	quitBlock ifNotNil:
		[:effectiveQuitBlock|
		quitBlock := nil. "stop recursion on explicit window close."
		[effectiveQuitBlock value]
			on: BlockCannotReturn
			do: [:ex|]]	"Cause return from #test, et al"
]
