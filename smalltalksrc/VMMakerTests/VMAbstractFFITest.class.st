Class {
	#name : 'VMAbstractFFITest',
	#superclass : 'VMAbstractPrimitiveTest',
	#pools : [
		'LibFFIConstants'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'helpers' }
VMAbstractFFITest >> createReturnFloatExternalFunctionFor: aBlock [

	^ self
		createExternalFunctionFor: aBlock
		withArgumentTypes: #()
		withReturnType: interpreter libFFI float
]

{ #category : 'helpers' }
VMAbstractFFITest >> createReturnFloatExternalFunctionFor: aBlock withArgumentTypes: argumentTypes [

	^ self
		createExternalFunctionFor: aBlock
		withArgumentTypes: argumentTypes
		withReturnType: interpreter libFFI float
]

{ #category : 'helpers' }
VMAbstractFFITest >> initializationOptions [

	^ super initializationOptions , { 
		#FEATURE_FFI . true }
]

{ #category : 'helpers' }
VMAbstractFFITest >> interpreterClass [
	
	^ VMTestMockInterpreter
]

{ #category : 'helpers' }
VMAbstractFFITest >> readyProcesses [
	
	| collection |
	collection := OrderedCollection new.
	interpreter processesInProcessListDo: [ :e | collection add: e ].
	^ collection
]

{ #category : 'initialization' }
VMAbstractFFITest >> setUp [ 

	super setUp.
	
	interpreter libFFI: LibFFI new.
	interpreter libFFI interpreter: interpreter.

]
