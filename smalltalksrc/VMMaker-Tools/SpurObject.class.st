"
spur := SpurImage onFile: Smalltalk imagePath.
firstObject := spur firstObject.
secondObject := firstObject nextObject.
thirdObject := secondObject nextObject.
fourthObject := thirdObject nextObject.
fifthObject := fourthObject nextObject.

firstObject basicNumberOfSlots.
secondObject basicNumberOfSlots.
thirdObject basicNumberOfSlots.
fourthObject classIndex.

fifthObject classIndex.
fifthObject format.
fifthObject numberOfSlots.

fifthObject nextObject nextObject nextObject nextObject nextObject nextObject numberOfSlots.

(spur specialObjectsArray slotAt: 1) address = spur firstObject address.

1) Podemos encontrar a nil?
2) Podemos encontrar a true?
3) Podemos encontrar a false?

4) Podemos encontrar la tabla de clases?
  4.1) Como a partir de un class index (en el header del objeto) encontramos una clase en la tabla.
  4.2) Una vez que tenes la clase, recuperar el nombre de la clase (7ma variable es el nombre)
  4.3) Transformar un string en la imagen a un string normal.
  4.4) hacer un pretty print del objeto:
     - nombre de la clase
     - tipo de objeto / format
     - tamaño
"
Class {
	#name : #SpurObject,
	#superclass : #Object,
	#instVars : [
		'address',
		'image',
		'spurLayout'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #'as yet unclassified' }
SpurObject class >> on: address image: anImage [
	^self new
		address: address;
		image: anImage;
		yourself.
	
]

{ #category : #testing }
SpurObject >> = anotherObject [
	"if an oop is provided directly, we still allow the comparison"
	(anotherObject isKindOf: SmallInteger) ifTrue: [ ^ anotherObject = address ].
	
	^ anotherObject address = address
]

{ #category : #accessing }
SpurObject >> address [
	^ address
]

{ #category : #accessing }
SpurObject >> address: anInteger [ 
	address := anInteger
]

{ #category : #'accessing-slots' }
SpurObject >> allSlots [

	^ self spurLayout allSlots
]

{ #category : #converting }
SpurObject >> asLocalByteArray [ 
	^ self spurLayout asLocalByteArray 
]

{ #category : #converting }
SpurObject >> asSpurClass [
	^ SpurClass on: address image: self image
]

{ #category : #accessing }
SpurObject >> basicClass [ 

	^ self image hiddenRootsObj classOrNilAtIndex: self classIndex.
]

{ #category : #'accessing-slots' }
SpurObject >> basicNumberOfSlots [

	^ self spurLayout basicNumberOfSlots
]

{ #category : #'accessing-header' }
SpurObject >> byteSize [
	
	| numberOfSlots |
	numberOfSlots := self numberOfSlots.
	^ (numberOfSlots = 0
		ifTrue: [ 1 ]
		ifFalse: [ numberOfSlots ]) * self wordSize.
]

{ #category : #'accessing-header' }
SpurObject >> classIndex [
	
	^ self headerInteger bitAnd: (2 raisedTo: 22) -1
]

{ #category : #printing }
SpurObject >> classOop [
	^ self simulator fetchClassOf: address value
]

{ #category : #printing }
SpurObject >> classSpurObject [
	^ self class on: self classOop image: image 
]

{ #category : #accessing }
SpurObject >> endAddress [

	| basicSize padding |
	"All objects start aligned to 64 bits.
	This means all objects FINISH aligned to 64 bits too"
	basicSize := self headerSize + self byteSize.
	padding := basicSize % 8.
	^ address + basicSize + padding
]

{ #category : #accessing }
SpurObject >> fetchPointer: anInteger [

	^ self image fetchPointer: anInteger ofObject: self address value
]

{ #category : #'accessing-header' }
SpurObject >> format [
	
	^ (self headerInteger  >> 24) bitAnd: 2r11111
]

{ #category : #'gt-inspector-extension' }
SpurObject >> gtInspectorLayoutIn: composite [
	<gtInspectorPresentationOrder: 0>
	^self spurLayout gtInspectorLayoutIn: composite

]

{ #category : #accessing }
SpurObject >> header [
	^ self isImmediate ifFalse: [ image simulator baseHeader: address value]
]

{ #category : #'accessing-header' }
SpurObject >> headerInteger [

	^ self image headerOf: address
]

{ #category : #'accessing-header' }
SpurObject >> headerSize [

	^ 8 "always 64 bits"
]

{ #category : #constants }
SpurObject >> identityHashHalfWordMask [

	^16r3fffff
]

{ #category : #accessing }
SpurObject >> image [
	^ image
]

{ #category : #accessing }
SpurObject >> image: anImage [ 
	image := anImage
]

{ #category : #'accessing-header' }
SpurObject >> indexInClassTable [
	" Applies only if self contains a class.
	Returns the index in the classTable of the class stored in objOop"
	^ self rawHashBits
]

{ #category : #accessing }
SpurObject >> inspectionItems: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Oop'>
	| items |
	self isImmediate ifTrue: [
		^ address value inspectIntegerIn: aBuilder ].
	items := {
		#oop -> (self address value).
		#header -> (self header printStringBase: 2).
		#class -> self classSpurObject.
		#classIndex -> self classIndex.
		#numSlots -> self numSlots.	
		} asOrderedCollection .
	1 to: self numSlots do: [ :i|
		 items add: (('slot', i printString) -> (self slotAt: i)) ].
	items add: #format -> self format.
	items add: #hash -> self oopHash.
	items add: #pinned -> self isPinned.
	items add: (#space -> (self isOld ifTrue: 'Old Space' ifFalse: 'Young Space')).
	items add: #immutable -> self isImmutable.
	
	
	
	^ aBuilder newTable 
		addColumn: (SpStringTableColumn 
			title: 'Key'
			evaluated: [ :each | StObjectPrinter asTruncatedTextFrom: each key ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Value' 
			evaluated: [ :each | StObjectPrinter asTruncatedTextFrom: each value ])
			beSortable;
		items: items;
		yourself
]

{ #category : #'accessing-slots' }
SpurObject >> instanceVariables [
	^ (1 to: self numSlots) collect: [ :index | self slotAt: index ]
]

{ #category : #testing }
SpurObject >> isImmediate [
	^ self simulator isImmediate: address value
]

{ #category : #testing }
SpurObject >> isImmutable [
	^ image simulator isImmutable: address value
]

{ #category : #testing }
SpurObject >> isOld [
	^ self simulator isOldObject: self address value
]

{ #category : #testing }
SpurObject >> isYoung [
	^ self simulator isYoungObject: self address value
]

{ #category : #accessing }
SpurObject >> memory [

	^ image memory
]

{ #category : #something }
SpurObject >> nextObject [
	^ image nextObjectOf: self
]

{ #category : #'accessing-slots' }
SpurObject >> numSlots [
	^ self image numSlotsOf: self.
]

{ #category : #'accessing-header' }
SpurObject >> objectFormat [
	
	^ (self headerInteger >> 24) bitAnd: 2r11111
]

{ #category : #converting }
SpurObject >> oop [

	^ address
]

{ #category : #something }
SpurObject >> oopHash [
	^ image simulator rawHashBitsOf: address value
]

{ #category : #'accessing-header' }
SpurObject >> previousHeaderInteger [

	^ self memory integerAt: address + (0 - self headerSize) size: 4 signed: false
]

{ #category : #printing }
SpurObject >> printAsCharacter [
	^ self shouldBeImplemented
]

{ #category : #printing }
SpurObject >> printAsImmediate [
	self isCharacter ifTrue: [ ^ self printAsCharacter ].
	"default case is a smallInteger"
	^ self printAsInteger
]

{ #category : #printing }
SpurObject >> printAsInteger [
	^ 'SmallInteger: ', address printString
]

{ #category : #printing }
SpurObject >> printOn: aStream [
	| knownObject |
	knownObject := VMFrameBuilder new memory: self simulator ; adaptAddressToMemory: address.
	knownObject isString ifTrue: [ ^ aStream <<  knownObject ].

	self isImmediate ifTrue:[ ^ aStream << self printAsImmediate ].
	
	address printOn: aStream
	
]

{ #category : #printing }
SpurObject >> printString [
	| knownObject |
	knownObject := VMFrameBuilder new memory: self simulator ; adaptAddressToMemory: address.
	knownObject isString ifTrue: [ ^ knownObject ].

	self isImmediate ifTrue:[ ^ self printAsImmediate ].
	
	^ String streamContents: [ :s |
		s << address printString.
		]
	
]

{ #category : #'accessing-header' }
SpurObject >> rawHashBits [
	" Returns the index in the classTable of the class in objOop"
	self flag: #endianness.
	^((self memory unsignedLongAt: self oop + 4 bigEndian: false) bitAnd: self identityHashHalfWordMask)
]

{ #category : #accessing }
SpurObject >> simulator [
	^self image simulator
]

{ #category : #'accessing-slots' }
SpurObject >> slotAt: anIndex [
	"Api is 1 based but the memory api is O based"
	self numSlots >= anIndex ifFalse: [ SubscriptOutOfBounds signal ].
	^ SpurObject on: (self spurLayout slotAt: anIndex - 1) image: image 
]

{ #category : #'accessing-slots' }
SpurObject >> slotAt: anIndex put: aSpurObjectOrOop [
	"Our api is 1 based but the simulator is 0 based"

	| value |
	self numSlots >= anIndex ifFalse: [ SubscriptOutOfBounds signal ].	

	value := aSpurObjectOrOop isInteger 
		ifTrue:[ aSpurObjectOrOop ] 
		ifFalse: [ aSpurObjectOrOop address ].
		
	^ self simulator
		  storePointer: anIndex - 1
		  ofObject: self address
		  withValue: value
]

{ #category : #accessing }
SpurObject >> slots [
	^(self headerInteger bitAnd: 16rFF00000000000000) >> 56.
]

{ #category : #testing }
SpurObject >> spIsNil [
	^ self address = self image nilObject address
]

{ #category : #accessing }
SpurObject >> spurLayout [
	^ spurLayout ifNil: [ spurLayout := SpurLayout on: self image: image ]
]

{ #category : #accessing }
SpurObject >> spurLayout: anObject [
	spurLayout := anObject
]

{ #category : #testing }
SpurObject >> value [
	^ (address class includesBehavior: SpurObject) 
		ifTrue: [ address address ]
		ifFalse: [ address ]
]

{ #category : #accessing }
SpurObject >> vmClass [
	^self image classOf: self
]

{ #category : #printing }
SpurObject >> vmPrintOop [

	<primitive: 154>
]

{ #category : #constants }
SpurObject >> wordSize [

	^ self image wordSize 
]
