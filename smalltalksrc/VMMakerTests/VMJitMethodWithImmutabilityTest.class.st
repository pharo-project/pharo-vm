Class {
	#name : 'VMJitMethodWithImmutabilityTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'running' }
VMJitMethodWithImmutabilityTest >> initialCodeSize [

	^ 32 * 1024
]

{ #category : 'initialization' }
VMJitMethodWithImmutabilityTest >> setUp [ 

	super setUp.
	self initializeSpecialSelectors
]

{ #category : 'initialization' }
VMJitMethodWithImmutabilityTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit superSendTrampolineAt: 0 put: (self compileTrampoline: [ cogit RetN: 0 ] named:#superSendTrampoline0). 
	cogit ordinarySendTrampolineAt: 0 put: (self compileTrampoline: [ cogit RetN: 0 ] named:#ordinarySendTrampoline0). 
	
]

{ #category : 'tests' }
VMJitMethodWithImmutabilityTest >> testCompileMethodWithALotOfAssignmentsToInstanceVariables [
	| callingMethod |
	
	callingMethod := self jitMethod: (VMJistMethodTestObject>>#initialize).
	
	self deny: callingMethod address equals: 0.
]
