Class {
	#name : 'VMContextReificationTest',
	#superclass : 'VMBasicPrimitiveTest',
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'tests' }
VMContextReificationTest >> testSenderObjectWithCallerInDifferentPage [

	| method newFP frameCaller frameCallee callerReceiver currentPage newPage |

	callerReceiver := memory integerObjectOf: 11.
	method := methodBuilder newMethod buildMethod.
	frameCaller := stackBuilder addNewFrame
		receiver: callerReceiver;
		stack: { memory integerObjectOf: 17 };
		method: method; yourself.

	frameCallee := stackBuilder addNewFrame
		receiver: (memory integerObjectOf: 17);
		stack: { memory nilObject };
		method: method; yourself.

	stackBuilder buildStack.

	currentPage := interpreter stackPage.
	interpreter ensureFrameIsMarried: frameCaller framePointer SP:frameCaller stackPointer. 
	newPage := interpreter stackPages newStackPage.
	
	newFP := interpreter moveFramesIn: currentPage through: frameCallee framePointer toPage: newPage.
	interpreter setStackPageAndLimit: newPage.
	interpreter setStackPointersFromPage: newPage.

	interpreter primitiveSenderObject.

	self assert: interpreter stackTop equals: callerReceiver
]

{ #category : 'tests' }
VMContextReificationTest >> testSenderObjectWithCallerInTheSamePage [

	| method frameCaller frameCallee callerReceiver |

	callerReceiver := memory integerObjectOf: 11.
	method := methodBuilder newMethod buildMethod.
	frameCaller := stackBuilder addNewFrame
		receiver: callerReceiver;
		stack: { memory integerObjectOf: 17 };
		method: method; yourself.

	frameCallee := stackBuilder addNewFrame
		receiver: (memory integerObjectOf: 17);
		stack: { memory nilObject };
		method: method; yourself.

	stackBuilder buildStack.
	
	interpreter primitiveSenderObject.

	self assert: interpreter stackTop equals: callerReceiver
]

{ #category : 'tests' }
VMContextReificationTest >> testSenderObjectWithCallerOutsideStack [

	| method newFP frameCaller frameCallee callerReceiver oldPage newPage |

	callerReceiver := memory integerObjectOf: 11.
	method := methodBuilder newMethod buildMethod.
	frameCaller := stackBuilder addNewFrame
		receiver: callerReceiver;
		method: method;
		beSuspendedAt: (interpreter initialIPForHeader:
			(memory methodHeaderOf: method) method: method);
		stack: { memory integerObjectOf: 17 };
		yourself.

	frameCallee := stackBuilder addNewFrame
		receiver: (memory integerObjectOf: 17);
		stack: { memory nilObject };
		method: method; yourself.

	stackBuilder buildStack.

	oldPage := interpreter stackPage.
	
	interpreter ensureFrameIsMarried: frameCaller framePointer SP:frameCaller stackPointer. 
	newPage := interpreter stackPages newStackPage.
	newFP := interpreter moveFramesIn: oldPage through: frameCallee framePointer toPage: newPage.
	interpreter setStackPageAndLimit: newPage.
	interpreter setStackPointersFromPage: newPage.
	
	interpreter divorceFramesIn: oldPage.

	interpreter primitiveSenderObject.

	self assert: interpreter stackTop equals: callerReceiver
]

{ #category : 'tests' }
VMContextReificationTest >> testSenderObjectWithNoSenderFails [

	| method frameCallee callerReceiver top |

	callerReceiver := memory integerObjectOf: 11.
	method := methodBuilder newMethod buildMethod.
	top := memory integerObjectOf: 16rcafebabe.

	frameCallee := stackBuilder addNewFrame
		receiver: (memory integerObjectOf: 17);
		stack: { top };
		method: method; yourself.

	stackBuilder buildStack.

	interpreter primitiveSenderObject.	
	
	self assert: interpreter failed.
	self assert: interpreter stackTop equals: top
]
