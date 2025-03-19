Class {
	#name : 'SlangMemoryRegion',
	#superclass : 'Object',
	#instVars : [
		'start',
		'memory',
		'originallyRequestedMemory'
	],
	#category : 'Slang-Simulation',
	#package : 'Slang',
	#tag : 'Simulation'
}

{ #category : 'memory access' }
SlangMemoryRegion >> at: anInteger [
	
	^ self byteAt: anInteger
]

{ #category : 'memory access' }
SlangMemoryRegion >> byteAt: anInteger [
	"0 based offset"
	^ memory at: anInteger
]

{ #category : 'memory access' }
SlangMemoryRegion >> doubleAt: anInteger [ 
	"anInteger is 0 based offset"
	^ memory float64AtOffset: anInteger
]

{ #category : 'memory access' }
SlangMemoryRegion >> doubleAt: anInteger put: aNumber [ 
	"anInteger is 0 based offset"
	^ memory float64AtOffset: anInteger put: aNumber
]

{ #category : 'memory access' }
SlangMemoryRegion >> floatAt: anInteger [
	"anInteger is 0 based offset"
	^ memory float32AtOffset: anInteger
]

{ #category : 'memory access' }
SlangMemoryRegion >> floatAt: anInteger put: aNumber [ 
	"anInteger is 0 based offset"
	^ memory float32AtOffset: anInteger put: aNumber
]

{ #category : 'memory access' }
SlangMemoryRegion >> integerAt: anInteger put: value size: nBytes signed: aBoolean [
	"anInteger is 0 based offset"
	
	^ memory
		integerAt: anInteger + 1
		put: value
		size: nBytes
		signed: aBoolean
]

{ #category : 'memory access' }
SlangMemoryRegion >> integerAt: anInteger size: nBytes signed: aBoolean [
	"anInteger is 0 based offset"
	
	^ memory
		integerAt: anInteger + 1
		size: nBytes
		signed: aBoolean
]

{ #category : 'accessing' }
SlangMemoryRegion >> memory [

	^ memory
]

{ #category : 'accessing' }
SlangMemoryRegion >> memory: anObject [

	memory := anObject
]

{ #category : 'accessing' }
SlangMemoryRegion >> originallyRequestedMemory [

	^ originallyRequestedMemory
]

{ #category : 'accessing' }
SlangMemoryRegion >> originallyRequestedMemory: anObject [

	originallyRequestedMemory := anObject
]

{ #category : 'printing' }
SlangMemoryRegion >> printOn: aStream [

	super printOn: aStream.

	aStream
		nextPut: $ ;
		print: start;
		nextPut: $-;
		print: (start+originallyRequestedMemory)
]

{ #category : 'bulk-replace' }
SlangMemoryRegion >> replaceFrom: anInteger to: anInteger2 with: aSlangMemoryRegion [ 

	^ memory replaceFrom: anInteger to: anInteger2 with: aSlangMemoryRegion
]

{ #category : 'bulk-replace' }
SlangMemoryRegion >> replaceFrom: anInteger to: anInteger2 with: aCArray startingAt: anInteger4 [ 
	
	^ memory replaceFrom: anInteger to: anInteger2 with: aCArray startingAt: anInteger4 
]

{ #category : 'accessing' }
SlangMemoryRegion >> requestedMemoryCopy [
	
	^ memory copyFrom: 1 to: originallyRequestedMemory
]

{ #category : 'accessing' }
SlangMemoryRegion >> size [
	^ self originallyRequestedMemory 
]

{ #category : 'accessing' }
SlangMemoryRegion >> start [

	^ start
]

{ #category : 'accessing' }
SlangMemoryRegion >> start: anObject [

	start := anObject
]
