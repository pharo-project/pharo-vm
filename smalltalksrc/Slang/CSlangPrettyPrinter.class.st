Class {
	#name : #CSlangPrettyPrinter,
	#superclass : #CAbstractNodeVisitor,
	#instVars : [
		'stream',
		'level'
	],
	#category : #'Slang-AST'
}

{ #category : #accessing }
CSlangPrettyPrinter >> contents [
	
	^ stream contents
]

{ #category : #initialization }
CSlangPrettyPrinter >> initialize [

	super initialize.
	stream := '' writeStream.
	level := 0
]

{ #category : #generated }
CSlangPrettyPrinter >> printExpression: cAST [

	(cAST isLeaf
		"Cast expressions already contain their own parentheses"
		or: [ cAST isCastExpression 
			"An unary expression that has a leaf expression dosen't need parentheses aroud expression"
			or: [cAST isUnaryOperation and: [cAST expression isLeaf or: [ cAST needsParentheses]]]])
		ifTrue: [ cAST acceptVisitor: self ]
		ifFalse: [ 
			stream nextPut: $(.
			cAST acceptVisitor: self.
			stream nextPut: $) ]
	
]

{ #category : #generated }
CSlangPrettyPrinter >> visitArray: anArrayAcess [

	anArrayAcess array acceptVisitor: self.
	stream nextPut: $[.
	anArrayAcess index acceptVisitor: self.
	stream nextPut: $]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitArrayDeclarator: anArrayDeclarator [

	anArrayDeclarator declarator acceptVisitor: self.
	stream nextPut: $[.
	anArrayDeclarator size ifNotNil: [ :size |
		stream nextPutAll: size asString ].
	stream nextPut: $]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitArrow: aPointerAccess [

	aPointerAccess needsParentheses ifTrue:  [ stream nextPut: $(].
	self printExpression: aPointerAccess structurePointer.
	stream nextPutAll: '->'.
	aPointerAccess member acceptVisitor: self.
	aPointerAccess needsParentheses ifTrue:  [ stream nextPut: $)].
]

{ #category : #generated }
CSlangPrettyPrinter >> visitAssignment: anAssignment [

	anAssignment needsParentheses ifTrue: [ stream nextPut: $( ].
	anAssignment lvalue acceptVisitor: self.
	stream
		nextPutAll: ' ';
		nextPutAll: anAssignment operator;
		nextPutAll: ' '.
	anAssignment rvalue acceptVisitor: self.
	anAssignment needsParentheses ifTrue: [ stream nextPut: $) ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitBinary: aBinary [
	
	aBinary needsParentheses ifTrue: [ stream nextPut: $( ].
	self printExpression: aBinary left.
	
	stream
		nextPutAll: ' ';
		nextPutAll: aBinary operator;
		nextPutAll: ' '.
		
	self printExpression: aBinary right.
	aBinary needsParentheses ifTrue: [ stream nextPut: $) ].
]

{ #category : #generated }
CSlangPrettyPrinter >> visitBreakStatement: aBreakStatement [

	stream nextPutAll: 'break'
]

{ #category : #generated }
CSlangPrettyPrinter >> visitCall: aCall [
	
	
	stream nextPutAll: (aCall identifier name).
	stream nextPutAll: '('.
	aCall arguments do: [ :arg | arg acceptVisitor: self ] separatedBy: [ stream nextPutAll: ', '].
	stream nextPutAll: ')'.
		
]

{ #category : #generated }
CSlangPrettyPrinter >> visitCastExpression: aCastExpression [

	| nbParentheses |
	nbParentheses := aCastExpression needsParentheses ifTrue: [ 2 ] ifFalse: [ 1 ].
	"Wrap everything between parentheses to avoid ambiguities"
	stream next: nbParentheses put: $(.
	
	"Print the type between parentheses"
	stream nextPut: $(.
	aCastExpression type acceptVisitor: self.
	stream nextPutAll: ') '.
	
	"Print the expression to cast"
	self printExpression: aCastExpression expression.
	stream space.
	stream next: nbParentheses put: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitComment: aComment [

	stream nextPutAll: '/* '.
	stream nextPutAll: aComment comment.
	stream nextPutAll: ' */'
]

{ #category : #generated }
CSlangPrettyPrinter >> visitCompoundStatement: aCompoundStatement [

	aCompoundStatement needsBrackets ifTrue: [ 
		stream nextPutAll: '{'.

		level := level + 1.
		stream crtab: level ].

	aCompoundStatement declarations , aCompoundStatement statements
		do: [ :e | 
			e acceptVisitor: self.
			e needsSeparator ifTrue: [ stream nextPut: $; ] ]
		separatedBy: [ stream crtab: level ].

	aCompoundStatement needsBrackets ifTrue: [ 
		level := level - 1.
		stream
			crtab: level;
			nextPut: $} ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitConstant: aConstant [

	stream nextPutAll: aConstant value asString
]

{ #category : #generated }
CSlangPrettyPrinter >> visitDeclaration: aDeclaration [

	aDeclaration specifiers do: [ :e | 
		stream nextPutAll: e.
		stream space ].

	aDeclaration hasRawPrototype ifFalse: [ 
		aDeclaration declarators
			do: [ :e | e acceptVisitor: self ]
			separatedBy: [ stream nextPutAll: ', ' ] ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitDeclarator: aDeclarator [

	aDeclarator qualifiers
		do: [ :e | 
			stream nextPutAll: e.
			stream space ].
	
	aDeclarator pointers
		do: [ :e | stream nextPutAll: e ].
	
	aDeclarator declarator acceptVisitor: self
]

{ #category : #generated }
CSlangPrettyPrinter >> visitDecrement: anDecrementNode [
	| visit |
	visit := [ anDecrementNode object acceptVisitor: self ].
	anDecrementNode prefix ifFalse: visit.
	stream nextPutAll: '--'.
	anDecrementNode prefix ifTrue: visit.
]

{ #category : #generated }
CSlangPrettyPrinter >> visitDoStatement: aDoStatement [

	stream nextPutAll: 'do'.
	aDoStatement statement acceptVisitor: self.
	stream nextPutAll: 'while('.
	aDoStatement while acceptVisitor: self.
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitEmptyStatement: anEmptyStatement [
	"Nothing to print."
]

{ #category : #generated }
CSlangPrettyPrinter >> visitExpressionList: anExpressionList [

	stream nextPut: $(.
	anExpressionList expressions
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ 
			stream nextPutAll: ', '.
			anExpressionList printOnMultipleLines ifTrue: [ stream cr ] ].
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitForStatement: aForStatement [

	stream nextPutAll: 'for ('.
	aForStatement init
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: '; '.
	aForStatement until acceptVisitor: self.
	stream nextPutAll: '; '.
	aForStatement step
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: ') '.
	aForStatement statement acceptVisitor: self
]

{ #category : #generated }
CSlangPrettyPrinter >> visitFunctionDeclarator: aFunctionDeclarator [

	aFunctionDeclarator declarator acceptVisitor: self.
	stream nextPut: $(.
	aFunctionDeclarator parameters
		do: [ :arg | arg acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitFunctionDefinition: aFunction [

	aFunction specifiers
		do: [ :e | stream nextPutAll: e ]
		separatedBy: [ stream space ].
	stream cr.
	aFunction hasRawPrototype ifFalse: [ 
		aFunction declarator acceptVisitor: self ].
	stream cr.
	aFunction body acceptVisitor: self
]

{ #category : #generated }
CSlangPrettyPrinter >> visitGotoStatement: aGoToStatement [

	stream nextPutAll: 'goto ';
			 nextPutAll: aGoToStatement label name
	
]

{ #category : #generated }
CSlangPrettyPrinter >> visitIdentifier: anIdentifier [

	stream nextPutAll: anIdentifier name
]

{ #category : #generated }
CSlangPrettyPrinter >> visitIfStatement: anIf [

	stream nextPutAll: 'if ('.
	anIf if acceptVisitor: self.
	stream nextPutAll: ') '.
	anIf then isCompoundStatement ifFalse: [ stream crtab: level + 1 ].
	anIf then acceptVisitor: self.
	anIf then needsTrailingSemicolon ifTrue: [ stream nextPut: $; ].
	anIf else ifNotNil: [ :e | 
		anIf then isCompoundStatement ifFalse: [ stream crtab: level ].
		stream nextPutAll: ' else '.
		anIf else isCompoundStatement ifFalse: [ stream crtab: level + 1 ].
		e acceptVisitor: self.
		anIf else needsTrailingSemicolon ifTrue: [ stream nextPut: $; ]]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitIncrement: anIncrementNode [
	| visit |
	visit := [ anIncrementNode object acceptVisitor: self ].
	anIncrementNode prefix ifFalse: visit.
	stream nextPutAll: '++'.
	anIncrementNode prefix ifTrue: visit.
]

{ #category : #generated }
CSlangPrettyPrinter >> visitInitDeclarator: anInitDeclarator [

	anInitDeclarator declarator acceptVisitor: self.
	stream nextPutAll: ' = '.
	anInitDeclarator initializer acceptVisitor: self.
]

{ #category : #generated }
CSlangPrettyPrinter >> visitInitializer: anInitializer [

	stream
		nextPut: ${;
		crtab: level + 1.
	anInitializer initializers
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream crtab: level.
	stream nextPut: $}
]

{ #category : #generated }
CSlangPrettyPrinter >> visitLabeledStatement: aLabeledStatement [

	aLabeledStatement case = 'default'
		ifTrue: [ stream nextPutAll: 'default' ]
		ifFalse: [ stream
			nextPutAll: 'case ';
			print: aLabeledStatement case ].
	
	stream
		nextPutAll: ':';
		crtab: level.
	aLabeledStatement statement acceptVisitor: self.
]

{ #category : #generated }
CSlangPrettyPrinter >> visitParameterDeclaration: aParameter [

	"aParameter specifiers
		do: [ :e | stream nextPutAll: e ]
		separatedBy: [ stream space ].
	stream space.
	aParameter declarator acceptVisitor: self"
	stream nextPutAll: aParameter rawDeclaration 
]

{ #category : #generated }
CSlangPrettyPrinter >> visitPoint: aMemberAccess [

	aMemberAccess needsParentheses ifTrue:  [ stream nextPut: $(].
	self printExpression: aMemberAccess object.
	stream nextPut: $..
	aMemberAccess member acceptVisitor: self.
	aMemberAccess needsParentheses ifTrue:  [ stream nextPut: $)].
]

{ #category : #generated }
CSlangPrettyPrinter >> visitPreprocessorIf: anIf [

	stream nextPutAll: '#if '.
	anIf if acceptVisitor: self.
	stream cr.
	anIf then acceptVisitor: self.
	anIf else ifNotNil: [ :e | 
		stream cr; nextPutAll: '#else /* '.
		anIf if acceptVisitor: self.
		stream
			nextPutAll: ' */';
			cr.
		e acceptVisitor: self ].
	stream cr; nextPutAll: '#endif /* '.
	anIf if acceptVisitor: self.
	stream
		nextPutAll: ' */';
		cr
]

{ #category : #visiting }
CSlangPrettyPrinter >> visitRawCode: aCRawCodeNode [ 
	
	stream nextPutAll: aCRawCodeNode code asString
]

{ #category : #generated }
CSlangPrettyPrinter >> visitReturnStatement: aReturn [

	stream nextPutAll: 'return'.
	aReturn expression ifNotNil: [ :exp |
		stream space.
		exp acceptVisitor: self ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitStringLiteral: aStringLiteral [

	aStringLiteral needsDoubleQuotes ifTrue: [ stream nextPut: $" ].
	stream nextPutAll: aStringLiteral value.
	aStringLiteral needsDoubleQuotes ifTrue: [ stream nextPut: $" ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitSwitchStatement: aSwitchStatement [

	stream nextPutAll: 'switch ('.
	aSwitchStatement if acceptVisitor: self.
	stream nextPutAll: ') '.
	aSwitchStatement statement acceptVisitor: self.
]

{ #category : #generated }
CSlangPrettyPrinter >> visitTernary: aTernary [

	stream nextPutAll: '(('.
	aTernary condition acceptVisitor: self.
	stream nextPut: $).
	aTernary printOnMultipleLines ifTrue: [ stream crtab: level + 1 ].
	stream nextPutAll: ' ? '.
	aTernary then acceptVisitor: self.
	aTernary printOnMultipleLines ifTrue: [ stream crtab: level + 1 ].
	stream nextPutAll: ' : '.
	aTernary else acceptVisitor: self.
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitTypename: aTypename [

	stream nextPutAll: aTypename symbol
]

{ #category : #generated }
CSlangPrettyPrinter >> visitUnaryOperator: anUnary [

	| avoidParentheses |
	anUnary needsParentheses ifTrue: [ stream nextPut: $( ].
	avoidParentheses := anUnary expression isCastExpression
		or: [ anUnary expression isConstant or: [
			anUnary expression isIdentifier  or: [ anUnary expression isLeaf]]].
	stream nextPutAll: anUnary operator.
	avoidParentheses ifFalse: [ stream nextPut: $( ].
	anUnary expression acceptVisitor: self.
	avoidParentheses ifFalse: [ stream nextPut: $) ].
	anUnary needsParentheses ifTrue: [ stream nextPut: $) ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitWhileStatement: aWhileStatement [

	stream nextPutAll: 'while ('.
	aWhileStatement while acceptVisitor: self.
	stream nextPutAll: ') '.
	aWhileStatement statement acceptVisitor: self
]

{ #category : #accessing }
CSlangPrettyPrinter >> writeStream: aWriteStream [

	stream := aWriteStream 
]
