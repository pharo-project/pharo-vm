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
	self initializeSpecialSelectors
]

{ #category : #running }
VMJitMethodTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit ceSendMustBeBooleanAddFalseTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddFalseTrampoline).
	cogit ceSendMustBeBooleanAddTrueTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddTrueTrampoline).

	cogit ceCheckForInterruptTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceCheckForInterruptTrampoline)
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
VMJitMethodTest >> testJitCompiledVectorAddition [

	| callingMethod cm x y z |
	
	x := self new64BitIndexableOfSize: 2.
	y := self new64BitIndexableOfSize: 2.
	z := self new64BitIndexableOfSize: 2.
		
	memory storeFloat64: 0 ofObject: x withValue: 1.0. 
	memory storeFloat64: 1 ofObject: x withValue: 2.0.
	memory storeFloat64: 0 ofObject: y withValue: 10.0.
	memory storeFloat64: 1 ofObject: y withValue: 20.0.
	
	cm := IRBuilder buildMethod: [ :builder |"TODO handle arrays with an odd number of elements"
		builder
				numArgs: 3; 		
				addTemps: { #firstVector. #secondVector. #thirdVector. #i. #end };
				pushLiteral: 0;
				storeTemp: #i;
				popTop;
				pushLiteral: 2;
				storeTemp: #end;
				popTop;
				jumpBackTarget: #loop;
				pushTemp: #end;
				pushTemp: #i;
				send: #==;
				jumpAheadTo: #exit if: true;
					pushTemp: #i;
					pushTemp: #firstVector;
					pushArrayToRegister;
					pushTemp: #i;
					pushTemp: #secondVector;
					pushArrayToRegister;
					addFloat64Vector;
					pushTemp: #i;
					pushTemp: #thirdVector;
					storeRegisterIntoArray;
					popTop;
				pushTemp: #i;
				pushLiteral: 2;
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

	self initStack.

	self 
		callCogMethod: callingMethod 
		receiver: memory nilObject 
		arguments: {x. y. z}
		returnAddress: callerAddress.
	
	self assert: machineSimulator receiverRegisterValue equals: z.
	self assert: (memory fetchFloat64: 0 ofObject: z) equals: 11.0.
	self assert: (memory fetchFloat64: 1 ofObject: z) equals: 22.0.
	
	
	

]

{ #category : #tests }
VMJitMethodTest >> testMixedInlinedLiteralsSmoteTest [
	| callingMethod |
	
	callingMethod := self jitMethod: (FreeTypeSubPixelAntiAliasedGlyphRenderer>>#filter:).
	
	self deny: callingMethod address equals: 0.
]
