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
CSlangPrettyPrinter >> visitArrayDeclarator: anArrayDeclarator [

	anArrayDeclarator declarator acceptVisitor: self.
	stream nextPut: $[.
	anArrayDeclarator size ifNotNil: [ :size |
		stream nextPutAll: size asString ].
	stream nextPut: $]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitAssignment: anAssignment [

	anAssignment lvalue acceptVisitor: self.
	stream
		nextPutAll: ' ';
		nextPutAll: anAssignment operator;
		nextPutAll: ' '.
	
	(anAssignment rvalue isConstant or: [ anAssignment rvalue isIdentifier ])
		ifFalse: [ stream nextPutAll: '(' ].
	anAssignment rvalue acceptVisitor: self.

	(anAssignment rvalue isConstant or: [ anAssignment rvalue isIdentifier ])
		ifFalse: [ stream nextPutAll: ')' ].
]

{ #category : #generated }
CSlangPrettyPrinter >> visitBinary: aBinary [
	| leftParenthesises rightParenthesises |
	
	leftParenthesises := (aBinary left isConstant or: [ aBinary left isIdentifier ]).
	rightParenthesises := (aBinary right isConstant or: [ aBinary right isIdentifier ]).
	
	leftParenthesises ifFalse: [ stream nextPutAll: '(' ].
	aBinary left acceptVisitor: self.
	leftParenthesises ifFalse: [ stream nextPutAll: ')' ].
	
	stream
		nextPutAll: ' ';
		nextPutAll: aBinary operator;
		nextPutAll: ' '.
		
	rightParenthesises ifFalse: [ stream nextPutAll: '(' ].
	aBinary right acceptVisitor: self.
	rightParenthesises ifFalse: [ stream nextPutAll: ')' ].
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

	stream nextPut: $(.
	aCastExpression type acceptVisitor: self.
	stream nextPut: $).
	stream nextPut: $(.
	aCastExpression expression acceptVisitor: self.
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitCompoundStatement: aCompoundStatement [

	aCompoundStatement needsBrackets ifTrue: [ 
		stream
			tab: level;
			nextPutAll: '{'.

		level := level + 1.
		stream crtab: level ].

	aCompoundStatement declarations , aCompoundStatement statements
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ 
			stream nextPut: $;.
			stream crtab: level ].

	aCompoundStatement needsBrackets ifTrue: [ 
		stream nextPut: $;.
		level := level - 1.
		stream
			crtab: level;
			nextPut: $}.
		aCompoundStatement needsCarriageReturn ifTrue: [ stream cr ] ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitConstant: aConstant [

	stream nextPutAll: aConstant value asString
]

{ #category : #generated }
CSlangPrettyPrinter >> visitDeclaration: aDeclaration [

	aDeclaration specifiers
		do: [ :e | 
			stream nextPutAll: e.
			stream space ].
	
	aDeclaration declarators
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
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
	anIf then acceptVisitor: self.
	anIf else ifNotNil: [ :e | 
		stream nextPutAll: 'else '.
		e acceptVisitor: self ]
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
CSlangPrettyPrinter >> visitReturnStatement: aReturn [

	stream nextPutAll: 'return'.
	aReturn expression ifNotNil: [ :exp |
		stream space.
		exp acceptVisitor: self ]
]

{ #category : #generated }
CSlangPrettyPrinter >> visitTernary: aTarnary [

	stream nextPutAll: '(('.
	aTarnary condition acceptVisitor: self.
	stream nextPutAll: ') ? '.
	aTarnary then acceptVisitor: self.
	stream nextPutAll: ' : '.
	aTarnary else acceptVisitor: self.
	stream nextPut: $)
]

{ #category : #generated }
CSlangPrettyPrinter >> visitTypename: aTypename [

	stream nextPutAll: aTypename symbol
]

{ #category : #generated }
CSlangPrettyPrinter >> visitUnaryOperator: anUnary [
	| parenthesises |
	
	parenthesises := (anUnary expression isConstant or: [ anUnary expression isIdentifier ]).
	stream nextPutAll: anUnary operator.
	parenthesises ifFalse: [ stream nextPut: $( ].
	anUnary expression acceptVisitor: self.
	parenthesises ifFalse: [ stream nextPut: $) ].
]

{ #category : #accessing }
CSlangPrettyPrinter >> writeStream: aWriteStream [

	stream := aWriteStream 
]
