Class {
	#name : #VMStorePopTest,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMStorePopTest >> jitOptions [

	^ super jitOptions
		  at: #IMMUTABILITY put: true;
		  yourself
]

{ #category : #tests }
VMStorePopTest >> testExtendedStoreAndPopIV1ImmutableObjectCallingConvention [

	| instanceVariableToWrite stopAddress methodWithStoreCheck storeTrampoline |
	instanceVariableToWrite := 1.
	
	"Create an object with at least `instanceVariableToWrite` instance variables.
	In memory, instance variables are 0-indexed so substract 1"
	obj := self newObjectWithSlots: instanceVariableToWrite.
	memory setIsImmutableOf: obj to: true.
	
	"The receiver should be in a receiver register based on Cog's calling convention"
	machineSimulator receiverRegisterValue: obj.
	
	"Set an address as store check trampoline.
	The bytecode below will jump to it if it is a old -> young store"
	storeTrampoline := self compileTrampoline: [ 
			stopAddress := cogit Stop ] named: #ceStoreTrampoline.
	cogit objectRepresentation
		setAllStoreTrampolinesWith: storeTrampoline.
		
	cogit ceStoreContextInstVarTrampoline: storeTrampoline.
	
	"When the store trampoline is called, the assigned value should be in the class register.
	Let's put a marker value. If we find this value after calling the trampoline, then the call did not set it."
	machineSimulator classRegisterValue: 16rBADF00D.
	
	"The first byte of the push receiver instance variable bytecode family is used to identify which variable (0-based again)"
	cogit byte0: instanceVariableToWrite - 1.		
	methodWithStoreCheck := self compile: [
		cogit useTwoPaths: false.
		cogit methodOrBlockNumTemps: 0.
		cogit extA: 0.
		cogit initSimStackForFramelessMethod: 0.
		cogit byte1: 0.
		cogit needsFrame: true.
		
		cogit genPushLiteral: memory falseObject.
		cogit genExtStoreReceiverVariableBytecode ].

	self runFrom: methodWithStoreCheck until: stopAddress address.
	
	self assert: machineSimulator classRegisterValue equals: memory falseObject
]

{ #category : #tests }
VMStorePopTest >> testStoreAndPopIV1ImmutableObjectCallingConvention [

	| instanceVariableToWrite stopAddress methodWithStoreCheck |
	instanceVariableToWrite := 1.
	
	"Create an object with at least `instanceVariableToWrite` instance variables.
	In memory, instance variables are 0-indexed so substract 1"
	obj := self newObjectWithSlots: instanceVariableToWrite.
	memory setIsImmutableOf: obj to: true.
	
	"The receiver should be in a receiver register based on Cog's calling convention"
	machineSimulator receiverRegisterValue: obj.
	
	"Set an address as store check trampoline.
	The bytecode below will jump to it if it is a old -> young store"
	cogit objectRepresentation
		setAllStoreTrampolinesWith: (self compileTrampoline: [ 
			stopAddress := cogit Stop ] named: #ceStoreTrampoline).
	
	"The first byte of the push receiver instance variable bytecode family is used to identify which variable (0-based again)"
	cogit byte0: instanceVariableToWrite - 1.		
	methodWithStoreCheck := self compile: [
		cogit useTwoPaths: false.
		cogit methodOrBlockNumTemps: 0.
		cogit initSimStackForFramelessMethod: 0.
		
		cogit genPushLiteral: memory falseObject.
		cogit genStoreAndPopReceiverVariableBytecode ].

	self runFrom: methodWithStoreCheck until: stopAddress address.
	
	self assert: machineSimulator classRegisterValue equals: memory falseObject
]
