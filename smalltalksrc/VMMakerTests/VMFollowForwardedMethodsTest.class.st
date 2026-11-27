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
VMFollowForwardedMethodsTest >> testDoesNotReadTheSelectorOfAFreedMethod [
	"Nothing updates the selector of a freed method: after a compaction of old space it points inside
	 another object, and reading it as an object can crash the VM. So the walk after a become must not
	 read it at all. Here the selector is a canary that cannot be read: any read of it fails."

	| freedMethod selectorThatCannotBeRead |
	freedMethod := cogit
		               cog: (self createMethodOopFromHostMethod: (self findMethod: #methodReturningNil))
		               selector: self newZeroSizedObject.
	cogit methodZone freeMethod: freedMethod.
	selectorThatCannotBeRead := 0. "nothing is mapped at address 0"
	freedMethod selector: selectorThatCannotBeRead.

	self shouldnt: [ cogit followForwardedMethods ] raise: Error
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
