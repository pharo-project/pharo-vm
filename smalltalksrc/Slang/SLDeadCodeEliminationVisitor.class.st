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

	aSendNode isConditionalSend ifTrue: [
		aSendNode arguments do: [ :subNode | self visit: subNode ].
		^ self ].
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
