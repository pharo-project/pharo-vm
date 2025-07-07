Class {
	#name : 'SLNodeAnnotatorVisitor',
	#superclass : 'Object',
	#instVars : [
		'info',
		'inExpressionStack',
		'inSendStack',
		'searchForAssignValueStack',
		'searchForReturnValueStack',
		'searchForExpressionValueStack',
		'searchForStmtListValue',
		'currentShouldBePartiallyIgnored'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> activateCurrentSouldBePartiallyIgnored [
	
	currentShouldBePartiallyIgnored := true
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addAssignmentInfoFor: aNode [
	"when an assignment has been met, the effective exitVar is not all of the nodes in it, often it is just a single node (or more if conditionals) the nodes have a link to theirs assignment
	true or nil on the stack indicate if the node is the effective exitVar"

	self
		processValueSourceFor: aNode
		from: searchForAssignValueStack
		constantString: self assignmentString
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addReturnInfoFor: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is the exit value
	true or false on the stack only indicate if the node is the effective value of the returning expression or not"

	self
		processValueSourceFor: aNode
		from: searchForReturnValueStack
		constantString: self returnString
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addToEffectiveExpressionOrNot: aNode [

	| entry isAnEffectiveExpression isEffectivelyIgnored |
	entry := info at: aNode.
	isAnEffectiveExpression := false.
	isEffectivelyIgnored := false.

	(currentShouldBePartiallyIgnored not and: [
		 (self topOfStack: searchForExpressionValueStack) or: [
			 self isEffectiveExpression: aNode ] ]) ifTrue: [
		isAnEffectiveExpression := true ].

	(searchForStmtListValue isNotEmpty and: [
		 searchForStmtListValue top key ]) ifTrue: [
		isAnEffectiveExpression := true ].

	"for stacks restoration"
	(currentShouldBePartiallyIgnored and: [
		 self topOfStack: searchForExpressionValueStack ]) ifTrue: [
		isEffectivelyIgnored := true ].

	entry at: self isEffectivelyIgnoredString put: isEffectivelyIgnored.
	entry at: self expressionString put: isAnEffectiveExpression
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addToFromSearchStmtList: aNode [
	"for stacks restoration only, indicate if we are in a statement list and if we are indicate if the statement list was a used expression"

	(info at: aNode)
		at: self fromSearchStmtListString
		put: (searchForStmtListValue isEmpty
				 ifTrue: [ nil ]
				 ifFalse: [ searchForStmtListValue top value ])
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addToInExpression: aNode [

	self
		addToInStack: aNode
		stack: inExpressionStack
		entry: self inExpressionString
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addToInSend: aNode [

	self addToInStack: aNode stack: inSendStack entry: self inSendString
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> addToInStack: aNode stack: aStack entry: aString [

	aStack isEmpty ifTrue: [ ^ self ].
	(info at: aNode) at: aString put: true
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> annotateNodeState: aNode [

	| top |
	self ensureEntryInInfoDictFor: aNode.

	self addToInExpression: aNode.
	self addToInSend: aNode.

	self addReturnInfoFor: aNode.
	self addAssignmentInfoFor: aNode.
	self addToEffectiveExpressionOrNot: aNode.

	self addToFromSearchStmtList: aNode.

	currentShouldBePartiallyIgnored ifTrue: [
		self deActivateCurrentSouldBePartiallyIgnored.
		^ self ].

	searchForStmtListValue isEmpty ifTrue: [ ^ self ].
	top := searchForStmtListValue pop.
	searchForStmtListValue push: false -> top value
]

{ #category : 'visiting-main-API-helpers' }
SLNodeAnnotatorVisitor >> assertStacksAreEmpty [

	self assert: searchForAssignValueStack isEmpty.
	self assert: searchForReturnValueStack isEmpty.
	self assert: searchForExpressionValueStack isEmpty.
	self assert: inExpressionStack isEmpty.
	self assert: inSendStack isEmpty.
	self assert: searchForStmtListValue isEmpty
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> assigningParentFor: aNode [

	^ self associationValueInfoFor: aNode entry: self assignmentString
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> assignmentString [

	^ #assignment
]

{ #category : 'helpers-accessing-info' }
SLNodeAnnotatorVisitor >> associationKeyInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :assoc | assoc key ]
		  ifAbsent: [ false ]
]

{ #category : 'helpers-accessing-info' }
SLNodeAnnotatorVisitor >> associationValueInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :assoc | assoc value ]
		  ifAbsent: [ nil ]
]

{ #category : 'helpers-accessing-info' }
SLNodeAnnotatorVisitor >> booleanInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ :bool | bool ]
		  ifAbsent: [ false ]
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanBranchInfoFrom: aNode [

	aNode children do: [ :child |
		child nodesDo: [ :node | info at: node put: IdentityDictionary new ] ]
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfoFrom: aNode [

	info at: aNode put: IdentityDictionary new
]

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> deActivateCurrentSouldBePartiallyIgnored [

	currentShouldBePartiallyIgnored := false
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> fromSearchStmtListString [
	"use for restoration only"

	^ #fromSearchStmtList
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

	self activateCurrentSouldBePartiallyIgnored.
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

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> inSendString [

	^ #inSend
]

{ #category : 'initialization' }
SLNodeAnnotatorVisitor >> initialize [

	super initialize.

	"empty, true or false on top depending of if the parent needs an expression as a dependance"
	searchForExpressionValueStack := Stack new.
	"either empty or have something on top depending if the children are in the expression of one of their parents"
	inExpressionStack := Stack new.

	"similar to inExpression but specific to send"
	inSendStack := Stack new.

	"empty or true/false -> returningParent on top depending on if the parent has found its return value or not"
	searchForReturnValueStack := Stack new.

	"empty or true/false -> assigningParent on top depending on if the parent has found its assigning value or not"
	searchForAssignValueStack := Stack new.

	"StmtList through jump can end up having multiple value point, this stack is re updated when crossing goToNode.
	it has true/false -> true/false on top depending on if we are currently searching for one of the values the second boolean indicate if the value of the stmtList is use in the first place so we do not re update the stack if not necessary"
	searchForStmtListValue := Stack new.

	"when searching for the deepest node that give the expression value, some nodes can be pass through like conditionals and stmtLists or statement only node (goTos, comments or labels)
	inactivate the search... stack"
	currentShouldBePartiallyIgnored := false.

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

{ #category : 'testing-stack-restoration' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnored: aNode [
	"for stack restoration"

	^ self booleanInfoFor: aNode entry: self isEffectivelyIgnoredString
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnoredString [

	^ #isEffectivelyIgnored
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

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isInSend: aNode [

	^ self presenceInfoFor: aNode entry: self inSendString
]

{ #category : 'helpers-accessing-info' }
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

	(searchForStmtListValue isNotEmpty and: [
		 searchForStmtListValue top key ]) ifTrue: [
		assoc := true -> assoc value ].

	currentShouldBePartiallyIgnored
		ifTrue: [ assoc := false -> assoc value ]
		ifFalse: [
			aStack pop.
			aStack push: false -> assoc value ].

	entry at: aString put: assoc
]

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> pushInExpressionStack [
	"value doesn't matter for this stack "

	inExpressionStack push: true
]

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> pushInSendStack [
	"value doesn't matter for this stack "

	inSendStack push: true
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeAssigningParentFrom: aNode [
	"use in inlining to put assignment down the ast : x = { ... exp} -> {x = ... exp}, clean all the info as a side effect, it needs to be recalculated
	answer if something was done"

	| assignment |
	assignment := self assigningParentFor: aNode.
	assignment ifNil: [ ^ false ].
	1 haltIf: [ aNode tMethod selector = #methodAReturnBlockAssignment ].

	"necessary because in inlining we switched the send node with its replacement"
	self visitFromBranchStartingAt: aNode parent.
	self transformToAssignmentFrom: assignment assignment: assignment.

	assignment parent
		replaceChild: assignment
		with: assignment expression.
	self cleanInfoFrom: assignment.

	self visitFromBranchStartingAt: assignment parent.
	^ true
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeReturningParentFrom: aNode [
	"use in inlining for redondant return : return {return exp} -> {return exp}, clean all the info as a side effect, it needs to be recalculated
	answer if anything was done"

	| returningParent |
	returningParent := self returningParentFor: aNode.
	returningParent ifNil: [ ^ false ].
	1 haltIf: [ aNode tMethod selector = #methodAReturnBlockAssignment ].
	"necessary because in inlining we switched the send node with its replacement"
	self visitFromBranchStartingAt: aNode parent.
	self transformDirectReturnFrom: returningParent.

	returningParent parent
		replaceChild: returningParent
		with: returningParent expression.
	self cleanInfoFrom: returningParent.
	
	self visitFromBranchStartingAt: returningParent parent.
	^ true
]

{ #category : 'helpers-stack-restoration' }
SLNodeAnnotatorVisitor >> restoreInSomeThingStacksFrom: aNode [

	| restoredStacks |
	restoredStacks := OrderedCollection new.
	(self presenceInfoFor: aNode entry: self inExpressionString) ifTrue: [
		self pushInExpressionStack.
		restoredStacks add: inExpressionStack ].

	(self presenceInfoFor: aNode entry: self inSendString) ifTrue: [
		self pushInSendStack.
		restoredStacks add: inSendStack ].

	^ restoredStacks
]

{ #category : 'helpers-stack-restoration' }
SLNodeAnnotatorVisitor >> restoreSearchForSimpleInfoStacksFrom: aNode [

	| restoredStacks |
	restoredStacks := OrderedCollection new.
	(self isInReturn: aNode) ifTrue: [
		searchForReturnValueStack push:
			(self isEffectiveReturnValue: aNode)
			-> (self returningParentFor: aNode).
		restoredStacks add: searchForReturnValueStack ].

	(self isInAssignment: aNode) ifTrue: [
		searchForAssignValueStack push:
			(self isEffectiveAssignmentValue: aNode)
			-> (self assigningParentFor: aNode).
		restoredStacks add: searchForAssignValueStack ].

	^ restoredStacks
]

{ #category : 'helpers-stack-restoration' }
SLNodeAnnotatorVisitor >> restoreSearchSomeThingStacksFrom: aNode [

	| entry restoredStacks |
	restoredStacks := OrderedCollection new.
	((self isEffectiveExpression: aNode) or: [
		 self isEffectivelyIgnored: aNode ]) ifTrue: [
		searchForExpressionValueStack push: true.
		restoredStacks add: searchForExpressionValueStack ].

	entry := (info at: aNode) at: self fromSearchStmtListString.
	entry ifNil: [ ^ restoredStacks ].
	searchForStmtListValue push:
		(self topOfStack: searchForExpressionValueStack) -> entry.
	searchForExpressionValueStack isNotEmpty
		ifTrue: [ searchForExpressionValueStack pop ]
		ifFalse: [ restoredStacks add: searchForExpressionValueStack ].
	searchForExpressionValueStack push: false.
	restoredStacks add: searchForStmtListValue.

	^ restoredStacks
]

{ #category : 'visiting-main-API-helpers' }
SLNodeAnnotatorVisitor >> restoreStackStateFrom: aNode [
	"to just revisit a branch and not the whole AST, we need to restore the different stacks using the info dictionary"

	| restoredStacks |
	restoredStacks := OrderedCollection new.
	restoredStacks addAll: (self restoreInSomeThingStacksFrom: aNode).
	restoredStacks addAll:
		(self restoreSearchForSimpleInfoStacksFrom: aNode).
	restoredStacks addAll: (self restoreSearchSomeThingStacksFrom: aNode).
"	1 halt."
	^ restoredStacks
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

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> topOfStack: aStack [
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
				1 haltIf: [
					child tMethod selector = #methodAReturnBlockAssignment ].
				child parent replaceChild: child with: child asReturnNode ]
			ifFalse: [
				child isReturn ifTrue: [ "already got a return for this branch"
					^ self ].
				self transformDirectReturnFrom: child ] ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> transformToAssignmentFrom: parentNode assignment: assignment [
	"recursively go throught the ast to transfrom expression of assignment
	a = exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [a = exp] ifFalse [a = exp]"

	parentNode children do: [ :child |
		((self isEffectiveAssignmentValue: child) and: [
			 (self assigningParentFor: child) == assignment ])
			ifTrue: [
				child parent replaceChild: child with: (TAssignmentNode new
						 variable: assignment variable;
						 expression: child;
						 yourself) ]
			ifFalse: [
			self transformToAssignmentFrom: child assignment: assignment ] ]
]

{ #category : 'visiting-main-API' }
SLNodeAnnotatorVisitor >> visit: aNode [

	aNode accept: self.
	self assertStacksAreEmpty
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

	self activateCurrentSouldBePartiallyIgnored.
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

{ #category : 'visiting-main-API' }
SLNodeAnnotatorVisitor >> visitFromBranchStartingAt: aNode [

	| restoredStacks |
	self cleanBranchInfoFrom: aNode.
	restoredStacks := self restoreStackStateFrom: aNode.
	self cleanInfoFrom: aNode.
	aNode accept: self.
	restoredStacks do: [ :stack | stack pop ].
	self assertStacksAreEmpty
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitGoToNode: aTGotoNode [

	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aTGotoNode.


	"goTo only comes from inlining to keep the execution flow correct where a return was.
	since inlining goes through multiple phases, static analysis may become flawed, for example :
		'a := [... methodWithReturn … b]' gives 'a = [... c . goTo l ... l ... b]' is equivalent (and should be transform to) '[ ... c . goTo l ... l ... a := b]'
		'a := methodeWithMultipleReturn' gives 'a = [... c . goTo l ... l ... b]' is equivalent (and should be transform to) '[ ... a := c . goTo l ... l ... a := b]'
	so after an inlining phases we invalidate goTo generated so that they do not 'indicate an active exit point anymore'"
	"the current implementation might be subject to bugs, the tests regardings goTo are all working properly but the AST should be invalidate AFTER an inlining phases and not during which is something we do
	so the last line should be moved"
	aTGotoNode haveBeenMetInInlining ifTrue: [ ^ self ].
	searchForStmtListValue top value ifTrue: [
		searchForStmtListValue push: true -> true ].
	aTGotoNode metInInlining
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitInlineNode: anInlineNode [

	self annotateNodeState: anInlineNode.

	anInlineNode method parseTree accept: self
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitLabeledCommentNode: aLabeledCommentNode [

	self activateCurrentSouldBePartiallyIgnored.
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
	self pushInSendStack.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	searchForExpressionValueStack pop.
	inExpressionStack pop.
	inSendStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitStatementListNode: aStatementsListNode [

	| stmts needExitValue |
	stmts := aStatementsListNode statements.
	needExitValue := self topOfStack:
		                 searchForExpressionValueStack.

	searchForExpressionValueStack push: false.
	searchForStmtListValue push: needExitValue -> needExitValue.
	stmts reverse do: [ :stmt | stmt accept: self ].

	searchForExpressionValueStack pop.
	searchForStmtListValue pop.

	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aStatementsListNode
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSwitchStatementNode: aSwitchStatementNode [

	| caseStatementsAndOtherWiseOrNilCollection |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSwitchStatementNode.

	caseStatementsAndOtherWiseOrNilCollection := aSwitchStatementNode
		                                             cases collect: [ :case |
		                                             case second ].
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o |
		caseStatementsAndOtherWiseOrNilCollection add: o ].

	self giveStacksInfoForMultipleBranches:
		caseStatementsAndOtherWiseOrNilCollection.

	searchForExpressionValueStack push: true.
	self pushInExpressionStack.

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
