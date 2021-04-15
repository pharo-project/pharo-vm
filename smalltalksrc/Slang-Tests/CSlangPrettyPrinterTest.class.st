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
CSlangPrettyPrinterTest >> testVisitCall [

	| print |
	print := self prettyPrint: (CCallNode identifier: (CIdentifierNode name: 'toto')
	arguments: { CIdentifierNode name: 'x' . CIdentifierNode name: 'y'}).
	
	self assert: print equals: 'toto(x, y)'


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
