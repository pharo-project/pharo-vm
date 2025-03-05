Class {
	#name : 'SLDeadCodeEliminationoldTestClass',
	#superclass : 'SlangStructType',
	#instVars : [
		'instancesVariable'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'translation' }
SLDeadCodeEliminationoldTestClass class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn
				 caseOf: { ([ 'instancesVariable' ] -> [ #size_t ]) }
				 otherwise: [ #sqInt ]) ]
]

{ #category : 'only-comment' }
SLDeadCodeEliminationoldTestClass >> conditionalWithOnlyCommentNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ self method ]
		ifFalse: [ self method ]
]

{ #category : 'only-comment' }
SLDeadCodeEliminationoldTestClass >> conditionalWithOnlyCommentSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifTrue: [ self method ]
		ifFalse: [ self method ]
]

{ #category : 'accessing' }
SLDeadCodeEliminationoldTestClass >> instancesVariable [
	^ instancesVariable
]

{ #category : 'helpers' }
SLDeadCodeEliminationoldTestClass >> method [

	<inline: true>
	
]

{ #category : 'helpers' }
SLDeadCodeEliminationoldTestClass >> method: arg [
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationoldTestClass >> methodAddingCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method + self method to: #type
]

{ #category : 'as yet unclassified' }
SLDeadCodeEliminationoldTestClass >> methodWithAddInCoerce [

	<returnTypeC: #void>
	self cCoerce: 4 + 8 to: #type
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	<returnTypeC: #void>
	| var |
	var := [ :arg |
	       self method: arg.
	       arg ] value: var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithBlockValueAssignmentNotIntoSameVariableInArguments [

	<returnTypeC: #void>
	| var var2 |
	var := [ :arg |
	       self method: arg.
	       arg ] value: var2
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	<returnTypeC: #void>
	| var var2 |
	var := [ :arg :arg2 |
	       self method: arg.
	       self method: arg2.
	       arg.
	       arg2 ] value: var2 value: var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithBlockValueValueAssignmentNotIntoSameVariableInArguments [

	<returnTypeC: #void>
	| var var2 |
	var := [ :arg :arg2 |
	       self method: arg.
	       self method: arg2.
	       arg2 ] value: var value: var2
]

{ #category : 'method-in-c-coerce' }
SLDeadCodeEliminationoldTestClass >> methodWithCallInCoerce [

	<returnTypeC: #void>
	self cCoerce: self method to: #type
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationoldTestClass >> methodWithConstantInAssignment [

	<returnTypeC: #void>
	| i |
	5.
	i := 5
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationoldTestClass >> methodWithConstantInReturn [
	5.
	^ 5 
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInRepeat [

	<returnTypeC: #void>
	| var |
	[
	var := var.
	self method ] repeat
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInTimesRepeat [
	| var |
	3 timesRepeat: [ :elm | 5. instancesVariable. var. self method: elm ]
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInToByDo [

	| var |
	1 to: 4 by: 2 do: [ :index |
		5.
		instancesVariable.
		var.
		self method: index ]
]

{ #category : 'dead-code-in-do-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInToDo [

	| var |
	1 to: 4 do: [ :index |
		5.
		instancesVariable.
		var.
		self method: index ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileFalseBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[ var = true ] whileFalse: [
		var := var.
		self method.
		false ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileFalseBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[ self method ] whileFalse: [
		var := var.
		self method.
		false ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileFalseLastExpressionIsLeaf [

	<returnTypeC: #void>
	| expr var |
	[
	var := var.
	self method.
	true ] whileFalse
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileTrueBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[var = false ] whileTrue: [
		var := var.
		self method.
		true ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileTrueBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[self method ] whileTrue: [
		var := var.
		self method.
		true ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithDeadCodeInWhileTrueLastExpressionIsLeaf [

	<returnTypeC: #void>
	| expr var |
	[
	var := var.
	self method.
	true ] whileTrue
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyCaseOfNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 4 ] -> [  ]).
			([ 6 ] -> [  ]) }
]

{ #category : 'empty-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyCaseOfOtherwiseNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 1 ] -> [  ]).
				([ 2 ] -> [  ]) }
		otherwise: [  ]
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyCaseOfOtherwiseSendInReceiver [

	<returnTypeC: #void>
	(self method: 2)
		caseOf: {
				([ 1 ] -> [  ]).
				([ 2 ] -> [  ]) }
		otherwise: [  ]
]

{ #category : 'empty-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyCaseOfSendInReceiver [

	<returnTypeC: #void>
	self method caseOf: {
			([ 4 ] -> [  ]).
			([ 6 ] -> [  ]) }
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	self method > 0 >= (self method: 1) < 5 <= self method = 5
	== (self method: self method)
		ifFalse: [  ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifFalse: [  ]
		ifTrue: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfFalseInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifTrue: [ i := 5 ]
		ifFalse: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	self method ifNotNil: [  ] ifNil: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	self method > 0 >= (self method: 1) < 5 <= self method = 5
	== (self method: self method)
		ifTrue: [  ]
		ifFalse: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueInIfFalseIfTrueAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifFalse: [ i := 5 ]
		ifTrue: [  ]
]

{ #category : 'reduce-boolean-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'reduce-boolean-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyIfTrueInIfTrueIfFalseAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0
		ifTrue: [  ]
		ifFalse: [ i := 5 ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyWhileFalseNoSendInCondition [

	<returnTypeC: #void>
	[ true ] whileFalse
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyWhileFalseSendInCondition [

	<returnTypeC: #void>
	[ self method ] whileFalse
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyWhileTrueNoSendInCondition [

	<returnTypeC: #void>
	[ true ] whileTrue
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyWhileTrueSendInCondition [

	<returnTypeC: #void>
	[ self method ] whileTrue
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [  ] ifNotNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [ i := 5 ] ifNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNotNilInIfNilIfNotNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNil: [ i := 5 ] ifNotNil: [  ]
]

{ #category : 'reduce-nil-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'reduce-nil-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithEmptyifNotNilInIfNotNilIfNilAndSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method ifNotNil: [  ] ifNil: [ i := 5 ]
]

{ #category : 'used-leaf-in-assignment' }
SLDeadCodeEliminationoldTestClass >> methodWithInstanceVariableInAssignment [

	<returnTypeC: #void>
	| i |
	instancesVariable.
	i := instancesVariable
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationoldTestClass >> methodWithInstanceVariableInReturn [

	instancesVariable.
	^ instancesVariable
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	<returnTypeC: #void>
	| var |
	var := [ :arg | arg ] value: var
]

{ #category : 'variable-not-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyBlockValueAssignmentNotIntoSameVariableInArguments [

	<returnTypeC: #void>
	| var var2 |
	var := [ :arg | arg ] value: var2
]

{ #category : 'only-comment' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyComment [

	<returnTypeC: #void>
	self method
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInRepeat [

	<returnTypeC: #void>
	| var |
	[ var := var ] repeat
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileFalse [

	<returnTypeC: #void>
	| var |
	[
	var := var.
	true ] whileFalse
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileFalseBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[ var = false ] whileFalse: [
		var := var.
		false ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileFalseBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[ self method ] whileFalse: [
		var := var.
		false ]
]

{ #category : 'dead-code-in-unary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileTrue [

	<returnTypeC: #void>
	| var |
	[
	var := var.
	true ] whileTrue
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileTrueBinaryNoSendInReceiver [

	<returnTypeC: #void>
	| var |
	[ var = true ] whileTrue: [
		var := var.
		3 ]
]

{ #category : 'dead-code-in-binary-iterative' }
SLDeadCodeEliminationoldTestClass >> methodWithOnlyDeadCodeInWhileTrueBinarySendInReceiver [

	<returnTypeC: #void>
	| var |
	[ self method ] whileTrue: [
		var := var.
		3 ]
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationoldTestClass >> methodWithSelfAssign [

	<returnTypeC: #void>
	| var |
	var := var.
	^ var
]

{ #category : 'unused-leaf' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstant [

	<returnTypeC: #void>
	5
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [ ^ 2 ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [
			 4.
			 ^ 2 ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfAndReturnInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ 1 ]).
			([ 6 ] -> [ 2 ]) }
			otherwise: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ 1 ]).
				([ 6 ] -> [ 2 ]) }
		otherwise: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: { ([ 5 ] -> [ 1 ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: { ([ 5 ] -> [ 1 ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInCoerce [

	<returnTypeC: #void>
	self cCoerce: 5 to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [ 5 ]
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ 5 ]
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ 5 ] ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNil: [ 5 ]
		ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ] ifNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ 5 ]
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ 5 ]
		ifFalse: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantInIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ 5 ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedConstantReturnInCaseOfAndUnusedConstantInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariable [

	<returnTypeC: #void>
	instancesVariable
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: {
			([ 5 ] -> [ instancesVariable ]).
			([ 6 ] -> [
			 instancesVariable.
			 ^ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfAndReturnInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ instancesVariable ]).
				([ 6 ] -> [ instancesVariable ]) }
		otherwise: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	anInt caseOf: { ([ 5 ] -> [ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCaseOfSendInExpression [

	<returnTypeC: #void>
	(self method: 3) caseOf: { ([ 5 ] -> [ instancesVariable ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInCoerce [

	<returnTypeC: #void>
	self cCoerce: instancesVariable to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifFalse: [ instancesVariable ]
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ instancesVariable ]
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ instancesVariable ] ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNil: [ instancesVariable ]
		ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ instancesVariable ] ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		ifNotNil: [ instancesVariable ]
		ifNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	nil ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	(self method: self method) ifNotNil: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	true
		ifTrue: [ instancesVariable ]
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ instancesVariable ]
		ifFalse: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	true ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableInIfTrueSendInReceiver [

	<returnTypeC: #void>
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ instancesVariable ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedInstanceVariableReturnInCaseOfAndUnusedInstanceVariableInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariable [

	<returnTypeC: #void>
	| i |
	i
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableAndReturnInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [
			 i.
			 ^ i ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableAndReturnInCaseOfSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3) caseOf: {
			([ 5 ] -> [ i ]).
			([ 6 ] -> [ 
				i.
				^ i ]) }
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfAndReturnInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3)
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt caseOf: { ([ 5 ] -> [ i ]) }
]

{ #category : 'unused-leaf-in-switch-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCaseOfSendInExpression [

	<returnTypeC: #void>
	| i |
	(self method: 3) caseOf: { ([ 5 ] -> [ i ]) }
]

{ #category : 'unused-leaf-in-c-coerce' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInCoerce [

	<returnTypeC: #void>
	| i |
	self cCoerce: i to: #type
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfFalseIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifFalse: [ i ]
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfFalseIfTrueSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ i ]
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfFalseSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNilIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i ] ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNilIfNotNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNil: [ i ]
		ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method) ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNotNilIfNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i ] ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNotNilIfNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNotNil: [ i ]
		ifNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNotNilNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	nil ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfNotNilSendInReceiver [

	<returnTypeC: #void>
	| i |
	(self method: self method)
		ifNotNil: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfTrueIfFalseNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true
		ifTrue: [ i ]
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfTrueIfFalseSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ i ]
		ifFalse: [ i ]
]

{ #category : 'unused-leaf-in-conditional-no-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfTrueNoSendInReceiver [

	<returnTypeC: #void>
	| i |
	true ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-conditional-send-in-receiver' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableInIfTrueSendInReceiver [

	<returnTypeC: #void>
	| i |
	self method > 0 <= (self method: 3) = (self method: self method)
		ifTrue: [ i ]
]

{ #category : 'unused-leaf-in-switch-no-send-in-expression' }
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

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
SLDeadCodeEliminationoldTestClass >> methodWithUnusedVariableReturnInCaseOfAndUnusedVariableInOtherwiseSendInExpression [

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
SLDeadCodeEliminationoldTestClass >> methodWithVariableInAssignment [

	<returnTypeC: #void>
	| i j |
	i.
	j.
	i := j
]

{ #category : 'used-leaf-in-return' }
SLDeadCodeEliminationoldTestClass >> methodWithVariableInReturn [

	| i |
	i.
	^ i
]

{ #category : 'only-comment' }
SLDeadCodeEliminationoldTestClass >> switchWithOnlyCommentNoSendInReceiver: anInt [

	<returnTypeC: #void>
	anInt
		caseOf: {
				([ 5 ] -> [ self method ]).
				([ 6 ] -> [ self method ]) }
		otherwise: [ self method ]
]

{ #category : 'only-comment' }
SLDeadCodeEliminationoldTestClass >> switchWithOnlyCommentSendInReceiver [

	<returnTypeC: #void>
	(self method: self method)
		caseOf: {
				([ 5 ] -> [ self method ]).
				([ 6 ] -> [ self method ]) }
		otherwise: [ self method ]
]
