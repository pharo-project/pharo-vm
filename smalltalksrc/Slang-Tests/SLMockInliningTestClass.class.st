Class {
	#name : 'SLMockInliningTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'statements' }
SLMockInliningTestClass >> methodA [

	1 + 1.
	self methodB
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodAAssignOnReturn [

	1 + 1.
	self methodBAssignOnReturn
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodAReturnOnAssignment [

	| var |
	1 + 1.
	^ self methodBReturnOnAssignment: [ :x |
		var := x.
		 ]
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodB [

	2 + 2
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodBAssignOnReturn [

	^ 2 + 2
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodBReturnOnAssignment [

	| var |
	var := 2 + 2
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodBReturnOnAssignment: aBlock [

	| var |
	var := 2 + 2.
	^ aBlock value: var
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodC [
	3 + 3.
	self methodA 
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodCAssignOnReturn [
	| a |
	3 + 3.
	a := self methodAAssignOnReturn
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodCReturnOnAssignment [
	3 + 3.
	^ self methodAReturnOnAssignment
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
