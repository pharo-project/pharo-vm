Extension { #name : #BlockClosure }

{ #category : #'*VMMaker-interpreter simulator' }
BlockClosure >> shouldStopIfAtPC: address [
	<primitive: 202>
	^self value: address
]

{ #category : #'*VMMaker-conveniences' }
BlockClosure >> value: firstArg value: secondArg value: thirdArg value: fourthArg value: fifthArg [
	"Activate the receiver, creating a closure activation (MethodContext)
	 whose closure is the receiver and whose caller is the sender of this
	 message. Supply the arguments and copied values to the activation
	 as its arguments and copied temps. Primitive. Essential."

	<primitive: 205>
	numArgs ~= 5 ifTrue: [ self numArgsError: 5 ].
	self primitiveFailed
]
