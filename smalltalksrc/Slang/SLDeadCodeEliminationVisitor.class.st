Class {
	#name : 'SLDeadCodeEliminationVisitor',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'cleaning' }
SLDeadCodeEliminationVisitor >> cleanASTOf: aNode [
	"supressing an unused variable in a conditional statement can leave it empty. We can supress the conditional branch if we encounter such cases"
	aNode parent isTMethod ifTrue: [ ^self ].
	aNode parent remove: aNode.
	aNode parent children isEmpty ifTrue: [
		self cleanASTOf: aNode parent ]
]

{ #category : 'acccessing' }
SLDeadCodeEliminationVisitor >> codeGenerator [ 
	^ codeGenerator
]

{ #category : 'accessing' }
SLDeadCodeEliminationVisitor >> codeGenerator: aCodeGen [
	codeGenerator := aCodeGen
]

{ #category : 'testing' }
SLDeadCodeEliminationVisitor >> isMaybeSendWithoutSideEffect: aSendNode [

	^ aSendNode isConditionalSend or: [ aSendNode selector beginsWith: #cCoerce ]
]

{ #category : 'testing' }
SLDeadCodeEliminationVisitor >> isStructAccessorWithNoSideEffect: aSendNode [

	^ (codeGenerator isStructSend: aSendNode) and: [ aSendNode numArgs = 0 ]
]

{ #category : 'dead-code-elimimation' }
SLDeadCodeEliminationVisitor >> removeDeadCodeUsing: aCodeGen [

	codeGenerator := aCodeGen.
	codeGenerator methods do: [ :m | self visit: m parseTree ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visit: aNode [

	aNode accept: self
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitAssignmentNode: anAssignmentNode [
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitConstantNode: aConstantNode [

	self cleanASTOf: aConstantNode
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

	(self isMaybeSendWithoutSideEffect: aSendNode) ifTrue: [
		aSendNode arguments do: [ :subNode | self visit: subNode ].
		^ self ].
	(self isStructAccessorWithNoSideEffect: aSendNode) ifTrue: [
		self cleanASTOf: aSendNode ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitStatementListNode: aStatementListNode [

	aStatementListNode children do: [ :subNode |
		subNode ifNotNil: [ self visit: subNode ] ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	aSwitchStatementNode cases do: [ :case | self visit: case second ]
]

{ #category : 'visiting' }
SLDeadCodeEliminationVisitor >> visitVariableNode: aVariableNode [

	self cleanASTOf: aVariableNode
]
