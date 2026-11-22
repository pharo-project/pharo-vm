"
I test Cogit>>followForwardedMethods, the walk of the method zone after a become.
"
Class {
	#name : 'VMFollowForwardedMethodsTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'methods under test' }
VMFollowForwardedMethodsTest >> methodReturningNil [

	^ nil
]

{ #category : 'tests' }
VMFollowForwardedMethodsTest >> testDoesNotFollowTheSelectorOfAFreedMethod [
	"A freed method keeps the selector it had, and nothing updates it any more: after a compaction
	 of old space it can point inside another object. Here it points at a slot holding nil, which
	 read as a header has class index 0 and passes isOopForwarded:. Following it reads the next word
	 as the forwarding pointer."

	| machineCodeMethod objectAroundStaleSelector staleSelector |
	machineCodeMethod := cogit
		                     cog: (self createMethodOopFromHostMethod: (self findMethod: #methodReturningNil))
		                     selector: self newZeroSizedObject.
	cogit methodZone freeMethod: machineCodeMethod.

	objectAroundStaleSelector := self newOldSpaceObjectWithSlots: 2.
	memory storePointer: 1 ofObject: objectAroundStaleSelector withValue: (memory integerObjectOf: 42).
	staleSelector := objectAroundStaleSelector + memory baseHeaderSize.
	machineCodeMethod selector: staleSelector.
	self assert: (memory isOopForwarded: staleSelector).

	cogit followForwardedMethods.

	self assert: machineCodeMethod selector equals: staleSelector
]

{ #category : 'tests' }
VMFollowForwardedMethodsTest >> testFollowsTheForwardedSelectorOfAMethod [

	| machineCodeMethod selector newSelector |
	selector := self newZeroSizedObject.
	machineCodeMethod := cogit
		                     cog: (self createMethodOopFromHostMethod: (self findMethod: #methodReturningNil))
		                     selector: selector.
	newSelector := self newOldSpaceObjectWithSlots: 0.
	memory forward: selector to: newSelector.

	cogit followForwardedMethods.

	self assert: machineCodeMethod selector equals: newSelector
]
