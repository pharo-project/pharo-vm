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

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithAssignment.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 3.
	self assert: effectiveExpressionValueSet size equals: 6.

	self assert: (effectiveConstantExpressionValueSet includes: 1).
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 3).

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value = 1 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) name = #x
					 and: [ (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value ~= 1 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil and: [
					 (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert:
		((effectiveExpressionValueSet select: [ :node | node isSend ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) name = #y
						 and: [ (sLNodeAnnotatorVisitor isInReturn: node) not ] ] ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithBlockReturn [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementConstantSet |
	tMethod := ccg methodNamed: #methodWithBlockReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.
	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 5.
	self assert: effectiveExpressionValueSet size equals: 1.

	self assert: effectiveConstantExpressionValueSet size equals: 1.
	self assert: (effectiveConstantExpressionValueSet includes: 4).

	self
		assert: nonEffectiveExpressionOrStatementConstantSet size
		equals: 2.
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 2).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 3).

	self assert:
		((effectiveExpressionValueSet select: [ :node | node isConstant ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) and: [
					 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
						 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isConstant ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ])
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithConditionalAssignment [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet firstStmtList |
	tMethod := ccg methodNamed: #methodWithConditionalAssignment.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.
	self assert: nonEffectiveExpressionOrStatementSet size equals: 5.
	self assert: effectiveExpressionValueSet size equals: 4.

	self assert: (effectiveConstantExpressionValueSet includes: 1).
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) name = #x ] ] ]).
	self assert:
		((effectiveExpressionValueSet reject: [ :node | node isConstant ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
						 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil ] ] ]).

	firstStmtList := tMethod parseTree.
	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isAssignment not and: [ node ~= firstStmtList ] ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 sLNodeAnnotatorVisitor isInAssignment: node ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet reject: [ :node |
			  node isAssignment not and: [ node ~= firstStmtList ] ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'constant' }
SLAnnotatorVisitorTest >> testMethodWithConstant [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementConstantSet |
	tMethod := ccg methodNamed: #methodWithConstant.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 10.
	self assert: effectiveExpressionValueSet size equals: 2.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 1).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 2).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 3).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 4).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: true).

	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).

	self assert:
		((effectiveExpressionValueSet select: [ :node |
			  node value isInteger ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert:
		((effectiveExpressionValueSet select: [ :node | node value = true ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturn [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 2.
	self assert: effectiveExpressionValueSet size equals: 1.

	self assert: (effectiveConstantExpressionValueSet includes: 2).

	self assert: (effectiveExpressionValueSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturnInConditional [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithReturnInConditional.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 7.
	self assert: effectiveExpressionValueSet size equals: 2.

	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: effectiveConstantExpressionValueSet size equals: 2.

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturningConditional [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithReturningConditional.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.
	self assert: nonEffectiveExpressionOrStatementSet size equals: 5.
	self assert: effectiveExpressionValueSet size equals: 3.
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value isInteger ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).
	self assert:
		((effectiveExpressionValueSet reject: [ :node | node isConstant ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInReturn: node) and: [
					 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
						 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isStatementList and: [ node children first isConstant ] ])
			 allSatisfy: [ :node | sLNodeAnnotatorVisitor isInReturn: node ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isStatementList and: [ node children first isConstant not ] ])
			 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isSend ]) allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isInReturn: node ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not ])
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsExpression [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet firstSend secondSend thirdSend |
	tMethod := ccg methodNamed: #methodWithSendAsExpression.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.


	nonEffectiveExpressionOrStatementSendSet := self getSendNodeInSet:
		                                            nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSendSet := self getSendNodeInSet:
		                                   effectiveExpressionValueSet.

	firstSend := ((tMethod parseTree statements at: 1) statements at: 1)
		             expression.
	secondSend := firstSend arguments at: 1.
	thirdSend := (tMethod parseTree statements at: 2) expression.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 4.
	self assert: effectiveExpressionValueSet size equals: 8.

	self assert: nonEffectiveExpressionOrStatementSendSet isEmpty.

	self assert: effectiveExpressionValueSendSet size equals: 3.
	self assert: (effectiveExpressionValueSendSet includes: firstSend).
	self assert: (effectiveExpressionValueSendSet includes: secondSend).
	self assert: (effectiveExpressionValueSendSet includes: thirdSend).

	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: firstSend) and: [
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: firstSend) name
			 = #x and: [ (sLNodeAnnotatorVisitor isInReturn: firstSend) not ] ]).


	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: secondSend) and: [
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: secondSend) isNil
				 and: [ (sLNodeAnnotatorVisitor isInReturn: secondSend) not ] ]).

	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: thirdSend) and: [
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: thirdSend) name
			 = #y and: [ (sLNodeAnnotatorVisitor isInReturn: thirdSend) not ] ])
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsStatement [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet |
	tMethod := ccg methodNamed: #methodWithSendAsStatement.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementSendSet := self getSendNodeInSet:
		                                            nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSendSet := self getSendNodeInSet:
		                                   effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 4.
	self assert: effectiveExpressionValueSet size equals: 3.

	self assert: (effectiveConstantExpressionValueSet includes: 1).

	self assert: nonEffectiveExpressionOrStatementSendSet size equals: 2.
	self assert: (nonEffectiveExpressionOrStatementSendSet includes:
			 ((tMethod parseTree statements at: 1) statements at: 1)).
	self assert: (nonEffectiveExpressionOrStatementSendSet includes:
			 (tMethod parseTree statements at: 2)).

	self assert: effectiveExpressionValueSendSet isEmpty.

	self assert:
		(nonEffectiveExpressionOrStatementSendSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ])
]

{ #category : 'statement-list' }
SLAnnotatorVisitorTest >> testMethodWithStatementList [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet nonEffectiveExpressionOrStatementConstantSet constant11 |
	tMethod := ccg methodNamed: #methodWithStatementList.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 10.
	self assert: effectiveExpressionValueSet size equals: 1.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 5).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 6).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 7).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 8).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 9).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 10).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isConstant and: [ node value = 10 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isConstant and: [ node value ~= 10 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	constant11 := effectiveExpressionValueSet asArray first.
	self assert: constant11 value equals: 11.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant11) and: [
			 (sLNodeAnnotatorVisitor isDirectReturn: constant11) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: constant11) not ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsAssignmentExpression [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithSwitchAsAssignmentExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 7.
	self assert: effectiveExpressionValueSet size equals: 4.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 4).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 5).

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) name = #x ]).
	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil ]).

	self assert: ((effectiveExpressionValueSet
			  addAll: nonEffectiveExpressionOrStatementSet;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not  ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsReturnExpression [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet firstStmtList |
	tMethod := ccg methodNamed: #methodWithSwitchAsReturnExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 7.
	self assert: effectiveExpressionValueSet size equals: 3.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 4).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 5).

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).

	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 sLNodeAnnotatorVisitor isDirectReturn: node ] ]).
	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not ] ]).

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet reject: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isDirectReturn: node) not ] ]).

	self assert: ((effectiveExpressionValueSet
			  addAll: nonEffectiveExpressionOrStatementSet;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsStatement [

	| tMethod nonEffectiveExpressionOrStatementSet effectiveExpressionValueSet nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet |
	tMethod := ccg methodNamed: #methodWithSwitchAsStatement.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 8.
	self assert: effectiveExpressionValueSet size equals: 1.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 4).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 5).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 6).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 7).

	self assert: (effectiveConstantExpressionValueSet includes: 3).

	self assert: ((effectiveExpressionValueSet
			  addAll: nonEffectiveExpressionOrStatementSet;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor isDirectReturn: node) not and: [
						 (sLNodeAnnotatorVisitor getAssigningVariableFor: node) isNil ] ] ] ])
]
