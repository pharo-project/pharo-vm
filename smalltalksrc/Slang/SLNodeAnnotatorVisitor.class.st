Class {
	#name : 'SLNodeAnnotatorVisitor',
	#superclass : 'Object',
	#instVars : [
		'annotatorStack',
		'returnStack',
		'exitVarStack',
		'currentMethod',
		'info'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToExitVar: aNode [
	"when an assignment has been met, all of the expression is in it but regarding exitVar, we only want the top level expression node to have the exitVar, the sub node if they exist have exitvar to nil and are still considered inside an assignment"

	| entry |
	exitVarStack isEmpty ifTrue: [ ^ self ].

	entry := info at: aNode.
	entry at: self exitVarString put: exitVarStack top.
	exitVarStack pop.
	exitVarStack push: nil
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToReturn: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is an expression>
	true or false on the stack indicate if the node is the a direct return and is the returning expression or not"

	| entry |
	returnStack isEmpty ifTrue: [ ^ self ].

	entry := info at: aNode.
	entry at: self returnString put: returnStack top.
	returnStack pop.
	"no longer the direct return"
	returnStack push: false
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToStatementOrExpression: aNode [

	| entry |
	entry := info at: aNode.
	(annotatorStack isNotEmpty and: [
		 annotatorStack top = self expressionString ])
		ifTrue: [
			entry at: self expressionString put: true.
			aNode isAnExpression: true ]
		ifFalse: [
			entry at: self expressionString put: false.
			aNode isAnExpression: false ].

	"default to a statement by default"
	annotatorStack isEmpty ifFalse: [ ^ self ].
	entry at: self expressionString put: false.
	aNode isAnExpression: false
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode [

	self ensureEntryInInfoDictFor: aNode.
	self addToStatementOrExpression: aNode.
	self addToReturn: aNode.
	self addToExitVar: aNode
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> currendMethod: aTmethod [

	currentMethod := aTmethod
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> exitVarFor: aNode [

	^ (info at: aNode) at: self exitVarString ifAbsent: [ nil ]
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> exitVarString [

	^ #exitVar
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> expressions [

	| expressions |
	expressions := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifTrue: [
			expressions add: assoc key ] ].
	^ expressions
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> handleConditionalSendVisit: aSendNode [

	| returnTop exitVarTop size |
	annotatorStack push: self expressionString.

	size := aSendNode arguments size.
	aSendNode arguments doWithIndex: [ :arg :index |
		returnTop := returnStack isEmpty ifFalse: [ returnStack top ].
		exitVarTop := exitVarStack isEmpty ifFalse: [ exitVarStack top ].
		arg accept: self.
		index ~= size ifTrue: [
			returnTop ifNotNil: [
				returnStack pop.
				returnStack push: returnTop ].
			exitVarTop ifNotNil: [
				exitVarStack pop.
				exitVarStack push: exitVarTop ] ] ].

	aSendNode receiver accept: self.

	annotatorStack pop.

	self annotateNodeState: aSendNode
]

{ #category : 'initialization' }
SLNodeAnnotatorVisitor >> initialize [

	super initialize.
	annotatorStack := Stack new.
	returnStack := Stack new.
	exitVarStack := Stack new.
	info := IdentityDictionary new
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isDirectReturn: aNode [

	^ (info at: aNode) at: self returnString ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInAssignment: aNode [ 
	
	^ (info at: aNode) at: self exitVarString ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> returnString [

	^ #return
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> statementString [

	^ #statement
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> statements [

	| statements |
	statements := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifFalse: [
			statements add: assoc key ] ].
	^ statements
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visit: aNode [

	aNode accept: self.
	self assert: exitVarStack isEmpty.
	self assert: returnStack isEmpty.
	self assert: annotatorStack isEmpty.
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitAssignmentNode: anAssignmentNode [

	self annotateNodeState: anAssignmentNode.

	annotatorStack push: self expressionString.
	exitVarStack push: anAssignmentNode variable.

	anAssignmentNode expression accept: self.
	anAssignmentNode variable accept: self.

	annotatorStack pop.
	exitVarStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitBraceCaseNode: aTBraceCaseNode [
	"shouldn't be reachable in real condition, TBraceCaseNode are translated to switch before going throught any operation.
	it can be reach throught tests as a side effect since inlining goes for all knowned methods in the codeGenerator even if they are not the tests focuss"

	
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitCaseStatementNode: aCaseStmtNode [

	self annotateNodeState: aCaseStmtNode.

	annotatorStack push: self expressionString.
	
	aCaseStmtNode expression accept: self.
	aCaseStmtNode cases do: [ :case | case accept: self ].
	
	annotatorStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitConstantNode: aConstantNode [

	self annotateNodeState: aConstantNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitGoToNode: aTGotoNode [

	self annotateNodeState: aTGotoNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitInlineNode: anInlineNode [
	
	self annotateNodeState: anInlineNode.
	
	annotatorStack push: self expressionString.
	
	anInlineNode method parseTree accept: self.
	
	annotatorStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitLabeledCommentNode: aLabeledCommentNode [

	self annotateNodeState: aLabeledCommentNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitReturnNode: aReturnNode [

	self annotateNodeState: aReturnNode.

	annotatorStack push: self expressionString.
	returnStack push: true.

	aReturnNode expression accept: self.

	annotatorStack pop.
	returnStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSendNode: aSendNode [

	aSendNode isConditionalSend ifTrue: [
		self handleConditionalSendVisit: aSendNode.
		^ self ].

	self annotateNodeState: aSendNode.

	annotatorStack push: self expressionString.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	annotatorStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitStatementListNode: aStatementsListNode [

	| stmts |
	aStatementsListNode isEmptyOrHasNothingButComments
		ifFalse: [
			aStatementsListNode lastNonCommentStatement accept: self.
			stmts := aStatementsListNode allButLastNonCommentStatement ]
		ifTrue: [ stmts := aStatementsListNode statements ].

	self annotateNodeState: aStatementsListNode.

	annotatorStack push: self statementString.

	stmts do: [ :stmt | stmt accept: self ].

	annotatorStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	self annotateNodeState: aSwitchStatementNode.

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
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
