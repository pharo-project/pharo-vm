Class {
	#name : 'SLNodeAnnotatorVisitorTestClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLNodeAnnotatorVisitorTestClass >> emptyMethod [
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitorTestClass >> emptyMethod: arg [
]

{ #category : 'assignment' }
SLNodeAnnotatorVisitorTestClass >> methodWithAssignment [

	| x y |
	x := 1.
	y := 2 + 3
]

{ #category : 'return' }
SLNodeAnnotatorVisitorTestClass >> methodWithBlockReturn [

	^ [
	  2.
	  3.
	  4 ]
]

{ #category : 'assignment' }
SLNodeAnnotatorVisitorTestClass >> methodWithConditionalAssignment [

	| x |
	x := true
		     ifTrue: [ 1 ]
		     ifFalse: [ 2 ]
]

{ #category : 'constant' }
SLNodeAnnotatorVisitorTestClass >> methodWithConstant [

	1.
	2.
	3.
	true ifTrue: [
		4.
		^ 5 ].
	^ 6
]

{ #category : 'return' }
SLNodeAnnotatorVisitorTestClass >> methodWithReturn [

	^ 2
]

{ #category : 'return' }
SLNodeAnnotatorVisitorTestClass >> methodWithReturnInConditional [

	true
		ifTrue: [ ^ 2 ]
		ifFalse: [ ^ 4 ]
]

{ #category : 'return' }
SLNodeAnnotatorVisitorTestClass >> methodWithReturningConditional [

	^ true
		  ifTrue: [ 2 ]
		  ifFalse: [ 4 ]
]

{ #category : 'send' }
SLNodeAnnotatorVisitorTestClass >> methodWithSendAsExpression [

	| x y |
	x := [ self emptyMethod: self emptyMethod ].
	y := self emptyMethod
]

{ #category : 'send' }
SLNodeAnnotatorVisitorTestClass >> methodWithSendAsStatement [

	[ self emptyMethod: 1 ].
	self emptyMethod
]

{ #category : 'statement-list' }
SLNodeAnnotatorVisitorTestClass >> methodWithStatementList [

	5.
	6.
	7.
	[ 8. 9 ].
	^ [ 10. 11 ]
]

{ #category : 'switch' }
SLNodeAnnotatorVisitorTestClass >> methodWithSwitchAsExpression [

	| x |
	x := 3 caseOf: {
			     ([ 4 ] -> [ 6 ]).
			     ([ 5 ] -> [ 7 ]) }
]

{ #category : 'switch' }
SLNodeAnnotatorVisitorTestClass >> methodWithSwitchAsStatement [

	3 caseOf: {
			([ 4 ] -> [ 6 ]).
			([ 5 ] -> [ 7 ]) }
]
