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
		constantString: self exitVarString
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

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> effectiveExpressionValueSet [

	| expressions |
	expressions := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifTrue: [
			expressions add: assoc key ] ].
	^ expressions
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> exitVarString [

	^ #exitVar
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> getAssigningVariableFor: aNode [

	| assignmentNode |
	assignmentNode := (info at: aNode)
		                  at: self exitVarString
		                  ifAbsent: [ nil ].
	(assignmentNode isNil or: [ assignmentNode key not ]) ifTrue: [
		^ nil ].
	^ assignmentNode value
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
	"conditionals are handle a bit like they would be in C, they are control-flow node"

	inExpressionStack push: true.

	self giveStacksInfoForMultipleBranches: aSendNode arguments.

	aSendNode receiver accept: self.

	inExpressionStack pop.

	currentShouldBePartiallyIgnored push: true.
	self annotateNodeState: aSendNode
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
	"either empty or have true on top depending if the children are in the expression of one of their parents"
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
SLNodeAnnotatorVisitor >> isDirectReturn: aNode [

	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc key ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isEffectiveExpression: aNode [

	^ (self isDirectReturn: aNode) or: [ (self getAssigningVariableFor: aNode) isNotNil ]
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

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> nonEffectiveExpressionOrStatementSet [

	| statements |
	statements := IdentitySet new.
	info associationsDo: [ :assoc |
		(assoc value at: self expressionString) ifFalse: [
			statements add: assoc key ] ].
	^ statements
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

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> removeAssigningParentFrom: aSendNode [
	"use in inlining to put assignment down the ast : x = { ... exp} -> {x = ... exp}, clean all the info as a side effect, it needs to be recalculated
	answer if something was done"

	| assignment exitVar |
	exitVar := self getAssigningVariableFor: aSendNode.
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
	(self isDirectReturn: aSendNode) ifFalse: [ ^ false ].

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
	"if the node is in a return give the returningParent even if the node is not the exitvalue itself"
	^ (info at: aNode)
		  at: self returnString
		  ifPresent: [ :assoc | assoc value ]
		  ifAbsent: [ nil ]
]

{ #category : 'accessing' }
SLNodeAnnotatorVisitor >> stacksForSpecificValueHolder [

	^ {
		  searchForAssignValueStack.
		  searchForReturnValueStack }
]

{ #category : 'helpers-string-constant' }
SLNodeAnnotatorVisitor >> statementString [

	^ #statement
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
		(self isDirectReturn: child)
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
		(self getAssigningVariableFor: child) == exitVar
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
	inExpressionStack push: true.

	searchForAssignValueStack push: true -> anAssignmentNode variable.

	anAssignmentNode expression accept: self.
	anAssignmentNode variable accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop.

	searchForAssignValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitBraceCaseNode: aTBraceCaseNode [
	"shouldn't be reachable in real condition, TBraceCaseNode are translated to switch before going throught any operation.
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

	searchForExpressionValueStack push: true.
	searchForReturnValueStack push: true -> aReturnNode.
	inExpressionStack push: true.

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
	inExpressionStack push: true.

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

	caseStatementsAndOtherWiseOrNilCollection := OrderedCollection new.
	caseStatementsAndOtherWiseOrNilCollection := aSwitchStatementNode
		                                             cases collect: [ :case |
		                                             case second ].
	aSwitchStatementNode otherwiseOrNil ifNotNil: [ :o |
		caseStatementsAndOtherWiseOrNilCollection add: o ].

	searchForExpressionValueStack push: true.
	inExpressionStack push: true.
	self giveStacksInfoForMultipleBranches:
		caseStatementsAndOtherWiseOrNilCollection.

	aSwitchStatementNode cases do: [ :case |
		| caseLabels |
		caseLabels := case first.

		caseLabels do: [ :label |
			searchForExpressionValueStack push: false.
			label accept: self.
			searchForExpressionValueStack pop ] ].


	aSwitchStatementNode expression accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
