Class {
	#name : #SLInliningTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithAssignmentReturnConstant [
	self methodWithAssignmentReturnConstant.
	^ 0
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithAssignmentReturnConstantInIf [
	self methodWithAssignmentReturnConstantInIf.

]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithUnusedVariableReturnConstant [
	self methodReturnConstant.
	^ 0
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithUnusedVariableReturnConstantInIf [
	self methodReturnConstantInIf.

]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithUnusedVariableReturnConstantInIfElse [
	self methodReturnConstantInIfElse.

]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodCalledMethodWithUnusedVariableReturnConstantInIfElseNeedToBeTransformed [
	self methodReturnConstantInIfElseNeedToBeTransformed

]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodReturnConstant [
	^ 5
	
	
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodReturnConstantInIf [
	true 
	ifTrue: [ 
		^ -1
		 ].

	
	
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodReturnConstantInIfElse [

	true
		ifTrue: [ ^ -1 ]
		ifFalse: [ ^ 5 ]
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodReturnConstantInIfElseNeedToBeTransformed [
	| i |
	true
		ifTrue: [ ^ -1 ]
		ifFalse: [ i := 5 .
			^ 5
			]
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodWithAssignmentReturnConstant [
	| i |
	i := 5.
	^ 5
	
	
]

{ #category : #'unused-variables' }
SLInliningTestClass >> methodWithAssignmentReturnConstantInIf [
	| i | 
	true 
	ifTrue: [ 
		i := 5.
		^ -1
		 ].

	
	
]
