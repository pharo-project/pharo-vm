"
I implement a Smalltalk
	foo caseOf: { [IntegerConstant | GlobalVariable] -> [expr] }
statement converting it into a C switch statement.  I make some effort to discover identical right-hand-side cases.
"
Class {
	#name : #TSwitchStmtNode,
	#superclass : #TParseNode,
	#instVars : [
		'expression',
		'cases',
		'otherwiseOrNil',
		'switchVariable'
	],
	#category : #'Slang-AST'
}

{ #category : #visiting }
TSwitchStmtNode >> accept: aVisitor [
	
	^ aVisitor visitSwitchStatementNode: self
]

{ #category : #transforming }
TSwitchStmtNode >> asCASTExpressionIn: aBuilder [

	| var ternary |
	ternary := nil.
	self assert: (expression isVariable or: [ switchVariable notNil ]).
	var := [ :i | 
	       switchVariable
		       ifNil: [ expression asCASTIn: aBuilder ]
		       ifNotNil: [ 
			       i = 1
				       ifTrue: [ 
					       CAssignmentNode
						       lvalue: (CIdentifierNode name: switchVariable)
						       rvalue: (expression asCASTIn: aBuilder) ]
				       ifFalse: [ CIdentifierNode name: switchVariable ] ] ].
	cases size to: 1 by: -1 do: [ :i | 
		[ :labels :case | 
		labels size to: 1 by: -1 do: [ :j | 
			ternary := ternary
				           ifNil: [ 
					           (CTernaryNode
						            condition: (CBinaryOperatorNode
								             operator: #==
								             left: (var value: i)
								             right: ((labels at: j) asCASTExpressionIn: aBuilder))
						            then:
							            ((TStatementListNode new
								              setArguments: #(  )
								              statements: case statements) 
								             asCASTExpressionIn: aBuilder)
						            else: (otherwiseOrNil
								             ifNotNil: [ 
									             otherwiseOrNil asCASTExpressionIn: aBuilder ]
								             ifNil: [ 
									             CExpressionListNode new expressions: { 
												             (CCallNode
													              identifier: (CIdentifierNode name: 'error')
													              arguments:
														              { (CStringLiteralNode value:
																               'Case not found and no otherwise clause') }).
												             (CConstantNode value: 0) } ]))
						           printOnMultipleLines: true;
						           yourself ]
				           ifNotNil: [ 
					           (CTernaryNode
						            condition: (CBinaryOperatorNode
								             operator: #==
								             left: (var value: i)
								             right: ((labels at: j) asCASTExpressionIn: aBuilder))
						            then:
							            ((TStatementListNode new
								              setArguments: #(  )
								              statements: case statements) 
								             asCASTExpressionIn: aBuilder)
						            else: ternary)
						           printOnMultipleLines: true;
						           yourself ] ] ] valueWithArguments: (cases at: i) ].
	^ ternary
]

{ #category : #transforming }
TSwitchStmtNode >> asCASTIn: aBuilder [

	| statements |
	statements := CCompoundStatementNode new.
	cases do: [ :tuple | 
		[ :labels :case | 
		| nestedCase statement |
		statement := case asCASTIn: aBuilder.
		labels size to: 1 by: -1 do: [ :i | 
			nestedCase := CLabeledStatementNode
				              case: ((labels at: i) asCASTExpressionIn: aBuilder)
				              statement: (i = labels size
						               ifTrue: [ statement ]
						               ifFalse: [ nestedCase ]) ].
		statements add: nestedCase.
		case endsWithReturn ifFalse: [ 
			statements add: CBreakStatementNode new ] ] valueWithArguments:
			tuple ].
	statements add: (CLabeledStatementNode
			 case: 'default'
			 statement: (otherwiseOrNil 
					  ifNotNil: [ otherwiseOrNil asCASTIn: aBuilder ]
					  ifNil: [ 
						  CCallNode
							  identifier: (CIdentifierNode name: 'error')
							  arguments:
							  { (CStringLiteralNode value:
								   'Case not found and no otherwise clause') } ])).
	^ CSwitchStatementNode
		  if: (expression asCASTExpressionIn: aBuilder)
		  statement: statements
]

{ #category : #transforming }
TSwitchStmtNode >> asCASTIn: aBuilder addToEndOfCases: aNodeToPrependOrNil [

	| statements |
	statements := CCompoundStatementNode new.
	cases do: [ :tuple | 
		[ :labels :case | 
		| nestedCase statement |
		statement := case
			             asCASTIn: aBuilder
			             prependToEnd: aNodeToPrependOrNil.
		labels size to: 1 by: -1 do: [ :i | 
			nestedCase := CLabeledStatementNode
				              case: ((labels at: i) asCASTExpressionIn: aBuilder)
				              statement: (i = labels size
						               ifTrue: [ statement ]
						               ifFalse: [ nestedCase ]) ].
		statements add: nestedCase ] valueWithArguments: tuple.
		(aNodeToPrependOrNil notNil and: [ aNodeToPrependOrNil isReturn ]) 
			ifFalse: [ statements add: CBreakStatementNode new ] ].
	statements add:
		(CLabeledStatementNode case: 'default' statement: (otherwiseOrNil
				  ifNotNil: [ 
				  otherwiseOrNil
					  asCASTIn: aBuilder
					  prependToEnd: aNodeToPrependOrNil ]
				  ifNil: [ 
					  CCallNode
						  identifier: (CIdentifierNode name: 'error')
						  arguments:
						  { (CStringLiteralNode value:
							   'Case not found and no otherwise clause') } ])).
	(otherwiseOrNil isNil and: [ aNodeToPrependOrNil isNotNil ]) ifTrue: [ 
		| defaultExpr type |
		defaultExpr := TConstantNode value: -1.
		(aNodeToPrependOrNil isAssignment and: [ 
			 (type := aBuilder
				          typeFor: aNodeToPrependOrNil variable
				          in: aBuilder currentMethod) notNil and: [ 
				 aBuilder isPointerCType: type ] ]) ifTrue: [ 
			defaultExpr := TSendNode new
				               setSelector: #cCoerceSimple:to:
				               receiver: (TVariableNode new setName: 'self')
				               arguments: { 
						               defaultExpr.
						               (TConstantNode value: type) } ].
		statements add:
			((aNodeToPrependOrNil copy setExpression: defaultExpr) asCASTIn:
				 aBuilder) ].
	^ CSwitchStatementNode
		  if: (expression asCASTExpressionIn: aBuilder)
		  statement: statements
]

{ #category : #transformations }
TSwitchStmtNode >> bindVariableUsesIn: aDictionary [
	expression := expression bindVariableUsesIn: aDictionary.
	cases := (cases collect:
				[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
				{ pair first collect: [:labelNode| labelNode bindVariableUsesIn: aDictionary].
				   pair last bindVariableUsesIn: aDictionary }]).
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil := otherwiseOrNil bindVariableUsesIn: aDictionary]
]

{ #category : #transformations }
TSwitchStmtNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound."
	| newExpression newCases newOtherwise |
	newExpression := expression bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen.
	newCases := cases collect:
					[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
					{ pair first collect: [:labelNode| labelNode bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen].
					   pair last bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen}].
	newOtherwise := otherwiseOrNil ifNotNil:
						[otherwiseOrNil bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen].
	^(newExpression = expression
	   and: [newCases = cases
	   and: [newOtherwise = otherwiseOrNil]])
		ifTrue: [self]
		ifFalse:
			[self shallowCopy
				expression: newExpression;
				cases: newCases;
				otherwiseOrNil: newOtherwise;
				yourself]
]

{ #category : #transformations }
TSwitchStmtNode >> bindVariablesIn: aDictionary [
	expression := expression bindVariablesIn: aDictionary.
	cases := (cases collect:
				[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
				{ pair first collect: [:labelNode| labelNode bindVariablesIn: aDictionary].
				   pair last bindVariablesIn: aDictionary }]).
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil := otherwiseOrNil bindVariablesIn: aDictionary]
]

{ #category : #transformations }
TSwitchStmtNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	expression := expression bindVariablesIn: aDictionary unless: cautionaryBlock.
	cases := (cases collect:
				[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
				{ pair first collect: [:labelNode| labelNode bindVariablesIn: aDictionary unless: cautionaryBlock].
				   pair last bindVariablesIn: aDictionary unless: cautionaryBlock }]).
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil := otherwiseOrNil bindVariablesIn: aDictionary unless: cautionaryBlock]
]

{ #category : #accessing }
TSwitchStmtNode >> cases [
	"Answer the value of cases"

	^ cases
]

{ #category : #accessing }
TSwitchStmtNode >> cases: anObject [
	"Set the value of cases"

	cases := anObject
]

{ #category : #accessing }
TSwitchStmtNode >> children [
	
	^ { expression },
		cases flattened,
		(otherwiseOrNil ifNil: [ #() ] ifNotNil: [ {otherwiseOrNil} ])
]

{ #category : #'instance initialization' }
TSwitchStmtNode >> createCasesFromBraceNode: aTBraceNode [
	"Answer a sequence of tuples of { labels. case } for a TBraceNode, making
	 sure to collect equivalent cases together under a signle sequence of labels."
	| casesToStrings stringsToLabels newCases |
	casesToStrings := Dictionary new.
	stringsToLabels := Dictionary new.
	newCases := OrderedCollection new: aTBraceNode caseLabels size.
	aTBraceNode caseLabels with: aTBraceNode cases do:
		[:label :case| | printString |
		printString := casesToStrings at: case put: case printString.
		(stringsToLabels at: printString ifAbsentPut: [OrderedCollection new]) addLast: label].

	aTBraceNode caseLabels with: aTBraceNode cases do:
		[:label :case| | printString labels |
		printString := casesToStrings at: case.
		label = (labels := (stringsToLabels at: printString) asArray) first ifTrue:
			[newCases addLast: { labels collect: [:ea| ea statements first]. case}]].

	^newCases
]

{ #category : #accessing }
TSwitchStmtNode >> expression [
	"Answer the value of expression"

	^ expression
]

{ #category : #accessing }
TSwitchStmtNode >> expression: anObject [
	"Set the value of expression"

	expression := anObject
]

{ #category : #'instance initialization' }
TSwitchStmtNode >> expression: expr cases: aTBraceNode otherwiseOrNil: otherwiseOrNilNode [

	self expression: expr.
	self cases: (self createCasesFromBraceNode: aTBraceNode).
	self otherwiseOrNil: otherwiseOrNilNode
]

{ #category : #comparing }
TSwitchStmtNode >> isSameAs: anotherNode [

	anotherNode isSwitch ifFalse: [ ^ false ].
	(expression isSameAs: anotherNode expression)
		ifFalse: [ ^ false ].
	
	cases size ~= anotherNode cases size ifTrue: [ ^ false ].
	cases with: anotherNode cases do: [ :case1 :case2 |
		case1 first = case2 first
			ifFalse: [ ^ false ].
		(case1 second isSameAs: case2 second)
			ifFalse: [ ^ false ]
	].

	"Apparently it went ok after all this"
	^ true
]

{ #category : #testing }
TSwitchStmtNode >> isSwitch [
	^true
]

{ #category : #enumerating }
TSwitchStmtNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock.
	cases do:
		[:pair|
		pair first do: [:node| node nodesDo: aBlock].
		pair last nodesDo: aBlock].
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil nodesDo: aBlock].
	aBlock value: self
]

{ #category : #enumerating }
TSwitchStmtNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	expression nodesDo: aBlock parent: self.
	cases do:
		[:pair|
		pair first do: [:node| node nodesDo: aBlock parent: self.].
		pair last nodesDo: aBlock parent: self.].
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil nodesDo: aBlock parent: self].
	aBlock value: self value: parent
]

{ #category : #enumerating }
TSwitchStmtNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	expression nodesDo: aBlock parent: self unless: cautionaryBlock.
	cases do:
		[:pair|
		pair first do: [:node| node nodesDo: aBlock parent: self unless: cautionaryBlock].
		pair last nodesDo: aBlock parent: self unless: cautionaryBlock].
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil nodesDo: aBlock parent: self unless: cautionaryBlock]
]

{ #category : #enumerating }
TSwitchStmtNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	expression nodesDo: aBlock unless: cautionaryBlock.
	cases do:
		[:pair|
		pair first do: [:node| node nodesDo: aBlock unless: cautionaryBlock].
		pair last nodesDo: aBlock unless: cautionaryBlock].
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil nodesDo: aBlock unless: cautionaryBlock]
]

{ #category : #accessing }
TSwitchStmtNode >> otherwiseOrNil [
	"Answer the value of otherwiseOrNil"

	^ otherwiseOrNil
]

{ #category : #accessing }
TSwitchStmtNode >> otherwiseOrNil: anObject [
	"Set the value of otherwiseOrNil"

	otherwiseOrNil := anObject
]

{ #category : #copying }
TSwitchStmtNode >> postCopy [
	expression := expression copy.
	cases := (cases collect:
				[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
				{ pair first collect: [:labelNode| labelNode copy].
				   pair last copy }]).
	otherwiseOrNil := otherwiseOrNil copy
]

{ #category : #printing }
TSwitchStmtNode >> printOn: aStream level: level [

	aStream crtab: level.
	aStream nextPutAll: 'switch ('.
	expression printOn: aStream level: level.
	aStream nextPutAll: ') {'.
	cases do:
		[:tuple|
		 [:labels :case|
		  labels do:
			[:label|
			 aStream
				crtab: level;
				nextPutAll: 'case '.
			label printOn: aStream level: level + 1.
			aStream nextPut: $:].
		  aStream crtab: level + 1.
		  case printOn: aStream level: level + 1.
		  aStream crtab: level + 1; nextPutAll: 'break;']
			valueWithArguments: tuple].
	otherwiseOrNil ifNotNil:
		[aStream
			crtab: level;
			nextPutAll: 'default:';
			crtab: level + 1.
		 otherwiseOrNil printOn: aStream level: level + 1].
	aStream
		crtab: level;
		nextPut: $}
]

{ #category : #transformations }
TSwitchStmtNode >> removeAssertions [
	expression removeAssertions.
	cases do:
		[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
		pair first do: [:labelNode| labelNode removeAssertions].
		pair last removeAssertions].
	otherwiseOrNil ifNotNil:
		[otherwiseOrNil removeAssertions]
]

{ #category : #transformations }
TSwitchStmtNode >> replaceNodesIn: aDictionary [
	^aDictionary
		at: self
		ifAbsent:
			[expression := expression replaceNodesIn: aDictionary.
			 cases := (cases collect:
						[:pair| "<Array with: <Array with: ParseTreeNode> with: TStmtListNode"
						{ pair first collect: [:labelNode| labelNode replaceNodesIn: aDictionary].
						   pair last replaceNodesIn: aDictionary }]).
			 otherwiseOrNil ifNotNil:
				[otherwiseOrNil := otherwiseOrNil replaceNodesIn: aDictionary].
			 self]
]

{ #category : #accessing }
TSwitchStmtNode >> switchVariable [
	"Answer the value of switchVariable"

	^ switchVariable
]

{ #category : #accessing }
TSwitchStmtNode >> switchVariable: anObject [
	"Set the value of switchVariable"

	switchVariable := anObject
]
