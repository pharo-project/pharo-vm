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
	#name : #MLLinearisationVisitor,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'builder'
	],
	#category : #'Slang-AST'
}

{ #category : #accessing }
MLLinearisationVisitor >> codeGenerator [

	^ codeGenerator
]

{ #category : #accessing }
MLLinearisationVisitor >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #visiting }
MLLinearisationVisitor >> visitAssignmentNode: aTAssignmentNode [ 
	
	aTAssignmentNode expression accept: self.
	
	builder push: (aTAssignmentNode shallowCopy
		expression: builder pop;
		yourself)
]

{ #category : #visiting }
MLLinearisationVisitor >> visitCaseStatementNode: aTCaseStmtNode [
	
	| expressionVar newCases |
	aTCaseStmtNode expression accept: self.
	expressionVar := builder pop.
	newCases := aTCaseStmtNode cases collect: [ :case |
		case accept: self.
		builder pop.
	].

	builder push: (aTCaseStmtNode shallowCopy
		expression: expressionVar;
		cases: newCases;
		yourself)
]

{ #category : #visiting }
MLLinearisationVisitor >> visitConstantNode: aTConstantNode [ 
	
	builder push: aTConstantNode
]

{ #category : #visiting }
MLLinearisationVisitor >> visitInlineNode: aTInlineNode [

	aTInlineNode method accept: self.
	builder push: builder pop asInlineNode
]

{ #category : #visiting }
MLLinearisationVisitor >> visitLabeledCommentNode: aTLabeledCommentNode [ 

	builder push: aTLabeledCommentNode
]

{ #category : #visiting }
MLLinearisationVisitor >> visitMethod: aTMethod [ 

	aTMethod parseTree accept: self.
	builder push: (aTMethod shallowCopy
		parseTree: builder pop;
		yourself)
]

{ #category : #visiting }
MLLinearisationVisitor >> visitReturnNode: aTReturnNode [ 
	
	aTReturnNode expression accept: self.
	builder addStatement: (TReturnNode expression: builder pop)
]

{ #category : #visiting }
MLLinearisationVisitor >> visitSendNode: aTSendNode [ 

	| receiverVar argVars newSelector |
	aTSendNode receiver accept: self.
	receiverVar := builder pop.
	
	argVars := aTSendNode arguments collect: [ :arg |
		arg accept: self.
		builder pop.
	].

	"Transform and: to ifTrue: and or: to ifFalse:
	The consumer of the node will decide if it is used as an expression or not"
	newSelector := aTSendNode selector.
	(aTSendNode selector = #and:) ifTrue: [ 
		newSelector := #ifTrue: ].
	(aTSendNode selector = #or:) ifTrue: [ 
		newSelector := #ifFalse: ].
	
	builder push: (TSendNode
		receiver: receiverVar
		selector: newSelector
		arguments: argVars)
]

{ #category : #visiting }
MLLinearisationVisitor >> visitStatementListNode: aTStatementListNode [ 
	
	| statementList previousBuilder |
	previousBuilder := builder.
	
	builder := MLStatementListBuider new
		codeGenerator: codeGenerator;
		parent: previousBuilder;
		yourself.
	aTStatementListNode statements do: [ :each | 
		each accept: self.
		builder finishStatement.
	].
	statementList := builder buildStatementList.
	
	previousBuilder ifNotNil: [ previousBuilder push: statementList ].
	builder := previousBuilder.
	
	^ statementList
]

{ #category : #visiting }
MLLinearisationVisitor >> visitVariableNode: aTVariableNode [ 
	
	builder push: aTVariableNode
]
