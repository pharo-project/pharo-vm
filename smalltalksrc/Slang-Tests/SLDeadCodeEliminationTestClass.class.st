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

{ #category : 'helpers' }
SLDeadCodeEliminationTestClass >> method: arg [
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodAddingCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method + self method to: #type
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithAddInCoerce [

	<returnTypeC: #void>
	self cCoerce: 4 + 8 to: #type
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method to: #type
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithConstantInAssignment [

	<returnTypeC: #void>
	| i |
	5.
	i := 5
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithConstantInReturn [
	5.
	^ 5 
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithEmptyCaseOfNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 4 ] -> [  ]).
			([ 6 ] -> [  ]) }
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithEmptyCaseOfOtherwiseNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 1 ] -> [  ]).
				([ 2 ] -> [  ]) }
		otherwise: [  ]
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithEmptyCaseOfOtherwiseSendInReceiver [

	<returnTypeC: #void>
	(self method: 2)
		caseOf: {
				([ 1 ] -> [  ]).
				([ 2 ] -> [  ]) }
		otherwise: [  ]
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithEmptyCaseOfSendInReceiver [

	<returnTypeC: #void>
	self method caseOf: {
			([ 4 ] -> [  ]).
			([ 6 ] -> [  ]) }
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	self method > 0 >= (self method: 1) < 5 <= self method = 5
	== (self method: self method)
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	self method > 0 >= (self method: 1) < 5 <= self method = 5
	== (self method: self method)
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInAssignment [

	<returnTypeC: #void>
	| i |
	instancesVariable.
	i := instancesVariable
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInReturn [

	instancesVariable.
	^ instancesVariable
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstant [

	<returnTypeC: #void>
	5
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [ ^ 2 ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [
			 4.
			 ^ 2 ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ nil ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [ 
			2.
			^ 5 ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [
			4.
			^ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [ 2 ]) }
			otherwise: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: { ([ 5 ] -> [ 1 ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: { ([ 5 ] -> [ 1 ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCoerce [

	<returnTypeC: #void>
	self cCoerce: 5 to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [ 5 ]
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ 5 ]
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ 5 ] ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNil: [ 5 ]
		ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ 5 ]
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ 5 ]
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [
				 5.
				 ^ 2 ]) }
		otherwise: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [
				 3.
				 ^ 2 ]) }
		otherwise: [ 5 ]
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariable [

	<returnTypeC: #void>
	instancesVariable
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [
			instancesVariable.
			^ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [
			instancesVariable.
			^ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: { ([ 5 ] -> [ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: { ([ 5 ] -> [ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCoerce [

	<returnTypeC: #void>
	self cCoerce: instancesVariable to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [ instancesVariable ]
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ instancesVariable ]
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ instancesVariable ] ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNil: [ instancesVariable ]
		ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ instancesVariable ] ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNotNil: [ instancesVariable ]
		ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ instancesVariable ]
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ instancesVariable ]
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [
				 instancesVariable.
				 ^ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [
				 instancesVariable.
				 ^ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariable [

	<returnTypeC: #void>
	| i |
	i
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [
			 i.
			 ^ i ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3) caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [ 
				i.
				^ i ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [
			i.
			^ i ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [
			i.
			^ i ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt caseOf: { ([ 5 ] -> [ i ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3) caseOf: { ([ 5 ] -> [ i ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCoerce [

	<returnTypeC: #void>
	| i |
	self cCoerce: i to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [ i ]
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ i ]
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfFalseSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i ] ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNil: [ i ]
		ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method) ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i ] ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNotNil: [ i ]
		ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [ i ]
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ i ]
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInIfTrueSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [
				 i.
				 ^ i ]) }
		otherwise: [ i ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [
				 i.
				 ^ i ]) }
		otherwise: [ i ]
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithVariableInAssignment [

	<returnTypeC: #void>
	| i j |
	i.
	j.
	i := j
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithVariableInReturn [

	| i |
	i.
	^ i
]
