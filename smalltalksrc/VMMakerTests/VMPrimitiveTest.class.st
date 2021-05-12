Class {
	#name : #VMPrimitiveTest,
	#superclass : #VMInterpreterTests,
	#instVars : [
		'imageName'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : #'VMMakerTests-InterpreterTests'
}

{ #category : #asserting }
VMPrimitiveTest >> assert: anOop contentEquals: oopToCompare [ 

	| numSlotOop numSlotOopToCompare |
	numSlotOop := memory numSlotsOf: anOop.
	numSlotOopToCompare := (memory numSlotsOf: anOop).
	self assert:  numSlotOop equals: numSlotOopToCompare.
	
	0 to: numSlotOop do: [:index | 
	self assert: (memory fetchByte: index ofObject: anOop) equals: (memory fetchByte: index ofObject:oopToCompare)		
		]	
	
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> installFloatClass [

	| classFloat |
	classFloat := self
		              newClassInOldSpaceWithSlots: 0
		              instSpec: memory firstLongFormat.
	memory setHashBitsOf: classFloat to: ClassFloatCompactIndex.
	memory
		storePointer: ClassFloatCompactIndex
		ofObject: memory classTableFirstPage
		withValue: classFloat

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
]

{ #category : #'as yet unclassified' }
VMPrimitiveTest >> newArrayWith: aCollection [ 
	| array |
	array := self newObjectWithSlots: aCollection size format: memory arrayFormat classIndex: memory arrayClassIndexPun.
	aCollection withIndexDo: [ :item :index | 
		memory storePointer: index - 1 ofObject: array withValue: item	
	].
	^ array
	
]

{ #category : #running }
VMPrimitiveTest >> setUp [
	
	"taken from VMSimpleStackBasedCogitBytecodeTest >> #setup"
	| newMethod ctx page |
	super setUp.

	"Create the root context with a valid method"
	"Let's create a method with enough size. It should have at least a literal (4 or 8 bytes depending the word size) and some bytecodes, so we can put the IP inside the method"
	newMethod := methodBuilder newMethod build.
	
	"The context has 5 (in 32 bits) or 9 (in 64 bits) as initial IP, as method has at least one literal"
	ctx := self newSmallContextReceiver: memory nilObject method: newMethod arguments: #() temporaries: #() ip: self wordSize + 1.
	
	page := interpreter makeBaseFrameFor: ctx.
	interpreter setStackPointersFromPage: page.
	interpreter setStackPageAndLimit: page.
	
	self setUpScheduler.
	imageName := VMPrimitiveTest name 
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> setUpForwardedObjects [
	| class1 class2 object1 object2 array1 array2 |
	
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2. 
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory isForwarded: object1) equals: true.
	self assert: (memory isForwarded: object2) equals: true.
	
	^ object1. 
]

{ #category : #running }
VMPrimitiveTest >> tearDown [

	imageName ifNotNil: [ imageName asFileReference ensureDelete ].
	super tearDown
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddFailsWithTypeErrorOnFirstOperand [

	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 

	self assert: interpreter failed.
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddFailsWithTypeErrorOnSecondOperand [

	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveAdd. 

	self assert: interpreter failed.
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddFailsWithTypeErrorPreservesStack [
	| string |
	
	string := self newString: '42'.
	interpreter push: string. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: string. 
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddWithNoOverflow [

	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 3). 
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddWithNoOverflowPopsOperands [

	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteAdd (1 2) for us to check that 1 and 2 were popped from the stack by checking that the next value is our marker, for instance 42"
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddWithOverflow [

	interpreter push: (memory integerObjectOf: memory maxSmallInteger).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 
	
	self assert: interpreter failed.
	
	
]

{ #category : #'tests - primitiveAdd' }
VMPrimitiveTest >> testPrimitiveAddWithOverflowPreservesStack [
	
	| maxSmallInt |
	
	maxSmallInt:= (memory integerObjectOf: memory maxSmallInteger). 
	
	interpreter push: maxSmallInt. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveAdd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: maxSmallInt.
	
	
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeCreatesForwardersForObjectsOfDifferentSize [
	| class1 class2 object1 object2 array1 array2 |
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory isForwarded: object1) equals: true.
	self assert: (memory isForwarded: object2) equals: true
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesClass [
	| class1 class2 object1 object2 array1 array2 |
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory fetchClassOf: object1) equals: class2.
	self assert: (memory fetchClassOf: object2) equals: class1
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesClassForObjectsOfDifferentSize [
	| class1 class2 object1 object2 array1 array2 |
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory fetchClassOf: (memory followForwarded: object1)) equals: class2.
	self assert: (memory fetchClassOf: (memory followForwarded: object2)) equals: class1
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesContents [
	| class object1 object2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	object1 := memory instantiateClass: class.
	memory storeInteger: 0 ofObject: object1 withValue: 42.
	
	object2 := memory instantiateClass: class.
	memory storeInteger: 0 ofObject: object2 withValue: 75.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory fetchInteger: 0 ofObject: object1) equals: 75.
	self assert: (memory fetchInteger: 0 ofObject: object2) equals: 42.
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesContentsForObjectsOfDifferentSize [
	| class1 class2 object1 object2 array1 array2 |
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	memory storeInteger: 0 ofObject: object1 withValue: 42.
	
	object2 := memory instantiateClass: class2.
	memory storeInteger: 0 ofObject: object2 withValue: 75.
	memory storeInteger: 1 ofObject: object2 withValue: 76.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory fetchInteger: 0 ofObject: (memory followForwarded: object1)) equals: 75.
	self assert: (memory fetchInteger: 1 ofObject: (memory followForwarded: object1)) equals: 76.
	self assert: (memory fetchInteger: 0 ofObject: (memory followForwarded: object2)) equals: 42
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesIdentityHash [
	| class object1 object2 hash1 hash2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class.
	
	hash1 := memory rawHashBitsOf: object1.
	hash2 := memory rawHashBitsOf: object2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory rawHashBitsOf: object1) equals: hash2.
	self assert: (memory rawHashBitsOf: object2) equals: hash1
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeExchangesIdentityHashForObjectsOfDifferentSize [
	| class1 class2 object1 object2 hash1 hash2 array1 array2 |
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	hash1 := memory rawHashBitsOf: object1.
	
	object2 := memory instantiateClass: class2.
	hash2 := memory rawHashBitsOf: object2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory rawHashBitsOf: (memory followForwarded: object1)) equals: hash2.
	self assert: (memory rawHashBitsOf: (memory followForwarded: object2)) equals: hash1
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeFailsForImmediates [
	| class immediate array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	immediate := memory integerObjectOf: 42.
	
	array1 := self newArrayWith: { class }.
	array2 := self newArrayWith: { immediate }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrInappropriate.
	
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeFailsForImmutableObject [
	| class object1 object2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class.
	memory setIsImmutableOf: object2 to: true. 
	
	array1 := self newArrayWith: { object2 }.
	array2 := self newArrayWith: { object1 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrNoModification
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeFailsForPinnedObject [
	| class object1 object2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class isPinned: true.
	 
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrObjectIsPinned
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeOneWayCopyHashIfCopyHasIsFalseDoesNotCopyHash [
	| class object1 object2 hash2BeforeBecome array1 array2 object2FromForwarder |
	class := self
		newClassInOldSpaceWithSlots: 1
		instSpec: memory nonIndexablePointerFormat.
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class.
	hash2BeforeBecome := memory hashBitsOf: object2.
	array1 := self newArrayWith: {object1}.
	array2 := self newArrayWith: {object2}.
	interpreter push: array1.
	interpreter push: array2.
	interpreter push: memory falseObject.
	interpreter primitiveArrayBecomeOneWayCopyHash.
	object2FromForwarder := memory followForwarded: object1.
	
	self
		assert: (memory hashBitsOf: object2FromForwarder)
		equals: hash2BeforeBecome.
	self assert: (memory hashBitsOf: object2) equals: hash2BeforeBecome
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeOneWayCopyHashIfCopyHasIsTrueCopiesHash [
	| class object1 object2 hash1 hash2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class.
	hash1 := memory hashBitsOf: object1.
	hash2 := memory hashBitsOf: object2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	interpreter push: memory trueObject.
	
	interpreter primitiveArrayBecomeOneWayCopyHash.
	
	self assert: (memory hashBitsOf: object2) equals: hash1.
	self deny: (memory hashBitsOf: object2) equals: hash2
]

{ #category : #'tests - become' }
VMPrimitiveTest >> testPrimitiveArrayBecomeOneWayCreatesForwardThatPointsToOriginalObject [
	| class object1 object2 array1 array2 |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class.
	object2 := memory instantiateClass: class.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2.
	interpreter push: memory trueObject.
	
	interpreter primitiveArrayBecomeOneWayCopyHash.
	
	self assert: (memory followForwarded: object1)  equals: object2
]

{ #category : #'tests - primitiveAsCharacter' }
VMPrimitiveTest >> testPrimitiveAsCharacter [
	interpreter push: (memory integerObjectOf: 65).
	
	interpreter primitiveAsCharacter. 

	self deny: interpreter failed.
	self assert: interpreter stackTop equals: (memory characterObjectOf: 65). 
]

{ #category : #'tests - primitiveAsCharacter' }
VMPrimitiveTest >> testPrimitiveAsCharacterCompilesWithNoArg [
	
	interpreter primitiveAsCharacter. 

	self deny: interpreter failed.
]

{ #category : #'tests - primitiveAsCharacter' }
VMPrimitiveTest >> testPrimitiveAsCharacterFailsForOutOfRangeArg [
	
	interpreter push: memory maxSmallInteger. 
	
	interpreter primitiveAsCharacter. 

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveAsCharacter' }
VMPrimitiveTest >> testPrimitiveAsCharacterFailsWithNonIntObject [
	
	interpreter push: memory trueObject. 
	
	interpreter primitiveAsCharacter. 
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveAtDoesntFailsIfObjectIsImmutable [

	| class object slotIndex objectToPutInSlot |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: memory trueObject.
	interpreter primitiveSetImmutability.
	
	slotIndex := memory integerObjectOf: 1.
	objectToPutInSlot := memory instantiateClass: class indexableSize: 1.
	interpreter push: object.
	interpreter push: slotIndex.
	
	interpreter primitiveAt.
	
	self deny: interpreter failed.
	
self assert: (memory fetchPointer: 0 ofObject: object) equals: interpreter stackTop. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveAtFailsForImmediate [

	interpreter push: (memory integerObjectOf: 32).
	interpreter push: (memory integerObjectOf: 1).
	interpreter primitiveAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrInappropriate. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveAtFailsForNonIndexableObject [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter primitiveAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveAtFailsForNonIntegerArgument [
	| class objectInstance |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	objectInstance := memory instantiateClass: class.
	
	interpreter push: objectInstance.
	interpreter push: memory falseObject.
	interpreter primitiveAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsForForwardedReceiver [
	| class objectInstance biggerClass objectForwarded array1 array2 |
	"Forwarding an object happens when becoming it with a bigger object"
	
	"We push receiver then 3 arguments"
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	objectInstance := memory instantiateClass: class.
	
	biggerClass := self newClassInOldSpaceWithSlots: 50 instSpec: memory nonIndexablePointerFormat.
	objectForwarded :=  memory instantiateClass: biggerClass.
	
	array1 := self newArrayWith: { objectInstance }.
	array2 := self newArrayWith: { objectForwarded }.
	
	interpreter push: array1.
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	interpreter push: objectInstance.
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: memory falseObject.
	interpreter argumentCount: 3.
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsForImmediate [

	interpreter push: (memory integerObjectOf: 32).
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrInappropriate. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsForMoreThanTwoArguments [
	| class objectInstance |
	"I don't know how to force a bad argument count."
	
	self skip.
	
	
	"We push receiver then 3 arguments"
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	objectInstance := memory instantiateClass: class.
	
	interpreter push: objectInstance.
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: memory falseObject.
	interpreter push: memory falseObject.
	interpreter argumentCount: 4.
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrInappropriate. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsForNonIndexableObject [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsForNonIntegerArgument [
	| class objectInstance |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	objectInstance := memory instantiateClass: class.
	
	interpreter push: objectInstance.
	interpreter push: memory falseObject.
	interpreter push: memory falseObject.
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument. 
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveAtPutFailsIfObjectIsContext [

	| class object slotIndex objectToPutInSlot |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := interpreter ensureFrameIsMarried: interpreter framePointer SP: interpreter stackPointer.

	interpreter push: object.
	
	slotIndex := memory integerObjectOf: 1.
	objectToPutInSlot := memory instantiateClass: class indexableSize: 1.
	interpreter push: object.
	interpreter push: slotIndex.
	interpreter push: objectToPutInSlot.
	
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	"2 is the bad receiver exception in the special object array for the primFailCode"
	self assert: interpreter primFailCode equals: 2. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutFailsIfObjectIsImmutable [

	| class object slotIndex objectToPutInSlot |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: memory trueObject.
	interpreter primitiveSetImmutability.
	
	slotIndex := memory integerObjectOf: 1.
	objectToPutInSlot := memory instantiateClass: class indexableSize: 1.
	interpreter push: object.
	interpreter push: slotIndex.
	interpreter push: objectToPutInSlot.
	
	interpreter primitiveAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrNoModification. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutPutsTheValueForAnIndexableObject [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveAtPut.
	
	self deny: interpreter failed.
	self assert: (memory fetchPointer: 0 ofObject: object) equals: memory falseObject.
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveAtPutPutsTheValueForAnIndexableObject2 [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	
	self assert: interpreter stackTop equals: memory trueObject.
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveAtReturnsTheValueForAnIndexableObject [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	
	interpreter primitiveAtPut.
	
	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	
	interpreter primitiveAt. 
	
	self deny: interpreter failed.
	self assert: (memory fetchPointer: 0 ofObject: object) equals: memory falseObject.
	self assert: interpreter stackTop equals: memory falseObject. 
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBifShitBorderCase [

	interpreter push: (memory integerObjectOf: (memory maxSmallInteger >> memory numSmallIntegerTagBits)).
	interpreter push: (memory integerObjectOf: (memory wordSize * -8) + (memory numSmallIntegerTagBits )).
	
	interpreter primitiveBitShift. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0).
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAnd1 [

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitAnd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAnd2 [

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r0).
	
	interpreter primitiveBitAnd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAndFailsPreservesStack [
	
	| string |
	
	string := self newString: '42'.
	interpreter push: string. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitAnd. 
	
	self assert: interpreter failed. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: string. 
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAndFailsWithTypeErrorOnFirstOperand [
	
	| string |
	
	string := self newString: '42'.
	interpreter push: string. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitAnd. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAndFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveBitAnd. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAndWithMaxBitIntWithNoDataLoss [
	"This insures the fact that no data is lost during the processing of usqInt by the primitive"

	| num |
	
	num := memory maxCInteger >> memory numSmallIntegerTagBits.
	
	interpreter push: (memory integerObjectOf: num).
	interpreter push: (memory integerObjectOf: num - 1 ).
	
	interpreter primitiveBitAnd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: (num - 1)).
]

{ #category : #'tests - primitiveBitAnd' }
VMPrimitiveTest >> testPrimitiveBitAndWithNegativNumbers [
"111... 010110 -> -42
 000... 010110 ->  21"""

	interpreter push: (memory integerObjectOf: -42).
	interpreter push: (memory integerObjectOf: 21).
	
	interpreter primitiveBitAnd. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 21). 
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOr1 [ 

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOr2 [

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r0).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
	
	
	
	
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOr3 [

	interpreter push: (memory integerObjectOf: 16r0).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
	
	
	
	
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOr4 [

	"This is to insure that primitiveBitOr executes a logical Or and not an XOr"
	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
	
	
	
	
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOrFailsPreservesStack [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter failed. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: memory trueObject.
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOrFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitOr. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOrFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveBitOr. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOrWithMaxBitIntWithNoDataLoss [
	"This insure the fact that no data is lost during the processing of usqInt by the primitive"

	| num |
	
	num := memory maxCInteger >> memory numSmallIntegerTagBits.
	
	interpreter push: (memory integerObjectOf: num).
	interpreter push: (memory integerObjectOf: num - 1 ).
	
	interpreter primitiveBitOr. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: (num - 1)).
]

{ #category : #'tests - primitiveBitOr' }
VMPrimitiveTest >> testPrimitiveBitOrWithNegativNumbers [

	interpreter push: (memory integerObjectOf: -73).
	interpreter push: (memory integerObjectOf: (memory maxCInteger >> memory numSmallIntegerTagBits) - 1).
	
	interpreter primitiveBitOr. 

	self assert: interpreter stackTop equals: (memory integerObjectOf: ((memory maxCInteger >> memory numSmallIntegerTagBits) - 1)).
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShift1 [

	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory integerObjectOf: -16). 
	
	interpreter primitiveBitShift. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftFailsWithTypeErrorOnFirstOperand [

	interpreter push: memory trueObject. 
	interpreter push: (memory integerObjectOf: (memory maxSmallInteger)).
	
	interpreter primitiveBitShift. 
	
	self
		assert: interpreter failed. 
		
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: (memory maxSmallInteger)).
	interpreter push: memory trueObject. 
	
	interpreter primitiveBitShift. 
	
	self
		assert: interpreter failed. 
		
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftFailsWithTypeErrorPreservesStack [

	interpreter push: memory trueObject. 
	interpreter push: (memory integerObjectOf: (memory maxSmallInteger)).
	
	interpreter primitiveBitShift. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: (memory maxSmallInteger)).
	self assert: (interpreter stackValue: 1) equals: (memory trueObject). 	
		
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftLeft [

	interpreter push: (memory integerObjectOf: 16). 
	interpreter push: (memory integerObjectOf: 1). 
	
	interpreter primitiveBitShift. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 32). 
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftRight [

	interpreter push: (memory integerObjectOf: 16). 
	interpreter push: (memory integerObjectOf: -1). 
	
	interpreter primitiveBitShift. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 8). 
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftWithNegativNumbers [

	memory wordSize = 8 ifFalse: [ ^ self ]. "The 32 bits version of the primitive doesn't handle the negativ number case"
	interpreter push: (memory integerObjectOf: memory minSmallInteger).
	interpreter push: (memory integerObjectOf: -2).
	interpreter primitiveBitShift.
	self
		assert: interpreter stackTop
		equals: (memory integerObjectOf: 16r1C00000000000000)
]

{ #category : #'tests - primitiveBitShift' }
VMPrimitiveTest >> testPrimitiveBitShiftWithOverflow [
"Insures no data is lost when bitshift overflows the integer type."

	interpreter push: memory maxSmallInteger. 
	interpreter push: (memory integerObjectOf: 1). 
	
	interpreter primitiveBitShift. 
	
	self assert: (interpreter stackTop) > (memory maxSmallInteger).
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXor1 [

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXor2 [

	interpreter push: (memory integerObjectOf: 16r0).
	interpreter push: (memory integerObjectOf: 16r1).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXor3 [

	interpreter push: (memory integerObjectOf: 16r1).
	interpreter push: (memory integerObjectOf: 16r0).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXor4 [

	interpreter push: (memory integerObjectOf: 16r0).
	interpreter push: (memory integerObjectOf: 16r0).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXorFailsPreservesStack [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter failed. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: memory trueObject.
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXorFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveBitXor. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXorFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveBitXor. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXorWithMaxBitIntWithNoDataLoss [
	"This guarantees the fact that no data is lost during the processing of usqInt by the primitive"
	"111... 111
	 100... 000
	Xor
	011... 111 = maxSmallInt >> 1 "

	| num |
	
	num := memory maxCInteger >> memory numSmallIntegerTagBits.
	
	interpreter push: (memory integerObjectOf: num).
	interpreter push: (memory integerObjectOf: (1 << (memory numSmallIntegerBits - 1))).
	
	interpreter primitiveBitXor. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: ((memory maxCInteger >> (memory numSmallIntegerTagBits + 1)))).
]

{ #category : #'tests - primitiveBitXor' }
VMPrimitiveTest >> testPrimitiveBitXorWithNegativNumbers [

	interpreter push: (memory integerObjectOf: -42).
	interpreter push: (memory integerObjectOf: (memory maxCInteger >> memory numSmallIntegerTagBits) - 1).
	
	interpreter primitiveBitXor. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 40).
]

{ #category : #'tests - primitiveClass' }
VMPrimitiveTest >> testPrimitiveClassDoesntFailsForForwardedObjectAndArgCountEqualsZero [
	
	interpreter push: self setUpForwardedObjects. 
	
	interpreter primitiveClass. 
	
	self deny: interpreter failed. 
	
	
	
	
]

{ #category : #'tests - primitiveClass' }
VMPrimitiveTest >> testPrimitiveClassFailsForForwardedObjectAndArgCountMoreThanZero [
	
	interpreter push: self setUpForwardedObjects. 
	interpreter argumentCount: 1. 
	
	interpreter primitiveClass. 
	
	self assert: interpreter failed. 
	
	
	
	
]

{ #category : #'tests - primitiveClass' }
VMPrimitiveTest >> testPrimitiveClassReturnsAClass [

	interpreter push: memory trueObject.
	
	interpreter primitiveClass. 

	self assert: interpreter stackTop equals: (memory fetchClassOf: (memory trueObject)). 
	
	
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDiv [

	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDiv. 
	
	self deny: interpreter failed. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 7). 
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivFailPreservesStack [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	
	interpreter primitiveDiv. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: (memory trueObject).
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDiv. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveDiv. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivOnNonIntegerResultRoundsAndDoesntFail [
"In the primitive implementation of quo, it doesnt push the rest of the operation on the stack"

	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveDiv. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 10). 
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivWith0DivisionOnFirstOperand [

	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveDiv. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivWith0DivisionOnSecondOperand [

	interpreter push: (memory integerObjectOf: 4).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveDiv. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivWithNegativeNumbers [
	
	interpreter push: (memory integerObjectOf: 4).
	interpreter push: (memory integerObjectOf: -2).
	
	interpreter primitiveDiv. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: -2). 
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivWithNegativeNumbers2 [
	
	interpreter push: (memory integerObjectOf: -9).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveDiv. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: -3). 
]

{ #category : #'tests - primitiveDiv' }
VMPrimitiveTest >> testPrimitiveDivWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDiv. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteDiv (2 2) for us to check that 2 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivide [

	interpreter push: (memory integerObjectOf: 4).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDivide. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 2). 
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideFailPreservesStack [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDivide. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: (memory trueObject).
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideFailsOnFloatResult [
	"The interpreter fails because 42%4 != 0"
	
	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveDivide. 
	
	self assert: interpreter failed. 
	

]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDivide. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveDivide. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideWith0DivisionOnFirstOperand [

	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveDivide. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideWith0DivisionOnSecondOperand [

	interpreter push: (memory integerObjectOf: 4).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveDivide. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideWithNegativeNumbers [
	
	interpreter push: (memory integerObjectOf: 6).
	interpreter push: (memory integerObjectOf: -2).
	
	interpreter primitiveDivide. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: -3). 
]

{ #category : #'tests - primitiveDivide' }
VMPrimitiveTest >> testPrimitiveDivideWithNegativeNumbers2 [
	
	interpreter push: (memory integerObjectOf: -42).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveDivide. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: -21). 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualFailsWithFloat [

	self installFloatClass.
	
	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory floatObjectOf: 15.0).
	
	interpreter primitiveEqual.
	
	self assert: interpreter failed
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveEqual.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithNoError1 [

	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory integerObjectOf: 15).
	
	interpreter primitiveEqual.

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithNoError2 [

	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveEqual.

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithNoErrorPopsOperands [

	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveEqual. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteEqual (12 16) for us to check that 12 and 16 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithTypeErrorOnFirstOperand [

	interpreter push: (memory falseObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveEqual.

	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveEqual' }
VMPrimitiveTest >> testPrimitiveEqualWithTypeErrorOnSecondOperand [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory trueObject).
	
	interpreter primitiveEqual.

	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveGetImmutabilityOfImmediateReturnsTrue [

	interpreter push: (memory integerObjectOf: 1).
	interpreter primitiveGetImmutability.
	
	self assert: interpreter stackTop equals: memory trueObject
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveGetImmutabilityOnANewObjectIsFalse [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter primitiveGetImmutability.

	self assert: interpreter stackTop equals: memory falseObject
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveGetImmutabilityReturnsTrueIfObjectIsImmutable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.
	memory setIsImmutableOf: object to: true. 

	interpreter push: object.
	interpreter primitiveGetImmutability.
	
	self assert: interpreter stackTop equals: memory trueObject
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualFailsWithFloat [

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
	self installFloatClass.
	
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory floatObjectOf: 16.0).
	
	interpreter primitiveGreaterOrEqual.
	
	self assert: interpreter failed
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveGreaterOrEqual. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory trueObject).
	
	interpreter primitiveGreaterOrEqual. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveGreaterOrEqual.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualWithNoError1 [

	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveGreaterOrEqual. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualWithNoError2 [
	
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveGreaterOrEqual. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualWithNoErrorEquals [
	
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveGreaterOrEqual. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveGreaterOrEqual' }
VMPrimitiveTest >> testPrimitiveGreaterOrEqualWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveGreaterOrEqual. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteGreaterOrEqual (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanFailsWithFloat [

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
	self installFloatClass.
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory floatObjectOf: 16.0).
	interpreter primitiveGreaterThan.
	self assert: interpreter failed
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveGreaterThan. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory trueObject).
	
	interpreter primitiveGreaterThan. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveGreaterThan.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanWithNoError1 [
	
	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: -1000).
	
	interpreter primitiveGreaterThan. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanWithNoError2 [
	
	interpreter push: (memory integerObjectOf: -1000).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveGreaterThan. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanWithNoErrorEquals [
	
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveGreaterThan. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveGreaterThan' }
VMPrimitiveTest >> testPrimitiveGreaterThanWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveGreaterThan. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteGreaterThen (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42).
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalDoesntFailForForwardedOopOnOtherObjectWithArgCountLessThanOne [
	|object1|
	"Tests the case where objectArg = 1 and: isOopFowarded: stackTop"
	
	object1 := self setUpForwardedObjects. 
	
	interpreter argumentCount: 1.
	
	interpreter push: (memory integerObjectOf: 16). 
	interpreter push: object1. 
	
	interpreter primitiveIdentical. 

	self deny: interpreter failed. 
]

{ #category : #'as yet unclassified' }
VMPrimitiveTest >> testPrimitiveIdenticalFailsForForwardedOop [
	| class1 class2 object1 object2 array1 array2|
	
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array2.
	
	interpreter primitiveArrayBecome.
	
	interpreter push: object1. 
	interpreter push: array2. 
	
	interpreter primitiveIdentical. 

	self assert: interpreter primFailCode equals: PrimErrBadArgument.
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalFailsForForwardedOopOnOtherObject [
	|object1|
	"Tests the case where objectArg > 1 and: isOopFowarded: stackTop"
	
	object1 := self setUpForwardedObjects.
	
	interpreter argumentCount: 3.
	
	interpreter push: (memory integerObjectOf: 16). 
	interpreter push: object1.
	 
	interpreter primitiveIdentical. 

	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadArgument.
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalFailsForForwardedOopOnReceiver [
	|object1|
	
	object1 := self setUpForwardedObjects. 
	
	interpreter push: object1. 
	interpreter push: (memory integerObjectOf: 16). 
	
	interpreter primitiveIdentical. 

	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadArgument.
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalReturnsBool [

	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveIdentical. 

	self assert: interpreter stackTop equals: memory falseObject. 
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalReturnsFalseForObjectsWithSameValueButDifferentType [
	| object1 object2 |
	
	object1:= memory integerObjectOf: 16. 
	object2:= memory floatObjectOf: 16.0 . 
	
	interpreter push: object1 . 
	interpreter push: object2. 
	
	interpreter primitiveIdentical. 

	self assert: interpreter stackTop equals: memory falseObject. 
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalReturnsFalseWithWrongArgCount [
	| object |
	
	object:= memory integerObjectOf: 16. 
	
	interpreter push: object. 

	interpreter primitiveIdentical. 
	
	self deny: interpreter failed. 

	self assert: interpreter stackTop equals: memory falseObject. 
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalReturnsTrueForIdenticalObject [
	| object |
	
	object:= memory integerObjectOf: 16. 
	interpreter push: object. 
	interpreter push: object. 
	
	interpreter primitiveIdentical. 

	self assert: interpreter stackTop equals: memory trueObject. 
	
]

{ #category : #'tests - primitiveIdentical' }
VMPrimitiveTest >> testPrimitiveIdenticalReturnsTrueForObjectsWithSameValue [
	| object1 object2 |
	
	object1:= memory integerObjectOf: 16. 
	object2:= memory integerObjectOf: 16. 
	
	interpreter push: object1 . 
	interpreter push: object2. 
	
	interpreter primitiveIdentical. 

	self assert: interpreter stackTop equals: memory trueObject. 
	
]

{ #category : #'tests - primitiveImmediateAsInteger' }
VMPrimitiveTest >> testPrimitiveImmediateAsIntegerFailsWithTypeError [

	interpreter push: (memory trueObject).
	
	interpreter primitiveImmediateAsInteger. 

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
	
	
]

{ #category : #'tests - primitiveImmediateAsInteger' }
VMPrimitiveTest >> testPrimitiveImmediateAsIntegerWithChar [

	interpreter push: (memory characterObjectOf: 66).
	
	interpreter primitiveImmediateAsInteger. 

	self deny: interpreter failed.
	self assert: interpreter stackTop equals: (memory integerObjectOf: 66).  
	
	
]

{ #category : #'tests - primitiveImmediateAsInteger' }
VMPrimitiveTest >> testPrimitiveImmediateAsIntegerWithFloat [

	interpreter push: (memory integerObjectOf: 0). 
	
	interpreter primitiveImmediateAsInteger. 

	self deny: interpreter failed.
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
	
	
]

{ #category : #'tests - primitiveImmediateAsInteger' }
VMPrimitiveTest >> testPrimitiveImmediateAsIntegerWithInt [

	interpreter push: (memory integerObjectOf: memory maxSmallInteger).
	
	interpreter primitiveImmediateAsInteger. 

	self deny: interpreter failed.
	self assert: interpreter stackTop equals: (memory integerObjectOf: memory maxSmallInteger). 
	
	
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveInstVarAtOverBoundShouldFailForIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter primitiveInstVarAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveInstVarAtOverBoundShouldFailForNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter primitiveInstVarAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex.
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveInstVarAtPutOverBoundShouldFailForIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory arrayFormat .
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory falseObject.
	interpreter primitiveInstVarAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveInstVarAtPutOverBoundShouldFailNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory falseObject.
	interpreter primitiveInstVarAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex.
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveInstVarAtPutPutsTheValueForNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveInstVarAtPut.
	
	self deny: interpreter failed.
	self assert: (memory fetchPointer: 0 ofObject: object) equals: memory falseObject.
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveInstVarAtReturnsTheValueForNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	
	interpreter primitiveInstVarAtPut.
	
	interpreter push: memory trueObject. 
	"This is a token to make sure that the object that is tested is the one returned by primitiveInstVarAtPut, and not the one pushed before"
	
	interpreter push: object. 
	interpreter push: (memory integerObjectOf: 1).
	
	interpreter primitiveInstVarAt. 
	
	self deny: interpreter failed.
	self assert: interpreter stackTop equals: memory falseObject.
]

{ #category : #'tests - primitiveIsPinned' }
VMPrimitiveTest >> testPrimitiveIsPinnedBool [

	interpreter push: (memory trueObject). 
	
	interpreter primitiveIsPinned. 
	
	self deny: interpreter failed. 
	self assert: interpreter stackTop equals: memory falseObject. 
]

{ #category : #'tests - primitiveIsPinned' }
VMPrimitiveTest >> testPrimitiveIsPinnedFailsForForwardedObjects [

	interpreter push: self setUpForwardedObjects. 
	
	interpreter primitiveIsPinned. 
	
	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveIsPinned' }
VMPrimitiveTest >> testPrimitiveIsPinnedFailsForImmediateObjects [

	interpreter push: (memory integerObjectOf: 16). 
	
	interpreter primitiveIsPinned. 
	
	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveIsPinned' }
VMPrimitiveTest >> testPrimitiveIsPinnedSmallInt [

	interpreter push: (memory integerObjectOf: 10). 
	
	interpreter primitiveIsPinned. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualFailsWithFloat [

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
	self installFloatClass.
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory floatObjectOf: 16.0).
	interpreter primitiveLessOrEqual.
	self assert: interpreter failed
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveLessOrEqual.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualWithNoError1 [
	
	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveLessOrEqual. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualWithNoError2 [
	
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveLessOrEqual. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualWithNoErrorEquals [
	
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveLessOrEqual. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveLessOrEqual. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteAdd (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42).
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualsFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveLessOrEqual. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveLessOrEqual' }
VMPrimitiveTest >> testPrimitiveLessOrEqualsFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveLessOrEqual.
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanFailsWithFloat [

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
	self installFloatClass.
	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory floatObjectOf: 15.0).
	interpreter primitiveLessThan.
	self assert: interpreter failed
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveLessThan. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory trueObject).
	
	interpreter primitiveLessThan. 
	
	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveLessThan.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanWithNoError1 [
	
	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveLessThan. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanWithNoError2 [
	
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveLessThan. 

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanWithNoErrorEquals [
	
	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveLessThan. 

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveLessThan' }
VMPrimitiveTest >> testPrimitiveLessThanWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveLessThan. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteLessThan (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveMod' }
VMPrimitiveTest >> testPrimitiveMod [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMod. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveMod' }
VMPrimitiveTest >> testPrimitiveModFailPreservesStack [

	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	
	interpreter primitiveMod. 
	
	self assert: interpreter failed. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: (memory trueObject).
]

{ #category : #'tests - primitiveMod' }
VMPrimitiveTest >> testPrimitiveModFailsWithTypeErrorOnFirstOperand [

	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveMod. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveMod' }
VMPrimitiveTest >> testPrimitiveModFailsWithTypeErrorOnSecondOperand [

	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory falseObject).
	
	
	interpreter primitiveMod. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveMod' }
VMPrimitiveTest >> testPrimitiveModNegativeValue [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: -2).
	
	interpreter primitiveMod. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyBy0 [

	interpreter push: (memory integerObjectOf: memory maxCInteger >> memory numSmallIntegerTagBits).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveMultiply. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyFailsWithTypeErrorOnFirstOperand [

	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMultiply. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveMultiply. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyFailsWithTypeErrorPreservesStack [

	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	
	interpreter primitiveMultiply. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: (memory trueObject).
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyWithNoOverflow [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMultiply. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 32). 
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyWithNoOverflowPopsOperands [

	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMultiply. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteMultiply (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyWithOverflow [

	interpreter push: (memory integerObjectOf: (memory maxSmallInteger)).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMultiply. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveMultiply' }
VMPrimitiveTest >> testPrimitiveMultiplyWithOverflowPreservesStack [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: memory maxSmallInteger).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveMultiply. 
	
	self assert: (interpreter stackValue: 2) equals: (memory integerObjectOf: 16). 
]

{ #category : #'tests - primitiveNew' }
VMPrimitiveTest >> testPrimitiveNewCreatesTheObjectInYoungSpace [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNew.

	self deny: interpreter failed.
	self assert: (memory isYoung: interpreter stackTop)
]

{ #category : #'tests - primitiveNew' }
VMPrimitiveTest >> testPrimitiveNewCreatesTheObjectWithCorrectSize [
	| class |
	class := self newClassInOldSpaceWithSlots: 4 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNew.

	self assert: (memory numSlotsOf: interpreter stackTop) equals: 4
]

{ #category : #'tests - primitiveNew' }
VMPrimitiveTest >> testPrimitiveNewInFullNewSpaceAllocatesInOldSpace [
	| class |
	"Allocate enough space to generate a full new space"
	self assert: (memory
				allocateSlots: (memory scavengeThreshold - memory freeStart) // self wordSize - 1
				format: memory arrayFormat
				classIndex: memory arrayClassIndexPun) isNotNil.

	class := self newClassInOldSpaceWithSlots: 256 instSpec: memory nonIndexablePointerFormat.
	interpreter push: class.
	interpreter primitiveNew.
	
	self deny: interpreter failed.
	self deny: (memory isYoung: interpreter stackTop)
]

{ #category : #'tests - primitiveNew' }
VMPrimitiveTest >> testPrimitiveNewInFullNewSpaceScheduleGC [
	| class |
	"Allocate enough space to generate a full new space"
	self assert: (memory
				allocateSlots: (memory scavengeThreshold - memory freeStart) // self wordSize - 1
				format: memory arrayFormat
				classIndex: memory arrayClassIndexPun) isNotNil.
	
	class := self newClassInOldSpaceWithSlots: 256 instSpec: memory nonIndexablePointerFormat.
	
	interpreter push: class.
	interpreter primitiveNew.

	self assert: memory needGCFlag
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewIsNotPinned [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNew.

	self deny: (memory isPinned: interpreter stackTop)
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedCreatesTheObjectInOldSpace [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNewPinned.

	self deny: interpreter failed.
	self deny: (memory isYoung: interpreter stackTop)
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedObjectInFullNewSpaceIsSchedulingGC [
	| class |
	class := self newClassInOldSpaceWithSlots: 3 instSpec: memory nonIndexablePointerFormat.

	"Allocate enough space to generate a full new space"
	self assert: (memory
				allocateSlots: (memory scavengeThreshold - memory freeStart) // self wordSize - 3
				format: memory arrayFormat
				classIndex: memory arrayClassIndexPun) isNotNil.

	self deny: memory needGCFlag.
	
	interpreter push: class.
	interpreter primitiveNewPinned.

	self deny: interpreter failed.
	self assert: memory needGCFlag 
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedObjectIsNotSchedulingGC [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNewPinned.

	self deny: interpreter failed.
	self deny: memory needGCFlag 
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedObjectIsPinned [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter primitiveNewPinned.

	self deny: interpreter failed.
	self assert: (memory isPinned: interpreter stackTop)
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedWithArgsCreatesTheObjectInOldSpace [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 7).
	interpreter primitiveNewWithArgPinned.

	self deny: interpreter failed.
	self deny: (memory isYoung: interpreter stackTop)
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedWithArgsObjectIsNotSchedulingGC [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 7).
	interpreter primitiveNewWithArgPinned.

	self deny: interpreter failed.
	self deny: memory needGCFlag 
]

{ #category : #'tests - primitiveNewPinned' }
VMPrimitiveTest >> testPrimitiveNewPinnedWithArgsObjectIsPinned [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 7).
	interpreter primitiveNewWithArgPinned.

	self deny: interpreter failed.
	self assert: (memory isPinned: interpreter stackTop)
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgCreatesTheObjectInYoungSpace [
	| newObj class |

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 7).

	interpreter primitiveNewWithArg.

	newObj := interpreter stackTop.

	self deny: interpreter failed.
	self assert: (memory isYoung: newObj)
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgCreatesTheObjectWithCorrectSize [
	| newObj class |

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 7).

	interpreter primitiveNewWithArg.

	newObj := interpreter stackTop.

	self assert: (memory numSlotsOf: newObj) equals: 7
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgInFullNewSpaceAllocatesInOldSpace [
	| newObj class |

	"Allocate enough space to generate a full new space"
	self assert: (memory
				allocateSlots: (memory scavengeThreshold - memory freeStart) // self wordSize - 1
				format: memory arrayFormat
				classIndex: memory arrayClassIndexPun) isNotNil.

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 256).

	interpreter primitiveNewWithArg.

	newObj := interpreter stackTop.

	self assert: (memory isOldObject: newObj)
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgInFullNewSpaceScheduleGC [
	| class |

	"Allocate enough space to generate a full new space"
	self assert: (memory
				allocateSlots: (memory scavengeThreshold - memory freeStart) // self wordSize - 1
				format: memory arrayFormat
				classIndex: memory arrayClassIndexPun) isNotNil.

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 256).

	interpreter primitiveNewWithArg.

	self assert: memory needGCFlag
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgWithInvalidClassFails [
	| class |

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: 256).

	interpreter primitiveNewWithArg.

	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : #'tests - primitiveNewWithArgs' }
VMPrimitiveTest >> testPrimitiveNewWithArgWithNegativeArgumentFails [
	| class |

	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter push: (memory integerObjectOf: -256).

	interpreter primitiveNewWithArg.

	self assert: interpreter primFailCode equals: PrimErrBadArgument
]

{ #category : #'tests - primitiveNew' }
VMPrimitiveTest >> testPrimitiveNewWithInvalidClassFails [
	| class |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory arrayFormat.

	interpreter push: class.
	interpreter primitiveNew.

	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualFailsWithFloat [

	"This simulated classFloat class is necessary because the 32bits VM cannot instanciate boxed floats by itself"
	self installFloatClass.
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory floatObjectOf: 16.0).
	interpreter primitiveNotEqual.
	self assert: interpreter failed
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithNegativeNumbers [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -13).
	
	interpreter primitiveNotEqual.

	self deny: interpreter failed. 
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithNoError1 [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveNotEqual.

	self assert: interpreter stackTop equals: (memory falseObject). 
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithNoError2 [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 42).
	
	interpreter primitiveNotEqual.

	self assert: interpreter stackTop equals: (memory trueObject). 
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithNoErrorPopsOperands [

	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 18).
	
	interpreter primitiveNotEqual. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteNotEqual (16 18) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"

	self assert: interpreter stackTop equals: (memory integerObjectOf: 42).
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithTypeErrorOnFirstOperand [

	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitiveNotEqual.

	self assert: interpreter failed. 
]

{ #category : #'tests - primitiveNotEqual' }
VMPrimitiveTest >> testPrimitiveNotEqualWithTypeErrorOnSecondOperand [

	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory trueObject).
	
	interpreter primitiveNotEqual.

	self assert: interpreter failed. 
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinFailsForForwardedObjects [

	interpreter push: self setUpForwardedObjects. 
	
	interpreter primitivePin. 
	
	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadArgument. 
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinFailsForImmediate [

	interpreter push: (memory integerObjectOf: 16).
	
	interpreter primitivePin. 
	
	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinFailsForNOnBoolOnSecondArg [

	interpreter push: (memory instantiateClass: (self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat)).
	interpreter push: (memory integerObjectOf: 16). 
	
	interpreter primitivePin. 
	
	self assert: interpreter failed. 
	self assert: interpreter primFailCode equals: PrimErrBadArgument. 
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinPinsObjectCreatedInNewSpace [
	|object object2|
	
	object := (memory instantiateClass: (self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat)).
	interpreter push: object. 
	interpreter push: (memory trueObject). 
	
	self deny: (memory isPinned: object).
	
	interpreter primitivePin. 
	
	self deny: interpreter failed. 
	
	object2 := memory followForwarded: object. 
	
	self assert: (memory isPinned: object2). 
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinPinsObjectCreatedInOldSpace [
	|object|
	
	object := self newOldSpaceObjectWithSlots: 1.
	interpreter push: object. 
	interpreter push: (memory trueObject). 
	
	self deny: (memory isPinned: object).
	
	interpreter primitivePin. 
	
	self deny: interpreter failed. 
	
	self assert: (memory isPinned: object). 

	
	
]

{ #category : #'tests - primitivePin' }
VMPrimitiveTest >> testPrimitivePinReturnsBoolean [
	|object|
	
	object := self newOldSpaceObjectWithSlots: 1.
	interpreter push: object. 
	interpreter push: (memory trueObject). 
	
	self deny: (memory isPinned: object).
	
	interpreter primitivePin. 
	
	self deny: interpreter failed. 
	
	self assert: interpreter stackTop equals: memory falseObject. 

	
	
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuo [

	interpreter push: (memory integerObjectOf: 15).
	interpreter push: (memory integerObjectOf: 2).
	interpreter primitiveQuo. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 7). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoFailPreservesStack [
	
	interpreter push: (memory trueObject).
	interpreter push: (memory integerObjectOf: 2).
	
	
	interpreter primitiveQuo. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: (memory trueObject).
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveQuo. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveQuo. 

	self assert: interpreter failed.
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoOnFloatResultDoesntReturnRest [
"Tests that the rest of the integer division is not pushed into the stack, as this is not expected in a primitive behavior"
	interpreter push: (memory integerObjectOf: 16).
	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveQuo. 
	
	self assert: (interpreter stackValue: 1) equals: (memory integerObjectOf: 16). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoOnFloatResultRoundsAndDoesntFail [

	interpreter push: (memory integerObjectOf: 42).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveQuo. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 10). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoWith0DivisionOnFirstOperand [

	interpreter push: (memory integerObjectOf: 0).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveQuo. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoWith0DivisionOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 4).
	interpreter push: (memory integerObjectOf: 0).
	
	interpreter primitiveQuo. 
	
	self assert: (interpreter stackTop) equals: (memory integerObjectOf: 0). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoWithNegativeNumbers1 [

	interpreter push: (memory integerObjectOf: -13).
	interpreter push: (memory integerObjectOf: -2).
	
	interpreter primitiveQuo.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 6). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoWithNegativeNumbers2 [

	interpreter push: (memory integerObjectOf: -9).
	interpreter push: (memory integerObjectOf: 4).
	
	interpreter primitiveQuo.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: -2). 
]

{ #category : #'tests - primitiveQuo' }
VMPrimitiveTest >> testPrimitiveQuoWithNoErrorPopsOperands [
	
	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveQuo. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteAdd (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveSetImmutabilityOfImmediateShouldFail [

	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory trueObject.
	interpreter primitiveSetImmutability.
	
	self assert: interpreter failed
]

{ #category : #'tests - primitiveImmutability' }
VMPrimitiveTest >> testPrimitiveSetImmutabilityOfObjectAsTrueSetsImmutability [

	| class object |
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: memory trueObject.
	interpreter primitiveSetImmutability.
	
	self assert: (memory isImmutable: object)
]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeAnswersCorrectSizeForContext [

	| method |
	method := methodBuilder newMethod build.
	
	interpreter push: method.
	interpreter primitiveSize.
	
	"One literal + 10 bytecodes"
	self assert: interpreter stackTop equals: (memory integerObjectOf: (10 + wordSize)).

]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeAnswersCorrectSizeForIndexableObject [

	| array1 |
	array1 := self newArrayWith: { memory integerObjectOf: 1 . memory integerObjectOf: 2 . memory integerObjectOf: 3 }.

	interpreter push: array1.
	interpreter primitiveSize.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 3).

]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeAnswersCorrectSizeForMethod [

	| method |
	method := methodBuilder newMethod build.
	
	interpreter push: method.
	interpreter primitiveSize.
	
	"One literal + 10 bytecodes"
	self assert: interpreter stackTop equals: (memory integerObjectOf: (10 + wordSize)).

]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeFailsForForwardedObject [

	| array1 array2 arrayForwarder arrayForwardee |
	array1 := self newArrayWith: { memory integerObjectOf: 1 . memory integerObjectOf: 2 . memory integerObjectOf: 3 }.
	array2 := self newArrayWith: { memory integerObjectOf: 4 . memory integerObjectOf: 5 }.
	
	interpreter push: array1.
	interpreter primitiveSize.
	
	arrayForwarder := self newArrayWith: { array1 }.
	arrayForwardee := self newArrayWith: { array2 }.
	
	interpreter push: arrayForwarder.
	interpreter push: arrayForwardee.
	interpreter primitiveArrayBecome.
	
	interpreter push: array1.
	interpreter push: array1.
	interpreter primitiveSize.
	
	self assert: interpreter primFailCode equals: PrimErrBadReceiver

]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeFailsForForwardedObjectThenCallForwarderResolutionAndCallPrimitiveAgain [

	| array1 array2 arrayForwarder arrayForwardee |
	array1 := self newArrayWith: { memory integerObjectOf: 1 . memory integerObjectOf: 2 . memory integerObjectOf: 3 }.
	array2 := self newArrayWith: { memory integerObjectOf: 4 . memory integerObjectOf: 5 }.
	
	arrayForwarder := self newArrayWith: { array1 }.
	arrayForwardee := self newArrayWith: { array2 }.
	
	interpreter push: arrayForwarder.
	interpreter push: arrayForwardee.
	interpreter primitiveArrayBecome.
	
	interpreter push: memory falseObject.
	interpreter push: array1.
	interpreter argumentCount: 1.
	interpreter primitiveSize.
	self assert: (interpreter followForwardedForAccessorDepth: 0).

	interpreter initPrimCall.
	interpreter primitiveSize.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2)

]

{ #category : #'tests - primitiveSize' }
VMPrimitiveTest >> testPrimitiveSizeFailsForNonIndexable [
	| class objectInstance |
	"Forwarding an object happens when becoming it with a bigger object"
	
	"We push receiver then 3 arguments"
	class := self newClassInOldSpaceWithSlots: 0 instSpec: memory nonIndexablePointerFormat.
	objectInstance := memory instantiateClass: class.
	
	interpreter push: objectInstance.
	interpreter primitiveSize.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadReceiver. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveSlotAtOverBoundShouldFailForIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter primitiveSlotAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex. 
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveSlotAtOverBoundShouldFailNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter primitiveSlotAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex.
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveSlotAtPutOverBoundShouldFailForIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory arrayFormat.
	
	object := memory instantiateClass: class indexableSize: 1.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory falseObject.
	interpreter primitiveSlotAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex. 
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveSlotAtPutOverBoundShouldFailNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory falseObject.
	interpreter primitiveSlotAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadIndex.
]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveSlotAtPutPutsTheValueForNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveSlotAtPut.
	
	self deny: interpreter failed.
	self assert: (memory fetchPointer: 0 ofObject: object) equals: memory falseObject.
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveSlotAtPutsTheValueForNonIndexable [
	| class object |
	class := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	
	object := memory instantiateClass: class.

	interpreter push: object.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	
	interpreter primitiveSlotAtPut.
	
	interpreter push: object. 
	interpreter push: (memory integerObjectOf: 1).
	
	interpreter primitiveSlotAt. 
	
	self deny: interpreter failed.
	self assert: (memory fetchPointer: 0 ofObject: object) equals: memory falseObject.
]

{ #category : #'tests - snapshot' }
VMPrimitiveTest >> testPrimitiveSnapshotContextsShouldBeTenured [
	| method frame contextOop contextIdentityHash suspendedContext |

	interpreter pluginList: #(). 
	self initializeOldSpaceForFullGC.
	self setContextClassIntoClassTable.
	method := methodBuilder newMethod build.
	frame := stackBuilder addNewFrame method: method ; yourself.
	stackBuilder buildStack.
	
	contextOop := interpreter ensureFrameIsMarried: frame framePointer SP: frame stackPointer.
	contextIdentityHash := memory hashBitsOf: contextOop.
	
	interpreter instructionPointer: method + 17.
	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.
	
	interpreter primitiveSnapshot.
	
	suspendedContext := memory fetchPointer: SuspendedContextIndex ofObject: memory memoryActiveProcess.
	self assert: (memory hashBitsOf: suspendedContext) equals: contextIdentityHash.
]

{ #category : #'tests - snapshot' }
VMPrimitiveTest >> testPrimitiveSnapshotCreateImage [
	| method file |
	interpreter pluginList: #(). 
	self initializeOldSpaceForFullGC.
	self setContextClassIntoClassTable.
	method := methodBuilder newMethod build.

	stackBuilder addNewFrame method: method.
	stackBuilder buildStack.

	interpreter instructionPointer: method + (1 + 8 + 8).

	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.
	interpreter primitiveSnapshot.
	
	file := imageName asFileReference.

	self assert: file exists.
	self assert: file size > 0.


]

{ #category : #'tests - snapshot' }
VMPrimitiveTest >> testPrimitiveSnapshotNewKeptObjectShouldBeTenured [
	| method object objectHash |
	interpreter pluginList: #(). 

	self initializeOldSpaceForFullGC.
	self setContextClassIntoClassTable.
	
	method := methodBuilder newMethod build.
	stackBuilder addNewFrame method: method.
	stackBuilder buildStack.
	interpreter instructionPointer: method + 17.
	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.
	
	object := self newObjectWithSlots: 0.
	self keepObjectInVMVariable1: object.
	objectHash := memory hashBitsOf: object.
	
	interpreter primitiveSnapshot.

	self assert: (memory hashBitsOf: self keptObjectInVMVariable1) equals: objectHash

]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveStringAtPutShouldFailForNonCharacterArgument [
	"Every other test is common with at:put:"
	| objectInstance |
	objectInstance := self newString: 'pouet'.
	
	interpreter push: objectInstance.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveStringAtPut.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument.

]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveStringAtPutShouldNotFailWhenReceiverIsAString [
	"Every other test is common with at:put:"
	| string |

	string := self newString: 'po'.

	interpreter push: string.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory characterObjectOf: 2).

	interpreter primitiveStringAtPut.
	
	self assert: interpreter successful.

]

{ #category : #'tests - primitiveAtPut' }
VMPrimitiveTest >> testPrimitiveStringAtPutShouldNotModifyStringIfFailedWhenNonCharacterArgument [
	"Every other test is common with at:put:"

	| string |
	string := self newString: 'po'.

	interpreter push: string.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveStringAtPut.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument.

	self assert: string contentEquals: (self newString: 'po')
]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveStringAtShouldFailForNonCharacterArgument [
	"Every other test is common with at:put:"
	| objectInstance |
	objectInstance := self memory integerObjectOf: 2. 
	
	interpreter push: objectInstance.
	interpreter push: (memory integerObjectOf: 1).
	interpreter primitiveStringAt.
	
	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrInappropriate.

]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveStringAtShouldNotFailWhenReceiverIsAString [
	"Every other test is common with at:put:"
	| string |

	string := self newString: 'po'.

	interpreter push: string.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory characterObjectOf: 2).

	interpreter primitiveStringAtPut.
	
	interpreter push: string.
	interpreter push: (memory integerObjectOf: 1).
	
	interpreter primitiveStringAt. 
	
	self assert: interpreter successful.
	self assert: interpreter stackTop equals: (memory characterObjectOf: 2). 

]

{ #category : #'tests - primitiveAt' }
VMPrimitiveTest >> testPrimitiveStringAtShouldNotModifyStringIfFailedWhenNonCharacterArgument [
	"Every other test is common with at:put:"

	| string |
	string := self newString: 'po'.

	interpreter push: string.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: memory falseObject.
	interpreter primitiveStringAtPut.

	self assert: interpreter failed.
	self assert: interpreter primFailCode equals: PrimErrBadArgument.

	self assert: string contentEquals: (self newString: 'po')
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtracFailsWithTypeErrorOnFirstOperand [
	
	interpreter push: memory trueObject.
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveSubtract. 

	self assert: interpreter failed.
	
	
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtracFailsWithTypeErrorOnSecondOperand [
	
	interpreter push: (memory integerObjectOf: 2).
	interpreter push: memory trueObject.
	
	interpreter primitiveSubtract. 

	self assert: interpreter failed.
	
	
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtractFailsWithTypeErrorPreservesStack [

	| string |
	
	string := self newString: '42'.
	interpreter push: string. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveSubtract. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: string.
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtractWithNoOverflow [

	interpreter push: (memory integerObjectOf: 2).
	interpreter push: (memory integerObjectOf: 1).
	
	interpreter primitiveSubtract. 
	
	self deny: interpreter failed.
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 1). 
	
	
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtractWithNoOverflowPopsOperands [

	interpreter push: (memory integerObjectOf: 42). "Marker"
	interpreter push: (memory integerObjectOf: 10).
	interpreter push: (memory integerObjectOf: 20).
	
	interpreter primitiveSubtract. 
	
	interpreter popStack. 
	"The previous lines pop the result of primiviteSubtract (1 2) for us to check that 1 and 2 were poped from the Stack by checking that the next value is our marker, for instance 42"
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 42). 
	
	
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtractWithOverflow [

	interpreter push: (memory integerObjectOf: memory minSmallInteger).
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveSubtract. 
	
	self assert: interpreter failed.
]

{ #category : #'tests - primitiveSubtract' }
VMPrimitiveTest >> testPrimitiveSubtractWithOverflowPreservesStack [

	| minSmallInt |
	
	minSmallInt:= (memory integerObjectOf: memory minSmallInteger). 
	
	interpreter push: minSmallInt. 
	interpreter push: (memory integerObjectOf: 2).
	
	interpreter primitiveSubtract. 
	
	self assert: interpreter stackTop equals: (memory integerObjectOf: 2). 
	self assert: (interpreter stackValue: 1) equals: minSmallInt.
	
	
]
