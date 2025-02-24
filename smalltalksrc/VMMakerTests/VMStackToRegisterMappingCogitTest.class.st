Class {
	#name : 'VMStackToRegisterMappingCogitTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#instVars : [
		'methodReceiver',
		'receiverOperationBlock',
		'argumentOperation',
		'codeAddress',
		'receiverValue',
		'argumentValue',
		'arguments',
		'sendBytecode',
		'value1',
		'value2',
		'expectedResult',
		'expectedReflexiveResult'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> argumentOperation: aFullBlockClosure [ 
	
	argumentOperation := aFullBlockClosure
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> arguments: aCollection [ 
	arguments := aCollection
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> buildStackFrame [
	"Let's prepare the trampoline in case of non-optimized path"
	self createSpecialSelectorArray.

	"We will call to this address"
	sendTrampolineAddress := self compile: [ cogit RetN: 0 ].
	cogit ordinarySendTrampolineAt: sentSelector numArgs put: sendTrampolineAddress.
	
	"Setting a value that is not the SmallInteger tag"
	cogit methodOrBlockNumTemps: "methodOrBlockNumTemps" 0 + arguments size.
	cogit methodOrBlockNumArgs: arguments size.
	cogit initSimStackForFramefulMethod: 0.
	cogit receiverTags: (memory fetchClassTagOf: methodReceiver).
	cogit regArgsHaveBeenPushed: false.

	self createFramefulCallFrom: callerAddress receiver: methodReceiver arguments: arguments temporaries: #().

]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> compileMethod [

	codeAddress := self compile: [ 
		               receiverOperationBlock value.
		               argumentOperation value.

		               cogit byte0: sendBytecode. "Eg: Special Send:#+"
		               cogit genSpecialSelectorArithmetic.
		               cogit genReturnTopFromMethod ]
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> expectedReflexiveResult [
	^ expectedReflexiveResult
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> expectedReflexiveResult: anObject [
	expectedReflexiveResult := anObject
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> expectedResult [
	^ expectedResult
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> expectedResult: anObject [
	expectedResult := anObject
]

{ #category : 'running' }
VMStackToRegisterMappingCogitTest >> jitCompilerClass [

	^ StackToRegisterMappingCogit 
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> methodReceiver: anOop [ 
	methodReceiver := anOop
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> receiverOperation: aFullBlockClosure [ 
	
	receiverOperationBlock := aFullBlockClosure
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> sendBytecode [
	^ sendBytecode
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> sendBytecode: anObject [
	sendBytecode := anObject
]

{ #category : 'running' }
VMStackToRegisterMappingCogitTest >> setUp [

	super setUp.
	methodReceiver := memory nilObject.
	arguments := #().
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> shouldCallTrampolineWith: receiverOfOperation and: argumentOfOperation [ 

	self buildStackFrame.
	self compileMethod.
	
	self runFrom: codeAddress until: sendTrampolineAddress.
	self assertSpecialSendTo: receiverOfOperation value withArg: argumentOfOperation value
]

{ #category : 'builder' }
VMStackToRegisterMappingCogitTest >> shouldPerformOperationReturning: aValue [ 

	self buildStackFrame.
	self compileMethod.
	
	self runFrom: codeAddress until: callerAddress.
	self assert: machineSimulator receiverRegisterValue equals: (memory integerObjectOf: aValue).
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> value1 [
	^ value1
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> value1: anObject [
	value1 := anObject
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> value2 [
	^ value2
]

{ #category : 'accessing' }
VMStackToRegisterMappingCogitTest >> value2: anObject [
	value2 := anObject
]
