Class {
	#name : 'VMPushThisProcessTest',
	#superclass : 'VMStackToRegisterMappingCogitTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests - thisContext' }
VMPushThisProcessTest >> setUp [

	super setUp.
	wordSize = 4 ifTrue: [ self skip ].

]

{ #category : 'tests - thisContext' }
VMPushThisProcessTest >> testPushThisProcessBytecodePushesOnlyThisProcess [

	| method machineCodeBreakpoint |

	self setUpScheduler.

	method := self compile: [

		cogit needsFrame: true.
		cogit methodOrBlockNumTemps: 0.
		cogit initSimStackPointer: nil.

		cogit byte1: 1.
		cogit extBBytecode.
		self assert: cogit extB equals: 1.
		cogit genExtPushPseudoVariable.
		cogit ssFlushStack.

		machineCodeBreakpoint := cogit Stop ].

	"We test that before our pushed value we find the same badfood"
	self pushAddress: 16rbadf00d.

	"Push the active process and pop it back"
	self
		runFrom: method
		until: machineCodeBreakpoint address.
	self popAddress.

	self
		assert: self popAddress
		equals: 16rbadf00d
]

{ #category : 'tests - thisContext' }
VMPushThisProcessTest >> testPushThisProcessBytecodePushesThisProcess [

	| method machineCodeBreakpoint |

	self setUpScheduler.

	method := self compile: [

		cogit needsFrame: true.
		cogit methodOrBlockNumTemps: 0.
		cogit initSimStackPointer: nil.

		cogit byte1: 1.
		cogit extBBytecode.
		self assert: cogit extB equals: 1.
		cogit genExtPushPseudoVariable.
		cogit ssFlushStack.

		machineCodeBreakpoint := cogit Stop ].

	self
		runFrom: method
		until: machineCodeBreakpoint address.

	self
		assert: self popAddress
		equals: memory memoryActiveProcess
]
