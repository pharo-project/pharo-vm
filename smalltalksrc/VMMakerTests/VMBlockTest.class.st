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

{ #category : #helpers }
VMBlockTest >> installBlockClosureClass [
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

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	self assert: (memory fetchPointer: FullClosureReceiverIndex ofObject: interpreter stackTop) equals: memory trueObject
]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureKnowsCompiledBlock [

	| methodReturning initialMethod methodInitialPC methodEndPC compiledBlock closure compiledBlockInLiteralFrame compiledBlockOfReturnedClosure |
	
	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
	"Bytecode index is 1-based, use 0 to set IP just before the first bytecode.
	The first thing interpretWhile: dows is to fetch a new bytecode"
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	closure := interpreter stackTop.
	compiledBlockInLiteralFrame := memory fetchPointer: 1 ofObject: methodReturning.
	compiledBlockOfReturnedClosure := memory fetchPointer: FullClosureCompiledBlockIndex ofObject: closure.
	
	self
		assert: compiledBlockInLiteralFrame
		equals: compiledBlockOfReturnedClosure
]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureShouldCopyUsedMethodVariable [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodWithLocalReturningABlock.

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	"We assign 1 to the local variable of the method, see methodWithLocalReturningABlock"
	self
		assert: (memory fetchPointer: FullClosureFirstCopiedValueIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 1).

]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureShouldHaveOuterContextObject [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	

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

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
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

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	

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

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.

	interpreter instructionPointer:
		(methodBuilder bytecodeAt: 0 forMethod: methodReturning).
	interpreter interpretWhile: [ interpreter method = methodReturning ].

	self assert: true
]

{ #category : #testing }
VMBlockTest >> testPushClosureBytecodePushesClosure [

	| methodReturning initialMethod |

	initialMethod := self createMethodOopFromPharoMethod:
		                     self class >> #anEmptyMethod.
	methodReturning := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
	interpreter interpretWhile: [ interpreter method = methodReturning ].


	self
		assert: (memory fetchClassOf: interpreter stackTop)
		equals: (memory classAtIndex: ClassFullBlockClosureCompactIndex)
]
