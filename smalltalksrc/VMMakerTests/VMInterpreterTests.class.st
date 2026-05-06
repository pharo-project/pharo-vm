Class {
	#name : 'VMInterpreterTests',
	#superclass : 'VMSpurMemoryManagerTest',
	#pools : [
		'VMClassIndices',
		'VMObjectIndices'
	],
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'running' }
VMInterpreterTests >> setUp [
	
	"taken from VMSimpleStackBasedCogitBytecodeTest >> #setup"
	super setUp.
	
	memory nilObject: (self newObjectWithSlots: 0).
	memory trueObject: (self newObjectWithSlots: 0).
	memory falseObject: (self newObjectWithSlots: 0).
	
	"We don't access its contents, but we need it to be after nil, true and false"
	memory hiddenRootsObject: (self newArrayWithSlots: 0).
		
	self initializeOldSpaceForScavenger.


]
