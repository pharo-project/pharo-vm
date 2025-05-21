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

{ #category : 'inlining-simple' }
SLMockInliningTestClass >> methodA [

	1 + 1.
	self methodB
]

{ #category : 'inlining-simple' }
SLMockInliningTestClass >> methodAAssignOnReturn [

	1 + 1.
	^ self methodBAssignOnReturn
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturn [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'inlining-jump' }
SLMockInliningTestClass >> methodAMultipleReturnAlwaysInlined [

	<inline: #always>
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

{ #category : 'inlining-simple' }
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
SLMockInliningTestClass >> methodAWithReturningSendReturningArgumentsInlined [

	^ self methodB: self methodAMultipleReturnAlwaysInlined
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

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodBAssignOnReturn [

	^ 2 + 2
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

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment [

	| var |
	var := 2 + 2
]

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment: aBlock [

	| var |
	var := 2 + 2.
	^ aBlock value: var
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

{ #category : 'inlining-simple-helpers' }
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

{ #category : 'inlining-simple-helpers' }
SLMockInliningTestClass >> methodCReturnOnAssignment [
	3 + 3.
	^ self methodAReturnOnAssignment
]

{ #category : 'inlining-jump-helpers' }
SLMockInliningTestClass >> methodCSimpleReturn [

	^ 3 + 3
]

{ #category : 'collect-statements-for-inlining' }
SLMockInliningTestClass >> methodWithAvoidedSelectors [

	self cCode: [  ] inSmalltalk: [  ].
	self cCall: 'method'.
	self cCall: 'method' withArguments: { 1. 2. 3 }.
	self cppIf: ['cppCond'. true] ifTrue: [ 'in cppIfTrue'. false ] ifFalse: [ 'in cppIfFalse'. true ].
	[ 'and receiver'. true ] and: [ 'and argument'. false ].
	[ 'or receiver' . false ] or: [ 'or argument'. true ].
	[ 'ifTrue receiver'. false ] ifTrue: ['ifTrue argument' . true ]
]
