Class {
	#name : 'VMStackToRegisterMappingTest',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'running' }
VMStackToRegisterMappingTest >> setUp [

	super setUp.
	"Start with an empty stack, always has at least self in the fixed part"
	
	" | self        |  \
	  | arg0        |   |
	  | ...         |   |
	  | argn        |   - Fixed part per frame. Pops should not touch this part
	  | temp0       |   |
	  | ...         |   |
	  | temp1       |  /
	  | stackEntry0 |  \
	  | ...         |   - Variable part per frame. Push and pop act here.
	  | stackEntryn |  /
	"
	
	cogit methodOrBlockNumTemps: 0.
	cogit initSimStackPointer: 0.
	
	"Spilling only works on frameful compilation"
	cogit needsFrame: true
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testFlushBelowTop [

	| stop stackPointerBefore framePointer |
	sendAddress := self compile: [
		cogit ssPushConstant: 1.
		"Do not flush the constant, and pop it"
		cogit ssFlushStackExceptTop: 1.
		cogit ssPop: 1 popSpilled: false.
		stop := cogit Stop
	].

	"Push a frame. Saved FP, method, context, receiver"
	framePointer := self machineSimulator smalltalkStackPointerRegisterValue.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: (memory integerObjectOf: 17).

	self machineSimulator framePointerRegisterValue: framePointer.
	stackPointerBefore := self machineSimulator smalltalkStackPointerRegisterValue.
	self runFrom: sendAddress until: stop address.

	"The stack top should still be the receiver"
	self assert: self machineSimulator smalltalkStackPointerRegisterValue equals: stackPointerBefore.
	self assert: self popAddress equals: (memory integerObjectOf: 17)
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopConstant [

	cogit ssPushConstant: 1.
	cogit ssPop: 1.
	
	self assert: cogit ssSize equals: 1.
	self assert: cogit ssTop equals: cogit simSelf.
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopNonSpilledTopToRegister [

	| stop stackPointerBefore framePointer |
	sendAddress := self compile: [
		cogit ssPushConstant: 1.
		cogit ssFlushStackExceptTop: 1.
		cogit ssPopTopToReg: ReceiverResultReg.
		stop := cogit Stop
	].

	"Push a frame. Saved FP, method, context, receiver"
	framePointer := self machineSimulator smalltalkStackPointerRegisterValue.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: (memory integerObjectOf: 17).

	self machineSimulator framePointerRegisterValue: framePointer.
	stackPointerBefore := self machineSimulator smalltalkStackPointerRegisterValue.
	self runFrom: sendAddress until: stop address.

	"Nothing should have been left in the stack"
	self assert: self machineSimulator smalltalkStackPointerRegisterValue equals: stackPointerBefore.
	self assert: self machineSimulator receiverRegisterValue equals: 1
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopRegister [

	cogit ssPushRegister: TempReg.
	cogit ssPop: 1.
	
	self assert: cogit ssSize equals: 1.
	self assert: cogit ssTop equals: cogit simSelf
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopSpilledConstantShouldPopFromStack [

	| stop stackPointerBefore framePointer |
	sendAddress := self compile: [
		cogit ssPushConstant: 1.
		cogit ssFlushStack.
		cogit ssPop: 1.
		stop := cogit Stop
	].

	"Push a frame. Saved FP, method, context, receiver"
	framePointer := self machineSimulator smalltalkStackPointerRegisterValue.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: (memory integerObjectOf: 17).

	self machineSimulator framePointerRegisterValue: framePointer.
	stackPointerBefore := self machineSimulator smalltalkStackPointerRegisterValue.
	self runFrom: sendAddress until: stop address.

	"Nothing should have been left in the stack"
	self assert: self machineSimulator smalltalkStackPointerRegisterValue equals: stackPointerBefore
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopSpilledConstantWithoutPoppingShouldNotPopFromStack [

	| stop stackPointerBefore framePointer |
	sendAddress := self compile: [
		cogit ssPushConstant: 1.
		cogit ssFlushStack.
		cogit ssPop: 1 popSpilled: false.
		stop := cogit Stop
	].

	"Push a frame. Saved FP, method, context, receiver"
	framePointer := self machineSimulator smalltalkStackPointerRegisterValue.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: (memory integerObjectOf: 17).

	self machineSimulator framePointerRegisterValue: framePointer.
	stackPointerBefore := self machineSimulator smalltalkStackPointerRegisterValue.
	self runFrom: sendAddress until: stop address.

	"The constant should have been pushed"
	self assert: self machineSimulator smalltalkStackPointerRegisterValue equals: stackPointerBefore - memory wordSize.
	self assert: self popAddress equals: 1
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPopSpilledTopToRegister [

	| stop stackPointerBefore framePointer |
	sendAddress := self compile: [
		cogit ssPushConstant: 1.
		cogit ssFlushStack.
		cogit ssPopTopToReg: ReceiverResultReg.
		stop := cogit Stop
	].

	"Push a frame. Saved FP, method, context, receiver"
	framePointer := self machineSimulator smalltalkStackPointerRegisterValue.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: 0.
	self pushAddress: (memory integerObjectOf: 17).

	self machineSimulator framePointerRegisterValue: framePointer.
	stackPointerBefore := self machineSimulator smalltalkStackPointerRegisterValue.
	self runFrom: sendAddress until: stop address.

	"Nothing should have been left in the stack"
	self assert: self machineSimulator smalltalkStackPointerRegisterValue equals: stackPointerBefore.
	self assert: self machineSimulator receiverRegisterValue equals: 1
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPushConstant [

	cogit ssPushConstant: 1.
	
	self assert: cogit ssSize equals: 2.
	self assert: cogit ssTop type equals: SSConstant.
	self assert: cogit ssTop constant equals: 1.
	self deny: cogit ssTop spilled
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testPushRegister [

	cogit ssPushRegister: TempReg.

	self assert: cogit ssSize equals: 2.
	self assert: cogit ssTop type equals: SSRegister.
	self assert: cogit ssTop registerr equals: TempReg.
	self deny: cogit ssTop spilled
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testSpillConstant [

	cogit ssPushConstant: 1.
	cogit ssFlushStack.

	"Should not pop/push the stack"	
	self assert: cogit ssSize equals: 2.
	
	"The element should be the same as before"
	self assert: cogit ssTop type equals: SSConstant.
	self assert: cogit ssTop constant equals: 1.
	
	"But not it is spilled"
	self assert: cogit ssTop spilled
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testSpillRegister [

	cogit ssPushRegister: TempReg.
	cogit ssFlushStack.

	"Should not pop/push the stack"	
	self assert: cogit ssSize equals: 2.
	
	"The element should now be in a spilled position in the stack.
	I.e., Relative to FPReg, with offset 4 (base 0) in the frame (the first three are saved FP, method, context, receiver)"
	self assert: cogit ssTop type equals: SSSpill.
	self assert: cogit ssTop base equals: FPReg.
	self assert: cogit ssTop offset equals: -4 * memory wordSize.
	
	"But it is spilled"
	self assert: cogit ssTop spilled
]

{ #category : 'tests' }
VMStackToRegisterMappingTest >> testTopOfEmptyIsSimSelf [
	
	self assert: cogit ssSize equals: 1.
	self assert: cogit ssTop equals: cogit simSelf
]
