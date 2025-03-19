Class {
	#name : 'VMClassTagInlineReadTest',
	#superclass : 'VMPrimitiveCallAbstractTest',
	#pools : [
		'CogRTLOpcodes'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMClassTagInlineReadTest >> testLinkingWithEntryOffset [

	| sendingMethod targetMethod callSiteReturn |
	sendingMethod := self
		                 jitMethod: (self findMethod: #methodWithSend)
		                 selector: memory nilObject.

	targetMethod := self
		                jitMethod: (self findMethod: #yourself)
		                selector: memory trueObject.

	cogit sendSitesIn: sendingMethod do: [ :annotation :pc | callSiteReturn := pc ].

	cogit
		linkSendAt: callSiteReturn
		in: sendingMethod
		to: targetMethod
		offset: cogit entryOffset
		receiver: memory falseObject.
		
	self assert: (cogit backend inlineCacheTagAt: callSiteReturn) equals:(memory classIndexOf: memory falseObject)
]

{ #category : 'tests' }
VMClassTagInlineReadTest >> testLinkingWithEntryOffsetLargeClassIndex [

	| sendingMethod targetMethod callSiteReturn |
	sendingMethod := self
		                 jitMethod: (self findMethod: #methodWithSend)
		                 selector: memory nilObject.

	cogit sendSitesIn: sendingMethod do: [ :annotation :pc | callSiteReturn := pc ].

	targetMethod := self
		                jitMethod: (self findMethod: #yourself)
		                selector: memory trueObject.


	obj := self newZeroSizedObject.
	memory setClassIndexOf: obj to: (1 << memory classIndexFieldWidth - 5).

	cogit
		linkSendAt: callSiteReturn
		in: sendingMethod
		to: targetMethod
		offset: cogit entryOffset
		receiver: obj.
	

	self assert: (cogit backend inlineCacheTagAt: callSiteReturn) equals: (1 << memory classIndexFieldWidth - 5)
]
