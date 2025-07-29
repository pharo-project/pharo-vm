Class {
	#name : 'SLInlinerWithAnnotation',
	#superclass : 'SLAbstractInlineStrategy',
	#instVars : [
		'currentMethod',
		'sLNodeAnnotatorVisitor'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'inlining-preparation' }
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
	self replaceVariableIn: substitutionDict for: meth.
	^ stmtList
]

{ #category : 'inlining-decision' }
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

{ #category : 'testing' }
SLInlinerWithAnnotation >> checkForCompletenessFor: aTMethod [
	"Set the complete flag if the parse tree contains no further candidates for inlining."

	| foundIncompleteSend |
	codeGenerator maybeBreakForTestOfInliningOf: aTMethod selector.

	foundIncompleteSend := false.
	aTMethod parseTree
		nodesDo: [ :node |
			node isSend ifTrue: [
				(aTMethod
					 methodIsEffectivelyComplete: node selector
					 in: codeGenerator)
					ifTrue: [
						(self isInlineableFunctionCall: node) ifTrue: [
							aTMethod complete: false. "more inlining to do"
							^ self ] ]
					ifFalse: [ foundIncompleteSend := true ] ] ]
		unless: [ :node |
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					codeGenerator isAssertSelector: node selector ] ] ].
	foundIncompleteSend ifFalse: [ aTMethod complete: true ]
]

{ #category : 'testing' }
SLInlinerWithAnnotation >> checkForFlagIn: aTMethod [

	(aTMethod parseTree sizeWithoutComments > 1 and: [
		 aTMethod parseTree firstNonCommentStatement isSend and: [
			 aTMethod parseTree firstNonCommentStatement selector == #flag: ] ])
		ifTrue: [ aTMethod parseTree removeFirstNonCommentStatement ]
]

{ #category : 'accessing' }
SLInlinerWithAnnotation >> codeGenerator [

	^ codeGenerator
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

{ #category : 'inlining-preparation' }
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

{ #category : 'initialization' }
SLInlinerWithAnnotation >> initialize [

	super initialize.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor new
]

{ #category : 'inlining-support' }
SLInlinerWithAnnotation >> inlineBuiltin: aSendNode [

	| sel meth inlinedReplacement |
	(aSendNode selector beginsWith: 'perform:') ifTrue: [
		^ self inlineFunctionCall: aSendNode asTransformedConstantPerform ].
	sel := aSendNode receiver selector.
	meth := codeGenerator methodNamed: sel.
	(meth notNil and: [ meth inline == true ]) ifFalse: [ ^ nil ].
	(self isFunctional: meth) ifTrue: [
		inlinedReplacement := self inlineFunctionCall: aSendNode receiver.
		^ TSendNode new
			  setSelector: aSendNode selector
			  receiver: inlinedReplacement
			  arguments: aSendNode arguments copy ].
	(self isInlineableConditional: aSendNode) ifTrue: [
		^ self inlineConditional: aSendNode ].
	^ nil
]

{ #category : 'inlining-support' }
SLInlinerWithAnnotation >> inlineCodeOrNilForStatement: aNode [
	"If the given statement node can be inlined, answer the statements that replace it. Otherwise, answer nil."

	(aNode isReturn and: [ self isInlineableSend: aNode expression ])
		ifTrue: [ ^ self inlineSend: aNode expression ].

	(aNode isAssignment and: [ self isInlineableSend: aNode expression ])
		ifTrue: [ ^ self inlineSend: aNode expression ].

	(aNode isSend and: [ self isInlineableSend: aNode ]) ifTrue: [
		^ self inlineSend: aNode ].
	^ nil
]

{ #category : 'inlining-support-condtional' }
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

{ #category : 'inlining-support-condtional' }
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

	data at: #replacementTree put: (self
			 inlineFunctionCall: aSendNode receiver
			 inInlineableConditional: true).

	data at: #returnReplacement put: (isGuarding
			 ifTrue: [
				 TLabeledCommentNode new setLabel:
					 (currentMethod unusedLabelForInlining: (data at: #method)) ]
			 ifFalse: [ aSendNode arguments first ]).

	^ data
]

{ #category : 'inlining-support' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode [

	^ self inlineFunctionCall: aSendNode inInlineableConditional: false
]

{ #category : 'inlining-support' }
SLInlinerWithAnnotation >> inlineFunctionCall: aSendNode inInlineableConditional: aBoolean [
	"Answer the body of the called function, substituting the actual
	 parameters for the formal argument variables in the method body.
	 Assume caller has established that:
		1. the method arguments are all substitutable nodes, and
		2. the method to be inlined contains no additional embedded returns."

	| sel meth parametersToReplaceByArgument argsForInlining substitutionDict |
	sel := aSendNode selector.
	meth := (codeGenerator methodNamed: sel) copy.
	meth ifNil: [ ^ self inlineBuiltin: aSendNode ].
	parametersToReplaceByArgument := Set withAll: currentMethod args.
	argsForInlining := aSendNode argumentsForInliningCodeGenerator:
		                   codeGenerator.
	meth args with: argsForInlining do: [ :argName :exprNode |
		exprNode isLeaf ifTrue: [
			parametersToReplaceByArgument add: argName ] ].
	self checkForFlagIn: meth.
	meth
		renameVarsForInliningInto: currentMethod
		except: parametersToReplaceByArgument
		in: codeGenerator.
	meth renameLabelsForInliningInto: currentMethod.
	currentMethod
		addVarsDeclarationsAndLabelsOf: meth
		except: parametersToReplaceByArgument.
	substitutionDict := Dictionary new: meth args size * 2.
	meth args with: argsForInlining do: [ :argName :exprNode |
		substitutionDict at: argName put: exprNode.
		(parametersToReplaceByArgument includes: argName) ifFalse: [
			currentMethod removeLocal: argName ] ].
	meth parseTree bindVariablesIn: substitutionDict.
	"copyWithoutReturn does it implictly, avoid duplicating them and in addition if meth end up in an expressionList, they won't appear which might cause bug,
	see asCASTIn: vs asCASTExpressionIn: for stmtList.
	"
	meth locals: Set new.
	aBoolean ifFalse: [ sLNodeAnnotatorVisitor copyWithoutReturn: meth ].

	"same 'optimization' as before"
	meth parseTree children size = 1 ifTrue: [
		meth parseTree: meth parseTree last ].

	^ meth parseTree
]

{ #category : 'inlining-support-condtional' }
SLInlinerWithAnnotation >> inlineGuardingConditional: aSendNode [
	"Inline
		aSend ifTrue:/ifFalse: [statements]
	 where aSend is inlineable and always answers booleans.  We convert
	 the boolean returns in aSend to jumps."

	| data evaluateIfTrue replacementTree map lastNode evaluateLabel skipLabel |
	data := self
		        inlineConditionalGuardingOrConditionalInit: aSendNode
		        isGuarding: true.
	evaluateIfTrue := data at: #isIfTrue.
	replacementTree := data at: #replacementTree.
	skipLabel := data at: #returnReplacement.
	map := Dictionary new.

	(replacementTree lastNonCommentStatement isReturn and: [
		 replacementTree lastNonCommentStatement expression value
		 = evaluateIfTrue ]) ifTrue: [
		lastNode := replacementTree lastNonCommentStatement ].

	replacementTree nodesDo: [ :node |
		| expr |
		node isReturn ifTrue: [
			expr := node expression.
			self assert:
				(expr isConstant and: [ #( true false ) includes: expr value ]).
			map at: node put: (expr value ~~ evaluateIfTrue
					 ifTrue: [ TGoToNode label: skipLabel label ]
					 ifFalse: [
						 node == lastNode
							 ifTrue: [
								 TLabeledCommentNode new setComment:
									 'end ' , aSendNode receiver selector , '; fall through' ]
							 ifFalse: [
								 evaluateLabel ifNil: [
									 evaluateLabel := TLabeledCommentNode new setLabel:
										                  (currentMethod unusedLabelForInlining:
											                   (data at: #method)) ].
								 TGoToNode label: evaluateLabel label ] ]) ] ].

	data at: #map put: map.
	self replaceNodeIn: aSendNode with: data.

	^ TStatementListNode new
		  setArguments: #(  )
		  statements: (evaluateLabel
				   ifNil: [
					   replacementTree statements
					   , aSendNode arguments first statements , { skipLabel } ]
				   ifNotNil: [
					   replacementTree statements , { evaluateLabel }
					   , aSendNode arguments first statements , { skipLabel } ])
]

{ #category : 'inlining-support-condtional' }
SLInlinerWithAnnotation >> inlineReturningConditional: aSendNode [
	"Inline
		aSend ifTrue:/ifFalse: [^expr]
	 where aSend is inlineable and always answers booleans.  We inline ^expr
	 into aSend."

	| data returnIfTrue returnNode replacementTree map lastNode label |
	data := self
		        inlineConditionalGuardingOrConditionalInit: aSendNode
		        isGuarding: false.
	returnIfTrue := data at: #isIfTrue.
	replacementTree := data at: #replacementTree.
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
									 'end ' , aSendNode receiver selector , '; fall through' ]
							 ifFalse: [
								 label ifNil: [
									 label := TLabeledCommentNode new setLabel:
										          (currentMethod unusedLabelForInlining: (data at: #method)) ].
								 TGoToNode label: label label ] ]) ] ].
				
	data at: #map put: map.
	self replaceNodeIn: aSendNode with: data.

	^ label ifNil: [ replacementTree ] ifNotNil: [
		  TStatementListNode new setArguments: #(  ) statements: {
				  replacementTree.
				  label } ]
]

{ #category : 'inlining-support' }
SLInlinerWithAnnotation >> inlineSend: aSendNode [
	"Answer a collection of statements to replace the given send.  directReturn indicates
	 that the send is the expression in a return statement, so returns can be left in the
	 body of the inlined method. If exitVar is nil, the value returned by the send is not
	 used; thus, returns need not assign to the output variable.

	 Types are propagated to as-yet-untyped variables when inlining a send that is assigned,
	 otherwise the assignee variable type must match the return type of the inlinee.  Return
	 types are not propagated."

	| sel callee exitLabel inlineStmts label omittedParameters calleeParameters exitVar directReturn isUsedExpression assigningParent |
	sel := aSendNode selector.
	callee := codeGenerator methodNamed: sel.
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
	calleeParameters size = aSendNode arguments size ifFalse: [ ^ nil ].
	callee := callee copy.

	self checkForFlagIn: callee.

	self
		propagateReturnTypeDirectReturn: directReturn
		exitVar: exitVar
		callee: callee.
	self
		propagateArgumentTypeArguments: calleeParameters
		in: callee
		from: aSendNode.

	callee
		renameVarsForInliningInto: currentMethod
		except: omittedParameters
		in: codeGenerator.
	callee renameLabelsForInliningInto: currentMethod.
	currentMethod
		addVarsDeclarationsAndLabelsOf: callee
		except: omittedParameters.

	callee hasReturn ifTrue: [
		directReturn ifFalse: [
			exitLabel := currentMethod unusedLabelForInliningInto:
				             currentMethod.
			(self label: exitLabel for: callee)
				ifTrue: [ currentMethod labels add: exitLabel ]
				ifFalse: [ "is label used?" exitLabel := nil ] ] ].

	self moveDownReturnsAndAssignmentsFor: aSendNode including: callee.

	inlineStmts := callee parseTree.
	inlineStmts
		addAllFirst: (self
				 argAssignmentsFor: callee
				 send: aSendNode
				 except: omittedParameters);
		addFirst:
			(label := TLabeledCommentNode new setComment: 'begin ' , sel).

	exitLabel
		ifNotNil: [
			inlineStmts addLast:
				(TLabeledCommentNode new setLabel: exitLabel comment: 'end ' , sel) ]
		ifNil: [
			inlineStmts addLast:
				(TLabeledCommentNode new setComment: 'end ' , sel) ].

	inlineStmts isComment ifTrue: [ "Nuke empty methods; e.g. override of flushAtCache"
		inlineStmts statements: OrderedCollection new ].
	isUsedExpression ifFalse: [
		inlineStmts nodesDo: [ :node |
			node isGoTo ifTrue: [ node metInInlining ] ] ].
	^ inlineStmts
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> invert: aSendNode replacement: aNode [

	aSendNode parent replaceChild: aSendNode with: aNode
]

{ #category : 'inlining-decision' }
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

{ #category : 'testing' }
SLInlinerWithAnnotation >> isFunctional: aTMethod [
	"Answer if the receiver is a functional method. That is, if it
	 consists of a single return statement of an expression  or an assert or flag followed by
	 such a statement.

	 Answer false for methods with return types other than the simple
	 integer types to work around bugs in the inliner."

	| parseTree last |
	parseTree := aTMethod parseTree.
	parseTree statements size = 1 ifFalse: [
		(parseTree statements size = 2 and: [
			 parseTree statements first isSend and: [
				 parseTree statements first selector == #flag: or: [
					 (codeGenerator isAssertSelector:
						  parseTree statements first selector) and: [
						 parseTree statements first selector ~~ #asserta: ] ] ] ])
			ifFalse: [ ^ false ] ].
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

{ #category : 'inlining-decision' }
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
								  node expression isConstant and: [
									  #( true false ) includes: node expression value ] ] ] ] ] ] ] ]
]

{ #category : 'inlining-decision' }
SLInlinerWithAnnotation >> isInlineableFunctionCall: aNode [

	^ self isInlineableFunctionCall: aNode transformedConstantFrom: nil
]

{ #category : 'inlining-decision' }
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
				   ((self isFunctional: m) or: [
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

{ #category : 'inlining-decision' }
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

{ #category : 'inlining-decision' }
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
			 node statements notEmpty and: [
				 node lastNonCommentStatement isStatementList ] ]) ifTrue: [
			list := node lastNonCommentStatement statements.
			node replaceChild: node lastNonCommentStatement withList: list ] ].
	^ labelUsed
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> moveDownReturnsAndAssignmentsFor: aSendNode including: aTMethodReplacement [

	| replacementParseTree |
	replacementParseTree := aTMethodReplacement parseTree.

	self invert: aSendNode replacement: replacementParseTree.
	sLNodeAnnotatorVisitor
		visitFromBranchStartingAt: aSendNode
		replacement: replacementParseTree.

	sLNodeAnnotatorVisitor moveDownAssigningParentFrom:
		replacementParseTree.
	sLNodeAnnotatorVisitor moveDownReturningParentFrom:
		replacementParseTree
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

{ #category : 'inlining-support-condtional' }
SLInlinerWithAnnotation >> replaceNodeIn: aSendNode with: data [

	| replacementTree method |
	replacementTree := data at: #replacementTree.
	method := data at: #method.

	replacementTree replaceNodesIn: (data at: #map).
	replacementTree comment:
		{ ('inline ' , aSendNode receiver selector) }.
	currentMethod
		addVarsDeclarationsAndLabelsOf: method
		except: method args
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> replaceVariableIn: aReplacementDictionary for: aTMethod [

	| replacement |
	aReplacementDictionary isEmpty ifTrue: [ ^ self ].
	aTMethod parseTree nodesDo: [ :node |
		(node isVariable and: [
			 aReplacementDictionary
				 at: node name
				 ifPresent: [ true ]
				 ifAbsent: [ false ] ]) ifTrue: [
			replacement := (aReplacementDictionary at: node name) copy.
			node parent replaceChild: node with: replacement.
			sLNodeAnnotatorVisitor
				visitFromBranchStartingAt: node
				replacement: replacement.
			sLNodeAnnotatorVisitor moveDownAssigningParentFrom: replacement ] ]
]

{ #category : 'transformation' }
SLInlinerWithAnnotation >> revert: aSendNode replacement: aTMethod [

	aTMethod parseTree parent
		replaceChild: aTMethod parseTree
		with: aSendNode.
	aTMethod parseTree parent: aTMethod
]

{ #category : 'inlining-preparation' }
SLInlinerWithAnnotation >> statementsListsForInliningInCurrentMethod [
	"Answer a collection of statement list nodes that are candidates for inlining.
	 Currently, we cannot inline into the argument blocks of and: and or: messages.
	 We do not want to inline code strings within cCode:inSmalltalk: blocks (those with a
	 proper block for the cCode: argument are inlined in MessageNode>>asTranslatorNodeIn:).
	 We do not want to inline code within assert: sends (because we want the assert to read nicely)."

	| stmtLists |
	stmtLists := OrderedCollection new: 10.

	currentMethod parseTree
		nodesDo: [ :node |
		node isStatementList ifTrue: [ stmtLists add: node ] ]
		unless: [ :node |
			node isSend and: [
				node selector == #cCode:inSmalltalk: or: [
					node selector == #cCall: or: [
						node selector == #cCall:withArguments: or: [
							codeGenerator isAssertSelector: node selector ] ] ] ] ].
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
			node cases do: [ :case | stmtLists remove: case ifAbsent: [  ] ] ] ].
	^ stmtLists
]

{ #category : 'inlining-preparation' }
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

	| sendsToInline |
	sendsToInline := Dictionary new: 100.

	codeGenerator pushScope: currentMethod while: [
		currentMethod parseTree
			nodesDo: [ :node |
				(self isInlineableFunctionCall: node) ifTrue: [
					(self inlineFunctionCall: node) ifNotNil: [ :replacement |
						sendsToInline at: node put: replacement ] ] ]
			unless: [ :node | "Don't inline the arguments to asserts to keep the asserts readable"
				node isSend and: [
					node selector == #cCode:inSmalltalk: or: [
						codeGenerator isAssertSelector: node selector ] ] ] ].

	sendsToInline isEmpty ifTrue: [ ^ false ].
	currentMethod replaceNodesIn: sendsToInline.
	^ true
]

{ #category : 'inlining' }
SLInlinerWithAnnotation >> tryToInlineMethodStatementsListsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method as top-level statements.
	 Answer if anything was inlined."

	| stmtLists didSomething newStatements |
	didSomething := false.
	stmtLists := self statementsListsForInliningInCurrentMethod.

	stmtLists do: [ :stmtList |
		newStatements := TStatementListNode statements:
			                 (OrderedCollection new: stmtList statements size).
		stmtList statements do: [ :stmt |
			(self inlineCodeOrNilForStatement: stmt)
				ifNil: [ newStatements addAllLast: { stmt } ]
				ifNotNil: [ :inlinedStmts |
					didSomething := true.
					newStatements addAllLast: inlinedStmts statements ] ].
		stmtList statements: newStatements statements ].

	^ didSomething
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

	self ensureConditionalAssignmentsAreTransformedInCurrentMethod.
	self annotateCurrentMethod.
	didSomething := self tryToInlineMethodStatementsListsInCurrentMethod.
	didSomething ifTrue: [ self annotateCurrentMethod ].
	self tryToInlineMethodExpressionsInCurrentMethod ifTrue: [
		self annotateCurrentMethod.
		didSomething := true ].

	didSomething ifTrue: [ currentMethod writtenToGlobalVarsCache: nil ].

	"marking a method complete is progress"
	currentMethod isComplete ifFalse: [
		self checkForCompletenessFor: currentMethod.
		currentMethod isComplete ifTrue: [ didSomething := true ] ].

	^ didSomething
]
