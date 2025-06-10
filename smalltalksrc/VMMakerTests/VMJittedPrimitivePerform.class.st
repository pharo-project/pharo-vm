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
		cogit methodOrBlockNumArgs: 1.
		cogit objectRepresentation genPrimitivePerform.
		stop := cogit Stop ]
	bytecodes: 10
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
VMJittedPrimitivePerform >> testPrimitivePerformFailsIfMethodFoundIsNotRightArity [

	| receiver selector method machineCodeMethod |
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.

	"The target method has 1 argument, the perform callsite does not provide it
		=> we expect check fail"
	method := methodBuilder numberOfArguments: 1; buildMethod.
	machineCodeMethod := targetMethodAddress.
	(cogit cogMethodSurrogateAt: machineCodeMethod)
		objectHeader: memory nullHeaderForMachineCodeMethod;
		methodObject: method;
		cmNumArgs: 1;
		methodHeader: (interpreter rawHeaderOf: method).
	interpreter rawHeaderOf: method put: machineCodeMethod.
	
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

	| receiver selector method machineCodeMethod |
	receiver := memory nilObject.
	selector := memory integerObjectOf: 2.

	machineCodeMethod := targetMethodAddress.
	method := methodBuilder numberOfArguments:0; buildMethod.
	(cogit cogMethodSurrogateAt: machineCodeMethod)
		methodObject: method;
		objectHeader: memory nullHeaderForMachineCodeMethod.
	interpreter rawHeaderOf: method put: machineCodeMethod.
	
	interpreter messageSelector: selector.
	interpreter newMethod: method.
	interpreter addNewMethodToCache: (memory fetchClassOf: receiver).

	self prepareStackForSendReceiver: receiver arguments: { selector }.

	self runFrom: cogInitialAddress until: targetMethodAddress + cogit noCheckEntryOffset
]
