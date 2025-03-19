Class {
	#name : 'VMPrimitiveChangeClassParametrizedTest',
	#superclass : 'VMPrimitiveTest',
	#instVars : [
		'originBytes',
		'destinationBytes',
		'arraySize'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'building suites' }
VMPrimitiveChangeClassParametrizedTest class >> testParameters [

	^ super testParameters
	* (ParametrizedTestMatrix new
		forSelector: #originBytes addOptions: { 1. 2. 4. 8 };
		forSelector: #destinationBytes addOptions: { 1. 2. 4. 8 };
		forSelector: #arraySize addOptions: (1 to: 8);
		yourself)
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> arraySize [

	^ arraySize
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> arraySize: anObject [

	arraySize := anObject
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> destinationBytes [

	^ destinationBytes
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> destinationBytes: anObject [

	destinationBytes := anObject
]

{ #category : 'tests - primitiveClass' }
VMPrimitiveChangeClassParametrizedTest >> formatForBytes: bytes [

	bytes = 1 ifTrue: [ ^ memory firstByteFormat ].
	bytes = 2 ifTrue: [ ^ memory firstShortFormat ].
	bytes = 4 ifTrue: [ ^ memory firstLongFormat ].
	bytes = 8 ifTrue: [ ^ memory sixtyFourBitIndexableFormat ].
	self error: 'Ask Guille or Rasta'
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> originBytes [

	^ originBytes
]

{ #category : 'accessing' }
VMPrimitiveChangeClassParametrizedTest >> originBytes: anObject [

	originBytes := anObject
]

{ #category : 'tests - primitiveClass' }
VMPrimitiveChangeClassParametrizedTest >> testPrimitiveChangeClassOfIntegerArrayToByteArray [

	| integerArray byteArray conversionRatio |
	
	(arraySize * originBytes) \\ destinationBytes = 0 ifFalse: [ ^ self skip ].
	
	conversionRatio := originBytes / destinationBytes.
	integerArray := self newBitIndexableOfSize: arraySize
		bytesPerSlot: originBytes
			format: (self formatForBytes: originBytes).
	byteArray := self newBitIndexableOfSize: 0 "the size does not matter"
			bytesPerSlot: destinationBytes
		   format: (self formatForBytes: destinationBytes).

	interpreter
		push: integerArray;
		push: byteArray.

	interpreter primitiveChangeClass.

	self assert: interpreter successful.
	self assert: (memory fetchClassOf: integerArray) equals: (memory fetchClassOf: byteArray).
	self assert: (memory stSizeOf: integerArray) equals: arraySize * conversionRatio
]
