Class {
	#name : #SpurSimulatorImage,
	#superclass : #SpurImage,
	#instVars : [
		'simulator'
	],
	#classInstVars : [
		'simulator'
	],
	#category : #'VMMaker-Tools-Model'
}

{ #category : #'as yet unclassified' }
SpurSimulatorImage class >> onSpurSimulator: aSpur64BitMMLESimulator [

	^ self new
		  simulator: aSpur64BitMMLESimulator;
		  yourself
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> classOf: aSpurObject [ 
	^self objectForOop: (simulator fetchClassOf: aSpurObject address)
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> fetchPointer: anInteger ofObject: objectOop [

	^ simulator fetchPointer: anInteger ofObject: objectOop
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> headerOf: anInteger [ 
	^simulator objectMemory baseHeader: anInteger
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> memory [
	^simulator
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> nilObject [
 	^SpurObject on: simulator nilObject image: self 

]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> numberOfSlotsOf: aSpurObject [

	^simulator numSlotsOf: aSpurObject address
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> objectForOop: anInteger [

	^ SpurObject on: anInteger image: self
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> simulator [
	^ simulator
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> simulator: aSpur64BitMMLESimulator [ 
	simulator := aSpur64BitMMLESimulator
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> wordSize [
	^simulator wordSize
]
