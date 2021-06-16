Class {
	#name : #SlangBasicTranslationTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'generator',
		'translationStrategy',
		'numSmallIntegerTagBits'
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

{ #category : #compatibility }
SlangBasicTranslationTest >> constantClass [
	
	"The translator requires that we define a class with constants"
	^ VMBasicConstants
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator [

	^ generator
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator: anObject [

	generator := anObject
]

{ #category : #compatibility }
SlangBasicTranslationTest >> isNonArgumentImplicitReceiverVariableName: aString [ 
	
	^ false
]

{ #category : #accessing }
SlangBasicTranslationTest >> numSmallIntegerTagBits [
	
	"Hook for some tests that require changing translation depending on this value"
	^ numSmallIntegerTagBits
]

{ #category : #accessing }
SlangBasicTranslationTest >> objectMemoryClass [
	
	"Compatibility method to make the test look like a vm translatable class"
	^ self
]

{ #category : #running }
SlangBasicTranslationTest >> setUp [

	super setUp.

	generator := MLVMCCodeGenerator new.
	generator vmMaker: VMMaker new.
	generator vmMaker vmmakerConfiguration: VMMakerConfiguration.
	generator currentMethod: (TMethod new
		labels: Set new;
		resetUsedVariablesCache;
		yourself).
	
	"Tell the generator this is the class we are generating.
	That will make the generation dispatch to us to ask for configurations such as the number of small integer bits"
	generator vmClass: self.
	numSmallIntegerTagBits := 42.
]

{ #category : #compatibility }
SlangBasicTranslationTest >> shouldGenerateDeadCode [
	
	"Compatibility method to make the test look like a VM translatable class"
	^ true
]

{ #category : #helpers }
SlangBasicTranslationTest >> slangTranslate: tast inStream: aWriteStream [ 

	tast
		emitCCodeOn: aWriteStream
		level: 0
		generator: generator
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testAssignementAsExpression [

	"y := a := false"
	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
	translation := self translate: send.

	self assert: translation equals: 'y = (a = 0)'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testAssignementAsExpressionWithExpressionBlock [
	
	"y := a := [ 1 foo: 2. 3 foo: 4. 5 foo: 6 ]"
	"The assignment tested is in an other assignment in order to force it to be in argument form."
	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TAssignmentNode new
				         setVariable: (TVariableNode new setName: 'a')
				         expression:
					         (TStmtListNode new setArguments: #(  ) statements: { 
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 1)
								           arguments: { (TConstantNode value: 2) }).
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 3)
								           arguments: { (TConstantNode value: 4) }).
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 5)
								           arguments: { (TConstantNode value: 6) }) })).
	translation := self translate: send.

	self assert: translation equals: 'y = (foo(1, 2), foo(3, 4), (a = foo(5, 6)))'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testAssignementAsExpressionWithExpressionBlockWithLastStatementEqualToReceiver [

	"y := a := [ 1 foo: 2. 3 foo: 4. 5 foo: 6. a]"

	"The assignment tested is in an other assignment in order to force it to be in argument form."

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TAssignmentNode new
				         setVariable: (TVariableNode new setName: 'a')
				         expression:
					         (TStmtListNode new setArguments: #(  ) statements: { 
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 1)
								           arguments: { (TConstantNode value: 2) }).
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 3)
								           arguments: { (TConstantNode value: 4) }).
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 5)
								           arguments: { (TConstantNode value: 6) }).
							          (TVariableNode new setName: 'a') })).
	translation := self translate: send.

	self
		assert: translation
		equals: 'y = (foo(1, 2), foo(3, 4), foo(5, 6), a)'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockAsArgument [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4. 5 foo: 6 ] value ifTrue: [ a := b ]"
	"In order to test the translation of a block as an argument, the block is given as condition of an if."
	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStmtListNode new setArguments: #(  ) statements: { 
			              (TSendNode new
				               setSelector: #foo
				               receiver: (TConstantNode value: 1)
				               arguments: { (TConstantNode value: 2) }).
			              (TSendNode new
				               setSelector: #foo
				               receiver: (TConstantNode value: 3)
				               arguments: { (TConstantNode value: 4) }).
			              (TSendNode new
				               setSelector: #foo
				               receiver: (TConstantNode value: 5)
				               arguments: { (TConstantNode value: 6) }) }.
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSendNode new setSelector: #value receiver: expression arguments: {})
			                arguments: { (TStmtListNode new setStatements: { 
						                 (TAssignmentNode new
							                  setVariable: (TVariableNode new setName: 'a')
							                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, 2), foo(3, 4), foo(5, 6))) {
	a = b;
}'
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
					receiver: (TConstantNode value: 1)
					arguments: { TConstantNode value: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode value: 3)
					arguments: { TConstantNode value: 4 }.
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
					receiver: (TConstantNode value: 1)
					arguments: { TConstantNode value: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode value: 3)
					arguments: { TConstantNode value: 4 }
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
							receiver: (TConstantNode value: 1)
							arguments: { TConstantNode value: 2 }.
						TSendNode new
							setSelector: #bar
							receiver: (TConstantNode value: 3)
							arguments: { TConstantNode value: 4 }.
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
SlangBasicTranslationTest >> testBlockValueWithConstantArgument [

	"Case:
	
	[ :i | a := i ] value: 7"

	| translation |

	translation := self translate: (TSendNode new
		setSelector: #value:
		receiver: (TStmtListNode new
			setArguments: #(i)
			statements: {
				TAssignmentNode new setVariable: (TVariableNode new setName: 'a') expression: (TVariableNode new setName: 'i')
			})
		arguments: { TConstantNode value: 7 }).

	self assert: translation trimBoth equals: '{
	a = 7;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueWithNonLeafArgument [

	"Case:
	
	[ :i | a := i ] value: 7 + 5"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #value:
			                receiver: (TStmtListNode new
					                 setArguments: #( i )
					                 statements: { (TAssignmentNode new
							                  setVariable: (TVariableNode new setName: 'a')
							                  expression: (TVariableNode new setName: 'i')) })
			                arguments: { (TSendNode new
					                 setSelector: #+
					                 receiver: (TConstantNode value: 7)
					                 arguments: { (TConstantNode value: 5) }) }).

	self assert: translation trimBoth equals: 'i = 7 + 5;
{
	a = i;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueWithNonLeafArgumentAndMultipleUse [

	"Case:
	
	[ :i | a := i ] value: 7 + 5"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #value:
			                receiver:
				                (TStmtListNode new
					                 setArguments: #( i )
					                 statements: { 
							                 (TAssignmentNode new
								                  setVariable:
								                  (TVariableNode new setName: 'a')
								                  expression: (TVariableNode new setName: 'i')).
							                 (TAssignmentNode new
								                  setVariable:
								                  (TVariableNode new setName: 'b')
								                  expression: (TSendNode new
										                   setSelector: #*
										                   receiver:
										                   (TVariableNode new setName: 'i')
										                   arguments: { (TConstantNode value: 5) })) })
			                arguments: { (TSendNode new
					                 setSelector: #+
					                 receiver: (TConstantNode value: 7)
					                 arguments: { (TConstantNode value: 5) }) }).

	self assert: translation trimBoth equals: 'i = 7 + 5;
{
	a = i;
	b = i * 5;
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
					receiver: (TConstantNode value: 1)
					arguments: { TConstantNode value: 2 }.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode value: 3)
					arguments: { TConstantNode value: 4 }.
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
	translation := self translate: (TConstantNode value: $A).
	
	self assert: translation equals: '''A'''
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantFalse [

	| translation |
	translation := self translate: (TConstantNode value: false).
	
	self assert: translation equals: '0'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantFloat [

	| translation |
	translation := self translate: (TConstantNode value: 3.1415).
	
	self assert: translation equals: '3.1415'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantInteger [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode value: 17).
	
	self assert: translation equals: '17'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantIntegerHexaCaseA [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case A"	
	translation := self translate: (TConstantNode value: (2 raisedTo: 20)).
	
	self assert: translation equals: '0x100000'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantIntegerHexaCaseB [

	| translation |
	"Only sequences of binary 1s are translated to hexa, and only if either
		- they area single bit turned on and > 65536
		- or the distance between the higher and lower bits are >= 4"

	"Case B"
	translation := self translate: (TConstantNode value: 2r11111100000).

	self assert: translation equals: '0x7E0'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantNil [

	| translation |
	translation := self translate: (TConstantNode value: nil).
	
	self assert: translation equals: 'null'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantQuoteCharacter [

	| translation |
	"Special case that should be escaped in C"
	translation := self translate: (TConstantNode value: $').
	
	self assert: translation equals: '''\'''''
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantString [

	| translation |
	translation := self translate: (TConstantNode value: '1
2
3').
	
	self assert: translation equals: '"1\n2\n3"'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbol [

	| translation |
	translation := self translate: (TConstantNode value: #symbol).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColon [

	| translation |
	translation := self translate: (TConstantNode value: #symbol:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithMultipleKeywords [

	| translation |
	translation := self translate: (TConstantNode value: #sym__bol___:another__:).
	
	self assert: translation equals: 'sym__bol___another'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithUnderscores [

	| translation |
	translation := self translate: (TConstantNode value: #symbol___:).
	
	self assert: translation equals: 'symbol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolColonWithUnderscoresInTheMiddle [

	| translation |
	translation := self translate: (TConstantNode value: #sym__bol___:).
	
	self assert: translation equals: 'sym__bol'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantSymbolWithTranslationMap [

	| translation |
	generator addSelectorTranslation: #+> to: #strangearrow.
	
	translation := self translate: (TConstantNode value: #+>).
	
	self assert: translation equals: 'strangearrow'
]

{ #category : #'tests-constants' }
SlangBasicTranslationTest >> testConstantTrue [

	| translation |
	translation := self translate: (TConstantNode value: true).
	
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
					receiver: (TConstantNode value: 1)
					arguments: { TConstantNode value: 2 }.
				TConstantNode value: 72.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode value: 3)
					arguments: { TConstantNode value: 4 }.
				TVariableNode new setName: 'var'.
			})
		arguments: { }).

	self assert: translation trimBoth equals: '{
	foo(1, 2);
	bar(3, 4);
}'
]

{ #category : #'tests-goto' }
SlangBasicTranslationTest >> testGoto [

	| translation |
	
	translation := self translate: (TGoToNode label: 'lab').

	self assert: translation equals: 'goto lab'
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
			expression: (TConstantNode value: 7));
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

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAbs [

	| translation send |
	
	send := TSendNode new
					setSelector: #abs
					receiver: (TConstantNode value: -1)
					arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'abs(-1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAddressOf [

	| translation send |
	send := TSendNode new
		        setSelector: #addressOf:
		        receiver: (TVariableNode new setName: 'aVM')
		        arguments: {(TVariableNode new setName: 'x')}.
	translation := self translate: send.

	self assert: translation equals: '&x'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAllMask [

	| translation send |

	send := TSendNode new
					setSelector: #allMask:
					receiver: (TVariableNode new setName: 'a')
					arguments: { TConstantNode value: 7 }.
	translation := self translate: send.

	self assert: translation equals: '((a & 7) == 7)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAnd [

	| translation send |

	send := TSendNode new
					setSelector: #&
					receiver: (TConstantNode value: false)
					arguments: { TConstantNode value: true }.
	translation := self translate: send.

	self assert: translation equals: '0 && 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsFloat [

	| translation send |
	send := TSendNode new
		        setSelector: #asFloat
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((double) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsInteger [

	| translation send |
	send := TSendNode new
		        setSelector: #asInteger
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((sqInt) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsIntegerPtr [

	| translation send |
	send := TSendNode new
		        setSelector: #asIntegerPtr
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((sqIntptr_t) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsLong [

	| translation send |
	send := TSendNode new
		        setSelector: #asLong
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((long) x )'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendAsSymbol [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #asSymbol
			                receiver: (TConstantNode value: 'foo_one')
			                arguments: { }).

	self assert: translation equals: 'foo_one'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsUnsignedInteger [

	| translation send |
	send := TSendNode new
		        setSelector: #asUnsignedInteger
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsUnsignedIntegerPtr [

	| translation send |
	send := TSendNode new
		        setSelector: #asUnsignedIntegerPtr
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqIntptr_t) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsUnsignedLong [

	| translation send |
	send := TSendNode new
		        setSelector: #asUnsignedLong
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((unsigned long) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsUnsignedLongLong [

	| translation send |
	send := TSendNode new
		        setSelector: #asUnsignedLongLong
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((unsigned long long) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsVoidPointer [

	| translation send |
	send := TSendNode new
		        setSelector: #asVoidPointer
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((void *) x )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAt [

	| translation send |
	
	send := TSendNode new
					setSelector: #at:
					receiver: (TVariableNode new setName: 'tab')
					arguments: {TConstantNode value: 7}.
	translation := self translate: send.

	self assert: translation equals: 'tab[7]'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAtPut [

	| translation send |
	send := TSendNode new
		        setSelector: #at:put:
		        receiver: (TVariableNode new setName: 'tab')
		        arguments: { 
				        (TConstantNode value: 7).
				        (TVariableNode new setName: 'a') }.
	translation := self translate: send.

	self assert: translation equals: 'tab[7] = a'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendBaseHeaderSize [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #baseHeaderSize
			                receiver: (TVariableNode new setName: 'aVM')
			                arguments: { }).

	self assert: translation equals: 'BaseHeaderSize'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBetweenAnd [

	| translation send |
	send := TSendNode new
		        setSelector: #between:and:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TConstantNode value: 0).
				        (TConstantNode value: 100) }.
	translation := self translate: send.

	self assert: translation equals: '((x >= 0) && (x <= 100))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitAnd [

	| translation send |

	send := TSendNode new
					setSelector: #bitAnd:
					receiver: (TVariableNode new setName: 'a')
					arguments: { TConstantNode value: 1 }.
	translation := self translate: send.

	self assert: translation equals: 'a & 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitClear [

	| translation send |
	send := TSendNode new
		        setSelector: #bitClear:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {(TConstantNode value: 3)}.
	translation := self translate: send.

	self assert: translation equals: '((a | 3) - 3)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitInvert32On32Bits [

	| translation send |
	send := TSendNode new
		        setSelector: #bitInvert32
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((unsigned int) (~a) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitInvert32On64Bits [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #bitInvert32
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((unsigned int) (~a) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitInvert64On32Bits [

	| translation send |
	send := TSendNode new
		        setSelector: #bitInvert64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '~((unsigned long long) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitInvert64On64Bits [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #bitInvert64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '~((usqIntptr_t) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitOr [

	| translation send |

	send := TSendNode new
					setSelector: #bitOr:
					receiver: (TVariableNode new setName: 'a')
					arguments: { TConstantNode value: 1 }.
	translation := self translate: send.

	self assert: translation equals: 'a | 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitShiftWithExpressionShiftValue [

	| translation send |
	send := TSendNode new
		        setSelector: #bitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TSendNode new
				         setSelector: #+
				         receiver: (TVariableNode new setName: 'var')
				         arguments: { (TConstantNode value: 2) }) }.
	translation := self translate: send.

	self assert: translation equals: '(((var + 2) < 0) ? (((usqInt) a ) >> (-(var + 2))) : (((usqInt) a ) << (var + 2)))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitShiftWithNegativeConstantShiftValue [

	| translation send |
	send := TSendNode new
		        setSelector: #bitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: -3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) >> 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitShiftWithPositiveConstantShiftValue [

	| translation send |
	send := TSendNode new
		        setSelector: #bitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) << 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendBitXor [

	| translation send |

	send := TSendNode new
					setSelector: #bitXor:
					receiver: (TVariableNode new setName: 'a')
					arguments: { TConstantNode value: 1 }.
	translation := self translate: send.

	self assert: translation equals: 'a ^ 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendByteSwap32 [

	| translation send |
	send := TSendNode new
		        setSelector: #byteSwap32
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'SQ_SWAP_4_BYTES(a)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendByteSwap32IfBigEndian [

	| translation send |
	send := TSendNode new
		        setSelector: #byteSwapped32IfBigEndian:
		        receiver: nil
		        arguments: {TVariableNode new setName: 'a'}.
	translation := self translate: send.

	self assert: translation equals: 'SQ_SWAP_4_BYTES_IF_BIGENDIAN(a)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendByteSwap64 [

	| translation send |
	send := TSendNode new
		        setSelector: #byteSwap64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'SQ_SWAP_8_BYTES(a)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendByteSwap64IfBigEndian [

	| translation send |
	send := TSendNode new
		        setSelector: #byteSwapped64IfBigEndian:
		        receiver: nil
		        arguments: {TVariableNode new setName: 'a'}.
	translation := self translate: send.

	self assert: translation equals: 'SQ_SWAP_8_BYTES_IF_BIGENDIAN(a)'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendBytesPerOop [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #bytesPerOop
			                receiver: (TVariableNode new setName: 'aVM')
			                arguments: { }).

	self assert: translation equals: 'BytesPerOop'	
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendBytesPerWord [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #bytesPerWord
			                receiver: (TVariableNode new setName: 'aVM')
			                arguments: { }).

	self assert: translation equals: 'BytesPerWord'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeInSmalltalkWithNonConstant [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:inSmalltalk:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
					(TVariableNode new setName: 'value').
					'unused' }.
	translation := self translate: send.

	self assert: translation equals: 'value'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeInSmalltalkWithString [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:inSmalltalk:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
					TConstantNode value: 'some string'.
					'unused' }.
	translation := self translate: send.

	self assert: translation equals: 'some string'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeInSmalltalkWithStringNotesVariables [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:inSmalltalk:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
					TConstantNode value: 'some 1 _underscoreToo #yep'.
					'unused' }.
	translation := self translate: send.

	self assert: (generator currentMethod usedVariablesCache includes: 'some').
	self assert: (generator currentMethod usedVariablesCache includes: '_underscoreToo').
	self assert: (generator currentMethod usedVariablesCache includes: 'yep').
	self deny: (generator currentMethod usedVariablesCache includes: '1').
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeWithNonConstant [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { (TVariableNode new setName: 'value') }.
	translation := self translate: send.

	self assert: translation equals: 'value'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeWithString [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { TConstantNode value: 'some string' }.
	translation := self translate: send.

	self assert: translation equals: 'some string'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeWithStringNotesVariables [

	| translation send |
	send := TSendNode new
		        setSelector: #cCode:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { TConstantNode value: 'some 1 _underscoreToo #yep' }.
	translation := self translate: send.

	self assert: (generator currentMethod usedVariablesCache includes: 'some').
	self assert: (generator currentMethod usedVariablesCache includes: '_underscoreToo').
	self assert: (generator currentMethod usedVariablesCache includes: 'yep').
	self deny: (generator currentMethod usedVariablesCache includes: '1').
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendCCoerceFloatLiteralToFloat [

	"self cCoerce: 1.2 to: 'float'"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #cCoerce:to:
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { 
					                (TConstantNode value: 1.2).
					                (TConstantNode value: 'float') }).

	self assert: translation equals: '1.2f'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendCCoerceVariableToFloat [

	"self cCoerce: var to: 'float'"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #cCoerce:to:
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { 
					                (TVariableNode new setName: 'var').
					                (TConstantNode value: 'float') }).

	self assert: translation equals: '((float) var )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrue [

	"self cppIf: #FEATURE ifTrue: [ a := false. c := 1 ]"
	| translation send |
	send := TSendNode new
		        setSelector: #cppIf:ifTrue:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
				        (TConstantNode value: #FEATURE).
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '#if FEATURE
{
	a = 0;
	c = 1;
}
#endif /* FEATURE */'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueIfFalse [

	"self cppIf: #FEATURE ifTrue: [ a := false. c := 1 ]"
	| translation send |
	send := TSendNode new
		        setSelector: #cppIf:ifTrue:ifFalse:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
				        (TConstantNode value: #FEATURE).
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
							(TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: true)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 0)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '#if FEATURE
{
	a = 0;
	c = 1;
}
#else /* FEATURE */
{
	a = 1;
	c = 0;
}
#endif /* FEATURE */'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendDeny [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #deny:
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { (TSendNode new
					                 setSelector: #=
					                 receiver: (TVariableNode new setName: 'foo')
					                 arguments: { (TConstantNode value: 10) }) }).

	self assert: translation equals: 'assert(!(foo == 10))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendDivide [

	| translation send |

	send := TSendNode new
					setSelector: #/
					receiver: (
						TSendNode new
						setSelector: #+
						receiver: (TConstantNode value: 1)
						arguments: { TConstantNode value: 2 }
					)
					arguments: { TConstantNode value: 3 }.
	translation := self translate: send.

	self assert: translation equals: '(1 + 2) / 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendEqual [

	| translation send |

	send := TSendNode new
					setSelector: #=
					receiver: (
						TSendNode new
						setSelector: #+
						receiver: (TConstantNode value: 1)
						arguments: { TConstantNode value: 2 }
					)
					arguments: { TConstantNode value: 3 }.
	translation := self translate: send.

	self assert: translation equals: '(1 + 2) == 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendFlag [

	| translation send |
	send := TSendNode new
		        setSelector: #flag:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { TConstantNode value: #aSymbol }.
	translation := self translate: send.

	self assert: translation equals: 'flag("aSymbol")'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendFunctionCall [

	"Case:
	
	1 foo: 2"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #foo
			                receiver: (TConstantNode value: 1)
			                arguments: { (TConstantNode value: 2) }).

	self assert: translation equals: 'foo(1, 2)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendFunctionCallInOperation [

	"Case:
	
	1 foo: 2 + 3"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #+
			                receiver: (TSendNode new
					                 setSelector: #foo
					                 receiver: (TConstantNode value: 1)
					                 arguments: { (TConstantNode value: 2) })
			                arguments: { (TConstantNode value: 3) }).

	self assert: translation equals: '(foo(1, 2)) + 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendGreaterThan [

	| translation send |
	send := TSendNode new
		        setSelector: #>=
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: 'a >= 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalse [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (!x) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseIfTrue [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStmtListNode new setStatements: { (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) {
	a = 1;
} else {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseIfTrueCollapseBothArmsOfConditional [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:ifTrue:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TConstantNode value: 7) })
		        arguments: { 
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'foo(x, 7);
{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseWithReceiverFalseConstant [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifFalse:
		        receiver: (TConstantNode value: false)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseWithReceiverSendNot [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:
		        receiver: (TSendNode new
				         setSelector: #not
				         receiver: (TVariableNode new setName: 'x')
				         arguments: {  })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseWithReceiverTrueConstant [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifFalse:
		        receiver: (TConstantNode value: true)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation equals: ''
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNil [

	| translation send |
	generator generateDeadCode: true.
	send := TSendNode new
		        setSelector: #ifNil:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (!(foo(x))) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilifNotNil [

	"(self foo: x) ifNil: [ a:= true. c = 1 ] ifNotNil: [ b := false. c := 7 ]"
	| translation send |
	send := TSendNode new
		        setSelector: #ifNil:ifNotNil:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }).
							(TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'b')
						          expression: (TConstantNode value: true)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 7)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (foo(x)) {
	b = 1;
	c = 7;
} else {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilifNotNilWithNilConstantReceiver [
	
	"nil ifNil: [ a:= true. c = 1 ] ifNotNil: [ b := false. c := 7 ]"
	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNil:ifNotNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }).
							(TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'b')
						          expression: (TConstantNode value: true)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 7)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNil [

	| translation send |
	generator generateDeadCode: true.
	send := TSendNode new
		        setSelector: #ifNotNil:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (foo(x)) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilIfNil [

	"(self foo: x) ifNotNil: [ a:= true. c = 1 ] ifNil: [ b := false. c := 7 ]"
	| translation send |
	send := TSendNode new
		        setSelector: #ifNotNil:ifNil:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }).
							(TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'b')
						          expression: (TConstantNode value: true)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 7)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (foo(x)) {
	a = 0;
	c = 1;
} else {
	b = 1;
	c = 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilIfNilWithNilConstantReceiver [

	"nil ifNotNil: [ a:= true. c = 1 ] ifNil: [ b := false. c := 7 ]"
	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNotNil:ifNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }).
							(TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'b')
						          expression: (TConstantNode value: true)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 7)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	b = 1;
	c = 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNotNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation equals: ''
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrue [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueAsArgument [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TStmtListNode new setStatements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = (x
	 ? ((a = 0), (c = 1))
	 : 0)'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfTrueAsArgumentWithReceiverTrueConstant [

	| translation send |
	generator generateDeadCode: false.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:
				         receiver: (TConstantNode value: true)
				         arguments: { (TConstantNode value: 1) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueIfFalse [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:ifFalse:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStmtListNode new setStatements: { (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) {
	a = 0;
	c = 1;
} else {
	a = 1;
}'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfTrueIfFalseAsArgument [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:ifFalse:
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TStmtListNode new setStatements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }).
								(TStmtListNode new setStatements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: true)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 0)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = (x
	 ? ((a = 0), (c = 1))
	 : ((a = 1), (c = 0)))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueIfFalseCollapseBothArmsOfConditional [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:ifFalse:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TConstantNode value: 7) })
		        arguments: { 
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStmtListNode new setStatements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'foo(x, 7);
{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueWithBlockReceiver [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TStmtListNode new setStatements: { (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'y')
						          expression: (TConstantNode value: false)).
								TVariableNode new setName: 'x' })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (((y = 0), x)) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfTrueWithReceiverBinaryOperation [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TSendNode new
				         setSelector: #&
				         receiver: (TVariableNode new setName: 'a')
				         arguments: { (TVariableNode new setName: 'b') })
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (a && b) {
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueWithReceiverFalseConstant [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TConstantNode value: false)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation equals: ''
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueWithReceiverTrueConstant [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TConstantNode value: true)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	a = 0;
	c = 1;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueWithSingleStatementArgument [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { TVariableNode new setName: 'break' }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) break'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIntegerValueOf [

	| translation send |

	send := TSendNode new
					setSelector: #integerValueOf:
					receiver: (TVariableNode named: 'self')
					arguments: { TConstantNode value: true }.
	translation := self translate: send.

	self assert: translation equals: '1 >> ', numSmallIntegerTagBits asString
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIsNil [

	| translation send |

	send := TSendNode new
					setSelector: #isNil
					receiver: (TVariableNode new setName: 'ptr')
					arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'ptr == null'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShifLitteralIntegerOverflow [

	| translation send |
	
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TConstantNode value: 3)
		        arguments: { (TConstantNode value: 32) }.
	translation := self translate: send.

	self assert: translation equals: '3ULL << 32'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShifNegativeLitteralIntegerOverflow [

	| translation send |
	
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TConstantNode value: -3)
		        arguments: { (TConstantNode value: 32) }.
	translation := self translate: send.

	self assert: translation equals: '((int) (((usqInt) -3 ) << 32) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShift [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'sqInt'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((sqInt) (((usqInt) a ) << 3) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftByVariable [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'unsigned short'.
	
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TConstantNode value: 3)
		        arguments: { (TVariableNode new setName: 'a') }.
	translation := self translate: send.

	self assert: translation equals: '3U << a'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftByVariableIn32Bits [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'sqInt'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TConstantNode value: 3)
		        arguments: { (TVariableNode new setName: 'a') }.
	translation := self translate: send.

	self assert: translation equals: '3U << a'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftByVariableIn64Bits [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'sqInt'.
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TConstantNode value: 3)
		        arguments: { (TVariableNode new setName: 'a') }.
	translation := self translate: send.

	self assert: translation equals: '3ULL << a'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftLong [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'sqLong'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((sqLong) (((usqLong) a ) << 3) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftShortType [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'short'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((sqInt) (((usqInt) a ) << 3) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftUnsigned [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'usqInt'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: 'a << 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLeftBitShiftUnsignedShortType [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'unsigned short'.
	send := TSendNode new
		        setSelector: #<<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) << 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLessThan [

	| translation send |
	send := TSendNode new
		        setSelector: #<
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: 'a < 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendLessThanOrEqual [

	| translation send |
	send := TSendNode new
		        setSelector: #<=
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: 'a <= 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendMax [

	| translation send |
	send := TSendNode new
		        setSelector: #max:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TVariableNode new setName: 'y') }.
	translation := self translate: send.

	self assert: translation equals: '((x < y) ? y : x)'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendMaxSmallInteger [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #maxSmallInteger
			                receiver: (TVariableNode new setName: 'aMemory')
			                arguments: { }).

	self assert: translation equals: 'MaxSmallInteger'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccess [

	| translation send |

	send := TSendNode new
		        setSelector: #aField
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'toto.aField'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendMin [

	| translation send |
	send := TSendNode new
		        setSelector: #min:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TVariableNode new setName: 'y') }.
	translation := self translate: send.

	self assert: translation equals: '((x < y) ? x : y)'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendMinSmallInteger [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #minSmallInteger
			                receiver: (TVariableNode new setName: 'aMemory')
			                arguments: { }).

	self assert: translation equals: 'MinSmallInteger'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendModulo [

	| translation send |

	send := TSendNode new
					setSelector: #\\
					receiver: (TConstantNode value: 3)
					arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '3 % 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendNegated [

	| translation send |

	send := TSendNode new
					setSelector: #negated
					receiver: (TConstantNode value: 3)
					arguments: { }.
	translation := self translate: send.

	self assert: translation equals: '-3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendNoMask [

	| translation send |

	send := TSendNode new
					setSelector: #noMask:
					receiver: (TVariableNode new setName: 'a')
					arguments: { TConstantNode value: 1 }.
	translation := self translate: send.

	self assert: translation equals: '(a & 1) == 0'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendNot [

	| translation send |

	send := TSendNode new
					setSelector: #not
					receiver: (TConstantNode value: true)
					arguments: { }.
	translation := self translate: send.

	self assert: translation equals: '!1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendNotEqual [

	| translation send |

	send := TSendNode new
					setSelector: #~=
					receiver: (TVariableNode new setName: 'a')
					arguments: {(TConstantNode value: 2)}.
	translation := self translate: send.

	self assert: translation equals: 'a != 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendNotNil [

	| translation send |

	send := TSendNode new
					setSelector: #notNil
					receiver: (TVariableNode new setName: 'ptr')
					arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'ptr != null'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendOr [

	| translation send |

	send := TSendNode new
					setSelector: #|
					receiver: (TConstantNode value: 0)
					arguments: { TConstantNode value: 1 }.
	translation := self translate: send.

	self assert: translation equals: '0 || 1'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPerform [
	"self perform: #foo"
	| translation send |
	send := TSendNode new
		        setSelector: #perform:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: {(TConstantNode value: #foo)}.
	translation := self translate: send.

	self assert: translation equals: 'foo()'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPerformWith [
	"self perform: #foo with: x"
	| translation send |
	send := TSendNode new
		        setSelector: #perform:with:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: {TConstantNode value: #foo. TVariableNode new setName: 'x'}.
	translation := self translate: send.

	self assert: translation equals: 'foo(x)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPerformWithWith [
	"self perform: #foo with: x with: y"
	| translation send |
	send := TSendNode new
		        setSelector: #perform:with:with:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: {TConstantNode value: #foo. TVariableNode new setName: 'x'. TVariableNode new setName: 'y'}.
	translation := self translate: send.

	self assert: translation equals: 'foo(x, y)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPlus [

	| translation send |

	send := TSendNode new
					setSelector: #+
					receiver: (
						TSendNode new
						setSelector: #+
						receiver: (TConstantNode value: 1)
						arguments: { TConstantNode value: 2 }
					)
					arguments: { TConstantNode value: 3 }.
	translation := self translate: send.

	self assert: translation equals: '(1 + 2) + 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPowerTo [

	| translation send |
	send := TSendNode new
		        setSelector: #**
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '(sqInt)(pow(x, 2))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPreDecrement [

	| translation send |

	send := TSendNode new
					setSelector: #preDecrement
					receiver: (TVariableNode new setName: 'i')
					arguments: { }.
	translation := self translate: send.

	self assert: translation equals: '--i'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendPreIncrement [

	| translation send |

	send := TSendNode new
					setSelector: #preIncrement
					receiver: (TVariableNode new setName: 'i')
					arguments: { }.
	translation := self translate: send.

	self assert: translation equals: '++i'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRaisedTo [

	| translation send |
	send := TSendNode new
		        setSelector: #raisedTo:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: 'pow(x, 2)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRepeat [

	" [ var := var - 7 ] repeat"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #repeat
		        receiver: (TStmtListNode new setStatements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (1) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRightBitShiftSignedIn64Bits [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'sqInt'.
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #>>
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) >> 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRightBitShiftUnsigned [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'usqInt'.
	send := TSendNode new
		        setSelector: #>>
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) >> 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRightBitShiftUnsignedIn64Bits [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'usqInt'.
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #>>
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a ) >> 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendRounded [

	| translation send |
	send := TSendNode new
		        setSelector: #rounded
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: 'round(a)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSequentialAndWithConstantReceiverTrue [

	| translation send |
	send := TSendNode new
		        setSelector: #and:
		        receiver: (TConstantNode value: true)
		        arguments: { (TStmtListNode new setStatements: { 
					         (TSendNode new
						          setSelector: #+
						          receiver: (TConstantNode value: 1)
						          arguments: {(TConstantNode value: 2)}).
					         (TSendNode new
						          setSelector: #=
						          receiver: (TVariableNode new setName: 'a')
						          arguments: { (TVariableNode new setName: 'b') }) }) }.
	translation := self translate: send.

	self assert: translation equals: '1 && ((1 + 2 , a == b))'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendShouldBeImplemented [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #shouldBeImplemented
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { }).

	self assert: translation equals: 'error("shouldBeImplemented")'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendShouldNotImplement [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #shouldNotImplement
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { }).

	self assert: translation equals: 'error("shouldNotImplement")'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftExpressionReceiver [

	| translation send |
	generator var: 'a' declareC: 'sqLong a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TSendNode new
				         setSelector: #+
				         receiver: (TVariableNode new setName: 'a')
				         arguments: { (TConstantNode value: 1) })
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((signed) (a + 1) ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftInt64VariableReceiver [

	| translation send |
	generator var: 'a' declareC: '__int64 a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((__int64) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftLongLongVariableReceiver [

	| translation send |
	generator var: 'a' declareC: 'long long a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((long long) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftSqLongVariableReceiver [

	| translation send |
	generator var: 'a' declareC: 'sqLong a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((sqLong) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftUnsignedInt64VariableReceiver [

	| translation send |
	generator var: 'a' declareC: 'unsigned __int64 a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((signed __int64) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftUnsignedLongLongVariableReceiver [

	| translation send |
	generator var: 'a' declareC: 'unsigned long long a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((signed long long) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedBitShiftUsqLongVariableReceiver [

	| translation send |
	generator var: 'a' declareC: 'usqLong a'.
	send := TSendNode new
		        setSelector: #signedBitShift:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 2) }.
	translation := self translate: send.

	self assert: translation equals: '((sqLong) a ) << 2'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntFromLong [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #signedIntFromLong
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((int) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntFromLong64 [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #signedIntFromLong64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((sqLong) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntFromShort [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #signedIntFromShort
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((short) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntToLong [

	| translation send |
	send := TSendNode new
		        setSelector: #signedIntToLong
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntToLong64 [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #signedIntToLong64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) a )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntToLong64Bits [

	| translation send |
	generator wordSize: 8.
	send := TSendNode new
		        setSelector: #signedIntToLong
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) ((int) a ) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedIntToShort [

	| translation send |
	generator var: 'a' declareC: 'int a'.
	send := TSendNode new
		        setSelector: #signedIntToShort
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '((usqInt) ((short) a ) )'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSignedRightBitShiftVariable64Bits [

	| translation send |
	generator currentMethod declarationAt: 'a' put: 'long long'.
	send := TSendNode new
		        setSelector: #>>>
		        receiver: (TVariableNode new setName: 'a')
		        arguments: { (TConstantNode value: 3) }.
	translation := self translate: send.

	self assert: translation equals: '((sqInt) a ) >> 3'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendSubclassResponsibility [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #subclassResponsibility
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { }).

	self assert: translation equals: 'error("subclassResponsibility")'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendTimes [

	| translation send |

	send := TSendNode new
					setSelector: #*
					receiver: (
						TSendNode new
						setSelector: #+
						receiver: (TConstantNode value: 1)
						arguments: { TConstantNode value: 2 }
					)
					arguments: { TConstantNode value: 3 }.
	translation := self translate: send.

	self assert: translation equals: '(1 + 2) * 3'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendTimesRepeat [

	"5 timesRepeat: [ var := var - 7 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #timesRepeat:
		        receiver: (TConstantNode value: 5)
		        arguments: { (TStmtListNode new setStatements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	var -= 7;
}{
	var -= 7;
}{
	var -= 7;
}{
	var -= 7;
}{
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToByDo [

	"1 to: 10 by: 2 do: [ var := var -7 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:by:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TConstantNode value: 10).
						(TConstantNode value: 2).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'for (i = 1; i <= 10; i += 2) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToByDoLimitExpressionHasSideEffect [

	"1 to: (var foo) by: 2 do: [ var := var -7 ]"
	"In the C for loop, the limit expression is executed at each iteration.
	In Pharo, the limit expression (var foo in this exemple) is executed only once, the value is then passed as argument to the function to:by:do:.
	If the limit expression has side-effect, a limit variable is declared, for both safety and efficiency."
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:by:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TSendNode new
					         setSelector: #foo
					         receiver: (TVariableNode new setName: 'var')
					         arguments: {  }).
				        (TConstantNode value: 2).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }).
						(TVariableNode new setName: 'toDoLimit') }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: 'for (i = 1, toDoLimit = foo(var); i <= toDoLimit; i += 2) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToByDoWithNegativeStep [

	"10 to: 0 by: -2 do: [ var := var -7 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:by:do:
		        receiver: (TConstantNode value: 10)
		        arguments: { 
				        (TConstantNode value: 0).
						(TConstantNode value: -2).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'for (i = 10; i >= 0; i += -2) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToByDoWithOperationReceiver [

	"(1 + 1 foo: 2) to: 10 by: 2 do: [ var := var -7 ]"

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:by:do:
		        receiver: (TSendNode new
				         setSelector: #+
				         receiver: (TConstantNode value: 1)
				         arguments: { (TSendNode new
						          setSelector: #foo
						          receiver: (TConstantNode value: 1)
						          arguments: { (TConstantNode value: 2) }) })
		        arguments: { 
				        (TConstantNode value: 10).
				        (TConstantNode value: 2).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: 'for (i = 1 + (foo(1, 2)); i <= 10; i += 2) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToByDoWithOperationUpdate [

	"1 to: 10 by: (1 + 1 foo: 2) do: [ var := var -7 ]"

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:by:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TConstantNode value: 10).
				        (TSendNode new
					         setSelector: #+
					         receiver: (TConstantNode value: 1)
					         arguments: { (TSendNode new
							          setSelector: #foo
							          receiver: (TConstantNode value: 1)
							          arguments: { (TConstantNode value: 2) }) }).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: 'for (i = 1; i <= 10; i += 1 + (foo(1, 2))) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDo [

	"1 to: 10 do: [ var := var -7 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TConstantNode value: 10).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'for (i = 1; i <= 10; i++) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDoAvoidUnderflowingOfLimitExpression [

	"1 to: foo - 1 do: [ var := var - 7 ]"
	"Here, the limit expression is foo -1."
	"If foo is an unsigned int, foo-1 can be UINT_MAX. Instead of i<= (foo-1) we have i<foo in order to avoid this 'underflow'."
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TSendNode new
					         setSelector: #-
					         receiver: (TVariableNode new setName: 'foo')
					         arguments: { (TConstantNode value: 1) }).
				        (TConstantNode value: 10).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: 'for (i = 1; i < foo; i++) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDoLimitExpressionHasSideEffect [

	"1 to: (var foo) do: [ var := var -7 ]"

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:do:
		        receiver: (TConstantNode value: 1)
		        arguments: { 
				        (TSendNode new
					         setSelector: #foo
					         receiver: (TVariableNode new setName: 'var')
					         arguments: {  }).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: 'for (i = 1; i <= (foo(var)); i++) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDoWithOperationReceiver [

	"(1 + 1 foo: 2) to: 10 do: [ var := var -7 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #to:do:
		        receiver: (TSendNode new
				         setSelector: #+
				         receiver: (TConstantNode value: 1)
				         arguments: { (TSendNode new
						          setSelector: #foo
						          receiver: (TConstantNode value: 1)
						          arguments: { (TConstantNode value: 2) }) })
		        arguments: { 
				        (TConstantNode value: 10).
				        (TStmtListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'for (i = 1 + (foo(1, 2)); i <= 10; i++) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendTruncateTo [

	| translation send |
	send := TSendNode new
		        setSelector: #truncateTo:
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {(TConstantNode value: 2)}.
	translation := self translate: send.

	self assert: translation equals: '(a & ~1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileFalseWithManyStatementsInReceiverAndArgument [

	"[ var := var - 7. var >= 21 ] whileFalse: [ b := var \\ 3 ]"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileFalse:
		        receiver: (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments:
			        { (TStmtListNode new setStatements: { (TAssignmentNode new
					          setVariable: (TVariableNode new setName: 'b')
					          expression: (TSendNode new
							           setSelector: #\\
							           receiver: (TVariableNode new setName: 'var')
							           arguments: {(TConstantNode value: 3)})) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (1) {
	var -= 7;
	if (var >= 21) break;
	b = var % 3;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileFalseWithOneStatementInReceiverBlock [

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileFalse:
		        receiver:
			        (TStmtListNode new setStatements: { (TSendNode new
					          setSelector: #&
					          receiver: (TVariableNode new setName: 'a')
					          arguments: {(TVariableNode new setName: 'b')}) })
		        arguments: { (TStmtListNode new setStatements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (!(a && b)) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileFalseWithoutArguments [

	"[ var := var - 7. var >= 21 ] whileFalse"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileFalse
		        receiver: (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments: {}.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'do{
	var -= 7;
}while(!(var >= 21))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithManyStatementsInReceiverAndArgument [

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileTrue:
		        receiver: (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments:
			        { (TStmtListNode new setStatements: { (TAssignmentNode new
					          setVariable: (TVariableNode new setName: 'b')
					          expression: (TSendNode new
							           setSelector: #\\
							           receiver: (TVariableNode new setName: 'var')
							           arguments: {(TConstantNode value: 3)})) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (1) {
	var -= 7;
	if (!(var >= 21)) break;
	b = var % 3;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithNilAsArgument [

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileTrue:
		        receiver: (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #&
						          receiver: (TVariableNode new setName: 'a')
						          arguments: { (TVariableNode new setName: 'b') }) })
		        arguments:
		        { (TStmtListNode new setStatements:
			         { (TVariableNode new setName: 'nil') }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'do{
	var -= 7;
}while(a && b)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithOneStatementInReceiverBlock [

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileTrue:
		        receiver:
			        (TStmtListNode new setStatements: { (TSendNode new
					          setSelector: #&
					          receiver: (TVariableNode new setName: 'a')
					          arguments: {(TVariableNode new setName: 'b')}) })
		        arguments: { (TStmtListNode new setStatements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (a && b) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithoutArguments [

	"[ var := var - 7. var >= 21 ] whileTrue"
	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileTrue
		        receiver: (TStmtListNode new setStatements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments: {}.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'do{
	var -= 7;
}while(var >= 21)'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testSendWordSize [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #wordSize
			                receiver: (TVariableNode new setName: 'aVM')
			                arguments: { }).

	self assert: translation equals: 'BytesPerWord'
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
			expression:  (TConstantNode value: 1).
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
			TConstantNode value: { 1 . 2 . 3 }.
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

	self assert: translation equals: 'null'
]

{ #category : #'tests-variables' }
SlangBasicTranslationTest >> testTranslateNormalVariable [

	| translation |
	translation := self translate: (TVariableNode new setName: 'someVar').

	self assert: translation equals: 'someVar'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testVariableAssignment [

	| translation variable expression |

	variable := TVariableNode new setName: 'var'.

	expression := TConstantNode value: 7.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation equals: 'var = 7'
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
					receiver: (TConstantNode value: 1)
					arguments: { TConstantNode value: 2 }.
				TVariableNode new setName: 'var'.
				TSendNode new
					setSelector: #bar
					receiver: (TConstantNode value: 3)
					arguments: { TConstantNode value: 4 }.
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
			TConstantNode value: 7.
		}.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation equals: 'var -= 7'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testVariableUpdateAssignmentPlus [

	| translation variable expression |

	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		setSelector: #+
		receiver: variable 
		arguments: { 
			TConstantNode value: 7.
		}.

	translation := self translate: (TAssignmentNode new
			setVariable: variable
			expression: expression).

	self assert: translation equals: 'var += 7'
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

{ #category : #accessing }
SlangBasicTranslationTest >> wordSize [
	
	^ generator wordSize
]
