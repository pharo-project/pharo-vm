Class {
	#name : #VMInspectorTest,
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
	#category : #'VMMaker-Tools-Tests'
}

{ #category : #running }
VMInspectorTest >> setUp [
	
	super setUp.
	image := SpurSimulatorImage onSpurSimulator: memory.

	


]

{ #category : #tests }
VMInspectorTest >> testEqualsOtherObject [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image objectForOop: (image simulator integerObjectOf: 42).
	
	self assert: object1 equals: object2
]

{ #category : #'test-testing' }
VMInspectorTest >> testIsImmediateObject [
	| object |
	object := image objectForOop: (image simulator integerObjectOf: 42).
	
	self assert: object isImmediate
]

{ #category : #'test-testing' }
VMInspectorTest >> testIsNotImmediateObject [
	| object |
	object := image objectForOop: (self newObjectWithSlots: 1).
	
	self assert: object isImmediate not
]

{ #category : #'test-testing' }
VMInspectorTest >> testIsOld [
	| oop |
	oop := SpurObject on: (self newOldSpaceObjectWithSlots: 1) image: image.

	self assert: oop isOld.
]

{ #category : #'test-testing' }
VMInspectorTest >> testIsYoung [
	| oop |
	oop := SpurObject on: (self newObjectWithSlots: 1) image: image.

	self assert: oop isYoung.
]

{ #category : #tests }
VMInspectorTest >> testNilHasNoInstanceVariable [

	self assert: image nilObject instanceVariables isEmpty.
]

{ #category : #'tests-printing' }
VMInspectorTest >> testNotEqualsNil [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image objectForOop: (image simulator nilObject).
	
	self deny: object1 equals: object2
]

{ #category : #'tests-printing' }
VMInspectorTest >> testObjectEqualOop [
	| object1 object2 |
	object1 := image objectForOop: (image simulator integerObjectOf: 42).
	object2 := image simulator integerObjectOf: 42.
	
	self assert: object1 equals: object2
]

{ #category : #tests }
VMInspectorTest >> testObjectWithInstanceVariableCycleWeCanNavigate [

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
VMInspectorTest >> testObjectWithInstanceVariableHasInstanceVariable [

	| objectOop |
	objectOop := self newObjectWithSlots: 2.
	self assert: (image objectForOop: objectOop) instanceVariables isNotEmpty.
]

{ #category : #'tests-printing' }
VMInspectorTest >> testObjectWithNilClass [
	| oop object |
	oop := self newObjectWithSlots: 1.
	object := SpurObject on: oop image: image.

	self assert: object printString equals: oop printString
]

{ #category : #'tests-printing' }
VMInspectorTest >> testPrintFalse [

	self assert: 'falseObject' equals: image falseObject printString
]

{ #category : #'tests-printing' }
VMInspectorTest >> testPrintNil [

	self assert: 'nilObject' equals: image nilObject printString
]

{ #category : #'tests-printing' }
VMInspectorTest >> testPrintTrue [

	self assert: 'trueObject' equals: image trueObject printString
]

{ #category : #tests }
VMInspectorTest >> testSlotAtPut [

	| objectOop1 object1 objectOop2 object2 |
	objectOop1 := self newObjectWithSlots: 1.
	objectOop2 := self newObjectWithSlots: 1.
	
	object1 := (image objectForOop: objectOop1).
	object2 := (image objectForOop: objectOop2).
	
	object1 slotAt: 1 put: object2.
	object2 slotAt: 1 put: object1.

	self assert: (object1 slotAt: 1) address equals: object2.
]
