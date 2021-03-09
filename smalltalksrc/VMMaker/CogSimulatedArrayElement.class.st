Class {
	#name : #CogSimulatedArrayElement,
	#superclass : #Object,
	#instVars : [
		'getterBlock',
		'setterBlock'
	],
	#category : #'VMMaker-JITSimulation'
}

{ #category : #accessing }
CogSimulatedArrayElement >> getValue [
	
	^ getterBlock value
]

{ #category : #accessing }
CogSimulatedArrayElement >> getterBlock: aFullBlockClosure [ 
	getterBlock := aFullBlockClosure
]

{ #category : #accessing }
CogSimulatedArrayElement >> setValue: anInteger [ 
	
	^ setterBlock value: anInteger
]

{ #category : #accessing }
CogSimulatedArrayElement >> setterBlock: aFullBlockClosure [ 
	setterBlock := aFullBlockClosure
]
