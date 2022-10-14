Class {
	#name : #VMMachineCodeDebuggerStackItem,
	#superclass : #Object,
	#instVars : [
		'address',
		'machineSimulator'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #'instance creation' }
VMMachineCodeDebuggerStackItem class >> address: anInteger on: machineSimulator [ 
	
	^ self new
		address: anInteger;
		machineSimulator: machineSimulator;
		yourself
]

{ #category : #accessing }
VMMachineCodeDebuggerStackItem >> address [
	^ address
]

{ #category : #accessing }
VMMachineCodeDebuggerStackItem >> address: anInteger [ 
	address := anInteger
]

{ #category : #accessing }
VMMachineCodeDebuggerStackItem >> machineSimulator: anUnicornARMv8Simulator [ 
	machineSimulator := anUnicornARMv8Simulator
]

{ #category : #evaluating }
VMMachineCodeDebuggerStackItem >> specialRegister [

	| isSP isFP |
	isSP := machineSimulator smalltalkStackPointerRegisterValue = address.
	isFP := machineSimulator fp = address.
	^ String streamContents: [ :str | 
		isSP ifTrue: [ str nextPutAll: 'SP ' ].
		isFP ifTrue: [ str nextPutAll: 'FP ' ]. ]

]

{ #category : #evaluating }
VMMachineCodeDebuggerStackItem >> value [ 

	^ machineSimulator wordAt: address
]
