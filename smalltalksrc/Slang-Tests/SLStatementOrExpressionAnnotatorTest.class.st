Class {
	#name : 'SLStatementOrExpressionAnnotatorTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLStatementOrExpressionAnnotator'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helper' }
SLStatementOrExpressionAnnotatorTest >> getSendNodeInSet: aSetOfNode [

	^ aSetOfNode select: [ :node | node isSend ]
]

{ #category : 'helper' }
SLStatementOrExpressionAnnotatorTest >> getValueOfConstantNodeInSet: aSetOfNode [

	^ (aSetOfNode select: [ :node | node isConstant ]) collect: [ :node |
		  node value ]
]

{ #category : 'assignment' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithAssignment [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithAssignment.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 3.
	self assert: expressions size equals: 6.

	self assert: (constantSetExpression includes: 1).
	self assert: (constantSetExpression includes: 2).
	self assert: (constantSetExpression includes: 3)
]

{ #category : 'constant' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithConstant [

	| tMethod statements expressions constantSetExpression constantSetStatement |
	tMethod := ccg methodNamed: #methodWithConstant.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 7.
	self assert: expressions size equals: 5.

	self assert: (constantSetStatement includes: 1).
	self assert: (constantSetStatement includes: 2).
	self assert: (constantSetStatement includes: 3).
	self assert: (constantSetStatement includes: 4).

	self assert: (constantSetExpression includes: true).
	self assert: (constantSetExpression includes: 5).
	self assert: (constantSetExpression includes: 6)
]

{ #category : 'return' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithReturn [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithReturn.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 2.
	self assert: expressions size equals: 1.

	self assert: (constantSetExpression includes: 2)
]

{ #category : 'return' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithReturnInConditional [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithReturnInConditional.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 2.
	self assert: expressions size equals: 7.

	self assert: (constantSetExpression includes: 2).
	self assert: (constantSetExpression includes: 4)
]

{ #category : 'send' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithSendAsExpression [

	| tMethod statements expressions sendStatementSet sendExpressionSet constantSetStatement firstSend secondSend thirdSend |
	tMethod := ccg methodNamed: #methodWithSendAsExpression.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.

	sendStatementSet := self getSendNodeInSet: statements.
	sendExpressionSet := self getSendNodeInSet: expressions.

	firstSend := ((tMethod parseTree statements at: 1) statements at: 1)
		             expression.
	secondSend := firstSend arguments at: 1.
	thirdSend := (tMethod parseTree statements at: 2) expression.

	self assert: statements size equals: 4.
	self assert: expressions size equals: 8.

	self assert: sendStatementSet isEmpty.

	self assert: sendExpressionSet size equals: 3.
	self assert: (sendExpressionSet includes: firstSend).
	self assert: (sendExpressionSet includes: secondSend).
	self assert: (sendExpressionSet includes: thirdSend)
]

{ #category : 'send' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithSendAsStatement [

	| tMethod statements expressions constantSetExpression sendStatementSet sendExpressionSet constantSetStatement |
	tMethod := ccg methodNamed: #methodWithSendAsStatement.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.
	constantSetStatement := self getValueOfConstantNodeInSet: statements.

	sendStatementSet := self getSendNodeInSet: statements.
	sendExpressionSet := self getSendNodeInSet: expressions.

	self assert: statements size equals: 4.
	self assert: expressions size equals: 3.

	self assert: (constantSetExpression includes: 1).

	self assert: sendStatementSet size equals: 2.
	self assert: (sendStatementSet includes:
			 ((tMethod parseTree statements at: 1) statements at: 1)).
	self assert:
		(sendStatementSet includes: (tMethod parseTree statements at: 2)).

	self assert: sendExpressionSet isEmpty
]

{ #category : 'statement-list' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithStatementList [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithStatementList.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 9.
	self assert: expressions size equals: 2.

	self assert: (constantSetStatement includes: 5).
	self assert: (constantSetStatement includes: 6).
	self assert: (constantSetStatement includes: 7).
	self assert: (constantSetStatement includes: 8).
	self assert: (constantSetStatement includes: 9).
	self assert: (constantSetStatement includes: 10).

	self assert: (constantSetExpression includes: 11)
]

{ #category : 'switch' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithSwitchAsExpression [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithSwitchAsExpression.
	tMethod prepareMethodIn: ccg.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 4.
	self assert: expressions size equals: 7.

	self assert: (constantSetStatement includes: 4).
	self assert: (constantSetStatement includes: 5).

	self assert: (constantSetExpression includes: 3).
	self assert: (constantSetExpression includes: 6).
	self assert: (constantSetExpression includes: 7)
]

{ #category : 'switch' }
SLStatementOrExpressionAnnotatorTest >> testMethodWithSwitchAsStatement [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithSwitchAsStatement.
	tMethod prepareMethodIn: ccg.

	sLStatementOrExpressionAnnotator visit: tMethod parseTree.

	statements := sLStatementOrExpressionAnnotator statements.
	expressions := sLStatementOrExpressionAnnotator expressions.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 8.
	self assert: expressions size equals: 1.

	self assert: (constantSetStatement includes: 4).
	self assert: (constantSetStatement includes: 5).
	self assert: (constantSetStatement includes: 6).
	self assert: (constantSetStatement includes: 7).

	self assert: (constantSetExpression includes: 3)
]
