Class {
	#name : 'VMFFISameThreadBytecodeReturnMarshallingTest',
	#superclass : 'VMFFIReturnMarshallingTest',
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'running' }
VMFFISameThreadBytecodeReturnMarshallingTest >> createMethod [

	^ methodBuilder
		  newMethod;
		  literalAt: 0 put: memory nilObject; 
		  bytecodes: #[0 230 0 92];
		  buildMethod
]

{ #category : 'tests - marshalling return' }
VMFFISameThreadBytecodeReturnMarshallingTest >> doTestCalloutWithReturnType: aLibFFIType returnValue: valueToReturn asserting: aBlock [
	
	| tfExternalFunction previousStackTop |

	tfExternalFunction := self
		createExternalFunctionFor: [ valueToReturn ]
		withArgumentTypes: #()
		withReturnType: aLibFFIType.

	memory storePointer: 1 ofObject: interpreter method withValue: tfExternalFunction.

	previousStackTop := interpreter stackTop.
	
	interpreter sameThreadCalloutBytecode.

	self assert: (interpreter stackValue: 1) equals: previousStackTop.	
	aBlock value
]

{ #category : 'running' }
VMFFISameThreadBytecodeReturnMarshallingTest >> initialIP [

	^ (self wordSize * 2) + 1
]
