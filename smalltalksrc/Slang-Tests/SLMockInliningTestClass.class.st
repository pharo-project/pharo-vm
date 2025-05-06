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
