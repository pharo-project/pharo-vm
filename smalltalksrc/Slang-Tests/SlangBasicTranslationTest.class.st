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

{ #category : #accessing }
SlangBasicTranslationTest >> generator [

	^ generator
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator: anObject [

	generator := anObject
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
	generator currentMethod: (TMethod new
		labels: Set new;
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
	
	self assert: translation equals: 'NULL'
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

	self assert: translation equals: '(double)(x)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsInteger [

	| translation send |
	send := TSendNode new
		        setSelector: #asInteger
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '(sqInt)(x)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendAsIntegerPtr [

	| translation send |
	send := TSendNode new
		        setSelector: #asIntegerPtr
		        receiver: (TVariableNode new setName: 'x')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '(sqIntptr_t)(x)'
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
SlangBasicTranslationTest >> testSendBitInvert64On32Bits [

	| translation send |
	send := TSendNode new
		        setSelector: #bitInvert64
		        receiver: (TVariableNode new setName: 'a')
		        arguments: {}.
	translation := self translate: send.

	self assert: translation equals: '~(unsigned long long)a'
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

	self assert: translation equals: '~(usqIntptr_t)a'
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

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendFunctionCall [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4. var ] value"

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #foo
			                receiver: (TConstantNode value: 1)
			                arguments: { (TConstantNode value: 2) }).

	self assert: translation equals: 'foo(1, 2)'
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
}else {
	a = 1;
}'
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

	self assert: translation equals: 'ptr == NULL'
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

	self assert: translation equals: '((sqInt)((usqInt)(-3) << 32))'
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

	self assert: translation equals: '((sqInt)((usqInt)(a) << 3))'
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

	self assert: translation equals: '((sqLong)((usqLong)(a) << 3))'
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

	self assert: translation equals: '((sqInt)((usqInt)(a) << 3))'
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

	self assert: translation equals: '((usqInt)(a) << 3)'
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

	self assert: translation equals: 'ptr != NULL'
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
SlangBasicTranslationTest >> testSendRepeat [

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

	self assert: translation trimBoth equals: 'while(1) {
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

	self assert: translation equals: '((usqInt) a) >> 3'
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

	self assert: translation equals: '((usqInt) a) >> 3'
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

	self assert: translation equals: '((usqInt) a) >> 3'
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

	self assert: translation equals: '1 && ((1 + 2, a == b))'
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

	self assert: translation equals: '((sqLong) a) >> 3'
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

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #timesRepeat:
		        receiver: (TConstantNode value: 3)
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
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDo [

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

	self assert: translation trimBoth equals: 'for(i = 1; i <= 10; i++) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendToDoAvoidUnderflowing [

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
		equals: 'for(i = 1; i < foo; i++) {
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

	self assert: translation trimBoth equals: 'while(1) {
	var -= 7;
	if(var >= 21) break;
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

	self assert: translation trimBoth equals: 'while(!(a && b)) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileFalseWithoutArguments [

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

	self assert: translation trimBoth equals: 'while(1) {
	var -= 7;
	if(!(var >= 21)) break;
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

	self assert: translation trimBoth equals: 'while(a && b) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithoutArguments [

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

	self assert: translation equals: 'NULL'
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
