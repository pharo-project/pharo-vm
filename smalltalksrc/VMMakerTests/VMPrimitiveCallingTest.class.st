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
