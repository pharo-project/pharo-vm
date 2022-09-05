Class {
	#name : #VMJitMethodTest,
	#superclass : #VMPrimitiveCallAbstractTest,
	#pools : [
		'CogRTLOpcodes'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'as yet unclassified' }
VMJitMethodTest >> addVector: arg1 with: arg2 intoVector: arg3 [

	| tmp1 tmp2 |
	tmp1 := 0.
	tmp2 := 2.
	[ tmp2 == tmp1 ] whileFalse: [ 
		arg3.
		tmp1 := tmp1 + 2 ].
	^ arg3
]

{ #category : #tests }
VMJitMethodTest >> comparingSmallIntegers: aBitmap [

	aBitmap size = 32768 ifTrue: [ ^ 17 ].
	^ 23
]

{ #category : #helpers }
VMJitMethodTest >> initStack [

	self createBaseFrame.
	
	"Initialize Stack to the correct pointers in the selected page"
	machineSimulator smalltalkStackPointerRegisterValue: interpreter stackPointer.
	machineSimulator framePointerRegisterValue: interpreter framePointer.
	machineSimulator baseRegisterValue: cogit varBaseAddress.
	
	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.

]

{ #category : #running }
VMJitMethodTest >> initialCodeSize [

	^ 16 * 1024
]

{ #category : #running }
VMJitMethodTest >> setUp [ 

	super setUp.
	self initializeSpecialSelectors.
	self installFloat64RegisterClass	
]

{ #category : #running }
VMJitMethodTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit ceSendMustBeBooleanAddFalseTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddFalseTrampoline).
	cogit ceSendMustBeBooleanAddTrueTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddTrueTrampoline).

	cogit ceCheckForInterruptTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceCheckForInterruptTrampoline).
	cogit ceReturnToInterpreterTrampoline: (self compileTrampoline: [ cogit Stop ] named:#ceReturnToInterpreterTrampoline).
]

{ #category : #tests }
VMJitMethodTest >> testComparingSmallIntegersThatNotFit [
	| callingMethod parameter aSize bytesPerSlot desiredByteSize numberOfWordSizeSlots padding |
	
	aSize := 32768.
	bytesPerSlot := 1.
	desiredByteSize := aSize * bytesPerSlot roundUpTo: self wordSize.
	numberOfWordSizeSlots := desiredByteSize / self wordSize.
	padding := desiredByteSize / bytesPerSlot - aSize.

	parameter := memory
		  allocateSlots: numberOfWordSizeSlots
		  format: memory firstByteFormat + padding
		  classIndex: self nextOrdinaryClassIndex.

	"We replace the sendTrampoline to simulate the message send of #size"
	sendTrampolineAddress := self compileTrampoline: [ 
		cogit MoveCq: (memory integerObjectOf: 32768) R: ReceiverResultReg.
		cogit RetN:0 ] named: #send0argsTrampoline.
	
	cogit ordinarySendTrampolineAt: 0 "args" put: sendTrampolineAddress.
		
	callingMethod := self jitMethod: (self findMethod: #comparingSmallIntegers:).
		
	self 
		callCogMethod: callingMethod 
		receiver: memory nilObject 
		arguments:  { parameter }
		returnAddress: callerAddress.
	
	self 
		assert: (memory integerValueOf: machineSimulator receiverRegisterValue)
		equals: 17
]

{ #category : #tests }
VMJitMethodTest >> testJitCompiledFloat32VectorAddition [

	| callingMethod cm x y z |
	
	x := self new32BitIndexableFromArray: #(1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0).
	y := self new32BitIndexableFromArray: #(10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0).
	z := self new32BitIndexableOfSize: 8.
		
	cm := IRBuilder buildMethod: [ :builder |"TODO handle arrays with an odd number of elements"
		builder
				numArgs: 3; 		
				addTemps: { #firstVector. #secondVector. #thirdVector. #i. #end };
				pushLiteral: 0;
				storeTemp: #i;
				popTop;
				pushLiteral: 8;
				storeTemp: #end;
				popTop;
				jumpBackTarget: #loop;
				pushTemp: #end;
				pushTemp: #i;
				send: #==;
				jumpAheadTo: #exit if: true;
					pushTemp: #i;
					pushTemp: #firstVector;
					pushFloat32ArrayToRegister;
					pushTemp: #i;
					pushTemp: #secondVector;
					pushFloat32ArrayToRegister;
					addFloat32Vector;
					pushTemp: #i;
					pushTemp: #thirdVector;
					storeFloat32RegisterIntoArray;
					popTop;
				pushTemp: #i;
				pushLiteral: 4;
				send: #+;
				storeTemp: #i;
				popTop;
				jumpBackTo: #loop;
				jumpAheadTarget: #exit;
				pushTemp: #thirdVector;
				returnTop
		 ].
	
	self class addSelector: #addVector:with:intoVector: withMethod: cm.

	callingMethod := self jitMethod: (self findMethod: #addVector:with:intoVector:).

	wordSize = 4 ifTrue: [ ^ self assert: callingMethod isNil ].

	self initStack.

	self 
		callCogMethod: callingMethod 
		receiver: memory nilObject 
		arguments: {x. y. z}
		returnAddress: callerAddress.
	
	self assert: machineSimulator receiverRegisterValue equals: z.
	self assert: (memory fetchFloat32: 0 ofObject: z) equals: 11.0.
	self assert: (memory fetchFloat32: 1 ofObject: z) equals: 22.0.
	self assert: (memory fetchFloat32: 2 ofObject: z) equals: 33.0.
	self assert: (memory fetchFloat32: 3 ofObject: z) equals: 44.0.
	self assert: (memory fetchFloat32: 4 ofObject: z) equals: 55.0.
	self assert: (memory fetchFloat32: 5 ofObject: z) equals: 66.0.
	self assert: (memory fetchFloat32: 6 ofObject: z) equals: 77.0.
	self assert: (memory fetchFloat32: 7 ofObject: z) equals: 88.0.		
	
	

]

{ #category : #tests }
VMJitMethodTest >> testJitCompiledFloat64VectorAddition [

	| callingMethod cm x y z firstTerm size |

	firstTerm := 1.0 to: 2.0.
	size := firstTerm size.

	x := self new64BitIndexableFromArray: firstTerm.
	y := self new64BitIndexableFromArray: (firstTerm collect: [:i | i * 10]).
	z := self new64BitIndexableOfSize: size.

	cm := IRBuilder buildMethod: [ :builder | "TODO handle arrays with an odd number of elements"
		      builder
			      numArgs: 3;
			      addTemps:
				      { #firstVector. #secondVector. #thirdVector. #i. #end };
			      pushLiteral: 0;
			      storeTemp: #i;
			      popTop;
			      pushLiteral: size;
			      storeTemp: #end;
			      popTop;
			      jumpBackTarget: #loop;
			      pushTemp: #end;
			      pushTemp: #i;
			      send: #==;
			      jumpAheadTo: #exit if: true;
			      pushTemp: #i;
			      pushTemp: #firstVector;
			      pushFloat64ArrayToRegister;
			      pushTemp: #i;
			      pushTemp: #secondVector;
			      pushFloat64ArrayToRegister;
			      addFloat64Vector;
			      pushTemp: #i;
			      pushTemp: #thirdVector;
			      storeFloat64RegisterIntoArray;
			      popTop;
			      pushTemp: #i;
			      pushLiteral: 2;
			      send: #+;
			      storeTemp: #i;
			      popTop;
			      jumpBackTo: #loop;
			      jumpAheadTarget: #exit;
			      pushTemp: #thirdVector;
			      returnTop ].

	self class addSelector: #addVector:with:intoVector: withMethod: cm.

	callingMethod := self jitMethod:
		                 (self findMethod: #addVector:with:intoVector:).

	self wordSize = 4 ifTrue: [ ^ self assert: callingMethod isNil ].

	self initStack.

	self
		callCogMethod: callingMethod
		receiver: memory nilObject
		arguments: { 
				x.
				y.
				z }
		returnAddress: callerAddress.

	self assert: machineSimulator receiverRegisterValue equals: z.
	self assert: (memory fetchFloat64: 0 ofObject: z) equals: 11.0.
	self assert: (memory fetchFloat64: 1 ofObject: z) equals: 22.0
]

{ #category : #tests }
VMJitMethodTest >> testMixedInlinedLiteralsSmoteTest [
	| callingMethod |
	
	callingMethod := self jitMethod: (FreeTypeSubPixelAntiAliasedGlyphRenderer>>#filter:).
	
	self deny: callingMethod address equals: 0.
]

{ #category : #tests }
VMJitMethodTest >> testOnStackReplacementForLongRunningVectorAddMethod [
	| callingMethod cm x y z firstTerm size frame |
	
	firstTerm := 1.0 to: 2.0.
	size := firstTerm size.

	x := self new64BitIndexableFromArray: firstTerm.
	y := self new64BitIndexableFromArray:
		     (firstTerm collect: [ :i | i * 10 ]).
	z := self new64BitIndexableOfSize: size.

	cm := IRBuilder buildMethod: [ :builder | "TODO handle arrays with an odd number of elements"
		      builder
			      numArgs: 3;
			      addTemps:
				      { #firstVector. #secondVector. #thirdVector. #i. #end };
			      pushLiteral: 0;
			      storeTemp: #i;
			      popTop;
			      pushLiteral: size;
			      storeTemp: #end;
			      popTop;
			      jumpBackTarget: #loop;
			      pushTemp: #end;
			      pushTemp: #i;
			      send: #==;
			      jumpAheadTo: #exit if: true;
			      pushTemp: #i;
			      pushTemp: #firstVector;
			      pushFloat64ArrayToRegister;
			      pushTemp: #i;
			      pushTemp: #secondVector;
			      pushFloat64ArrayToRegister;
			      addFloat64Vector;
			      pushTemp: #i;
			      pushTemp: #thirdVector;
			      storeFloat64RegisterIntoArray;
			      popTop;
			      pushTemp: #i;
			      pushLiteral: 2;
			      send: #+;
			      storeTemp: #i;
			      popTop;
			      jumpBackTo: #loop;
			      jumpAheadTarget: #exit;
			      pushTemp: #thirdVector;
			      returnTop ].

	self class addSelector: #addVector:with:intoVector: withMethod: cm.
	
	callingMethod := self createMethodOopFromPharoMethod:
		                 (self findMethod: #addVector:with:intoVector:).

	self initStack.
	"As we are entering the interpreter first, the SP and FP has to be in the CStack."
	machineSimulator sp: cogit getCStackPointer.
	machineSimulator fp: cogit getCFramePointer.

	frame := stackBuilder
		         args: { x };
		         addNewFrame.
	stackBuilder frames first context: 17513312."TODO set proper context"
	frame stack: { 
			x.
			y.
			z };
			method: callingMethod.
	
	stackBuilder buildStack.

	cogit generateReturnToInterpreterPCTrampoline.
	interpreter newMethod: callingMethod.
	interpreter activateNewMethod.
	"Set the backwards branch count to 3 so it trips in the first iteration.
	This should trigger JIT compilation and On Stack Replacement"
	interpreter
		iframeBackwardBranchByte: interpreter framePointer
		put: 3.
	interpreter sigset: nil jmp: 0.
	
	[interpreter interpretUntilReturn.] on: ReenterInterpreter do: [ :notification | 
		"Stop when returning from compiled method to interpreter"
	].

	self assert: (memory fetchFloat64: 0 ofObject: z) equals: 11.0.
	self assert: (memory fetchFloat64: 1 ofObject: z) equals: 22.0
]
