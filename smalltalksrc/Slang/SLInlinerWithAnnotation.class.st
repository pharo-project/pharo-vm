Class {
	#name : 'SLInlinerWithAnnotation',
	#superclass : 'SLAbstractInlineStrategy',
	#instVars : [
		'currentMethod',
		'sLNodeAnnotatorVisitor',
		'sendsForInlining',
		'conditionalForInlining',
		'performSendForInlining'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'transformation' }
SLInlinerWithAnnotation >> addBeginAndEndCommentsFor: aTStatementList selector: aSelector exitLabel: aLabel [

	aTStatementList addFirst:
		(TLabeledCommentNode new setComment: 'begin ' , aSelector).
	aLabel
		ifNotNil: [
			aTStatementList addLast:
				(TLabeledCommentNode new
					 setLabel: aLabel
					 comment: 'end ' , aSelector) ]
		ifNil: [
			aTStatementList addLast:
				(TLabeledCommentNode new setComment: 'end ' , aSelector) ]
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> addToConditionalInlining: aSendNode [

	| indexesToRemove |
	(self isInlineableConditional: aSendNode) ifFalse: [ ^ self ].

	indexesToRemove := OrderedCollection new.
	sendsForInlining doWithIndex: [ :dictionary :index |
		(dictionary values includes: aSendNode receiver) ifTrue: [
			indexesToRemove add: index ] ].

	sendsForInlining := sendsForInlining reject: [ :dictionary |
		                    dictionary values includes: aSendNode receiver ].

	sendsForInlining add: (IdentityDictionary new
			 at: self conditionalInliningString put: aSendNode;
			 yourself)
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> addToPerformSendlInlining: aSendNode from: anOtherSendNode [

	sendsForInlining add: (IdentityDictionary new
			 at: self functionCallFromBuitinInliningString
			 put: anOtherSendNode -> aSendNode;
			 yourself)
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> addToSendlInlining: aSendNode [

	sendsForInlining add: (IdentityDictionary new
			 at: self functionCallInliningString put: aSendNode;
			 yourself)
]

{ #category : 'preparation' }
SLInlinerWithAnnotation >> annotateCurrentMethod [

	sLNodeAnnotatorVisitor cleanInfo.
	sLNodeAnnotatorVisitor visit: currentMethod parseTree
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> argAssignmentsFor: meth send: aSendNode except: elidedArgs [
	"Return a collection of assignment nodes that assign the given argument expressions to the formal parameter variables of the given method."

	"Optimization: If the actual parameters are either constants or local variables in the target method (the receiver), substitute them directly into the body of meth. Note that global variables cannot be subsituted because the inlined method might depend on the exact ordering of side effects to the globals."

	| stmtList substitutionDict argList |
	meth args size > (argList := aSendNode arguments) size ifTrue: [
		self assert: (meth args first beginsWith: 'self_in_').
		argList := { aSendNode receiver } , aSendNode arguments ].

	stmtList := OrderedCollection new: argList size.
	substitutionDict := Dictionary new: argList size.
	meth args with: argList do: [ :argName :exprNode |
		(currentMethod
			 isNode: exprNode
			 substitutableFor: argName
			 inMethod: meth
			 in: codeGenerator)
			ifTrue: [
				substitutionDict at: argName put: (codeGenerator
						 node: exprNode
						 typeCompatibleWith: argName
						 inliningInto: meth
						 in: currentMethod).

				currentMethod
					removeLocal: argName
					ifAbsent: [ self assert: (argName beginsWith: 'self_in_') ].
				currentMethod declarations removeKey: argName ifAbsent: nil ]
			ifFalse: [ "Add an assignment for anything except an unused self_in_foo argument"
				(elidedArgs includes: argName) ifFalse: [
					stmtList addLast: (TAssignmentNode new
							 setVariable: (TVariableNode new setName: argName)
							 expression: (codeGenerator
									  node: exprNode copy
									  typeCompatibleWith: argName
									  inliningInto: meth
									  in: currentMethod)) ] ] ].

	meth parseTree addAllFirst: stmtList.
	^ substitutionDict
]

{ #category : 'preparation-function-call-string' }
SLInlinerWithAnnotation >> builtinString [

	^ #builtinString
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> canBeInlineInExpression: aNode replacement: aTMethod [
	"for now"

	| parseTree |
	(sLNodeAnnotatorVisitor isInSend: aNode) ifFalse: [ ^ true ].
	parseTree := aTMethod parseTree.
	^ sLNodeAnnotatorVisitor
		  do: [
		  (sLNodeAnnotatorVisitor hasGotoOrMultipleReturn: parseTree) not ]
		  visit: parseTree
]

{ #category : 'testing-method' }
SLInlinerWithAnnotation >> checkForCompletenessFor: aTMethod [
	"Set the complete flag if the parse tree contains no further candidates for inlining."

	| foundIncompleteSend stmtsForInlining |
	codeGenerator maybeBreakForTestOfInliningOf: aTMethod selector.
	stmtsForInlining := self statementsListsForInliningInCurrentMethod.
	self fillSendForInliningInCurrentMethod.
	(sendsForInlining isNotEmpty or: [ stmtsForInlining isNotEmpty ])
		ifTrue: [ ^ self ].
	foundIncompleteSend := false.


	aTMethod parseTree
		nodesDo: [ :node |
			(node isSend and: [ node selector ~= currentMethod selector ])
				ifTrue: [
					(aTMethod
						 methodIsEffectivelyComplete: node selector
						 in: codeGenerator) ifFalse: [ foundIncompleteSend := true ] ] ]
		unless: [ :node |
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					codeGenerator isAssertSelector: node selector ] ] ].
	foundIncompleteSend ifFalse: [ aTMethod complete: true ]
]

{ #category : 'testing-method' }
SLInlinerWithAnnotation >> checkForFlagIn: aTStatementList [

	(aTStatementList sizeWithoutComments > 1 and: [
		|firstStatement|
		firstStatement := aTStatementList firstNonCommentStatement.
firstStatement isSend and: [
			 firstStatement selector == #flag: ] ])
		ifTrue: [ aTStatementList removeFirstNonCommentStatement ]
]

{ #category : 'accessing' }
SLInlinerWithAnnotation >> codeGenerator [

	^ codeGenerator
]

{ #category : 'preparation-function-call-string' }
SLInlinerWithAnnotation >> conditionalInliningString [

	^ #conditionalInliningString
]

{ #category : 'accessing' }
SLInlinerWithAnnotation >> currentMethod [

	^ currentMethod
]

{ #category : 'accessing' }
SLInlinerWithAnnotation >> currentMethod: aTMethod [

	currentMethod := aTMethod
]

{ #category : 'inlining' }
SLInlinerWithAnnotation >> doInliningIn: aTMethod [

	self currentMethod: aTMethod.
	^ self tryToInlineMethodsInCurrentMethod
]

{ #category : 'preparation' }
SLInlinerWithAnnotation >> ensureConditionalAssignmentsAreTransformedInCurrentMethod [
	"Make passes transforming
		foo := expr ifTrue: [a] ifFalse: [b]
	 into
		expr ifTrue: [foo := a] ifFalse: [foo := b]
	 until no such instances exist in the tree.  This is needed for correct inlining
	 given the limitations of inlineCodeOrNilForStatement:returningNodes:in:"

	| transformedAssignments |
	[
	transformedAssignments := Dictionary new.
	currentMethod parseTree
		nodesDo: [ :node |
			(self transformConditionalAssignment: node) ifNotNil: [
				:replacement | transformedAssignments at: node put: replacement ] ]
		unless: [ :node | "Don't inline the arguments to asserts to keep the asserts readable"
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					codeGenerator isAssertSelector: node selector ] ] ].
	transformedAssignments notEmpty and: [
		currentMethod replaceNodesIn: transformedAssignments.
		true ] ] whileTrue
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> fillConditionalSendOrTryPerformSearchForInlining: aNode transformedConstantFrom: originalNodeForVisitorInfo [

	aNode asTransformedConstantPerform
		ifNil: [ self addToConditionalInlining: aNode ]
		ifNotNil: [ :node | "when going through transformation, the new node n take the place of aNode but not in the visitor so we keep track of the old node "
			self
				fillSendForInlining: node
				transformedConstantFrom: originalNodeForVisitorInfo ]
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> fillSendForInlining: aNode [

	^ self fillSendForInlining: aNode transformedConstantFrom: nil
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> fillSendForInlining: aNode transformedConstantFrom: anOtherNodeOrNil [
	"Answer if the given send node is a call to a 'functional' method--a method whose body is a single return statement of some expression and whose actual parameters can all be directly substituted.
	if a method is marked as always inlined and complete, the method also returns true"

	| originalNodeForVisitorInfo tMethod |
	codeGenerator maybeBreakForTestToInline: aNode in: self.
	aNode isSend ifFalse: [ ^ false ].

	originalNodeForVisitorInfo := anOtherNodeOrNil
		                              ifNil: [ aNode ]
		                              ifNotNil: [ anOtherNodeOrNil ].
	tMethod := codeGenerator methodNamed: aNode selector.
	tMethod ifNil: [
		self
			fillConditionalSendOrTryPerformSearchForInlining: aNode
			transformedConstantFrom: originalNodeForVisitorInfo.
		^ self ].
	self
		fillSendOrPerformSendForInlining: aNode
		method: tMethod
		transformedConstantFrom: originalNodeForVisitorInfo
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> fillSendForInliningInCurrentMethod [

	sendsForInlining := OrderedCollection new.

	currentMethod parseTree
		nodesDo: [ :node | self fillSendForInlining: node ]
		unless: [ :node | "Don't inline the arguments to asserts to keep the asserts readable"
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					codeGenerator isAssertSelector: node selector ] ] ]
]

{ #category : 'preparation-function-call' }
SLInlinerWithAnnotation >> fillSendOrPerformSendForInlining: aNode method: aTMethod transformedConstantFrom: originalNodeForVisitorInfo [

	| isInlineableSend |
	isInlineableSend := (aTMethod ~~ currentMethod and: [
		                     ((self isFunctional: aTMethod) or: [
			                      aTMethod mustBeInlined and: [
				                      aTMethod isComplete ] ]) and: [
			                     aTMethod mayBeInlined and: [
				                     (codeGenerator mayInline: aTMethod selector)
					                     and: [
						                     (aNode arguments allSatisfy: [ :a |
							                      self
								                      isSubstitutableNode: a
								                      intoMethod: aTMethod ]) and: [
							                     self
								                     canBeInlineInExpression:
								                     originalNodeForVisitorInfo
								                     replacement: aTMethod ] ] ] ] ]) or: [
		                    aTMethod checkForRequiredInlinability ].
	isInlineableSend ifFalse: [ ^ self ].
	aNode == originalNodeForVisitorInfo
		ifTrue: [ self addToSendlInlining: aNode ]
		ifFalse: [
			self
				addToPerformSendlInlining: aNode
				from: originalNodeForVisitorInfo ]
]

{ #category : 'preparation-statement' }
SLInlinerWithAnnotation >> filterStmtForInliningIn: tStmtListNodeLists [

	| stmtsList |
	stmtsList := OrderedCollection new.
	tStmtListNodeLists do: [ :tStmtList |
		tStmtList statements do: [ :stmt |
			| expression |
			expression := stmt.
			(stmt isReturn or: [ stmt isAssignment ]) ifTrue: [
				expression := stmt expression ].

			(self isInlineableSend: expression) ifTrue: [
				stmtsList add: expression ] ] ].

	^ stmtsList
]

{ #category : 'preparation-function-call-string' }
SLInlinerWithAnnotation >> functionCallFromBuitinInliningString [

	^ #functionCallFromBuitinInliningString
]

{ #category : 'preparation-function-call-string' }
SLInlinerWithAnnotation >> functionCallInliningString [

	^ #functionCallInliningString
]

{ #category : 'initialization' }
SLInlinerWithAnnotation >> initialize [

	super initialize.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor new
]

{ #category : 'conditional' }
SLInlinerWithAnnotation >> inlineConditional: aSendNode [
	"If possible answer the inlining of a conditional, otherwise answer nil.
	 Currently the only pattern we support is
		aSend ifTrue:/ifFalse: [...]
	 where aSend is marked inline and always answers booleans."

	self assert: (self isInlineableConditional: aSendNode).
	self assert: aSendNode arguments first isStatementList.
	^ (aSendNode arguments first sizeWithoutComments = 1 and: [
		   aSendNode arguments first lastNonCommentStatement isReturn ])
		  ifTrue: [ self inlineReturningConditional: aSendNode ]
		  ifFalse: [ self inlineGuardingConditional: aSendNode ]
]

{ #category : 'conditional' }
SLInlinerWithAnnotation >> inlineConditionalGuardingOrConditionalInit: aSendNode isGuarding: isGuarding [
	"init data for inlining conditional"

	| data |
	self assert: currentMethod == codeGenerator currentMethod.
	self assert: (self isInlineableConditional: aSendNode).
	codeGenerator maybeBreakForInlineOf: aSendNode in: self.

	data := Dictionary new.
	data at: #isIfTrue put: aSendNode selector = #ifTrue:.

	data
		at: #method
		put: (codeGenerator methodNamed: aSendNode receiver selector) copy.

	self
		inlineFunctionCall: aSendNode receiver
		inInlineableConditional: true.

	data at: #returnReplacement put: (isGuarding
			 ifTrue: [
				 TLabeledCommentNode new setLabel:
					 (currentMethod unusedLabelForInlining: (data at: #method)) ]
			 ifFalse: [ aSendNode arguments first ]).

	^ data
]

{ #category : 'function-call' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode [

	^ self
		  inlineFunctionCall: aSendNode
		  inInlineableConditional: false
		  fromBuiltin: nil
]

{ #category : 'function-call' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode fromBuiltin: aNOdeOrNil [

	^ self
		  inlineFunctionCall: aSendNode
		  inInlineableConditional: false
		  fromBuiltin: aNOdeOrNil
]

{ #category : 'function-call' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode inInlineableConditional: aBoolean [

	^ self
		  inlineFunctionCall: aSendNode
		  inInlineableConditional: aBoolean
		  fromBuiltin: nil
]

{ #category : 'function-call' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode inInlineableConditional: aBoolean fromBuiltin: aNodeOrNil [
	"Answer the body of the called function, substituting the actual
	 parameters for the formal argument variables in the method body.
	 Assume caller has established that:
		1. the method arguments are all substitutable nodes, and
		2. the method to be inlined contains no additional embedded returns."

	| selector meth parametersToReplaceByArgument argsForInlining substitutionDict parseTree |
	selector := aSendNode selector.
	meth := (codeGenerator methodNamed: selector) copy.

	parseTree := meth parseTree.
	parametersToReplaceByArgument := Set withAll: currentMethod args.
	argsForInlining := aSendNode argumentsForInliningCodeGenerator:
		                   codeGenerator.
	meth args with: argsForInlining do: [ :argName :exprNode |
		exprNode isLeaf ifTrue: [
			parametersToReplaceByArgument add: argName ] ].
	self checkForFlagIn: parseTree.

	self
		renameVarsAndLabelsForInliningIntoCurrentMethodOf: meth
		except: parametersToReplaceByArgument.

	substitutionDict := Dictionary new: meth args size * 2.
	meth args with: argsForInlining do: [ :argName :exprNode |
		substitutionDict at: argName put: exprNode.
		(parametersToReplaceByArgument includes: argName) ifFalse: [
			currentMethod removeLocal: argName ] ].
	parseTree bindVariablesIn: substitutionDict.
	"copyWithoutReturn does it implictly, avoid duplicating them and in addition if meth end up in an expressionList, they won't appear which might cause bug,
	see asCASTIn: vs asCASTExpressionIn: for stmtList.
	"
	meth locals: Set new.
	aBoolean ifFalse: [ SLNodeAnnotatorVisitor copyWithoutReturn: meth ].

	"same 'optimization' as before but with comments if possible"
	(parseTree children size = 1 and: [ aBoolean not ])
		ifTrue: [
			meth parseTree: parseTree last.
			parseTree := parseTree last ]
		ifFalse: [
			self
				addBeginAndEndCommentsFor: parseTree
				selector: selector
				exitLabel: nil ].

	"visiting is done just after"
	aBoolean ifTrue: [
		aSendNode parent replaceChild: aSendNode with: parseTree.
		^ self ].
	sLNodeAnnotatorVisitor
		visitFromBranchStartingAt: (aNodeOrNil ifNil: [ aSendNode ])
		replacement: parseTree
]

{ #category : 'conditional' }
SLInlinerWithAnnotation >> inlineGuardingConditional: aSendNode [
	"Inline
		aSend ifTrue:/ifFalse: [statements]
	 where aSend is inlineable and always answers booleans.  We convert
	 the boolean returns in aSend to jumps."

	| data evaluateIfTrue replacementTree map lastNode evaluateLabel skipLabel selector inlineStmts skipLabelStmt |
	selector := aSendNode receiver selector.

	data := self
		        inlineConditionalGuardingOrConditionalInit: aSendNode
		        isGuarding: true.
	evaluateIfTrue := data at: #isIfTrue.
	replacementTree := aSendNode receiver.
	skipLabel := data at: #returnReplacement.
	map := Dictionary new.

	(replacementTree lastExpression allSatisfy: [ :node |
		 node isReturn and: [ node expression value = evaluateIfTrue ] ])
		ifTrue: [ lastNode := replacementTree lastExpression ].

	replacementTree nodesDo: [ :node |
		| expr |
		node isReturn ifTrue: [
			expr := node expression.
			self assert:
				(expr isConstant and: [ #( true false ) includes: expr value ]).
			map at: node put: (expr value ~~ evaluateIfTrue
					 ifTrue: [ TGoToNode label: skipLabel label ]
					 ifFalse: [
						 (lastNode isNotNil and: [ lastNode includes: node ])
							 ifTrue: [
								 TLabeledCommentNode new setComment:
									 'end ' , selector , '; fall through' ]
							 ifFalse: [
								 evaluateLabel ifNil: [
									 evaluateLabel := TLabeledCommentNode new setLabel:
										                  (currentMethod unusedLabelForInlining:
											                   (data at: #method)) ].
								 TGoToNode label: evaluateLabel label ] ]) ] ].

	data at: #map put: map.
	self replaceNodeIn: aSendNode with: data.

	replacementTree isComment ifTrue: [
		replacementTree statements: {  }.
		skipLabel := nil ].
	(replacementTree sizeWithoutComments = 1 and: [
		 replacementTree lastNonCommentStatement label = skipLabel label ])
		ifTrue: [
			replacementTree statements: {  }.
			aSendNode arguments first statements: {  }.
			skipLabel := nil ].

	skipLabelStmt := skipLabel
		                 ifNotNil: [ { skipLabel } ]
		                 ifNil: [ {  } ].
	inlineStmts := TStatementListNode new
		               setArguments: #(  )
		               statements: (evaluateLabel
				                ifNil: [
					                replacementTree statements
					                , aSendNode arguments first statements
					                , skipLabelStmt ]
				                ifNotNil: [
					                replacementTree statements , { evaluateLabel }
					                , aSendNode arguments first statements
					                , skipLabelStmt ]).

	sLNodeAnnotatorVisitor
		visitFromBranchStartingAt: aSendNode
		replacement: inlineStmts
]

{ #category : 'conditional' }
SLInlinerWithAnnotation >> inlineReturningConditional: aSendNode [
	"Inline
		aSend ifTrue:/ifFalse: [^expr]
	 where aSend is inlineable and always answers booleans.  We inline ^expr
	 into aSend."

	| data returnIfTrue returnNode replacementTree map lastNode label selector inlineStmts |
	selector := aSendNode receiver selector.
	data := self
		        inlineConditionalGuardingOrConditionalInit: aSendNode
		        isGuarding: false.
	returnIfTrue := data at: #isIfTrue.
	replacementTree := aSendNode receiver.
	returnNode := data at: #returnReplacement.
	map := Dictionary new.

	"The last node is either a return or a boolean constant."
	lastNode := replacementTree lastNonCommentStatement.
	lastNode isReturn
		ifTrue: [
			lastNode expression value == returnIfTrue ifTrue: [
				lastNode := nil "i.e. take the fall-through path and /don't/ return" ] ]
		ifFalse: [
			self assert:
				(lastNode isConstant and: [
					 #( true false ) includes: lastNode value ]).
			lastNode value == returnIfTrue ifTrue: [ "i.e. /do/ return"
				map at: lastNode put: returnNode ] ].
	replacementTree nodesDo: [ :node |
		| expr |
		node isReturn ifTrue: [
			expr := node expression.
			self assert:
				(expr isConstant and: [ #( true false ) includes: expr value ]).
			map at: node put: (expr value == returnIfTrue
					 ifTrue: [ returnNode ]
					 ifFalse: [
						 node == lastNode
							 ifTrue: [
								 TLabeledCommentNode new setComment:
									 'end ' , selector , '; fall through' ]
							 ifFalse: [
								 label ifNil: [
									 label := TLabeledCommentNode new setLabel:
										          (currentMethod unusedLabelForInlining:
											           (data at: #method)) ].
								 TGoToNode label: label label ] ]) ] ].

	data at: #map put: map.
	self replaceNodeIn: aSendNode with: data.

	inlineStmts := label ifNil: [ replacementTree ] ifNotNil: [
		               TStatementListNode new
			               setArguments: #(  )
			               statements: {
					               replacementTree.
					               label } ].

	sLNodeAnnotatorVisitor
		visitFromBranchStartingAt: aSendNode
		replacement: inlineStmts
]

{ #category : 'statement' }
SLInlinerWithAnnotation >> inlineSend: aSendNode [
	"Answer a collection of statements to replace the given send.  directReturn indicates
	 that the send is the expression in a return statement, so returns can be left in the
	 body of the inlined method. If exitVar is nil, the value returned by the send is not
	 used; thus, returns need not assign to the output variable.

	 Types are propagated to as-yet-untyped variables when inlining a send that is assigned,
	 otherwise the assignee variable type must match the return type of the inlinee.  Return
	 types are not propagated."

	| selector callee exitLabel inlineStmts omittedParameters calleeParameters exitVar directReturn isUsedExpression assigningParent argumentsSubstitutionDict |
	selector := aSendNode selector.
	callee := codeGenerator methodNamed: selector.
	directReturn := sLNodeAnnotatorVisitor isEffectiveReturnValue:
		                aSendNode.
	(sLNodeAnnotatorVisitor isEffectiveAssignmentValue: aSendNode)
		ifTrue: [
			assigningParent := sLNodeAnnotatorVisitor assigningParentFor:
				                   aSendNode.
			exitVar := assigningParent variable name ].
	"for goTo management"
	isUsedExpression := (sLNodeAnnotatorVisitor isEffectiveExpression:
		                     aSendNode) and: [
		                    directReturn not and: [
			                    exitVar isNil or: [
				                    sLNodeAnnotatorVisitor isEffectiveExpression:
					                    assigningParent ] ] ].

	"convenient for debugging..."
	codeGenerator maybeBreakForInlineOf: aSendNode in: self.

	[ :res |
	omittedParameters := res first.
	calleeParameters := res second ] value:
		(self trimArgumentsIn: callee).
	calleeParameters size = aSendNode arguments size ifFalse: [ ^ self ].
	callee := callee copy.
	inlineStmts := callee parseTree.

	self checkForFlagIn: inlineStmts.

	self
		propagateReturnTypeDirectReturn: directReturn
		exitVar: exitVar
		callee: callee.
	self
		propagateArgumentTypeArguments: calleeParameters
		in: callee
		from: aSendNode.

	self
		renameVarsAndLabelsForInliningIntoCurrentMethodOf: callee
		except: omittedParameters.

	exitLabel := self
		             replaceReturnWithGoToIfNeededIn: callee
		             directReturn: directReturn.

	argumentsSubstitutionDict := self
		                             argAssignmentsFor: callee
		                             send: aSendNode
		                             except: omittedParameters.

	self
		addBeginAndEndCommentsFor: inlineStmts
		selector: selector
		exitLabel: exitLabel.

	inlineStmts isComment ifTrue: [ "Nuke empty methods; e.g. override of flushAtCache"
		inlineStmts statements: OrderedCollection new ].

	self
		moveDownReturnsAndAssignmentsFor: aSendNode
		including: inlineStmts.
	self replaceVariableIn: argumentsSubstitutionDict for: inlineStmts.

	isUsedExpression ifFalse: [
		inlineStmts nodesDo: [ :node |
			node isGoTo ifTrue: [ node indicateAnExitPointInlined ] ] ]
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isConditionalToBeTransformedForAssignment: aSend [
	"Answer if a send is of the form
		e1
			ifTrue: [e2 ifTrue: [self m1] ifFalse: [self m2]]
			ifFalse: [self m3]
	 such that at least one of the sends mN may be inlined.."

	^ (#( #ifTrue:ifFalse: #ifFalse:ifTrue: ) includes: aSend selector)
		  and: [
			  aSend arguments anySatisfy: [ :arg |
				  | stmt |
				  self assert: arg isStatementList.
				  arg statements size > 1 or: [
					  (stmt := arg firstNonCommentStatement) isSwitch or: [
						  stmt isSend and: [
							  (codeGenerator mayInline: stmt selector) or: [
								  self isConditionalToBeTransformedForAssignment: stmt ] ] ] ] ] ]
]

{ #category : 'testing-method' }
SLInlinerWithAnnotation >> isFunctional: aTMethod [
	"Answer if the receiver is a functional method. That is, if it
	 consists of a single return statement of an expression  or an assert or flag followed by
	 such a statement.

	 Answer false for methods with return types other than the simple
	 integer types to work around bugs in the inliner."

	| parseTree last size |
	parseTree := aTMethod parseTree.
	size := parseTree sizeWithoutComments.

	size = 1 ifFalse: [
		(size = 2 and: [
			 | first |
			 first := parseTree firstNonCommentStatement.
			 first isSend and: [
				 first selector == #flag: or: [
					 (codeGenerator isAssertSelector: first selector) and: [
						 first selector ~~ #asserta: ] ] ] ]) ifFalse: [ ^ false ] ].
	last := parseTree lastNonCommentStatement.
	(last isReturn or: [
		 sLNodeAnnotatorVisitor
			 do: [ sLNodeAnnotatorVisitor isReturningIf: last ]
			 visit: last ]) ifFalse: [ ^ false ].

	^ #( int #'unsigned int' #long #'unsigned long' #'long long'
	     #'unsigned long long' sqInt usqInt #sqIntptr_t #usqIntptr_t
	     sqLong usqLong #'int *' #'unsigned int *' #'sqInt *' #'usqInt *'
	     #'sqLong *' #'usqLong *' #'char *' #'CogMethod *' #'AbstractInstruction *'
	     #'FILE *' ) includes: aTMethod returnType
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isInlineableConditional: aSendNode [
	"Answer if the given send node is of the form aSend [ifTrue:|ifFalse:] [statements]
	 where the method for aSend is marked as inline and all returns within it answer booleans."

	| method |
	^ (#( ifTrue: ifFalse: ) includes: aSendNode selector) and: [
		  aSendNode receiver isSend and: [
			  (method := codeGenerator anyMethodNamed:
				             aSendNode receiver selector) notNil and: [
				  method inline == true and: [
					  method parseTree lastNonCommentStatement isReturn and: [
						  method parseTree allSatisfy: [ :node |
							  node isReturn not or: [
								  node expression isDefine not and: [
									  node expression isConstant and: [
										  #( true false ) includes: node expression value ] ] ] ] ] ] ] ] ]
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isInlineableFunctionCall: aNode [

	^ self isInlineableFunctionCall: aNode transformedConstantFrom: nil
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isInlineableFunctionCall: aNode transformedConstantFrom: anOtherNodeOrNil [
	"Answer if the given send node is a call to a 'functional' method--a method whose body is a single return statement of some expression and whose actual parameters can all be directly substituted.
	if a method is marked as always inlined and complete, the method also returns true"

	| nodeForVisitorInfo |
	codeGenerator maybeBreakForTestToInline: aNode in: self.
	aNode isSend ifFalse: [ ^ false ].
	nodeForVisitorInfo := anOtherNodeOrNil
		                      ifNil: [ aNode ]
		                      ifNotNil: [ anOtherNodeOrNil ].
	^ (codeGenerator methodNamed: aNode selector)
		  ifNil: [
			  aNode asTransformedConstantPerform
				  ifNil: [ self isInlineableConditional: aNode ]
				  ifNotNil: [ :n | "when going through transformation, the new node n take the place of aNode but not in the visitor so we keep track of the old node "
					  self
						  isInlineableFunctionCall: n
						  transformedConstantFrom: nodeForVisitorInfo ] ]
		  ifNotNil: [ :m |
			  (m ~~ currentMethod and: [
				   ((m isFunctionalIn: codeGenerator) or: [
					    m mustBeInlined and: [ m isComplete ] ]) and: [
					   m mayBeInlined and: [
						   (codeGenerator mayInline: m selector) and: [
							   (aNode arguments allSatisfy: [ :a |
								    self isSubstitutableNode: a intoMethod: m ]) and: [
								   self
									   canBeInlineInExpression: nodeForVisitorInfo
									   replacement: m ] ] ] ] ]) or: [
				  m checkForRequiredInlinability ] ]
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isInlineableSend: aNode [
	"Answer if the given expresssion node is a call to a method that can be inlined."

	| m |
	codeGenerator maybeBreakForTestToInline: aNode in: self.
	aNode isSend ifFalse: [ ^ false ].

	m := codeGenerator methodNamed: aNode selector. "nil if builtin or external function"
	m ifNil: [ ^ false ].

	^ m ~~ currentMethod and: [
		  m mayBeInlined and: [
			  (m isComplete and: [
				   (codeGenerator mayInline: m selector) and: [
					   self canBeInlineInExpression: aNode replacement: m ] ]) or: [
				  m checkForRequiredInlinability ] ] ]
]

{ #category : 'testing-node' }
SLInlinerWithAnnotation >> isSubstitutableNode: aNode intoMethod: targetMeth [
	"Answer true if the given parameter node is either a constant, a local variable, or a formal parameter of the receiver. Such parameter nodes may be substituted directly into the body of the method during inlining. Note that global variables cannot be subsituted into methods with possible side effects (i.e., methods that may assign to global variables) because the inlined method might depend on having the value of the global variable captured when it is passed in as an argument."

	| var |
	aNode isConstant ifTrue: [ ^ true ].

	aNode isVariable ifTrue: [
		var := aNode name.
		((currentMethod locals includes: var) or: [
			 currentMethod args includes: var ]) ifTrue: [ ^ true ].
		var = #self ifTrue: [ ^ true ].
		(targetMeth maySubstituteGlobal: var in: codeGenerator) ifTrue: [
			^ true ] ].

	"For now allow literal blocks to be substituted.  They better be accessed only
	 with value[:value:*] messages though!"
	aNode isStatementList ifTrue: [ ^ true ].

	(aNode isSend and: [
		 codeGenerator isStructAccessorWithNoSideEffect: aNode ]) ifTrue: [
		^ true ].

	"scan expression tree; must contain only constants, builtin ops, and inlineable vars"
	aNode nodesDo: [ :node |
		node isSend ifTrue: [
			((codeGenerator isBuiltinSelector: node selector) or: [
				 codeGenerator isStructAccessorWithNoSideEffect: node ]) ifFalse: [
				^ false ] ].
		node isVariable ifTrue: [
			var := node name.
			((currentMethod locals includes: var) or: [
				 (currentMethod args includes: var) or: [
					 var = #self or: [
						 targetMeth maySubstituteGlobal: var in: codeGenerator ] ] ])
				ifFalse: [ ^ false ] ].
		(node isConstant or: [ node isVariable or: [ node isSend ] ])
			ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> label: exitLabel for: aTMethod [
	"Replace each return statement in this method with an assignment to the
	 exit variable followed by either a return or a goto to the given label.
	 Answer if a goto was generated."

	"Optimization: If exitVar is nil, the return value of the inlined method is not being used, so don't add the assignment statement."

	| labelUsed map eliminateReturnSelfs definingClass |
	labelUsed := false.
	map := Dictionary new.

	"Conceivably one might ^self from a struct class and mean it.  In most cases though
	 ^self means `get me outta here, fast'.  So unless this method is from a VMStruct class,
	 elide any ^self's"
	definingClass := aTMethod definingClass.
	eliminateReturnSelfs := ((definingClass inheritsFrom: SlangClass)
		                         and: [ definingClass isStructClass ]) not
		                        and: [
		                        #( #void #sqInt ) includes:
			                        aTMethod returnType ].

	aTMethod parseTree nodesDo: [ :node |
		| replacement |
		node isReturn ifTrue: [
			aTMethod 
				transformReturnSubExpression: node
				toAssignmentOf: nil
				andGoto: exitLabel
				unless: eliminateReturnSelfs
				into: [ :rep :labelWasUsed |
					replacement := rep.
					labelWasUsed ifTrue: [ labelUsed := true ] ].

			map at: node put: (replacement ifNil: [
					 TLabeledCommentNode new setComment:
						 'return ' , node expression printString ]) ] ].
	map isEmpty ifTrue: [
		aTMethod deny: labelUsed.
		^ false ].
	"Now do a top-down replacement for all returns that should be mapped to assignments and gotos"
	aTMethod parseTree replaceNodesIn: map.

	"Now flatten any new statement lists..."
	aTMethod parseTree nodesDo: [ :node |
		| list |
		(node isStatementList and: [
			 node isComment not and: [
				 node lastNonCommentStatement isStatementList ] ]) ifTrue: [
			list := node lastNonCommentStatement statements.
			node replaceChild: node lastNonCommentStatement withList: list ] ].
	^ labelUsed
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> moveDownReturnsAndAssignmentsFor: aSendNode including: aTStatementList [

	sLNodeAnnotatorVisitor
		visitFromBranchStartingAt: aSendNode
		replacement: aTStatementList.

	sLNodeAnnotatorVisitor moveDownAssigningParentFrom: aTStatementList.
	sLNodeAnnotatorVisitor moveDownReturningParentFrom: aTStatementList
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> propagateArgumentTypeArguments: calleeParameters in: callee from: aSendNode [
	"Propagate any unusual argument types to untyped argument variables"

	calleeParameters with: aSendNode arguments do: [ :formal :actual |
		(callee declarationAt: formal ifAbsent: nil) ifNil: [
			| type |
			(actual isVariable and: [
				 (type := currentMethod typeFor: actual name in: codeGenerator)
					 notNil ]) ifTrue: [
				type ~= #sqInt ifTrue: [
					callee declarationAt: formal put: (type last = $*
							 ifTrue: [ type , formal ]
							 ifFalse: [ type , ' ' , formal ]) ] ] ] ]
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> propagateReturnTypeDirectReturn: directReturn exitVar: exitVar callee: callee [
	"Propagate the return type of an inlined method"

	| exitType |
	(directReturn or: [ exitVar notNil ]) ifFalse: [ ^ self ].
	exitType := directReturn
		            ifTrue: [ currentMethod returnType ]
		            ifFalse: [
			            (currentMethod typeFor: exitVar in: codeGenerator)
				            ifNil: [ #sqInt ] ].
	(exitType = #void or: [ exitType = callee returnType ]) ifFalse: [
		callee propagateReturnIn: codeGenerator ]
]

{ #category : 'preparation-statement' }
SLInlinerWithAnnotation >> removeNonSupportedStmtForInliningIn: stmtLists [

	currentMethod parseTree nodesDo: [ :node |
		node isSend ifTrue: [
			node selector = #cCode:inSmalltalk: ifTrue: [
				node nodesDo: [ :ccisNode |
					stmtLists remove: ccisNode ifAbsent: [  ] ] ].
			node selector = #cCall: ifTrue: [
				node nodesDo: [ :ccisNode |
					stmtLists remove: ccisNode ifAbsent: [  ] ] ].
			node selector = #cCall:withArguments: ifTrue: [
				node nodesDo: [ :ccisNode |
					stmtLists remove: ccisNode ifAbsent: [  ] ] ].
			(#( #cppIf:ifTrue:ifFalse: #cppIf:ifTrue: ) includes: node selector)
				ifTrue: [
					node arguments first nodesDo: [ :inCondNode |
						stmtLists remove: inCondNode ifAbsent: [  ] ] ].
			(#( #and: #or: ) includes: node selector) ifTrue: [ "Note: the PP 2.3 compiler produces two arg nodes for these selectors"
				stmtLists remove: node arguments first ifAbsent: [  ].
				stmtLists remove: node arguments last ifAbsent: [  ] ].
			(#( #ifTrue: #ifFalse: #ifTrue:ifFalse: #ifFalse:ifTrue:
			    #ifNil: #ifNotNil: #ifNil:ifNotNil: #ifNotNil:ifNil: )
				 includes: node selector) ifTrue: [
				stmtLists remove: node receiver ifAbsent: [  ] ].
			(#( whileTrue whileTrue: whilefalse whileFalse: ) includes:
				 node selector) ifTrue: [ "Allow inlining if it is a [...] whileTrue/whileFalse.
				This is identified by having more than one statement in the 
				receiver block in which case the C code wouldn't work anyways"
				node receiver sizeWithoutComments = 1 ifTrue: [
					stmtLists remove: node receiver ifAbsent: [  ] ] ].
			node selector = #to:do: ifTrue: [
				stmtLists remove: node receiver ifAbsent: [  ].
				stmtLists remove: node args first ifAbsent: [  ] ].
			node selector = #to:by:do: ifTrue: [
				stmtLists remove: node receiver ifAbsent: [  ].
				stmtLists remove: node arguments first ifAbsent: [  ].
				stmtLists remove: node arguments second ifAbsent: [  ] ] ].
		node isCaseStmt ifTrue: [ "don't inline cases"
			node cases do: [ :case | stmtLists remove: case ifAbsent: [  ] ] ] ]
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> renameVarsAndLabelsForInliningIntoCurrentMethodOf: aTMethod except: varsToNotRename [

	aTMethod
		renameVarsForInliningInto: currentMethod
		except: varsToNotRename
		in: codeGenerator.
	aTMethod renameLabelsForInliningInto: currentMethod.
	currentMethod
		addVarsDeclarationsAndLabelsOf: aTMethod
		except: varsToNotRename
]

{ #category : 'conditional' }
SLInlinerWithAnnotation >> replaceNodeIn: aSendNode with: data [

	| method |
	method := data at: #method.

	self replaceNodesIn: (data at: #map) for: aSendNode receiver.

	currentMethod
		addVarsDeclarationsAndLabelsOf: method
		except: method args
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> replaceNodesIn: aReplacementDictionary for: aNode [

	| replacement |
	aReplacementDictionary isEmpty ifTrue: [ ^ self ].
	aNode nodesDo: [ :node |
		(aReplacementDictionary
			 at: node
			 ifPresent: [ true ]
			 ifAbsent: [ false ]) ifTrue: [
			replacement := (aReplacementDictionary at: node) copy.
			node parent replaceChild: node with: replacement ] ]
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> replaceReturnWithGoToIfNeededIn: callee directReturn: directReturn [

	| exitLabel |
	callee hasReturn ifTrue: [
		directReturn ifFalse: [
			exitLabel := currentMethod unusedLabelForInliningInto:
				             currentMethod.
			(self label: exitLabel for: callee)
				ifTrue: [ currentMethod labels add: exitLabel ]
				ifFalse: [ "is label used?" ^ nil ] ] ].
	^ exitLabel
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> replaceVariableIn: aReplacementDictionary for: aNode [

	| replacement |
	aReplacementDictionary isEmpty ifTrue: [ ^ self ].
	aNode nodesDo: [ :node |
		(node isVariable and: [
			 aReplacementDictionary
				 at: node name
				 ifPresent: [ true ]
				 ifAbsent: [ false ] ]) ifTrue: [
			replacement := (aReplacementDictionary at: node name) copy.

			sLNodeAnnotatorVisitor
				visitFromBranchStartingAt: node
				replacement: replacement.
			sLNodeAnnotatorVisitor moveDownAssigningParentFrom: replacement ] ]
]

{ #category : 'preparation-statement' }
SLInlinerWithAnnotation >> statementsListsForInliningInCurrentMethod [
	"Answer a collection of statement list nodes that are candidates for inlining.
	 Currently, we cannot inline into the argument blocks of and: and or: messages.
	 We do not want to inline code strings within cCode:inSmalltalk: blocks (those with a
	 proper block for the cCode: argument are inlined in MessageNode>>asTranslatorNodeIn:).
	 We do not want to inline code within assert: sends (because we want the assert to read nicely)."

	| tStmtListNodeLists |
	tStmtListNodeLists := OrderedCollection new: 10.

	currentMethod parseTree
		nodesDo: [ :node |
			node isStatementList ifTrue: [ tStmtListNodeLists add: node ] ]
		unless: [ :node |
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					node selector == #cCall: or: [
						node selector == #cCall:withArguments: or: [
							codeGenerator isAssertSelector: node selector ] ] ] ] ].

	self removeNonSupportedStmtForInliningIn: tStmtListNodeLists.

	^ self filterStmtForInliningIn: tStmtListNodeLists
]

{ #category : 'preparation' }
SLInlinerWithAnnotation >> transformConditionalAssignment: node [
	"If possible answer the transformation of code of the form
		var := e1
				ifTrue: [e2 ifTrue: [self m1] ifFalse: [self m2]]
				ifFalse: [self m3]
	 into
		e1
			ifTrue: [e2 ifTrue: [var := self m1] ifFalse: [var := self m2]]
			ifFalse: [var := self m3]
	 to allow inlining of m1, m2, et al.  Otherwise answer nil."

	| expr |
	^ (node isAssignment and: [
		   (expr := node expression) isSend and: [
			   (#( #ifTrue:ifFalse: #ifFalse:ifTrue: ) includes: expr selector)
				   and: [ self isConditionalToBeTransformedForAssignment: expr ] ] ])
		  ifTrue: [
			  expr copy
				  arguments: (expr arguments collect: [ :stmtList |
							   stmtList copy assignLastExpressionTo: node variable ]);
				  yourself ]
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> trimArgumentsIn: aTMethod [

	| calleeParameters omittedParameters varNode |
	calleeParameters := aTMethod args.
	omittedParameters := #(  ).
	(calleeParameters notEmpty and: [
		 calleeParameters first beginsWith: 'self_in_' ]) ifFalse: [
		^ OrderedCollection new
			  add: omittedParameters;
			  add: calleeParameters;
			  yourself ].
	"If the first arg is not used we can and should elide it."
	varNode := TVariableNode new setName: calleeParameters first.
	(aTMethod parseTree noneSatisfy: [ :node | varNode isSameAs: node ])
		ifTrue: [ omittedParameters := { calleeParameters first } ].

	calleeParameters := calleeParameters allButFirst.
	^ OrderedCollection new
		  add: omittedParameters;
		  add: calleeParameters;
		  yourself
]

{ #category : 'inlining' }
SLInlinerWithAnnotation >> tryToInlineMethodExpressionsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method as receivers or parameters.
	 Answer if anything was inlined."

	self fillSendForInliningInCurrentMethod.
	sendsForInlining isEmpty ifTrue: [ ^ false ].

	codeGenerator pushScope: currentMethod while: [
		sendsForInlining do: [ :dictionary |
			dictionary at: self functionCallInliningString ifPresent: [
				self inlineFunctionCall:
					(dictionary at: self functionCallInliningString) ].
			dictionary
				at: self functionCallFromBuitinInliningString
				ifPresent: [
					| nodes |
					nodes := dictionary at: self functionCallFromBuitinInliningString.
					self inlineFunctionCall: nodes value fromBuiltin: nodes key ].
			dictionary at: self conditionalInliningString ifPresent: [
				self inlineConditional:
					(dictionary at: self conditionalInliningString) ] ] ].

	^ true
]

{ #category : 'inlining' }
SLInlinerWithAnnotation >> tryToInlineMethodStatementsListsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method as top-level statements.
	 Answer if anything was inlined."

	| stmtLists |
	stmtLists := self statementsListsForInliningInCurrentMethod.
	stmtLists isEmpty ifTrue: [ ^ false ].

	stmtLists do: [ :stmt | self inlineSend: stmt ].

	^ true
]

{ #category : 'inlining' }
SLInlinerWithAnnotation >> tryToInlineMethodsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method.
	 Set the complete flag when all inlining has been done.
	 Answer if something was inlined."

	| didSomething |
	currentMethod definedAsMacro ifTrue: [
		currentMethod isComplete ifTrue: [ ^ false ].
		^ currentMethod complete: true ].

	currentMethod isComplete ifTrue: [ ^ false ].

	self ensureConditionalAssignmentsAreTransformedInCurrentMethod.
	self annotateCurrentMethod.
	didSomething := self tryToInlineMethodStatementsListsInCurrentMethod.
	didSomething := self tryToInlineMethodExpressionsInCurrentMethod or: [
		                didSomething ].

	didSomething ifTrue: [ currentMethod writtenToGlobalVarsCache: nil ].

	"marking a method complete is progress"
	currentMethod isComplete ifFalse: [
		self checkForCompletenessFor: currentMethod.
		currentMethod isComplete ifTrue: [ didSomething := true ] ].

	^ didSomething
]
