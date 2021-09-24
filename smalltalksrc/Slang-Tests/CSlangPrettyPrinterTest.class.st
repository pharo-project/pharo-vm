"
A CSlangPrettyPrinterTest is a test class for testing the behavior of CSlangPrettyPrinter
"
Class {
	#name : #CSlangPrettyPrinterTest,
	#superclass : #TestCase,
	#category : #'Slang-Tests-AST'
}

{ #category : #'initialize-release' }
CSlangPrettyPrinterTest >> prettyPrint: cAST [

	| prettyPrinter |
	prettyPrinter := CSlangPrettyPrinter new.
	
	^ String streamContents: [ :str | 
		prettyPrinter writeStream: str.
		cAST acceptVisitor: prettyPrinter. ]
	
]

{ #category : #running }
CSlangPrettyPrinterTest >> setUp [
	super setUp.
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitArray [

	| print |
	print := self prettyPrint: (CArrayAccessNode array: (CIdentifierNode name: 'tab') index: (CConstantNode value: 7)).
	
	self assert: print equals: 'tab[7]'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitArrayDeclarator [

	| print |
	print := self prettyPrint: (CArrayDeclaratorNode identifier: 'aLiteralArray').
	
	self assert: print equals: 'aLiteralArray[]'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitArrow [

	| print |
	print := self prettyPrint: (CStructurePointerAccessNode structurePointer: (CIdentifierNode name: 'myStruct') member: (CIdentifierNode name: 'field1')).
	
	self assert: print equals: 'myStruct->field1'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitAssignment [

	| print |
	print := self prettyPrint: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2)).
	
	self assert: print equals: 'toto = 2'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitBinary [

	| print |
	print := self prettyPrint: (
		CBinaryOperatorNode operator: #+
			left: (CIdentifierNode name: 'x')
			right: (CBinaryOperatorNode operator: #- 
						left: (CIdentifierNode name: 'y') 
						right: (CConstantNode value: 10))).
	
	self assert: print equals: 'x + (y - 10)'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitBreakStatement [

	| print |
	print := self prettyPrint: (CBreakStatementNode new).

	self assert: print trimBoth equals: 'break'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitCall [

	| print |
	print := self prettyPrint: (CCallNode identifier: (CIdentifierNode name: 'toto')
	arguments: { CIdentifierNode name: 'x' . CIdentifierNode name: 'y'}).
	
	self assert: print equals: 'toto(x, y)'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitCastExpression [

	| print |
	print := self prettyPrint:
		         (CCastExpressionNode
			          type: (CTypeNameNode symbol: 'int')
			          expression: (CBinaryOperatorNode
					           operator: #+
					           left: (CConstantNode value: 1)
					           right: (CIdentifierNode name: 'x'))).

	self assert: print equals: '((int) (1 + x) )'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitCastExpressionDouble [

	| print |
	print := self prettyPrint: (CBinaryOperatorNode
			          operator: #/
			          left: (CCastExpressionNode
					           type: (CTypeNameNode symbol: 'double')
					           expression: (CIdentifierNode name: 'a'))
			          right: (CIdentifierNode name: 'b')).


	self assert: print equals: '((double) a ) / b'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitComment [

	| print |
	print := self prettyPrint: (CCommentNode comment: ' a kind comment for the developper :3 ').
	
	self assert: print equals: '/* a kind comment for the developper :3 */'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitCompoundStatement [

	| print |
	print := self prettyPrint: (CCompoundStatementNode
			  declarations: { (CAssignmentNode
						lvalue: (CIdentifierNode name: 'toto')
						rvalue: (CConstantNode value: '99')) }
			  statements: { (CAssignmentNode
					   lvalue: (CIdentifierNode name: 'toto')
					   rvalue: (CIdentifierNode name: 'tutu')) }).
	
	self assert: print trimBoth equals: '{
	toto = 99;

	toto = tutu;
}'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitConstant [

	| print |
	print := self prettyPrint: (CConstantNode value: 7).
	
	self assert: print equals: '7'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitDeclaration [

	| print |
	print := self prettyPrint: (CDeclarationNode
					   specifiers: { 'static' . 'int' }
					   declarators: {(CInitDeclaratorNode
							    declarator: (CArrayDeclaratorNode identifier: 'toto')
							    initializer: (CGLRInitializerNode initializers: {
														CConstantNode value: 9.
														CConstantNode value: 10.
														CConstantNode value: 12
														})).
											(CInitDeclaratorNode
							    declarator: (CArrayDeclaratorNode identifier: 'tutu')
							    initializer: (CGLRInitializerNode initializers: {
														CConstantNode value: 5.
														CConstantNode value: 2
														})).
									}).
	
	self assert: print equals: 'static int toto[] = {
	9, 10, 12
}, tutu[] = {
	5, 2
}'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitDeclarator [

	| print |
	print := self prettyPrint: (CPointerDeclaratorNode declarator: (CIdentifierNode name: 'toto') pointers: 1).
	
	self assert: print equals: '*toto'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitDecrement [

	| print |
	print := self prettyPrint: (CDecrementNode object: (CIdentifierNode name: 'i')).
	
	self assert: print equals: 'i--'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitDoStatement [

	| print compound |
	compound := (CCompoundStatementNode statements: { CConstantNode value: 15 }).
	print := self prettyPrint: (CDoStatementNode
			          while: (CBinaryOperatorNode
					           operator: #&&
					           left: (CIdentifierNode name: 'a')
					           right: (CIdentifierNode name: 'b'))
			          statement: compound).

	self assert: print trimBoth equals: 'do{
	15;
}while(a && b)'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitEmptyStatement [

	| print |
	print := self prettyPrint: CEmptyStatementNode new.
	
	self assert: print equals: ''


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitExpressionList [

	| print |
	print := self prettyPrint: (CExpressionListNode new expressions:
			          { (CCallNode
				           identifier: (CIdentifierNode name: 'foo')
				           arguments: { 
						           (CConstantNode value: 1).
						           (CConstantNode value: 2) }).
						(CCallNode
				           identifier: (CIdentifierNode name: 'foo')
				           arguments: { 
						           (CConstantNode value: 3).
						           (CConstantNode value: 4) }).
						(CCallNode
				           identifier: (CIdentifierNode name: 'foo')
				           arguments: { 
						           (CConstantNode value: 5).
						           (CConstantNode value: 6) }) }).

	self assert: print trimBoth equals: '(foo(1, 2), foo(3, 4), foo(5, 6))'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitForStatement [

	| print init init2 until step step2 for |
	init := CAssignmentNode
		        lvalue: (CIdentifierNode name: 'i')
		        rvalue: (CConstantNode value: 1).
	init2 := CAssignmentNode
		         lvalue: (CIdentifierNode name: 'j')
		         rvalue: (CConstantNode value: 2).
	until := CBinaryOperatorNode
		         operator: #<=
		         left: (CIdentifierNode name: 'i')
		         right: (CConstantNode value: 10).
	step := CIncrementNode object: (CIdentifierNode name: 'i').
	step2 := CIncrementNode object: (CIdentifierNode name: 'j').
	for := CForStatementNode
		       init: { init. init2 }
		       until: until
		       step: { step. step2 }
		       statement: (CCompoundStatementNode statements: { 
					        (CAssignmentNode
						         lvalue: (CIdentifierNode name: 'a')
						         rvalue: (CBinaryOperatorNode
								          operator: #%
								          left: (CIdentifierNode name: 'i')
								          right: (CConstantNode value: 2))).
					        (CIncrementNode object: (CIdentifierNode name: 'j')) }).
	print := self prettyPrint: for.

	self assert: print trimBoth equals: 'for (i = 1, j = 2; i <= 10; i++, j++) {
	a = i % 2;
	j++;
}'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitFunctionDefinition [

	| print |
	print := self prettyPrint: (CFunctionDefinitionNode
			          declarator: (CFunctionDeclaratorNode
					           declarator: (CIdentifierNode name: 'foo')
					           parameters: { (CParameterDeclarationNode
							            declarator: (CIdentifierNode name: 'x')
							            specifiers:  { 'int' }) })
			          body: CCompoundStatementNode new
			          specifiers: { 'static'. 'int' }).

	self assert: print trimBoth equals: 'static int
foo(int x)
{
}'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitGotoStatement [

	| print |
	print := self prettyPrint: (CGotoStatementNode identifier: 'toto').
	
	self assert: print equals: 'goto toto'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitIdentifier [

	| print |
	print := self prettyPrint: (CIdentifierNode name: 'toto').
	
	self assert: print equals: 'toto'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitIfStatement [

	| print |
	print := self prettyPrint: (CIfStatementNode
			          if: (CBinaryOperatorNode
					           operator: #&&
					           left: (CIdentifierNode name: 'a')
					           right: (CIdentifierNode name: 'b'))
			          then: (CCompoundStatementNode
					           declarations: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CConstantNode value: 99)) }
					           statements: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CIdentifierNode name: 'tutu')) })
						else: (CCompoundStatementNode
					           declarations: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CConstantNode value: 1)) }
					           statements: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'tutu')
							            rvalue: (CIdentifierNode name: 'toto')) })).

	self assert: print trimBoth equals: 'if (a && b) {
	toto = 99;

	toto = tutu;
} else {
	toto = 1;

	tutu = toto;
}'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitIncrement [

	| print |
	print := self prettyPrint: (CIncrementNode object: (CIdentifierNode name: 'i')).
	
	self assert: print equals: 'i++'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitInitDeclarator [

	| print |
	print := self prettyPrint: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '99')).
	
	self assert: print equals: 'toto = 99'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitInitializer [

	| print |
	print := self prettyPrint: (CGLRInitializerNode initializers: 
		{(CConstantNode value: 0) . (CConstantNode value: 1) . (CConstantNode value: 2)} ).
	
	self assert: print equals: '{
	0, 1, 2
}'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitParameterDeclaration [

	| print |
	print := self prettyPrint: ((CParameterDeclarationNode
							            declarator: (CIdentifierNode name: 'x')
							            specifiers: {'unsigned'. 'int'})).

	self assert: print equals: 'unsigned int x'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitParameterRawDeclaration [

	| print |
	print := self prettyPrint: ((CParameterDeclarationNode
							            declarator: (CIdentifierNode name: 'x')
							            cDeclaration: 'unsigned int x')).

	self assert: print equals: 'unsigned int x'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPoint [

	| print |
	print := self prettyPrint: (CMemberAccessNode object: (CIdentifierNode name: 'myStruct') member: (CIdentifierNode name: 'field1')).
	
	self assert: print equals: 'myStruct.field1'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPreIncrement [

	| print |
	print := self prettyPrint: (CIncrementNode object: (CIdentifierNode name: 'i') prefix: true).
	
	self assert: print equals: '++i'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPreprocessorDefine [

	| print |
	print := self prettyPrint: (CPreprocessorDefineNode
			          token: (CIdentifierNode name: 'MASK')
			          expression: (CConstantNode value: 10)).

	self assert: print equals: '#define MASK 10'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPreprocessorDefineWithRawExpression [

	| print |
	print := self prettyPrint: (CPreprocessorDefineNode
			          token: (CIdentifierNode name: 'failedFunctionDefinition')
			          rawMacro: '(void (*)(void))0').

	self
		assert: print
		equals: '#define failedFunctionDefinition (void (*)(void))0'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPreprocessorIf [

	| print |
	print := self prettyPrint: (CPreprocessorIfNode
			          if: (CBinaryOperatorNode
					           operator: #&&
					           left: (CIdentifierNode name: 'a')
					           right: (CIdentifierNode name: 'b'))
			          then: (CCompoundStatementNode
					           declarations: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CConstantNode value: 99)) }
					           statements: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CIdentifierNode name: 'tutu')) })
						else: (CCompoundStatementNode
					           declarations: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'toto')
							            rvalue: (CConstantNode value: 1)) }
					           statements: { (CAssignmentNode
							            lvalue: (CIdentifierNode name: 'tutu')
							            rvalue: (CIdentifierNode name: 'toto')) })).

	self assert: print trimBoth equals: '#if a && b
{
	toto = 99;

	toto = tutu;
}
#else /* a && b */
{
	toto = 1;

	tutu = toto;
}
#endif /* a && b */'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitPreprocessorIfOfSimpleStatementsAddsSeparator [

	| print |
	print := self prettyPrint: (CPreprocessorIfNode
			          if: (CConstantNode value: #condition)
			          then: (CCompoundStatementNode statements: {
							(CAssignmentNode
								lvalue: (CIdentifierNode name: 'toto')
								rvalue: (CConstantNode value: 99)) })
						else: (CCompoundStatementNode statements: {
							(CAssignmentNode
				            lvalue: (CIdentifierNode name: 'toto')
				            rvalue: (CConstantNode value: 100)) })).

	self assert: print trimBoth equals: '#if condition
{
	toto = 99;
}
#else /* condition */
{
	toto = 100;
}
#endif /* condition */'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitReturnStatement [

	| print |
	print := self prettyPrint: (CReturnStatementNode expression: (CIdentifierNode name: 'x')).
	
	self assert: print equals: 'return x'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitStringLiteral [

	| print |
	print := self prettyPrint: (CStringLiteralNode value: 'You are breathtaking!').

	self assert: print equals: '"You are breathtaking!"'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitTernary [

	| print |
	print := self prettyPrint: (CTernaryNode
			          condition: (CBinaryOperatorNode
					           operator: #&&
					           left: (CIdentifierNode name: 'a')
					           right: (CIdentifierNode name: 'b'))
			          then: (CConstantNode value: 0)
						else: (CConstantNode value: 1)).

	self assert: print trimBoth equals: '((a && b) ? 0 : 1)'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitTypename [

	| print |
	print := self prettyPrint: (CTypeNameNode symbol: 'int').

	self assert: print equals: 'int'
]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitUnaryOperator [

	| print |
	print := self prettyPrint: (
		CUnaryOperatorNode operator: #-
			expression: (CBinaryOperatorNode operator: #-
								left:  (CConstantNode value: 1)
								right: (CConstantNode value: 2))).
	
	self assert: print equals: '-(1 - 2)'


]

{ #category : #'tests-visitor' }
CSlangPrettyPrinterTest >> testVisitWhileStatement [

	| print |
	print := self prettyPrint: (CWhileStatementNode
			          while: (CBinaryOperatorNode
					           operator: #&&
					           left: (CIdentifierNode name: 'a')
					           right: (CIdentifierNode name: 'b'))
			          statement: (CCompoundStatementNode statements: { CConstantNode value: 15 })).

	self assert: print trimBoth equals: 'while (a && b) {
	15;
}'
]
