Class {
	#name : 'SLAnnotatorVisitorTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'sLNodeAnnotatorVisitor',
		'nonEffectiveExpressionOrStatementCollection',
		'effectiveExpressionValueCollection'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helper' }
SLAnnotatorVisitorTest >> checkEffectiveExpressionValueCollection [

	^ effectiveExpressionValueCollection allSatisfy: [ :node |
		  sLNodeAnnotatorVisitor isInExpression: node ]
]

{ #category : 'helper' }
SLAnnotatorVisitorTest >> checkNonEffectiveExpressionOrStatementCollection [

	^ nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
		  (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
			  (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not ] ]
]

{ #category : 'helper' }
SLAnnotatorVisitorTest >> fillCollectionValue: aTMethod [

	aTMethod parseTree nodesDo: [ :node |
		(sLNodeAnnotatorVisitor isEffectiveExpression: node)
			ifTrue: [ effectiveExpressionValueCollection add: node ]
			ifFalse: [ nonEffectiveExpressionOrStatementCollection add: node ] ]
]

{ #category : 'helper' }
SLAnnotatorVisitorTest >> getSendNodeIn: aCollectionOfNode [

	^ aCollectionOfNode select: [ :node | node isSend ]
]

{ #category : 'helper' }
SLAnnotatorVisitorTest >> getValueOfConstantNodeIn: aCollectionOfNode [

	^ (aCollectionOfNode select: [ :node | node isConstant ]) collect: [
		  :node | node value ]
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithAssignment [

	| tMethod effectiveConstantExpressionValueSet constant1 constant2And3 send2Add3 assignmentNodes assignmentNodeX assignmentNodeY |
	tMethod := ccg methodNamed: #methodWithAssignment.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 3.
	self assert: effectiveExpressionValueCollection size equals: 6.

	self assert: (effectiveConstantExpressionValueSet includes: 1).
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	assignmentNodes := nonEffectiveExpressionOrStatementCollection
		                   select: [ :node | node isAssignment ].
	assignmentNodeX := (assignmentNodes select: [ :node |
		                    node variable name = #x ]) first.
	assignmentNodeY := (assignmentNodes select: [ :node |
		                    node variable name = #y ]) first.

	constant1 := (effectiveExpressionValueCollection select: [ :node |
		              node isConstant and: [ node value = 1 ] ]) first.
	self assert: ((sLNodeAnnotatorVisitor assigningParentFor: constant1)
		 = assignmentNodeX and: [
			 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: constant1 ]).

	constant2And3 := effectiveExpressionValueCollection select: [ :node |
		                 node isConstant and: [ node value ~= 1 ] ].
	self assert: (constant2And3 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node)
			 = assignmentNodeY and: [
				 (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not ] ]).

	send2Add3 := (effectiveExpressionValueCollection select: [ :node |
		              node isSend ]) first.
	self assert:
		((sLNodeAnnotatorVisitor isInAssignment: send2Add3) and: [
			 (sLNodeAnnotatorVisitor assigningParentFor: send2Add3)
			 = assignmentNodeY and: [
				 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: send2Add3 ] ]).

	effectiveExpressionValueCollection do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInAssignment: node) and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not ]) ].

	self assert:
		(nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
					 (sLNodeAnnotatorVisitor isInExpression: node) not and: [
						 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ] ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithBlockReturn [

	| tMethod nonEffectiveExpressionOrStatementConstantSet constant4 returnNode constant2And3 firstStmtList blockNode |
	tMethod := ccg methodNamed: #methodWithBlockReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 5.
	self assert: effectiveExpressionValueCollection size equals: 1.

	self
		assert: nonEffectiveExpressionOrStatementConstantSet size
		equals: 2.
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 2).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 3).

	returnNode := (nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isReturn ]) first.
	constant4 := effectiveExpressionValueCollection first.
	self assert: constant4 value equals: 4.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant4) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant4) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: constant4) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: constant4)
					 = returnNode ] ] ]).

	firstStmtList := tMethod parseTree.
	{
		firstStmtList.
		returnNode } do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInExpression: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil ] ]) ].

	constant2And3 := nonEffectiveExpressionOrStatementCollection select: [
		                 :node | node isConstant ].
	blockNode := nonEffectiveExpressionOrStatementCollection select: [
		             :node |
		             node isStatementList and: [ node ~= firstStmtList ] ].
	constant2And3 addAll: blockNode.
	constant2And3 do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor isInExpression: node) and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode ] ]) ].

	nonEffectiveExpressionOrStatementCollection do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInAssignment: node) not ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'assignment' }
SLAnnotatorVisitorTest >> testMethodWithConditionalAssignment [

	| tMethod effectiveConstantExpressionValueSet firstStmtList assignmentNode constant1And2 variableX |
	tMethod := ccg methodNamed: #methodWithConditionalAssignment.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 5.
	self assert: effectiveExpressionValueCollection size equals: 4.

	self assert: (effectiveConstantExpressionValueSet includes: 1).
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: true).
	self assert: effectiveConstantExpressionValueSet size equals: 3.

	assignmentNode := (nonEffectiveExpressionOrStatementCollection
		                   select: [ :node | node isAssignment ]) first.

	constant1And2 := effectiveExpressionValueCollection select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant1And2 allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node ]).

	variableX := (effectiveExpressionValueCollection reject: [ :node |
		              node isConstant ]) first.
	self assert:
		(sLNodeAnnotatorVisitor isEffectiveAssignmentValue: variableX) not.

	effectiveExpressionValueCollection do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) and: [
					 (sLNodeAnnotatorVisitor assigningParentFor: node)
					 = assignmentNode ] ]) ].

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementCollection select: [ :node |
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

	nonEffectiveExpressionOrStatementCollection do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInReturn: node) not ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'constant' }
SLAnnotatorVisitorTest >> testMethodWithConstant [

	| tMethod effectiveConstantExpressionValueSet nonEffectiveExpressionOrStatementConstantSet constant5And6 constantTrue returns return5 return6 stmtListOfIfTrueAndConstant4AndAndReturn5 |
	tMethod := ccg methodNamed: #methodWithConstant.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 9.
	self assert: effectiveExpressionValueCollection size equals: 3.

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

	constant5And6 := effectiveExpressionValueCollection select: [ :node |
		                 node value isInteger ].
	self assert: (constant5And6 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ] ]).

	returns := nonEffectiveExpressionOrStatementCollection select: [
		           :node | node isReturn ].
	return5 := (returns select: [ :node | node expression value = 5 ])
		           first.
	return6 := (returns select: [ :node | node expression value = 6 ])
		           first.

	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (constant5And6 select: [ :node | node value = 5 ]) first)
		equals: return5.
	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (constant5And6 select: [ :node | node value = 6 ]) first)
		equals: return6.

	constantTrue := (effectiveExpressionValueCollection select: [ :node |
		                 node value = true ]) first.
	self assert:
		((sLNodeAnnotatorVisitor isInReturn: constantTrue) not and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constantTrue) not
				 and: [
				 (sLNodeAnnotatorVisitor returningParentFor: constantTrue) isNil ] ]).

	effectiveExpressionValueCollection do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInAssignment: node) not ].

	self assert:
		(nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil ] ] ]).

	"ifTrue body"
	stmtListOfIfTrueAndConstant4AndAndReturn5 := (nonEffectiveExpressionOrStatementCollection
		                                              select: [ :node |
		                                              node isSend ]) first
		                                             arguments first
		                                             asOrderedCollection.
	stmtListOfIfTrueAndConstant4AndAndReturn5 first statements do: [
		:node | stmtListOfIfTrueAndConstant4AndAndReturn5 add: node ].
	stmtListOfIfTrueAndConstant4AndAndReturn5 do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInExpression: node) ].

	(nonEffectiveExpressionOrStatementCollection reject: [ :node |
		 stmtListOfIfTrueAndConstant4AndAndReturn5 includes: node ]) do: [
		:node |
		self assert: (sLNodeAnnotatorVisitor isInExpression: node) not ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturn [

	| tMethod constant2 returnNode |
	tMethod := ccg methodNamed: #methodWithReturn.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 2.
	self assert: effectiveExpressionValueCollection size equals: 1.

	constant2 := effectiveExpressionValueCollection first.
	self assert: constant2 value equals: 2.

	returnNode := (nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isReturn ]) first.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant2) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant2) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: constant2)
				 = returnNode and: [
					 (sLNodeAnnotatorVisitor isInAssignment: constant2) not ] ] ]).


	self assert:
		(nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
						 (sLNodeAnnotatorVisitor isInExpression: node) not ] ] ] ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturnInConditional [

	| tMethod effectiveConstantExpressionValueSet constant2And4 returnNodes return2 return4 ifTrueIfFalseNode firstStmtList constantTrue |
	tMethod := ccg methodNamed: #methodWithReturnInConditional.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 6.
	self assert: effectiveExpressionValueCollection size equals: 3.

	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: true).

	constant2And4 := effectiveExpressionValueCollection select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant2And4 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ] ]).



	returnNodes := nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isReturn ].
	return2 := (returnNodes select: [ :node | node expression value = 2 ])
		           first.
	return4 := (returnNodes select: [ :node | node expression value = 4 ])
		           first.

	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (effectiveExpressionValueCollection select: [ :node |
					  node value = 2 ]) first)
		equals: return2.
	self
		assert: (sLNodeAnnotatorVisitor returningParentFor:
				 (effectiveExpressionValueCollection select: [ :node |
					  node value = 4 ]) first)
		equals: return4.

	constantTrue := (effectiveExpressionValueCollection select: [ :node |
		                 node value = true ]) first.
	self assert:
		((sLNodeAnnotatorVisitor isInReturn: constantTrue) not and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constantTrue) not
				 and: [
				 (sLNodeAnnotatorVisitor returningParentFor: constantTrue) isNil ] ]).

	effectiveExpressionValueCollection do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInAssignment: node) not ].

	self assert:
		(nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil ] ] ]).

	ifTrueIfFalseNode := (nonEffectiveExpressionOrStatementCollection
		                      select: [ :node | node isSend ]) first.
	firstStmtList := tMethod parseTree.
	{
		firstStmtList.
		ifTrueIfFalseNode } do: [ :node |
		self assert:
			(sLNodeAnnotatorVisitor isInExpression: ifTrueIfFalseNode) not ].

	(nonEffectiveExpressionOrStatementCollection reject: [ :node |
		 {
			 firstStmtList.
			 ifTrueIfFalseNode } includes: node ]) do: [ :node |
		self assert: (sLNodeAnnotatorVisitor isInExpression: node) ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'return' }
SLAnnotatorVisitorTest >> testMethodWithReturningConditional [

	| tMethod effectiveConstantExpressionValueSet constant2And4 returnNode constantTrue firtStmtList |
	tMethod := ccg methodNamed: #methodWithReturningConditional.
	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 5.
	self assert: effectiveExpressionValueCollection size equals: 3.
	self assert: (effectiveConstantExpressionValueSet includes: 2).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: true).

	returnNode := (nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isReturn ]) first.
	constant2And4 := effectiveExpressionValueCollection select: [ :node |
		                 node isConstant and: [ node value isInteger ] ].
	self assert: (constant2And4 allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ]).

	constantTrue := (effectiveExpressionValueCollection select: [ :node |
		                 node value = true ]) first.
	self assert:
		(sLNodeAnnotatorVisitor isEffectiveReturnValue: constantTrue) not.

	self assert:
		(effectiveExpressionValueCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode
					 and: [ (sLNodeAnnotatorVisitor isInAssignment: node) not ] ] ]).

	firtStmtList := tMethod parseTree.
	self assert:
		((nonEffectiveExpressionOrStatementCollection select: [ :node |
			  node ~= firtStmtList and: [ node ~= returnNode ] ]) allSatisfy: [
			 :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode
					 and: [ sLNodeAnnotatorVisitor isInExpression: node ] ] ]).
	{
		firtStmtList.
		returnNode } do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
					 (sLNodeAnnotatorVisitor isInExpression: node) not ] ]) ].

	self assert:
		(nonEffectiveExpressionOrStatementCollection allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsExpression [
	"for this method, the AST is modified by asTranslatorNodeIn: for assignment which push down the assignment inside a block                            "

	| tMethod nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet firstSend secondSend thirdSend assignmentNodes assignmentX assignmentY |
	tMethod := ccg methodNamed: #methodWithSendAsExpression.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementSendSet := self getSendNodeIn:
		                                            nonEffectiveExpressionOrStatementCollection.
	effectiveExpressionValueSendSet := self getSendNodeIn:
		                                   effectiveExpressionValueCollection.

	firstSend := ((tMethod parseTree statements at: 1) statements at: 1)
		             expression.
	secondSend := firstSend arguments at: 1.
	thirdSend := (tMethod parseTree statements at: 2) expression.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 4.
	self assert: effectiveExpressionValueCollection size equals: 8.

	self assert: nonEffectiveExpressionOrStatementSendSet isEmpty.

	self assert: effectiveExpressionValueSendSet size equals: 3.
	self assert: (effectiveExpressionValueSendSet includes: firstSend).
	self assert: (effectiveExpressionValueSendSet includes: secondSend).
	self assert: (effectiveExpressionValueSendSet includes: thirdSend).

	assignmentNodes := nonEffectiveExpressionOrStatementCollection
		                   select: [ :node | node isAssignment ].
	assignmentX := (assignmentNodes select: [ :node |
		                node variable name = #x ]) first.
	assignmentY := (assignmentNodes select: [ :node |
		                node variable name = #y ]) first.

	{
		firstSend.
		secondSend } do: [ :node |
		self
			assert: (sLNodeAnnotatorVisitor assigningParentFor: node)
			equals: assignmentX ].

	self
		assert: (sLNodeAnnotatorVisitor assigningParentFor: thirdSend)
		equals: assignmentY.

	{
		firstSend.
		thirdSend } do: [ :node |
		self assert:
			(sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) ].

	self assert:
		(sLNodeAnnotatorVisitor isEffectiveAssignmentValue: secondSend) not.

	effectiveExpressionValueCollection do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 sLNodeAnnotatorVisitor isInAssignment: node ]) ].

	nonEffectiveExpressionOrStatementCollection do: [ :node |
		self assert:
			((sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil and: [
					 (sLNodeAnnotatorVisitor isInReturn: node) not ] ]) ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'send' }
SLAnnotatorVisitorTest >> testMethodWithSendAsStatement [

	| tMethod nonEffectiveExpressionOrStatementSendSet effectiveExpressionValueSendSet constant1 firstSend secondSend selfs firstStmtList blockNode |
	tMethod := ccg methodNamed: #methodWithSendAsStatement.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementSendSet := self getSendNodeIn:
		                                            nonEffectiveExpressionOrStatementCollection.
	effectiveExpressionValueSendSet := self getSendNodeIn:
		                                   effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 4.
	self assert: effectiveExpressionValueCollection size equals: 3.

	constant1 := (effectiveExpressionValueCollection select: [ :node |
		              node isConstant ]) first.
	selfs := effectiveExpressionValueCollection select: [ :node |
		         node ~= constant1 ].
	self assert: constant1 value equals: 1.
	self assert: selfs size equals: 2.
	selfs do: [ :node | self assert: node name equals: 'self' ].

	effectiveExpressionValueCollection do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
						 (sLNodeAnnotatorVisitor isEffectiveAssignmentValue: node) not
							 and: [
								 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
									 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ] ] ]) ].

	firstSend := (tMethod parseTree statements at: 1) statements at: 1.
	secondSend := tMethod parseTree statements at: 2.
	self assert: nonEffectiveExpressionOrStatementSendSet size equals: 2.
	self assert:
		(nonEffectiveExpressionOrStatementSendSet includes: firstSend).
	self assert:
		(nonEffectiveExpressionOrStatementSendSet includes: secondSend).

	firstStmtList := tMethod parseTree.
	self assert:
		(nonEffectiveExpressionOrStatementCollection includes: firstStmtList).
	blockNode := nonEffectiveExpressionOrStatementCollection reject: [
		             :node |
		             {
			             firstSend.
			             secondSend.
			             firstStmtList } includes: node ].
	self assert: blockNode size equals: 1.
	blockNode := blockNode first.

	nonEffectiveExpressionOrStatementCollection do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor returningParentFor: node) isNil and: [
						 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ]) ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'statement-list' }
SLAnnotatorVisitorTest >> testMethodWithStatementList [

	| tMethod nonEffectiveExpressionOrStatementConstantSet constant11 returnNode blockNodeInReturn constant10 |
	tMethod := ccg methodNamed: #methodWithStatementList.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 10.
	self assert: effectiveExpressionValueCollection size equals: 1.

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

	returnNode := (nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isReturn ]) first.
	constant10 := (nonEffectiveExpressionOrStatementCollection select: [
		               :node | node isConstant and: [ node value = 10 ] ])
		              first.
	blockNodeInReturn := returnNode expression.
	self assert: (nonEffectiveExpressionOrStatementCollection includes:
			 blockNodeInReturn).
	{
		blockNodeInReturn.
		constant10 } do: [ :node |
		self assert: ((sLNodeAnnotatorVisitor isInReturn: node) and: [
				 (sLNodeAnnotatorVisitor returningParentFor: node) = returnNode ]) ].

	self assert:
		((nonEffectiveExpressionOrStatementCollection select: [ :node |
			  node ~= blockNodeInReturn and: [ node ~= constant10 ] ])
			 allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not ]).

	nonEffectiveExpressionOrStatementCollection do: [ :node |
		self assert:
			((sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ]) ].

	constant11 := effectiveExpressionValueCollection first.
	self assert: constant11 value equals: 11.
	self assert: ((sLNodeAnnotatorVisitor isInReturn: constant11) and: [
			 (sLNodeAnnotatorVisitor isEffectiveReturnValue: constant11) and: [
				 (sLNodeAnnotatorVisitor isInAssignment: constant11) not ] ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchAsAssignmentExpression [

	| tMethod effectiveConstantExpressionValueSet assignmentNode |
	tMethod := ccg methodNamed: #methodWithSwitchAsAssignmentExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 5.
	self assert: effectiveExpressionValueCollection size equals: 6.

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).

	assignmentNode := (nonEffectiveExpressionOrStatementCollection
		                   select: [ :node | node isAssignment ]) first.
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) = assignmentNode ]).
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) = assignmentNode ]).

	effectiveExpressionValueCollection do: [ :node |
		self
			assert: (sLNodeAnnotatorVisitor assigningParentFor: node)
			equals: assignmentNode ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection.

	self assert: ((effectiveExpressionValueCollection
			  addAll: nonEffectiveExpressionOrStatementCollection;
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

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 5.
	self assert: effectiveExpressionValueCollection size equals: 5.

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).

	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isInReturn: node "and: [
				 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ]" ]).
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isInReturn: node "and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ]" ]).

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementCollection select: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node | sLNodeAnnotatorVisitor isInReturn: node ]).

	self assert:
		((nonEffectiveExpressionOrStatementCollection reject: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node | (sLNodeAnnotatorVisitor isInReturn: node) not ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection.

	self assert: ((effectiveExpressionValueCollection
			  addAll: nonEffectiveExpressionOrStatementCollection;
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

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 6.
	self assert: effectiveExpressionValueCollection size equals: 3.

	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 6).
	self assert:
		(nonEffectiveExpressionOrStatementConstantSet includes: 7).

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: 5).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection.

	self assert: ((effectiveExpressionValueCollection
			  addAll: nonEffectiveExpressionOrStatementCollection;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
					 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not and: [
						 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ] ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchWithOtherwiseAsAssignmentExpression [

	| tMethod effectiveConstantExpressionValueSet assignmentNode |
	tMethod := ccg methodNamed:
		           #methodWithSwitchWithOtherwiseAsAssignmentExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 6.
	self assert: effectiveExpressionValueCollection size equals: 7.

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).
	self assert: (effectiveConstantExpressionValueSet includes: 8).

	assignmentNode := (nonEffectiveExpressionOrStatementCollection
		                   select: [ :node | node isAssignment ]) first.
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) = assignmentNode ]).
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor assigningParentFor: node) = assignmentNode ]).

	effectiveExpressionValueCollection do: [ :node |
		self
			assert: (sLNodeAnnotatorVisitor assigningParentFor: node)
			equals: assignmentNode ].

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection.

	self assert: ((effectiveExpressionValueCollection
			  addAll: nonEffectiveExpressionOrStatementCollection;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInReturn: node) not and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ] ])
]

{ #category : 'switch' }
SLAnnotatorVisitorTest >> testMethodWithSwitchWithOtherwiseAsReturnExpression [

	| tMethod nonEffectiveExpressionOrStatementConstantSet effectiveConstantExpressionValueSet firstStmtList |
	tMethod := ccg methodNamed:
		           #methodWithSwitchWithOtherwiseAsReturnExpression.
	tMethod prepareMethodIn: ccg.

	sLNodeAnnotatorVisitor visit: tMethod parseTree.

	self fillCollectionValue: tMethod.

	nonEffectiveExpressionOrStatementConstantSet := self
		                                                getValueOfConstantNodeIn:
		                                                nonEffectiveExpressionOrStatementCollection.
	effectiveConstantExpressionValueSet := self
		                                       getValueOfConstantNodeIn:
		                                       effectiveExpressionValueCollection.

	self
		assert: nonEffectiveExpressionOrStatementCollection size
		equals: 6.
	self assert: effectiveExpressionValueCollection size equals: 6.

	self assert: (effectiveConstantExpressionValueSet includes: 3).
	self assert: (effectiveConstantExpressionValueSet includes: 4).
	self assert: (effectiveConstantExpressionValueSet includes: 5).
	self assert: (effectiveConstantExpressionValueSet includes: 6).
	self assert: (effectiveConstantExpressionValueSet includes: 7).
	self assert: (effectiveConstantExpressionValueSet includes: 8).

	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value ~= 3 ] ]) allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isInReturn: node "and: [
				 sLNodeAnnotatorVisitor isEffectiveReturnValue: node ]" ]).
	self assert: ((effectiveExpressionValueCollection select: [ :node |
			  node isConstant and: [ node value = 3 ] ]) allSatisfy: [ :node |
			 sLNodeAnnotatorVisitor isInReturn: node "and: [
				 (sLNodeAnnotatorVisitor isEffectiveReturnValue: node) not ]" ]).

	firstStmtList := tMethod parseTree.

	self assert:
		((nonEffectiveExpressionOrStatementCollection select: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node | sLNodeAnnotatorVisitor isInReturn: node ]).

	self assert:
		((nonEffectiveExpressionOrStatementCollection reject: [ :node |
			  node isReturn not and: node ~= firstStmtList ]) allSatisfy: [
			 :node | (sLNodeAnnotatorVisitor isInReturn: node) not ]).

	self assert: self checkNonEffectiveExpressionOrStatementCollection.
	self assert: self checkEffectiveExpressionValueCollection.

	self assert: ((effectiveExpressionValueCollection
			  addAll: nonEffectiveExpressionOrStatementCollection;
			  yourself) allSatisfy: [ :node |
			 (sLNodeAnnotatorVisitor isInAssignment: node) not and: [
				 (sLNodeAnnotatorVisitor assigningParentFor: node) isNil ] ])
]
