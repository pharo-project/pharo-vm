Class {
	#name : #CogSimulatedArrayVariable,
	#superclass : #Object,
	#instVars : [
		'address',
		'getterSelector',
		'receiver',
		'readOnly',
		'setterSelector',
		'elementSize',
		'elementCount'
	],
	#category : #'VMMaker-JITSimulation'
}

{ #category : #accessing }
CogSimulatedArrayVariable >> accessorForAddress: anInteger [ 
	
	| index |
	index := anInteger - address // elementSize. 
	
	^ CogSimulatedArrayElement new
			getterBlock: [ receiver perform: getterSelector with: index ];
			setterBlock: [ :anObject | receiver perform: setterSelector with: index with: anObject ];
			yourself
]

{ #category : #accessing }
CogSimulatedArrayVariable >> address: anInteger [ 
	address := anInteger
]

{ #category : #simulating }
CogSimulatedArrayVariable >> addressForIndex: anInteger [ 
	
	^ address + (anInteger * elementSize)
]

{ #category : #testing }
CogSimulatedArrayVariable >> canHandle: anInteger [ 
	
	^ (address <= anInteger and: [ (address + (elementSize * elementCount)) > anInteger ])
		and: [ anInteger - address % elementSize = 0 ]
]

{ #category : #accessing }
CogSimulatedArrayVariable >> elementCount: anInteger [ 

	elementCount := anInteger
]

{ #category : #accessing }
CogSimulatedArrayVariable >> elementSize: anInteger [ 

	elementSize := anInteger

]

{ #category : #accessing }
CogSimulatedArrayVariable >> getterSelector [
	^ getterSelector
]

{ #category : #accessing }
CogSimulatedArrayVariable >> getterSelector: aString [ 
	getterSelector := aString
]

{ #category : #accessing }
CogSimulatedArrayVariable >> receiver [
	^ receiver
]

{ #category : #accessing }
CogSimulatedArrayVariable >> receiver: aCogEventLogger [ 
	receiver := aCogEventLogger
]

{ #category : #accessing }
CogSimulatedArrayVariable >> setterSelector: aString [ 
	setterSelector := aString
]
