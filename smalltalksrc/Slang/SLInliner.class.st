Class {
	#name : 'SLInliner',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator',
		'currentMethod',
		'sLNodeAnnotatorVisitor'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'testing' }
SLInliner >> checkForCompletenessFor: aTMethod [
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
SLInliner >> checkForFlagIn: aTMethod [

	(aTMethod parseTree sizeWithoutComments > 1 and: [
		 aTMethod parseTree firstNonCommentStatement isSend and: [
			 aTMethod parseTree firstNonCommentStatement selector == #flag: ] ])
		ifTrue: [ aTMethod parseTree removeFirst ]
]

{ #category : 'accessing' }
SLInliner >> codeGenerator [

	^ codeGenerator
]

{ #category : 'accessing' }
SLInliner >> codeGenerator: aCodeGenerator [

	codeGenerator := aCodeGenerator
]

{ #category : 'accessing' }
SLInliner >> currentMethod [

	^ currentMethod
]

{ #category : 'accessing' }
SLInliner >> currentMethod: aTMethod [

	currentMethod := aTMethod
]

{ #category : 'inlining-preparation' }
SLInliner >> ensureConditionalAssignmentsAreTransformedInCurrentMethod [
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
SLInliner >> initialize [

	super initialize.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor new
]

{ #category : 'inlining-support' }
SLInliner >> inlineBuiltin: aSendNode [

	| sel meth inlinedReplacement |
	(aSendNode selector beginsWith: 'perform:') ifTrue: [
		^ self inlineFunctionCall: aSendNode asTransformedConstantPerform ].
	sel := aSendNode receiver selector.
	meth := codeGenerator methodNamed: sel.
	(meth notNil and: [ meth inline == true ]) ifFalse: [ ^ nil ].
	(meth isFunctionalIn: codeGenerator) ifTrue: [
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
SLInliner >> inlineCodeOrNilForStatement: aNode [
	"If the given statement node can be inlined, answer the statements that replace it. Otherwise, answer nil."

	(aNode isReturn and: [ self isInlineableSend: aNode expression ])
		ifTrue: [ ^ self inlineSend: aNode expression ].

	(aNode isAssignment and: [ self isInlineableSend: aNode expression ])
		ifTrue: [ ^ self inlineSend: aNode expression ].

	(aNode isSend and: [ self isInlineableSend: aNode ]) ifTrue: [
		^ self inlineSend: aNode ].
	^ nil
]

{ #category : 'inlining-support' }
SLInliner >> inlineCodeOrNilForStatement: aNode returningNodes: returningNodes [
	"If the given statement node can be inlined, answer the statements that replace it. Otherwise, answer nil."

	(aNode isReturn and: [ self isInlineableSend: aNode expression ])
		ifTrue: [
			^ (self
				   inlineSend: aNode expression
				   directReturn: true
				   exitVar: nil) asReturnNode ].

	(aNode isAssignment and: [ self isInlineableSend: aNode expression ])
		ifTrue: [
			^ self
				  inlineSend: aNode expression
				  directReturn: false
				  exitVar: aNode variable name ].

	(aNode isSend and: [ self isInlineableSend: aNode ]) ifTrue: [
		^ self
			  inlineSend: aNode
			  directReturn: (returningNodes includes: aNode)
			  exitVar: nil ].
	^ nil
]

{ #category : 'inlining-support-condtional' }
SLInliner >> inlineConditional: aSendNode [
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
SLInliner >> inlineConditionalGuardingOrConditionalInit: aSendNode isGuarding: isGuarding [
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

	data
		at: #replacementTree
		put: (self inlineFunctionCall: aSendNode receiver).

	data at: #returnReplacement put: (isGuarding
			 ifTrue: [
				 TLabeledCommentNode new setLabel:
					 (currentMethod unusedLabelForInlining: (data at: #method)) ]
			 ifFalse: [ aSendNode arguments first ]).

	^ data
]

{ #category : 'inlining-support' }
SLInliner >> inlineFunctionCall: aSendNode [
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
	meth parseTree parent: aSendNode parent.
	^ meth parseTree endsWithReturn
		  ifTrue: [ meth parseTree copyWithoutReturn ]
		  ifFalse: [ meth parseTree ]
]

{ #category : 'inlining-support-condtional' }
SLInliner >> inlineGuardingConditional: aSendNode [
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
SLInliner >> inlineReturningConditional: aSendNode [
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
SLInliner >> inlineSend: aSendNode [
	"Answer a collection of statements to replace the given send.  directReturn indicates
	 that the send is the expression in a return statement, so returns can be left in the
	 body of the inlined method. If exitVar is nil, the value returned by the send is not
	 used; thus, returns need not assign to the output variable.

	 Types are propagated to as-yet-untyped variables when inlining a send that is assigned,
	 otherwise the assignee variable type must match the return type of the inlinee.  Return
	 types are not propagated."

	| sel callee exitLabel inlineStmts label omittedParameters calleeParameters exitVar directReturn |
	sel := aSendNode selector.
	callee := codeGenerator methodNamed: sel.

	directReturn := sLNodeAnnotatorVisitor isDirectReturn: aSendNode.
	exitVar := (sLNodeAnnotatorVisitor exitVarFor: aSendNode) ifNotNil: [
		           :var | var name ].

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
			(callee exitVar: exitVar label: exitLabel)
				ifTrue: [ currentMethod labels add: exitLabel ]
				ifFalse: [ "is label used?" exitLabel := nil ] ].

		sLNodeAnnotatorVisitor removeReturningParentFrom: aSendNode.
		sLNodeAnnotatorVisitor visit: currentMethod parseTree.
		directReturn := sLNodeAnnotatorVisitor isDirectReturn: aSendNode.
		exitVar := (sLNodeAnnotatorVisitor exitVarFor: aSendNode) ifNotNil: [
			           :var | var name ] ].

	(inlineStmts := OrderedCollection new:
			                callee statements size + callee args size + 2)
		add: (label := TLabeledCommentNode new setComment: 'begin ' , sel);
		addAll: (currentMethod
				 argAssignmentsFor: callee
				 send: aSendNode
				 except: omittedParameters
				 in: codeGenerator);
		addAll: callee statements. "method body"
	exitLabel
		ifNotNil: [
			inlineStmts add:
				(TLabeledCommentNode new setLabel: exitLabel comment: 'end ' , sel) ]
		ifNil: [
		inlineStmts add: (TLabeledCommentNode new setComment: 'end ' , sel) ].
	inlineStmts := TStatementListNode statements: inlineStmts.

	directReturn ifTrue: [
		callee endsWithReturn ifTrue: [
			callee parseTree parent: aSendNode parent.
			exitVar ifNotNil: [ inlineStmts := inlineStmts copyWithoutReturn ] ] ].

	inlineStmts isComment ifTrue: [ "Nuke empty methods; e.g. override of flushAtCache"
		inlineStmts statements: OrderedCollection new ].
	^ inlineStmts
]

{ #category : 'inlining-support' }
SLInliner >> inlineSend: aSendNode directReturn: directReturn exitVar: exitVar [
	"Answer a collection of statements to replace the given send.  directReturn indicates
	 that the send is the expression in a return statement, so returns can be left in the
	 body of the inlined method. If exitVar is nil, the value returned by the send is not
	 used; thus, returns need not assign to the output variable.

	 Types are propagated to as-yet-untyped variables when inlining a send that is assigned,
	 otherwise the assignee variable type must match the return type of the inlinee.  Return
	 types are not propagated."

	| sel callee exitLabel inlineStmts label omittedParameters calleeParameters |
	sel := aSendNode selector.
	callee := codeGenerator methodNamed: sel.


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
			(callee exitVar: exitVar label: exitLabel)
				ifTrue: [ currentMethod labels add: exitLabel ]
				ifFalse: [ "is label used?" exitLabel := nil ] ] ].

	(inlineStmts := OrderedCollection new:
			                callee statements size + callee args size + 2)
		add: (label := TLabeledCommentNode new setComment: 'begin ' , sel);
		addAll: (currentMethod
				 argAssignmentsFor: callee
				 send: aSendNode
				 except: omittedParameters
				 in: codeGenerator);
		addAll: callee statements. "method body"
	exitLabel
		ifNotNil: [
			inlineStmts add:
				(TLabeledCommentNode new setLabel: exitLabel comment: 'end ' , sel) ]
		ifNil: [
		inlineStmts add: (TLabeledCommentNode new setComment: 'end ' , sel) ].
	inlineStmts := TStatementListNode statements: inlineStmts.

	directReturn ifTrue: [
		callee endsWithReturn ifTrue: [
			callee parseTree parent: aSendNode parent.
			exitVar ifNotNil: [ inlineStmts := inlineStmts copyWithoutReturn ] ] ].

	inlineStmts isComment ifTrue: [ "Nuke empty methods; e.g. override of flushAtCache"
		inlineStmts statements: OrderedCollection new ].
	^ inlineStmts
]

{ #category : 'inlining-decision' }
SLInliner >> isConditionalToBeTransformedForAssignment: aSend [
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

{ #category : 'inlining-decision' }
SLInliner >> isInlineableConditional: aSendNode [
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
SLInliner >> isInlineableFunctionCall: aNode [
	"Answer if the given send node is a call to a 'functional' method--a method whose body is a single return statement of some expression and whose actual parameters can all be directly substituted."

	codeGenerator maybeBreakForTestToInline: aNode in: self.
	aNode isSend ifFalse: [ ^ false ].
	^ (codeGenerator methodNamed: aNode selector)
		  ifNil: [
			  aNode asTransformedConstantPerform
				  ifNil: [ self isInlineableConditional: aNode ]
				  ifNotNil: [ :n | self isInlineableFunctionCall: n ] ]
		  ifNotNil: [ :m |
			  (m ~~ currentMethod and: [
				   ((m isFunctionalIn: codeGenerator) or: [
					    m mustBeInlined and: [ m isComplete ] ]) and: [
					   m mayBeInlined and: [
						   (codeGenerator mayInline: m selector) and: [
							   aNode arguments allSatisfy: [ :a |
								   self isSubstitutableNode: a intoMethod: m ] ] ] ] ]) or: [
				  m checkForRequiredInlinability ] ]
]

{ #category : 'inlining-decision' }
SLInliner >> isInlineableSend: aNode [
	"Answer if the given expresssion node is a call to a method that can be inlined."

	| m |
	codeGenerator maybeBreakForTestToInline: aNode in: self.
	aNode isSend ifFalse: [ ^ false ].
	m := codeGenerator methodNamed: aNode selector. "nil if builtin or external function"
	^ m isNotNil and: [
		  m ~~ self and: [
			  m mayBeInlined and: [
				  (m isComplete and: [ codeGenerator mayInline: m selector ]) or: [
					  m checkForRequiredInlinability ] ] ] ]
]

{ #category : 'inlining-decision' }
SLInliner >> isSubstitutableNode: aNode intoMethod: targetMeth [
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
		 aNode isStructAccessorWithNoSideEffectIn: codeGenerator ]) ifTrue: [
		^ true ].

	"scan expression tree; must contain only constants, builtin ops, and inlineable vars"
	aNode nodesDo: [ :node |
		node isSend ifTrue: [
			((codeGenerator isBuiltinSelector: node selector) or: [
				 node isStructAccessorWithNoSideEffectIn: codeGenerator ])
				ifFalse: [ ^ false ] ].
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
SLInliner >> propagateArgumentTypeArguments: calleeParameters in: callee from: aSendNode [
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
SLInliner >> propagateReturnTypeDirectReturn: directReturn exitVar: exitVar callee: callee [
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
SLInliner >> replaceNodeIn: aSendNode with: data [

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

{ #category : 'inlining-preparation' }
SLInliner >> statementsListsForInliningInCurrentMethod [
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
SLInliner >> transformConditionalAssignment: node [
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
SLInliner >> trimArgumentsIn: aTMethod [

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
SLInliner >> tryToInlineMethodExpressionsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method as receivers or parameters.
	 Answer if anything was inlined."

	| sendsToInline |
	sendsToInline := Dictionary new: 100.
	sLNodeAnnotatorVisitor visit: currentMethod parseTree.

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
	sLNodeAnnotatorVisitor cleanInfo.
	^ true
]

{ #category : 'inlining' }
SLInliner >> tryToInlineMethodStatementsListsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method as top-level statements.
	 Answer if anything was inlined."

	| stmtLists didSomething newStatements returningNodes |
	didSomething := false.
	returningNodes := Set new.
	currentMethod parseTree nodesDo: [ :node |
		node isReturn ifTrue: [
			returningNodes add: node expression.
			node expression isConditionalSend ifTrue: [
				returningNodes addAll:
					(node expression arguments collect: [ :stmtList |
						 stmtList statements last ]) ] ] ].
	stmtLists := self statementsListsForInliningInCurrentMethod.

	stmtLists do: [ :stmtList |
		newStatements := TStatementListNode statements:
			                 (OrderedCollection new: stmtList statements size).
		stmtList statements do: [ :stmt |
			(self
				 inlineCodeOrNilForStatement: stmt
				 returningNodes: returningNodes)
				ifNil: [ newStatements addAllLast: { stmt } ]
				ifNotNil: [ :inlinedStmts |
					didSomething := true.
					newStatements addAllLast: inlinedStmts statements ] ].
		stmtList statements: newStatements statements ].

	"This is a hack; forgive me. The inlining above tends to keep return statements in statement lists.
	 In the case of returning ifs we don't want the returns in case the returning if is generated as an expression."
	returningNodes do: [ :returningNode |
		(returningNode isConditionalSend and: [
			 returningNode arguments anySatisfy: [ :alternativeNode |
				 alternativeNode endsWithReturn ] ]) ifTrue: [
			returningNode arguments withIndexDo: [ :alternativeNode :index |
				alternativeNode endsWithReturn ifTrue: [
					returningNode arguments
						at: index
						put: alternativeNode copyWithoutReturn ] ] ] ].

	^ didSomething
]

{ #category : 'inlining' }
SLInliner >> tryToInlineMethodsInCurrentMethod [
	"Expand any (complete) inline methods sent by this method.
	 Set the complete flag when all inlining has been done.
	 Answer if something was inlined."

	| didSomething |
	currentMethod definedAsMacro ifTrue: [
		currentMethod isComplete ifTrue: [ ^ false ].
		^ currentMethod complete: true ].

	self ensureConditionalAssignmentsAreTransformedInCurrentMethod.
	didSomething := self tryToInlineMethodStatementsListsInCurrentMethod.
	didSomething := self tryToInlineMethodExpressionsInCurrentMethod or: [
		                didSomething ].

	didSomething ifTrue: [ currentMethod writtenToGlobalVarsCache: nil ].

	"marking a method complete is progress"
	currentMethod isComplete ifFalse: [
		self checkForCompletenessFor: currentMethod.
		currentMethod isComplete ifTrue: [ didSomething := true ] ]. "marking a method complete is progress"
	^ didSomething
]
