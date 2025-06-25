Class {
	#name : 'SLNodeAnnotatorVisitor',
	#superclass : 'Object',
	#instVars : [
		'info',
		'inExpressionStack',
		'searchForAssignValueStack',
		'searchForReturnValueStack',
		'searchForExpressionValueStack',
		'searchForStmtListValue',
		'currentShouldBePartiallyIgnored'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addAssignmentInfoFor: aNode [
	"when an assignment has been met, the effective exitVar is not all of the nodes in it, often it is just a single node (or more if conditionals) the nodes have a link to theirs assignment
	true or nil on the stack indicate if the node is the effective exitVar"

	self
		processValueSourceFor: aNode
		from: searchForAssignValueStack
		constantString: self assignmentString
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addReturnInfoFor: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is the exit value
	true or false on the stack only indicate if the node is the effective value of the returning expression or not"

	self
		processValueSourceFor: aNode
		from: searchForReturnValueStack
		constantString: self returnString
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToEffectiveExpressionOrNot: aNode [

	| entry isAnEffectiveExpression |
	entry := info at: aNode.
	isAnEffectiveExpression := false.

	((self topOfBooleanStack: currentShouldBePartiallyIgnored) not and: [
		 (self topOfBooleanStack: searchForExpressionValueStack) or: [
			 self isEffectiveExpression: aNode ] ]) ifTrue: [
		isAnEffectiveExpression := true ].

	entry at: self expressionString put: isAnEffectiveExpression
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToInExpression: aNode [

	inExpressionStack isEmpty ifTrue: [ ^ self ].
	(info at: aNode) at: self inExpressionString put: true
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode [

	self ensureEntryInInfoDictFor: aNode.

	self addToInExpression: aNode.

	self addReturnInfoFor: aNode.
	self addAssignmentInfoFor: aNode.
	self addToEffectiveExpressionOrNot: aNode.

	(self topOfBooleanStack: currentShouldBePartiallyIgnored) ifTrue: [
		currentShouldBePartiallyIgnored pop.
		^ self ].
	(self topOfBooleanStack: searchForStmtListValue) ifFalse: [ ^ self ].
	searchForStmtListValue pop.
	searchForStmtListValue push: false
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> assigningParentFor: aNode [

	^ self associationValueInfoFor: aNode entry: self assignmentString
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> assignmentString [

	^ #exitVar
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> associationKeyInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :assoc | assoc key ]
		  ifAbsent: [ false ]
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> associationValueInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :assoc | assoc value ]
		  ifAbsent: [ nil ]
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> booleanInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :bool | bool ]
		  ifAbsent: [ false ]
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> giveStacksInfoForMultipleBranches: aCollectionOfNode [
	"re give the informations for each branch after using it"

	| tops size |
	tops := OrderedCollection new.
	size := aCollectionOfNode size.
	aCollectionOfNode doWithIndex: [ :arg :index |
		self stacksForSpecificValueHolder do: [ :stack |
			stack isEmpty ifFalse: [ tops add: stack top -> stack ] ].
		arg accept: self.
		index ~= size ifTrue: [
			tops do: [ :assoc |
				assoc value pop.
				assoc value push: assoc key ] ] ]
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> handleConditionalSendVisit: aSendNode [
	"conditionals are control-flow node and thus treated differently from the other sends"

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.

	self giveStacksInfoForMultipleBranches: aSendNode arguments.

	searchForExpressionValueStack push: true.
	aSendNode receiver accept: self.
	searchForExpressionValueStack pop.

	inExpressionStack pop
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> inExpressionString [
	"value doesn't actually matter, but the stack need elements"

	^ #inExpression
]

{ #category : 'initialization' }
SLNodeAnnotatorVisitor >> initialize [

	super initialize.

	"empty, true or false on top depending of if the parent needs an expression as a dependance"
	searchForExpressionValueStack := Stack new.
	"either empty or have somethin on top depending if the children are in the expression of one of their parents"
	inExpressionStack := Stack new.

	"empty or true/false -> returningParent on top depending of if the parent has found its return value or not"
	searchForReturnValueStack := Stack new.

	"empty or true/false -> assigningParent on top depending of if the parent has found its assigning value or not"
	searchForAssignValueStack := Stack new.

	"StmtList throught jump can end up having multiple value point, this stack is re updated when crossing goToNode and is a boolean stack"
	searchForStmtListValue := Stack new.

	"when searching for the deepest node that give the expression value, some nodes can be pass through like conditionals and stmtLists or statement only node (goTos, comments or labels)
	inactivate the search... stack"
	currentShouldBePartiallyIgnored := Stack new.

	"collect all the informations gathered for a given node"
	info := IdentityDictionary new
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isEffectiveAssignmentValue: aNode [

	^ self associationKeyInfoFor: aNode entry: self assignmentString
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isEffectiveExpression: aNode [

	^ (self isEffectiveReturnValue: aNode) or: [
		  (self isEffectiveAssignmentValue: aNode) or: [
			  self booleanInfoFor: aNode entry: self expressionString ] ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isEffectiveReturnValue: aNode [

	^ self associationKeyInfoFor: aNode entry: self returnString
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInAssignment: aNode [

	^ self presenceInfoFor: aNode entry: self assignmentString
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInExpression: aNode [

	^ self presenceInfoFor: aNode entry: self inExpressionString
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInReturn: aNode [

	^ self presenceInfoFor: aNode entry: self returnString
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> presenceInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> processValueSourceFor: aNode from: aStack constantString: aString [

	| entry assoc |
	aStack isEmpty ifTrue: [ ^ self ].

	assoc := aStack top copy.
	entry := info at: aNode.

	(self topOfBooleanStack: searchForStmtListValue) ifTrue: [
		assoc := true -> assoc value ].

	(self topOfBooleanStack: currentShouldBePartiallyIgnored)
		ifTrue: [ assoc := false -> assoc value ]
		ifFalse: [
			aStack pop.
			aStack push: false -> assoc value ].

	entry at: aString put: assoc
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> pushInExpressionStack [
	"value doesn't matter for this stack "

	inExpressionStack push: true
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeAssigningParentFrom: aSendNode [
	"use in inlining to put assignment down the ast : x = { ... exp} -> {x = ... exp}, clean all the info as a side effect, it needs to be recalculated
	answer if something was done"

	| assignment exitVar |
	exitVar := self assigningParentFor: aSendNode.
	exitVar ifNil: [ ^ false ].

	assignment := exitVar parent.
	"necessary because of the inlining hack"
	self cleanInfo.
	self visit: assignment tMethod parseTree.
	self transformToAssignmentFrom: assignment exitVar: exitVar.

	assignment parent
		replaceChild: assignment
		with: assignment expression.

	self cleanInfo.
	^ true
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeReturningParentFrom: aSendNode [
	"use in inlining for redondant return : return {return exp} -> {return exp}, clean all the info as a side effect, it needs to be recalculated
	answer if anything was done"

	| returningParent |
	(self isEffectiveReturnValue: aSendNode) ifFalse: [ ^ false ].

	returningParent := self returningParentFor: aSendNode.
	"necessary because of the inlining hack"
	self cleanInfo.
	self visit: returningParent tMethod parseTree.
	self transformDirectReturnFrom: returningParent.

	returningParent parent
		replaceChild: returningParent
		with: returningParent expression.

	self cleanInfo.
	^ true
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> returnString [

	^ #return
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> returningParentFor: aNode [

	^ self associationValueInfoFor: aNode entry: self returnString
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> stacksForSpecificValueHolder [

	^ {
		  searchForAssignValueStack.
		  searchForReturnValueStack }
]

{ #category : 'helpers' }
SLNodeAnnotatorVisitor >> topOfBooleanStack: aStack [
	"return the top value of a boolean stack"

	^ aStack isNotEmpty and: [ aStack top ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformDirectReturnFrom: parentNode [
	"recursively go throught the ast to transfrom directReturn
	^ exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [^exp] ifFalse [^exp]"

	parentNode children do: [ :child |
		(self isEffectiveReturnValue: child)
			ifTrue: [
			child parent replaceChild: child with: child asReturnNode ]
			ifFalse: [
				child isReturn ifTrue: [ "already got a return for this branch"
					^ self ].
				self transformDirectReturnFrom: child ] ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformToAssignmentFrom: parentNode exitVar: exitVar [
	"recursively go throught the ast to transfrom expression of assignment
	a = exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [a = exp] ifFalse [a = exp]"

	parentNode children do: [ :child |
		(self assigningParentFor: child) == exitVar
			ifTrue: [
				child parent replaceChild: child with: (TAssignmentNode new
						 variable: exitVar;
						 expression: child;
						 yourself) ]
			ifFalse: [ self transformToAssignmentFrom: child exitVar: exitVar ] ]
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visit: aNode [

	aNode accept: self.
	self assert: searchForAssignValueStack isEmpty.
	self assert: searchForReturnValueStack isEmpty.
	self assert: searchForExpressionValueStack isEmpty.
	self assert: inExpressionStack isEmpty.
	self assert: searchForStmtListValue isEmpty
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitAssignmentNode: anAssignmentNode [

	self annotateNodeState: anAssignmentNode.

	searchForExpressionValueStack push: true.
	self pushInExpressionStack.

	searchForAssignValueStack push: true -> anAssignmentNode.

	anAssignmentNode expression accept: self.
	anAssignmentNode variable accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop.

	searchForAssignValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitBraceCaseNode: aTBraceCaseNode [
	"shouldn't be reachable in real condition, TBraceCaseNode are translated to switch before going through any operation.
	it can be reach throught tests as a side effect since inlining goes for all knowned methods in the codeGenerator even if they are not the tests focuss"

	
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitCaseStatementNode: aCaseStmtNode [

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aCaseStmtNode.

	searchForExpressionValueStack push: true.
	inExpressionStack push: true.

	self giveStacksInfoForMultipleBranches: aCaseStmtNode cases.
	aCaseStmtNode expression accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitConstantNode: aConstantNode [

	self annotateNodeState: aConstantNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitGoToNode: aTGotoNode [

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aTGotoNode.

	aTGotoNode haveBeenMetInInlining ifTrue: [ ^ self ].
	searchForStmtListValue pop.
	searchForStmtListValue push: true.
	aTGotoNode metInInlining
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitInlineNode: anInlineNode [

	self annotateNodeState: anInlineNode.

	anInlineNode method parseTree accept: self
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitLabeledCommentNode: aLabeledCommentNode [

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aLabeledCommentNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitReturnNode: aReturnNode [

	self annotateNodeState: aReturnNode.
	
	"line might be unecessary"
	searchForExpressionValueStack push: true.
	searchForReturnValueStack push: true -> aReturnNode.
	self pushInExpressionStack.

	aReturnNode expression accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop.
	searchForReturnValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSendNode: aSendNode [

	aSendNode isConditionalSend ifTrue: [
		self handleConditionalSendVisit: aSendNode.
		^ self ].

	self annotateNodeState: aSendNode.

	searchForExpressionValueStack push: true.
	self pushInExpressionStack.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	searchForExpressionValueStack pop.
	inExpressionStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitStatementListNode: aStatementsListNode [

	| stmts needExitValue |
	stmts := aStatementsListNode statements.
	needExitValue := self topOfBooleanStack:
		                 searchForExpressionValueStack.

	searchForExpressionValueStack push: false.
	searchForStmtListValue push: needExitValue.
	stmts reverse do: [ :stmt | stmt accept: self ].

	searchForExpressionValueStack pop.
	searchForStmtListValue pop.

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aStatementsListNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	| caseStatementsAndOtherWiseOrNilCollection |
	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aSwitchStatementNode.

	caseStatementsAndOtherWiseOrNilCollection := aSwitchStatementNode
		                                             cases collect: [ :case |
		                                             case second ].
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o |
		caseStatementsAndOtherWiseOrNilCollection add: o ].

	searchForExpressionValueStack push: true.
	self pushInExpressionStack.
	self giveStacksInfoForMultipleBranches:
		caseStatementsAndOtherWiseOrNilCollection.

	aSwitchStatementNode cases do: [ :case |
		| caseLabels |
		caseLabels := case first.

		caseLabels do: [ :label | label accept: self ] ].


	aSwitchStatementNode expression accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
