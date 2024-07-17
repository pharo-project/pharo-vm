Class {
	#name : 'SLDeadCodeEliminationTestClass',
	#superclass : 'SlangStructType',
	#instVars : [
		'instancesVariable'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstant [

	| i |
	i = 5 ifTrue: [ ^ self methodReturnConstant ].
	^ 0
]

{ #category : 'unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstantInIfWithoutReturn [

	| i |
	i = 5 ifTrue: [ self methodReturnConstantInIf ].
	^ 0
]

{ #category : 'unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstantWithoutReturn [

	| i |
	i = 5 ifTrue: [ self methodReturnConstant ].
	^ 0
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTestClass >> methodCallInReturnMethodWithAssignmentAndReturnConstant [

	<returnTypeC: #sqInt>
	^ self methodWithAssignmentAndReturnConstant
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTestClass >> methodCallInReturnMethodWithAssignmentAndReturnConstantInIf [

	^ self methodWithAssignmentAndReturnConstantInIf
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTestClass >> methodCallInReturnMethodWithReturnConstant [
	^ self methodReturnConstant 
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTestClass >> methodCallInReturnMethodWithReturnConstantInIf [
	<returnTypeC: #sqInt>
	^ self methodReturnConstantInIf 
]

{ #category : 'inline-in-return' }
SLDeadCodeEliminationTestClass >> methodCallInReturnMethodWithReturnConstantInIfElse [
	<returnTypeC: #sqInt>
	^ self methodReturnConstantInIfElse
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithAssignmentAndReturnConstant [

	self methodWithAssignmentAndReturnConstant
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithAssignmentAndReturnConstantInIf [

	self methodWithAssignmentAndReturnConstantInIf
]

{ #category : 'unused-variable' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithExpression [

	self methodWithExpression
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithReturnConstant [

	self methodReturnConstant
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithReturnConstantInIf [

	self methodReturnConstantInIf
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodReturnConstant [

	^ 5
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodReturnConstantInIf [

	<returnTypeC: #sqInt>
	true ifTrue: [ ^ -1 ]
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodReturnConstantInIfElse [

	true
		ifTrue: [ ^ -1 ]
		ifFalse: [ ^ 5 ]
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodWithAssignmentAndReturnConstant [

	| i |
	i := 5.
	^ 5
]

{ #category : 'unused-constant' }
SLDeadCodeEliminationTestClass >> methodWithAssignmentAndReturnConstantInIf [

	| i |
	true ifTrue: [
		i := 5.
		^ -1 ]
]

{ #category : 'unused-variable' }
SLDeadCodeEliminationTestClass >> methodWithExpression [

	| i |
	i = 1 ifTrue: [ ^ 1 ].
	i = 2 ifTrue: [ ^ i ].
	i = 3 ifTrue: [ ^ instancesVariable ]
]
