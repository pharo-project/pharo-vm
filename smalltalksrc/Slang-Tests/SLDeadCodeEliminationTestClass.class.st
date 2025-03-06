Class {
	#name : 'SLDeadCodeEliminationTestClass',
	#superclass : 'SlangStructType',
	#instVars : [
		'instancesVariable',
		'instancesVariable2'
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

{ #category : 'only-comment' }
SLDeadCodeEliminationTestClass >> conditionalWithOnlyCommentNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ self method ]
		ifFalse: [ self method ]
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTestClass >> conditionalWithOnlyCommentSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifTrue: [ self method ]
		ifFalse: [ self method ]
]

{ #category : 'accessing' }
SLDeadCodeEliminationTestClass >> instancesVariable [
	^ instancesVariable
]

{ #category : 'helpers' }
SLDeadCodeEliminationTestClass >> method [

	<inline: true>
	
]

{ #category : 'helpers' }
SLDeadCodeEliminationTestClass >> method: arg [

	<inline: false>
	
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodAddingCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method + self method to: #type
]

{ #category : 'helpers' }
SLDeadCodeEliminationTestClass >> methodReturnValueFromBlock [

	^ [ :arg1 | arg1 ] value: 10 + 10
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var |
	var := [ :arg |
	       self method: arg.
	       arg ] value: var.
	^ var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithBlockValueAssignmentNotIntoSameVariableInArguments [

	| var var2 |
	var := [ :arg |
	       self method: arg.
	       arg ] value: var2.
	^ var
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var var2 |
	var := [ :arg :arg2 |
	       self method: arg.
	       self method: arg2.
	       arg.
	       arg2 ] value: var2 value: var.
	^ var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments [

	<returnTypeC: #void>
	| var var2 |
	var := [ :arg :arg2 |
	       self method: arg.
	       self method: arg2.
	       arg2 ] value: var value: var2
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method to: #type
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithConstantInAssignment [

	| i |
	5.
	i := 5.
	^ i
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithConstantInReturn [
	5.
	^ 5 
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInRepeat [

	<returnTypeC: #void>
	| var |
	[
	var := var.
	self method ] repeat
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInTimesRepeat [
	| var |
	3 timesRepeat: [ :elm | 5. instancesVariable. var. self method: elm ]
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInToByDo [

	| var |
	1 to: 4 by: 2 do: [ :index |
		5.
		instancesVariable.
		var.
		self method: index ]
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInToDo [

	| var |
	1 to: 4 do: [ :index |
		5.
		instancesVariable.
		var.
		self method: index ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[ var = true ] whileFalse: [
		var := var.
		self method.
		false ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileFalseBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[ self method ] whileFalse: [
		var := var.
		self method.
		false ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileFalseLastExpressionIsLeaf [

	<returnTypeC: #void>
	| expr var |
	[
	var := var.
	self method.
	true ] whileFalse
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[var = false ] whileTrue: [
		var := var.
		self method.
		true ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileTrueBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[self method ] whileTrue: [
		var := var.
		self method.
		true ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithDeadCodeInWhileTrueLastExpressionIsLeaf [

	<returnTypeC: #void>
	| expr var |
	[
	var := var.
	self method.
	true ] whileTrue
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

	| i |
	i = 0
		ifFalse: [  ]
		ifTrue: [ i := 5 ].
	^ i
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [

	| i |
	self method > 0
		ifFalse: [  ]
		ifTrue: [ i := 5 ].
	^ i
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [

	| i |
	i = 0
		ifTrue: [ i := 5 ]
		ifFalse: [  ].
	^ i
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [

	| i |
	self method > 0
		ifTrue: [ i := 5 ]
		ifFalse: [  ].
	^ i
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

	| i |
	i = 0
		ifFalse: [ i := 5 ]
		ifTrue: [  ].
	^ i
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [

	| i |
	self method > 0
		ifFalse: [ i := 5 ]
		ifTrue: [  ].
	^ i
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [

	| i |
	i = 0
		ifTrue: [  ]
		ifFalse: [ i := 5 ].
	^ i
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [

	| i |
	self method > 0
		ifTrue: [  ]
		ifFalse: [ i := 5 ].
	^ i
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithEmptyWhileFalseNoSendInCondition [

	<returnTypeC: #void>
	[ true ] whileFalse
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithEmptyWhileFalseSendInCondition [

	<returnTypeC: #void>
	[ self method ] whileFalse
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithEmptyWhileTrueNoSendInCondition [

	<returnTypeC: #void>
	[ true ] whileTrue
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithEmptyWhileTrueSendInCondition [

	<returnTypeC: #void>
	[ self method ] whileTrue
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [

	| i |
	i ifNil: [  ] ifNotNil: [ i := 5 ].
	^ i
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [

	| i |
	self method ifNil: [  ] ifNotNil: [ i := 5 ].
	^ i
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [

	| i |
	i ifNotNil: [ i := 5 ] ifNil: [  ].
	^ i
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [

	| i |
	self method ifNotNil: [ i := 5 ] ifNil: [  ].
	^ i
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [

	| i |
	i ifNil: [ i := 5 ] ifNotNil: [  ].
	^ i
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [

	| i |
	self method ifNil: [ i := 5 ] ifNotNil: [  ].
	^ i
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [

	| i |
	i ifNotNil: [  ] ifNil: [ i := 5 ].
	^ i
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [

	| i |
	self method ifNotNil: [  ] ifNil: [ i := 5 ].
	^ i
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInAssignment [

	| i |
	instancesVariable.
	i := instancesVariable.
	^ i
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithInstanceVariableInReturn [

	instancesVariable.
	^ instancesVariable
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithNeverUsedLocals [

	| var1 var2 var3 var4 var5 var6 |
	var1.
	var2 := var1.
	var3 := var4.
	var4 := 5.
	var5 := 6.
	var6 := var5.
	^ var6
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithNeverUsedLocalsFromBlock [

	| var1 |
	var1 := 5.
	var1 := [ :arg1 | arg1 + 1 ] value: var1.
	^ var1
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithNeverUsedLocalsFromBlockStatement [

	| var1 var2 |
	var1 := 4.
	[ :arg1 | var2 := arg1 + 1 ] value: var1.
	^ var2
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithNeverUsedLocalsFromBlockWithExpressionInArguments [

	| var1 |
	var1 := [ :arg1 | arg1 + 1 ] value: 5 + 1.
	^ var1
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithNeverUsedLocalsFromBlockasArguments [

	self method: self methodReturnValueFromBlock
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var |
	var := [ :arg | arg ] value: var.
	^ var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments [

	| var var2 |
	var := [ :arg | arg ] value: var2.
	^ var
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTestClass >> methodWithOnlyComment [

	<returnTypeC: #void>
	self method
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInRepeat [

	| var |
	[ var := var ] repeat.
	^ var
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileFalse [

	| var |
	[
	var := var.
	true ] whileFalse.
	^ var
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver [

	| var |
	[ var = false ] whileFalse: [
		var := var.
		false ].
	^ var
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver [

	| var |
	[ self method ] whileFalse: [
		var := var.
		false ].
	^ var
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileTrue [

	| var |
	[
	var := var.
	true ] whileTrue.
	^ var
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver [

	| var |
	[ var = true ] whileTrue: [
		var := var.
		3 ].
	^ var
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationTestClass >> methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver [

	| var |
	[ self method ] whileTrue: [
		var := var.
		3 ].
	^ var
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithOnlyNeverUsedLocals [

	| var1 var2 var3 var4 |
	var1.
	var2 := var1.
	var3 := var4.
	var4 := 5
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationTestClass >> methodWithOnlyUselessAssignment [

	<returnTypeC: #void>
	| i j |
	i := 5.
	j := i
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationTestClass >> methodWithSelfAssign [

	| var |
	var := var.
	^ var
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithSendWithNoSideEffectInCoerce [

	<returnTypeC: #void>
	self cCoerce: 4 + 8 to: #type
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

	(self method: 3) caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [
			 4.
			 ^ 2 ]) }.
	^ 0
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	anInt
		caseOf: {
				([ 5 ] -> [ nil ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [
			2.
			^ 5 ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression [

	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [
			4.
			^ 5 ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

	anInt
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [ 5 ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [ 5 ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfNoSendInExpression: anInt [

	anInt caseOf: { ([ 5 ] -> [ 1 ]) }.
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCaseOfSendInExpression [

	(self method: 3) caseOf: { ([ 5 ] -> [ 1 ]) }.
	^ 0
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInCoerce [

	self cCoerce: 5 to: #type.
	^ 0
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver [

	0 = 1
		ifFalse: [ 5 ]
		ifTrue: [ 5 ].
	^ 0
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
	0 = 1 ifFalse: [ 5 ]
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
	| i |
	i ifNil: [ 5 ] ifNotNil: [ 5 ]
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
	| i |
	i ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	i ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	i ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	0 = 1
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
	0 = 1 ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantInIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

	anInt
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [
				 5.
				 ^ 2 ]) }
		otherwise: [ 5 ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [
				 3.
				 ^ 2 ]) }
		otherwise: [ 5 ].
	^ 0
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariable [

	<returnTypeC: #void>
	instancesVariable
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression: anInt [

	anInt caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }.
	^ instancesVariable
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression [

	(self method: 3) caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }.
	^ instancesVariable
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [
			instancesVariable.
			^ instancesVariable ].
	^ instancesVariable
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression [

	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [
			instancesVariable.
			^ instancesVariable ].
	^ instancesVariable
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: anInt [

	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [

	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ].
	^ 0
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
	0 = 1
		ifFalse: [ instancesVariable ]
		ifTrue: [ instancesVariable2 ]
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
	0 = 1 ifFalse: [ instancesVariable ]
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
	| i |
	i ifNil: [ instancesVariable ] ifNotNil: [ instancesVariable ]
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
	| i |
	i ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	i ifNotNil: [ instancesVariable ] ifNil: [ instancesVariable ]
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
	| i |
	i ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationTestClass >> methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	0 = 1
		ifTrue: [ instancesVariable2 ]
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
	0 = 1 ifTrue: [ instancesVariable ]
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

	| i |
	i := 5.
	anInt caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [
			 i.
			 ^ i ]) }.
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableAndReturnInCaseOfSendInExpression [

	| i |
	i := 5.
	(self method: 3) caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [
			 i.
			 ^ i ]) }.
	^ 0
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

	| i |
	i := 5.
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [
			i.
			^ i ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression [

	| i |
	i := 5.
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [
			i.
			^ i ].
	^ 0
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
	0 = 1 ifFalse: [ i ]
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
	i ifNil: [ i ] ifNotNil: [ i ]
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
	i ifNil: [ i ]
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
	i ifNotNil: [ i ]
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
	| i j |
	0 = 1
		ifTrue: [ i ]
		ifFalse: [ j ]
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
	0 = 1 ifTrue: [ i ]
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

	| i |
	i = 5.
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [
				 i.
				 ^ i ]) }
		otherwise: [ i ].
	^ 0
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationTestClass >> methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

	| i |
	i := 5.
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [
				 i.
				 ^ i ]) }
		otherwise: [ i ].
	^ 0
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationTestClass >> methodWithUselessAssignment [

	| i j k l |
	k := 6.
	l := k + 1.
	i := 5.
	j := i.
	^ j
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTestClass >> methodWithUselessCodeInBinaryIterativeNoSendInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: 5 do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTestClass >> methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: 5 + 5 do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationTestClass >> methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: self method do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTestClass >> methodWithUselessLocalsDefinitionsWithSameNameInSubBranches [

	| var1 var2 |
	var1 := 0.
	var2 := 1.
	var1 = 1 ifFalse: [
		| subVar1 subVar2 |
		subVar1 := 5.
		var1 := self method: subVar1 ].
	var1 = 1 ifFalse: [
		| subVar2 |
		subVar2 := 5 + 5.
		var1 := self method: subVar2 ].
	^ var1
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTestClass >> methodWithUselessLocalsInSubBranches [

	| var1 var2 |
	var1 := 0.
	var2 := 1.
	var1 = 1 ifFalse: [
		| subVar1 subVar2 |
		subVar2 := 5 + 5.
		subVar1 := 5.
		var1 := self method: subVar1 ].
	^ var1
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationTestClass >> methodWithUselessLocalsWithSameNameInSubBranches [

	| var1 var2 |
	var1 := 0.
	var2 := 1.
	var1 = 1 ifFalse: [
		| subVar1 subVar2 |
		subVar2 := 5 + 5.
		subVar1 := 5.
		var1 := self method: subVar1 ].
	var1 = 1 ifFalse: [
		| subVar2 |
		subVar2 := 5 + 5.
		var1 := self method: subVar2 ].
	^ var1
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationTestClass >> methodWithVariableInAssignment [

	| i j |
	i.
	j.
	i := j.
	^ i
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationTestClass >> methodWithVariableInReturn [

	| i |
	i.
	i := 0.
	^ i
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTestClass >> switchWithOnlyCommentNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ self method ]).
				([ 6 ] -> [ self method ]) }
		otherwise: [ self method ]
]

{ #category : 'only-comment' }
SLDeadCodeEliminationTestClass >> switchWithOnlyCommentSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		caseOf: {
				([ 5 ] -> [ self method ]).
				([ 6 ] -> [ self method ]) }
		otherwise: [ self method ]
]
