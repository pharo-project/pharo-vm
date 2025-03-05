Class {
	#name : 'SLDeadCodeEliminationAlgoTestClass',
	#superclass : 'SlangStructType',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> isValidObjStackPage: objStackPage myIndex: myx [
	"Just check the page itself."

	<inline: false>
	| objStackInvalidBecause invalidObjStackPage ObjStackPageSlots ObjStackMyx marking |
	(self classIndexOf: objStackPage) = self wordSizeClassIndexPun
		ifFalse: [
			objStackInvalidBecause := 'wrong class index'.
			invalidObjStackPage := objStackPage.
			^ false ].
	(self formatOf: objStackPage) = self wordIndexableFormat ifFalse: [
		objStackInvalidBecause := 'wrong format'.
		invalidObjStackPage := objStackPage.
		^ false ].
	(self numSlotsOfAny: objStackPage) = ObjStackPageSlots ifFalse: [
		objStackInvalidBecause := 'wrong num slots'.
		invalidObjStackPage := objStackPage.
		^ false ].
	myx = (self fetchPointer: ObjStackMyx ofObject: objStackPage)
		ifFalse: [
			objStackInvalidBecause := 'wrong myx'.
			invalidObjStackPage := objStackPage.
			^ false ].
	(marking and: [ (self isMarked: objStackPage) not ]) ifTrue: [
		objStackInvalidBecause := 'marking but page is unmarked'.
		invalidObjStackPage := objStackPage.
		^ false ].
	^ true
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> methReturnInt [
	
	^ 5
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method [

	^ [ :arg1 | arg1 ] value: 10 + 10
]

{ #category : 'helpers' }
SLDeadCodeEliminationAlgoTestClass >> method: arg [
	<inline: false>
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTestClass >> methodWithBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var |
	var := [ :arg |
	       self method: arg.
	       arg ] value: var.
	^ var.
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTestClass >> methodWithBlockValueValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var var2 |
	var := [ :arg :arg2 |
	       self method: arg.
	       self method: arg2.
	       arg.
	       arg2 ] value: var2 value: var.
	^ var
]

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> methodWithCCoerceInExpression [

	<var: #i type: #'char *'>
	| i |
	i := self methReturnInt.
	^ i
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTestClass >> methodWithEmptyCaseOfSendInReceiver [

	self method caseOf: {
			([ 4 ] -> [ ^ 5 ]).
			([ 6 ] -> [  ]) }.
	^ 6
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocals [

	| var1 var2 var3 var4 var5 var6 |
	var1.
	var2 := var1.
	var3 := var4.
	var4 := 5.
	var5 := 6.
	var6 := var5.
	^ var6
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocalsFromBlock [

	| var1 |
	var1 := 5.
	var1 := [ :arg1 | arg1 + 1 ] value: var1.
	^ var1
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocalsFromBlockStatement [

	| var1 var2 |
	var1 := 4.
	[ :arg1 | var2 := arg1 + 1 ] value: var1.
	^ var2
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocalsFromBlockStatementWithExpressionInArguments [

	| var1 var2 |
	var1 := 4.
	[ :arg1 | var2 := arg1 + 1 ] value: var1.
	^ var2
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocalsFromBlockWithExpressionInArguments [

	| var1 |
	var1 := [ :arg1 | arg1 + 1 ] value: 5 + 1.
	^ var1
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithNeverUsedLocalsFromBlockasArguments [

	self method: self method
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTestClass >> methodWithOnlyBlockValueAssignmentIntoSameVariableInArguments [
	"produce a self assignation at translation time"

	| var |
	var := [ :arg | arg ] value: var.
	^ var
]

{ #category : 'never-used-locals' }
SLDeadCodeEliminationAlgoTestClass >> methodWithOnlyNeverUsedLocals [

	| var1 var2 var3 var4 |
	var1.
	var2 := var1.
	var3 := var4.
	var4 := 5
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTestClass >> methodWithOnlyUselessAssignment [

	<returnTypeC: #void>
	| i j |
	i := 5.
	j := i
]

{ #category : 'variable-assign-to-itself' }
SLDeadCodeEliminationAlgoTestClass >> methodWithSelfAssign [

	| var |
	var := var.
	^ var
]

{ #category : 'useless-switch' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUnusedVariableInCaseOfAndUnusedVariableInOtherwiseNoSendInExpression: anInt [

	<returnTypeC: #void>
	| i |
	anInt
		caseOf: {
				([ 5 ] -> [ i ]).
				([ 6 ] -> [ i ]) }
		otherwise: [ i ]
]

{ #category : 'useless-assignment' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessAssignment [

	| i j k l |
	k := 6.
	l := k + 1.
	i := 5.
	j := i.
	^ j
]

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessCodeInBinaryIterative [

	| var1 var2 |
	var1 := 0.
	2 to: 5 + 5 do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessCodeInBinaryIterativeNoSendInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: 5 do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessCodeInBinaryIterativeSendWithNoSideEffectsInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: 5 + 5 do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'useless-code-binary-iterative' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessCodeInBinaryIterativeSendWithSideEffectsInLimit [

	| var1 var2 |
	var1 := 0.
	2 to: self method do: [ :i |
		var2.
		var1 := var1 + 1 ].
	^ var1
]

{ #category : 'useless-local-in-sub-branches' }
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessLocalsDefinitionsWithSameNameInSubBranches [

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
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessLocalsInSubBranches [

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
SLDeadCodeEliminationAlgoTestClass >> methodWithUselessLocalsWithSameNameInSubBranches [

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

{ #category : 'debug' }
SLDeadCodeEliminationAlgoTestClass >> pop: nItems thenPushBool: boolean [

	<returnTypeC: #sqInt>
	| trueObj falseObj |
	self pop: nItems.
	self push: (boolean
			 ifTrue: [ trueObj ]
			 ifFalse: [ falseObj ])
]
