Class {
	#name : 'VMSpurScavengeWeakTest',
	#superclass : 'VMSpurInitializedOldSpaceTest',
	#category : 'VMMakerTests-MemoryTests',
	#package : 'VMMakerTests',
	#tag : 'MemoryTests'
}

{ #category : 'test-format' }
VMSpurScavengeWeakTest >> testNewWeakObjectShouldBeInstanceOfWeakClass [

	| weakObjectOop |
	self createWeakArrayClass.
	weakObjectOop := self newWeakObjectOfSize: 1.

	self assert: (memory fetchClassOfNonImm: weakObjectOop) equals: ourWeakClass
]

{ #category : 'test-format' }
VMSpurScavengeWeakTest >> testNewWeakObjectShouldHaveClassIndexOfItsClass [

	| weakObjectOop classIndex |
	self createWeakArrayClass.
	weakObjectOop := self newWeakObjectOfSize: 1.

	classIndex := memory classIndexOf: weakObjectOop.
	
	self assert: classIndex equals: (memory ensureBehaviorHash: ourWeakClass)
]

{ #category : 'tests' }
VMSpurScavengeWeakTest >> testScavengeOldWeakObjectReferencingNonSurvivorShouldBeNilled [

	| weakObjectOop nonWeakObjectOop nonWeakObjectHash nilHash |
	self createWeakArrayClass.
	weakObjectOop := self newWeakObjectOfSize: 1.

	"Force object to not be collected by putting them in special variables"
	memory coInterpreter newMethod: weakObjectOop.
	memory flushNewSpace.
	weakObjectOop := memory remapObj: weakObjectOop.

	nonWeakObjectOop := self newZeroSizedObject.
	nonWeakObjectHash := memory hashBitsOf: nonWeakObjectOop.
	memory storePointer: 0 ofObject: weakObjectOop withValue: nonWeakObjectOop.
	
	nilHash := memory hashBitsOf: memory nilObject.
	memory doScavenge: 1 "TenureByAge".	
	
	self
		assert: (memory hashBitsOf: (memory fetchPointer: 0 ofObject: weakObjectOop))
		equals: nilHash
]

{ #category : 'tests' }
VMSpurScavengeWeakTest >> testScavengeWeakObjectReferencingNonSurvivorShouldBeNilled [

	| weakObjectOop nonWeakObjectOop nilHash |
	self createWeakArrayClass.
	weakObjectOop := self newWeakObjectOfSize: 1.
	nonWeakObjectOop := self newZeroSizedObject.
	memory storePointer: 0 ofObject: weakObjectOop withValue: nonWeakObjectOop.
	
	"Force object to not be collected by putting them in special variables"
	memory coInterpreter newMethod: weakObjectOop.
	nilHash := memory hashBitsOf: memory nilObject.
	memory doScavenge: 1 "TenureByAge".
	weakObjectOop := memory remapObj: weakObjectOop.	
	
	self
		assert: (memory hashBitsOf: (memory fetchPointer: 0 ofObject: weakObjectOop))
		equals: nilHash
]

{ #category : 'tests' }
VMSpurScavengeWeakTest >> testScavengeWeakObjectReferencingSurvivorShouldLeaveWeakObjectAsIs [

	| weakObjectOop nonWeakObjectOop nonWeakObjectHash |
	self createWeakArrayClass.
	weakObjectOop := self newWeakObjectOfSize: 1.
	nonWeakObjectOop := self newZeroSizedObject.
	nonWeakObjectHash := memory hashBitsOf: nonWeakObjectOop.
	memory storePointer: 0 ofObject: weakObjectOop withValue: nonWeakObjectOop.
	
	"Force object to not be collected by putting them in special variables"
	memory coInterpreter newMethod: weakObjectOop.
	memory coInterpreter profileSemaphore: nonWeakObjectOop.

	memory doScavenge: 1 "TenureByAge".
	weakObjectOop := memory remapObj: weakObjectOop.	
	
	self
		assert: (memory hashBitsOf: (memory fetchPointer: 0 ofObject: weakObjectOop))
		equals: nonWeakObjectHash
]
