Class {
	#name : 'SLDeadCodeEliminationVisitor',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'accessing' }
SLDeadCodeEliminationVisitor >> codeGenerator [ 
	^ codeGenerator
]

{ #category : 'accessing' }
SLDeadCodeEliminationVisitor >> codeGenerator: aCodeGen [
	codeGenerator := aCodeGen
]

{ #category : 'helper' }
SLDeadCodeEliminationVisitor >> handleIterativeAndConditionalSend: aSendNode [
	"return true if the node has been visited"

	(aSendNode isConditionalSend or: [ aSendNode isBinaryIterativeSend ])
		ifTrue: [
			| receiver |
			receiver := aSendNode receiver.
			(receiver isStatementList and: [ receiver statements size > 1 ])
				ifTrue: [ self visitStatementListNodeExceptLast: receiver ].
			aSendNode arguments do: [ :subNode | self visit: subNode ].
			^ true ].
	aSendNode isDoIterativeSend ifTrue: [
		self visit: (aSendNode arguments at: 3) ].
	aSendNode isUnaryIterativeSend ifTrue: [
		self visit: aSendNode receiver.
		^ true ].

	aSendNode isUnaryIterativeSendWithImportantLastStatement ifTrue: [
		self visitStatementListNodeExceptLast: aSendNode receiver.
		^ true ].
	
	^ false
]

{ #category : 'testing' }
SLDeadCodeEliminationVisitor >> isStructAccessorWithNoSideEffect: aSendNode [

	^ (codeGenerator isStructSend: aSendNode) and: [ aSendNode numArgs = 0 ]
]

{ #category : 'dead-code-elimination' }
SLDeadCodeEliminationVisitor >> removeDeadCodeUsing: aCodeGen [

	codeGenerator := aCodeGen.
	codeGenerator methods do: [ :m |
		codeGenerator currentMethod: m.
		self visit: m parseTree ]
]

{ #category : 'cleaning' }
SLDeadCodeEliminationVisitor >> removeUnusedNodesInBranch: aNode [
	"supressing an unused expression can leave the parent empty, the method will recursively try to supress empty node "

	aNode parent removeUnusedNodesInBranch: aNode
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visit: aNode [

	aNode accept: self
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitAssignmentNode: anAssignmentNode [
	"handle assignement that end up being assignement to itself"

	| var expr |
	var := anAssignmentNode variable.
	expr := anAssignmentNode expression.
	"var := var"
	(anAssignmentNode variable isSameAs: expr) ifTrue: [
		self removeUnusedNodesInBranch: anAssignmentNode ].

	"a node like var := [ :arg | self method:arg. arg ] value: var -> [ :arg | self method:arg ] value: var,
					 var := [ :arg :arg2 | self method:arg. self method:arg2. arg2 ] value: var2 value: var -> [ :arg :arg2 | self method:arg. self method:arg2 ] value: var2 value: var"
	(expr isSend and: [ expr isValueExpansion ]) ifTrue: [ "check if var is in the arguments of the value: selector and its place in it"
		expr arguments doWithIndex: [ :arg :index |
			(arg isSameAs: var) ifTrue: [
				| lastStmt |
				"expr receiver is the block"
				lastStmt := expr receiver lastNonCommentStatement.
				"check if lastStmt is the arguments which has the value of var"
				(lastStmt isVariable and: [
					 lastStmt name = (expr receiver arguments at: index) ]) ifTrue: [ "directly replace the assignement by the block itself and remove the variable at the end of the block"
					anAssignmentNode parent replaceChild: anAssignmentNode with: expr.
					self removeUnusedNodesInBranch: lastStmt ] ] ] ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitCaseStatementNode: aCaseStatementNode [
	"nothing for now"
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitConstantNode: aConstantNode [

	self removeUnusedNodesInBranch: aConstantNode
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitGoToNode: aGoToNode [
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitInlineNode: anInlineNode [
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitLabeledCommentNode: aLabeledCommentNode [
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitReturnNode: aReturnNode [
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitSendNode: aSendNode [

	(self handleIterativeAndConditionalSend: aSendNode) ifTrue: [ ^ self ].

	(aSendNode selector beginsWith: #cCoerce) ifTrue: [
		self visit: aSendNode arguments first.
		^ self ].

	(self isStructAccessorWithNoSideEffect: aSendNode) ifTrue: [
		self removeUnusedNodesInBranch: aSendNode ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitStatementListNode: aStatementListNode [

	aStatementListNode children do: [ :subNode | self visit: subNode ]
]

{ #category : 'helper' }
SLDeadCodeEliminationVisitor >> visitStatementListNodeExceptLast: aStatementListNode [
	"useful for whileTrue as the last statements is actually not dead code and for whileTrue: as the receiver might be a statements list"

	| statements |
	statements := aStatementListNode children.

	statements size < 2 ifTrue: [
		self removeUnusedNodesInBranch: aStatementListNode ].

	1 to:
	(statements indexOf: aStatementListNode lastNonCommentStatement) - 1
	do: [ :i | self visit: (statements at: i) ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	aSwitchStatementNode cases do: [ :case | self visit: case second ].
	aSwitchStatementNode otherwiseOrNil ifNil: [ ^ self ].
	self visit: aSwitchStatementNode otherwiseOrNil
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitVariableNode: aVariableNode [
	self removeUnusedNodesInBranch: aVariableNode
]
