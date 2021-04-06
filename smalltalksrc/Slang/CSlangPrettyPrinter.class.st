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
CSlangPrettyPrinter >> visitCompoundStatement: aCompoundStatement [

	aCompoundStatement needsBrackets ifTrue: [
		stream
			crtab: level;
			nextPutAll: '{'.
	
		level := level + 1.
		stream crtab: level ].
	
	aCompoundStatement declarations,
		aCompoundStatement statements
			do: [ :e | e acceptVisitor: self ]
			separatedBy: [ 
				stream nextPut: $;.
				stream crtab: level ].
	
	aCompoundStatement needsBrackets ifTrue: [
		stream nextPut: $;.
		level := level - 1.
		stream crtab: level; nextPut: $}; cr
	]
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
CSlangPrettyPrinter >> visitIdentifier: anIdentifier [

	stream nextPutAll: anIdentifier name
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

{ #category : #accessing }
CSlangPrettyPrinter >> writeStream: aWriteStream [

	stream := aWriteStream 
]
