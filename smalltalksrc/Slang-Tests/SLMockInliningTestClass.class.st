Class {
	#name : 'SLMockInliningTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLMockInliningTestClass >> emptyMethod: arg [

	
]

{ #category : 'inlining-arguments' }
SLMockInliningTestClass >> emptyMethodAWithArgumentsInlined [

	self emptyMethod: self methodCAlwaysInlined
]

{ #category : 'inlining-arguments' }
SLMockInliningTestClass >> emptyMethodAWithSimpleArgumentsInlined [

	self emptyMethod: self methodBAlwaysInlined
]

{ #category : 'helpers' }
SLMockInliningTestClass >> functionalMethod [

	^ 4
]

{ #category : 'inlining-simple' }
SLMockInliningTestClass >> methodA [

	1 + 1.
	self methodB
]

{ #category : 'inlining-assignment-helpers' }
SLMockInliningTestClass >> methodAAssignOnReturn [

	1 + 1.
	^ self methodBAssignOnReturn
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineIfFalseReturningIfTrueInAssignement [

	| a |
	a := self methodBIfFalseReturningIfTrue
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineIfFalseReturningIfTrueInReturn [

	^ self methodBIfFalseReturningIfTrue
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineMultipleIfFalseReturningIfTrueInAssignment [

	| a |
	a := self methodB
		  ifFalse: [ self methodBIfFalseReturningIfTrue ]
		  ifTrue: [
			  5.
			  self methodBIfFalseReturningIfTrue ]
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineMultipleIfFalseReturningIfTrueInReturn [

	^ self methodB
		  ifFalse: [ self methodBIfFalseReturningIfTrue ]
		  ifTrue: [
			  5.
			  self methodBIfFalseReturningIfTrue ]
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineReturningIfTrueIfFalseInAssignment [

	| a |
	a := self methodBReturningIfTrueIfFalse
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineReturningIfTrueIfFalseInReturn [

	^ self methodBReturningIfTrueIfFalse
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineReturningIfTrueInAssignment [

	| a |
	a := self methodBReturningIfTrue
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineReturningIfTrueInReturn [

	^ self methodBReturningIfTrue
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineReturningInlinedIfTrueIfFalseInAssignment [

	| a |
	a := self methodBReturningInlinedIfTrueIfFalse
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineReturningInlinedIfTrueIfFalseInReturn [

	^ self methodBReturningInlinedIfTrueIfFalse
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAInlineReturningInlinedIfTrueInAssignment [

	| a |
	a := self methodBReturningInlinedIfTrue
]

{ #category : 'inlining-returning-conditional' }
SLMockInliningTestClass >> methodAInlineReturningInlinedIfTrueInReturn [

	^ self methodBReturningInlinedIfTrue
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturn [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnAsAssignmentExpression [

	| x |
	x := self methodBMultipleReturn
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnAsReturnExpression [

	^ self methodBMultipleReturn
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnAsReturnExpressionAndStatement [

	^ self methodBMultipleReturnExpressionAndStatement
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnExpression [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnInlined [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAReturnAssignment [

	| a |
	^ a := self methodB
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodAReturnBlockAssignment [

	| a |
	^ a := [ self methodB ]
]

{ #category : 'inlining-assignment-helpers' }
SLMockInliningTestClass >> methodAReturnOnAssignment [

	| var |
	1 + 1.
	^ self methodBReturnOnAssignment: [ :x |
		var := x.
		 ]
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodASimpleReturn [

	self methodBSimpleReturn.
	^ 1 + 1
]

{ #category : 'inlining-arguments' }
SLMockInliningTestClass >> methodAWithArgumentsInlined [

	^ self methodB: self methodCAlwaysInlined
]

{ #category : 'inlining-arguments' }
SLMockInliningTestClass >> methodAWithReturningSendArgumentsInlined [

	^ self methodB: self methodCAlwaysInlined
]

{ #category : 'inlining-returning-arguments' }
SLMockInliningTestClass >> methodAWithReturningSendWithMethodWithMultipleReturnInArgumentsInlined [

	^ self methodB: self methodAMultipleReturnInlined
]

{ #category : 'inlining-returning-arguments' }
SLMockInliningTestClass >> methodAWithReturningSendWithReturningIfInArgumentsInlined [

	^ self methodB: self methodBReturningIfTrueIfFalse
]

{ #category : 'inlining-returning-arguments' }
SLMockInliningTestClass >> methodAWithReturningSendWithReturningIfInSendInArgumentsInlined [

	^ self methodB: self methodBReturningIfTrueIfFalseInSend
]

{ #category : 'inlining-arguments' }
SLMockInliningTestClass >> methodAWithSimpleArgumentsInlined [

	self methodB: self methodBAlwaysInlined
]

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodB [

	2 + 2
]

{ #category : 'inlining-arguments-helpers' }
SLMockInliningTestClass >> methodB: anArg [

	<inline: #never>
	^ anArg
]

{ #category : 'inlining-arguments-helpers' }
SLMockInliningTestClass >> methodBAlwaysInlined [

	<inline: #always>
	2 + 2
]

{ #category : 'inlining-assignment-helpers' }
SLMockInliningTestClass >> methodBAssignOnReturn [

	^ 2 + 2
]

{ #category : 'inlining-returning-conditional-helpers' }
SLMockInliningTestClass >> methodBIfFalseReturningIfTrue [

	self methodB
		ifFalse: [ true ]
		ifTrue: [ ^ false ].
	^ true
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBMultipleReturn [

	self methodB ifTrue: [ ^ 0 ].
	self methodCMultipleReturn.
	^ 2 + 2
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBMultipleReturnExpressionAndStatement [

	^ self methodB
		  ifTrue: [ 2 ]
		  ifFalse: [ self methodCMultipleReturn ]
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBMultipleReturnExpressionAndStatementInlined [

	^ self methodB
		  ifTrue: [ 2 ]
		  ifFalse: [ self methodBReturningInlinedIfTrueIfFalse ]
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBMultipleReturningIfWithReturnPartiallyPushedDown [

	^ self methodB
		  ifTrue: [ ^ [ 2 ] ]
		  ifFalse: [ 3 ]
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBMultipleReturningIfWithReturnPushedDown [

	self methodB
		ifTrue: [ ^ 2 ]
		ifFalse: [ ^ 3 ]
]

{ #category : 'inlining-assignment-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment [

	| var |
	var := 2 + 2
]

{ #category : 'inlining-assignment-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment: aBlock [

	| var |
	var := 2 + 2.
	^ aBlock value: var
]

{ #category : 'inlining-returning-conditional-helpers' }
SLMockInliningTestClass >> methodBReturningIfTrue [

	^ self methodB ifTrue: [ true ]
]

{ #category : 'inlining-returning-conditional-helpers' }
SLMockInliningTestClass >> methodBReturningIfTrueIfFalse [

	^ self methodB ifTrue: [ 1 ] ifFalse: [ 2 ]
]

{ #category : 'inlining-returning-arguments-helpers' }
SLMockInliningTestClass >> methodBReturningIfTrueIfFalseInSend [

	^ self methodB: (self methodB
			   ifTrue: [ 1 ]
			   ifFalse: [ 2 ])
]

{ #category : 'inlining-returning-conditional-helpers' }
SLMockInliningTestClass >> methodBReturningInlinedIfTrue [

	^ self methodB ifTrue: [ self methodB ]
]

{ #category : 'inlining-returning-conditional-helpers' }
SLMockInliningTestClass >> methodBReturningInlinedIfTrueIfFalse [

	^ self methodB ifTrue: [ self methodB ] ifFalse: [ self methodA ]
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodBSimpleReturn [

	self methodCSimpleReturn.
	^ 2 + 2
]

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodC [

	3 + 3.
	self methodA
]

{ #category : 'inlining-arguments-helpers' }
SLMockInliningTestClass >> methodCAlwaysInlined [

	<inline: #always>
	3 + 3.
	self methodA
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodCAssignOnReturn [

	| a |
	3 + 3.
	a := self methodAAssignOnReturn
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodCMultipleReturn [

	self methodC ifTrue: [ ^ 1 ].
	^ 3 + 3
]

{ #category : 'inlining-assignment' }
SLMockInliningTestClass >> methodCReturnOnAssignment [

	3 + 3.
	^ self methodAReturnOnAssignment
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodCSimpleReturn [

	^ 3 + 3
]

{ #category : 'inlining-variable' }
SLMockInliningTestClass >> methodInlineVariableWithSameName [
	| a |
	a := self methodWithVariableA.
]

{ #category : 'inlining-iterative' }
SLMockInliningTestClass >> methodWithAssignmentOnRepeatInlined [

	| a |
	a := self methodWithRepeat
]

{ #category : 'inlining-iterative' }
SLMockInliningTestClass >> methodWithAssignmentOnToByDoInlined [

	| a |
	a := self methodWithToByDo
]

{ #category : 'inlining-iterative' }
SLMockInliningTestClass >> methodWithAssignmentOnToDoInlined [

	| a |
	a := self methodWithToDo
]

{ #category : 'inlining-iterative' }
SLMockInliningTestClass >> methodWithAssignmentOnWhileTrueBinaryInlined [

	| a |
	a := self methodWithWhileTrueBinary
]

{ #category : 'inlining-iterative' }
SLMockInliningTestClass >> methodWithAssignmentOnWhileTrueInlined [

	| a |
	a := self methodWithWhileTrue
]

{ #category : 'collect-statements-for-inlining' }
SLMockInliningTestClass >> methodWithAvoidedSelectors [

	self cCode: [ self methodB ] inSmalltalk: [ self methodB ].
	self cCall: 'method'.
	self cCall: 'method' withArguments: {
			self methodB.
			2.
			3 }.
	self
		cppIf: [ self methodB ]
		ifTrue: [ self methodB ]
		ifFalse: [ self methodB ].
	[ self methodB ] and: [ false ].
	[ false ] or: [ self methodB ].
	[ self methodB ] ifTrue: [ self methodB ]
]

{ #category : 'inlining-block-helpers' }
SLMockInliningTestClass >> methodWithBlockArgument: aBlock [

	| a |
	a := aBlock value
]

{ #category : 'inlining-block' }
SLMockInliningTestClass >> methodWithBlockArgumentInlined [

	self methodWithBlockArgument: [ 2 ]
]

{ #category : 'inlining-block' }
SLMockInliningTestClass >> methodWithBlockWithReturningIfArgumentInlined [

	self methodWithBlockArgument: [
		self methodBReturningInlinedIfTrueIfFalse ]
]

{ #category : 'inlining-block' }
SLMockInliningTestClass >> methodWithBlockWithReturningIfWithGotoInlinedArgumentInlined [

	self methodWithBlockArgument: [ self methodBMultipleReturn ]
]

{ #category : 'inlining-block' }
SLMockInliningTestClass >> methodWithBlockWithReturningIfWithInlinedArgumentInlined [

	self methodWithBlockArgument: [
		self methodBMultipleReturnExpressionAndStatement ]
]

{ #category : 'inlining-conditional-receiver' }
SLMockInliningTestClass >> methodWithIfTrueReceiverInlined [

	self methodWithMultipleBooleanReturn ifTrue: [ self methodB ].
	^ 1
]

{ #category : 'inlining-conditional-receiver-helpers' }
SLMockInliningTestClass >> methodWithMultipleBooleanReturn [

	<inline: true>
	self methodB ifTrue: [ ^ false ].
	self methodCMultipleReturn.
	^ true
]

{ #category : 'inlining-perform-send' }
SLMockInliningTestClass >> methodWithPerformSend [

	^ self perform: #functionalMethod
]

{ #category : 'inlining-perform-send' }
SLMockInliningTestClass >> methodWithPerformSendAsReceiver [

	^ (self perform: #functionalMethod) + 2
]

{ #category : 'inlining-perform-send' }
SLMockInliningTestClass >> methodWithPerformSendAsReceiverNotInlined [

	^ (self perform: #methodB) + 2
]

{ #category : 'inlining-perform-send' }
SLMockInliningTestClass >> methodWithPerformSendNotInlined [

	^ self perform: #methodB
]

{ #category : 'inlining-iterative-helpers' }
SLMockInliningTestClass >> methodWithRepeat [

	[ self methodB ifTrue: [ ^ 5 ] ] repeat
]

{ #category : 'inlining-conditional-receiver' }
SLMockInliningTestClass >> methodWithReturningIfTrueReceiverInlined [

	self methodWithMultipleBooleanReturn ifTrue: [
		self methodB.
		^ 0 ].
	^ 1
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodWithReturningIfWithReturnPartiallyPushedDownInlined [

	self methodB:
		self methodBMultipleReturningIfWithReturnPartiallyPushedDown
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodWithReturningIfWithReturnPushedDownInlined [

	self methodB: self methodBMultipleReturningIfWithReturnPushedDown
]

{ #category : 'inlining-iterative-helpers' }
SLMockInliningTestClass >> methodWithToByDo [

	1 to: 4 by: 2 do: [:i | (self methodB: i)ifTrue: [ ^ self methodB ] ]
]

{ #category : 'inlining-iterative-helpers' }
SLMockInliningTestClass >> methodWithToDo [

	1 to: 2 do: [:i | (self methodB: i) ifTrue: [ ^ self methodB ] ]
]

{ #category : 'inlinng-variable-helpers' }
SLMockInliningTestClass >> methodWithVariableA [

	| a |
	a := 2.
	^ 3
]

{ #category : 'inlining-iterative-helpers' }
SLMockInliningTestClass >> methodWithWhileTrue [

	[
	self methodB ifTrue: [ ^ 5 ].
	true ] whileTrue
]

{ #category : 'inlining-iterative-helpers' }
SLMockInliningTestClass >> methodWithWhileTrueBinary [

	[ true ] whileTrue: [ self methodB ifTrue: [ ^ self methodB ] ]
]
