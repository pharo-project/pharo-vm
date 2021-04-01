"
A few tests to explore the ambiguity of a GLR grammar.


"
Class {
	#name : #CASTParserTests,
	#superclass : #TestCase,
	#category : #'CAST-Tests'
}

{ #category : #examples }
CASTParserTests class >> ambiguityAsAttribute [
	<example>
	| block |
	block := [ :in :others | 
	in
		ifNotNil: [ in isCollection
				ifTrue: [ 1 to: in size do:
						[ :i | block value: (in at: i) value: (others collect: [ :e | e at: i ]) ] ]
				ifFalse: [ others do: [ :i | in ambiguous: i ] ] ] ].
	^ [ CASTParser
		parse:
			' void f(int i) {
	i * i;
} ' ]
		on: SmaCCAmbiguousResultNotification
		do: [ :ex | 
			| results |
			results := ex tag
				collect: [ :t | t performOnSmaCCParser: ex parser ].
			block value: results first value: results allButFirst.
			ex resume: results first ]
]

{ #category : #examples }
CASTParserTests class >> ambiguityAsAttribute2 [
	<example>
	| block |
	block := [ :in :others | 
	in
		ifNotNil: [ in isCollection
				ifTrue: [ 1 to: in size do:
						[ :i | block value: (in at: i) value: (others collect: [ :e | e at: i ]) ] ]
				ifFalse: [ others do: [ :i | in ambiguous: i ] ] ] ].
	^ [ CASTParser parse: ' int i;' ]
		on: SmaCCAmbiguousResultNotification
		do: [ :ex | 
			| results |
			results := ex tag
				collect: [ :t | t performOnSmaCCParser: ex parser ].
			block value: results first value: results allButFirst.
			ex resume: results first ]
]

{ #category : #examples }
CASTParserTests class >> ambiguityAsAttribute3 [
	<example>
	| block |
	block := [ :in :others | 
	in
		ifNotNil: [ in isCollection
				ifTrue: [ 1 to: in size do:
						[ :i | block value: (in at: i) value: (others collect: [ :e | e at: i ]) ] ]
				ifFalse: [ in attributeNamed: #ambiguous put: others ] ] ].
	^ [ CASTParser
		parse:
			' int i; void f() { i * i; }' ]
		on: SmaCCAmbiguousResultNotification
		do: [ :ex | 
			| results |
			results := ex tag
				collect: [ :t | t performOnSmaCCParser: ex parser ].
			block value: results first value: results allButFirst.
			ex resume: results first ]
]

{ #category : #examples }
CASTParserTests class >> inspectingAmbiguousNotification [
	<example>
	[ CASTParser
		parse:
			' void f(int i) {
	i * i;
} ' ]
		on: SmaCCAmbiguousResultNotification
		do: [ :ex | 
			ex inspect.
			ex resume: ex tag first ]
]

{ #category : #examples }
CASTParserTests class >> inspectingAmbiguousNotificationWithHalt [
	<example>
	[ CASTParser
		parse:
			'typedef int i;
void f() {
	i * i;
}' ]
		on: SmaCCAmbiguousResultNotification
		do: [ :ex | 
			self halt.
			ex resume: ex tag first ]
]

{ #category : #helpers }
CASTParserTests >> parseDeclaration: aStratement [

	| unit |
	unit := CASTParser parse: 'int f(){ 
		', aStratement ,';
	}'.

	^ unit declarations first declarations first
]

{ #category : #helpers }
CASTParserTests >> parseExpression: anExpression [

	
	^ self parseStatement: anExpression, ';'
]

{ #category : #helpers }
CASTParserTests >> parseStatement: aStratement [

	| unit |
	unit := CASTParser parse: 'int f(){ 
		', aStratement ,'
	}'.
	
	^ unit declarations first statements first
]

{ #category : #'tests-assignment' }
CASTParserTests >> testParseAccumulatingAssignment [

	| assignment |
	assignment := self parseExpression: 'a += 1'.
	
	self assert: assignment isExpression.
	self assert: assignment lvalue name equals: 'a'.
	self assert: assignment operator equals: '+='.
]

{ #category : #'tests-binary operators' }
CASTParserTests >> testParseAddition [

	| expression |
	expression := self parseExpression: 'a+2'.
	
	self assert: expression isExpression.
	self assert: expression isBinaryOperation.
	self assert: expression operator equals: '+'
]

{ #category : #'tests-binary operators' }
CASTParserTests >> testParseAdditionPrecedence [

	| expression |
	expression := self parseExpression: 'a+2+1'.
	
	self assert: expression isExpression.
	self assert: expression isBinaryOperation.
	self assert: expression operator equals: '+'.

	self assert: expression left isExpression.
	self assert: expression left isBinaryOperation.
	self assert: expression left operator equals: '+'.
	self assert: expression left left name equals: 'a'.
	self assert: expression left right value equals: '2'.
	
	self assert: expression right value equals: '1'.

	

]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseArrayDeclarationWithInitializer [

	| declaration declarator |
	declaration := self parseDeclaration: 'int a[] = foo()'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isInitializerDeclarator.
	self assert: declarator initializer isCall.

	"Inside the initializer declarator is the array declarator"
	declarator := declarator declarator.
	self assert: declarator isArrayDeclarator.
	self assert: declarator size equals: nil.
	self assert: declarator declarator name equals: 'a'.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseArrayDeclarationWithSize [

	| declaration declarator |
	declaration := self parseDeclaration: 'int a[17]'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isArrayDeclarator.
	self assert: declarator size value equals: '17'.
	self assert: declarator declarator name equals: 'a'.
]

{ #category : #'tests-basic expressions' }
CASTParserTests >> testParseArrayNode [

	| expression |
	expression := self parseExpression: 'a[1]'.
		
	self assert: expression isExpression.
	self assert: expression isArrayAccessNode.
	self assert: expression array name equals: 'a'.
	self assert: expression index value equals: '1'.
]

{ #category : #'tests-assignment' }
CASTParserTests >> testParseAssignment [

	| assignment |
	assignment := self parseExpression: 'a = 1'.
	
	self assert: assignment isExpression.
	self assert: assignment lvalue name equals: 'a'.
	self assert: assignment operator equals: '='.
]

{ #category : #'tests-calls' }
CASTParserTests >> testParseCall [

	| expression |
	expression := self parseExpression: 'toto()'.
	
	self assert: expression isExpression.
	self assert: expression isCall.
	self assert: expression identifier name equals: 'toto'.
	self assert: expression arguments isEmpty.
]

{ #category : #'tests-calls' }
CASTParserTests >> testParseCallWithArguments [

	| expression |
	expression := self parseExpression: 'toto(1, foo(), 1+2)'.
	
	self assert: expression isExpression.
	self assert: expression isCall.
	self assert: expression identifier name equals: 'toto'.
	self assert: expression arguments first isConstant.
	self assert: expression arguments second isCall.
	self assert: expression arguments third isBinaryOperation.
]

{ #category : #'tests-basic expressions' }
CASTParserTests >> testParseCommaSeparatedExpression [

	| expression commaSeparatedExpression |
	expression := self parseExpression: 'a = (1,foo(2),1+2)'.

	commaSeparatedExpression := expression rvalue.
	self assert: commaSeparatedExpression isCommaSeparatedExpression.
	self assert: commaSeparatedExpression expressions first isConstant.
	self assert: commaSeparatedExpression expressions second isCall.
	self assert: commaSeparatedExpression expressions third isBinaryOperation.
]

{ #category : #'tests-compound statements' }
CASTParserTests >> testParseCompoundStatement [

	| statement |
	statement := self parseStatement: '{
		1;
		2;
		3;
	}'.
		
	self assert: statement isCompoundStatement.
	self assert: statement statements first value equals: '1'.
	self assert: statement statements second value equals: '2'.
	self assert: statement statements third value equals: '3'.
]

{ #category : #'tests-assignment' }
CASTParserTests >> testParseDecrementingAssignment [

	| assignment |
	assignment := self parseExpression: 'a -= 1'.
	
	self assert: assignment isExpression.
	self assert: assignment lvalue name equals: 'a'.
	self assert: assignment operator equals: '-='.
]

{ #category : #'tests-assignment' }
CASTParserTests >> testParseDividingAssignment [

	| assignment |
	assignment := self parseExpression: 'a /= 1'.
	
	self assert: assignment isExpression.
	self assert: assignment lvalue name equals: 'a'.
	self assert: assignment operator equals: '/='.
]

{ #category : #'tests-compound statements' }
CASTParserTests >> testParseEmptyCompoundStatement [

	| statement |
	statement := self parseStatement: '{
	}'.
		
	self assert: statement isCompoundStatement.
	self assert: statement statements isEmpty
]

{ #category : #'tests-basic expressions' }
CASTParserTests >> testParseEmptyStatement [

	| unit |
	unit := CASTParser parse: 'int f(){ ; }'.
	
	self assert: unit declarations first statements first isEmptyStatement.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseFloatingPointConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		17.2333;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '17.2333'.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseFunctionDeclarator [

	| declaration declarator |
	declaration := self parseDeclaration: 'int f(void)'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isFunctionDeclarator.
	self assert: declarator declarator name equals: 'f'.
	self assert: declarator parameters size equals: 1.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseFunctionPointerDeclarator [

	| declaration declarator |
	declaration := self parseDeclaration: 'int (*pf)(void)'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isFunctionDeclarator.
	self assert: declarator declarator isPointerDeclarator.
	self assert: declarator declarator declarator name equals: 'pf'.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseHexadecimalIntegerConstantConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		0x7;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '0x7'.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseHexadecimalIntegerConstantConstant2 [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		0X7;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '0X7'.
]

{ #category : #'tests-basic expressions' }
CASTParserTests >> testParseIdentifier [

	| expression |
	expression := self parseExpression: 'a'.
	
	self assert: expression isExpression.
	self assert: expression isIdentifier.
	self assert: expression name equals: 'a'.
]

{ #category : #'tests-control flow' }
CASTParserTests >> testParseIfElse [

	| statement |
	statement := self parseStatement: 'if (a) {  } else { }'.
	
	self assert: statement isIf.
	self assert: statement else notNil
]

{ #category : #'tests-control flow' }
CASTParserTests >> testParseIfNoElse [

	| statement |
	statement := self parseStatement: 'if (a) {  }'.

	self assert: statement isIf.
	self assert: statement else isNil
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseIntegerConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		17;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '17'.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseLongIntegerConstantConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		7L;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '7L'.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseLongIntegerConstantConstant2 [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		7l;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '7l'.
]

{ #category : #'tests-binary operators' }
CASTParserTests >> testParseMultiplication [

	| expression |
	expression := self parseExpression: 'a*2'.
	
	self assert: expression isExpression.
	self assert: expression isBinaryOperation.
	self assert: expression operator equals: '*'
]

{ #category : #'tests-binary operators' }
CASTParserTests >> testParseMultiplicationPrecedenceOverAddition [

	| expression |
	expression := self parseExpression: 'a+2*1'.
	
	self assert: expression isExpression.
	self assert: expression isBinaryOperation.
	self assert: expression operator equals: '+'.

	self assert: expression left name equals: 'a'.

	self assert: expression right isExpression.
	self assert: expression right isBinaryOperation.
	self assert: expression right operator equals: '*'.
	self assert: expression right left value equals: '2'.
	self assert: expression right right value equals: '1'.

	

]

{ #category : #'tests-assignment' }
CASTParserTests >> testParseMultiplyingAssignment [

	| assignment |
	assignment := self parseExpression: 'a *= 1'.
	
	self assert: assignment isExpression.
	self assert: assignment lvalue name equals: 'a'.
	self assert: assignment operator equals: '*='.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseOctalIntegerConstantConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		07;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '07'.
]

{ #category : #'tests-basic expressions' }
CASTParserTests >> testParseParenthesizedExpression [

	| expression |
	expression := self parseExpression: '(1)'.
	
	self assert: expression isExpression.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParsePointerDeclarator [

	| declaration declarator |
	declaration := self parseDeclaration: 'int *a'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isPointerDeclarator.
	self assert: declarator declarator name equals: 'a'.
]

{ #category : #'tests-control flow' }
CASTParserTests >> testParseReturnWithExpression [

	| statement |
	statement := self parseStatement: 'return a;'.
	
	self assert: statement isReturn.
	self assert: statement expression notNil
]

{ #category : #'tests-control flow' }
CASTParserTests >> testParseReturnWithoutExpression [

	| statement |
	statement := self parseStatement: 'return;'.
	
	self assert: statement isReturn.
	self assert: statement expression isNil
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseSequenceOfDeclarators [

	| declaration declarator |
	declaration := self parseDeclaration: 'int a=1, b=2'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 2.

	declarator := declaration declarators first.
	self assert: declarator isInitializerDeclarator.
	self assert: declarator initializer isConstant.
	self assert: declarator declarator name equals: 'a'.

	declarator := declaration declarators second.
	self assert: declarator isInitializerDeclarator.
	self assert: declarator initializer isConstant.
	self assert: declarator declarator name equals: 'b'.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseSimpleArrayDeclaration [

	| declaration declarator |
	declaration := self parseDeclaration: 'int a[]'.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isArrayDeclarator.
	self assert: declarator size equals: nil.
	self assert: declarator declarator name equals: 'a'.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseStructDeclarator [

	| declaration declarator |
	declaration := (CASTParser parse: 'struct C { int member; } obj;') declarations first.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isFunctionDeclarator.
	self assert: declarator declarator name equals: 'f'.
	self assert: declarator parameters size equals: 1.
]

{ #category : #'tests-structures' }
CASTParserTests >> testParseStructureAndUnionAccess [

	| expression |
	expression := self parseExpression: 'structOrUnion.field'.
		
	self assert: expression isExpression.
	self assert: expression isMemberAccess.
	self assert: expression object name equals: 'structOrUnion'.
	self assert: expression member name equals: 'field'.
]

{ #category : #'tests-structures' }
CASTParserTests >> testParseStructurePointerAccess [

	| expression |
	expression := self parseExpression: 'strrr->field'.
		
	self assert: expression isExpression.
	self assert: expression isStructPointerAccess.
	self assert: expression structurePointer name equals: 'strrr'.
	self assert: expression member name equals: 'field'.
]

{ #category : #'tests-declarators' }
CASTParserTests >> testParseUnionDeclarator [

	| declaration declarator |
	declaration := (CASTParser parse: 'union C { int member; } obj;') declarations first.
	
	self assert: (declaration specifiers includes: 'int').
	self assert: declaration declarators size equals: 1.

	declarator := declaration declarators first.
	self assert: declarator isFunctionDeclarator.
	self assert: declarator declarator name equals: 'f'.
	self assert: declarator parameters size equals: 1.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseUnsignedIntegerConstantConstant [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		7U;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '7U'.
]

{ #category : #'tests-numbers' }
CASTParserTests >> testParseUnsignedIntegerConstantConstant2 [

	| unit firstStatement |
	unit := CASTParser parse: 'int f(){ 
		7u;
	}'.
	
	firstStatement := unit declarations first statements first.
	
	self assert: firstStatement isExpression.
	self assert: firstStatement isConstant.
	self assert: firstStatement value equals: '7u'.
]

{ #category : #'tests-control flow' }
CASTParserTests >> testParseWhile [

	| statement |
	statement := self parseStatement: 'while (a) {  }'.
	
	self assert: statement isWhile
]
