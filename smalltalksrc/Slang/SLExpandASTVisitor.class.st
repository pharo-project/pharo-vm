Class {
	#name : 'SLExpandASTVisitor',
	#superclass : 'Object',
	#instVars : [
		'translationDictionary',
		'currentTMethod'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'acccessing' }
SLExpandASTVisitor >> currentMethod: aTMethod [

	currentTMethod := aTMethod
]

{ #category : 'transformation' }
SLExpandASTVisitor >> expandASTInCurrentMethod [

	self visit: currentTMethod parseTree
]

{ #category : 'initialization' }
SLExpandASTVisitor >> initTranslationDictionary [
	
	| pairs |
	translationDictionary  := Dictionary new.
	pairs := #( 
		f:printf: #expandPrintfIn:
		
		#value: #expandASTIn:
		#value:value: #expandASTIn:
		#value:value:value: #expandASTIn:
		#value:value:value:value: #expandASTIn:
		#value:value:value:value:value: #expandASTIn:
		#value:value:value:value:value:value: #expandASTIn:
	).
	
	1 to: pairs size by: 2 do: [:i |
		translationDictionary at: (pairs at: i) put: (pairs at: i + 1)].
]

{ #category : 'initialization' }
SLExpandASTVisitor >> initialize [ 
	super initialize .
	self initTranslationDictionary
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visit: aNode [
	aNode accept: self
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitAssignmentNode: anAssignmentNode [

	anAssignmentNode expandASTIn: currentTMethod.

	self visit: anAssignmentNode expression.
	self visit: anAssignmentNode variable
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitCaseStatementNode: aCaseStatementNode [

	self visit: aCaseStatementNode expression.
	aCaseStatementNode cases do: [ :case | self visit: case ]
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitConstantNode: aConstantNode [
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitGoToNode: aGotoNde [
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitInlineNode: anInlineNode [

	self visit: anInlineNode method parseTree
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitLabeledCommentNode: aLabeledCommentNode [
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitReturnNode: aReturnNode [

	self visit: aReturnNode expression
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitSendNode: aSendNode [

	| action |
	action := translationDictionary
		          at: aSendNode selector
		          ifAbsent: [ nil ].
	aSendNode arguments do: [ :arg | self visit: arg ].
	action ifNotNil: [ aSendNode perform: action with: currentTMethod ]
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitStatementListNode: aStatementListNode [

	aStatementListNode statements do: [ :stmt | self visit: stmt ]
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitSwitchStatementNode: aSwitchStatmentNode [

	self visit: aSwitchStatmentNode expression.
	aSwitchStatmentNode cases do: [ :cases | self visit: cases second ]
]

{ #category : 'visiting' }
SLExpandASTVisitor >> visitVariableNode: aVariableNode [

	
]
