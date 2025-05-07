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
SLMockInliningTestClass >> methodB [

	2 + 2
]

{ #category : 'statements' }
SLMockInliningTestClass >> methodC [
	3 + 3.
	self methodA 
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
