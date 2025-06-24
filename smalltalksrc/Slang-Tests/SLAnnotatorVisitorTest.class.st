Class {
	#name : 'SLAnnotatorVisitorTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLNodeAnnotatorVisitor',
		'nonEffectiveExpressionOrStatementSet',
		'effectiveExpressionValueSet'
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

	| tMethod effectiveConstantExpressionValueSet constant1 constant2And3 send2Add3 assignmentNodes assignmentNodeX assignmentNodeY |
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
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	assignmentNodes := nonEffectiveExpressionOrStatementSet select: [
		                   :node | node isAssignment ].
	assignmentNodeX := (assignmentNodes select: [ :node |
		                    node variable name = #x ]) asArray first.
	assignmentNodeY := (assignmentNodes select: [ :node |
		                    node variable name = #y ]) asArray first.

	constant1 := (effectiveExpressionValueSet select: [ :node |
		              node isConstant and: [ node value = 1 ] ]) asArray
		             first.
	self assert: ((sLNodeAnnotatorVisitor assigningParentFor: constant1)
		 = assignmentNodeX and: [
			 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: constant1 ]).

	constant2And3 := effectiveExpressionValueSet select: [ :node |
		                 node isConstant and: [ node value ~= 1 ] ].
	self assert: (constant2And3 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node)
			 = assignmentNodeY and: [
				 (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not ] ]).

	send2Add3 := (effectiveExpressionValueSet select: [ :node |
		              node isSend ]) asArray first.
	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: send2Add3) and: [
			 (sLNodeAnnotatorVisitor assigningParentFor: send2Add3)
			 = assignmentNodeY and: [
				 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: send2Add3 ] ]).

	effectiveExpressionValueSet do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 sLNodeAnnotatorVisitor isInExpression: node ] ]) ].

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInExpression: node) not and: [
						 (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not
							 and: [
							 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ] ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithBlockReturn [

	| tMethod nonEffectiveExpressionOrStatementConstantSet constant4 returnNode constant2And3 firstStmtList blockNode |
	tMethod := ccg methodNamed: #methodWithBlockReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeInSet:
		                                                nonEffectiveExpressionOrStatementSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 5.
	self assert: effectiveExpressionValueSet size equals: 1.

	self
		assert: nonEffectiveExpressionOrStatementConstantSet size
		equals: 2.
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 2).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 3).

	returnNode := (nonEffectiveExpressionOrStatementSet select: [ :node |
		               node isReturn ]) asArray first.
	constant4 := effectiveExpressionValueSet asArray first.
	self assert: constant4 value equals: 4.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant4) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant4) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: constant4) not and: [
					 (sLNodeAnnotatorVisitor isInExpression: constant4) and: [
						 (sLNodeAnnotatorVisitor returningParentFor: constant4)
						 = returnNode ] ] ] ]).

	firstStmtList := tMethod parseTree.
	{
		firstStmtList.
		returnNode } do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInExpression: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil ] ]) ].

	constant2And3 := nonEffectiveExpressionOrStatementSet select: [ :node |
		                 node isConstant ].
	blockNode := nonEffectiveExpressionOrStatementSet select: [ :node |
		             node isStatementList and: [ node ~= firstStmtList ] ].
	constant2And3 addAll: blockNode.
	constant2And3 do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInExpression: node) and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode ] ]) ].

	nonEffectiveExpressionOrStatementSet do: [ :node |
		self assert:
			((sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not ]) ]
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithConditionalAssignment [

	| tMethod effectiveConstantExpressionValueSet firstStmtList assignmentNode constant1And2 variableX |
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
	self assert: (effectiveConstantExpressionValueSet includes: true).
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	assignmentNode := (nonEffectiveExpressionOrStatementSet select: [
		                   :node | node isAssignment ]) asArray first.

	constant1And2 := effectiveExpressionValueSet select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant1And2 allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node ]).

	variableX := (effectiveExpressionValueSet reject: [ :node |
		              node isConstant ]) asArray first.
	self assert:
		(sLNodeAnnotatorVisitor isEffectiveAssignmentValue: variableX) not.

	effectiveExpressionValueSet do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInExpression: node) and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
						 (sLNodeAnnotatorVisitor assigningParentFor: node)
						 = assignmentNode ] ] ]) ].

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isAssignment not and: [ node ~= firstStmtList ] ])
			 allSatisfy: [ :node |
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor assigningParentFor: node)
					 = assignmentNode and: [
						 sLNodeAnnotatorVisitor isInExpression: node ] ] ]).
	{
		firstStmtList.
		assignmentNode } do: [ :node |
		self assert:
			((sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil and: [
					 (sLNodeAnnotatorVisitor isInExpression: node) not ] ]) ].

	nonEffectiveExpressionOrStatementSet do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not ]) ]
]

{ #category : 'constant' }
SLAnnotatorVisitorTest >> testMethodWithConstant [

	| tMethod effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementConstantSet constant5And6 constantTrue returns return5 return6 stmtListOfIfTrueAndConstant4AndAndReturn5 |
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

	self assert: nonEffectiveExpressionOrStatementSet size equals: 9.
	self assert: effectiveExpressionValueSet size equals: 3.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 1).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 2).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 3).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 4).

	self assert: (effectiveConstantExpressionValueSet includes: true).
	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).

	constant5And6 := (effectiveExpressionValueSet select: [ :node |
		                  node value isInteger ]) asArray.
	self assert: (constant5And6 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
						 sLNodeAnnotatorVisitor isInExpression: node ] ] ] ]).

	returns := nonEffectiveExpressionOrStatementSet select: [ :node |
		           node isReturn ].
	return5 := (returns select: [ :node | node expression value = 5 ])
		           asArray first.
	return6 := (returns select: [ :node | node expression value = 6 ])
		           asArray first.

	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (constant5And6 select: [ :node | node value = 5 ]) first)
		equals: return5.
	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (constant5And6 select: [ :node | node value = 6 ]) first)
		equals: return6.

	constantTrue := (effectiveExpressionValueSet select: [ :node |
		                 node value = true ]) asArray first.
	self assert:
		((sLNodeAnnotatorVisitor isInReturn: constantTrue) not and: [
			 (sLNodeAnnotatorVisitor isInAssignment: constantTrue) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constantTrue) not
					 and: [
						 (sLNodeAnnotatorVisitor returningParentFor: constantTrue) isNil
							 and: [ sLNodeAnnotatorVisitor isInExpression: constantTrue ] ] ] ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil ] ] ]).

	"ifTrue body"
	stmtListOfIfTrueAndConstant4AndAndReturn5 := (nonEffectiveExpressionOrStatementSet
		                                              select: [ :node |
		                                              node isSend ]) asArray
		                                             first arguments first
		                                             asOrderedCollection.
	stmtListOfIfTrueAndConstant4AndAndReturn5 first statements do: [
		:node | stmtListOfIfTrueAndConstant4AndAndReturn5 add: node ].
	stmtListOfIfTrueAndConstant4AndAndReturn5 do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInExpression: node) ].

	(nonEffectiveExpressionOrStatementSet reject: [ :node |
		 stmtListOfIfTrueAndConstant4AndAndReturn5 includes: node ]) do: [
		:node |
		self assert: (sLNodeAnnotatorVisitor isInExpression: node) not ]
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturn [

	| tMethod constant2 returnNode |
	tMethod := ccg methodNamed: #methodWithReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.


	self assert: nonEffectiveExpressionOrStatementSet size equals: 2.
	self assert: effectiveExpressionValueSet size equals: 1.

	constant2 := effectiveExpressionValueSet asArray first.
	self assert: constant2 value equals: 2.

	returnNode := (nonEffectiveExpressionOrStatementSet select: [ :node |
		               node isReturn ]) asArray first.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant2) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant2) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: constant2)
				 = returnNode and: [
					 (sLNodeAnnotatorVisitor isInAssignment: constant2) not and: [
						 sLNodeAnnotatorVisitor isInExpression: constant2 ] ] ] ]).


	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
						 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
							 (sLNodeAnnotatorVisitor isInExpression: node) not ] ] ] ] ])
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturnInConditional [

	| tMethod effectiveConstantExpressionValueSet constant2And4 returnNodes return2 return4 ifTrueIfFalseNode firstStmtList |
	tMethod := ccg methodNamed: #methodWithReturnInConditional.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	nonEffectiveExpressionOrStatementSet := sLNodeAnnotatorVisitor
		                                        nonEffectiveExpressionOrStatementSet.
	effectiveExpressionValueSet := sLNodeAnnotatorVisitor
		                               effectiveExpressionValueSet.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeInSet:
		                                       effectiveExpressionValueSet.

	self assert: nonEffectiveExpressionOrStatementSet size equals: 6.
	self assert: effectiveExpressionValueSet size equals: 3.

	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: true).

	constant2And4 := effectiveExpressionValueSet select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant2And4 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	returnNodes := nonEffectiveExpressionOrStatementSet select: [ :node |
		               node isReturn ].
	return2 := (returnNodes select: [ :node | node expression value = 2 ])
		           asArray first.
	return4 := (returnNodes select: [ :node | node expression value = 4 ])
		           asArray first.

	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (effectiveExpressionValueSet select: [ :node | node value = 2 ])
					 asArray first)
		equals: return2.
	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (effectiveExpressionValueSet select: [ :node | node value = 4 ])
					 asArray first)
		equals: return4.

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
						 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ] ] ]).

	ifTrueIfFalseNode := (nonEffectiveExpressionOrStatementSet select: [
		                      :node | node isSend ]) asArray first.
	firstStmtList := tMethod parseTree.
	{
		firstStmtList.
		ifTrueIfFalseNode } do: [ :node |
		self assert:
			(sLNodeAnnotatorVisitor isInExpression: ifTrueIfFalseNode) not ].
	(nonEffectiveExpressionOrStatementSet reject: [ :node |
		 node = firstStmtList or: [ node = ifTrueIfFalseNode ] ]) do: [
		:node | (sLNodeAnnotatorVisitor isInExpression: node) not ]
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturningConditional [

	| tMethod effectiveConstantExpressionValueSet constant2And4 returnNode constantTrue |
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
	self assert: (effectiveConstantExpressionValueSet includes: true).

	returnNode := (nonEffectiveExpressionOrStatementSet select: [ :node |
		               node isReturn ]) asArray first.
	constant2And4 := effectiveExpressionValueSet select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant2And4 allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ]).

	constantTrue := (effectiveExpressionValueSet select: [ :node |
		                 node value = true ]) asArray first.
	self assert:
		(sLNodeAnnotatorVisitor isEffectiveReturnValue: constantTrue) not.

	self assert: (effectiveExpressionValueSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode
					 and: [ (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

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

	| tMethod nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet firstSend secondSend thirdSend |
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
			 (sLNodeAnnotatorVisitor assigningParentFor: firstSend) name = #x
				 and: [ (sLNodeAnnotatorVisitor isInReturn: firstSend) not ] ]).


	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: secondSend) and: [
			 (sLNodeAnnotatorVisitor assigningParentFor: secondSend) isNil
				 and: [ (sLNodeAnnotatorVisitor isInReturn: secondSend) not ] ]).

	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: thirdSend) and: [
			 (sLNodeAnnotatorVisitor assigningParentFor: thirdSend) name = #y
				 and: [ (sLNodeAnnotatorVisitor isInReturn: thirdSend) not ] ])
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsStatement [

	| tMethod effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet |
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

	| tMethod nonEffectiveExpressionOrStatementConstantSet constant11 |
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
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isConstant and: [ node value ~= 10 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
					 (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	constant11 := effectiveExpressionValueSet asArray first.
	self assert: constant11 value equals: 11.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant11) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant11) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: constant11) not ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsAssignmentExpression [

	| tMethod nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet |
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
			 (sLNodeAnnotatorVisitor assigningParentFor: node) name = #x ]).
	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ]).

	self assert:
		(nonEffectiveExpressionOrStatementSet allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ]).

	self assert: ((effectiveExpressionValueSet
			  addAll: nonEffectiveExpressionOrStatementSet;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsReturnExpression [

	| tMethod nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet firstStmtList |
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
				 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ] ]).
	self assert: ((effectiveExpressionValueSet select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ]).

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementSet select: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ]).

	self assert:
		((nonEffectiveExpressionOrStatementSet reject: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ]).

	self assert: ((effectiveExpressionValueSet
			  addAll: nonEffectiveExpressionOrStatementSet;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsStatement [

	| tMethod nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet |
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
					 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
						 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ] ])
]
