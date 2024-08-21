Class {
	#name : 'VMSimpleStackBasedCogitMegamorphicPICTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#pools : [
		'VMMethodCacheConstants'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests - PIC' }
VMSimpleStackBasedCogitMegamorphicPICTest >> setUp [

	| specialSelectorsArray |
	super setUp.
	self setUpCogMethodEntry.

	memory coInterpreter
		moveMethodCacheToMemoryAt: (memory memoryManager allocate: MethodCacheEntrySize * MethodCacheSize * (interpreter sizeof: #sqInt)).

	specialSelectorsArray := self newOldSpaceObjectWithSlots: 2.
	memory coInterpreter
		specialSelectorArray: specialSelectorsArray;
		specialSelector: 0 put: memory falseObject.

	cogit generateOpenPICPrototype.
]

{ #category : 'tests - PIC' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testLookupExistingMegamorphicPICReturnsPIC [

	| selector createdPic specialObjectsArray |
	selector := memory trueObject.
	
	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.
	
	self assert: (cogit methodZone openPICWithSelector: selector) equals: createdPic.
]

{ #category : 'tests - PIC' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testLookupNonExistingMegamorphicPICReturnsNil [

	self assert: (cogit methodZone openPICWithSelector: memory trueObject) equals: nil
]

{ #category : 'tests - PIC' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testMiss [

	"We have to call the pic and see if it reaches the abort trampoline"
	| selector createdPic numArgs finishedSimulation |	

	selector := memory trueObject.
	numArgs := 0.
	createdPic := cogit cogOpenPICSelector: selector numArgs: numArgs.
	
	cogit setCFramePointer: machineSimulator framePointerRegisterValue.
	cogit setCStackPointer: machineSimulator stackPointerRegisterValue.
	
	"Receiver is nil, class tag of the first entry is 1 (a small integer).
	 - the receiver does not match with the class tag for case 0
	 - the receiver does not match with the class tag for case 1
	 - so it should call the closed pic miss trampoline"
	machineSimulator baseRegisterValue: cogit varBaseAddress.
	machineSimulator receiverRegisterValue: memory falseObject.

	"We call to get to the abort trampoline. If this fails this will timeout"
	finishedSimulation := false.

	self runFrom: createdPic asInteger + cogit entryOffset until: inlineCacheMissTrampoline.

	"Failing all two PIC cases calls the pic trampoline.
	 - The instruction pointer is at the trampoline
	 - The class register value contains the pic
	 - the receiver register value contains the receiver"	
	self assert: machineSimulator sendNumberOfArgumentsRegisterValue equals: createdPic address
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICHasTheCorrectPicAbortTrampoline [

	| createdPic selector |

	selector := memory trueObject.
	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.

	self
		assert: (cogit backend callTargetFromReturnAddress: createdPic asInteger + cogit missOffset)
		equals: (cogit picAbortTrampolineFor: 1)
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgs: numArgs [

	| selector createdPic |
	selector := memory trueObject.
	createdPic := cogit cogOpenPICSelector: selector numArgs: numArgs.
	self assert: createdPic cmNumArgs equals: numArgs
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWith1 [

	self testNewMegamorphicPICNumArgs: 1
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWith16 [

	self testNewMegamorphicPICNumArgs: 16
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWith2 [

	self testNewMegamorphicPICNumArgs: 2
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWith4 [

	self testNewMegamorphicPICNumArgs: 4
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWith8 [

	self testNewMegamorphicPICNumArgs: 8
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICNumArgsWithoutArgs [

	self testNewMegamorphicPICNumArgs: 0
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICSelector [
	| createdPic selector |

	selector := memory trueObject.
	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.
	self assert: createdPic selector equals: selector
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICSize [
	| createdPic selector |

	selector := memory trueObject.
	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.
	self assert: createdPic blockSize equals: cogit openPICSize.
]

{ #category : 'tests - metadata' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testNewMegamorphicPICType [

	| selector createdPic |
	selector := memory trueObject.
	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.
	self assert: createdPic cmType equals: CMMegamorphicIC.

]

{ #category : 'tests - PIC' }
VMSimpleStackBasedCogitMegamorphicPICTest >> testRelinkCallSiteToMegamorphicPICCallsNewPIC [

	| selector literalIndex method createdPic returnAfterCallAddress patchedCogMethod startAddress |
	sendTrampolineAddress := self compile: [ cogit RetN: 0 ].
	cogit ordinarySendTrampolineAt: 0 put: sendTrampolineAddress. "num args"
	self createFramefulCallFrom: callerAddress.

	literalIndex := 1.
	"The literal index is extracted from the byte0 of the instruction
	It is encoded with the bytecode number.
	The 208 is the first bytecode to send messages with zero arguments.
	The literal taken starts from zero in 208, one in 209... and so on"
	cogit byte0: 208 + literalIndex.
	selector := memory falseObject.
	method := methodBuilder newMethod
		          literalAt: literalIndex put: selector;
		          buildMethod.
	cogit methodObj: method.

	"The method will have 3 literals.
	The first literal is the methodHeader (smallInteger with flags).
	Literal 0 -> we are not using it (now it is nil)
	Literal 1 -> our selector"
	patchedCogMethod := self
		                    generateCogMethod: [ 
		                    cogit genSendLiteralSelector0ArgsBytecode ]
		                    selector: selector.

	createdPic := cogit cogOpenPICSelector: selector numArgs: 1.

	"We call to get to the send trampoline"
	self
		runFrom: patchedCogMethod asInteger + cogit noCheckEntryOffset
		until: sendTrampolineAddress.

	returnAfterCallAddress := machineSimulator hasLinkRegister
		                          ifTrue: [ 
		                          machineSimulator linkRegisterValue ]
		                          ifFalse: [ machineSimulator peekAddress ].
	"Let's rewrite the call site"
	cogit backEnd
		rewriteInlineCacheAt: returnAfterCallAddress
		tag: (cogit
				 inlineCacheValueForSelector: selector
				 in: patchedCogMethod
				 at: returnAfterCallAddress)
		target: createdPic asInteger + cogit entryOffset.
		
	startAddress := patchedCogMethod address + cogit noCheckEntryOffset.	
	
	cogit flushICacheFrom: startAddress to: startAddress + 32.

	"Let's rerun it to check if it gets to the patched address openPic"
	self
		runFrom: startAddress
		until: createdPic asInteger + cogit entryOffset.

	self
		assert: machineSimulator instructionPointerRegisterValue
		equals: createdPic asInteger + cogit entryOffset
]
