"
Calls become statements and nested calls are assigned to variables.
	
	For example, I transform statements of the form:
	
	> self foo: self nonInlinedMethodUsingAutolocalizedVariable
	
	into
	
	> t0 := self nonInlinedMethodUsingAutolocalizedVariable
	> t1 := self foo: t0
	
	Such localization happens on a per-block basis:
	
	> someExpression ifTrue: [
	>		self foo: self nonInlinedMethodUsingAutolocalizedVariable
	> ]

	into
	
	> someExpression ifTrue: [
	> 	| t0 t1 |
	> 	t0 := self nonInlinedMethodUsingAutolocalizedVariable.
	> 	t1 := self foo: t0
	> ]
	""
"
Class {
	#name : 'SLLinearisationVisitor',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator',
		'builder',
		'localizedVariables',
		'callgraphVariableCollector'
	],
	#category : 'Slang-Optimizations',
	#package : 'Slang',
	#tag : 'Optimizations'
}

{ #category : 'visiting' }
SLLinearisationVisitor >> addLinearisedStatement: anExpression [

	builder push: anExpression.
	^ builder popAsStatement
]

{ #category : 'accessing' }
SLLinearisationVisitor >> builder [

	^ builder
]

{ #category : 'accessing' }
SLLinearisationVisitor >> codeGenerator [

	^ codeGenerator
]

{ #category : 'accessing' }
SLLinearisationVisitor >> codeGenerator: anObject [

	codeGenerator := anObject.
	callgraphVariableCollector := SLCallGraphFreeVariableCollector codeGenerator: codeGenerator
]

{ #category : 'accessing' }
SLLinearisationVisitor >> localizedVariables: anObject [

	localizedVariables := anObject
]

{ #category : 'visiting' }
SLLinearisationVisitor >> pop [

	^ builder popAsExpression
]

{ #category : 'visiting' }
SLLinearisationVisitor >> shouldLineariseSend: aTSendNode [

	(codeGenerator isDynamicCall: aTSendNode) ifTrue: [ ^ true ].
	
	callgraphVariableCollector startFromSelector: aTSendNode selector.
	^ (callgraphVariableCollector freeVariablesUsedByMethodNamed: aTSendNode selector)
		anySatisfy: [ :each | localizedVariables includes: each ]
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitAssignmentNode: aTAssignmentNode [ 

	| expression |
	aTAssignmentNode expression accept: self.
	expression := aTAssignmentNode expression isConditionalSend
		ifTrue: [ builder popAsStatement ]
		ifFalse: [ builder popAsExpression ].
	
	builder push: (aTAssignmentNode shallowCopy
		expression: expression;
		yourself)
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitCaseStatementNode: aTCaseStmtNode [
	
	| expressionVar newCases |
	aTCaseStmtNode expression accept: self.
	expressionVar := self pop.
	newCases := aTCaseStmtNode cases collect: [ :case |
		case accept: self.
		self pop.
	].

	builder push: (aTCaseStmtNode shallowCopy
		expression: expressionVar;
		cases: newCases;
		yourself)
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitConstantNode: aTConstantNode [ 
	
	builder push: aTConstantNode
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitGoToNode: aTGoToNode [ 
	
	builder push: aTGoToNode
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitInlineNode: aTInlineNode [

	aTInlineNode method accept: self.
	builder push: self pop asInlineNode
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitLabeledCommentNode: aTLabeledCommentNode [ 

	builder push: aTLabeledCommentNode
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitMethod: aTMethod [ 

	aTMethod parseTree accept: self.
	builder push: (aTMethod shallowCopy
		parseTree: self pop;
		yourself)
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitReturnNode: aTReturnNode [ 
	
	aTReturnNode expression accept: self.
	builder addStatement: (TReturnNode expression: builder popAsStatement)
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitSendNode: aTSendNode [

	| receiverVar argVars newSelector newNode shouldLinearise |
	
	"Do not rewrite asserts..."
	(aTSendNode selector == #assert:)
		ifTrue: [
			builder pushAsStatement: aTSendNode.
			^ self ].
	
	"Transform and: to ifTrue: and or: to ifFalse:
	The consumer of the node will decide if it is used as an expression or not"
	newSelector := aTSendNode selector.
	shouldLinearise := self shouldLineariseSend: aTSendNode.
	aTSendNode selector = #and: ifTrue: [ 
		shouldLinearise := true.
		newSelector := #ifTrue: ].
	aTSendNode selector = #or: ifTrue: [ 
		shouldLinearise := true.
		newSelector := #ifFalse: ].

	aTSendNode receiver accept: self.
	receiverVar := shouldLinearise
		               ifTrue: [ builder popAsStatement ]
		               ifFalse: [ builder popAsExpression ].

	argVars := aTSendNode arguments collect: [ :arg | 
		           arg accept: self.
		           (aTSendNode isConditionalSend or: [ shouldLinearise ])
			           ifTrue: [ builder popAsStatement ]
			           ifFalse: [ builder popAsExpression ] ].

	newNode := TSendNode
		           receiver: receiverVar
		           selector: newSelector
		           arguments: argVars.

	shouldLinearise
		ifTrue: [ builder pushAsStatement: newNode ]
		ifFalse: [ builder push: newNode ]
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitStatement: aStatement [

	aStatement accept: self.
	builder finishStatement
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitStatementListNode: aTStatementListNode [ 
	
	| statementList previousBuilder |
	previousBuilder := builder.
	builder := MLStatementListBuider new
		codeGenerator: codeGenerator;
		parent: previousBuilder;
		yourself.
	aTStatementListNode statements do: [ :each | 
		self visitStatement: each
	].
	statementList := builder buildStatementList.
	statementList := aTStatementListNode shallowCopy
		addDeclarations: statementList declarations;
		statements: statementList statements;
		yourself.
	
	previousBuilder ifNotNil: [ previousBuilder push: statementList ].
	builder := previousBuilder.

	^ statementList
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitSwitchStatementNode: aTSwitchStmtNode [ 
	
	| expressionVar newCases |
	aTSwitchStmtNode expression accept: self.
	expressionVar := self pop.
	newCases := aTSwitchStmtNode cases collect: [ :case |
		case second accept: self.
		{case first. self pop}
	].

	builder push: (aTSwitchStmtNode shallowCopy
		expression: expressionVar;
		cases: newCases;
		yourself)
]

{ #category : 'visiting' }
SLLinearisationVisitor >> visitVariableNode: aTVariableNode [ 
	
	builder push: aTVariableNode
]
