Class {
	#name : #SlangMemoryRegion,
	#superclass : #Object,
	#instVars : [
		'start',
		'memory'
	],
	#category : #'Slang-Simulation'
}

{ #category : #accessing }
SlangMemoryRegion >> memory [

	^ memory
]

{ #category : #accessing }
SlangMemoryRegion >> memory: anObject [

	memory := anObject
]

{ #category : #accessing }
SlangMemoryRegion >> start [

	^ start
]

{ #category : #accessing }
SlangMemoryRegion >> start: anObject [

	start := anObject
]
