Class {
	#name : 'SLMockInliningTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'simple-inlining' }
SLMockInliningTestClass >> methodA [

	1 + 1.
	self methodB
]

{ #category : 'simple-inlining' }
SLMockInliningTestClass >> methodAAssignOnReturn [

	1 + 1.
	^ self methodBAssignOnReturn
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodAMultipleReturn [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodAMultipleReturnAsAssignmentExpression [

	| x |
	x := self methodBMultipleReturn
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodAMultipleReturnAsReturnExpression [

	^ self methodBMultipleReturn
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodAMultipleReturnAsReturnExpressionAndStatement [

	^ self methodBMultipleReturnExpressionAndStatement
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodAMultipleReturnExpression [

	self methodBMultipleReturn.
	^ 1 + 1
]

{ #category : 'simple-inlining' }
SLMockInliningTestClass >> methodAReturnOnAssignment [

	| var |
	1 + 1.
	^ self methodBReturnOnAssignment: [ :x |
		var := x.
		 ]
]

{ #category : 'jump-inlining' }
SLMockInliningTestClass >> methodASimpleReturn [

	self methodBSimpleReturn.
	^ 1 + 1
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodB [

	2 + 2
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodBAssignOnReturn [

	^ 2 + 2
]

{ #category : 'jump-inlining-helpers' }
SLMockInliningTestClass >> methodBMultipleReturn [

	self methodB ifTrue: [ ^ 0 ].
	self methodCMultipleReturn.
	^ 2 + 2
]

{ #category : 'jump-inlining-helpers' }
SLMockInliningTestClass >> methodBMultipleReturnExpressionAndStatement [

	^ self methodB
		  ifTrue: [ 2 ]
		  ifFalse: [ self methodCMultipleReturn ]
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment [

	| var |
	var := 2 + 2
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodBReturnOnAssignment: aBlock [

	| var |
	var := 2 + 2.
	^ aBlock value: var
]

{ #category : 'jump-inlining-helpers' }
SLMockInliningTestClass >> methodBSimpleReturn [

	self methodCSimpleReturn.
	^ 2 + 2
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodC [
	3 + 3.
	self methodA 
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodCAssignOnReturn [
	| a |
	3 + 3.
	a := self methodAAssignOnReturn
]

{ #category : 'jump-inlining-helpers' }
SLMockInliningTestClass >> methodCMultipleReturn [

	self methodC ifTrue: [ ^ 1 ].
	^ 3 + 3
]

{ #category : 'simple-inlining-helpers' }
SLMockInliningTestClass >> methodCReturnOnAssignment [
	3 + 3.
	^ self methodAReturnOnAssignment
]

{ #category : 'jump-inlining-helpers' }
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
