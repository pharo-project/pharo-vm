Class {
	#name : #VMSnapshotPrimitiveTest,
	#superclass : #VMInterpreterTests,
	#instVars : [
		'imageName'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants',
		'VMObjectIndices'
	],
	#category : #'VMMakerTests-InterpreterTests'
}

{ #category : #running }
VMSnapshotPrimitiveTest >> setUp [
	super setUp.

	interpreter pluginList: #(  ).
	self setUpScheduler.
	self initializeOldSpaceForFullGC.
	self setContextClassIntoClassTable.


	imageName := self class name
]

{ #category : #running }
VMSnapshotPrimitiveTest >> tearDown [

	imageName ifNotNil: [ imageName asFileReference ensureDeleteAll ].
	super tearDown
]

{ #category : #'tests - snapshot' }
VMSnapshotPrimitiveTest >> testPrimitiveSnapshotContextsShouldBeTenured [

	| method frame contextOop contextIdentityHash suspendedContext |

	method := methodBuilder newMethod buildMethod.
	frame := stackBuilder addNewFrame
		         method: method;
		         yourself.
	stackBuilder buildStack.

	contextOop := interpreter
		              ensureFrameIsMarried: frame framePointer
		              SP: frame stackPointer.
	contextIdentityHash := memory hashBitsOf: contextOop.

	interpreter instructionPointer: method + 17.
	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.

	interpreter primitiveSnapshot.

	suspendedContext := memory
		                    fetchPointer: SuspendedContextIndex
		                    ofObject: memory memoryActiveProcess.
	self
		assert: (memory hashBitsOf: suspendedContext)
		equals: contextIdentityHash
]

{ #category : #'tests - snapshot' }
VMSnapshotPrimitiveTest >> testPrimitiveSnapshotCreateImage [

	| method |

	method := methodBuilder newMethod buildMethod.

	stackBuilder addNewFrame method: method.
	stackBuilder buildStack.

	interpreter instructionPointer: method + (1 + 8 + 8).

	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.
	interpreter primitiveSnapshot.

	interpreter imageReaderWriter validateImage: imageName 
]

{ #category : #'tests - snapshot' }
VMSnapshotPrimitiveTest >> testPrimitiveSnapshotHandlesFormatToUse [

	| method |

	method := methodBuilder newMethod numberOfArguments: 1; buildMethod.

	stackBuilder addNewFrame 
		method: method;
		stack: { memory integerObjectOf: 4 }.
		
	stackBuilder buildStack.

	interpreter instructionPointer: method + (1 + 8 + 8).

	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.
	interpreter argumentCount: 1.
	interpreter primitiveSnapshot.

	interpreter imageReaderWriter validateImage: imageName 
]

{ #category : #'tests - snapshot' }
VMSnapshotPrimitiveTest >> testPrimitiveSnapshotNewKeptObjectShouldBeTenured [

	| method object objectHash |

	method := methodBuilder newMethod buildMethod.
	stackBuilder addNewFrame method: method.
	stackBuilder buildStack.
	interpreter instructionPointer: method + 17.
	interpreter imageName: imageName.
	interpreter setImageHeaderFlagsFrom: 0.

	object := self newObjectWithSlots: 0.
	self keepObjectInVMVariable1: object.
	objectHash := memory hashBitsOf: object.

	interpreter primitiveSnapshot.

	self
		assert: (memory hashBitsOf: self keptObjectInVMVariable1)
		equals: objectHash
]
