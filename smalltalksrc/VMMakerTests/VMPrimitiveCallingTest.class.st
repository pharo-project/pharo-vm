Class {
	#name : #VMPrimitiveCallingTest,
	#superclass : #VMInterpreterTests,
	#category : #'VMMakerTests-InterpreterTests'
}

{ #category : #tests }
VMPrimitiveCallingTest >> testPrimitiveFailingDoesNotSetErrorCodeInOtherTemp [

	"The method has two temporaries. The first one is the error code, the second one is a user defined temp."
	| method |
	method := methodBuilder newMethod
		bytecodes:
			#[ "call primitive" 		16rF8 16rB8 16r00
				"store into temp 0" 	16rF5 16r00 ];
		numberOfTemporaries: 2;
		isPrimitive: true;
		buildMethod.
	
	stackBuilder addNewFrame; buildStack.
	interpreter newMethod: method.
	interpreter primFailCode: -1.

	interpreter activateNewMethod.

	self assert: (interpreter temporary: 1 in: interpreter framePointer) equals: memory nilObject
]

{ #category : #tests }
VMPrimitiveCallingTest >> testPrimitiveFailingDoesNotSkipSecondBytecodeIfNotLongStore [

	"The method has two temporaries. The first one is the error code, the second one is a user defined temp."
	| method |
	method := methodBuilder newMethod
		bytecodes:
			#[ "call primitive" 		16rF8 16rB8 16r00
				"not store into temp 0" 	16rF4 ];
		numberOfTemporaries: 2;
		isPrimitive: true;
		buildMethod.
	
	stackBuilder addNewFrame; buildStack.
	interpreter newMethod: method.
	interpreter primFailCode: -1.

	interpreter activateNewMethod.
	
	interpreter internalizeIPandSP.
	self assert: interpreter fetchByte equals: 16rF4
]

{ #category : #tests }
VMPrimitiveCallingTest >> testPrimitiveFailingSetsErrorCodeInCorrectTemp [

	"The method has two temporaries. The first one is the error code, the second one is a user defined temp."
	| method |
	method := methodBuilder newMethod
		bytecodes:
			#[ "call primitive" 		16rF8 16rB8 16r00
				"store into temp 0" 	16rF5 16r00 ];
		numberOfTemporaries: 2;
		isPrimitive: true;
		buildMethod.
	
	stackBuilder addNewFrame; buildStack.
	interpreter newMethod: method.
	interpreter primFailCode: -1.

	interpreter activateNewMethod.

	self assert: (interpreter temporary: 0 in: interpreter framePointer) equals: (memory integerObjectOf: -1)
]

{ #category : #tests }
VMPrimitiveCallingTest >> testPrimitiveFailingSetsErrorCodeInCorrectTempWithInternalActivation [

	"The method has two temporaries. The first one is the error code, the second one is a user defined temp."
	| method |
	method := methodBuilder newMethod
		bytecodes:
			#[ "call primitive" 		16rF8 16rB8 16r00
				"store into temp 0" 	16rF5 16r00 ];
		numberOfTemporaries: 2;
		isPrimitive: true;
		buildMethod.
	
	stackBuilder addNewFrame; addNewFrame; buildStack.
	interpreter newMethod: method.
	interpreter primFailCode: -1.

	"Move the frame pointer to its caller but keep the correct one in the local FP".
	interpreter internalizeIPandSP.
	interpreter framePointer: (interpreter frameCallerFP: interpreter framePointer).

	"Use the internal version using the localFP"
	interpreter internalActivateNewMethod.
	
	"Then externalize and assert"
	interpreter externalizeFPandSP.
	self assert: (interpreter temporary: 0 in: interpreter framePointer) equals: (memory integerObjectOf: -1)
]
