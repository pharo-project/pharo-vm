Class {
	#name : 'SLStatementOrExpressionAnnotatorTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLStatementOrExpressionAnnotatorTestClass >> emptyMethod [
]

{ #category : 'helpers' }
SLStatementOrExpressionAnnotatorTestClass >> emptyMethod: arg [
]

{ #category : 'assignment' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithAssignment [

	| x |
	x := 1.
	x := 2 + 3
]

{ #category : 'constant' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithConstant [

	1.
	2.
	3.
	true ifTrue: [
		4.
		^ 5 ].
	^ 6
]

{ #category : 'return' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithReturn [

	^ 2
]

{ #category : 'return' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithReturnInConditional [

	true
		ifTrue: [ ^ 2 ]
		ifFalse: [ ^ 4 ]
]

{ #category : 'send' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithSendAsExpression [

	| x |
	x := [ self emptyMethod: self emptyMethod ].
	x := self emptyMethod
]

{ #category : 'send' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithSendAsStatement [

	[ self emptyMethod: 1 ].
	self emptyMethod
]

{ #category : 'statement-list' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithStatementList [

	5.
	6.
	7.
	[ 8. 9 ].
	^ [ 10. 11 ]
]

{ #category : 'switch' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithSwitchAsExpression [

	| x |
	x := 3 caseOf: {
			     ([ 4 ] -> [ 6 ]).
			     ([ 5 ] -> [ 7 ]) }
]

{ #category : 'switch' }
SLStatementOrExpressionAnnotatorTestClass >> methodWithSwitchAsStatement [

	3 caseOf: {
			([ 4 ] -> [ 6 ]).
			([ 5 ] -> [ 7 ]) }
]
