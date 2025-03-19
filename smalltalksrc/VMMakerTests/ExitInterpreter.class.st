Class {
	#name : 'ExitInterpreter',
	#superclass : 'Error',
	#instVars : [
		'returnValue'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'accessing' }
ExitInterpreter >> returnValue: anInteger [ 
	
	returnValue := anInteger
]
