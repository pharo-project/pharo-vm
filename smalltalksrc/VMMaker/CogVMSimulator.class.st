"
This class defines basic memory access and primitive simulation so that the CoInterpreter can run simulated in the Squeak environment.  It also defines a number of handy object viewing methods to facilitate pawing around in the object memory.  Remember that you can test the Cogit using its class-side in-image compilation facilities.

To see the thing actually run, you could (after backing up this image and changes), execute

	(CogVMSimulator new openOn: Smalltalk imageName) test

and be patient both to wait for things to happen, and to accept various things that may go wrong depending on how large or unusual your image may be.  We usually do this with a small and simple benchmark image.

Here's an example to launch the simulator in a window.  The bottom-right window has a menu packed with useful stuff:

(CogVMSimulator newWithOptions: #(Cogit StackToRegisterMappingCogit))
	desiredNumStackPages: 8;
	openOn: '/Users/eliot/Cog/startreader.image';
	openAsMorph;
	run

Here's a hairier example that I (Eliot) actually use in daily development with some of the breakpoint facilities commented out.

| cos proc opts |
CoInterpreter initializeWithOptions: (opts := Dictionary newFromPairs: #(Cogit StackToRegisterMappingCogit)).
CogVMSimulator chooseAndInitCogitClassWithOpts: opts.
cos := CogVMSimulator new.
""cos initializeThreadSupport."" ""to test the multi-threaded VM""
cos desiredNumStackPages: 8. ""to set the size of the stack zone""
""cos desiredCogCodeSize: 8 * 1024 * 1024."" ""to set the size of the Cogit's code zone""
cos openOn: '/Users/eliot/Squeak/Squeak4.4/trunk44.image'. ""choose your favourite image""
""cos setBreakSelector: 'r:degrees:'."" ""set a breakpoint at a specific selector""
proc := cos cogit processor.
""cos cogit sendTrace: 7."" ""turn on tracing""
""set a complex breakpoint at a specific point in machine code""
""cos cogit singleStep: true; breakPC: 16r56af; breakBlock: [:cg|  cos framePointer > 16r101F3C and: [(cos longAt: cos framePointer - 4) = 16r2479A and: [(cos longAt: 16r101F30) = (cos longAt: 16r101F3C) or: [(cos longAt: 16r101F2C) = (cos longAt: 16r101F3C)]]]]; sendTrace: 1"".
""[cos cogit compilationTrace: -1] on: MessageNotUnderstood do: [:ex|]."" ""turn on compilation tracing in the StackToRegisterMappingCogit""
""cos cogit setBreakMethod: 16rB38880.""
cos
	openAsMorph;
	""toggleTranscript;"" ""toggleTranscript will send output to the Transcript instead of the morph's rather small window""
	halt;
	run
"
Class {
	#name : 'CogVMSimulator',
	#superclass : 'CoInterpreterPrimitives',
	#traits : 'TVMSimulator',
	#classTraits : 'TVMSimulator classTrait',
	#instVars : [
		'parent',
		'enableCog',
		'byteCount',
		'lastPollCount',
		'lastExtPC',
		'sendCount',
		'lookupCount',
		'printSends',
		'traceOn',
		'myBitBlt',
		'imageName',
		'pluginList',
		'mappedPluginEntries',
		'quitBlock',
		'transcript',
		'eventTransformer',
		'printFrameAtEachStep',
		'printBytecodeAtEachStep',
		'systemAttributes',
		'uniqueIndices',
		'uniqueIndex',
		'breakCount',
		'atEachStepBlock',
		'startMicroseconds',
		'lastYieldMicroseconds',
		'externalSemaphoreSignalRequests',
		'externalSemaphoreSignalResponses',
		'extSemTabSize',
		'debugStackDepthDictionary',
		'performFilters',
		'eventQueue',
		'expectedSends',
		'expecting',
		'bootstrapping',
		'primitiveFailCount',
		'primitiveFlags',
		'initialAddress',
		'rumpCStackBase'
	],
	#classVars : [
		'ByteCountsPerMicrosecond',
		'ExpectedSends'
	],
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'debug support' }
CogVMSimulator class >> expectedSends [
	^ExpectedSends
]

{ #category : 'initialization' }
CogVMSimulator class >> initializeWithOptions: optionsDictionary [
	super initializeWithOptions: optionsDictionary.

	ByteCountsPerMicrosecond := InitializationOptions
										at: #ByteCountsPerMicrosecond
										ifAbsent: [100]
]

{ #category : 'class initialization' }
CogVMSimulator class >> initializeWithOptions: optionsDictionaryOrArray objectMemoryClass: objectMemoryClassOrNil [
	"The relevant ObjectMemory, Interpreter and Cogit classes must be initialized in order.
	 This happens notionally every time we start the simulator,
	 but in fact happens when ever we instantiate a simulator."
	InitializationOptions := optionsDictionaryOrArray isArray
							ifTrue: [Dictionary newFromPairs: optionsDictionaryOrArray]
							ifFalse: [optionsDictionaryOrArray].

	(objectMemoryClassOrNil ifNil: [self objectMemoryClass])
		initializeWithOptions: InitializationOptions.

	self initializeWithOptions: InitializationOptions.

	(self cogitClass withAllSuperclasses copyUpTo: Cogit) reverseDo:
		[:c| c initializeWithOptions: InitializationOptions]
]

{ #category : 'instance creation' }
CogVMSimulator class >> new [
	^self onObjectMemory: nil cogit: nil options: #()
]

{ #category : 'instance creation' }
CogVMSimulator class >> newWithOptions: optionsDictionaryOrArray [
	^self onObjectMemory: nil cogit: nil options: optionsDictionaryOrArray
]

{ #category : 'instance creation' }
CogVMSimulator class >> onObjectMemory: anObjectMemory [
	^self onObjectMemory: anObjectMemory cogit: nil options: #()
]

{ #category : 'instance creation' }
CogVMSimulator class >> onObjectMemory: anObjectMemory cogit: aCogit [
	^self onObjectMemory: anObjectMemory cogit: aCogit options: #()
]

{ #category : 'instance creation' }
CogVMSimulator class >> onObjectMemory: anObjectMemory cogit: aCogit options: optionsDictionaryOrArray [
	| simulatorClass |
	^self == CogVMSimulator
		ifTrue:
			[simulatorClass := SmalltalkImage current endianness == #big
				ifTrue: [self notYetImplemented]
				ifFalse: [CogVMSimulatorLSB].
			simulatorClass
				initializeWithOptions: optionsDictionaryOrArray
				objectMemoryClass: (anObjectMemory ifNotNil: [anObjectMemory class]).
			 simulatorClass
				onObjectMemory: (anObjectMemory ifNil:
										[self objectMemoryClass simulatorClass new])
				cogit: aCogit
				options: optionsDictionaryOrArray]
		ifFalse:
			[| sim |
			sim := self basicNew.
			sim objectMemory: anObjectMemory.
			sim cogit: aCogit.
			sim initialize.
			sim]
]

{ #category : 'debug support' }
CogVMSimulator >> allObjectsSelect: objBlock [
	"self allObjectsSelect: [:oop | (self baseHeader: oop) = 1234]"

	| selected |
	selected := OrderedCollection new.
	objectMemory allObjectsDo:
		[:oop| (objBlock value: oop) ifTrue: [selected addLast: oop]].
	^ selected
]

{ #category : 'accessing' }
CogVMSimulator >> atEachStepBlock [
	^atEachStepBlock
]

{ #category : 'accessing' }
CogVMSimulator >> atEachStepBlock: aBlock [
	atEachStepBlock := aBlock
]

{ #category : 'initialization' }
CogVMSimulator >> basicInitialize [
	"Initialize the CogVMSimulator when running the interpreter inside Smalltalk.  The
	 primary responsibility of this method is to allocate Smalltalk Arrays for variables
	 that will be declared as statically-allocated global arrays in the translated code."
	super initialize.

	transcript := Transcript.
	bootstrapping := false.

	objectMemory ifNil:
		[objectMemory := self class objectMemoryClass simulatorClass new].
	cogit ifNil:
		[cogit := self class cogitClass new setInterpreter: self].
	objectMemory coInterpreter: self cogit: cogit.

	(cogit numRegArgs > 0
	 and: [VMClass initializationOptions at: #CheckStackDepth ifAbsent: [true]]) ifTrue:
		[debugStackDepthDictionary := Dictionary new].

	self assert: ConstMinusOne = (objectMemory integerObjectOf: -1).

	cogMethodZone := cogit methodZone. "Because Slang can't remove intermediate implicit receivers (cogit methodZone foo doesn't reduce to foo())"
	enableCog := true.

	methodCache := Array new: MethodCacheSize.
	atCache := nil.
	self flushMethodCache.
	cogCompiledCodeCompactionCalledFor := false.
	gcSemaphoreIndex := 0.
	externalSemaphoreSignalRequests := externalSemaphoreSignalResponses := #().
	externalPrimitiveTable := CArrayAccessor on: (Array
		new: MaxExternalPrimitiveTableSize
		withAll: 0).
	externalPrimitiveTableFirstFreeIndex := 0.
	primitiveTable := self class primitiveTable copy.

	desiredNumStackPages := desiredEdenBytes := desiredCogCodeSize := 0.
	"This is initialized on loading the image, but convenient for testing stack page values..."
	numStackPages := self defaultNumStackPages. 
	startMicroseconds := lastYieldMicroseconds := self ioUTCStartMicroseconds.
	maxLiteralCountForCompile := MaxLiteralCountForCompile.
	minBackwardJumpCountForCompile := MinBackwardJumpCountForCompile.
	flagInterpretedMethods := false.

	"initialize InterpreterSimulator variables used for debugging"
	byteCount := lastPollCount := sendCount := lookupCount := 0.
	quitBlock := [^self close].
	traceOn := true.
	printSends := printFrameAtEachStep := printBytecodeAtEachStep := false.
	myBitBlt := BitBltSimulator new setInterpreter: self.
	eventQueue := SharedQueue new.
	suppressHeartbeatFlag := deferSmash := deferredSmash := false.
	systemAttributes := Dictionary new.
	primTraceLog := CArrayAccessor on: (Array new: 256 withAll: 0).
	primTraceLogIndex := 0.
	traceLog := CArrayAccessor on: (Array new: TraceBufferSize withAll: 0).
	traceLogIndex := 0.
	traceSources := TraceSources.
	statCodeCompactionCount := 0.
	statCodeCompactionUsecs := 0.
	extSemTabSize := 256.
	
	"This will be overriden when calling initializePluginEntries"
	mappedPluginEntries := OrderedCollection new.
	
	imageReaderWriter := VMImageReaderWriter newWithMemory: objectMemory andInterpreter: self.

]

{ #category : 'hooks' }
CogVMSimulator >> beforeCodeZoneInitialization [ 

	super beforeCodeZoneInitialization.

	self moveMethodCacheToMemoryAt: (memoryManager allocate: MethodCacheEntrySize * MethodCacheSize * (self sizeof: #sqInt)).
	self movePrimTraceLogToMemoryAt: (memoryManager allocate: PrimTraceLogSize * (self sizeof: #sqInt)).

]

{ #category : 'accessing' }
CogVMSimulator >> bootstrapping: aBoolean [
	bootstrapping := aBoolean.
	objectMemory ifNotNil:
		[objectMemory bootstrapping: aBoolean]
]

{ #category : 'accessing' }
CogVMSimulator >> breakCount [
	^breakCount
]

{ #category : 'memory access' }
CogVMSimulator >> byteAt: byteAddress [
	"This is really only for the C library simulations memcpy:_:_: et al in VMClass.
	 Use objectMemory byteAt: directly where possible."
	^objectMemory byteAt: byteAddress
]

{ #category : 'memory access' }
CogVMSimulator >> byteAt: byteAddress put: byte [
	^objectMemory byteAt: byteAddress put: byte
]

{ #category : 'debug support' }
CogVMSimulator >> byteCount [
	"So you can call this from temp debug statements in, eg, Interpreter, such as
	self byteCount = 12661 ifTrue: [self halt].
	"

	^ byteCount
]

{ #category : 'UI' }
CogVMSimulator >> byteCountText [
	^(String streamContents: [:s| s nextPutAll: byteCount asStringWithCommas; nextPut: $/; nextPutAll: sendCount asStringWithCommas]) asText
]

{ #category : 'translation support' }
CogVMSimulator >> cCoerceSimple: value to: cTypeString [
	"Type coercion for translation and simulation.
	 For simulation answer a suitable surrogate for the struct types"

	^ cTypeString
		  caseOf: { ([ #'CogMethod *' ]
			   -> [ cogit cogMethodSurrogateAt: value asUnsignedInteger ]) }
		  otherwise: [ value ]
]

{ #category : 'plugin support' }
CogVMSimulator >> callExternalPrimitive: mapIndex [

	| entry |
	entry := self pluginEntryFor: mapIndex.
	"Spur needs the primitiveFunctionPointer to be set correctly
	 for accurate following of forwarders on primitive failure."
	primitiveFunctionPointer := entry at: 2.
	^ (entry at: 1) perform: (entry at: 2)
]

{ #category : 'trampolines' }
CogVMSimulator >> ceReapAndResetErrorCodeFor: cogMethod [
	"Override to map the address into a CogMethodSurrogate"
	| surrogate |
	surrogate := cogMethod isInteger
					ifTrue: [cogit cogMethodSurrogateAt: cogMethod]
					ifFalse: [cogMethod].
	^super ceReapAndResetErrorCodeFor: surrogate
]

{ #category : 'object memory support' }
CogVMSimulator >> checkStackIntegrity [
	"Override to deal with incomplete initialization."
	stackPages ifNil: [^true].
	stackPages pages ifNil: [^true].
	^super checkStackIntegrity
]

{ #category : 'debug support' }
CogVMSimulator >> classAndSelectorOfMethod: meth forReceiver: rcvr [
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
	mClass := objectMemory fetchPointer: SuperclassIndex ofObject: mClass.
	mClass = objectMemory nilObject]
		whileFalse: [].
	^ Array
		with: (objectMemory fetchClassOf: rcvr)
		with: (objectMemory splObj: SelectorDoesNotUnderstand)
]

{ #category : 'plugin support' }
CogVMSimulator >> classNameOf: aClass Is: className [
	"Check if aClass' name is className"
	| name |
	(objectMemory lengthOf: aClass) <= classNameIndex ifTrue:
		[^false]. "Not a class but maybe behavior" 
	name := objectMemory fetchPointer: classNameIndex ofObject: aClass.
	(objectMemory isBytes: name) ifFalse:
		[^false].
	^ className = (self stringOf: name)
]

{ #category : 'I/O primitives' }
CogVMSimulator >> clipboardRead: sz Into: actualAddress At: zeroBaseIndex [
	| str |
	str := Clipboard clipboardText.
	1 to: sz do:
		[:i | objectMemory byteAt: actualAddress + zeroBaseIndex + i - 1 put: (str at: i) asciiValue]
]

{ #category : 'I/O primitives' }
CogVMSimulator >> clipboardSize [

	^ Clipboard clipboardText size
]

{ #category : 'debug support' }
CogVMSimulator >> cloneSimulation [

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

{ #category : 'initialization' }
CogVMSimulator >> close [  "close any files that ST may have opened, etc"
	pluginList do: [:assoc| | plugin | plugin := assoc value. plugin ~~ self ifTrue: [plugin close]]
]

{ #category : 'primitive support' }
CogVMSimulator >> codeGeneratorToComputeAccessorDepth [

	^ codeGeneratorToComputeAccessorDepth ifNil: [
		(VMMaker new
			vmmakerConfiguration: VMMakerConfiguration;
			buildCodeGeneratorForInterpreter: CoInterpreterPrimitives
			includeAPIMethods: false
			initializeClasses: false)
				logger: self transcript;
				yourself]
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> codeGeneratorToComputeAccessorDepth: aCCodeGenerator [ 

	codeGeneratorToComputeAccessorDepth := aCCodeGenerator
]

{ #category : 'simulation only' }
CogVMSimulator >> cogit [
	^cogit
]

{ #category : 'debug support' }
CogVMSimulator >> collectSends [
	expectedSends := WriteStream on: (Array new: 65536).
	expecting := false
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> copyBits [

	^ myBitBlt copyBits
]

{ #category : 'debug printing' }
CogVMSimulator >> cr [

	traceOn ifTrue: [ transcript cr; flush ].
]

{ #category : 'debugging traps' }
CogVMSimulator >> createActualMessageTo: class [

	class = objectMemory nilObject ifTrue: [self halt].

	^super createActualMessageTo: class
]

{ #category : 'debug support' }
CogVMSimulator >> debugStackPointersFor: aMethod [
	^CArrayAccessor on:
		(StackDepthFinder on: (VMCompiledMethodProxy new
									for: aMethod
									coInterpreter: self
									objectMemory: objectMemory))
			stackPointers
]

{ #category : 'initialization' }
CogVMSimulator >> desiredCogCodeSize: anInteger [
	desiredCogCodeSize := anInteger
]

{ #category : 'UI' }
CogVMSimulator >> desiredDisplayExtent [
	^(savedWindowSize
		ifNil: [640@480]
		ifNotNil: [savedWindowSize >> 16 @ (savedWindowSize bitAnd: 16rFFFF)])
			min: Display extent * 2 // 3
]

{ #category : 'initialization' }
CogVMSimulator >> desiredEdenBytes: anInteger [
	desiredEdenBytes := anInteger
]

{ #category : 'initialization' }
CogVMSimulator >> desiredNumStackPages: anInteger [
	desiredNumStackPages := anInteger
]

{ #category : 'plugin primitive support' }
CogVMSimulator >> dispatchMappedPluginEntry: n [ 
	^(mappedPluginEntries at: n) first
		perform: (mappedPluginEntries at: n) second
]

{ #category : 'interpreter shell' }
CogVMSimulator >> dispatchOn: anInteger in: selectorArray [
	"Simulate a case statement via selector table lookup.
	The given integer must be between 0 and selectorArray size-1, inclusive.
	For speed, no range test is done, since it is done by the at: operation.
	Note that, unlike many other arrays used in the Interpreter, this method expect NO CArrayAccessor wrapping - it would duplicate the +1. Maybe this would be better updated to make it all uniform"
	cogit breakPC ifNil:
		[cogit breakBlock ifNotNil:
			[:bb| (bb value: cogit) ifTrue: [self halt: 'breakpoint reached']]].
	self perform: (selectorArray at: (anInteger + 1)).
]

{ #category : 'debugging traps' }
CogVMSimulator >> divorceFrame: theFP andContext: ctxt [
	"((#(16r100570 16r101BC8) includes: theFP) or: [#(16r17159A4 16r1715948) includes: ctxt]) ifTrue:
		[self halt]."
	^super divorceFrame: theFP andContext: ctxt
]

{ #category : 'process primitive support' }
CogVMSimulator >> doSignalExternalSemaphores: minTableSize [
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

{ #category : 'error handling' }
CogVMSimulator >> doesNotUnderstand: aMessage [
	"If this is a doit and the objectMemory understands, pass it on."
	(thisContext findContextSuchThat: [:ctxt| ctxt selector == #evaluate:in:to:notifying:ifFail:logged:]) ifNotNil:
		[(objectMemory class whichClassIncludesSelector: aMessage selector) ifNotNil:
			[:implementingClass|
			(implementingClass inheritsFrom: Object) ifTrue: "i.e. VMClass and below"
				[thisContext sender selector ~~ #DoIt ifTrue:
					[Transcript nextPutAll: 'warning: redirecting ', aMessage selector, ' in ', thisContext sender printString, ' to objectMemory'; cr; flush].
				 aMessage lookupClass: nil.
				^aMessage sentTo: objectMemory]].
		(cogit class whichClassIncludesSelector: aMessage selector) ifNotNil:
			[:implementingClass|
			(implementingClass inheritsFrom: Object) ifTrue: "i.e. VMClass and below"
				[thisContext sender selector ~~ #DoIt ifTrue:
					[Transcript nextPutAll: 'warning: redirecting ', aMessage selector, ' in ', thisContext sender printString, ' to cogit'; cr; flush].
				 aMessage lookupClass: nil.
				^aMessage sentTo: cogit]]].
	^super doesNotUnderstand: aMessage
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> drawLoopX: xDelta Y: yDelta [

	^ myBitBlt drawLoopX: xDelta Y: yDelta
]

{ #category : 'debug support' }
CogVMSimulator >> dumpMethodHeader: hdr [
	^ String streamContents:
		[:strm |
		strm nextPutAll: '<nArgs=', ((hdr >> 25) bitAnd: 16r1F) printString , '>'.
		strm nextPutAll: '<nTemps=', ((hdr >> 19) bitAnd: 16r3F) printString , '>'.
		strm nextPutAll: '<lgCtxt=', ((hdr >> 18) bitAnd: 16r1) printString , '>'.
		strm nextPutAll: '<nLits=', ((hdr >> 10) bitAnd: 16rFF) printString , '>'.
		strm nextPutAll: '<prim=', ((hdr >> 1) bitAnd: 16r1FF) printString , '>'.
		]
]

{ #category : 'debug printing' }
CogVMSimulator >> elementsPerPrintOopLine [
	^4
]

{ #category : 'debugging traps' }
CogVMSimulator >> enableCog: aBoolean [
	enableCog := aBoolean
]

{ #category : 'debug support' }
CogVMSimulator >> expectSends: anArray [
	expectedSends := ReadStream on: anArray.
	expecting := true
]

{ #category : 'miscellaneous bytecodes' }
CogVMSimulator >> extABytecode [
	"224		11100000	aaaaaaaa	Extend A (Ext A = Ext A prev * 256 + Ext A)"
	(extA = 0 and: [extB = 0]) ifTrue:
		[lastExtPC := instructionPointer].
	^super extABytecode
]

{ #category : 'miscellaneous bytecodes' }
CogVMSimulator >> extBBytecode [
	"225		11100001	sbbbbbbb	Extend B (Ext B = Ext B prev * 256 + Ext B)"
	(extA = 0 and: [extB = 0]) ifTrue:
		[lastExtPC := instructionPointer].
	^super extBBytecode
]

{ #category : 'jump bytecodes' }
CogVMSimulator >> extUnconditionalJump [
	"242		11110010	i i i i i i i i	Jump i i i i i i i i (+ Extend B * 256, where bbbbbbbb = sddddddd, e.g. -32768 = i=0, a=0, s=1)"
	"| byte offset |
	byte := objectMemory byteAt: localIP + 1.
	offset := byte + (extB << 8).
	(offset < 0 and: [(self iframeBackwardBranchByte: localFP) - 2 = 1]) ifTrue: [self halt]."
	^super extUnconditionalJump
]

{ #category : 'interpreter shell' }
CogVMSimulator >> fetchByte [
	^objectMemory byteAt: (instructionPointer := instructionPointer + 1)
]

{ #category : 'interpreter access' }
CogVMSimulator >> fetchPointer: fieldIndex ofObject: oop [
	"index by word size, and return a pointer as long as the word size"
	self assert: (objectMemory cheapIsInMemory: oop).
	^objectMemory fetchPointer: fieldIndex ofObject: oop
]

{ #category : 'control primitives' }
CogVMSimulator >> filterPerformOf: selector to: receiver [
	"This is to allow simulator to filter start-up items to avoid as-yet unsimulatable plugins."
	performFilters ifNil: [^false].
	(performFilters at: (self shortPrint: receiver) ifAbsent: []) ifNotNil:
		[:messages|
		^messages includes: (self stringOf: selector)].
	^false
]

{ #category : 'memory access' }
CogVMSimulator >> firstIndexableField: oop [
	"This is in ObjectMemory and overridden in the obj mem simulators"
	self shouldNotImplement
]

{ #category : 'debug printing' }
CogVMSimulator >> flush [
	<cmacro: '() fflush(stdout)'>
	traceOn ifTrue: [transcript flush]
]

{ #category : 'plugin support' }
CogVMSimulator >> flushExternalPrimitives [
	self initializePluginEntries.
	super flushExternalPrimitives
]

{ #category : 'control primitives' }
CogVMSimulator >> forShortPrintString: shortPrintString filterPerformMessages: aCollection [
	performFilters ifNil:
		[performFilters := Dictionary new].
	performFilters at: shortPrintString put: aCollection
]

{ #category : 'frame access' }
CogVMSimulator >> frameOfMarriedContext: aContext [ 
	| senderOop |
	senderOop := objectMemory fetchPointer: SenderIndex ofObject: aContext.
	self assert: (objectMemory isIntegerObject: senderOop).
	^self withoutSmallIntegerTags: senderOop
]

{ #category : 'debug support' }
CogVMSimulator >> framePointer [
	^framePointer
]

{ #category : 'plugin primitives' }
CogVMSimulator >> functionForPrimitiveExternalCall: methodObj [
	"Override to jump through the plugin simulation hoops."
	| symbolOrIndex |
	symbolOrIndex := super functionForPrimitiveExternalCall: methodObj.
	^symbolOrIndex isSymbol
		ifTrue: [symbolOrIndex]
		ifFalse: [(self pluginEntryFor: symbolOrIndex) at: 3]
]

{ #category : 'interpreter shell' }
CogVMSimulator >> functionPointerFor: primIndex inClass: lookupClass [
	"Override Interpreter to handle the external primitives caching.  See also
	 internalExecuteNewMethod."

	^(primIndex between: 1 and: MaxPrimitiveIndex)
		ifTrue: [primitiveTable at: primIndex + 1]
		ifFalse: [0]
]

{ #category : 'cog jit support' }
CogVMSimulator >> functionPointerForCompiledMethod: methodObj primitiveIndex: primIndex [
	^self mapFunctionToAddress: (super functionPointerForCompiledMethod: methodObj primitiveIndex: primIndex)
]

{ #category : 'memory access' }
CogVMSimulator >> halfWordHighInLong32: long32 [
	^self subclassResponsibility
]

{ #category : 'memory access' }
CogVMSimulator >> halfWordLowInLong32: long32 [
	^self subclassResponsibility
]

{ #category : 'debug support' }
CogVMSimulator >> headerStart: oop [

	^ (objectMemory extraHeaderBytes: oop) negated
]

{ #category : 'debug support' }
CogVMSimulator >> heapMapAtWord: address Put: aBit [
	^objectMemory heapMap heapMapAtWord: address asUnsignedInteger Put: aBit
]

{ #category : 'image save/restore' }
CogVMSimulator >> imageName [
	^imageName
]

{ #category : 'spur bootstrap' }
CogVMSimulator >> imageName: aString [
	imageName := aString
]

{ #category : 'file primitives' }
CogVMSimulator >> imageNameGet: p Length: sz [
	1 to: sz  do:
		[:i |
		objectMemory
			byteAt:  p + i - 1
			put: (imageName at: i) asInteger]
]

{ #category : 'file primitives' }
CogVMSimulator >> imageNamePut: p Length: sz [

	| newName |
	newName := ByteString new: sz.
	1 to: sz do: [ :i | 
		newName
			at: i
			put: (Character value: (objectMemory byteAt: p + i - 1)) ].
	imageName := newName
]

{ #category : 'file primitives' }
CogVMSimulator >> imageNameSize [
	^imageName size
]

{ #category : 'rump c stack' }
CogVMSimulator >> inMemoryCFramePointerAddress [
	^self rumpCStackAddress - 16
]

{ #category : 'initialization' }
CogVMSimulator >> inMemoryCStackPointerAddress [
	^self rumpCStackAddress - 8
]

{ #category : 'rump c stack' }
CogVMSimulator >> inMemoryStackLimitAddress [
	^self rumpCStackAddress - 24
]

{ #category : 'rump c stack' }
CogVMSimulator >> inMemoryVMOwnerLockAddress [
	^self rumpCStackAddress - 48
]

{ #category : 'interpreter shell' }
CogVMSimulator >> incrementByteCount [
	(byteCount := byteCount + 1) = breakCount ifTrue:
		[ self halt: 'breakCount reached' ].
	byteCount \\ 1000 = 0 ifTrue:
		[ self forceInterruptCheck ]
]

{ #category : 'test support' }
CogVMSimulator >> initStackPagesForTests [
	numStackPages := 8.
	stackPages := self stackPagesClass new setInterpreter: self.
	objectMemory memoryManager allocate: 1024 * 1024.
	cogCodeSize := 0.
	self initStackPages
]

{ #category : 'accessing' }
CogVMSimulator >> initialAddress [
	^ initialAddress
]

{ #category : 'initialization' }
CogVMSimulator >> initialize [
	"Initialize the CogVMSimulator when running the interpreter inside Smalltalk.  The
	 primary responsibility of this method is to allocate Smalltalk Arrays for variables
	 that will be declared as statically-allocated global arrays in the translated code."
	
	self basicInitialize.
	self initializePluginEntries.
]

{ #category : 'plugin support' }
CogVMSimulator >> initializePluginEntries [

	mappedPluginEntries := OrderedCollection new.
	primitiveAccessorDepthTable := Array new: primitiveTable size.
	pluginList := {  }.
	self loadNewPlugin: ''
]

{ #category : 'interpreter shell' }
CogVMSimulator >> insufficientMemorySpecifiedError [
	self error: 'Insufficient memory for this image'
]

{ #category : 'interpreter shell' }
CogVMSimulator >> interpret [
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
		self dispatchOn: currentBytecode in: BytecodeTable.
		self incrementByteCount ].
	instructionPointer := instructionPointer - 1. "undo the pre-increment of IP before returning"
	^ nil
]

{ #category : 'stack pages' }
CogVMSimulator >> interpreterAllocationReserveBytes [

	^ bootstrapping
		ifTrue: [ 0 ]
		ifFalse: [ super interpreterAllocationReserveBytes ]
]

{ #category : 'interpreter shell' }
CogVMSimulator >> invalidCompactClassError: name [
	self error: 'Class ', name, ' does not have the required compact class index'
]

{ #category : 'security' }
CogVMSimulator >> ioCanRenameImage [
	^true
]

{ #category : 'security' }
CogVMSimulator >> ioCanWriteImage [
	^true
]

{ #category : 'primitive support' }
CogVMSimulator >> ioExit [

	quitBlock value  "Cause return from #test"
]

{ #category : 'primitive support' }
CogVMSimulator >> ioExitWithErrorCode: ec [
	self ioExit
]

{ #category : 'process primitive support' }
CogVMSimulator >> ioGetMaxExtSemTableSize [
	^extSemTabSize
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioHeartbeatMilliseconds [
	^1
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioHighResClock [
	^self ioUTCMicroseconds
]

{ #category : 'initialization' }
CogVMSimulator >> ioInitHeartbeat [
	"No-op in the simulator.  We cause a poll every 1000 bytecodes instead."
]

{ #category : 'plugin support' }
CogVMSimulator >> ioLoadFunction: functionString From: pluginString [
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
	mappedPluginEntries addLast: { plugin. fnSymbol. [plugin perform: fnSymbol. self]}.
	transcript show: ' ... okay'.
	^mappedPluginEntries size
]

{ #category : 'plugin support' }
CogVMSimulator >> ioLoadFunction: functionString From: pluginString AccessorDepthInto: accessorDepthPtr [
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
		[firstTime ifTrue: [transcript cr; show: '... FAILED; primitive not in plugin'].
		 ^0].
	plugin := plugin value.
	mappedPluginEntries withIndexDo:
		[:pluginAndName :index|
		 ((pluginAndName at: 1) == plugin 
		  and:[(pluginAndName at: 2) == fnSymbol]) ifTrue:
			[firstTime ifTrue: [transcript show: ' ... okay'].
			 accessorDepthPtr at: 0 put: (pluginAndName at: 4).
			 ^index]].
	firstTime ifTrue: [transcript cr; show: '... FAILED; primitive not in plugin'].
	^0
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioMSecs [
	"Return the value of the millisecond clock."
	"NOT.  Actually, we want something a lot slower and, for exact debugging,
	something more repeatable than real time.  I have an idea: use the byteCount... (di 7/1/2004 13:55)"

	^self microsecondsToMilliseconds: self ioUTCMicroseconds
	
"At 20k bytecodes per second, this gives us about 200 ticks per second, or about 1/5 of what you'd expect for the real time clock.  This should still service events at one or two per second"
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioMicroMSecs [
	"Answer the value of the high-resolution millisecond clock."

	^ Time millisecondClockValue

]

{ #category : 'I/O primitives' }
CogVMSimulator >> ioProcessEvents [
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioRelinquishProcessorForMicroseconds: microseconds [
	"In the simulator give an indication that we're idling and check for input.
	 If called from machine code then increment the byte count since the clock
	 is derived from it and the clock will not advance otherwise.
	 If we're simulating threading we're in difficulties.  We need a UI process
	 (to run activities such as fill-in-the-blanks) but we also need an independent
	 thread of control to run this VM thread.  So we need to fork a new UI process."
	Processor activeProcess == UIManager default uiProcess ifTrue:
		[World doOneCycle].
	microseconds >= 1000
		ifTrue: [ (Delay forMilliseconds: microseconds + 999 // 1000) wait]
		ifFalse: [Processor yield].
	byteCount := byteCount + (microseconds * ByteCountsPerMicrosecond) - 1.
	self incrementByteCount
]

{ #category : 'I/O primitives' }
CogVMSimulator >> ioScreenDepth [
	^DisplayScreen actualScreenDepth.
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioScreenScaleFactor [
	^ 1.0
]

{ #category : 'process primitive support' }
CogVMSimulator >> ioSetMaxExtSemTableSize: anInteger [
	"Inform the VM of the maximum size the image will grow the exernal semaphore table (specialObjectsArray at: 39) to.
	 This allows the VM to allocate storage such that external semaphores can be signalled without locking."
	extSemTabSize := anInteger
]

{ #category : 'process primitive support' }
CogVMSimulator >> ioSynchronousCheckForEvents [
	"Hook allowing the platform to do anything it needs to do synchronously."
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioUTCMicroseconds [
	"Return the value of the microsecond clock."
	"NOT.  Actually, we want something a lot slower and, for exact debugging,
	 something more repeatable than real time.  Dan had an idea: use the byteCount...
	 We increment byteCount in stackLimitFromMachineCode and a real machine
	 can easily run e.g. nfib at 6e7 / second, which this would be 1 usec ~= 60 byteCounts.
	 Use 10 byteCounts per usec by default; see CogVMSimulator class>>initializeWithOptions:objectMemoryClass:"

	^byteCount // ByteCountsPerMicrosecond + startMicroseconds
	
	"Dan:
	 At 20k bytecodes per second, this gives us about 200 ticks per second, or about 1/5
	 of what you'd expect for the real time clock.  This should still service events at one or
	 two per second"
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> ioUTCStartMicroseconds [
	"Answer the value of the microsecond clock at startup."

	^startMicroseconds ifNil:
		[self class initializationOptions
			at: #startMicroseconds
			ifAbsent: [[Time utcMicrosecondClock] on: Error do: [Time totalSeconds * 1000000]]]
]

{ #category : 'rump c stack' }
CogVMSimulator >> isOnRumpCStack: address [

	^ address
		  between: self rumpCStackAddress - self rumpCStackSize
		  and: self rumpCStackAddress
]

{ #category : 'primitive support' }
CogVMSimulator >> isPrimitiveFunctionPointerAnIndex [
	"We save slots in the method cache by using the primitiveFunctionPointer
	 to hold either a function pointer or the index of a quick primitive. Since
	 quick primitive indices are small they can't be confused with function
	 addresses.  But since we use 1001 and up for external primitives that
	 would be functions in the C VM but are indices under simulation we treat
	 values above 1000 as if they were pointers (actually indices into the
	 externalPrimitiveTable)"

	^primitiveFunctionPointer isInteger
	  and: [primitiveFunctionPointer >= 0
	  and: [primitiveFunctionPointer <= MaxQuickPrimitiveIndex]]
]

{ #category : 'plugin support' }
CogVMSimulator >> loadNewPlugin: pluginString [
	(breakSelector notNil
	 and: [(self strncmp: pluginString _: breakSelector _: pluginString size) = 0]) ifTrue:
		[self halt: pluginString].
	^(self tryLoadNewPlugin: pluginString pluginEntries: mappedPluginEntries) ifNotNil:
		[:entry|
		 pluginList := pluginList copyWith: entry.
		 entry]
]

{ #category : 'debugging traps' }
CogVMSimulator >> logSend: oop [
	sendCount := sendCount + 1.
	(printSends or: [printBytecodeAtEachStep]) ifTrue:
		[transcript print: byteCount; nextPut: $/; print: sendCount; space.
		 self printStringOf: oop.
		 transcript cr; flush]
]

{ #category : 'memory access' }
CogVMSimulator >> long32At: byteAddress [
	"Return the 32-bit word at byteAddress which must be 0 mod 4."
	^objectMemory long32At: byteAddress
]

{ #category : 'memory access' }
CogVMSimulator >> longAt: byteAddress [
	^objectMemory longAt: byteAddress
]

{ #category : 'memory access' }
CogVMSimulator >> longAt: byteAddress put: a32BitValue [
	^objectMemory longAt: byteAddress put: a32BitValue
]

{ #category : 'callback support' }
CogVMSimulator >> lookupOrdinaryNoMNUEtcInClass: class [
	lookupCount := lookupCount + 1.
	^super lookupOrdinaryNoMNUEtcInClass: class
]

{ #category : 'cog jit support' }
CogVMSimulator >> mapFunctionToAddress: aSymbolOrIndexOrBlock [
	"Hackery to deal with the plugin primitive simulation hoops.
	 aSymbolOrIndex is either a Symbol (#primitiveExternalCall) or an
	 index above 1001 (an index + 1000 into the externalPrimitiveTable)."
	| sobui symbolOrBlock |

	aSymbolOrIndexOrBlock = 0 ifTrue: [^0].
	self assert: (aSymbolOrIndexOrBlock isSymbol
				or: [aSymbolOrIndexOrBlock isBlock
				or: [aSymbolOrIndexOrBlock isInteger
					and: [aSymbolOrIndexOrBlock between: 1001 and: 2000]]]).
	symbolOrBlock := aSymbolOrIndexOrBlock isInteger
						ifTrue: [(self pluginEntryFor: aSymbolOrIndexOrBlock) at: 3]
						ifFalse: [aSymbolOrIndexOrBlock].
	uniqueIndices ifNil:
		[uniqueIndices := Dictionary new.
		 uniqueIndex := 65535].
	sobui := uniqueIndices at: symbolOrBlock ifAbsentPut: [uniqueIndex := uniqueIndex + 1].
	^cogit
		mapPrimitive: symbolOrBlock
		withIndexToUniqueAddress: sobui
]

{ #category : 'plugin support' }
CogVMSimulator >> mappedPluginEntries [
	^mappedPluginEntries
]

{ #category : 'debug support' }
CogVMSimulator >> maybeCheckStackDepth: delta sp: sp pc: mcpc [

	| asp bcpc startbcpc cogMethod csp debugStackPointers |
	debugStackDepthDictionary ifNil: [ ^ self ].
	(self isMachineCodeFrame: framePointer) ifFalse: [ ^ self ].
	cogMethod := self mframeCogMethod: framePointer.
	debugStackPointers := debugStackDepthDictionary
		                      at: cogMethod methodObject
		                      ifAbsentPut: [
		                      self debugStackPointersFor:
			                      cogMethod methodObject ].
	startbcpc := self startPCOfMethod: cogMethod methodObject.
	bcpc := cogit bytecodePCFor: mcpc startBcpc: startbcpc in: cogMethod.
	self assert: bcpc ~= 0.
	(cogMethod cmIsFullBlock and: [ cogit isNonLocalReturnPC: mcpc ])
		ifTrue: [
			| lastbcpc |
			"Method returns within a block (within an unwind-protect) must check the stack depth at the
		  return, not the bytecode following, but the pc mapping maps to the bytecode following the
		  return. lastBytecodePCForBlockAt:in: catches method returns at the end of a block, modifying
		  the bcpc to that of the return.  isNonLocalReturnPC: catches method returns not at the end.
		  Assumes method return bytecodes are 1 bytecode long;a  dodgy assumption, but good enough."
			lastbcpc := cogit endPCOf: cogMethod methodObject.
			bcpc > lastbcpc ifTrue: [ bcpc := lastbcpc ] ].
	asp := self
		       stackPointerIndexForFrame: framePointer
		       WithSP: sp + objectMemory wordSize.
	csp := debugStackPointers at: bcpc ifAbsent: [ -1 ].
	"Compensate for some edge cases"
	asp - delta = csp ifTrue: [ "Compensate for the implicit context receiver push in a trap bytecode with the absence of a contnuation.
		  Assumes trap bytecodes are 1 byte bytecodes."
		(SistaVM and: [ cogit isTrapAt: mcpc ]) ifTrue: [ csp := csp + 1 ] ].
	self assert: asp - delta + 1 = csp
]

{ #category : 'primitive support' }
CogVMSimulator >> maybeMapPrimitiveFunctionPointerBackToSomethingEvaluable [
	"In the real VM primitiveFunctionPointer is either an index (for quick primitives)
	 or a proper function pointer to a primitive.  In the simulator it may be a small
	 index (corresponding to a quick primitive index), a symbol (corresponding to
	 a function pointer) or an index into the externalPrimitiveTable, or an invalid
	 address that references an evaluable in the simulatedTrampolines dictionary
	 of the Cogit.  The simulator expects dispatchFunctionPointer to be called with
	 primitiveFunctionPointer being a symbol only for internal primitives.  External
	 primitives must have their funciton pointer mapped back to an index.  This
	 method does the mapping back from fake addresses."
	<doNotGenerate>
	(primitiveFunctionPointer isInteger
	 and: [self isExternalPrimitiveCall: newMethod]) ifTrue: "External prims must be evaluated by the right plugin..."
		[(cogit simulatedTrampolines at: primitiveFunctionPointer ifAbsent: nil) ifNotNil:
			[:evaluable| | pfp index externalIndex |
						"primitiveFunctionPointer := pfp"
						"(1 to: self mappedPluginEntries size) select: [:index| (self mappedPluginEntries at: index) third == evaluable]"
			 pfp := primitiveFunctionPointer.
			 index := self mappedPluginEntries findFirst: [:entry| entry third == evaluable].
			 self assert: index ~= 0.
			 externalIndex := 1000 + (externalPrimitiveTable object
										indexOf: index
										ifAbsent: [self error: 'entry not found']).
			 self assert: ((self pluginEntryFor: externalIndex) notNil
						   and: [(self pluginEntryFor: externalIndex) third == evaluable]).
			 primitiveFunctionPointer := externalIndex.
			 ^self]].
	
	(primitiveFunctionPointer isInteger and: [ 
		cogit simulatedTrampolines includesKey: primitiveFunctionPointer ])
		ifTrue: [ primitiveFunctionPointer := (cogit simulatedTrampolines at: primitiveFunctionPointer) selector  ].
	
	^super maybeMapPrimitiveFunctionPointerBackToSomethingEvaluable
]

{ #category : 'cog jit support' }
CogVMSimulator >> mcprimFunctionForPrimitiveIndex: primIndex [
	^self mapFunctionToAddress: (super mcprimFunctionForPrimitiveIndex: primIndex)
]

{ #category : 'spur bootstrap' }
CogVMSimulator >> methodCache [
	^methodCache
]

{ #category : 'simulation only' }
CogVMSimulator >> methodCacheSize [
	^MethodCacheSize * objectMemory wordSize
]

{ #category : 'simulation only' }
CogVMSimulator >> methodForContext: aContextOop [
	self assert: (objectMemory isContext: aContextOop).
	^objectMemory fetchPointer: MethodIndex ofObject: aContextOop
]

{ #category : 'simulation only' }
CogVMSimulator >> minBackwardJumpCountForCompile [
	<doNotGenerate>
	^minBackwardJumpCountForCompile
]

{ #category : 'simulation only' }
CogVMSimulator >> minBackwardJumpCountForCompile: n [
	<doNotGenerate>
	minBackwardJumpCountForCompile := n
]

{ #category : 'initialization' }
CogVMSimulator >> moveMethodCacheToMemoryAt: address [
	| oldMethodCache |
	oldMethodCache := methodCache.
	"In the VM the methodCache is written as a normal array with 1-relative addressing.
	 In C this works by allocating an extra element in the methodCache array (see
	 class-side declareCVarsIn:).  In simulation simply position the start of the methodCache
	 one word lower, achieving the same effect.  -1 because CArrayAccessor is 0-relative
	 and adds 1 on accesses itself."
	methodCache := CMethodCacheAccessor new
						objectMemory: objectMemory
						at: address
						array: oldMethodCache
						functionPointerIndex: MethodCachePrimFunction
						entrySize: MethodCacheEntrySize.
	self assert: address - objectMemory wordSize = self methodCacheAddress.
	1 to: MethodCacheSize do:
		[:i|
		self assert: (methodCache at: i) = 0].
	methodCache at: 1 put: 16rC4EC4.
	self assert: (objectMemory longAt: address) = 16rC4EC4.
	1 to: MethodCacheSize do:
		[:i|
		methodCache at: i put: (oldMethodCache at: i)]
]

{ #category : 'initialization' }
CogVMSimulator >> movePrimTraceLogToMemoryAt: address [
	| oldTraceLog |
	oldTraceLog := primTraceLog.
	primTraceLog := CArrayOfLongsAccessor new
						objectMemory: objectMemory at: address.
	self assert: address = self primTraceLogAddress.
	0 to: PrimTraceLogSize - 1 do:
		[:i|
		self assert: (primTraceLog at: i) = 0].
	primTraceLog at: 0 put: 16rC4EC4.
	self assert: (objectMemory longAt: address) = 16rC4EC4.
	0 to: PrimTraceLogSize - 1 do:
		[:i|
		primTraceLog at: i put: (oldTraceLog at: i)]
]

{ #category : 'debug support' }
CogVMSimulator >> nameOfClass: classOop [
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

{ #category : 'initialization' }
CogVMSimulator >> nextShortFrom: aStream [
	"Read a 16-bit quantity from the given (binary) stream."
	^self subclassResponsibility
]

{ #category : 'test support' }
CogVMSimulator >> numStackPages [
	^numStackPages
]

{ #category : 'stack pages' }
CogVMSimulator >> osCogStackPageHeadroom [
	"Notional headroom for the simulator.  The platform provides this in the real VM."
	^1024
]

{ #category : 'accessing' }
CogVMSimulator >> parent [
	^ parent
]

{ #category : 'accessing' }
CogVMSimulator >> parent: anObject [

	parent := anObject
]

{ #category : 'plugin support' }
CogVMSimulator >> pluginEntryFor: mapIndex [
	^mappedPluginEntries at: (mapIndex > 1000
								ifTrue: [externalPrimitiveTable at: mapIndex - 1001]
								ifFalse: [mapIndex])
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> pluginList: aCollection [ 

	pluginList := aCollection
]

{ #category : 'other primitives' }
CogVMSimulator >> primStringcomparewithcollated [
	^ self primitiveFail
]

{ #category : 'other primitives' }
CogVMSimulator >> primStringfindSubstringinstartingAtmatchTable [
	^self primitiveFail
]

{ #category : 'other primitives' }
CogVMSimulator >> primStringindexOfAsciiinStringstartingAt [
	^ self primitiveFail
]

{ #category : 'other primitives' }
CogVMSimulator >> primStringtranslatefromtotable [
	^ self primitiveFail
]

{ #category : 'simulation only' }
CogVMSimulator >> primTraceLogSize [
	^PrimTraceLogSize * objectMemory wordSize
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveContextAtPut [
	"| aContext |
	aContext := self stackValue: 2.
	(#(24205456 24205732) includes: aContext) ifTrue:
		[(self checkIsStillMarriedContext: aContext currentFP: framePointer)
			ifTrue: [self printFrame: (self frameOfMarriedContext: aContext)
						WithSP: (self frameOfMarriedContext: aContext) - 48]
			ifFalse: [self printContext: aContext]]."
	^super primitiveContextAtPut
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveDoPrimitiveWithArgs [
	| primIndex |
	primIndex := objectMemory integerValueOf: (self stackValue: 1).
	transcript nextPutAll: 'DO PRIMITIVE: '; print: (self functionPointerFor: primIndex inClass: nil); cr; flush.
	(#(76 "primitiveStoreStackp" 188 189 "eval method") includes: primIndex) ifTrue:
		[self halt].
	^super primitiveDoPrimitiveWithArgs
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveExecuteMethod [
	self halt: thisContext selector.
	^super primitiveExecuteMethod
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> primitiveFailCount [
	^ primitiveFailCount
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> primitiveFailCount: anInteger [ 

	primitiveFailCount := anInteger
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> primitiveFailCounting [

	"This primitive always fails, but it counts the number of calls. Useful for tests"

	primitiveFailCount := primitiveFailCount + 1.
	self primitiveFail.
	
]

{ #category : 'as yet unclassified' }
CogVMSimulator >> primitiveForceMachineCodeCompaction [
	
	"This primitive does not exist in the production VM. It is used in the tests to force the Code Compaction and to test it."
	
	self commenceCogCompiledCodeCompaction.
	self pop: 2 thenPushBool: true.

]

{ #category : 'other primitives' }
CogVMSimulator >> primitiveGetAttribute [
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

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveNewWithArg [
	"(objectMemory hasSpurMemoryManagerAPI
	 and: [self classNameOf: (self stackValue: 1) Is: 'Bitmap']) ifTrue:
		[self printExternalHeadFrame.
		 self halt]."
	^super primitiveNewWithArg
]

{ #category : 'control primitives' }
CogVMSimulator >> primitiveObject: actualReceiver perform: selector withArguments: argumentArray lookedUpIn: lookupClass [
	"Override to allow simulator to filter start-up items to avoid as-yet unsimulatable plugins."

	(self filterPerformOf: selector to: actualReceiver) ifTrue:
		[^self pop: argumentCount + 1 thenPush: actualReceiver].
	^super primitiveObject: actualReceiver perform: selector withArguments: argumentArray lookedUpIn: lookupClass
]

{ #category : 'object access primitives' }
CogVMSimulator >> primitiveObjectAt [
	"self transcript
		nextPutAll: (self nameOfClass: (self methodClassOf: (self stackValue: 1)));
		nextPutAll: '>>#';
		nextPutAll: (self stringOf: (self maybeSelectorOfMethod: (self stackValue: 1)));
		nextPutAll: ' objectAt: '; print: (objectMemory integerValueOf: self stackTop); cr; flush.
	self halt."
	^super primitiveObjectAt
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveObjectPointsTo [
	"self halt."
	^super primitiveObjectPointsTo
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitivePerform [
	| receiver selector |
	"If called from the machine code perform primitive, it should not have been found,
	 except that the cacheing for V3 has a mismatch between that used ror the first-level
	 method cache and inline caches."
	receiver := (self stackValue: argumentCount).
	selector := self stackValue: argumentCount - 1.
	((self methodHasCogMethod: newMethod)
	 and: [(objectMemory isCompactInstance: receiver) not]) ifTrue:
		[self deny: (self newMethodInLookupCacheAt: selector and: (objectMemory fetchClassTagOf: receiver))].
	self sendBreakpoint: selector receiver: receiver.
	(self filterPerformOf: selector to: receiver) ifTrue:
		[^self pop: argumentCount].
	^super primitivePerform
]

{ #category : 'system control primitives' }
CogVMSimulator >> primitiveSignalAtMilliseconds [
	super primitiveSignalAtMilliseconds.
	"self successful ifTrue:
		[Transcript
			cr; nextPutAll: thisContext selector;
			nextPutAll: ' now '; nextPutAll: self ioUTCMicroseconds hex;
			nextPutAll: ' wakeup '; nextPutAll: nextWakeupUsecs hex;
			nextPutAll: ' wakeup - now '; print: nextWakeupUsecs - self ioUTCMicroseconds; flush]"
]

{ #category : 'debugging traps' }
CogVMSimulator >> primitiveStoreStackp [
	"self printContext: (self stackValue: 1).
	self halt."
	"(self stackValue: 1) = 16r1934F80 ifTrue: [self halt]."
	super primitiveStoreStackp
]

{ #category : 'plugin support' }
CogVMSimulator >> primitiveThatDoNothingWithOneArgument [
	
	| arg recvr |

	arg := self stackTop.
	recvr := self stackValue: 1.
	
	recvr = objectMemory nilObject 
		ifTrue: [ ^ self primitiveFail ].
	
	^ self pop: 2 thenPush: arg.
]

{ #category : 'system control primitives' }
CogVMSimulator >> primitiveVMParameter [
	(argumentCount = 2
	 and: [(self stackValue: 1) = (objectMemory integerObjectOf: 34)]) ifTrue:
		[self halt].
	^super primitiveVMParameter
]

{ #category : 'system control primitives' }
CogVMSimulator >> primitiveVoidVMState [
	self halt.
	^super primitiveVoidVMState
]

{ #category : 'debug printing' }
CogVMSimulator >> print: it [

	traceOn ifTrue:
		[it isString ifTrue: [transcript nextPutAll: it] ifFalse: [it printOn: transcript]]
]

{ #category : 'debug printing' }
CogVMSimulator >> printActivationNameForSelector: aSelector startClass: startClass [
	super printActivationNameForSelector: aSelector startClass: startClass.
	"(self transcript dependents detect: [:d| d isTextView] ifNone: []) ifNotNil:
		[:textView| | text size |
		text := textView text asString.
		((size := text size) >= 30
		and: [(text copyFrom: size - 29 to: size) = 'Object(ProtoObject)>initialize']) ifTrue:
			[self doOrDefer: [self changed: #byteCountText; changed: #composeAll].
			 self halt]"
]

{ #category : 'debug printing' }
CogVMSimulator >> printChar: aByte [

	traceOn ifTrue: [ transcript nextPut: aByte asCharacter ].
]

{ #category : 'debug printing' }
CogVMSimulator >> printCurrentBytecodeOn: aStream [
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

{ #category : 'debug printing' }
CogVMSimulator >> printECS [
	self printCallStackFP: framePointer
]

{ #category : 'debug printing' }
CogVMSimulator >> printFloat: f [

	traceOn ifTrue: [ transcript print: f ]
]

{ #category : 'testing' }
CogVMSimulator >> printFrameAtEachStep [
	^printFrameAtEachStep
]

{ #category : 'debug printing' }
CogVMSimulator >> printFrameOop: name at: address [
	<inline: false>
	self printFrameOop: name obj: (stackPages longAt: address) at: address
]

{ #category : 'debug printing' }
CogVMSimulator >> printFrameOop: name obj: obj at: address [
	| it len |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages longAt: address.
	self printHex: address;
		printChar: $:.
	len := self strlen: name.
	1 to: 12 - len do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	self tab.
	it = obj
		ifTrue: [self tab]
		ifFalse: [self printHex: obj; space].
	self
		print: (self shortPrint: obj);
		cr
]

{ #category : 'debug printing' }
CogVMSimulator >> printFrameThing: name andFrame: theFP at: address [
	<var: #theFP type: #'char *'>
	| it |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages longAt: address.
	self printHex: address;
		printChar: $:.
	1 to: 12 - (self strlen: name) do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	it ~= 0 ifTrue:
		[self printChar: $=; printNum: it.
		 (objectMemory isInMemory: it) ifFalse:
			[(cogit lookupAddress: it) ifNotNil:
				[:label| self space; printChar: $(; print: label; printChar: $)]]].
	self print: ' frame: '; printHex: theFP; cr
]

{ #category : 'debug printing' }
CogVMSimulator >> printFrameThing: name at: address [
	| it |
	<inline: false>
	<var: #name type: #'char *'>
	<var: #address type: #'char *'>
	it := stackPages longAt: address.
	self printHex: address;
		printChar: $:.
	1 to: 12 - (self strlen: name) do: [:i| self printChar: $ ].
	self print: name;
		print: ': ';
		printHex: it.
	it ~= 0 ifTrue:
		[self printChar: $=; printNum: it.
		 (objectMemory isInMemory: it) ifFalse:
			[(cogit lookupAddress: it) ifNotNil:
				[:label| self space; printChar: $(; print: label; printChar: $)]]].
	self cr
]

{ #category : 'debug printing' }
CogVMSimulator >> printHex: anInteger [

	traceOn ifTrue:
		[| it16 |
		 it16 := anInteger radix: 16.
		 transcript
			next: 8 - it16 size put: Character space;
			nextPutAll: (anInteger storeStringBase: 16)]
]

{ #category : 'debug printing' }
CogVMSimulator >> printHexnp: anInteger [

	traceOn ifTrue:
		[transcript nextPutAll: ((anInteger ifNil: [0]) asInteger storeStringBase: 16)]
]

{ #category : 'debug printing' }
CogVMSimulator >> printHexnpnp: anInteger [
	"Print n in hex, in the form '1234', unpadded"
	traceOn ifTrue:
		[transcript nextPutAll: ((anInteger ifNil: [0]) printStringBase: 16)]
]

{ #category : 'debug printing' }
CogVMSimulator >> printLCS [
	self printCallStackFP: framePointer
]

{ #category : 'debug printing' }
CogVMSimulator >> printNum: anInteger [

	traceOn ifTrue: [ transcript print: anInteger ].
]

{ #category : 'rump c stack' }
CogVMSimulator >> printRumpCStackTo: address [
	self assert: (self isOnRumpCStack: address).
	objectMemory getMemoryMap startOfObjectMemory - objectMemory wordSize
		to: address
		by: objectMemory wordSize negated
		do:
			[:addr|
			self printHex: addr.
			addr = cogit processor sp
				ifTrue: [self print: ' sp->']
				ifFalse:
					[addr = cogit processor fp
						ifTrue: [self print: ' fp->']
						ifFalse: [self tab]].
			self tab; printHex: (objectMemory longAt: addr); cr]
]

{ #category : 'debug printing' }
CogVMSimulator >> printStringForCurrentBytecode [
	^String streamContents: [:str| self printCurrentBytecodeOn: str]
]

{ #category : 'debug printing' }
CogVMSimulator >> printStringOf: oop [

	super printStringOf: oop.
	traceOn ifTrue: [transcript flush]
]

{ #category : 'debug printing' }
CogVMSimulator >> printStringOf: oop on: aStream [
	| fmt cnt i |
	(objectMemory isIntegerObject: oop) ifTrue:
		[^nil].
	(oop between: objectMemory getMemoryMap startOfObjectMemory and: objectMemory freeStart) ifFalse:
		[^nil].
	(oop bitAnd: (objectMemory wordSize - 1)) ~= 0 ifTrue:
		[^nil].
	fmt := objectMemory formatOf: oop.
	fmt < 8 ifTrue: [ ^nil ].

	cnt := 100 min: (objectMemory lengthOf: oop).
	i := 0.
	[i < cnt] whileTrue: [
		aStream nextPut: (Character value: (objectMemory fetchByte: i ofObject: oop)).
		i := i + 1.
	].
	aStream flush
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> queueForwardedEvent: event [
	eventQueue ifNil:
		[eventQueue := SharedQueue new].
	eventQueue nextPut: event
]

{ #category : 'image save/restore' }
CogVMSimulator >> reverseBytesInImage [
	UIManager default
		informUser: 'Swapping bytes of foreign image...'
		during: [super reverseBytesInImage]
]

{ #category : 'method lookup cache' }
CogVMSimulator >> rewriteMethodCacheEntryForExternalPrimitiveToFunction: localPrimAddress [

	super rewriteMethodCacheEntryForExternalPrimitiveToFunction:
		(self mapFunctionToAddress: (localPrimAddress = 0
				  ifTrue: [ #primitiveFail ]
				  ifFalse: [ localPrimAddress ])).
	"Hack; the super call will rewrite the entry to the address of the function.
	 So (when simulating) undo the damage and put back the functionPointer"
	(methodCache at: lastMethodCacheProbeWrite + MethodCacheMethod)
	= newMethod ifTrue: [
		methodCache
			at: lastMethodCacheProbeWrite + MethodCachePrimFunction
			put: (self cCoerce: localPrimAddress to: #sqIntptr_t) ]
]

{ #category : 'rump c stack' }
CogVMSimulator >> rumpCStackAddress [

	rumpCStackBase ifNil: [ rumpCStackBase := memoryManager allocate: self rumpCStackSize  ].
 	^ rumpCStackBase + self rumpCStackSize
]

{ #category : 'rump c stack' }
CogVMSimulator >> rumpCStackSize [
	"Allocate a rump C stack for simulation.  This stack is used for C calls, i.e. calls
	 made into the simulated C run-time, typically of routines in CoInterpreter.
	 We also use it to hold in-memory copies of the cStackPointer and cFramePointer
	 variables for simulation speed.  Alas we don't use an in-memory copy of stackLimit,
	 because we need some activity to count in order to implement the ioMSecs
	 routine and the stackLimit check is the ideal one."
	^ RumpCStackSize
]

{ #category : 'testing' }
CogVMSimulator >> run [
	"Just run"

	quitBlock := [ ^ self close ].
	self initStackPages.
	self loadInitialContext.
	self initialEnterSmalltalkExecutive.
	instructionPointer := instructionPointer - 1
	"undo the pre-increment of IP before returning"
]

{ #category : 'primitive support' }
CogVMSimulator >> saneFunctionPointerForFailureOfPrimIndex: primIndex [
	"For simulation override to do the check specially when the
	 primitiveFunctionPointer is an invalid address proxy for a primitive."
	| basePrimitive |
	
	(primitiveFunctionPointer isInteger
	and: [self isPrimitiveFunctionPointerAnIndex not
	and: [primIndex ~= PrimNumberExternalCall
	and: [(self isMetaPrimitiveIndex: primIndex) not]]]) ifTrue:
		[basePrimitive := self functionPointerFor: primIndex inClass: objectMemory nilObject.
		 ^(cogit lookupAddress: primitiveFunctionPointer) endsWith: basePrimitive].

	^super saneFunctionPointerForFailureOfPrimIndex: primIndex
]

{ #category : 'I/O primitives' }
CogVMSimulator >> savedWindowSize [
	^savedWindowSize ifNil: [0]
]

{ #category : 'accessing' }
CogVMSimulator >> setBreakCount: anInteger [
	breakCount := anInteger
]

{ #category : 'accessing' }
CogVMSimulator >> setBreakSelectorLength: anInteger [ 
	
	breakSelectorLength := anInteger
]

{ #category : 'accessing' }
CogVMSimulator >> setImageName: aString [ 
	imageName := aString
]

{ #category : 'debug printing' }
CogVMSimulator >> shortPrintContext: aContext [
	transcript newLine.
	^super shortPrintContext: aContext
]

{ #category : 'process primitive support' }
CogVMSimulator >> signalSemaphoreWithIndex: index [
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

{ #category : 'debug printing' }
CogVMSimulator >> space [

	traceOn ifTrue: [ transcript space ]
]

{ #category : 'plugin support' }
CogVMSimulator >> sqGetInterpreterProxy [
	"I am basically my own proxy..."
	^self
]

{ #category : 'simulation only' }
CogVMSimulator >> sqMakeMemoryNotExecutableFrom: baseAddress To: limitAdress [ 
	^self
]

{ #category : 'memory access' }
CogVMSimulator >> sqMemoryExtraBytesLeft: includingSwap [
	^0
]

{ #category : 'memory access' }
CogVMSimulator >> sqShrinkMemory: oldLimit By: delta [
	transcript show: 'shrink memory from ', oldLimit printString, ' by ', delta printString, ' remember it doesn''t actually shrink in simulation'; cr.

	^ oldLimit
]

{ #category : 'I/O primitives support' }
CogVMSimulator >> stackLimitFromMachineCode [

	"Intercept accesses to the stackLimit from machine code to increment byteCount so that
	 ioMSecs/ioMicroseconds does something reasonable when we're purely in machine code.
	 Force an interrupt check every 2 ms in simulated time (2ms = the default heartbeat), or if
	 the profile tick has expired.."

	(byteCount := byteCount + 1) - lastPollCount
	>= (2000 * ByteCountsPerMicrosecond) ifTrue: [ 
		lastPollCount := byteCount ].
	(lastPollCount = byteCount or: [ 
		 nextProfileTick > 0 and: [ 
			 nextProfileTick <= self ioUTCMicroseconds ] ]) ifTrue: [ 
		suppressHeartbeatFlag
			ifTrue: [ self forceInterruptCheck ]
			ifFalse: [ self forceInterruptCheckFromHeartbeat ] "gets set by selector breakpoints" ].
	^ stackLimit
]

{ #category : 'stack pages' }
CogVMSimulator >> stackPage [
	^stackPage
]

{ #category : 'accessing' }
CogVMSimulator >> stackPages [
	^stackPages
]

{ #category : 'simulation only' }
CogVMSimulator >> startInContextSuchThat: aBlock [
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
		[^self error: 'no context found'].
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

{ #category : 'simulation only' }
CogVMSimulator >> systemAttributes [
	^systemAttributes
]

{ #category : 'debug printing' }
CogVMSimulator >> tab [

	traceOn ifTrue: [ transcript tab ].
]

{ #category : 'testing' }
CogVMSimulator >> testBecome [
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

{ #category : 'simulation only' }
CogVMSimulator >> transcript [
	^transcript
]

{ #category : 'simulation only' }
CogVMSimulator >> transcript: aTranscript [
	transcript := aTranscript
]

{ #category : 'interpreter shell' }
CogVMSimulator >> unableToReadImageError [
	self error:  'Read failed or premature end of image file'
]

{ #category : 'debug support' }
CogVMSimulator >> veryDeepCopyWith: deepCopier [
	"Override to short-circuit the copying of any VMPluginCodeGenerators referenced from mappedPluginEntries and
	 uniqueIndices. These can in turn hold onto Monticello state, resulting in a huge ammount of unnecessary copying."
	deepCopier references
		at: mappedPluginEntries ifAbsentPut: [mappedPluginEntries];
		at: uniqueIndices ifAbsentPut: [uniqueIndices].
	mappedPluginEntries do:
		[:tuple| | block |
		block := tuple third.
		deepCopier references at: block ifAbsentPut: [block]].
	uniqueIndices keysDo:
		[:block|
		deepCopier references at: block ifAbsentPut: [block]].
	^super veryDeepCopyWith: deepCopier
]

{ #category : 'file primitives' }
CogVMSimulator >> vmPathGet: stringBase Length: stringSize [
	| pathName stringOop |
	pathName := self vmPath.
	stringOop := stringBase - objectMemory baseHeaderSize. "Due to C call in Interp"
	1 to: stringSize do:
		[:i | objectMemory storeByte: i-1 ofObject: stringOop
			withValue: (pathName at: i) asciiValue].

]

{ #category : 'I/O primitives support' }
CogVMSimulator >> warpBits [

	^ myBitBlt warpBits
]

{ #category : 'UI' }
CogVMSimulator >> windowColorToUse [
	^Color lightBlue
]

{ #category : 'primitive support' }
CogVMSimulator >> windowIsClosing [

	quitBlock ifNotNil:
		[:effectiveQuitBlock|
		quitBlock := nil. "stop recursion on explicit window close."
		[effectiveQuitBlock value]
			on: BlockCannotReturn
			do: [:ex|]]	"Cause return from #test, et al"
]

{ #category : 'debug printing' }
CogVMSimulator >> withMemoryProtectionDo: aBlock [
	objectMemory writeProtectMemory.
	stackPages writeProtectMemory.
	^aBlock ensure:
		[objectMemory writeEnableMemory.
		 stackPages writeEnableMemory]
]

{ #category : 'frame access' }
CogVMSimulator >> withoutSmallIntegerTags: anInteger [
	| signBit |
	self assert: (anInteger >= 0 and: [anInteger highBit <= (objectMemory wordSize * 8)]).
	signBit := 1 << (objectMemory wordSize * 8 - 1).
	^(anInteger bitAnd: signBit) ~= 0
		ifTrue: ["negative"
				(anInteger bitClear: signBit + 1) - signBit]
		ifFalse: ["positive"
				anInteger - 1]
]
