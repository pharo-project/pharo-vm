Class {
	#name : 'VMPermanentSpacePrimitiveTest',
	#superclass : 'VMAbstractPrimitiveTest',
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : 'VMMakerTests-PermSpace',
	#package : 'VMMakerTests',
	#tag : 'PermSpace'
}

{ #category : 'configuring' }
VMPermanentSpacePrimitiveTest >> configureEnvironmentBuilder [ 

	super configureEnvironmentBuilder.
	
	environmentBuilder permSpaceSize: 10*1024*1024.
]

{ #category : 'helpers' }
VMPermanentSpacePrimitiveTest >> replaceAllOf: destination with: source [

	interpreter push: destination.
	interpreter push: (memory integerObjectOf: 1).
	interpreter push: (memory integerObjectOf: (memory numSlotsOf: destination)).
	interpreter push: source.
	interpreter push: (memory integerObjectOf: 1).
	interpreter argumentCount: 4.
	interpreter primitiveStringReplace.

	self assert: interpreter primFailCode equals: 0
]

{ #category : 'initialization' }
VMPermanentSpacePrimitiveTest >> setUp [ 
	
	super setUp.
	self createEphemeronClass.
	self createWeakArrayClass.
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testIsInmmediateInPermSpace [

	interpreter push: (memory integerObjectOf: 42).
	interpreter argumentCount: 0.
	interpreter primitiveIsInPermSpace.
	
	self assert: interpreter stackTop equals: memory falseObject
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testIsNewObjectInPermSpace [

	interpreter push: (self newZeroSizedObject).
	interpreter argumentCount: 0.
	interpreter primitiveIsInPermSpace.
	
	self assert: interpreter stackTop equals: memory falseObject
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testIsOldObjectInPermSpace [

	interpreter push: (self newOldSpaceObjectWithSlots: 0).
	interpreter argumentCount: 0.
	interpreter primitiveIsInPermSpace.
	
	self assert: interpreter stackTop equals: memory falseObject
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testIsPermObjectInPermSpace [

	| oldObj permObject |
	oldObj := self newOldSpaceObjectWithSlots: 0.
	permObject := memory moveToPermSpace: oldObj.

	interpreter push: permObject.
	interpreter argumentCount: 0.
	interpreter primitiveIsInPermSpace.
	
	self assert: interpreter stackTop equals: memory trueObject
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceFailsOnEphemeron [

	| oldObject |

	oldObject := self newEphemeronObject.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceFailsOnWeakObject [

	| oldObject |

	oldObject := self newWeakObjectOfSize: 2.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksOnNewPointerObject [

	| newObject |

	newObject := self newObjectWithSlots: 2.

	interpreter push: newObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksOnOldPointerObject [

	| oldObject |

	oldObject := self newOldSpaceObjectWithSlots: 2.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]

{ #category : 'tests' }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksWithByteArray [

	| oldObject |

	oldObject := self newOldByteObjectOfSize: 67.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]

{ #category : 'tests - primitiveStringReplace' }
VMPermanentSpacePrimitiveTest >> testStringReplaceOfOldValueIntoPermArrayEndsInPermToOldSet [

	| permArray source oldObject |
	permArray := self newPermanentObjectWithSlots: 1.
	oldObject := self newOldSpaceObjectWithSlots: 0.
	source := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: source withValue: oldObject.

	self replaceAllOf: permArray with: source.
	memory doScavenge: 1 "TenureByAge".

	self deny: (memory isRemembered: permArray).
	self assert: (memory getFromPermToOldSpaceRememberedSet isInRememberedSet: permArray)
]

{ #category : 'tests - primitiveStringReplace' }
VMPermanentSpacePrimitiveTest >> testStringReplaceOfPermAndImmediateValuesIntoPermArrayDoesNotRemember [

	| permArray source |
	permArray := self newPermanentObjectWithSlots: 2.
	source := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: source withValue: (self newPermanentObjectWithSlots: 0).
	memory storePointer: 1 ofObject: source withValue: (memory integerObjectOf: 42).

	self replaceAllOf: permArray with: source.

	self deny: (memory isRemembered: permArray).
	self deny: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permArray)
]

{ #category : 'tests - primitiveStringReplace' }
VMPermanentSpacePrimitiveTest >> testStringReplaceOfYoungValueIntoPermArraySurvivesScavenge [

	| permArray source youngObject |
	permArray := self newPermanentObjectWithSlots: 1.
	youngObject := self newZeroSizedObject.
	source := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: source withValue: youngObject.

	self replaceAllOf: permArray with: source.

	self assert: (memory getFromPermToNewSpaceRememberedSet isInRememberedSet: permArray).

	memory doScavenge: 1 "TenureByAge".

	"Only the perm array keeps youngObject alive. If the perm array is remembered, the scavenger
	 copies youngObject to a survivor space and updates the slot; otherwise the slot keeps the eden address."
	self deny: (memory fetchPointer: 0 ofObject: permArray) equals: youngObject.
	self assert: (memory isYoung: (memory fetchPointer: 0 ofObject: permArray))
]
