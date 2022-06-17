Class {
	#name : #VMPermanentSpacePrimitiveTest,
	#superclass : #VMAbstractPrimitiveTest,
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : #'VMMakerTests-PermSpace'
}

{ #category : #configuring }
VMPermanentSpacePrimitiveTest >> configureEnvironmentBuilder [ 

	super configureEnvironmentBuilder.
	
	environmentBuilder permSpaceSize: 10*1024*1024.
]

{ #category : #initialization }
VMPermanentSpacePrimitiveTest >> setUp [ 
	
	super setUp.
	self createEphemeronClass.
	self createWeakArrayClass.
]

{ #category : #tests }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceFailsOnEphemeron [

	| oldObject |

	oldObject := self newEphemeronObject.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : #tests }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceFailsOnWeakObject [

	| oldObject |

	oldObject := self newWeakObjectOfSize: 2.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: PrimErrBadReceiver
]

{ #category : #tests }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksOnNewPointerObject [

	| newObject |

	newObject := self newObjectWithSlots: 2.

	interpreter push: newObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]

{ #category : #tests }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksOnOldPointerObject [

	| oldObject |

	oldObject := self newOldSpaceObjectWithSlots: 2.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]

{ #category : #tests }
VMPermanentSpacePrimitiveTest >> testMoveToPermSpaceWorksWithByteArray [

	| oldObject |

	oldObject := self newOldByteObjectOfSize: 67.

	interpreter push: oldObject.

	interpreter argumentCount: 0.
	interpreter primitiveMoveToPermSpace.
	
	self assert: interpreter primFailCode equals: 0
]
