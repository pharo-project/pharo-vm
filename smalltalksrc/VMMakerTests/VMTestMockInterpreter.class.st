Class {
	#name : #VMTestMockInterpreter,
	#superclass : #StackInterpreterSimulatorLSB,
	#instVars : [
		'interpreteBlock',
		'allocatedElements'
	],
	#category : #VMMakerTests
}

{ #category : #initialization }
VMTestMockInterpreter >> allocateParameters: anInteger using: allocationBlock [
	<inline: #always>

	anInteger = 0 ifTrue: [ ^ nil ].

	^ self
		cCode: [ allocationBlock value: anInteger ]
		inSmalltalk: [ | ptr | 
			ptr := CArrayAccessor on: (Array new: anInteger).
			allocatedElements add: ptr ]
]

{ #category : #'memory testing' }
VMTestMockInterpreter >> allocatedElements [
	
	^ allocatedElements 
]

{ #category : #initialization }
VMTestMockInterpreter >> basicInitialize [

	super basicInitialize.
	allocatedElements := Set new
]

{ #category : #accessing }
VMTestMockInterpreter >> enterSmalltalkExecutiveImplementation [ 

	interpreteBlock value
]

{ #category : #initialization }
VMTestMockInterpreter >> free: aPointer [

	allocatedElements remove: aPointer.
	^ super free: aPointer
]

{ #category : #accessing }
VMTestMockInterpreter >> interpreteBlock [
	^ interpreteBlock
]

{ #category : #accessing }
VMTestMockInterpreter >> interpreteBlock: anObject [
	interpreteBlock := anObject
]

{ #category : #initialization }
VMTestMockInterpreter >> malloc: aSize [

	^ allocatedElements add: (super malloc: aSize)
]
