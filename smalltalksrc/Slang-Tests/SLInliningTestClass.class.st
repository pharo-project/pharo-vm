Class {
	#name : 'SLInliningTestClass',
	#superclass : 'SlangStructType',
	#instVars : [
		'instancesVariable'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'unused-in-conditional' }
SLInliningTestClass >> methodCallInIfMethodWithReturnConstant [
	| i |
	i = 5
	ifTrue: [
	 ^ self methodReturnConstant ].
	^ 0

]

{ #category : 'unused-in-conditional' }
SLInliningTestClass >> methodCallInIfMethodWithReturnConstantInIfWithoutReturn [
	| i |
	i = 5
	ifTrue: [
	 self methodReturnConstantInIf ].
	^ 0

]

{ #category : 'unused-in-conditional' }
SLInliningTestClass >> methodCallInIfMethodWithReturnConstantWithoutReturn [
	| i |
	i = 5
	ifTrue: [
	 self methodReturnConstant ].
	^ 0

]

{ #category : 'inline-in-return' }
SLInliningTestClass >> methodCallInReturnMethodWithAssignmentAndReturnConstant [
	<returnTypeC: #sqInt>
	^ self methodWithAssignmentAndReturnConstant
]

{ #category : 'inline-in-return' }
SLInliningTestClass >> methodCallInReturnMethodWithAssignmentAndReturnConstantInIf [
	^ self methodWithAssignmentAndReturnConstantInIf
]

{ #category : 'inline-in-return' }
SLInliningTestClass >> methodCallInReturnMethodWithReturnConstant [
	^ self methodReturnConstant 
]

{ #category : 'inline-in-return' }
SLInliningTestClass >> methodCallInReturnMethodWithReturnConstantInIf [
	<returnTypeC: #sqInt>
	^ self methodReturnConstantInIf 
]

{ #category : 'inline-in-return' }
SLInliningTestClass >> methodCallInReturnMethodWithReturnConstantInIfElse [
	<returnTypeC: #sqInt>
	^ self methodReturnConstantInIfElse
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodCallMethodWithAssignmentAndReturnConstant [
	self methodWithAssignmentAndReturnConstant.
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodCallMethodWithAssignmentAndReturnConstantInIf [
	self methodWithAssignmentAndReturnConstantInIf.

]

{ #category : 'unused-variable' }
SLInliningTestClass >> methodCallMethodWithExpression [
	self methodWithExpression

]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodCallMethodWithReturnConstant [
	self methodReturnConstant.
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodCallMethodWithReturnConstantInIf [
	self methodReturnConstantInIf.

]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodReturnConstant [
	^ 5
	
	
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodReturnConstantInIf [
	<returnTypeC: #sqInt>
	true 
	ifTrue: [ 
		^ -1
		 ].

	
	
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodReturnConstantInIfElse [

	true
		ifTrue: [ ^ -1 ]
		ifFalse: [ ^ 5 ]
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodWithAssignmentAndReturnConstant [
	| i |
	i := 5.
	^ 5
	
	
]

{ #category : 'unused-constant' }
SLInliningTestClass >> methodWithAssignmentAndReturnConstantInIf [
	| i | 
	true 
	ifTrue: [ 
		i := 5.
		^ -1
		 ].

	
	
]

{ #category : 'unused-variable' }
SLInliningTestClass >> methodWithExpression [ 
	| i |
	i = 1 ifTrue: [ ^ 1 ].
	i = 2 ifTrue: [ ^ i ].
	i = 3 ifTrue: [ ^ instancesVariable ]
	
]
