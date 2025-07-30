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
		ignoredString: self isEffectivelyIgnoredInAssignmentString
]

{ #category : 'annotate' }
SLNodeAnnotatorVisitor >> addReturnInfoFor: aNode [
	"mark the given node has being inside a return expression, it doesn't mean that the node itself is the exit value
	true or false on the stack only indicate if the node is the effective value of the returning expression or not"

	self
		processValueSourceFor: aNode
		from: searchForReturnValueStack
		constantString: self returnString
		ignoredString: self isEffectivelyIgnoredInReturnString
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

{ #category : 'helpers-info-entry-string' }
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
		child nodesDo: [ :node |
			info at: node ifPresent: [ info removeKey: node ] ] ]
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfo [

	self initialize
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfoAndBranchInfoFrom: aNode [

	self cleanInfoFrom: aNode.
	self cleanBranchInfoFrom: aNode
]

{ #category : 'cleanup' }
SLNodeAnnotatorVisitor >> cleanInfoFrom: aNode [

	info removeKey: aNode 
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> copyWithoutReturn: aTMethod [

	| parseTree returns |
	parseTree := aTMethod parseTree.
	returns := parseTree allReturns.
	returns do: [ :return |
		return parent replaceChild: return with: return expression ]
]

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> deActivateCurrentSouldBePartiallyIgnored [

	currentShouldBePartiallyIgnored := false
]

{ #category : 'visiting-main-API' }
SLNodeAnnotatorVisitor >> do: aBlock visit: aNode [
	"do a block after visiting aNode, clean the info after"

	| blockResult |
	self visit: aNode.
	blockResult := aBlock value.
	self cleanInfoAndBranchInfoFrom: aNode.
	^ blockResult
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> ensureEntryInInfoDictFor: aNode [

	info at: aNode ifAbsentPut: [ IdentityDictionary new ]
]

{ #category : 'helpers-info-entry-string' }
SLNodeAnnotatorVisitor >> expressionString [

	^ #expression
]

{ #category : 'helpers-info-entry-stack-restoration' }
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
SLNodeAnnotatorVisitor >> handleConditionalSend: aSendNode [

	aSendNode isConditionalSend ifTrue: [
		self visitConditionalSend: aSendNode.
		^ true ].

	aSendNode isCppConditional ifTrue: [
		self visitCppConditional: aSendNode.
		^ true ].


	^ false
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> handleIterativeSend: aSendNode [

	aSendNode isUnaryIterativeSend ifTrue: [
		self visitUnaryIterativeSend: aSendNode.
		^ true ].

	aSendNode isUnaryIterativeSendWithImportantLastStatement ifTrue: [
		self visitUnaryIterativeSendWithImportantLastStatement: aSendNode.
		^ true ].

	aSendNode isBinaryIterativeSend ifTrue: [
		self visitBinaryIterativeSend: aSendNode.
		^ true ].

	aSendNode isDoIterativeSend ifTrue: [
		self visitDoIterativeSend: aSendNode.
		^ true ].

	^ false
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> hasEffectiveReturnValue: aNode [

	aNode nodesDo: [ :node |
		(self isEffectiveReturnValue: node) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> hasGotoOrMultipleReturn: aNode [

	| returnCounter |
	returnCounter := 0.

	^ self hasGotoOrMultipleReturn: aNode counterBlock: [ :bool |
		  bool ifTrue: [ returnCounter := returnCounter + 1 ].
		  returnCounter ]
]

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> hasGotoOrMultipleReturn: aNode counterBlock: aBlock [

	| stopToExplore returnCounter |
	aNode children reverseDo: [ :child |
		stopToExplore := child isReturn or: [ self isReturningIf: child ].
		returnCounter := aBlock value: stopToExplore.

		(child isGoTo or: [ returnCounter > 1 ]) ifTrue: [ ^ true ].
		stopToExplore ifFalse: [
			^ self hasGotoOrMultipleReturn: child counterBlock: aBlock ] ].
	^ false
]

{ #category : 'helpers-info-entry-string' }
SLNodeAnnotatorVisitor >> inExpressionString [
	"value doesn't actually matter, but the stack need elements"

	^ #inExpression
]

{ #category : 'helpers-info-entry-string' }
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

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> invalidateSearchStacksAfterReturn [
	"in an expression like a := exp1 ifTrue: [^ exp2] ifFalse: [exp3], the return node must not be simply ignored, it must correct the stacks so the exploration of exp2 does not mark nodes as used expression for  the node a := ...
	the stack for return and general expression are already being given new elements from the return node so it is not necessary to modify them"

	| top |
	searchForAssignValueStack isNotEmpty ifTrue: [
		top := searchForAssignValueStack pop.
		searchForAssignValueStack push: false -> top value ].

	searchForReturnValueStack isNotEmpty ifTrue: [
		top := searchForReturnValueStack pop.
		searchForReturnValueStack push: false -> top value ].

	searchForStmtListValue isNotEmpty ifFalse: [ ^ false ].
	top := searchForStmtListValue pop.
	searchForStmtListValue push: false -> false.

	^ top value
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

{ #category : 'testing-stack-restoration' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnoredInAssignment: aNode [
	"for stack restoration"

	^ self
		  booleanInfoFor: aNode
		  entry: self isEffectivelyIgnoredInAssignmentString
]

{ #category : 'helpers-info-entry-stack-restoration' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnoredInAssignmentString [

	^ #isEffectivelyIgnoredInAssignment
]

{ #category : 'testing-stack-restoration' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnoredInReturn: aNode [
	"for stack restoration"

	^ self
		  booleanInfoFor: aNode
		  entry: self isEffectivelyIgnoredInReturnString
]

{ #category : 'helpers-info-entry-stack-restoration' }
SLNodeAnnotatorVisitor >> isEffectivelyIgnoredInReturnString [

	^ #isEffectivelyIgnoredInReturn
]

{ #category : 'helpers-info-entry-stack-restoration' }
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

{ #category : 'testing' }
SLNodeAnnotatorVisitor >> isReturningIf: aNode [

	| isReturningIf |
	isReturningIf := aNode isConditionalSend and: [
		                 (self isEffectivelyIgnoredInReturn: aNode) or: [
			                 aNode arguments allSatisfy: [ :arg |
				                 self hasEffectiveReturnValue: arg ] ] ].

	isReturningIf := isReturningIf or: [
		                 aNode isCppConditional and: [
			                 (self isEffectivelyIgnoredInReturn: aNode) or: [
				                 aNode arguments allButFirst allSatisfy: [ :arg |
					                 self hasEffectiveReturnValue: arg ] ] ] ].

	^ isReturningIf
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> moveDownAssigningParentFrom: aNode [
	"use in inlining to put assignment down the ast : x = { ... exp} -> {x = ... exp}"

	| assignment |
	assignment := self assigningParentFor: aNode.
	assignment ifNil: [ ^ self ].

	self moveDownAssignmentFrom: assignment assignment: assignment.

	assignment parent
		replaceChild: assignment
		with: assignment expression.

	self
		visitFromBranchStartingAt: assignment
		replacement: assignment expression
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> moveDownAssignmentFrom: parentNode assignment: assignmentNode [
	"recursively go throught the ast to transfrom expression of assignment
	a = exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [a = exp] ifFalse [a = exp]"

	parentNode children do: [ :child |
		((self isEffectiveAssignmentValue: child) and: [
			 (self assigningParentFor: child) == assignmentNode ])
			ifTrue: [
				child parent replaceChild: child with: (TAssignmentNode new
						 variable: assignmentNode variable copy;
						 expression: child;
						 yourself) ]
			ifFalse: [
				self moveDownAssignmentFrom: child assignment: assignmentNode.
				(self isEffectivelyIgnoredInAssignment: child) ifTrue: [
					self
						moveDownSingleBranchConditional: child
						newBranch: (TAssignmentNode
								 variable: assignmentNode variable copy
								 expression: (TConstantNode value: 0)) ] ] ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> moveDownReturnFrom: parentNode return: returnNode [
	"recursively go throught the ast to move down returnNode
	^ exp ifTrue: [exp] ifFalse [exp] -> ifTrue: [^exp] ifFalse [^exp]"

	parentNode children do: [ :child |
		((self isEffectiveReturnValue: child) and: [
			 (self returningParentFor: child) = returnNode ])
			ifTrue: [
			child parent replaceChild: child with: child asReturnNode ]
			ifFalse: [
				child isReturn ifTrue: [ "already got a return for this branch"
					^ self ].
				self moveDownReturnFrom: child return: returnNode ] ]
]

{ #category : 'transformation' }
SLNodeAnnotatorVisitor >> moveDownReturningParentFrom: aNode [
	"use in inlining for redondant return : return {return exp} -> {return exp}"

	| returningParent |
	returningParent := self returningParentFor: aNode.
	returningParent ifNil: [ ^ self ].

	self
		moveDownReturnFrom: returningParent
		return: returningParent.

	returningParent parent
		replaceChild: returningParent
		with: returningParent expression.

	self
		visitFromBranchStartingAt: returningParent
		replacement: returningParent expression
]

{ #category : 'helpers-transformation' }
SLNodeAnnotatorVisitor >> moveDownSingleBranchConditional: aNode newBranch: anOtherNode [
	"does nothing is the node isnt a single branch conditional.
	when moving down a assignment/return in a single branch conditional, we need to consider the missing branch which Slang would have consider is the conditional was still an argument, see generateCASTIfNotNilAsArgument: for exemple and the other methods related to single conditional as arguments"

	| newSelector |
	aNode isSend ifFalse: [ ^ self ].
	aNode selector = #ifTrue: ifTrue: [ newSelector := #ifTrue:ifFalse: ].

	aNode selector = #ifFalse: ifTrue: [ newSelector := #ifFalse:ifTrue: ].

	aNode selector = #ifNotNil: ifTrue: [
		newSelector := #ifNotNil:ifNil: ].


	aNode selector = #ifNil: ifTrue: [
		newSelector := #ifNil:ifNotNil:.
		anOtherNode expression: aNode receiver ].

	newSelector ifNotNil: [
		| newArgument last |
		newArgument := TStatementListNode statements: { anOtherNode }.
		last := aNode arguments first lastNonCommentStatement.
		last isGoTo ifTrue: [ newArgument addLast: last copy ].
		aNode
			selector: newSelector;
			arguments: aNode arguments , { newArgument } ]
]

{ #category : 'helpers-accessing-info' }
SLNodeAnnotatorVisitor >> presenceInfoFor: aNode entry: aString [

	^ (info at: aNode)
		  at: aString
		  ifPresent: [ true ]
		  ifAbsent: [ false ]
]

{ #category : 'helpers-annotate' }
SLNodeAnnotatorVisitor >> processValueSourceFor: aNode from: aStack constantString: constantString ignoredString: ignoredString [

	| entry assoc isEffectivelyIgnored |
	aStack isEmpty ifTrue: [ ^ self ].

	assoc := aStack top copy.
	entry := info at: aNode.
	isEffectivelyIgnored := false.


	"searchForStmtListValue isNotEmpty ifTrue: [
		searchForStmtListValue top key ifTrue: [
			assoc := true -> assoc value ].
		searchForStmtListValue top value ifTrue: [
			isEffectivelyIgnored := true ] ]."

	currentShouldBePartiallyIgnored
		ifTrue: [
			assoc key ifTrue: [
				assoc := false -> assoc value.
				isEffectivelyIgnored := true ] ]
		ifFalse: [
			aStack pop.
			aStack push: false -> assoc value ].

	entry at: ignoredString put: isEffectivelyIgnored.
	entry at: constantString put: assoc
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

{ #category : 'helpers-stack-operation' }
SLNodeAnnotatorVisitor >> resetSearchStacksAfterReturn: hasInvalidateAStmtSearch [
	"unlike other nodes, search in statementList are from bottom to top, so after invalidating the stacks for a return exploration, we need to undo the modification done, meaning we might repush a false -> true on the stmtList stack, true indicating an active search, false indicating that the next node is not an used expression (we're waiting for a jump)"

	| top |
	hasInvalidateAStmtSearch ifFalse: [ ^ self ].

	top := searchForStmtListValue pop.
	searchForStmtListValue push: false -> true
]

{ #category : 'helpers-stack-restoration' }
SLNodeAnnotatorVisitor >> restoreInStacksFrom: aNode [

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
SLNodeAnnotatorVisitor >> restoreSearchFoGeneralValueStacksFrom: aNode [

	| entry restoredStacks |
	restoredStacks := OrderedCollection new.
	((self isEffectiveExpression: aNode) or: [
		 self isEffectivelyIgnored: aNode ]) ifTrue: [
		searchForExpressionValueStack push: true.
		restoredStacks add: searchForExpressionValueStack ].

	entry := (info at: aNode) at: self fromSearchStmtListString.
	entry ifNil: [ ^ restoredStacks ].
	entry
		ifFalse: [ searchForStmtListValue push: false -> entry ]
		ifTrue: [
			searchForStmtListValue push:
				(self topOfStack: searchForExpressionValueStack) -> entry.
			searchForExpressionValueStack isNotEmpty
				ifTrue: [ searchForExpressionValueStack pop ]
				ifFalse: [ restoredStacks add: searchForExpressionValueStack ].
			searchForExpressionValueStack push: false ].
	restoredStacks add: searchForStmtListValue.

	^ restoredStacks
]

{ #category : 'helpers-stack-restoration' }
SLNodeAnnotatorVisitor >> restoreSearchForSpecificValueStacksFrom: aNode [

	| restoredStacks |
	restoredStacks := OrderedCollection new.
	(self isInReturn: aNode) ifTrue: [
		searchForReturnValueStack push:
			((self isEffectiveReturnValue: aNode) or: [
				 self isEffectivelyIgnoredInReturn: aNode ])
			-> (self returningParentFor: aNode).
		restoredStacks add: searchForReturnValueStack ].

	(self isInAssignment: aNode) ifTrue: [
		searchForAssignValueStack push:
			((self isEffectiveAssignmentValue: aNode) or: [
				 self isEffectivelyIgnoredInAssignment: aNode ])
			-> (self assigningParentFor: aNode).
		restoredStacks add: searchForAssignValueStack ].

	^ restoredStacks
]

{ #category : 'visiting-main-API-helpers' }
SLNodeAnnotatorVisitor >> restoreStackStateFrom: aNode [
	"to just revisit a branch and not the whole AST, we need to restore the different stacks using the info dictionary"

	| restoredStacks |
	restoredStacks := OrderedCollection new.
	restoredStacks addAll: (self restoreInStacksFrom: aNode).
	restoredStacks addAll:
		(self restoreSearchForSpecificValueStacksFrom: aNode).
	restoredStacks addAll: (self restoreSearchFoGeneralValueStacksFrom: aNode).
"	1 halt."
	^ restoredStacks
]

{ #category : 'helpers-info-entry-string' }
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

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitBinaryIterativeSend: aSendNode [
	"in Slang, iterative are not considered as expression but rather as statement to be closer to C"

	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.
	searchForExpressionValueStack push: true.

	aSendNode arguments first accept: self.
	aSendNode receiver accept: self.

	searchForExpressionValueStack pop.
	inExpressionStack pop
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

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitConditionalSend: aSendNode [
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

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitConstantNode: aConstantNode [

	self annotateNodeState: aConstantNode
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitCppConditional: aSendNode [
	"conditionals are control-flow node and thus treated differently from the other sends"

	| arguments |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.

	arguments := aSendNode arguments.
	self giveStacksInfoForMultipleBranches: arguments allButFirst.

	searchForExpressionValueStack push: true.
	aSendNode receiver accept: self.
	arguments first accept: self.
	searchForExpressionValueStack pop.

	inExpressionStack pop
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitDoIterativeSend: aSendNode [
	"in Slang, iterative are not considered as expression but rather as statement to be closer to C"

	| arguments |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.
	searchForExpressionValueStack push: true.

	arguments := aSendNode arguments.
	arguments last accept: self.
	arguments allButLast do: [ :node | node accept: self ].
	aSendNode receiver accept: self.

	searchForExpressionValueStack pop.
	inExpressionStack pop
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitExitPointSend: aSendNode [

	| hasInvalidateAStmtSearch |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	hasInvalidateAStmtSearch := self invalidateSearchStacksAfterReturn.
	searchForExpressionValueStack push: true.
	self pushInExpressionStack.
	self pushInSendStack.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	searchForExpressionValueStack pop.
	inExpressionStack pop.
	inSendStack pop.
	self resetSearchStacksAfterReturn: hasInvalidateAStmtSearch
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

{ #category : 'visiting-main-API' }
SLNodeAnnotatorVisitor >> visitFromBranchStartingAt: aNode replacement: aReplacementNode [

	| restoredStacks |
	self cleanBranchInfoFrom: aNode.
	restoredStacks := self restoreStackStateFrom: aNode.
	self cleanInfoFrom: aNode.
	aReplacementNode accept: self.
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
	(aTGotoNode haveBeenMetInInlining or: [
		 searchForStmtListValue top value not ]) ifTrue: [ ^ self ].

	searchForStmtListValue top value ifTrue: [
		searchForStmtListValue pop.
		searchForStmtListValue push: true -> true ].

	self stacksForSpecificValueHolder do: [ :stack |
		stack isNotEmpty ifTrue: [
			| top |
			top := stack pop.
			stack push: true -> top value ] ]
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

	| hasInvalidateAStmtSearch |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aReturnNode.

	hasInvalidateAStmtSearch := self invalidateSearchStacksAfterReturn.
	searchForAssignValueStack isNotEmpty ifTrue: [  ].

	searchForExpressionValueStack push: true.
	searchForReturnValueStack push: true -> aReturnNode.
	self pushInExpressionStack.

	aReturnNode expression accept: self.

	inExpressionStack pop.
	searchForExpressionValueStack pop.
	searchForReturnValueStack pop.
	self resetSearchStacksAfterReturn: hasInvalidateAStmtSearch
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitSendNode: aSendNode [

	(self visitSpecialSend: aSendNode) ifTrue: [ ^ self ].

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

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitSpecialSend: aSendNode [

	(self handleConditionalSend: aSendNode) ifTrue: [ ^ true ].

	(self handleIterativeSend: aSendNode) ifTrue: [ ^ true ].

	(aSendNode selector keywords allSatisfy: [ :k |
		 #( 'value' 'value:' ) includes: k ]) ifTrue: [
		self visitValueExpansionSend: aSendNode.
		^ true ].

	aSendNode isExitPoint ifTrue: [ self visitExitPointSend: aSendNode ].

	^ false
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitStatementListNode: aStatementsListNode [

	| stmts searchForValue searchForStmtListValueEntry inUsedStmtList |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aStatementsListNode.

	stmts := aStatementsListNode statements.

	searchForStmtListValueEntry := false -> false.
	searchForStmtListValue isNotEmpty ifTrue: [
		searchForStmtListValueEntry := searchForStmtListValue top ].
	searchForValue := (self topOfStack: searchForExpressionValueStack)
		                  or: [ searchForStmtListValueEntry key ].
	"if we are going to met a goTo"
	inUsedStmtList := searchForStmtListValueEntry value or:
		                  searchForValue.

	searchForExpressionValueStack push: false.
	searchForStmtListValue push: searchForValue -> inUsedStmtList.
	stmts reverse do: [ :stmt | stmt accept: self ].

	searchForExpressionValueStack pop.
	searchForStmtListValue pop
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

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitUnaryIterativeSend: aSendNode [
	"in Slang, iterative are not considered as expression but rather as statement to be closer to C"

	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.
	searchForExpressionValueStack push: true.

	aSendNode receiver accept: self.

	searchForExpressionValueStack pop.
	inExpressionStack pop
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitUnaryIterativeSendWithImportantLastStatement: aSendNode [
	"for a 'a := [[ exp . condition ] whileTrue]' case (obtained through inlining for example), the last expression of the block is a condition not the expression value of a := ..."

	| block condition |
	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	"to not interpret the condition as the effective value, we move the condition to the top"
	block := aSendNode receiver.
	condition := block lastNonCommentStatement.
	block removeLast.
	block addAllFirstKeepingFirstComments: { condition }.

	self pushInExpressionStack.
	searchForExpressionValueStack push: true.

	aSendNode receiver accept: self.

	searchForExpressionValueStack pop.
	inExpressionStack pop.

	block removeFirstNonCommentStatement.
	block addAllLastKeepingEndComments: { condition }
]

{ #category : 'helpers-visiting' }
SLNodeAnnotatorVisitor >> visitValueExpansionSend: aSendNode [

	self activateCurrentSouldBePartiallyIgnored.
	self annotateNodeState: aSendNode.

	self pushInExpressionStack.

	searchForExpressionValueStack push: true.

	aSendNode receiver accept: self.
	aSendNode arguments do: [ :arg | arg accept: self ].

	inExpressionStack pop.

	searchForExpressionValueStack pop
]

{ #category : 'visiting' }
SLNodeAnnotatorVisitor >> visitVariableNode: aVariableNode [

	self annotateNodeState: aVariableNode
]
