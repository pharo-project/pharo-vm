Class {
	#name : #VMBlockTest,
	#superclass : #VMInterpreterTests,
	#pools : [
		'VMClassIndices',
		'VMObjectIndices'
	],
	#category : #'VMMakerTests-InterpreterTests'
}

{ #category : #supports }
VMBlockTest >> anEmptyMethod [
]

{ #category : #'as yet unclassified' }
VMBlockTest >> evaluatingABlock [

  [^1] value
]

{ #category : #accessing }
VMBlockTest >> initializationOptions [ 

	^ super initializationOptions , { #MULTIPLEBYTECODESETS. true. }
]

{ #category : #helpers }
VMBlockTest >> installFullBlockClosureClass [
		| aClass |
	aClass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: FullBlockClosure instSpec.

	memory setHashBitsOf: aClass to: ClassFullBlockClosureCompactIndex.
	memory
		storePointer: ClassFullBlockClosureCompactIndex
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : #supports }
VMBlockTest >> methodReturningABlock [
	
	^ []
	
]

{ #category : #'as yet unclassified' }
VMBlockTest >> methodReturningABlockInsideABlockWithLocal [

	true ifTrue: [ 
		| anArgument |
		anArgument := 2.
		^ [ anArgument ] ]
]

{ #category : #supports }
VMBlockTest >> methodReturningABlockWithTwoArguments [
	
	^ [:a :b]
	
]

{ #category : #supports }
VMBlockTest >> methodWithLocalReturningABlock [

	| a |
	a:= 1.
	^ [ a ]
]

{ #category : #supports }
VMBlockTest >> setUp [

	super setUp.
	self initializeSpecialSelectors.
	interpreter initExtensions.
]

{ #category : #'as yet unclassified' }
VMBlockTest >> testCreatingABlockCapturesReceiver [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlockInsideABlockWithLocal.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	self assert: (memory fetchPointer: FullClosureReceiverIndex ofObject: interpreter stackTop) equals: memory trueObject
]

{ #category : #running }
VMBlockTest >> setUp [

	super setUp.
	self initializeSpecialSelectors
]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureShouldCopyUsedMethodVariable [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlockInsideABlockWithLocal.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	"We assign 1 to the local variable of the method, see methodWithLocalReturningABlock"
	self
		assert: (memory fetchPointer: FullClosureFirstCopiedValueIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 1)
]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureKnowsCompiledBlock [

	| methodReturning initialMethod placeTakenByLiterals closure blockInitialPC compiledBlock |

	initialMethod := self createMethodOopFromPharoMethod:
		                 self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		                   self class >> #methodReturningABlock.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	"Bytecode index is 1-based, use 0 to set IP just before the first bytecode.
	The first thing interpretWhile: dows is to fetch a new bytecode"
	interpreter instructionPointer:
		(methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	"The start pc is after the two literals of the block"
	blockInitialPC := memory wordSize * 2.
	compiledBlock := memory
							   fetchPointer: FullClosureCompiledBlockIndex
							   ofObject: interpreter stackTop.

	self
		assert: (interpreter startPCOfMethod: compiledBlock)
		equals: blockInitialPC

]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureShouldHaveOuterContextObject [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	"The current frame returned, the context is widowed, but the VM does not mark what are the alive frames all the time"
	self deny: (interpreter isWidowedContext: (memory outerContextOf: interpreter stackTop)).
	"From time to time, the VM will mark the frames that are alive, and then be able to recognize that a context is widowed"
	interpreter externalWriteBackHeadFramePointers.
	self assert: (interpreter isWidowedContext: (memory outerContextOf: interpreter stackTop))
]

{ #category : #'as yet unclassified' }
VMBlockTest >> testCreatingABlockInsideABlockClosureShouldCopyUsedBlockVariable [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlockInsideABlockWithLocal.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	"We assign 2 to the local variable of the block, see methodReturningABlockInsideABlock"
	self assert: (memory fetchPointer: FullClosureFirstCopiedValueIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 2).

]

{ #category : #testing }
VMBlockTest >> testCreatingABlockWithoutArgumentsClosureShouldHaveNoArgument [

	| methodReturning initialMethod |
	
	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	self
		assert: (memory fetchPointer: FullClosureNumArgsIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 0).

]

{ #category : #'as yet unclassified' }
VMBlockTest >> testEvaluatingABlock [

	| methodReturning initialMethod |
	
	initialMethod := self createMethodOopFromPharoMethod:
		                 self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		                   self class >> #evaluatingABlock.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).

	"Interpret while we are in the correct method, and until the value message to the block"
	interpreter interpretWhile: [ 
		interpreter method = methodReturning 
			and: [ interpreter currentBytecode ~= 377 ] ].

	"The top of the stack should be the fullblock closure object"
	self
		assert: (memory fetchClassOf: interpreter stackTop)
		equals: (memory classAtIndex: ClassFullBlockClosureCompactIndex)
]

{ #category : #testing }
VMBlockTest >> testPushClosureBytecodePushesClosure [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installFullBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	interpreter setMethod: stackBuilder lastFrame method.
	
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	self
		assert: (memory fetchClassOf: interpreter stackTop)
		equals: (memory classAtIndex: ClassFullBlockClosureCompactIndex)
]
