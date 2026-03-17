Class {
	#name : 'VMJittedPrimitivePerform',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#instVars : [
		'stop',
		'targetMethodAddress'
	],
	#pools : [
		'VMMethodCacheConstants'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'running' }
VMJittedPrimitivePerform >> jitCompilerClass [

	^ StackToRegisterMappingCogit 
]

{ #category : 'running' }
VMJittedPrimitivePerform >> setUp [

	| nilClass |
	super setUp.
	self setUpTrampolines.
	self setUpCogMethodEntry.

	memory coInterpreter moveMethodCacheToMemoryAt:
		(memory memoryManager allocate:
			 MethodCacheEntrySize * MethodCacheSize
			 * (interpreter sizeof: #sqInt)).

	nilClass := self
		            newClassInOldSpaceWithSlots: 0
		            instSpec: memory nonIndexablePointerFormat.
	memory
		setClassIndexOf: memory nilObject
		to: (memory ensureBehaviorHash: nilClass).

	targetMethodAddress := self compile: [
		stop := cogit Stop ]
	bytecodes: 10
	headerSize: cogit noCheckEntryOffset.

	cogInitialAddress := self compile: [
		"The perform has one argument: the selector"
		cogit methodOrBlockNumArgs: 2.
		cogit objectRepresentation genPrimitivePerform.
		stop := cogit Stop ]
	bytecodes: 10
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> setUpCompiledMethodWithArity: numberOfArguments [

	| machineCodeMethod method |
	method := methodBuilder
		          numberOfArguments: numberOfArguments;
		          buildMethod.
	machineCodeMethod := targetMethodAddress.
	(cogit cogMethodSurrogateAt: machineCodeMethod)
		objectHeader: memory nullHeaderForMachineCodeMethod;
		methodObject: method;
		cmNumArgs: numberOfArguments;
		methodHeader: (interpreter rawHeaderOf: method).
	interpreter rawHeaderOf: method put: machineCodeMethod.
	^ method
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> testPrimitivePerformFailsIfMethodFoundHasHigherArity [

	| receiver selector method numberOfArguments |
	"The target method has 1 argument, the perform callsite does not provide it
		=> we expect check fail"
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.
	
	numberOfArguments := 2.
	method := self setUpCompiledMethodWithArity: numberOfArguments.
	
	interpreter messageSelector: selector.
	interpreter newMethod: method.
	interpreter addNewMethodToCache: (memory fetchClassOf: receiver).
	self prepareStackForSendReceiver: receiver arguments: { selector }.
	self runFrom: cogInitialAddress until: stop address
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> testPrimitivePerformFailsIfMethodFoundHasLowerArity [

	| receiver selector method numberOfArguments |
	"The target method has 1 argument, the perform callsite does not provide it
		=> we expect check fail"
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.
	
	numberOfArguments := 0.
	method := self setUpCompiledMethodWithArity: numberOfArguments.
	
	interpreter messageSelector: selector.
	interpreter newMethod: method.
	interpreter addNewMethodToCache: (memory fetchClassOf: receiver).
	self prepareStackForSendReceiver: receiver arguments: { selector }.
	self runFrom: cogInitialAddress until: stop address
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> testPrimitivePerformFailsIfMethodFoundIsNotJITCompiled [

	| receiver selector method |
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.

	method := methodBuilder buildMethod.
	interpreter messageSelector: selector.
	interpreter newMethod: method.
	interpreter addNewMethodToCache: (memory fetchClassOf: receiver).

	self prepareStackForSendReceiver: receiver arguments: { selector }.

	self runFrom: cogInitialAddress until: stop address
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> testPrimitivePerformFailsIfMethodNotInCache [

	| selector |
	selector := 2.

	self
		prepareStackForSendReceiver: memory nilObject
		arguments: { memory integerObjectOf: selector }.

	self runFrom: cogInitialAddress until: stop address.
]

{ #category : 'tests' }
VMJittedPrimitivePerform >> testPrimitivePerformJumpsToMethodIfCompiled [

	| receiver selector method numberOfArguments |
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.

	numberOfArguments := 1.
	method := self setUpCompiledMethodWithArity: numberOfArguments.
	
	interpreter messageSelector: selector.
	interpreter newMethod: method.
	interpreter addNewMethodToCache: (memory fetchClassOf: receiver).

	self prepareStackForSendReceiver: receiver arguments: { selector }.

	self runFrom: cogInitialAddress until: targetMethodAddress + cogit noCheckEntryOffset
]