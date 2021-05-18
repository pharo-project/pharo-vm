Class {
	#name : #VMImageInspectorTest,
	#superclass : #VMInterpreterTests,
	#instVars : [
		'imageName',
		'image'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : #'VMMaker-Tools-ImageInspector'
}

{ #category : #tests }
VMImageInspectorTest >> setSmallIntegerClassIntoClassTable [

	| class |
	class := self
		newClassInOldSpaceWithSlots: 0
		instSpec: memory forwardedFormat.
	image simulator setHashBitsOf: class to: memory smallIntegerTag.
	image simulator
		storePointer: memory smallIntegerTag
		ofObject: memory classTableFirstPage
		withValue: class.
	^class
	
]

{ #category : #running }
VMImageInspectorTest >> setUp [
	
	super setUp.
	image := SpurSimulatorImage onSpurSimulator: memory.
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testClassOfObjectIsNilObjectByDefault [
	| objectOop object |
	objectOop := self newObjectWithSlots: 1.
	
	object := (image objectForOop: objectOop).
	self assert: object classSpurObject equals: image simulator nilObject.
]

{ #category : #tests }
VMImageInspectorTest >> testEqualsOtherObject [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image objectForOop: (image simulator integerObjectOf: 42).
	
	self assert: object1 equals: object2
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testImmutability [
	| object objectOop |
	objectOop := (self newObjectWithSlots: 1).
	object := image objectForOop: objectOop.
	image simulator setIsImmutableOf: objectOop to: true.
	
	self assert: object isImmutable
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testImmutabilityISFalseByDefault [
	| object |
	object := image objectForOop: (self newObjectWithSlots: 1).
	
	self assert: object isImmutable not
]

{ #category : #tests }
VMImageInspectorTest >> testInspectOopInspectRightObject [
	| objectOop window |
	objectOop := self newObjectWithSlots: 1.
	window := image inspectOop: objectOop.
	[self assert: window title equals: 'Inspector on ', objectOop printString]
	ensure: [ window close ]
]

{ #category : #tests }
VMImageInspectorTest >> testIntegerKnowsItsClass [
	| class object |
	class := self setSmallIntegerClassIntoClassTable.
	object := SpurObject on: (image simulator integerObjectOf: 42) image: image.
	self assert: class equals: object classOop
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testIsImmediateObject [
	| object |
	object := image objectForOop: (image simulator integerObjectOf: 42).
	
	self assert: object isImmediate
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testIsNotImmediateObject [
	| object |
	object := image objectForOop: (self newObjectWithSlots: 1).
	
	self assert: object isImmediate not
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testIsOld [
	| oop |
	oop := SpurObject on: (self newOldSpaceObjectWithSlots: 1) image: image.

	self assert: oop isOld.
]

{ #category : #'test-testing' }
VMImageInspectorTest >> testIsYoung [
	| oop |
	oop := SpurObject on: (self newObjectWithSlots: 1) image: image.

	self assert: oop isYoung.
]

{ #category : #tests }
VMImageInspectorTest >> testNilHasNoInstanceVariable [

	self assert: image nilObject instanceVariables isEmpty.
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testNotEqualsNil [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image objectForOop: (image simulator nilObject).
	
	self deny: object1 equals: object2
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testObjectEqualOop [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image simulator integerObjectOf: 42.
	
	self assert: object1 equals: object2
]

{ #category : #tests }
VMImageInspectorTest >> testObjectWithInstanceVariableCycleWeCanNavigate [

	| objectOop1 object1 objectOop2 object2 |
	objectOop1 := self newObjectWithSlots: 1.
	objectOop2 := self newObjectWithSlots: 1.
	
	object1 := (image objectForOop: objectOop1).
	object2 := (image objectForOop: objectOop2).
	
	object1 slotAt: 1 put: object2.
	object2 slotAt: 1 put: object1.
	
	self assert: (object1 slotAt: 1) address equals: object2.
	self assert: (object2 slotAt: 1) address equals: object1.
]

{ #category : #tests }
VMImageInspectorTest >> testObjectWithInstanceVariableHasInstanceVariable [

	| objectOop |
	objectOop := self newObjectWithSlots: 2.
	self assert: (image objectForOop: objectOop) instanceVariables isNotEmpty.
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testObjectWithNilClass [
	| oop object |
	oop := self newObjectWithSlots: 1.
	object := SpurObject on: oop image: image.

	self assert: object printString equals: oop printString
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testPrintFalse [

	self assert: 'falseObject (' , (image falseObject oop printString), ')' equals: image falseObject printString
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testPrintNil [

	self assert: 'nilObject (' , (image nilObject oop printString), ')' equals: image nilObject printString
]

{ #category : #'tests-printing' }
VMImageInspectorTest >> testPrintTrue [

	self assert: 'trueObject (' , (image trueObject oop printString), ')' equals: image trueObject printString 
]

{ #category : #tests }
VMImageInspectorTest >> testSlotAtPut [

	| objectOop1 object1 objectOop2 object2 |
	objectOop1 := self newObjectWithSlots: 1.
	objectOop2 := self newObjectWithSlots: 1.
	
	object1 := (image objectForOop: objectOop1).
	object2 := (image objectForOop: objectOop2).
	
	object1 slotAt: 1 put: object2.
	
	self assert: (object1 slotAt: 1) address equals: object2.
]
