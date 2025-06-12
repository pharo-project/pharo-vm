Class {
	#name : #PrintfFormatDescriptor,
	#superclass : #Object,
	#instVars : [
		'flush',
		'width',
		'precision',
		'lengthModifier'
	],
	#classVars : [
		'Flags',
		'LengthModifiers',
		'Operators'
	],
	#category : #Printf
}

{ #category : #'class initialization' }
PrintfFormatDescriptor class >> initialize [
	"PrintfFormatDescriptor initialize"
	Operators := Dictionary new.
	Operators
		at: $P put: #PrintStringFormatDescriptor; "This is an extension for Smalltalk"
		at: $c put: #PrintfCharacterFormatDescriptor;
		at: $C put: #PrintfCharacterFormatDescriptor; "Beware; Microsoft changes this..."
		at: $s put: #PrintfStringFormatDescriptor;
		at: $S put: #PrintfStringFormatDescriptor. "Beware; Microsoft changes this..."
	#($d $o $u $x $X $p)
		do: [:operator | Operators at: operator put: #PrintfNumberFormatDescriptor].
	#($e $E $f $g $G $a $A)
		do: [:operator | Operators at: operator put: #PrintfFloatFormatDescriptor].

	Flags := Dictionary new.
	Flags at: $- put: #leftFlush.
	Flags at: $+ put: #rightFlush.
	Flags at: $  put: #space.
	Flags at: $# put: #radix.
	Flags at: $0 put: #zero.

	LengthModifiers := 'hl'
]

{ #category : #'instance creation' }
PrintfFormatDescriptor class >> new [
	^ super new initialize
]

{ #category : #'instance creation' }
PrintfFormatDescriptor class >> newFrom: desc [
	| myself |
	myself := self new.
	myself perform: desc flush.
	myself width: desc width.
	myself precision: desc precision.
	desc lengthModifier ifNotNil: [:lm| myself lengthModifier: lm].
	^myself
]

{ #category : #'instance creation' }
PrintfFormatDescriptor class >> scanFrom: stream [
	| descriptor numberHolderDescriptor lengthModifier |
	descriptor := self new.
	[Flags includesKey: stream peek]
		whileTrue: [descriptor := descriptor perform: (Flags at: stream next)].
	stream peek isDigit ifTrue: [descriptor width: (Integer readFrom: stream)].
	stream peek == $. ifTrue:
		[stream next.
		 stream peek == $*
			ifTrue: [numberHolderDescriptor := PrintfNumberHolderDescriptor new. stream next]
			ifFalse: [descriptor precision: (Integer readFrom: stream)]].
	(LengthModifiers includes: stream peek) ifTrue: [lengthModifier := stream next].
	descriptor := descriptor operator: stream next.
	lengthModifier ifNotNil:
		[descriptor lengthModifier: lengthModifier].
	numberHolderDescriptor ifNotNil:
		[descriptor widthDescriptor: numberHolderDescriptor.
		 ^{numberHolderDescriptor. descriptor}].
	^descriptor
]

{ #category : #rendering }
PrintfFormatDescriptor >> applyOperator: object [
	self subclassResponsibility
]

{ #category : #private }
PrintfFormatDescriptor >> flush [
	^ flush
]

{ #category : #'initialize-release' }
PrintfFormatDescriptor >> initialize [
	flush := #yourself.
	width := 0
]

{ #category : #scanning }
PrintfFormatDescriptor >> leftFlush [
	flush := #leftFlush
]

{ #category : #private }
PrintfFormatDescriptor >> lengthModifier [
	^lengthModifier
]

{ #category : #private }
PrintfFormatDescriptor >> lengthModifier: characterOrString [
	lengthModifier := characterOrString
]

{ #category : #private }
PrintfFormatDescriptor >> operator: char [
	| myself |
	myself := (Smalltalk at: (Operators at: char)) newFrom: self.
	myself setOperator: char.
	^ myself
]

{ #category : #private }
PrintfFormatDescriptor >> padding [
	^ Character space
]

{ #category : #private }
PrintfFormatDescriptor >> precision [
	^ precision
]

{ #category : #private }
PrintfFormatDescriptor >> precision: anInteger [
	precision := anInteger
]

{ #category : #printing }
PrintfFormatDescriptor >> printOn: aStream [
	aStream nextPut: $%.
	flush == #leftFlush ifTrue: [aStream nextPut: $-].
	flush == #leftFlush ifTrue: [aStream nextPut: $+]
]

{ #category : #printing }
PrintfFormatDescriptor >> printWidthOn: aStream [
	width ~= 0 ifTrue: [width printOn: aStream].
	precision ifNotNil: [aStream nextPut: $.. precision printOn: aStream].
	lengthModifier isCharacter ifTrue: [aStream nextPut: lengthModifier].
	lengthModifier isString ifTrue: [aStream nextPutAll: lengthModifier]
]

{ #category : #scanning }
PrintfFormatDescriptor >> radix [
	^ (PrintfNumberFormatDescriptor newFrom: self) radix
]

{ #category : #rendering }
PrintfFormatDescriptor >> render: object for: printfFormatString [
	| string length stringSize |
	string := self applyOperator: object.
	stringSize := string basicSize.
	length := self stringLength.
	(length > 0 and: [length < stringSize]) ifTrue:
		[string := string copyFrom: 1 to: length].
	width = 0 ifTrue: [^string].
	^(String new: width withAll: self padding)
		copyReplaceFrom: (self startIndexOfCopyReplaceWithStringSize: stringSize)
		to: (self stopIndexOfCopyReplaceWithStringSize: stringSize)
		with: string
]

{ #category : #scanning }
PrintfFormatDescriptor >> rightFlush [
	flush := #rightFlush
]

{ #category : #private }
PrintfFormatDescriptor >> setOperator: char [
]

{ #category : #scanning }
PrintfFormatDescriptor >> space [
	^ (PrintfNumberFormatDescriptor newFrom: self) space
]

{ #category : #rendering }
PrintfFormatDescriptor >> startIndexOfCopyReplaceWithStringSize: anInteger [

	|start|
	start := flush == #leftFlush
		ifTrue: [1]
		ifFalse: [width - anInteger + 1]. 
	^(start max: 1)

]

{ #category : #rendering }
PrintfFormatDescriptor >> stopIndexOfCopyReplaceWithStringSize: anInteger [

	| stop |
	stop := flush == #leftFlush
		ifTrue: [anInteger]
		ifFalse: [width]. 
	^stop min: width
]

{ #category : #private }
PrintfFormatDescriptor >> stringLength [
	^precision ifNil: [0]
]

{ #category : #private }
PrintfFormatDescriptor >> width [
	^ width
]

{ #category : #private }
PrintfFormatDescriptor >> width: anInteger [
	width := anInteger
]

{ #category : #scanning }
PrintfFormatDescriptor >> zero [
	^ (PrintfNumberFormatDescriptor newFrom: self) zero
]
