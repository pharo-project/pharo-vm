Class {
	#name : #CogEventLogger,
	#superclass : #CogClass,
	#instVars : [
		'cogEventBuffer',
		'cogEventBufferSize',
		'cogEventBufferPosition',
		'cogit',
		'cogEventFile'
	],
	#pools : [
		'CogMethodConstants'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #translation }
CogEventLogger class >> declareCVarsIn: aCCodeGenerator [ 

	"Declare any additional variables and/or add type declarations for existing variables."
	
	aCCodeGenerator removeVariable: #cogit.
	
	aCCodeGenerator
		var: #cogEventBuffer
		declareC: 'char cogEventBuffer[255] '.
		
	aCCodeGenerator 
		var: #cogEventFile
		declareC: 'FILE* cogEventFile = NULL'.

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
			cogEventBuffer at: cogEventBufferPosition put: aCharacter.
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

{ #category : #events }
CogEventLogger >> compactCompiledCodeFinished [

	self 
		clearEvent;
		forEvent: 'compactCompiledCode';
		logEvent.

]

{ #category : #builder }
CogEventLogger >> forEvent: aString [

	<var: #aString type: #'char*'>
	
	self 
		addString: aString;
		addLongLong: self ioUTCMicroseconds
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
		logEvent.
]

{ #category : #events }
CogEventLogger >> methodJitted: aCogMethod [

	<var: #aCogMethod type: #'CogMethod *'>
	cogEventBuffer at: 0 put: 0.

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
