Class {
	#name : 'VMStackInterpreterTest',
	#superclass : 'TestCase',
	#instVars : [
		'stackInterpreterClass'
	],
	#category : 'VMMakerTests-StackInterpreter',
	#package : 'VMMakerTests',
	#tag : 'StackInterpreter'
}

{ #category : 'running' }
VMStackInterpreterTest >> setUp [

	super setUp.
	stackInterpreterClass := StackInterpreter.
]

{ #category : 'accessing' }
VMStackInterpreterTest >> stackInterpreterClass [

	^ stackInterpreterClass
]

{ #category : 'accessing' }
VMStackInterpreterTest >> stackInterpreterClass: anObject [

	stackInterpreterClass := anObject
]

{ #category : 'running' }
VMStackInterpreterTest >> testIsObjectAccessor [

	self 
		assert: (self stackInterpreterClass isObjectAccessor: #firstIndexableField:);
		assert: (self stackInterpreterClass isObjectAccessor: #slotSizeOf:);
		assert: (self stackInterpreterClass isObjectAccessor: #fetchClassOf:)
]

{ #category : 'running' }
VMStackInterpreterTest >> testIsStackAccessor [

	self 
		assert: (self stackInterpreterClass isStackAccessor: #stackIntegerValue:);
		assert: (self stackInterpreterClass isStackAccessor: #stackValue:)
		

]
