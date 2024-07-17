Class {
	#name : 'VMJitMethodTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'as yet unclassified' }
VMJitMethodTest >> addVector: arg1 with: arg2 intoVector: arg3 [

	| tmp1 tmp2 |
	tmp1 := 0.
	tmp2 := 2.
	[ tmp2 == tmp1 ] whileFalse: [
		arg3.
		tmp1 := tmp1 + 2 ].
	^ arg3
]

{ #category : 'tests' }
VMJitMethodTest >> comparingSmallIntegers: aBitmap [

	aBitmap size = 32768 ifTrue: [ ^ 17 ].
	^ 23
]

{ #category : 'accessing' }
VMJitMethodTest >> filter: aGlyphForm [
	"This method is here only for a test"

	"aGlyphForm should be 3x stretched 8 bit GlyphForm"
	| w h s answer rowstart bytes word littleEndian shift v a colorVal i
	  prevG prevB r g b nextR nextG  filters rfilter gfilter bfilter
	balR balG balB |

	"correctionFactor := 0.0 ."
	filters := FreeTypeSettings current subPixelFilters.
	rfilter := filters at: 1.
	gfilter := filters at: 2.
	bfilter := filters at: 3.
	bytes := aGlyphForm bits.
	w := aGlyphForm width.
	h := aGlyphForm height.
	answer := aGlyphForm class extent: ((aGlyphForm width / 3) ceiling + 2)@h depth: 32.
	answer
		offset: (aGlyphForm offset x / 3) rounded@(aGlyphForm offset y);
		advance: (aGlyphForm advance / 3) rounded;
		linearAdvance: aGlyphForm linearAdvance.
	s := w + 3 >> 2.
	littleEndian := aGlyphForm isLittleEndian.
	0 to: h - 1 do: [:y |
		rowstart := (y * s)+1.
		prevG := prevB :=0.
		0 to: w - 1 by: 3 do:[:x |
			0 to: 2 do:[:subpixelindex |
				i := x + subpixelindex.
				word := bytes at: rowstart + (i//4).
				shift := -8* (littleEndian
					ifTrue:[i bitAnd: 3]
					ifFalse:[3-(i bitAnd: 3)]).
				v := (word bitShift: shift) bitAnd: 16rFF.
				subpixelindex = 0 ifTrue:[r := v].
				subpixelindex = 1 ifTrue:[g := v].
				subpixelindex = 2 ifTrue:[b := v]].
			x >= (w-3)
				ifTrue:[nextR := nextG := 0]
				ifFalse:[
					0 to: 1 do:[:subpixelindex |
						i := x + 3 + subpixelindex.
						word := bytes at: rowstart + (i//4).
						shift := -8* (littleEndian
							ifTrue:[i bitAnd: 3]
							ifFalse:[3-(i bitAnd: 3)]).
						v := (word bitShift: shift) bitAnd: 16rFF.
						subpixelindex = 0 ifTrue:[nextR := v].
						subpixelindex = 1 ifTrue:[nextG := v]]].
			"balance r g b"
			balR := (prevG*(rfilter at: 1))+
				(prevB*(rfilter at: 2))+
				(r*(rfilter at: 3))+
				(g*(rfilter at: 4))+
				(b*(rfilter at: 5)).
			balG := (prevB*(gfilter at: 1))+
				(r*(gfilter at: 2))+
				(g*(gfilter at: 3))+
				(b*(gfilter at: 4))+
				(nextR*(gfilter at: 5)).
			balB := (r*(bfilter at: 1))+
				(g*(bfilter at: 2))+
				(b*(bfilter at: 3))+
				(nextR*(bfilter at: 4))+
				(nextG*(bfilter at: 5)).
			"luminance := (0.299*balR)+(0.587*balG)+(0.114*balB).
			balR := balR + ((luminance - balR)*correctionFactor).
			balG := balG + ((luminance - balG)*correctionFactor).
			balB := balB + ((luminance - balB)*correctionFactor)."
			balR := balR  truncated.
			balR < 0 ifTrue:[balR := 0] ifFalse:[balR > 255 ifTrue:[balR := 255]].
			balG := balG  truncated.
			balG < 0 ifTrue:[balG := 0] ifFalse:[balG > 255 ifTrue:[balG := 255]].
			balB := balB  truncated.
			balB < 0 ifTrue:[balB := 0] ifFalse:[balB > 255 ifTrue:[balB := 255]].
			a := balR + balG + balB > 0 ifTrue:[16rFF] ifFalse:[0].
			colorVal := balB + (balG bitShift: 8) +  (balR bitShift: 16) + (a bitShift: 24).
			answer bits integerAt: (y*answer width)+(x//3+1) put: colorVal.
			prevB := b. prevG := g.  "remember the unbalanced values" ]].
	^answer
]

{ #category : 'helpers' }
VMJitMethodTest >> initStack [

	self createBaseFrame.
	
	"Initialize Stack to the correct pointers in the selected page"
	machineSimulator smalltalkStackPointerRegisterValue: interpreter stackPointer.
	machineSimulator framePointerRegisterValue: interpreter framePointer.
	machineSimulator baseRegisterValue: cogit varBaseAddress.

	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.

]

{ #category : 'running' }
VMJitMethodTest >> initialCodeSize [

	^ 16 * 1024
]

{ #category : 'running' }
VMJitMethodTest >> setUp [ 

	super setUp.
	self initializeSpecialSelectors.
	self installFloat64RegisterClass	
]

{ #category : 'running' }
VMJitMethodTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit ceSendMustBeBooleanAddFalseTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddFalseTrampoline).
	cogit ceSendMustBeBooleanAddTrueTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceSendMustBeBooleanAddTrueTrampoline).

	cogit ceCheckForInterruptTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceCheckForInterruptTrampoline).
	cogit ceReturnToInterpreterTrampoline: (self compileTrampoline: [ cogit Stop ] named:#ceReturnToInterpreterTrampoline).
]

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
VMJitMethodTest >> testMixedInlinedLiteralsSmoteTest [
	| callingMethod |
	
	callingMethod := self jitMethod: (self class>>#filter:).
	
	self deny: callingMethod address equals: 0.
]

{ #category : 'tests' }
VMJitMethodTest >> testOnStackReplacementForLongRunningVectorAddMethod [
	| callingMethod cm x y z firstTerm size frame |
	
	cogit setCStackPointer: interpreter rumpCStackAddress.
	cogit setCFramePointer: interpreter rumpCStackAddress.	
	
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
	
	callingMethod := self createMethodOopFromHostMethod:
		                 (self findMethod: #addVector:with:intoVector:).

	self initStack.

	"As we are entering the interpreter first, the SP and FP has to be in the CStack."
	machineSimulator sp: cogit getCStackPointer.
	machineSimulator fp: cogit getCFramePointer.

	frame := stackBuilder
		         args: { x };
		         addNewFrame.
	frame stack: { 
			x.
			y.
			z };
			method: callingMethod.
	
	"We need to set the first context to the base of the current page"
	stackBuilder createStackPage.
	stackBuilder preparePage.

	stackBuilder frames first context: (interpreter stackPages unsignedLongAt: (stackBuilder page baseAddress - self wordSize)).

	stackBuilder pushFrames.
	stackBuilder setInterpreterVariables.

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
