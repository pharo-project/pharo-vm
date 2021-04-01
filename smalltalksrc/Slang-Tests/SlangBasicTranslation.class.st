Class {
	#name : #SlangBasicTranslation,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'generator',
		'translationStrategy'
	],
	#category : #'Slang-Tests'
}

{ #category : #'building suites' }
SlangBasicTranslation class >> testParameters [ 

	^ ParametrizedTestMatrix new
		forSelector: #translationStrategy addOptions: { #slangTranslate . #astTranslate }
]

{ #category : #helpers }
SlangBasicTranslation >> astTranslate: tast inStream: aWriteStream [ 
	
	| cAST prettyPrinter |
	cAST := tast asCASTIn: generator.
	
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aWriteStream.
	cAST acceptVisitor: prettyPrinter.
]

{ #category : #accessing }
SlangBasicTranslation >> generator [

	^ generator
]

{ #category : #accessing }
SlangBasicTranslation >> generator: anObject [

	generator := anObject
]

{ #category : #running }
SlangBasicTranslation >> setUp [

	super setUp.

	generator := CCodeGenerator new.
	generator currentMethod: (TMethod new
		labels: Set new;
		yourself).
]

{ #category : #helpers }
SlangBasicTranslation >> slangTranslate: tast inStream: aWriteStream [ 
	
	tast
		emitCCodeOn: aWriteStream
		level: 0
		generator: generator
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testBlockValue [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
bar(3, 4);'
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testBlockValueAssignment [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
var = bar(3, 4);'
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testBlockValueAssignmentIntoSameVariable [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
bar(3, 4);'
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testBlockValueWithVariableAsLastExpression [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
bar(3, 4);'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantCharacter [

	| translation |
	translation := self translate: (TConstantNode new setValue: $A).
	
	self assert: translation equals: '''A'''
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantFalse [

	| translation |
	translation := self translate: (TConstantNode new setValue: false).
	
	self assert: translation equals: '0'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantFloat [

	| translation |
	translation := self translate: (TConstantNode new setValue: 3.1415).
	
	self assert: translation equals: '3.1415'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantInteger [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode new setValue: 17).
	
	self assert: translation equals: '17'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantIntegerHexaCaseA [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case A"	
	translation := self translate: (TConstantNode new setValue: (2 raisedTo: 20)).
	
	self assert: translation equals: '0x100000'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantIntegerHexaCaseB [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case B"
	translation := self translate: (TConstantNode new setValue: 2r11111100000).

	self assert: translation equals: '0x7E0'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantNil [

	| translation |
	translation := self translate: (TConstantNode new setValue: nil).
	
	self assert: translation equals: 'NULL'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantQuoteCharacter [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode new setValue: $').
	
	self assert: translation equals: '''\'''''
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantString [

	| translation |
	translation := self translate: (TConstantNode new setValue: '1
2
3').
	
	self assert: translation equals: '"1\n2\n3"'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbol [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbolColon [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbolColonWithMultipleKeywords [

	| translation |
	translation := self translate: (TConstantNode new setValue: #sym__bol___:another__:).
	
	self assert: translation equals: 'sym__bol___another'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbolColonWithUnderscores [

	| translation |
	translation := self translate: (TConstantNode new setValue: #symbol___:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbolColonWithUnderscoresInTheMiddle [

	| translation |
	translation := self translate: (TConstantNode new setValue: #sym__bol___:).
	
	self assert: translation equals: 'sym__bol'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantSymbolWithTranslationMap [

	| translation |
	generator addSelectorTranslation: #+> to: #strangearrow.
	
	translation := self translate: (TConstantNode new setValue: #+>).
	
	self assert: translation equals: 'strangearrow'
]

{ #category : #'tests-constants' }
SlangBasicTranslation >> testConstantTrue [

	| translation |
	translation := self translate: (TConstantNode new setValue: true).
	
	self assert: translation equals: '1'
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testConstantsStatementsInBlockValueAreIgnored [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
bar(3, 4);'
]

{ #category : #'tests-return' }
SlangBasicTranslation >> testReturnLeafInVoidMethod [

	| translation |
	
	generator currentMethod: (TMethod new returnType: 'void'; yourself).
	
	translation := self translate: (TReturnNode new
		setExpression: (TVariableNode new setName: 'var');
		yourself).
		
	self assert: translation equals: 'return'
]

{ #category : #'tests-return' }
SlangBasicTranslation >> testReturnNonLeafExpressionInVoidMethod [

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
SlangBasicTranslation >> testReturnVariable [

	| translation |
	translation := self translate: (TReturnNode new
		setExpression: (TVariableNode new setName: 'var');
		yourself).
		
	self assert: translation equals: 'return var'
]

{ #category : #'tests-assignment' }
SlangBasicTranslation >> testTranslateLiteralArrayAssignment [

	| translation variable expression |
	variable := (TVariableNode new setName: 'var').
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
SlangBasicTranslation >> testTranslateNil [

	| translation |
	translation :=  self translate: (TVariableNode new setName: 'nil').

	self assert: translation equals: 'NULL'
]

{ #category : #'tests-variables' }
SlangBasicTranslation >> testTranslateNormalVariable [

	| translation |
	translation := self translate: (TVariableNode new setName: 'someVar').

	self assert: translation equals: 'someVar'
]

{ #category : #'tests-blocks' }
SlangBasicTranslation >> testVariableStatementsInBlockValueAreIgnored [

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

	self assert: translation trimBoth equals: 'foo(1, 2);
bar(3, 4);'
]

{ #category : #helpers }
SlangBasicTranslation >> translate: tast [

	^ String streamContents: [ :str | 
		self
			perform: (translationStrategy , #':inStream:') asSymbol
			withArguments: { tast . str } ]
]

{ #category : #accessing }
SlangBasicTranslation >> translationStrategy [

	^ translationStrategy
]

{ #category : #accessing }
SlangBasicTranslation >> translationStrategy: anObject [

	translationStrategy := anObject
]
