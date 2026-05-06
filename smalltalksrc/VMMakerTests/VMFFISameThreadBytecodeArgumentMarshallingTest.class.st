Class {
	#name : 'VMFFISameThreadBytecodeArgumentMarshallingTest',
	#superclass : 'VMFFIArgumentMarshallingTest',
	#instVars : [
		'contextClass',
		'ffiFallbackSelector',
		'ffiFallbackMethod'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'running' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> createMethod [

	^ methodBuilder
		  newMethod;
		  literalAt: 0 put: memory nilObject; 
		  bytecodes: #[0 230 0 92];
		  buildMethod
]

{ #category : 'implementation' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> doTestFuntionWithArgumentType: argumentType smalltalkValue: smalltalkValue expectedValue: expectedValue [

	| tfExternalFunction savedValue previousStackTop |

	tfExternalFunction := self 
		createExternalFunctionFor:  [ :anArgument | savedValue := anArgument ] 
		withArgumentTypes: { argumentType } 
		withReturnType: interpreter libFFI void.
	
	memory storePointer: 1 ofObject: interpreter method withValue: tfExternalFunction.

	previousStackTop := interpreter stackTop.
	
	interpreter push: smalltalkValue.
	interpreter sameThreadCalloutBytecode.
	
	self deny: interpreter failed.
	self assert: interpreter stackTop equals: previousStackTop.
	self assert: savedValue equals: expectedValue.
]

{ #category : 'implementation' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> doTestFuntionWithArgumentType: argumentType smalltalkValue: smalltalkValue failsWith: expectedErrorCode [

	| tfExternalFunction savedValue |

	self installContextClass.
	self installFFIFallbackMethod.
	interpreter methodDictLinearSearchLimit: 3.
	interpreter setBreakSelector: nil.
	interpreter currentBytecode: 200.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ :anArgument | savedValue := anArgument ] 
		withArgumentTypes: { argumentType } 
		withReturnType: interpreter libFFI void.
	
	memory storePointer: 1 ofObject: interpreter method withValue: tfExternalFunction.
	
	interpreter push: smalltalkValue.
	interpreter sameThreadCalloutBytecode.
	
	self assert: interpreter method equals: ffiFallbackMethod.
]

{ #category : 'running' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> initialIP [

	^ (self wordSize * 2) + 1
]

{ #category : 'as yet unclassified' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> installContextClass [

	contextClass := self
		              newClassInOldSpaceWithSlots: 0
		              instSpec: memory sixtyFourBitIndexableFormat.
		
	memory setHashBitsOf: contextClass to: ClassMethodContextCompactIndex.
	
	memory
		storePointer: ClassMethodContextCompactIndex
		ofObject: memory classTableFirstPage
		withValue: contextClass.

]

{ #category : 'as yet unclassified' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> installFFIFallbackMethod [

	| aMethodDictionary |
	
	ffiFallbackSelector := self newZeroSizedObject.
	ffiFallbackMethod := self newMethodWithBytecodes: #[1 2 3 4 5 6 7 8].
	
	memory splObj: SelectorInvalidFFICall put: ffiFallbackSelector.
	
	self setUpMethodDictionaryIn: contextClass.

	aMethodDictionary := memory
		                     fetchPointer: MethodDictionaryIndex
		                     ofObject: contextClass.

	self
		installSelector: ffiFallbackSelector
		method: ffiFallbackMethod
		inMethodDictionary: aMethodDictionary.

]

{ #category : 'tests' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> testCalloutWithPointerArgumentWithIntObjectIsMarshalledCorrectly [

	self
		doTestFuntionWithArgumentType: interpreter libFFI pointer
		smalltalkValue: (memory integerObjectOf: 8)
		expectedValue: 8
]

{ #category : 'tests' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> testCalloutWithPointerArgumentWithOopObjectIsMarshalledCorrectly [

	| anObject |
	anObject := self newZeroSizedObject.

	self
		doTestFuntionWithArgumentType: interpreter libFFI pointer
		smalltalkValue: anObject
		expectedValue: anObject + BaseHeaderSize
]

{ #category : 'tests' }
VMFFISameThreadBytecodeArgumentMarshallingTest >> testCalloutWithPointerPassingCharacterProducesBadArgument [

	self
		doTestFuntionWithArgumentType:  interpreter libFFI pointer
		smalltalkValue: (memory characterObjectOf: 17)
		failsWith: PrimErrBadArgument

]
