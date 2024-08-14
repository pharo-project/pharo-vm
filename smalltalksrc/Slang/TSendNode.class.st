Class {
	#name : 'TSendNode',
	#superclass : 'TParseNode',
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'isBuiltinOperator'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'instance creation' }
TSendNode class >> receiver: aReceiverNode selector: aString [
	
	^ self receiver: aReceiverNode selector: aString arguments: #()
]

{ #category : 'instance creation' }
TSendNode class >> receiver: aReceiverNode selector: aString arguments: aCollection [ 
	
	^ self new
		setSelector: aString
		receiver: aReceiverNode
		arguments: aCollection;
		yourself
]

{ #category : 'comparing' }
TSendNode >> = aNode [

	super = aNode ifFalse: [ ^ false ].
	aNode isSend ifFalse: [ ^ false ].
	selector = aNode selector ifFalse: [ ^ false ].
	receiver = aNode receiver ifFalse: [ ^ false ].
	arguments size = aNode arguments size ifFalse: [ ^ false ].
	arguments doWithIndex: [ :arg :i | 
		(arg = (aNode arguments at: i)) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'visiting' }
TSendNode >> accept: aVisitor [
	
	^ aVisitor visitSendNode: self
]

{ #category : 'accessing' }
TSendNode >> args [

	self
		deprecated: 'use #arguments instead'
		transformWith: '`@rec args' -> '`@rec arguments'.

	^ self arguments
]

{ #category : 'accessing' }
TSendNode >> arguments [

	^arguments
]

{ #category : 'private' }
TSendNode >> arguments: aSequence [
	arguments := aSequence.
	arguments do: [ :e | e parent: self ].
]

{ #category : 'inlining support' }
TSendNode >> argumentsForInliningCodeGenerator: aCodeGen [
	^(self shouldIncludeReceiverAsFirstArgument: aCodeGen)
		ifTrue: [{receiver}, arguments]
		ifFalse: [arguments]
]

{ #category : 'tranforming' }
TSendNode >> asCASTAsFieldReferenceIn: aCodeGen [

	| struct access member |
	(aCodeGen isStructSend: self) ifFalse: [ ^ nil ].

	struct := receiver asCASTExpressionIn: aCodeGen.
	receiver isSend ifTrue: [ struct needsParentheses: true ].
	member := CIdentifierNode name: (aCodeGen cFunctionNameFor: selector).
	access := (receiver structTargetKindIn: aCodeGen) caseOf: { 
			          ([ #pointer ]
			           -> [ 
			           CStructurePointerAccessNode
				           structurePointer: struct
				           member: member ]).
			          ([ #struct ]
			           -> [ CMemberAccessNode object: struct member: member ]) }.
	arguments isEmpty ifFalse: [ 
		self assert: arguments size = 1.
		^ (CAssignmentNode
			   lvalue: (access
					    needsParentheses: false;
					    yourself)
			   rvalue: (arguments first asCASTExpressionIn: aCodeGen))
			  needsParentheses: true;
			  yourself ].
	^ access
		  needsParentheses: true;
		  yourself
]

{ #category : 'tranforming' }
TSendNode >> asCASTAsFunctionCallIn: aCodeGen [

	"Translate this message send into a C function call"

	| callNode |
	callNode := CCallNode
		            identifier:
		            (CIdentifierNode name:
			             (aCodeGen cFunctionNameFor: selector))
		            arguments: OrderedCollection new.


	"Only include the receiver as the first argument in certain cases.
	 The receiver is always included if it is an expression.
	 If it is a variable:
		 If the vmClass says it is an implicit variable, don't include it.
		 If the variable is 'self' and the method being called is not in
		 the method set (i.e. it is some external code), don't include it."
	(self shouldExcludeReceiverAsFirstArgument: aCodeGen) ifFalse: [ 
		callNode arguments add:
			((receiver structTargetKindIn: aCodeGen) == #struct
				 ifTrue: [ CUnaryOperatorNode operator: #& expression: (receiver asCASTExpressionIn: aCodeGen) ]
				 ifFalse: [ (receiver asCASTExpressionIn: aCodeGen) ]) ].
	arguments do: [ :arg | callNode arguments add: (arg asCASTExpressionIn: aCodeGen)].

	"Special case for pluggable modules. Replace messages to interpreterProxy
	 by interpreterProxy->message(..) if the message is not builtin"
	(aCodeGen shouldGenerateAsInterpreterProxySend: self) ifTrue: [ 
		(aCodeGen noteUsedPluginFunction: selector) ifTrue: [ 
			callNode := (CStructurePointerAccessNode 
				            structurePointer:
				            (CIdentifierNode name: 'interpreterProxy')
				            member: callNode) ] ].
	^ callNode
]

{ #category : 'tranforming' }
TSendNode >> asCASTExpressionIn: aCCodeGenerator [

	| construct |
	construct := aCCodeGenerator 
		             generateCASTForBuiltinAsArgumentConstructFor: self.
	construct ifNil: [ 
		construct := (self asCASTAsFieldReferenceIn: aCCodeGenerator) ifNotNil: [ :e | e] ifNil: [ 
			self asCASTAsFunctionCallIn: aCCodeGenerator ]].
	^ construct
]

{ #category : 'tranforming' }
TSendNode >> asCASTIn: aCCodeGenerator [

	| construct |
	construct := aCCodeGenerator generateCASTForBuiltinConstructFor: self.
	construct ifNil: [ 
		construct := self asCASTAsFieldReferenceIn: aCCodeGenerator.
		construct ifNil: [ 
			construct := self asCASTAsFunctionCallIn: aCCodeGenerator ] ].
	^ construct
]

{ #category : 'inlining support' }
TSendNode >> asTransformedConstantPerform [
	"If the receiver is a send of perform: with a constant selector,
	 answer a send node that elides the perform:, otherwise answer nil."
	^(selector isSymbol
	  and: [(selector beginsWith: #perform:)
	  and: [(selector keywords allSatisfy: [:kw| #('perform:' 'with:') includes: kw])
	  and: [arguments first isConstant
	  and: [arguments first value isSymbol
	  and: [arguments first value numArgs + 1 = arguments size]]]]]) ifTrue:
		[TSendNode new
			setSelector: arguments first value
			receiver: receiver
			arguments: arguments allButFirst]
]

{ #category : 'transformations' }
TSendNode >> bindVariableUsesIn: aDictionary [

	self receiver: (receiver bindVariableUsesIn: aDictionary).
	self arguments: (arguments collect: [ :a | a bindVariableUsesIn: aDictionary ]).
]

{ #category : 'transformations' }
TSendNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [

	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound.
	 Attempt to constant-fold and answer a constant node commented with the original expression.
	 Commenting with the original expression is important because it allows us to detect shared cases.
	 e.g. currentBytecode bitAnd: 15 is the same in case 1 and case 17, but '1 /* 1 bitAnd: 15 */' differs
	 from '1 /* 17 bitAnd: 15 */', whereas '1 /* currentBytecode bitAnd: 15 */' doesn't change."

	| newReceiver newArguments |
	"Constant-fold shiftForWord, but not BytesPerWord"
	((codeGen constantClass mostBasicConstantSelectors includes: selector) 
		 and: [ (codeGen isBuiltinSelector: selector) not ]) ifTrue: [ 
		codeGen
			isConstantNode: self
			valueInto: [ :val | ^ TConstantNode value: val ] ].
	newReceiver := receiver
		               bindVariableUsesIn: aDictionary
		               andConstantFoldIf: constantFold
		               in: codeGen.
	newArguments := arguments collect: [ :a | 
		                a
			                bindVariableUsesIn: aDictionary
			                andConstantFoldIf: constantFold
			                in: codeGen ].
	(newReceiver = receiver and: [ newArguments = arguments ]) ifTrue: [ 
		^ self ].
	(constantFold and: [ 
		 newReceiver isConstant and: [ 
			 newReceiver value isInteger and: [ 
				 (newArguments allSatisfy: [ :ea | 
					  ea isConstant and: [ ea value isInteger ] ]) and: [ 
					 codeGen isBuiltinSelector: selector ] ] ] ]) ifTrue: [ 
		| value |
		value := [ 
		         newReceiver value
			         perform: selector
			         withArguments: (newArguments collect: [ :ea | ea value ]) ]
			         on: Error
			         do: [ :ea | nil ].
		(value isInteger or: [ value == true or: [ value == false ] ]) 
			ifTrue: [ 
				^ TConstantNode new
					  setValue: value;
					  "We assume Message prints its keywords and arguments interleaved.
				 e.g. that (Message selector: #between:and: arguments: #(0 1)) printString = 'between: 0 and: 1'"
					  comment: (receiver isLeaf
							   ifTrue: [ receiver printString ]
							   ifFalse: [ '(' , receiver printString , ')' ]) , ' '
						  , (Message
								   selector: selector
								   arguments: (arguments collect: [ :ea | ea value ]))
								  printString;
					  yourself ] ].
	^ self shallowCopy
		  receiver: newReceiver;
		  arguments: newArguments;
		  yourself
]

{ #category : 'transformations' }
TSendNode >> bindVariablesIn: aDictionary [

	self receiver: (receiver bindVariablesIn: aDictionary).
	self arguments: (arguments collect: [ :a | a bindVariablesIn: aDictionary ]).
]

{ #category : 'transformations' }
TSendNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	self receiver: (receiver bindVariablesIn: aDictionary unless: cautionaryBlock).
	self arguments: (arguments collect: [ :a | a bindVariablesIn: aDictionary unless: cautionaryBlock]).
]

{ #category : 'accessing' }
TSendNode >> children [

	^ { receiver } , arguments
]

{ #category : 'dead-code-elimination' }
TSendNode >> collectSendInArguments: sendToCollect [

	arguments do: [ :child |
		child isSend ifTrue: [ child collectSendInSelf: sendToCollect ] ]
]

{ #category : 'dead-code-elimination' }
TSendNode >> collectSendInSelf: sendToCollect [
	"collect send message in the receiver of a conditional send, in we encounter a comparaison operator, we split it and iterate through its left and right values to avoid having unused expression result"

	self isSelectorWithNoSideEffect
		ifFalse: [ sendToCollect add: self ]
		ifTrue: [
			receiver isSend ifTrue: [
				receiver collectSendInSelf: sendToCollect ].
			self collectSendInArguments: sendToCollect ]
]

{ #category : 'accessing' }
TSendNode >> constantNumbericValueIfAtAllPossibleOrNilIn: aCCodeGen [
	"This is a version of constantNumbericValueOrNil for type checking rather than code generation.
	 It aims to yield a value if at all possible."

	(#( #* #'//' #+ #- #'<<' #'>>' bitAnd: bitOr: bitShift: ) includes:
		 selector) ifTrue: [
		(receiver constantNumbericValueIfAtAllPossibleOrNilIn: aCCodeGen)
			ifNotNil: [ :rval |
				(arguments first constantNumbericValueIfAtAllPossibleOrNilIn:
					 aCCodeGen) ifNotNil: [ :aval |
					^ rval perform: selector with: aval ] ] ].
	^ (aCCodeGen anyMethodNamed: selector) ifNotNil: [ :m |
		  m isReturnConstant ifTrue: [
			  m statements last expression
				  constantNumbericValueIfAtAllPossibleOrNilIn: aCCodeGen ] ]
]

{ #category : 'accessing' }
TSendNode >> constantNumbericValueOrNil [
	(#(* // + -) includes: selector) ifTrue:
		[receiver constantNumbericValueOrNil ifNotNil:
			[:rval|
			arguments first constantNumbericValueOrNil ifNotNil:
				[:aval|
				^rval perform: selector with: aval]]].
	^nil
]

{ #category : 'transformations' }
TSendNode >> copyWithoutReturn [
	self assert: self endsWithReturn.
	^self class new
		setSelector: selector
			receiver: receiver
				arguments: (arguments collect:
								[:arg|
								 arg endsWithReturn
									ifTrue: [arg copyWithoutReturn]
									ifFalse: [arg]]);
		yourself
]

{ #category : 'displaying' }
TSendNode >> displayString [

	^ selector printString
]

{ #category : 'testing' }
TSendNode >> endsWithReturn [
	^self isReturningIf
]

{ #category : 'testing' }
TSendNode >> hasSideEffect [
	"Answer if the parse tree rooted at this node has a side-effect or not."
	^(#(#+ #- #* #/ #// #\\ #= #== #~= #~~) includes: selector) not
]

{ #category : 'testing' }
TSendNode >> isAssertion [
	^(selector beginsWith: 'assert') or: [selector beginsWith: 'verify']
]

{ #category : 'testing' }
TSendNode >> isBuiltinOperator [

	^ isBuiltinOperator
]

{ #category : 'testing' }
TSendNode >> isBuiltinOperator: builtinFlag [

	isBuiltinOperator := builtinFlag.
]

{ #category : 'testing' }
TSendNode >> isConditionalSend [
	"Answer if the receiver is a send of any of the conditionals, ifTrue: ifTrue:ifFalse: et al"
	^#(	ifTrue:ifFalse: ifFalse:ifTrue: ifTrue: ifFalse:
		ifNil:ifNotNil: ifNotNil:ifNil: ifNil: ifNotNil:) includes: selector
]

{ #category : 'testing' }
TSendNode >> isLiteralArrayDeclaration [
	^selector == #cCoerce:to:
	  and: [arguments first isConstant
	  and: [arguments first value isLiteral
	  and: [arguments first value isCollection]]]
]

{ #category : 'testing' }
TSendNode >> isNonNullCCode [
	^(#(cCode: cCode:inSmalltalk:) includes: selector)
	   and: [arguments first isConstant
	   and: [arguments first value isString
	   and: [arguments first value notEmpty]]]
]

{ #category : 'testing' }
TSendNode >> isPreprocessorDirective [
	^#( cppIf:ifTrue:ifFalse: cppIf:ifTrue:) includes: selector
]

{ #category : 'testing' }
TSendNode >> isReturningIf [
	^(#(ifTrue:ifFalse: ifFalse:ifTrue: ifNil:ifNotNil: ifNotNil:ifNil:) includes: selector)
	   and: [arguments allSatisfy: [:arg| arg endsWithReturn]]
]

{ #category : 'comparing' }
TSendNode >> isSameAs: aTParseNode [

	(aTParseNode isSend and: [ 
		 selector == aTParseNode selector and: [ 
			 receiver isSameAs: aTParseNode receiver ] ]) ifFalse: [ ^ false ].
	arguments
		with: aTParseNode arguments
		do: [ :a :b | (a isSameAs: b) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'dead-code-elimination' }
TSendNode >> isSelectorWithNoSideEffect [
	^ #(#= #== #< #<= #> #>=) includes: selector
]

{ #category : 'C code generation' }
TSendNode >> isSelfReference: varNode in: aCodeGen [
	^(varNode name beginsWith: 'self')
	  and: [varNode name = 'self' or: [varNode name beginsWith: 'self_in_']]
]

{ #category : 'testing' }
TSendNode >> isSend [

	^true
]

{ #category : 'C code generation' }
TSendNode >> isStructReference: varNode in: aCodeGen [
	^(varNode structTargetKindIn: aCodeGen) notNil
]

{ #category : 'testing' }
TSendNode >> isValueExpansion [
	"Answer if the receiver is of the form literalBlock value[: arg]"
	^receiver isStatementList
	 and: [selector keywords allSatisfy: [:k| #('value' 'value:') includes: k]]
]

{ #category : 'accessing' }
TSendNode >> name [
	
	^ self printString
]

{ #category : 'testing' }
TSendNode >> needsTrailingSemicolon [
	"Answer if, when emitted as a statement (in particular in a TStmtList), the
	 receiver needs a trailing semicolon.  Preprocessor directives and special expansions do not."
	^(self isPreprocessorDirective
	   or: [self isValueExpansion
	   or: [selector == #expandDereferenceInterpreterProxyFunctionTable]]) not
]

{ #category : 'enumerating' }
TSendNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	receiver nodesDo: aBlock.
	arguments do: [ :arg | arg nodesDo: aBlock ].
	aBlock value: self
]

{ #category : 'enumerating' }
TSendNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	receiver nodesDo: aBlock parent: self.
	arguments do: [:arg| arg nodesDo: aBlock parent: self].
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TSendNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	receiver nodesDo: aBlock parent: self unless: cautionaryBlock.
	arguments do: [ :arg | arg nodesDo: aBlock parent: self unless: cautionaryBlock].
	aBlock value: self value: parent
]

{ #category : 'enumerating' }
TSendNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	receiver nodesDo: aBlock unless: cautionaryBlock.
	arguments do: [ :arg | arg nodesDo: aBlock unless: cautionaryBlock].
	aBlock value: self.
]

{ #category : 'accessing' }
TSendNode >> numArgs [
	^arguments size
]

{ #category : 'copying' }
TSendNode >> postCopy [

	self receiver: receiver copy.
	self arguments: (arguments collect: [ :arg | arg copy ])
]

{ #category : 'printing' }
TSendNode >> printOn: aStream level: level [
	| possiblyParenthesize |
	possiblyParenthesize :=
		[:node :newLevel|
		node
			ifNil: [aStream print: node]
			ifNotNil: 
				[(node isSend
				  and: [node selector precedence >= 3]) ifTrue:
					[aStream nextPut: $(].
				node printOn: aStream level: newLevel.
				(node isSend
				 and: [node selector precedence >= 3]) ifTrue:
					[aStream nextPut: $)]]].

	possiblyParenthesize value: receiver value: level.
	arguments size = 0 ifTrue:
		[aStream space; nextPutAll: selector.
		^self].
	selector keywords with: (arguments first: selector numArgs) do:
		[:keyword :arg |
		aStream space; nextPutAll: keyword; space.
		possiblyParenthesize value: arg value: level + 1]
]

{ #category : 'accessing' }
TSendNode >> receiver [

	^receiver
]

{ #category : 'private' }
TSendNode >> receiver: aNode [

	receiver := aNode.
	aNode parent: self
]

{ #category : 'dead-code-elimination' }
TSendNode >> reduceConditionalSend: branchIndex [
	"branch index is either 1 or 2, called when an argument of a conditional send have been removed, if the method has multiple branches we can reduce the branch number to match the transformation"

	branchIndex = 1
		ifTrue: [ self selector: self selector keywords second ]
		ifFalse: [ self selector: self selector keywords first ]
]

{ #category : 'transformations' }
TSendNode >> removeAssertions [
	receiver removeAssertions.
	arguments do: [:arg | arg removeAssertions].
]

{ #category : 'dead-code-elimination' }
TSendNode >> removeUnusedNodesInBranch: aChild [
	"this method should be only called when cleaning an AST tree after an unused expression was found meaning the method should be a conditional send or a cCoerce. 
	If the selector is a conditional and only one branch become empty, we can elude it.
	Only remove in the arguments but transform the receiver if the arguments number changed to zero (meaning the method is incorrect and can now be deleted)"

	| branchIndex |
	branchIndex := arguments indexOf: aChild.
	arguments := arguments select: [ :e | e ~= aChild ].
	arguments isEmpty
		ifTrue: [
			self transformReceiverAfterEmptyArguments.
			self parent removeUnusedNodesInBranch: self ]
		ifFalse: [
			(self selector beginsWith: #cCoerce)
				ifTrue: [ self parent removeUnusedNodesInBranch: self ]
				ifFalse: [ self reduceConditionalSend: branchIndex ] ]
]

{ #category : 'transformations' }
TSendNode >> replaceChild: aNode with: aReplacementNode [

	receiver == aNode ifTrue: [
		self receiver: aReplacementNode.
		^ self
	].
	self arguments: (arguments collect: [ :e |
		e == aNode
			ifTrue: [ aReplacementNode ]
			ifFalse: [ e ] ])
]

{ #category : 'transformations' }
TSendNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		self receiver: (receiver replaceNodesIn: aDictionary).
		self arguments: (arguments collect: [ :a | a replaceNodesIn: aDictionary ]).
		self]
]

{ #category : 'accessing' }
TSendNode >> selector [

	^selector
]

{ #category : 'accessing' }
TSendNode >> selector: aSymbol [
	selector := aSymbol
]

{ #category : 'accessing' }
TSendNode >> setSelector: aSymbol receiver: rcvrNode arguments: argList [

	^ self setSelector: aSymbol receiver: rcvrNode arguments: argList isBuiltInOp: false
]

{ #category : 'accessing' }
TSendNode >> setSelector: aSymbol receiver: rcvrNode arguments: argList isBuiltInOp: builtinFlag [

	selector := aSymbol.
	self receiver: rcvrNode.
	self arguments: argList asArray.
	isBuiltinOperator := builtinFlag.
]

{ #category : 'C code generation' }
TSendNode >> shouldExcludeReceiverAsFirstArgument: aCodeGen [
	"Only include the receiver as the first argument in certain cases.
	 The receiver is always included if it is an expression.
	 If it is a variable:
		 If the vmClass says it is an implicit variable, don't include it.
		 If the method's definingClass says it is an implicit variable, don't include it.
		 If the variable is 'self' and the method being called is not in
		 the method set (i.e. it is some external code), don't include it.
		 If it is a struct send of something the vm says is an implicit variable, don't include it."
	| m |
	(aCodeGen isAssertSelector: selector) ifTrue:
		[^true].
	
	(receiver isSend
	 and: [(receiver shouldExcludeReceiverAsFirstArgument: aCodeGen)
		or: [receiver receiver isVariable
			 and: [(self isSelfReference: receiver receiver in: aCodeGen)
				or: [self isStructReference: receiver receiver in: aCodeGen]]]]) ifTrue:
		[^aCodeGen isNonArgumentImplicitReceiverVariableName: receiver selector].

	^receiver isVariable
	    and: [(aCodeGen isNonArgumentImplicitReceiverVariableName: receiver name)
		    or: [(self isSelfReference: receiver in: aCodeGen)
			    and: [(m := aCodeGen methodNamed: selector) isNil
					or: [#(implicit nil) includes: m typeForSelf]]]]
]

{ #category : 'C code generation' }
TSendNode >> shouldIncludeReceiverAsFirstArgument: aCodeGen [
	"Only include the receiver as the first argument in certain cases.
	 The receiver is always included if it is an expression.
	 If it is a variable:
		 If the vmClass says it is an implicit variable, don't include it.
		 If the variable is 'self' and the method being called is not in
		 the method set (i.e. it is some external code), don't include it."
	^(self shouldExcludeReceiverAsFirstArgument: aCodeGen) not
]

{ #category : 'testing' }
TSendNode >> structTargetKindIn: aCodeGen [
	"Answer if the recever evaluates to a struct or struct pointer
	 and hence can be dereferenced using . or ->.  Answer any of
	 #struct #pointer or nil.  Right now we don't need or support
	 structure return so this method answers either #pointer or nil."
	selector == #cCoerceSimple:to: ifTrue:
		[^(SlangStructType isTypePointerToStruct: arguments last value) ifTrue:
			[#pointer]].

	selector == #addressOf: ifTrue:
		[^#pointer].

	selector == #at: ifTrue:
		[receiver isVariable ifTrue:
			[(aCodeGen typeOfVariable: receiver name) ifNotNil:
				[:type| 
				 type last = $* ifFalse:
					[^receiver structTargetKindIn: aCodeGen].
				 (SlangStructType isTypeStruct: (aCodeGen
											extractTypeFor: receiver name
											fromDeclaration: type allButLast)) ifTrue:
						[^#struct]]].
		(receiver structTargetKindIn: aCodeGen) ifNotNil:
			[:kind| ^kind]].

	(aCodeGen selectorReturnsPointerToStruct: selector) ifTrue:
		[^#pointer].

	(aCodeGen selectorReturnsStruct: selector) ifTrue:
		[^#struct].

	^nil
]

{ #category : 'dead-code-elimination' }
TSendNode >> transformReceiverAfterEmptyArguments [
	"keep any send that isn't a comparaison in the receiver to the parent of self. Since this method is called in a dead code cleaning processus the parent should only be a statement list or another conditional send"

	| sendToCollect |
	receiver isSend ifFalse: [ ^ self ].
	sendToCollect := OrderedCollection new.
	receiver collectSendInSelf: sendToCollect.
	sendToCollect isNotEmpty ifTrue: [
		self parent
			replaceChild: self
			with: (TStatementListNode statements: sendToCollect) ]
]

{ #category : 'type inference' }
TSendNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	^aCodeGenerator returnTypeForSend: self in: aTMethod ifNil: nil
]
