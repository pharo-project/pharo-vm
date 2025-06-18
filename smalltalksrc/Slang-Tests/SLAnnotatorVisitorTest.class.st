Class {
	#name : 'SLAnnotatorVisitorTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLNodeAnnotatorVisitor'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helper' }
SLAnnotatorVisitorTest >> getSendNodeInSet: aSetOfNode [

	^ aSetOfNode select: [ :node | node isSend ]
]

{ #category : 'helper' }
SLAnnotatorVisitorTest >> getValueOfConstantNodeInSet: aSetOfNode [

	^ (aSetOfNode select: [ :node | node isConstant ]) collect: [ :node |
		  node value ]
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithAssignment [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithAssignment.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 3.
	self assert: expressions size equals: 6.

	self assert: (constantSetExpression includes: 1).
	self assert: (constantSetExpression includes: 2).
	self assert: (constantSetExpression includes: 3).

	self assert: ((expressions select: [ :node |
			  node isConstant and: [ node value = 1 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor getAssignmentForExitVar: node) name = #x and: [
					 (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert: ((expressions select: [ :node |
			  node isConstant and: [ node value ~= 1 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor getAssignmentForExitVar: node) isNil and: [
					 (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert:
		((expressions select: [ :node | node isSend ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor getAssignmentForExitVar: node) name = #y and: [
					 (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithBlockReturn [

	| tMethod statements expressions constantSetExpression constantSetStatement |
	tMethod := ccg methodNamed: #methodWithBlockReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.
	constantSetStatement := self getValueOfConstantNodeInSet: statements.

	self assert: statements size equals: 5.
	self assert: expressions size equals: 1.

	self assert: constantSetExpression size equals: 1.
	self assert: (constantSetExpression includes: 4).

	self assert: constantSetStatement size equals: 2.
	self assert: (constantSetStatement includes: 2).
	self assert: (constantSetStatement includes: 3).

	self assert:
		((expressions select: [ :node | node isConstant ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		((statements select: [ :node | node isConstant ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ])
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithConditionalAssignment [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithConditionalAssignment.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.
	
	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.
	self assert: statements size equals: 5.
	self assert: expressions size equals: 4.
	self assert: (constantSetExpression includes: 1).
	self assert: (constantSetExpression includes: 2).
	self assert: constantSetExpression size equals: 3.
	self assert: ((expressions select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor getAssignmentForExitVar: node) name = #x ] ] ]).
	self assert:
		((expressions reject: [ :node | node isConstant ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor getAssignmentForExitVar: node) isNil ] ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'constant' }
SLAnnotatorVisitorTest >> testMethodWithConstant [

	| tMethod statements expressions constantSetExpression constantSetStatement |
	tMethod := ccg methodNamed: #methodWithConstant.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

	constantSetStatement := self getValueOfConstantNodeInSet: statements.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 10.
	self assert: expressions size equals: 2.

	self assert: (constantSetStatement includes: 1).
	self assert: (constantSetStatement includes: 2).
	self assert: (constantSetStatement includes: 3).
	self assert: (constantSetStatement includes: 4).
	self assert: (constantSetStatement includes: true).

	self assert: (constantSetExpression includes: 5).
	self assert: (constantSetExpression includes: 6).

	self assert:
		((expressions select: [ :node | node value isInteger ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert:
		((expressions select: [ :node | node value = true ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturn [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 2.
	self assert: expressions size equals: 1.

	self assert: (constantSetExpression includes: 2).

	self assert: (expressions allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturnInConditional [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithReturnInConditional.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.

	self assert: statements size equals: 7.
	self assert: expressions size equals: 2.

	self assert: (constantSetExpression includes: 2).
	self assert: (constantSetExpression includes: 4).
	self assert: constantSetExpression size equals: 2.

	self assert: ((expressions select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturningConditional [

	| tMethod statements expressions constantSetExpression |
	tMethod := ccg methodNamed: #methodWithReturningConditional.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.
	
	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.
	constantSetExpression := self getValueOfConstantNodeInSet:
		                         expressions.
	self assert: statements size equals: 2.
	self assert: expressions size equals: 6.
	self assert: (constantSetExpression includes: 2).
	self assert: (constantSetExpression includes: 4).
	self assert: constantSetExpression size equals: 3.
	self assert: ((expressions select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).
	self assert:
		((expressions reject: [ :node | node isConstant ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert: (statements allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsExpression [

	| tMethod statements expressions sendStatementSet sendExpressionSet constantSetStatement firstSend secondSend thirdSend |
	tMethod := ccg methodNamed: #methodWithSendAsExpression.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

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
	self assert: (sendExpressionSet includes: thirdSend).

	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: firstSend) and: [
			 (sLNodeAnnotatorVisitor getAssignmentForExitVar: firstSend) name = #x and: [
				 (sLNodeAnnotatorVisitor isInReturn: firstSend) not ] ]).


	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: secondSend) and: [
			 (sLNodeAnnotatorVisitor getAssignmentForExitVar: secondSend) isNil and: [
				 (sLNodeAnnotatorVisitor isInReturn: secondSend) not ] ]).

	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: thirdSend) and: [
			 (sLNodeAnnotatorVisitor getAssignmentForExitVar: thirdSend) name = #y and: [
				 (sLNodeAnnotatorVisitor isInReturn: thirdSend) not ] ])
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsStatement [

	| tMethod statements expressions constantSetExpression sendStatementSet sendExpressionSet constantSetStatement |
	tMethod := ccg methodNamed: #methodWithSendAsStatement.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

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

	self assert: sendExpressionSet isEmpty.

	self assert: (sendStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'statement-list' }
SLAnnotatorVisitorTest >> testMethodWithStatementList [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithStatementList.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

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

	self assert: (constantSetExpression includes: 11).

	self assert: ((statements select: [ :node |
			  node isConstant and: [ node value = 10 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert: ((statements select: [ :node |
			  node isConstant and: [ node value ~= 10 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).
	self assert: (expressions allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsExpression [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithSwitchAsExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

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
SLAnnotatorVisitorTest >> testMethodWithSwitchAsStatement [

	| tMethod statements expressions constantSetStatement constantSetExpression |
	tMethod := ccg methodNamed: #methodWithSwitchAsStatement.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	statements := sLNodeAnnotatorVisitor useAsStatementsSet.
	expressions := sLNodeAnnotatorVisitor useAsExpressionsSet.

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
