Class {
	#name : #CogSimulatedVariable,
	#superclass : #Object,
	#instVars : [
		'address',
		'getterSelector',
		'receiver',
		'readOnly',
		'setterSelector'
	],
	#category : #'VMMaker-JITSimulation'
}

{ #category : #'instance creation' }
CogSimulatedVariable class >> getterSelector: getterSelector in: aReceiver [ 

	^ self new
		getterSelector: getterSelector;
		setterSelector: (((getterSelector beginsWith: 'get')
						ifTrue: ['s', getterSelector allButFirst]
						ifFalse: [getterSelector]), ':') asSymbol;
		receiver: aReceiver;
		yourself
		
	

]

{ #category : #comparing }
CogSimulatedVariable >> = anotherOne [

	anotherOne species = self species ifFalse: [ ^ false ].
	
	^ getterSelector = anotherOne getterSelector
]

{ #category : #accessing }
CogSimulatedVariable >> address [
	^ address
]

{ #category : #accessing }
CogSimulatedVariable >> address: anInteger [ 
	address := anInteger
]

{ #category : #accessing }
CogSimulatedVariable >> beReadOnly [
	
	readOnly := true
]

{ #category : #accessing }
CogSimulatedVariable >> getValue [
	
	^ receiver perform: getterSelector
]

{ #category : #comparing }
CogSimulatedVariable >> getterSelector [ 
	
	^ getterSelector
]

{ #category : #accessing }
CogSimulatedVariable >> getterSelector: aString [ 
	getterSelector := aString
]

{ #category : #comparing }
CogSimulatedVariable >> hash [ 

	^ getterSelector hash
]

{ #category : #initialization }
CogSimulatedVariable >> initialize [

	super initialize.
	readOnly := false.
]

{ #category : #accessing }
CogSimulatedVariable >> receiver: aReceiver [ 
	
	receiver := aReceiver
]

{ #category : #operations }
CogSimulatedVariable >> setValue: anInteger [ 
	
	readOnly ifTrue: [ self error: 'This is a read only variable' ].
	
	^ receiver perform: setterSelector with: anInteger
]

{ #category : #accessing }
CogSimulatedVariable >> setterSelector: aString [ 
	
	setterSelector := aString
]

{ #category : #accessing }
CogSimulatedVariable >> value [

	self halt.
]
