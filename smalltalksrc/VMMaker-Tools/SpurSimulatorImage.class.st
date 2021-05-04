Class {
	#name : #SpurSimulatorImage,
	#superclass : #SpurImage,
	#instVars : [
		'currentObject'
	],
	#classInstVars : [
		'simulator'
	],
	#category : #'VMMaker-Tools-imageInspector'
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

{ #category : #accessing }
SpurSimulatorImage >> currentObject: anOop [
	currentObject := anOop
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> falseObject [
	^ self objectForOop: simulator falseObject
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> fetchPointer: anInteger ofObject: objectOop [

	^ simulator fetchPointer: anInteger ofObject: objectOop
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> headerOf: anInteger [ 
	^simulator objectMemory baseHeader: anInteger value
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> inspectOop: anOop [
	^ (SpurObject on: anOop image: self) inspect
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> inspectionItems: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Oop'>
	^ aBuilder newList
		items: { currentObject };
		yourself
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> memory [
	^simulator
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> nextObjectOf: anOop [
	"The simulator relies on class indexes, which we do not really set"
	self shouldNotImplement
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> nilObject [
 	^ SpurObject on: simulator nilObject image: self 

]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> numSlotsOf: aSpurObject [

	^simulator numSlotsOf: aSpurObject address value
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> objectForOop: anInteger [

	^ SpurObject on: anInteger image: self
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> trueObject [
	^ self objectForOop: simulator trueObject
]

{ #category : #'as yet unclassified' }
SpurSimulatorImage >> wordSize [
	^ simulator wordSize
]
