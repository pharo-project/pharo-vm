Class {
	#name : 'SLDeadCodeEliminationTestClass',
	#superclass : 'SlangStructType',
	#instVars : [
		'instancesVariable'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'translation' }
SLDeadCodeEliminationTestClass class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn
				 caseOf: { ([ 'instancesVariable' ] -> [ #size_t ]) }
				 otherwise: [ #sqInt ]) ]
]

{ #category : 'accessing' }
SLDeadCodeEliminationTestClass >> instancesVariable [
	^ instancesVariable
]

{ #category : 'helpers' }
SLDeadCodeEliminationTestClass >> method [
]

{ #category : 'inline-unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstant [

	| i |
	i = 5 ifTrue: [ self methodWithConstantInReturn ].
	^ 0
]

{ #category : 'inline-unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstantInIfWithoutReturn [

	| i |
	i = 5 ifTrue: [ self methodReturnConstantInIf ].
	^ 0
]

{ #category : 'inline-unused-in-conditional' }
SLDeadCodeEliminationTestClass >> methodCallInIfMethodWithReturnConstantWithoutReturn [

	| i |
	i = 5 ifTrue: [ self methodWithConstantInReturn ].
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
	^ self methodWithConstantInReturn 
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

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithAssignmentAndReturnConstant [

	self methodWithAssignmentAndReturnConstant
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithAssignmentAndReturnConstantInIf [

	self methodWithAssignmentAndReturnConstantInIf
]

{ #category : 'inline-unused-variable' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithExpression [

	self methodWithExpression
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithReturnConstant [

	self methodWithConstantInReturn
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodCallMethodWithReturnConstantInIf [

	self methodReturnConstantInIf
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodReturnConstantInIf [

	<returnTypeC: #sqInt>
	true ifTrue: [ ^ -1 ]
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodReturnConstantInIfElse [

	true
		ifTrue: [ ^ -1 ]
		ifFalse: [ ^ 5 ]
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodWithAssignmentAndReturnConstant [

	| i |
	i := 5.
	^ 5
]

{ #category : 'inline-unused-constant' }
SLDeadCodeEliminationTestClass >> methodWithAssignmentAndReturnConstantInIf [

	| i |
	true ifTrue: [
		i := 5.
		^ -1 ]
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithConstantInAssignment [

	<returnTypeC: #void>
	| i |
	i := 5
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithConstantInReturn [

	^ 5 
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	self method
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	self method
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'empty-branch-in-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'empty-branch-in-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'empty-branch-in-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'empty-branch-in-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'inline-unused-variable' }
SLDeadCodeEliminationTestClass >> methodWithExpression [

	| i |
	i = 1 ifTrue: [ ^ 1 ].
	i = 2 ifTrue: [ ^ i ].
	i = 3 ifTrue: [ ^ instancesVariable ]
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInAssignment [

	<returnTypeC: #void>
	| i |
	i := instancesVariable
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInReturn [

	^ instancesVariable
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstant [

	<returnTypeC: #void>
	5
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariable [

	<returnTypeC: #void>
	instancesVariable
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariable [

	<returnTypeC: #void>
	| i |
	i
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithVariableInAssignment [

	<returnTypeC: #void>
	| i j |
	i := j
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithVariableInReturn [
	| i |
	^ i
]
