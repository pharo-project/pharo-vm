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
VMInspectorTest >> testNilHasNoInstanceVariable [

	self assert: image nilObject instanceVariables isEmpty.
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

	self assert: (object1 slotAt: 1) equals: object2.
	self assert: (object2 slotAt: 1) equals: object1.
]

{ #category : #tests }
VMInspectorTest >> testObjectWithInstanceVariableHasInstanceVariable [

	| objectOop |
	objectOop := self newObjectWithSlots: 2.
	self assert: (image objectForOop: objectOop) instanceVariables isNotEmpty.
]

{ #category : #tests }
VMInspectorTest >> testPrintNil [

	| nilObject |
	nilObject:= image nilObject.
	self assert: nilObject printString equals: 'a(n) ',  nilObject address hex, '@', nilObject address hex.
]
