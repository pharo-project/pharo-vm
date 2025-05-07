Class {
	#name : 'SLStatementOrExpressionAnnotator',
	#superclass : 'Object',
	#instVars : [
		'annotatorStack',
		'currentMethod',
		'statements',
		'expressions'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'helpers' }
SLStatementOrExpressionAnnotator >> addToExpressionsOrStatements: aNode [

	annotatorStack top = self expressionString
		ifTrue: [ expressions add: aNode ]
		ifFalse: [ statements add: aNode ]
]

{ #category : 'accessing' }
SLStatementOrExpressionAnnotator >> currendMethod: aTmethod [

	currentMethod := aTmethod
]

{ #category : 'helpers' }
SLStatementOrExpressionAnnotator >> expressionString [

	^ #expression
]

{ #category : 'accessing' }
SLStatementOrExpressionAnnotator >> expressions [

	^ expressions
]

{ #category : 'initialization' }
SLStatementOrExpressionAnnotator >> initialize [

	super initialize.
	annotatorStack := Stack new.
	expressions := IdentitySet new.
	statements := IdentitySet new
]

{ #category : 'helpers' }
SLStatementOrExpressionAnnotator >> statementString [

	^ #statement
]

{ #category : 'accessing' }
SLStatementOrExpressionAnnotator >> statements [

	^ statements
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visit: aNode [

	annotatorStack push: self statementString.
	aNode accept: self.
	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitAssignmentNode: anAssignmentNode [

	self addToExpressionsOrStatements: anAssignmentNode.

	annotatorStack push: self expressionString.

	anAssignmentNode variable accept: self.
	anAssignmentNode expression accept: self.

	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitCaseStatementNode: aCaseStmtNode [

	self addToExpressionsOrStatements: aCaseStmtNode.

	annotatorStack push: self expressionString.
	
	aCaseStmtNode expression accept: self.
	aCaseStmtNode cases do: [ :case | case accept: self ].
	
	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitConstantNode: aConstantNode [

	self addToExpressionsOrStatements: aConstantNode
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitGoToNode: aTGotoNode [

	self addToExpressionsOrStatements: aTGotoNode
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitInlineNode: anInlineNode [
	
	self addToExpressionsOrStatements: anInlineNode.
	
	annotatorStack push: self expressionString.
	
	anInlineNode method parseTree accept: self.
	
	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitLabeledCommentNode: aLabeledCommentNode [

	self addToExpressionsOrStatements: aLabeledCommentNode
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitReturnNode: aReturnNode [

	self addToExpressionsOrStatements: aReturnNode.

	annotatorStack push: self expressionString.

	aReturnNode expression accept: self.

	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitSendNode: aSendNode [

	self addToExpressionsOrStatements: aSendNode.

	annotatorStack push: self expressionString.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitStatementListNode: aStatementsListNode [

	| stmts |
	self addToExpressionsOrStatements: aStatementsListNode.

	aStatementsListNode isEmptyOrHasNothingButComments
		ifFalse: [
			aStatementsListNode lastNonCommentStatement accept: self.
			stmts := aStatementsListNode allButLastNonCommentStatement ]
		ifTrue: [ stmts := aStatementsListNode statements ].

	annotatorStack push: self statementString.

	stmts do: [ :stmt | stmt accept: self ].

	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitSwitchStatementNode: aSwitchStatementNode [

	self addToExpressionsOrStatements: aSwitchStatementNode.

	aSwitchStatementNode cases do: [ :case |
		| caseLabels caseStatements |
		caseLabels := case first.
		caseStatements := case second.
		caseLabels do: [ :label |
			annotatorStack push: self statementString.
			label accept: self.
			annotatorStack pop.

			caseStatements accept: self ] ].

	annotatorStack push: self expressionString.

	aSwitchStatementNode expression accept: self.
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o | o accept: self ].

	annotatorStack pop
]

{ #category : 'visiting' }
SLStatementOrExpressionAnnotator >> visitVariableNode: aVariableNode [

	self addToExpressionsOrStatements: aVariableNode
]
