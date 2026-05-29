Class {
	#name : 'VMByteArrayAccessPrimitive',
	#superclass : 'VMInterpreterTests',
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'running' }
VMByteArrayAccessPrimitive >> setUp [

	super setUp.
	self createLargeIntegerClasses.

	stackBuilder
		addNewFrame;
		buildStack
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testFFIntegerAtPutWithMin64bitLargeNegativeInteger [

	| array1 largeIntegerOop |
	
	"
	Hardcodes a byte array that has the same value as the following large negative integer.
	largeIntegerObject := memory signed64BitIntegerFor: -9223372036854775808."
	array1 := self new8BitIndexableOfSize: 8.
	#[1 0 0 0 0 0 0 128] withIndexDo: [ :byte :index |
		memory storeByte: index - 1 ofObject: array1 withValue: byte
	].

	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter primitiveLoadInt64FromBytes.
	self deny: interpreter failed.

	largeIntegerOop := interpreter stackTop.
	#[255 255 255 255 255 255 255 127] withIndexDo: [ :expectedByte :index |
		self assert: (memory fetchByte: index - 1 ofObject: largeIntegerOop) equals: expectedByte.
	]
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testLoad64bitLargeNegativeIntegerInByteArray [

	| array1 largeIntegerObject largeIntegerValue |
	array1 := self new8BitIndexableOfSize: 8.
	largeIntegerObject := memory signed64BitIntegerFor: -9223372036854775807.
	
	largeIntegerValue := interpreter signed64BitValueOf: largeIntegerObject.
	interpreter int64AtPointer: (memory firstBytePointerOfDataObject: array1) put: largeIntegerValue.
	
	"Read the 64 bits at the array starting at offset 0 as a signed integer"
	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter primitiveLoadInt64FromBytes.

	self assert: (interpreter signed64BitValueOf: interpreter stackTop) equals: largeIntegerValue
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testLoad64bitPositiveSmallIntegerFromByteArray [

	| array1 largeIntegerObject largeIntegerValue |
	array1 := self new8BitIndexableOfSize: 8.
	largeIntegerObject := memory signed64BitIntegerFor: 17.
	
	largeIntegerValue := interpreter signed64BitValueOf: largeIntegerObject.
	interpreter int64AtPointer: (memory firstBytePointerOfDataObject: array1) put: largeIntegerValue.
	#[17 0 0 0 0 0 0 0] withIndexDo: [ :byte :index |
		self assert: (memory fetchByte: index - 1 ofObject: array1) equals: byte.
	].

	"Read the 64 bits at the array starting at offset 0 as a signed integer"
	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter primitiveLoadInt64FromBytes.

	self assert: (memory isIntegerObject: interpreter stackTop).
	self assert: (memory integerValueOf: interpreter stackTop) equals: 17
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testLoadMin64bitLargeNegativeIntegerInByteArray [

	| array1 largeIntegerObject largeIntegerValue |
	array1 := self new8BitIndexableOfSize: 8.
	largeIntegerObject := memory signed64BitIntegerFor: -9223372036854775808.
	
	largeIntegerValue := interpreter signed64BitValueOf: largeIntegerObject.
	interpreter int64AtPointer: (memory firstBytePointerOfDataObject: array1) put: largeIntegerValue.
	
	"Read the 64 bits at the array starting at offset 0 as a signed integer"
	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter primitiveLoadInt64FromBytes.

	self assert: (interpreter signed64BitValueOf: interpreter stackTop) equals: largeIntegerValue
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testPrimitiveLoadInt64LoadsNegative32bitSmallInteger [

	| array1 largeIntegerObject largeIntegerValue |
	array1 := self new8BitIndexableOfSize: 8.
	largeIntegerObject := memory signed64BitIntegerFor: -2147483649.

	largeIntegerValue := interpreter signed64BitValueOf:
		                     largeIntegerObject.
	interpreter
		int64AtPointer: (memory firstBytePointerOfDataObject: array1)
		put: largeIntegerValue.
	#[ 255 255 255 127 255 255 255 255 ] withIndexDo: [ :byte :index |
		self
			assert: (memory fetchByte: index - 1 ofObject: array1)
			equals: byte ].

	"Read the 64 bits at the array starting at offset 0 as a signed integer"
	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter primitiveLoadInt64FromBytes.

	memory wordSize = 8
		ifTrue: [
			self assert: (memory isIntegerObject: interpreter stackTop).
			self
				assert: (memory integerValueOf: interpreter stackTop)
				equals: -2147483649 ]
		ifFalse: [ "32bit"
			| largeIntegerOop |
			self deny: (memory isIntegerObject: interpreter stackTop).
			largeIntegerOop := interpreter stackTop.
			#[ 1 0 0 128 0 0 0 0 ] withIndexDo: [
				:expectedByte
				:index |
				self
					assert: (memory fetchByte: index - 1 ofObject: largeIntegerOop)
					equals: expectedByte ] ]
]

{ #category : 'tests' }
VMByteArrayAccessPrimitive >> testStoreMin64bitLargeNegativeIntegerInByteArray [

	| array1 largeIntegerObject largeIntegerValue |
	array1 := self new8BitIndexableOfSize: 8.
	largeIntegerObject := memory signed64BitIntegerFor: -9223372036854775808.
	
	largeIntegerValue := interpreter signed64BitValueOf: largeIntegerObject.
	
	"Store the 64 bits at the array starting at offset 0 as a signed integer"
	interpreter push: array1.
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: largeIntegerObject.
	interpreter primitiveStoreInt64IntoBytes.

	self assert: interpreter failed
]
