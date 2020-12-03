Class {
	#name : #VMBlockTest,
	#superclass : #VMInterpreterTests,
	#pools : [
		'VMObjectIndices',
		'VMSqueakClassIndices'
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
		instSpec: BlockClosure instSpec.
	memory setHashBitsOf: aClass to: ClassBlockClosureCompactIndex.
	memory
		storePointer: ClassBlockClosureCompactIndex
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : #supports }
VMBlockTest >> methodReturningABlock [
	
	^ []
	
]

{ #category : #'as yet unclassified' }
VMBlockTest >> methodReturningABlockInsideABlockWithLocal [
	
	true ifTrue:[|anArgument| anArgument := 2.
		^[anArgument]]
	
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
		assert: (memory fetchPointer: ClosureFirstCopiedValueIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 1).

]

{ #category : #testing }
VMBlockTest >> testCreatingABlockClosureShouldHaveCorrectPC [

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

	"hard code for now should be modified"
	self
		assert: (memory fetchPointer: ClosureStartPCIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 29).

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

	"Currently fails because the stack frame is not overriden.
	So the interpreter considers it's still married even thought the stack frame is already dead"

	self
		assert: (interpreter isWidowedContext: (memory outerContextOf: interpreter stackTop))

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
	self
		assert: (memory fetchPointer: ClosureFirstCopiedValueIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 2).

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
	

	interpreter instructionPointer: (methodBuilder bytecodeAt: 0 forMethod: methodOop).
	interpreter interpretWhile: [ interpreter method = methodOop ].

	self
		assert: (memory fetchPointer: ClosureNumArgsIndex ofObject: interpreter stackTop) equals: (memory integerObjectOf: 0).

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

	methodOop := self createMethodOopFromPharoMethod:
		             self class >> #methodReturningABlock.

	self installBlockClosureClass.
	"We want to avoid baseFrameReturn (base frame initialisation)"
	stackBuilder addNewFrame method: initialMethod.
	stackBuilder addNewFrame
		method: methodReturning;
		receiver: memory trueObject.
	stackBuilder buildStack.
	
	interpreter interpretWhile: [ interpreter method = methodOop ].


	self
		assert: (memory fetchClassOf: interpreter stackTop)
		equals: (memory classAtIndex: ClassBlockClosureCompactIndex)
]
