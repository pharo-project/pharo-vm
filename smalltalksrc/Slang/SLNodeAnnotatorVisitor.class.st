Class {
	#name : 'SLNodeAnnotatorVisitor',
	#superclass : 'Object',
	#instVars : [
		'returnStack',
		'exitVarStack',
		'currentMethod',
		'info',
		'useAsExpressionStack',
		'inExpressionStack'
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
SLNodeAnnotatorVisitor >> addToInExpression: aNode [

	inExpressionStack isEmpty ifTrue: [ ^ self ].
	(info at: aNode) at: self inExpressionString put: true
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToReturn: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is an expression>
	true or false on the stack indicate if the node is the a direct return and is the returning expression or not"

	| entry assoc |
	returnStack isEmpty ifTrue: [ ^ self ].

	entry := info at: aNode.
	assoc := returnStack top.
	entry at: self returnString put: assoc.
	returnStack pop.
	"no longer the direct return"
	returnStack push: false -> assoc value
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToStatementOrExpression: aNode [

	| entry |
	entry := info at: aNode.
	(useAsExpressionStack isNotEmpty and: [
		 useAsExpressionStack top = self expressionString ])
		ifTrue: [
			entry at: self expressionString put: true.
			aNode isAnExpression: true ]
		ifFalse: [
			entry at: self expressionString put: false.
			aNode isAnExpression: false ].

	"default to a statement by default"
	useAsExpressionStack isEmpty ifFalse: [ ^ self ].
	entry at: self expressionString put: false.
	aNode isAnExpression: false
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode [

	self ensureEntryInInfoDictFor: aNode.
	self addToStatementOrExpression: aNode.
	self addToReturn: aNode.
	self addToExitVar: aNode.
	self addToInExpression: aNode
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

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> exitVarFor: aNode [

	^ (info at: aNode) at: self exitVarString ifAbsent: [ nil ]
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> exitVarString [

	^ #exitVar
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> handleConditionalSendVisit: aSendNode [

	| returnTop exitVarTop size |
	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

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

	inExpressionStack pop.
	useAsExpressionStack pop.

	self annotateNodeState: aSendNode
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> inExpressionString [
	"value doesn't actually matter, but the stack need elements"

	^ #inExpression
]

{ #category : 'initialization' }
SLNodeAnnotatorVisitor >> initialize [

	super initialize.
	useAsExpressionStack := Stack new.
	returnStack := Stack new.
	exitVarStack := Stack new.
	inExpressionStack := Stack new.
	info := IdentityDictionary new
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isDirectExpression: aNode [

	^ (info at: aNode)
		  at: self expressionString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isDirectReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc key ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInAssignment: aNode [ 
	
	^ (info at: aNode) at: self exitVarString ifPresent: [ true ] ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInExpression: aNode [

	^ (info at: aNode)
		  at: self inExpressionString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeReturningParentFrom: aSendNode [
	"use in inlining for redondant return : return {return exp} -> {return exp}, clean all the info as a side effect, it needs to be recalculated"

	| returningParent |
	(self isInReturn: aSendNode) ifFalse: [ ^ self ].

	returningParent := self returningParentFor: aSendNode.

	self transformDirectReturnFrom: returningParent.

	returningParent parent
		replaceChild: returningParent
		with: returningParent expression.

	self cleanInfo
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> returnString [

	^ #return
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> returningParentFor: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc value ]
		  ifAbsent: [ nil ]
]

{ #category : 'helpers-constant' }
SLNodeAnnotatorVisitor >> statementString [

	^ #statement
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformDirectReturnFrom: parentNode [
	"recursively go throught the ast to transfrom directReturn
	^ exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [^exp] ifFalse [^exp]"

	parentNode children do: [ :child |
		(self isDirectReturn: child)
			ifTrue: [
			child parent replaceChild: child with: child asReturnNode ]
			ifFalse: [ self transformDirectReturnFrom: child ] ]
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> useAsExpressionsSet [

	| expressions |
	expressions := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifTrue: [
			expressions add: assoc key ] ].
	^ expressions
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> useAsStatementsSet [

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
	self assert: useAsExpressionStack isEmpty.
	self assert: inExpressionStack isEmpty
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitAssignmentNode: anAssignmentNode [

	self annotateNodeState: anAssignmentNode.

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	exitVarStack push: anAssignmentNode variable.

	anAssignmentNode expression accept: self.
	anAssignmentNode variable accept: self.

	inExpressionStack pop.
	useAsExpressionStack pop.
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

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	aCaseStmtNode expression accept: self.
	aCaseStmtNode cases do: [ :case | case accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
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

	anInlineNode method parseTree accept: self
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitLabeledCommentNode: aLabeledCommentNode [

	self annotateNodeState: aLabeledCommentNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitReturnNode: aReturnNode [

	self annotateNodeState: aReturnNode.

	useAsExpressionStack push: self expressionString.
	returnStack push: true -> aReturnNode.
	inExpressionStack push: self inExpressionString.

	aReturnNode expression accept: self.

	inExpressionStack pop.
	useAsExpressionStack pop.
	returnStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSendNode: aSendNode [

	aSendNode isConditionalSend ifTrue: [
		self handleConditionalSendVisit: aSendNode.
		^ self ].

	self annotateNodeState: aSendNode.

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
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

	useAsExpressionStack push: self statementString.

	stmts do: [ :stmt | stmt accept: self ].

	useAsExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	self annotateNodeState: aSwitchStatementNode.

	aSwitchStatementNode cases do: [ :case |
		| caseLabels caseStatements |
		caseLabels := case first.
		caseStatements := case second.
		caseLabels do: [ :label |
			useAsExpressionStack push: self statementString.
			label accept: self.
			useAsExpressionStack pop.

			caseStatements accept: self ] ].

	useAsExpressionStack push: self expressionString.
	inExpressionStack push: self inExpressionString.

	aSwitchStatementNode expression accept: self.
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o | o accept: self ].

	inExpressionStack pop.
	useAsExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
