Class {
	#name : #CogEventLogger,
	#superclass : #CogClass,
	#instVars : [
		'cogEventBuffer',
		'cogEventBufferSize',
		'cogEventBufferPosition',
		'cogit',
		'cogEventFile',
		'cogStatCounters',
		'currentCounterIndex',
		'coInterpreter'
	],
	#classVars : [
		'EMPTY_COUNTER_MARK',
		'INVALID_COUNTER_INDEX',
		'STAT_COUNTERS_SIZE'
	],
	#pools : [
		'CogAbstractRegisters',
		'CogMethodConstants',
		'LibFFIConstants'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #translation }
CogEventLogger class >> declareCVarsIn: aCCodeGenerator [ 

	"Declare any additional variables and/or add type declarations for existing variables."
	
	aCCodeGenerator removeVariable: #cogit.
	aCCodeGenerator removeVariable: #coInterpreter.
	
	aCCodeGenerator
		var: #cogEventBuffer
		declareC: 'char cogEventBuffer[255] '.
		
	aCCodeGenerator 
		var: #cogEventFile
		declareC: 'FILE* cogEventFile = NULL'.

	aCCodeGenerator 
		var: #currentCounterIndex
		declareC: 'sqInt currentCounterIndex = -1'.

	aCCodeGenerator 
		var: #cogStatCounters
		declareC: 'sqInt* cogStatCounters = NULL'	
]

{ #category : #initialization }
CogEventLogger class >> initializeWithOptions: options [

	STAT_COUNTERS_SIZE := 4096.
	EMPTY_COUNTER_MARK := BytesPerWord = 8 ifTrue: INT64_MIN ifFalse: INT32_MIN.
	INVALID_COUNTER_INDEX := STAT_COUNTERS_SIZE * 2.
]

{ #category : #translation }
CogEventLogger class >> isNonArgumentImplicitReceiverVariableName: aString [
	^#('cogit') includes: aString
]

{ #category : #translation }
CogEventLogger class >> mustBeGlobal: var [

	^#('cogEventFile') includes: var
]

{ #category : #translation }
CogEventLogger class >> typeForSelf [
	^#implicit
]

{ #category : #builder }
CogEventLogger >> addCharacter: aCharacter [

	<inline: #always>
	<var: #aCharacter type: #char>
	
	cogEventBufferPosition >= cogEventBufferSize 
		ifFalse: [ 
			cogEventBuffer at: cogEventBufferPosition put: aCharacter asInteger.
			cogEventBufferPosition := cogEventBufferPosition + 1 ]
]

{ #category : #builder }
CogEventLogger >> addClass: aClassOop [

	<inline: #always>
	<var: #aClassOop type: #'sqInt'>
	<var: #aBuffer type: #'char*'>
	
	| aBuffer |
	aClassOop = cogit objectMemory nilObject 
		ifTrue: [^ self addString: '(nil)'].

	aBuffer := self alloca: 129.

	cogit coInterpreter nameOfClass: aClassOop inBuffer: aBuffer withSize: 129.

	self addString: aBuffer.
]

{ #category : #builder }
CogEventLogger >> addLongLong: aLongLong [

	<inline: #always>
	<var: #aLongLong type: #'long long'>

	| size |

	cogEventBufferPosition = 0 
		ifFalse: [ self addCharacter: $, ].
	
	size := self 
		snprintf: cogEventBuffer + cogEventBufferPosition
		_: cogEventBufferSize - cogEventBufferPosition
		_: '%lld'
		_: aLongLong.
				
	cogEventBufferPosition := cogEventBufferPosition + size.
]

{ #category : #builder }
CogEventLogger >> addSelector: aSelectorOop [

	<inline: #always>
	<var: #aSelectorOop type: #'sqInt'>
	
	| format max quantity |

	aSelectorOop = cogit objectMemory nilObject 
		ifTrue: [^ self addString: '(nil)'].

	cogEventBufferPosition = 0 
		ifFalse: [ self addCharacter: $, ].

	format := cogit objectMemory formatOf: aSelectorOop.
	format < cogit objectMemory firstByteFormat 
		ifTrue: [^ self addString: '(non byte format)'].

	max := 128.
	quantity := max min: (cogit objectMemory lengthOf: aSelectorOop).

	self addCharacter: $".
	
	0 to: quantity - 1 do: [ :anIndex |
		self addCharacter: (cogit objectMemory fetchByte: anIndex ofObject: aSelectorOop )].
	
	self addCharacter: $".
	
]

{ #category : #builder }
CogEventLogger >> addString: aString [

	<inline: #always>
	<var: #aString type: #'char*'>
	
	| size | 
	
	cogEventBufferPosition = 0 
		ifFalse: [ self addCharacter: $, ].
	
	size := self strlen: aString.
	
	(cogEventBufferPosition + size + 2) >= cogEventBufferSize 
		ifFalse: [ 
			self addCharacter: $".
			self memcpy: cogEventBuffer + cogEventBufferPosition _: aString _: size. 
			cogEventBufferPosition := cogEventBufferPosition + size.
			self addCharacter: $"]
]

{ #category : #initialization }
CogEventLogger >> allocateStatCounters [
	
	cogStatCounters := self cCoerce: (self malloc: STAT_COUNTERS_SIZE * (self sizeof: #'sqInt')) to: #'sqInt *'.
	0 to: STAT_COUNTERS_SIZE - 1 do: [ :i | cogStatCounters at: i put: EMPTY_COUNTER_MARK ]
]

{ #category : #'memory access' }
CogEventLogger >> cCoerce: value to: cTypeString [
	"Type coercion. For translation a cast will be emmitted. When running in Smalltalk
	  answer a suitable wrapper for correct indexing."
	<doNotGenerate>

	^value
		ifNil: [value]
		ifNotNil: [value coerceTo: cTypeString sim: cogit coInterpreter]
]

{ #category : #builder }
CogEventLogger >> clearEvent [ 
	
	cogEventBuffer at: 1 put: 0.
	cogEventBufferSize := 254.
	cogEventBufferPosition := 0.
	
	cogEventFile isNil 
		ifTrue: [ 
			cogEventFile := self fopen: 'cogEvents.csv' _: 'w+'.
			cogEventFile 
				ifNil: [ self perror: 'fopen cogEvents.csv' ] ].


]

{ #category : #accessing }
CogEventLogger >> cogStatCounters [
	<doNotGenerate>
	
	^ cogStatCounters
]

{ #category : #accessing }
CogEventLogger >> cogStatCountersAt: anInteger [ 
	
	<doNotGenerate>
	
	^ cogStatCounters at: anInteger
]

{ #category : #accessign }
CogEventLogger >> cogStatCountersAt: anIndex put: aValue [ 
	
	<doNotGenerate>
	cogStatCounters at: anIndex put: aValue
]

{ #category : #accessing }
CogEventLogger >> cogit [
	<doNotGenerate>
	^ cogit
]

{ #category : #accessing }
CogEventLogger >> cogit: anObject [
	<doNotGenerate>
	
	cogit := anObject.
	coInterpreter := cogit coInterpreter
]

{ #category : #events }
CogEventLogger >> compactCompiledCodeFinished [

	self 
		clearEvent;
		forEvent: 'compactCompiledCode';
		logEvent.

]

{ #category : #counters }
CogEventLogger >> compileCountIncrement [ 
	
	| counterIndex address |

	<var: #address type:#sqInt>
	<var: #counterIndex type:#sqInt>

	<inline: true>

	counterIndex := self currentCounterIndex.
	address := self counterAddressFor: counterIndex.

	cogit backEnd hasRISCTempReg
		ifTrue: [  
				cogit MoveAw: address R: RISCTempReg.
				cogit AddCq: 1 R: RISCTempReg.
				cogit MoveR: RISCTempReg Aw: address]
		ifFalse: [ 
			 cogit PushR: TempReg.
			 cogit MoveAw: address R: TempReg.
			 cogit AddCq: 1 R: TempReg.
			 cogit MoveR: TempReg Aw: address.
			 cogit PopR: TempReg ]
	
]

{ #category : #util }
CogEventLogger >> counterAddressFor: anInteger [

	<returnTypeC: #usqInt>

	^ self
		  cCode: [ self addressOf: (cogStatCounters at: anInteger) ]
		  inSmalltalk: [ 
			  (cogit simulatedAddresses			
					simulatedArrayVariableGetter: #cogStatCountersAt:
					setter: #cogStatCountersAt:put: in: self 
					elementSize: (self sizeof: #'sqInt') elementCount: STAT_COUNTERS_SIZE) 
						addressForIndex: anInteger ]
]

{ #category : #counters }
CogEventLogger >> currentCounterIndex [

	<inline: true>
	<returnTypeC: #'sqInt'>

	^ currentCounterIndex = -1
		  ifTrue: [ currentCounterIndex := self nextCounterIndex ]
		  ifFalse: [ currentCounterIndex ]
]

{ #category : #events }
CogEventLogger >> ensureMethodIsCoggedEvent: aCogMethod [

	<api>
	<var: #aCogMethod type: #'CogMethod *'>

	self 
		clearEvent;
		forEvent: 'ensureMethodIsCogged';
		addClass: (cogit coInterpreter methodClassOf: aCogMethod methodObject);
		addSelector: (self methodSelector: aCogMethod);
		logEvent.
]

{ #category : #simulation }
CogEventLogger >> fflush: aZnCharacterWriteStream [ 

	<doNotGenerate>

	aZnCharacterWriteStream flush
]

{ #category : #simulation }
CogEventLogger >> fopen: aFileName _: aMode [ 
	
	<doNotGenerate>
	
	| inner |
	
	aMode = 'w+' ifFalse: [ self halt ].
	
	inner := aFileName asFileReference writeStream.
	inner truncate.
	
	^ (ZnNewLineWriterStream on: inner)
			forLf;
			yourself.
]

{ #category : #builder }
CogEventLogger >> forEvent: aString [

	<var: #aString type: #'char*'>
	
	self 
		addString: aString;
		addLongLong: coInterpreter ioUTCMicrosecondsNow
]

{ #category : #simulation }
CogEventLogger >> fprintf: aWriteStream _: aString _: aCArrayAccessor [ 
	
	<doNotGenerate>
	
	| str newString delimiterPosition |
	delimiterPosition := aCArrayAccessor object asString
		detectIndex: [ :e | e = Character null ] 
		ifNone: 0.
		
	delimiterPosition > 0 
		ifTrue: [ str := (aCArrayAccessor object first: delimiterPosition - 1) asString ]
		ifFalse: [ str := aCArrayAccessor object asString ].
	
	newString := aString printf: str.

	aWriteStream nextPutAll: newString.
]

{ #category : #accessing }
CogEventLogger >> initialize [
	<doNotGenerate>
	super initialize.
	
	currentCounterIndex := -1.
	cogEventBuffer := self alloca: 255.

]

{ #category : #events }
CogEventLogger >> invalidCounterIndex [
	
	<inline: true>
	^ INVALID_COUNTER_INDEX 
]

{ #category : #builder }
CogEventLogger >> logEvent [ 

	"Terminate the string in the buffer"
	cogEventBuffer 
		at: cogEventBufferPosition 
		put: 0.
		
	cogEventBufferPosition := cogEventBufferPosition + 1.
	
	cogEventFile ifNotNil:[ 
		self fprintf: cogEventFile _: '%s\n' _: cogEventBuffer.
		self fflush: cogEventFile ]
]

{ #category : #events }
CogEventLogger >> methodCollected: aCogMethod [

	<var: #aCogMethod type: #'CogMethod *'>
	cogEventBuffer at: 0 put: 0.

	self 
		clearEvent;
		forEvent: 'methodCollected';
		addClass: (cogit coInterpreter methodClassOf: aCogMethod methodObject);
		addSelector: (self methodSelector: aCogMethod);
		addLongLong: (self numberOfCalls: aCogMethod);
		logEvent.
	
	self releaseCounter: aCogMethod counterIndex.
	aCogMethod counterIndex: INVALID_COUNTER_INDEX.
]

{ #category : #events }
CogEventLogger >> methodJitted: aCogMethod [

	<var: #aCogMethod type: #'CogMethod *'>

	aCogMethod counterIndex: self currentCounterIndex.
	self resetCounterIndex.

	self 
		clearEvent;
		forEvent: 'methodJitted';
		addClass: (cogit coInterpreter methodClassOf: aCogMethod methodObject);
		addSelector: (self methodSelector: aCogMethod);
		logEvent.
]

{ #category : #utils }
CogEventLogger >> methodSelector: cogMethod [

	<var: #cogMethod type: 'CogMethod *'>
	
	cogMethod selector = cogit objectMemory nilObject
		ifTrue: [| s |
			(cogMethod cmType = CMMethod
			 and: [(s := cogit coInterpreter maybeSelectorOfMethod: cogMethod methodObject) notNil])
				ifTrue: [ ^ s ]
				ifFalse: [^ cogit objectMemory nilObject]]
		ifFalse: [^ cogMethod selector].

]

{ #category : #counters }
CogEventLogger >> nextCounterIndex [

	<returnTypeC: #'sqInt'>

	cogStatCounters 	
		ifNil: [ self allocateStatCounters ].

	0 to: STAT_COUNTERS_SIZE - 1 
		do: [ :i | (cogStatCounters at: i) = EMPTY_COUNTER_MARK 
				ifTrue: [ cogStatCounters at: i put: 0. 
							 ^ i ] ].
		
	self error: 'Could not find an empty counter'
]

{ #category : #counters }
CogEventLogger >> numberOfCalls: aCogMethod [

	<var: #aCogMethod type: #'CogMethod *'>
	<returnTypeC: #'long long'>
	
	^ cogStatCounters at: aCogMethod counterIndex 
]

{ #category : #events }
CogEventLogger >> recordDirectActivationOfQuickPrimitive: aMethodOop [

	| aMethodHeader aCogMethod |
	<api>
	<var: #aCogMethod type: #'CogMethod *'>

	aMethodHeader := coInterpreter rawHeaderOf: aMethodOop.
	(coInterpreter isCogMethodReference: aMethodHeader)
		ifFalse: [ ^ self ].

	aCogMethod := self cCoerceSimple: aMethodHeader to: #'CogMethod *'.
	cogStatCounters at: aCogMethod counterIndex put: (cogStatCounters at: aCogMethod counterIndex) + 1.

]

{ #category : #events }
CogEventLogger >> recordMethodActivatedAfterStackCheckOffset: aCogMethod [

	<api>
	<var: #aCogMethod type: #'CogMethod *'>

	cogStatCounters at: aCogMethod counterIndex put: (cogStatCounters at: aCogMethod counterIndex) + 1
		
]

{ #category : #Cogit }
CogEventLogger >> releaseCounter: anInteger [ 

	cogStatCounters at: anInteger put: EMPTY_COUNTER_MARK
]

{ #category : #counters }
CogEventLogger >> resetCounterIndex [

	currentCounterIndex := -1

]
