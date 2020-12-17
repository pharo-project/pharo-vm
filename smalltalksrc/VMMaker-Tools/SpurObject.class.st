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
	#category : #'VMMaker-Tools-Model'
}

{ #category : #'as yet unclassified' }
SpurObject class >> on: address image: anImage [
	^self new
		address: address;
		image: anImage;
		yourself.
	
]

{ #category : #something }
SpurObject >> = aSpurObject [
	^ self address = aSpurObject address
	
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

{ #category : #'as yet unclassified' }
SpurObject >> asLocalByteArray [ 
	^ self spurLayout asLocalByteArray 
]

{ #category : #converting }
SpurObject >> asSpurClass [
	^ SpurClass on: self address image: self image
]

{ #category : #accessing }
SpurObject >> basicClass [ 

	^ self image hiddenRootsObj classOrNilAtIndex: self classIndex.
]

{ #category : #'accessing-slots' }
SpurObject >> basicNumberOfSlots [

	^ self spurLayout basicNumberOfSlots
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SpurObject >> endAddress [

	| basicSize padding |
	"All objects start aligned to 64 bits.
	This means all objects FINISH aligned to 64 bits too"
	basicSize := self headerSize + self byteSize.
	padding := basicSize % 8.
	^ address + basicSize + padding
]

{ #category : #'as yet unclassified' }
SpurObject >> fetchPointer: anInteger [

	^ self image fetchPointer: anInteger ofObject: self address
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

{ #category : #'as yet unclassified' }
SpurObject >> instanceVariables [

	| numberOfSlots |
	numberOfSlots := self image numberOfSlotsOf: self.
	^ (1 to: numberOfSlots) collect: [ :index | self slotAt: index ]
]

{ #category : #accessing }
SpurObject >> memory [

	^ image memory
]

{ #category : #something }
SpurObject >> nextObject [

	| maybeObject |
	maybeObject := SpurObject on: self endAddress + self headerSize image: image.
	^ maybeObject basicNumberOfSlots = 16rFF
		ifTrue: [ maybeObject ]
		ifFalse: [ SpurObject on: self endAddress image: image ].
]

{ #category : #'as yet unclassified' }
SpurObject >> numberOfSlots [

	^ self image numberOfSlotsOf: self
]

{ #category : #'accessing-header' }
SpurObject >> objectFormat [
	
	^ (self headerInteger >> 24) bitAnd: 2r11111
]

{ #category : #'as yet unclassified' }
SpurObject >> oop [

	^ address
]

{ #category : #'accessing-header' }
SpurObject >> previousHeaderInteger [

	^ self memory integerAt: address + (0 - self headerSize) size: 4 signed: false
]

{ #category : #something }
SpurObject >> printOn: aStream [

	aStream nextPutAll: 'a(n) '.
	self vmClass printSimpleOn: aStream.
	aStream
		nextPutAll: '@';
		nextPutAll: self address hex
]

{ #category : #'as yet unclassified' }
SpurObject >> printSimpleOn: aLimitedWriteStream [ 
	
	aLimitedWriteStream nextPutAll: self address hex
]

{ #category : #'accessing-header' }
SpurObject >> rawHashBits [
	" Returns the index in the classTable of the class in objOop"
	self flag: #endianness.
	^((self memory unsignedLongAt: self oop + 4 bigEndian: false) bitAnd: self identityHashHalfWordMask)
]

{ #category : #'as yet unclassified' }
SpurObject >> simulator [
	^self image simulator
]

{ #category : #'accessing-slots' }
SpurObject >> slotAt: anInteger [ 
"Api is 1 based but the memory api is O based"

	^ self spurLayout slotAt: anInteger - 1
]

{ #category : #'as yet unclassified' }
SpurObject >> slotAt: anInteger put: aSpurObject [
"Our api is 1 based but the simulator is 0 based"
	^ self simulator
		  storePointer: anInteger - 1
		  ofObject: self address
		  withValue: aSpurObject address
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

{ #category : #'as yet unclassified' }
SpurObject >> vmClass [
	^self image classOf: self
]

{ #category : #'as yet unclassified' }
SpurObject >> vmPrintOop [

	<primitive: 154>
]

{ #category : #constants }
SpurObject >> wordSize [

	^ self image wordSize 
]
