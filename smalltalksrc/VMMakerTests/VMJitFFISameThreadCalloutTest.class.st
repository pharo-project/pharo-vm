Class {
	#name : 'VMJitFFISameThreadCalloutTest',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#instVars : [
		'jitCompilerClass',
		'abi'
	],
	#pools : [
		'LibFFIConstants'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'building suites' }
VMJitFFISameThreadCalloutTest class >> wordSize64Parameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'aarch64'. #wordSize -> 8};
		addCase: { #ISA -> #'X64'. #wordSize -> 8. #ABI -> #'_WIN64' };
		addCase: { #ISA -> #'X64'. #wordSize -> 8. #ABI -> #SysV };		
		yourself
]

{ #category : 'as yet unclassified' }
VMJitFFISameThreadCalloutTest >> ABI: anAbi [

	abi := anAbi
]

{ #category : 'helpers' }
VMJitFFISameThreadCalloutTest >> assertIsNonOptimizedCall: aTFFunctionDefinition [
	
	self deny: machineSimulator pc equals: (interpreter getHandler: aTFFunctionDefinition)
]

{ #category : 'helpers' }
VMJitFFISameThreadCalloutTest >> assertIsOptimizedCall: aTFFunctionDefinition [
	
	self assert: machineSimulator pc equals: (interpreter getHandler: aTFFunctionDefinition)
]

{ #category : 'helpers' }
VMJitFFISameThreadCalloutTest >> callCogMethod: callingMethod receiver: receiver arguments: args returnAddress: returnAddress [

	cogit processor setFramePointer: interpreter framePointer stackPointer: interpreter stackPointer.

	^ super callCogMethod: callingMethod receiver: receiver arguments: args returnAddress: returnAddress

]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> jitCompilerClass [

	^ jitCompilerClass ifNil: [ jitCompilerClass := super jitCompilerClass ]
]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> jitCompilerClass: aValue [

	jitCompilerClass := aValue
]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> jitOptions [ 
	
	| options |
	
	options := super jitOptions.
	
	^ abi 
		ifNotNil: [ options at: #ABI put: abi; yourself ]
		ifNil: [ options ]
	
]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> setUp [

	super setUp.
	
	self setUpTrampolines.
	self setUpCogMethodEntry.
	self createBaseFrame.
	
	interpreter libFFI: LibFFI new.
	interpreter libFFI interpreter: interpreter.
	
	self installFloatClass.
	self createExternalAddressClass.


]

{ #category : 'running' }
VMJitFFISameThreadCalloutTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit methodAbortTrampolines at: 0 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 1 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 2 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 3 put: cogit ceMethodAbortTrampoline.
	
	cogit picMissTrampolines at: 0 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 1 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 2 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 3 put: cogit ceCPICMissTrampoline.

	cogit picAbortTrampolines at: 0 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 1 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 2 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 3 put: cogit cePICAbortTrampoline.
	
	cogit ceStoreCheckTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceStoreCheckTrampoline).
	cogit objectRepresentation setAllStoreTrampolinesWith: (self compileTrampoline: [ cogit RetN: 0 ] named: #ceStoreTrampoline).
	
	cogit generateSameThreadCalloutTrampolines
]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionCallsExternalFunction [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ 
			self assertIsNonOptimizedCall: tfExternalFunction.
			called := true ] 
		withArgumentTypes: {} 
		withReturnType: interpreter libFFI void.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called
]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionChangesStack [

	| compiledMethod cogMethod tfExternalFunction changedStack anExternalAddress |

	changedStack := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [ 
										self assertIsNonOptimizedCall: tfExternalFunction.			
										changedStack := (machineSimulator stackPointerRegisterValue bitAnd: 16rFFFFFF00) = (cogit getCStackPointer bitAnd: 16rFFFFFF00).
										0 ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI void.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: changedStack.

]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionPopsCorrectlyAndReturnsTheResult [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ :a :b | 
			self assertIsNonOptimizedCall: tfExternalFunction.
			a + b ] 
		withArgumentTypes: {interpreter libFFI sint64. interpreter libFFI sint64} 
		withReturnType: interpreter libFFI sint64.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory integerObjectOf: 13);
		                  literalAt: 2 put: (memory integerObjectOf: 4);
		                  literalAt: 3 put: memory nilObject; "Class binding"
		                  bytecodes: #[ 
											33		"Push literal 1"
											34		"Push literal 2"
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 17).

]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testExecutingFunctionReturnsCorrectValue [

	| compiledMethod cogMethod externalFunction tfExternalFunction called |

	called := false.

	tfExternalFunction := self 
		createExternalFunctionFor:  [ 
			self assertIsNonOptimizedCall: tfExternalFunction.			
			17 ] 
		withArgumentTypes: {} 
		withReturnType: interpreter libFFI sint64.


	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.
		
	externalFunction := self compile: [ cogit Stop ].
	
	cogMethod := cogit cog: compiledMethod selector: memory nilObject.
	
	self deny: cogMethod isNil.

	self 
		callCogMethod: cogMethod 
		receiver: (memory integerObjectOf: 23) 
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 17).

]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testJITCompilesCallToTrampolineByDefault [

	| compiledMethod cogMethod tfExternalFunction |
	tfExternalFunction := self
		                      createExternalFunctionFor: [ self assertIsNonOptimizedCall: tfExternalFunction ]
		                      withArgumentTypes: {  }
		                      withReturnType: interpreter libFFI void.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[ 
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: memory nilObject
		arguments: {  }
		returnAddress: cogit ceSameThreadCalloutTrampoline.

	self
		assert: machineSimulator pc
		equals: cogit ceSameThreadCalloutTrampoline.
	self
		assert: machineSimulator sendNumberOfArgumentsRegisterValue
		equals: 0
]

{ #category : 'tests - double to void' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI double }
		                      withReturnType: interpreter libFFI void.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory floatObjectOf: 23.5);
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: 23.5
]

{ #category : 'tests - pointer pointer pointer pointer to void' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionFunctionPointerPointerPointerPointerToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments anExternalAddress argumentTypes anotherExternalAddress anotherExternalAddress2 anotherExternalAddress3 |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes :={ interpreter libFFI pointer. interpreter libFFI pointer. interpreter libFFI pointer. interpreter libFFI pointer }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :ptr2 :ptr3 :ptr4 | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := { ptr. ptr2. ptr3. ptr4 }.
										0 ]
		                      withArgumentTypes: argumentTypes 
		                      withReturnType: interpreter libFFI void.

	anExternalAddress := self newExternalAddress: 17.
	anotherExternalAddress := self newExternalAddress: 18.
	anotherExternalAddress2 := self newExternalAddress: 19.
	anotherExternalAddress3 := self newExternalAddress: 20.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: anotherExternalAddress;
		                  literalAt: 3 put: anotherExternalAddress2;
		                  literalAt: 4 put: anotherExternalAddress3;	
		                  literalAt: 5 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17.
	self assert: receivedArguments second equals: 18.
	self assert: receivedArguments third equals: 19.
	self assert: receivedArguments fourth equals: 20.	
]

{ #category : 'tests - pointer double double double double void' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerDoubleDoubleDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArgument1 receivedArgument2 receivedArgument3 anExternalAddress receivedArgument4 receivedArgument5 |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :dbl1 :dbl2 :dbl3 :dbl4 | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument1 := ptr.
										receivedArgument2 := dbl1.
										receivedArgument3 := dbl2.
										receivedArgument4 := dbl3.
										receivedArgument5 := dbl4.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double }
		                      withReturnType: interpreter libFFI void.		

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: (memory floatObjectOf: 99.5);
		                  literalAt: 5 put: (memory floatObjectOf: 55.0);
		                  literalAt: 6 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											37 "PushLiteral 5"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument1 equals: 17.
	self assert: receivedArgument2 equals: 23.5.
	self assert: receivedArgument3 equals: 42.0.
	self assert: receivedArgument4 equals: 99.5.
	self assert: receivedArgument5 equals: 55.0.			
]

{ #category : 'tests - pointer double double double void' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerDoubleDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArgument1 receivedArgument2 receivedArgument3 anExternalAddress receivedArgument4 |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :dbl1 :dbl2 :dbl3 | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument1 := ptr.
										receivedArgument2 := dbl1.
										receivedArgument3 := dbl2.
										receivedArgument4 := dbl3.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double }
		                      withReturnType: interpreter libFFI void.		

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: (memory floatObjectOf: 99.5);
		                  literalAt: 5 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument1 equals: 17.
	self assert: receivedArgument2 equals: 23.5.
	self assert: receivedArgument3 equals: 42.0.
	self assert: receivedArgument4 equals: 99.5.

]

{ #category : 'tests - pointer double double to void' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArgument1 receivedArgument2 receivedArgument3 anExternalAddress |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :dbl1 :dbl2 | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument1 := ptr.
										receivedArgument2 := dbl1.
										receivedArgument3 := dbl2.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double }
		                      withReturnType: interpreter libFFI void.		

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument1 equals: 17.
	self assert: receivedArgument2 equals: 23.5.
	self assert: receivedArgument3 equals: 42.0.		
]

{ #category : 'tests - pointer to pointer' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerToPointer [

	| compiledMethod cogMethod tfExternalFunction called anExternalAddress |

	called := false.

	tfExternalFunction := self
		                      createExternalFunctionFor: [ :e | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true. e + 23 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI pointer.		

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: (memory fetchClassTagOf: machineSimulator receiverRegisterValue) equals: memory classExternalAddressIndex.
	self assert: (interpreter readAddress: machineSimulator receiverRegisterValue) equals: 17 + 23.
	
	self assert: called.

]

{ #category : 'tests - pointer to void (NonOpt)' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerToVoidWithNilAsParameter [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: 0
]

{ #category : 'tests - pointer to void (NonOpt)' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionPointerToVoidWithOopAsParameter [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArgument |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										receivedArgument := arg.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: aByteArray;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArgument equals: aByteArray + BaseHeaderSize 
]

{ #category : 'tests - void to pointer' }
VMJitFFISameThreadCalloutTest >> testNonOptimizedFunctionVoidToPointer [

	| compiledMethod cogMethod tfExternalFunction called |

	called := false.

	tfExternalFunction := self
		                      createExternalFunctionFor: [ 
										self assertIsNonOptimizedCall: tfExternalFunction.
										called := true.
										16rCAFEBABE ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI pointer.		

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: (memory fetchClassTagOf: machineSimulator receiverRegisterValue) equals: memory classExternalAddressIndex.
	self assert: (interpreter readAddress: machineSimulator receiverRegisterValue) equals: 16rCafeBabe.
	
	self assert: called.

]

{ #category : 'tests - double to void' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArguments argumentTypes |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.
	argumentTypes := { interpreter libFFI double }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator
														 fetchArgumentsOfTypes: argumentTypes.
										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION.

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory floatObjectOf: 23.5);
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 23.5
]

{ #category : 'tests - pointer double double double double void' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerDoubleDoubleDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments argumentTypes anExternalAddress |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes := { interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr ":dbl1 :dbl2 :dbl3 :dbl4 Double Parameters are not handled by our simulation"  | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.
										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.
	

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: (memory floatObjectOf: 99.5);
		                  literalAt: 5 put: (memory floatObjectOf: 55.0);
		                  literalAt: 6 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											37 "PushLiteral 5"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17.
	self assert: receivedArguments second equals: 23.5.
	self assert: receivedArguments third equals: 42.0.
	self assert: receivedArguments fourth equals: 99.5.
	self assert: receivedArguments fifth equals: 55.0.
]

{ #category : 'tests - pointer double double double void' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerDoubleDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments argumentTypes anExternalAddress |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes := { interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double. interpreter libFFI double }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :dbl1 :dbl2 :dbl3 | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.
										0 ]
		                      withArgumentTypes: argumentTypes 
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: (memory floatObjectOf: 99.5);
		                  literalAt: 5 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17.
	self assert: receivedArguments second equals: 23.5.
	self assert: receivedArguments third equals: 42.0.
	self assert: receivedArguments fourth equals: 99.5.

]

{ #category : 'tests - pointer double double to void' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerDoubleDoubleToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments anExternalAddress argumentTypes |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes :={ interpreter libFFI pointer. interpreter libFFI double. interpreter libFFI double }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :dbl1 :dbl2 | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.

										0 ]
		                      withArgumentTypes: argumentTypes 
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: (memory floatObjectOf: 23.5);
		                  literalAt: 3 put: (memory floatObjectOf: 42.0);
		                  literalAt: 4 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17.
	self assert: receivedArguments second equals: 23.5.
	self assert: receivedArguments third equals: 42.0.		
]

{ #category : 'tests - pointer pointer pointer pointer to void' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerPointerPointerPointerToVoid [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments anExternalAddress argumentTypes anotherExternalAddress anotherExternalAddress2 anotherExternalAddress3 |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes :={ interpreter libFFI pointer. interpreter libFFI pointer. interpreter libFFI pointer. interpreter libFFI pointer }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:ptr :ptr2 :ptr3 :ptr4 | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.

										0 ]
		                      withArgumentTypes: argumentTypes 
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.
	anotherExternalAddress := self newExternalAddress: 18.
	anotherExternalAddress2 := self newExternalAddress: 19.
	anotherExternalAddress3 := self newExternalAddress: 20.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: anotherExternalAddress;
		                  literalAt: 3 put: anotherExternalAddress2;
		                  literalAt: 4 put: anotherExternalAddress3;	
		                  literalAt: 5 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											34 "PushLiteral 2"
											35 "PushLiteral 3"
											36 "PushLiteral 4"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17.
	self assert: receivedArguments second equals: 18.
	self assert: receivedArguments third equals: 19.
	self assert: receivedArguments fourth equals: 20.	
]

{ #category : 'tests - pointer to pointer' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToPointer [

	| compiledMethod cogMethod tfExternalFunction called anExternalAddress |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	tfExternalFunction := self
		                      createExternalFunctionFor: [ :e | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true. e + 23 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI pointer
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: (memory fetchClassTagOf: machineSimulator receiverRegisterValue) equals: memory classExternalAddressIndex.
	self assert: (interpreter readAddress: machineSimulator receiverRegisterValue) equals: 17 + 23.
	
	self assert: called.

]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidAllowinOopsWithOopAsParameter [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArguments argumentTypes |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes := { interpreter libFFI pointer }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.

										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_OBJECTS.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: aByteArray;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: aByteArray + BaseHeaderSize 
]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidChangesStack [

	| compiledMethod cogMethod tfExternalFunction changedStack anExternalAddress |

	isa = #IA32 ifTrue: [ ^ self skip ].

	changedStack := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										changedStack := (machineSimulator stackPointerRegisterValue bitAnd: 16rFFFFFF00) = (cogit getCStackPointer bitAnd: 16rFFFFFF00).
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: changedStack.

]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithExternalAddressAsParameter [

	| compiledMethod cogMethod tfExternalFunction called receivedArguments anExternalAddress argumentTypes |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	argumentTypes := { interpreter libFFI pointer }.
	
	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.
										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: anExternalAddress;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 23).
	self assert: called.
	self assert: receivedArguments first equals: 17
]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithNilAsParameterShouldFail [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArguments argumentTypes |
	
	isa = #IA32 ifTrue: [ ^ self skip ].
		
	called := false.
	argumentTypes := { interpreter libFFI pointer }.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.
										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: cogit ceFallbackInvalidFFICallTrampoline.

	self assert: machineSimulator pc equals: cogit ceFallbackInvalidFFICallTrampoline.
	self deny: called.

]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithOopAsParameterShouldFail [

	| compiledMethod cogMethod tfExternalFunction aByteArray called receivedArguments argumentTypes |

	isa = #IA32 ifTrue: [ ^ self skip ].
	
	called := false.
	argumentTypes := { interpreter libFFI pointer }. 

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										receivedArguments := machineSimulator 
													fetchArgumentsOfTypes: argumentTypes.

										0 ]
		                      withArgumentTypes: argumentTypes
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES.		

	aByteArray := self newByteArrayWithContent: #[1 2 3 4 0 0 0 0].

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: aByteArray;
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: cogit ceFallbackInvalidFFICallTrampoline.

	self assert: machineSimulator pc equals: cogit ceFallbackInvalidFFICallTrampoline.
	self deny: called.

]

{ #category : 'tests - pointer to void (Opt)' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionPointerToVoidWithSmallIntegerAsParameterShouldFail [

	| compiledMethod cogMethod tfExternalFunction called |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [:arg | 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										0 ]
		                      withArgumentTypes: { interpreter libFFI pointer }
		                      withReturnType: interpreter libFFI void
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION | FFI_FLAG_POINTERS_MIGHT_BE_EXTERNAL_ADDRESSES  | FFI_FLAG_POINTERS_MIGHT_BE_OBJECTS .		

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: (memory integerObjectOf: 17);
		                  literalAt: 2 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											33 "PushLiteral 1"
											230 0 "SameThreadCallout Literal0"
											88 "ReturnReceiver"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: cogit ceFallbackInvalidFFICallTrampoline.

	self assert: machineSimulator pc equals: cogit ceFallbackInvalidFFICallTrampoline.
	self deny: called.

]

{ #category : 'tests - void to pointer' }
VMJitFFISameThreadCalloutTest >> testOptimizedFunctionVoidToPointer [

	| compiledMethod cogMethod tfExternalFunction called |

	isa = #IA32 ifTrue: [ ^ self skip ].

	called := false.

	tfExternalFunction := self
		                      createExternalFunctionFor: [ 
										self assertIsOptimizedCall: tfExternalFunction.
										called := true.
										16rCafeBabe ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI pointer
									flags: FFI_FLAG_USE_OPTIMIZED_VERSION.

	compiledMethod := methodBuilder
		                  newMethod;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											230 0 "SameThreadCallout Literal0"
											92 "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {}
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: (memory fetchClassTagOf: machineSimulator receiverRegisterValue) equals: memory classExternalAddressIndex.
	self assert: (interpreter readAddress: machineSimulator receiverRegisterValue) equals: 16rCafeBabe.
	
	self assert: called.

]

{ #category : 'tests - general bytecode' }
VMJitFFISameThreadCalloutTest >> testPopingIntoTemporaryReturnValueWorkCorrectly [

	| compiledMethod cogMethod tfExternalFunction called anExternalAddress |

	called := false.

	"I need to return 0 in the function, even if it is void, as the simulation cannot identify when it is a 
	void returning function "
	tfExternalFunction := self
		                      createExternalFunctionFor: [ 
										self assertIsNonOptimizedCall: tfExternalFunction.			
										called:= true. 32 ]
		                      withArgumentTypes: { }
		                      withReturnType: interpreter libFFI sint64.

	anExternalAddress := self newExternalAddress: 17.

	compiledMethod := methodBuilder
		                  newMethod;
						   numberOfTemporaries: 1;
		                  literalAt: 0 put: tfExternalFunction;
		                  literalAt: 1 put: memory nilObject; "Class Binding"
		                  bytecodes: #[
											230 0 "SameThreadCallout Literal0"
											208 "PopInto Temp 0"
											64	 "Push Temp 0"
											92  "ReturnTop"];
		                  buildMethod.

	cogMethod := cogit cog: compiledMethod selector: memory nilObject.

	self deny: cogMethod isNil.

	self
		callCogMethod: cogMethod
		receiver: (memory integerObjectOf: 23)
		arguments: {  }
		returnAddress: callerAddress.

	self assert: machineSimulator pc equals: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: 32).
	self assert: called.

]
