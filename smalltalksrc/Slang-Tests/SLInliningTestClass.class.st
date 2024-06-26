Class {
	#name : #SLInliningTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

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
