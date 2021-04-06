Class {
	#name : #SlangBasicTranslationTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'generator',
		'translationStrategy'
	],
	#category : #'Slang-Tests'
}

{ #category : #'building suites' }
SlangBasicTranslationTest class >> testParameters [ 

	^ ParametrizedTestMatrix new
		forSelector: #translationStrategy addOptions: { #slangTranslate . #astTranslate }
]

{ #category : #helpers }
SlangBasicTranslationTest >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: generator.
	
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator [

	^ generator
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator: anObject [

	generator := anObject
]

{ #category : #running }
SlangBasicTranslationTest >> setUp [

	super setUp.

	generator := CCodeGenerator new.
	generator currentMethod: (TMethod new
		labels: Set new;
		yourself).
]

{ #category : #helpers }
SlangBasicTranslationTest >> slangTranslate: tast inStream: aWriteStream [ 
	
	tast
		emitCCodeOn: aWriteStream
		level: 0
		generator: generator
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValue [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4 ] value"

	| translation |

	translation := self translate: (TSendNode new
		setSelector: #value
		receiver: (TStmtListNode new
			setArguments: #()
			statements: {
				TSendNode new
					setSelector: #foo
					receiver: (TConstantNode new setValue: 1)
					arguments: { TConstantNode new setValue: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode new setValue: 3)
					arguments: { TConstantNode new setValue: 4 }.
			})
		arguments: { }).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAssignment [

	"Case:
	
	var := [ 1 foo: 2. 3 foo: 4 ] value"

	| translation variable expression |
	
	variable := TVariableNode new setName: 'var'.
	expression := TSendNode new
		setSelector: #value
		receiver: (TStmtListNode new
			setArguments: #()
			statements: {
				TSendNode new
					setSelector: #foo
					receiver: (TConstantNode new setValue: 1)
					arguments: { TConstantNode new setValue: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode new setValue: 3)
					arguments: { TConstantNode new setValue: 4 }
			})
		arguments: { }.
	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	var = bar(3, 4);
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAssignmentIntoSameVariable [

	"Case:
	
	var := [ 1 foo: 2. 3 foo: 4. var ] value"
	
	| translation variable expression |

	variable := (TVariableNode new setName: 'var').
	expression := TSendNode new
				setSelector: #value
				receiver: (TStmtListNode new
					setArguments: #()
					statements: {
						TSendNode new
							setSelector: #foo
							receiver: (TConstantNode new setValue: 1)
							arguments: { TConstantNode new setValue: 2 }.
						TSendNode new
							setSelector: #bar
							receiver: (TConstantNode new setValue: 3)
							arguments: { TConstantNode new setValue: 4 }.
						variable
					})
				arguments: { }.
	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueWithVariableAsLastExpression [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4. var ] value"

	| translation |
	
	translation := self translate: (TSendNode new
		setSelector: #value
		receiver: (TStmtListNode new
			setArguments: #()
			statements: {
				TSendNode new
					setSelector: #foo
					receiver: (TConstantNode new setValue: 1)
					arguments: { TConstantNode new setValue: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode new setValue: 3)
					arguments: { TConstantNode new setValue: 4 }.
				TVariableNode new setName: 'var'.
			})
		arguments: { }).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantCharacter [

	| translation |
	translation := self translate: (TConstantNode new setValue: $A).
	
	self assert: translation equals: '''A'''
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantFalse [

	| translation |
	translation := self translate: (TConstantNode new setValue: false).
	
	self assert: translation equals: '0'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantFloat [

	| translation |
	translation := self translate: (TConstantNode new setValue: 3.1415).
	
	self assert: translation equals: '3.1415'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantInteger [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode new setValue: 17).
	
	self assert: translation equals: '17'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantIntegerHexaCaseA [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case A"	
	translation := self translate: (TConstantNode new setValue: (2 raisedTo: 20)).
	
	self assert: translation equals: '0x100000'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantIntegerHexaCaseB [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case B"
	translation := self translate: (TConstantNode new setValue: 2r11111100000).

	self assert: translation equals: '0x7E0'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantNil [

	| translation |
	translation := self translate: (TConstantNode new setValue: nil).
	
	self assert: translation equals: 'NULL'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantQuoteCharacter [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode new setValue: $').
	
	self assert: translation equals: '''\'''''
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantString [

	| translation |
	translation := self translate: (TConstantNode new setValue: '1
2
3').
	
	self assert: translation equals: '"1\n2\n3"'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbol [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColon [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithMultipleKeywords [

	| translation |
	translation := self translate: (TConstantNode new setValue: #sym__bol___:another__:).
	
	self assert: translation equals: 'sym__bol___another'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithUnderscores [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol___:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithUnderscoresInTheMiddle [

	| translation |
	translation := self translate: (TConstantNode new setValue: #sym__bol___:).
	
	self assert: translation equals: 'sym__bol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolWithTranslationMap [

	| translation |
	generator addSelectorTranslation: #+> to: #strangearrow.
	
	translation := self translate: (TConstantNode new setValue: #+>).
	
	self assert: translation equals: 'strangearrow'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantTrue [

	| translation |
	translation := self translate: (TConstantNode new setValue: true).
	
	self assert: translation equals: '1'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testConstantsStatementsInBlockValueAreIgnored [

	"Case:
	
	[ 1 foo: 2. 72 . 3 foo: 4. var ] value"

	| translation |
	
	translation := self translate: (TSendNode new
		setSelector: #value
		receiver: (TStmtListNode new
			setArguments: #()
			statements: {
				TSendNode new
					setSelector: #foo
					receiver: (TConstantNode new setValue: 1)
					arguments: { TConstantNode new setValue: 2 }.
				TConstantNode new setValue: 72.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode new setValue: 3)
					arguments: { TConstantNode new setValue: 4 }.
				TVariableNode new setName: 'var'.
			})
		arguments: { }).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testReturnLeafInVoidMethod [

	| translation |
	
	generator currentMethod: (TMethod new returnType: 'void'; yourself).
	
	translation := self translate: (TReturnNode new
		setExpression: (TVariableNode new setName: 'var');
		yourself).
		
	self assert: translation equals: 'return'
]

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testReturnNonLeafExpressionInVoidMethod [

	| translation |
	
	generator currentMethod: (TMethod new returnType: 'void'; yourself).
	
	translation := self translate: (TReturnNode new
		setExpression: (TAssignmentNode new
			setVariable: (TVariableNode new setName: 'var')
			expression: (TConstantNode new setValue: 7));
		yourself).
		
	self assert: translation equals: 'var = 7;
return'
]

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testReturnVariable [

	| translation |
	translation := self translate: (TReturnNode new
		setExpression: (TVariableNode new setName: 'var');
		yourself).
		
	self assert: translation equals: 'return var'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testTranslateBlockAssignmentWithManyStatement [

	| translation variable expression |

	" var :=  [ a := b . c := 1 ]."

	variable := TVariableNode new setName: 'var'.

	expression := TStmtListNode new setStatements: {
		TAssignmentNode new
			setVariable: (TVariableNode new setName: 'a')
			expression:  (TVariableNode new setName: 'b').
		TAssignmentNode new
			setVariable:  (TVariableNode new setName: 'c')
			expression:  (TConstantNode new setValue: 1).
	}.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: '{
	a = b;
	var = (c = 1);
}'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testTranslateLiteralArrayAssignment [

	| translation variable expression |

	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		setSelector: #cCoerce:to:
		receiver: (TVariableNode new setName: 'self')
		arguments: { 
			TConstantNode new setValue: { 1 . 2 . 3 }.
			'int *' }.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: '{
	static int  aLiteralArray[] = {
		1, 2, 3
	};
	var = aLiteralArray;
}'
]

{ #category : #'tests-variables' }
SlangBasicTranslationTest >> testTranslateNil [

	| translation |
	translation :=  self translate: (TVariableNode new setName: 'nil').

	self assert: translation equals: 'NULL'
]

{ #category : #'tests-variables' }
SlangBasicTranslationTest >> testTranslateNormalVariable [

	| translation |
	translation := self translate: (TVariableNode new setName: 'someVar').

	self assert: translation equals: 'someVar'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testVariableStatementsInBlockValueAreIgnored [

	"Case:
	
	[ 1 foo: 2. var . 3 foo: 4 ] value"

	| translation |
	
	translation := self translate: (TSendNode new
		setSelector: #value
		receiver: (TStmtListNode new
			setArguments: #()
			statements: {
				TSendNode new
					setSelector: #foo
					receiver: (TConstantNode new setValue: 1)
					arguments: { TConstantNode new setValue: 2 }.
				TVariableNode new setName: 'var'.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode new setValue: 3)
					arguments: { TConstantNode new setValue: 4 }.
			})
		arguments: { }).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testVariableUpdateAssignmentMinus [

	| translation variable expression |

	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		setSelector: #-
		receiver: variable 
		arguments: { 
			TConstantNode new setValue: 7.
		}.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: 'var -= 7'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testVariableUpdateAssignmentPlus [

	| translation variable expression |

	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		setSelector: #+
		receiver: variable 
		arguments: { 
			TConstantNode new setValue: 7.
		}.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation trimBoth equals: 'var += 7'
]

{ #category : #helpers }
SlangBasicTranslationTest >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (translationStrategy , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]

{ #category : #accessing }
SlangBasicTranslationTest >> translationStrategy [

	^ translationStrategy
]

{ #category : #accessing }
SlangBasicTranslationTest >> translationStrategy: anObject [

	translationStrategy := anObject
]
