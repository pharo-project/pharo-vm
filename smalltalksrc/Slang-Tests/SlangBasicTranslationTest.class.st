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
		forSelector: #translationStrategy addOptions: { #astTranslate }
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

{ #category : #compatibility }
SlangBasicTranslationTest >> defineAtCompileTime: aString [

	^ #(#OPTION1 #OPTION3 #OPTION) includes: aString
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator [

	^ generator
]

{ #category : #accessing }
SlangBasicTranslationTest >> generator: anObject [

	generator := anObject
]

{ #category : #helpers }
SlangBasicTranslationTest >> getTMethodFrom: selector [

	"Generate a TMethod from a SlangBasicTranslationTestClass method."

	generator addClass: SlangBasicTranslationTestClass.
	generator inferTypes.
	^ generator methodNamed: selector
]

{ #category : #compatibility }
SlangBasicTranslationTest >> isNonArgumentImplicitReceiverVariableName: aString [ 
	
	^ false
]

{ #category : #helpers }
SlangBasicTranslationTest >> newLine [

	^ String cr
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
		definingClass: self class;
		selector: #setUp;
		yourself).
	generator pushScope: TStatementListNode new.
	
	"The translator accesses it directly using class variables..."
	SpurMemoryManager initBytesPerWord: 8.
	
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
					         (TStatementListNode new setArguments: #(  ) statements: { 
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
					         (TStatementListNode new setArguments: #(  ) statements: { 
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

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testBitShiftIfTrue [

	| translation ast |
	ast := TSendNode
		receiver: (TSendNode
			receiver: (TVariableNode named: 'aBoolean')
			selector: #ifTrue:ifFalse:
			arguments: { 
				TStatementListNode statements: { TConstantNode value: 1 }.
				TStatementListNode statements: { TConstantNode value: 2 }.
			 } )
		selector: #<<
		arguments: {TConstantNode value: 31}.
	
	translation := self translate: ast.
		
	self assert: translation equals: '((sqInt) (((usqInt) (((aBoolean)
	 ? 1
	 : 2)) ) << 0x1F) )'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValue [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4 ] value"

	| translation |

	translation := self translate: (TSendNode new
		setSelector: #value
		receiver: (TStatementListNode new
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
SlangBasicTranslationTest >> testBlockValueAsArgument [

	"Case:
	
	[ 1 foo: 2. 3 foo: 4. 5 foo: 6 ] value ifTrue: [ a := b ]"

	"In order to test the translation of a block as an argument, the block is given as condition of an if."

	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStatementListNode new
		              setArguments: #(  )
		              statements: { 
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
			                receiver: (TSendNode new
					                 setSelector: #value
					                 receiver: expression
					                 arguments: {  })
			                arguments:
				                { (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode new setName: 'a')
						                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, 2), foo(3, 4), foo(5, 6))) {
	a = b;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAsArgumentWithComment [

	| translation expression |
	expression := TStatementListNode new setArguments: #(  ) statements: { 
		TLabeledCommentNode withComment: 'yes!'.
		TConstantNode value: 17. }.
	translation := self translate: (TAssignmentNode
		variable: (TVariableNode named: 'v')
		expression: (TSendNode
			receiver: (TVariableNode named: 'v')
			selector: #ifTrue: 
			arguments: {expression})).

	self
		assert: translation trimBoth
		equals: 'v = ((v)
	 ? (/* yes! */ 17)
	 : 0)'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAsArgumentWithConstantArgument [

	"Case:
	
	([ :i | 1 foo: 2. i = 4 ] value: 4) ifTrue: [ a := b ]"

	"In order to test the translation of a block as an argument, the block is given as condition of an if."

	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStatementListNode new
		              setArguments: #( i )
		              statements: { 
				              (TSendNode new
					               setSelector: #foo
					               receiver: (TConstantNode value: 1)
					               arguments: { (TConstantNode value: 2) }).
				              (TSendNode new
					               setSelector: #=
					               receiver: (TVariableNode named: 'i')
					               arguments: { (TConstantNode value: 4) }) }.
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSendNode new
					                 setSelector: #value:
					                 receiver: expression
					                 arguments: { (TConstantNode value: 4) })
			                arguments:
				                { (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode new setName: 'a')
						                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, 2), 4 == 4)) {
	a = b;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAsArgumentWithMultipleArguments [

	"Case:
	
	([ :i :j | 1 foo: 2. i + j = 4  ] value: 4 value: 5) ifTrue: [ a := b ]"

	"In order to test the translation of a block as an argument, the block is given as condition of an if."

	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStatementListNode new
		              setArguments: #( i j )
		              statements: { 
				              (TSendNode new
					               setSelector: #foo
					               receiver: (TConstantNode value: 1)
					               arguments: { (TConstantNode value: 2) }).
				              (TSendNode new
					               setSelector: #=
					               receiver: (TSendNode new
							                setSelector: #+
							                receiver: (TVariableNode named: 'i')
							                arguments: { (TVariableNode named: 'j') })
					               arguments: { (TConstantNode value: 4) }) }.
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSendNode new
					                 setSelector: #value:
					                 receiver: expression
					                 arguments: { 
							                 (TConstantNode value: 4).
							                 (TConstantNode value: 5) })
			                arguments:
				                { (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode new setName: 'a')
						                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, 2), (4 + 5) == 4)) {
	a = b;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAsArgumentWithNonLeafArgument [

	"Case:
	
	([ :i | 1 foo: 2. i = 4 ] value: (3 foo: 4)) ifTrue: [ a := b ]"

	"In order to test the translation of a block as an argument, the block is given as condition of an if."

	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStatementListNode new
		              setArguments: #( i )
		              statements: { 
				              (TSendNode new
					               setSelector: #foo
					               receiver: (TConstantNode value: 1)
					               arguments: { (TConstantNode value: 2) }).
				              (TSendNode new
					               setSelector: #=
					               receiver: (TVariableNode named: 'i')
					               arguments: { (TConstantNode value: 4) }) }.
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSendNode new
					                 setSelector: #value:
					                 receiver: expression
					                 arguments: { (TSendNode new
							                  setSelector: #foo
							                  receiver: (TConstantNode value: 3)
							                  arguments: { (TConstantNode value: 4) }) })
			                arguments:
				                { (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode new setName: 'a')
						                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, 2), (foo(3, 4)) == 4)) {
	a = b;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testBlockValueAsArgumentWithNonLeafArgumentAndMultipleUse [

	"Case:
	
	([ :i | 1 foo: i. i = 4 ] value: (3 foo: 4)) ifTrue: [ a := b ]"

	"In order to test the translation of a block as an argument, the block is given as condition of an if."

	| translation variable expression |
	variable := TVariableNode new setName: 'var'.
	expression := TStatementListNode new
		              setArguments: #( i )
		              statements: { 
				              (TSendNode new
					               setSelector: #foo
					               receiver: (TConstantNode value: 1)
					               arguments: { (TVariableNode named: 'i') }).
				              (TSendNode new
					               setSelector: #=
					               receiver: (TVariableNode named: 'i')
					               arguments: { (TConstantNode value: 4) }) }.
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSendNode new
					                 setSelector: #value:
					                 receiver: expression
					                 arguments: { (TSendNode new
							                  setSelector: #foo
							                  receiver: (TConstantNode value: 3)
							                  arguments: { (TConstantNode value: 4) }) })
			                arguments:
				                { (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode new setName: 'a')
						                  expression: (TVariableNode new setName: 'b')) }) }).

	self
		assert: translation trimBoth
		equals: 'if ((foo(1, foo(3, 4)), (foo(3, 4)) == 4)) {
	a = b;
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
		receiver: (TStatementListNode new
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
				receiver: (TStatementListNode new
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
		receiver: (TStatementListNode new
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
			                receiver: (TStatementListNode new
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
				                (TStatementListNode new
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
		receiver: (TStatementListNode new
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

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testCaseStatementIsTranslatedAsSwitch [

	| translation |
	
	translation := self translate: (TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode }
		arguments: {}).

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	{
		someBytecode();
	}
	break;
}'
]

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testCaseStatementWithDifferentBodyAreDifferentCases [

	| translation |
	
	translation := self translate: (TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode . #someBytecode2 }
		arguments: {}).

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	{
		someBytecode();
	}
	break;
	case 1:
	{
		someBytecode2();
	}
	break;
}'
]

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testCaseStatementWithSameBodyAreSameCase [

	| translation |
	
	translation := self translate: (TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode . #someBytecode }
		arguments: {}).

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	case 1:
	{
		someBytecode();
	}
	break;
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
		receiver: (TStatementListNode new
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

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotInitializeReadBeforeWrittenArrayTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodUsingSingleArrayVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodUsingSingleArrayVariable);
	{
		int * bar;
		int[17] foo;

		bar = foo;
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotInitializeReadBeforeWrittenExternalTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodUsingSingleExternalVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodUsingSingleExternalVariable);
	{
		sqInt bar;
		external int foo;

		bar = foo;
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotInitializeReadBeforeWrittenInitializedTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodUsingSingleNonInitializedVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodUsingSingleNonInitializedVariable);
	{
		sqInt bar;
		sqInt foo;

		foo = 0;
		bar = foo;
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotInitializeReadBeforeWrittenStaticTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodUsingSingleStaticVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodUsingSingleStaticVariable);
	{
		int bar;
		static int foo;

		bar = foo;
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotRemoveExternalTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodDefiningSingleExternVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodDefiningSingleExternVariable);
	{
		extern int foo;


	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeDoesNotRemoveStaticTemp [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodDefiningSingleStaticVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodDefiningSingleStaticVariable);
	{
		static int foo;


	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeRemovesUnusedTemps [

	"Test the smalltalk comment of the function."

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodDefiningSingleVariable.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodDefiningSingleVariable);
	{
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeSortsLocalTemps [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithUnsortedTemps.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: '{
	VM_LABEL(methodWithUnsortedTemps);
	{
		sqInt aaa;
		sqInt bar;
		sqInt ddd;
		sqInt foo;
		sqInt zzz;

		aaa = 0;
		foo = 0;
		zzz = 0;
		bar = aaa;
		ddd = zzz + foo;
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeWithSharedCase [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithSharedCase.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: 'methodWithSharedCase:
/* methodWithSharedCase */
{
	VM_LABEL(methodWithSharedCase);
	{
	}
}'
]

{ #category : #'tests-inlinenode' }
SlangBasicTranslationTest >> testInlineNodeWithSharedLabelInCase [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithSharedLabelInCase.
	translation := self translate: tMethod asInlineNode.
	self
		assert: translation
		equals: 'sharedLabel:
/* methodWithSharedLabelInCase */
{
	VM_LABEL(methodWithSharedLabelInCase);
	{
	}
}'
]

{ #category : #'tests-labels' }
SlangBasicTranslationTest >> testLabel [

	| label translation |
	label := TLabeledCommentNode label: 'aLabel'.
	translation := self translate: label.

	self assert: translation equals: 'aLabel:
;'
]

{ #category : #'tests-labels' }
SlangBasicTranslationTest >> testLabelWithASMLabelDoesNotOutputOutsideInterpret [

	| label translation |
	label := TLabeledCommentNode new asmLabel: 'vm_label'.
	translation := self translate: label.

	self assert: translation equals: ''
]

{ #category : #'tests-labels' }
SlangBasicTranslationTest >> testLabelWithASMLabelWithinInterpret [

	| label translation |
	generator currentMethod: (TMethod new
		selector: #interpret;
		yourself).
	
	label := TLabeledCommentNode new asmLabel: 'vm_label'.
	translation := self translate: label.

	self assert: translation equals: 'VM_LABEL(vm_label);'
]

{ #category : #'tests-labels' }
SlangBasicTranslationTest >> testLabelWithComment [

	| label translation |
	label := TLabeledCommentNode withComment: 'some comment'.
	translation := self translate: label.

	self assert: translation equals: '/* some comment */'
]

{ #category : #'tests-labels' }
SlangBasicTranslationTest >> testLabelWithCommentWithPreviousCommentMarkingAnInline [

	| label translation |
	
	"If the previous comment marked an inline, do not output anything"
	generator previousCommentMarksInlining: true.
	
	label := TLabeledCommentNode withComment: 'some comment'.
	translation := self translate: label.

	self assert: translation equals: ''
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodComment [

	"Test the smalltalk comment of the function."

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithMultilineComment.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 1) , self newLine
			, (translation lineNumber: 2)
		equals:
			'/*	This function is doing nothing, and this comment is useless. Not that 
	useless finaly, because used to test method comments :D */'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodCommentOriginalMethod [

	"Comment that includes the pharo style method signature : ClassName>>MethodName "

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithMultilineComment.
	translation := self translate: tMethod.
	self
		assert: (translation trimBoth lineNumber: 3)
		equals:
		'/* SlangBasicTranslationTestClass>>#methodWithMultilineComment */'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodConditionalCompilationWithAnOption [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithAnOptionPragma.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithAnOptionPragma */

#if OPTION
static sqInt
methodWithAnOptionPragma(void)
{
	return 0;
}

#endif /* OPTION */'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodConditionalCompilationWithSeveralOptions [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithOptionPragma.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithOptionPragma */

#if OPTION1 && OPTION3
static sqInt
methodWithOptionPragma(void)
{
	return 0;
}

#endif /* OPTION1 && OPTION3 */'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodDefinitionRefersToGlobalStruct [

	"Test if the macro DECL_MAYBE_SQ_GLOBAL_STRUCT is included when the method references to global struct."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithMultilineComment.
	tMethod referencesGlobalStruct.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 7)
		equals: '	DECL_MAYBE_SQ_GLOBAL_STRUCT;'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodDefinitionRefersToVolatileGlobalStruct [

	"Test if the macro DECL_MAYBE_VOLATILE_SQ_GLOBAL_STRUCT is included when the method references to volatile global struct."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithVolatilePragma.
	tMethod referencesGlobalStruct.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 5)
		equals: '	DECL_MAYBE_VOLATILE_SQ_GLOBAL_STRUCT;'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodLocals [
	
	"Test method local variables printing."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithLocalVariables.
	tMethod recordDeclarationsIn: generator.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithLocalVariables */
static float
methodWithLocalVariables(void)
{
	int a;
	int b;
	float foo;

	foo = 1.2;
	a = 1;
	b = 1;
	return (a + b) + foo;
}'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodLocalsWithGlobalStruct [
	
	"Test method local variables printing."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithLocalVariables.
	tMethod referencesGlobalStruct.
	tMethod recordDeclarationsIn: generator.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithLocalVariables */
static float
methodWithLocalVariables(void)
{
	DECL_MAYBE_SQ_GLOBAL_STRUCT;
	int a;
	int b;
	float foo;

	foo = 1.2;
	a = 1;
	b = 1;
	return (a + b) + foo;
}'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodLocalsWithGlobalStructAndVolatile [
	
	"Test method local variables printing."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithLocalVariables.
	tMethod referencesGlobalStruct.
	tMethod recordDeclarationsIn: generator.
	tMethod properties: { #volatile -> true } asDictionary.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithLocalVariables */
static float
methodWithLocalVariables(void)
{
	DECL_MAYBE_VOLATILE_SQ_GLOBAL_STRUCT;
	volatile int a;
	volatile int b;
	volatile float foo;

	foo = 1.2;
	a = 1;
	b = 1;
	return (a + b) + foo;
}'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodLocalsWithVolatile [
	
	"Test method local variables printing."
	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithLocalVariables.
	tMethod recordDeclarationsIn: generator.
	tMethod properties: { #volatile -> true } asDictionary.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithLocalVariables */
static float
methodWithLocalVariables(void)
{
	volatile int a;
	volatile int b;
	volatile float foo;

	foo = 1.2;
	a = 1;
	b = 1;
	return (a + b) + foo;
}'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodParameters [

	"Test method parameters."
	| translation tMethod |
	generator addClass: SlangBasicTranslationTestClass.
	tMethod := generator methodNamed: #first:second:.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 4)
		equals: 'firstsecond(sqInt param1, sqInt param2)'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodPrototypeWithExport [

	"Test return type export with macro EXPORT()."
	| translation tMethod |
	tMethod := self getTMethodFrom: #increment:.
	tMethod export: true.
	tMethod returnType: #sqInt.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 2) , self newLine
			, (translation lineNumber: 3)
		equals: 'EXPORT(sqInt)
increment(sqInt x)'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodPrototypeWithFunctionPointerReturnType [

	"Test prototype when return type is a function pointer."
	| translation tMethod |
	tMethod := self getTMethodFrom: #increment:.
	tMethod returnType: 'void (*increment(sqInt x))(void)'.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 2)
		equals: 'static void (*increment(sqInt x))(void)'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodPrototypeWithStatic [

	| translation tMethod |
	tMethod := self getTMethodFrom: #increment:.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 2) , self newLine
			, (translation lineNumber: 3)
		equals: 'static sqInt
increment(sqInt x)'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodReturnType [

	| translation tMethod |
	tMethod := self getTMethodFrom: #increment:.
	tMethod static: false.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self assert: (translation lineNumber: 2) equals: 'sqInt'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodUsingExternVariable [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodDefiningSingleVariable.
	tMethod declarationAt: 'foo' put: 'extern float foo'. 
	tMethod recordDeclarationsIn: generator.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 5)
		equals: '	extern float foo;'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodUsingStaticVariable [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodDefiningSingleVariable.
	tMethod declarationAt: 'foo' put: 'static float foo'. 
	tMethod recordDeclarationsIn: generator.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 5)
		equals: '	static float foo;'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodVolatileLocals [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithVolatileLocalVariables.
	tMethod recordDeclarationsIn: generator.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 5) , self newLine
			, (translation lineNumber: 6) , self newLine
			, (translation lineNumber: 7)
		equals: '	volatile int a;
	volatile int b;
	volatile float foo;'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodWithNoParameter [

	| translation tMethod |
	tMethod := self getTMethodFrom: #methodWithMultilineComment.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: (translation lineNumber: 5)
		equals: 'methodWithMultilineComment(void)'
]

{ #category : #'tests-method' }
SlangBasicTranslationTest >> testMethodWithReturnTypeWithoutReturnReturnsZero [

	| translation tMethod |
	generator addClass: SlangBasicTranslationTestClass.
	generator inferTypes.
	tMethod := generator methodNamed: #methodWithoutReturn.
	translation := self translate: tMethod.
	translation := translation trimBoth.
	self
		assert: translation
		equals: '/* SlangBasicTranslationTestClass>>#methodWithoutReturn */
static sqInt
methodWithoutReturn(void)
{
	return 0;
}'
]

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testNonContiguousCaseStatementWithSameBodyAreCollapsedInSameCase [

	| translation |
	
	translation := self translate: (TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode . #someBytecode2 . #someBytecode }
		arguments: {}).

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	case 2:
	{
		someBytecode();
	}
	break;
	case 1:
	{
		someBytecode2();
	}
	break;
}'
]

{ #category : #'tests-blocks' }
SlangBasicTranslationTest >> testReturnBlockValueValueValue [

	"Case:
	
	return [ :a :b :c | a + b ] value: d value: e value: f "

	| translation |

	translation := self translate: (TReturnNode expression: 
		(TSendNode new
			setSelector: #value:value:value:
			receiver: (TStatementListNode new
				setArguments: { 
					TVariableNode named: 'a'.
					TVariableNode named: 'b'.
					TVariableNode named: 'c' }
				statements: {
					TSendNode new
						setSelector: #+
						receiver: (TVariableNode named: 'a')
						arguments: { TVariableNode named: 'b' }.
				})
			arguments: {
				TVariableNode named: 'd'.
				TVariableNode named: 'e'.
				TVariableNode named: 'f'. })).

	self assert: translation trimBoth equals: '{
	return a + b;
}'
]

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testReturnCaseStatementDoesNotReplaceGotoByReturn [

	| translation node |
	node := (TReturnNode expression: ((TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode }
		arguments: {}))).
	node replaceNodesIn: { node expression cases last -> (TGoToNode label: #destination) } asDictionary.
	
	translation := self translate: node.

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	goto destination;
	default:
	error("Case not found");
	return -1;
}'
]

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testReturnCaseStatementMovesReturnIntoSwitch [

	| translation |
	
	translation := self translate: (TReturnNode expression: ((TCaseStmtNode
		newWithExpression: (TVariableNode named: 'someVariable')
		selectors: { #someBytecode }
		arguments: {}))).

	self assert: translation equals: 'switch (someVariable) {
	case 0:
	{
		return someBytecode();
	}
	default:
	error("Case not found");
	return -1;
}'
]

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testReturnIfTrue [

	| translation ast |
	ast := TReturnNode
		expression: (TSendNode
			receiver: (TVariableNode named: 'aBoolean')
			selector: #ifTrue:ifFalse:
			arguments: { 
				TStatementListNode statements: { TConstantNode value: 1 }.
				TStatementListNode statements: { TConstantNode value: 2 }.
			 } ).
	
	translation := self translate: ast.
		
	self assert: translation equals: 'return ((aBoolean)
	 ? 1
	 : 2)'
]

{ #category : #'tests-return' }
SlangBasicTranslationTest >> testReturnLeafInVoidMethod [

	| translation |
	
	generator currentMethod: (TMethod new returnType: 'void'; yourself).
	
	translation := self translate: (TReturnNode new
		setExpression: (TVariableNode new setName: 'var');
		yourself).
		
	self assert: translation equals: 'return;'
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
return;'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testReturnSwitchStatementMovesReturnIntoSwitch [

	| translation |
	translation := self translate:
		               (TReturnNode expression: (TSwitchStmtNode new
				                 expression: (TVariableNode named: 'x')
				                 cases: (TBraceCaseNode new
						                  caseLabels:
							                  { (TStatementListNode new statements:
									                   { (TConstantNode value: 0) }) };
						                  cases:
							                  { (TStatementListNode new statements:
									                   { (TAssignmentNode new
										                    setVariable:
											                    (TVariableNode named: 'foo')
										                    expression: (TConstantNode value: 10)) }) };
						                  yourself)
				                 otherwiseOrNil:
					                 (TStatementListNode new statements:
						                  { (TAssignmentNode new
							                   setVariable: (TVariableNode named: 'foo')
							                   expression: (TConstantNode value: 0)) }))).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		return (foo = 10);
	}
	default:
	{
		return (foo = 0);
	}
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testReturnSwitchStatementMovesReturnIntoSwitchWithNoDefaultStatement [

	| translation |
	translation := self translate:
		               (TReturnNode expression: (TSwitchStmtNode new
				                 expression: (TVariableNode named: 'x')
				                 cases: (TBraceCaseNode new
						                  caseLabels:
							                  { (TStatementListNode new statements:
									                   { (TConstantNode value: 0) }) };
						                  cases:
							                  { (TStatementListNode new statements:
									                   { (TAssignmentNode new
										                    setVariable:
											                    (TVariableNode named: 'foo')
										                    expression: (TConstantNode value: 10)) }) };
						                  yourself)
				                 otherwiseOrNil: nil)).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		return (foo = 10);
	}
	default:
	error("Case not found and no otherwise clause");
	return -1;
}'
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

	self assert: translation equals: '(a & 7) == 7'
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

	self assert: translation equals: '(x >= 0) && (x <= 100)'
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

	self assert: translation equals: '(a | 3) - 3'
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
SlangBasicTranslationTest >> testSendCCodeAsArgumentWithBlock [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode named: 'y')
		        expression: (TSendNode new
				         setSelector: #cCode:
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TStatementListNode new statements: { 
							          (TSendNode new
								           setSelector: #foo
								           receiver: (TConstantNode value: 1)
								           arguments: { (TConstantNode value: 2) }).
							          (TVariableNode named: 'x') }) }).
	translation := self translate: send.

	self assert: translation equals: 'y = (foo(1, 2), x)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCCodeAsArgumentWithString [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode named: 'y')
		        expression: (TSendNode new
				         setSelector: #cCode:
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TConstantNode value: 'foo(x)') }).
	translation := self translate: send.

	self assert: translation equals: 'y = foo(x)'
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
				        (TStatementListNode new statements: { 
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

	"self cppIf: #FEATURE ifTrue: [ a := false. c := 1 ] ifFalse: [ a := true. c := 0 ]"

	| translation send |
	send := TSendNode new
		        setSelector: #cppIf:ifTrue:ifFalse:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
				        (TConstantNode value: #FEATURE).
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueIfFalseAsArgument [

	"A C preprocessor condition can anywhere in code, even in an expression statement."

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode named: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:
				         receiver: (TSendNode new
						          setSelector: #<
						          receiver: (TVariableNode named: 'x')
						          arguments: { (TConstantNode value: 10) })
				         arguments: { (TSendNode new
						          setSelector: #cppIf:ifTrue:ifFalse:
						          receiver: (TVariableNode new setName: 'self')
						          arguments: { 
								          (TConstantNode value: #FEATURE).
								          (TConstantNode value: 2).
								          (TConstantNode value: 4) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x < 10)
	 ? 
#    if FEATURE
			2
#    else /* FEATURE */
			4
#    endif /* FEATURE */
			
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueIfFalseAsArgumentIndentationInBlock [

	"A C preprocessor condition can be anywhere in code, even in an expression statement."

	| translation send |
	send := TStatementListNode new statements: { (TAssignmentNode new
			         setVariable: (TVariableNode named: 'y')
			         expression: (TSendNode new
					          setSelector: #ifTrue:
					          receiver: (TSendNode new
							           setSelector: #<
							           receiver: (TVariableNode named: 'x')
							           arguments: { (TConstantNode value: 10) })
					          arguments: { (TSendNode new
							           setSelector: #cppIf:ifTrue:ifFalse:
							           receiver: (TVariableNode new setName: 'self')
							           arguments: { 
									           (TConstantNode value: #FEATURE).
									           (TConstantNode value: 2).
									           (TConstantNode value: 4) }) })) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	y = ((x < 10)
		 ? 
#      if FEATURE
				2
#      else /* FEATURE */
				4
#      endif /* FEATURE */
				
		 : 0);
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueIfFalseIndentationInBlock [

	"[self cppIf: #FEATURE ifTrue: [ a := false. c := 1 ] ifFalse: [ a := true. c := 0 ]]"

	| translation send |
	send := TStatementListNode new statements: { (TSendNode new
			         setSelector: #cppIf:ifTrue:ifFalse:
			         receiver: (TVariableNode new setName: 'self')
			         arguments: { 
					         (TConstantNode value: #FEATURE).
					         (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }).
					         (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: true)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 0)) }) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	
#  if FEATURE
	{
		a = 0;
		c = 1;
	}
#  else /* FEATURE */
	{
		a = 1;
		c = 0;
	}
#  endif /* FEATURE */
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueIndentationInNestedBlocks [

	"self cppIf: #FEATURE ifTrue: [ a := false. c := 1 ]"

	| translation send |
	send := TStatementListNode new statements:
		        { (TStatementListNode new statements: { (TSendNode new
				          setSelector: #cppIf:ifTrue:
				          receiver: (TVariableNode new setName: 'self')
				          arguments: { 
						          (TConstantNode value: #FEATURE).
						          (TStatementListNode new statements: { 
								           (TAssignmentNode new
									            setVariable: (TVariableNode new setName: 'a')
									            expression: (TConstantNode value: false)).
								           (TAssignmentNode new
									            setVariable: (TVariableNode new setName: 'c')
									            expression: (TConstantNode value: 1)) }) }) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	{
		
#    if FEATURE
		{
			a = 0;
			c = 1;
		}
#    endif /* FEATURE */
	}
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueWithSendIfTrueAsCondition [

	"self cppIf: (true ifTrue: [ false ] ifFalse: [ true ]) ifTrue: [ a := false. c := 1 ]"

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #cppIf:ifTrue:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
				        (TSendNode new
					         setSelector: #ifTrue:ifFalse:
					         receiver: (TConstantNode value: true)
					         arguments: { 
							         (TStatementListNode new statements:
								          { (TConstantNode value: false) }).
							         (TStatementListNode new statements:
								          { (TConstantNode value: true) }) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendCppIfIfTrueWithSingleExpressionDoesNotAddsSeparator [

	| translation send |
	send := TReturnNode expression: (TSendNode new
			         setSelector: #cppIf:ifTrue:
			         receiver: (TVariableNode new setName: 'self')
			         arguments: { 
					         (TConstantNode value: #FEATURE).
					         (TStatementListNode new statements:
						          { (TAssignmentNode new
							           setVariable: (TVariableNode new setName: 'a')
							           expression: (TConstantNode value: false)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'return 
#  if FEATURE
		(a = 0)
#  endif /* FEATURE */'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendCppIfIfTrueWithSingleStatementAddsSeparator [

	| translation send |
	send := TSendNode new
		        setSelector: #cppIf:ifTrue:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: { 
				        (TConstantNode value: #FEATURE).
				        (TStatementListNode new statements:
					         { (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '#if FEATURE
{
	a = 0;
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
		        arguments: { (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfFalseAsArgument [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((!x)
	 ? ((a = 0), (c = 1))
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseAsArgumentWithNonLeafReceiver [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:
				         receiver: (TSendNode new
						          setSelector: #&
						          receiver: (TVariableNode new setName: 'x')
						          arguments: { (TVariableNode new setName: 'y') })
				         arguments: { (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((!(x && y))
	 ? ((a = 0), (c = 1))
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseAsArgumentWithReceiverSendNot [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:
				         receiver: (TSendNode new
						          setSelector: #not
						          receiver: (TSendNode new
								           setSelector: #&
								           receiver: (TVariableNode new setName: 'x')
								           arguments: { (TVariableNode new setName: 'y') })
						          arguments: {  })
				         arguments: { (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x && y)
	 ? ((a = 0), (c = 1))
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseIfTrue [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements:
					         { (TAssignmentNode new
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

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfFalseIfTrueAsArgument [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:ifTrue:
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: true)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 0)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x)
	 ? ((a = 1), (c = 0))
	 : ((a = 0), (c = 1)))'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfFalseIfTrueAsArgumentCollapseBothArmsOfConditional [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:ifTrue:
				         receiver: (TSendNode new
						          setSelector: #foo
						          receiver: (TVariableNode new setName: 'x')
						          arguments: { (TConstantNode value: 7) })
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = (foo(x, 7), 
((a = 0), (c = 1)))'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfFalseIfTrueAsArgumentCollapseBothArmsOfConditionalWithNoSideEffect [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifFalse:ifTrue:
				         receiver: (TVariableNode named: 'x')
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((a = 0), (c = 1))'
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
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).

						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfFalseIfTrueCollapseBothArmsOfConditionalWithNoSideEffect [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).

						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfFalseIfTrueWithSingleStatementArguments [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:ifTrue:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        TVariableNode new setName: 'break'.
				        TVariableNode new setName: 'continue' }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) 
	continue;
 else 
	break;'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfFalseWithNonLeafReceiver [

	| translation send |
	send := TSendNode new
		        setSelector: #ifFalse:
		        receiver: (TSendNode new
				         setSelector: #&
				         receiver: (TVariableNode new setName: 'x')
				         arguments: { (TVariableNode new setName: 'y') })
		        arguments: { (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TConstantNode value: false)).
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'c')
						          expression: (TConstantNode value: 1)) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (!(x && y)) {
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
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfNilAsArgument [

	| translation send |
	generator generateDeadCode: true.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNil:
				         receiver: (TVariableNode named: 'z')
				         arguments: { TVariableNode named: 'x' }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((!z)
	 ? x
	 : z)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilAsArgumentWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNil:
				         receiver: (TConstantNode value: nil)
				         arguments: { TVariableNode named: 'x' }).
	translation := self translate: send.

	self assert: translation equals: 'y = x'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilIfNotNilAsArgument [

	| translation send |
	generator generateDeadCode: true.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNil:ifNotNil:
				         receiver: (TVariableNode named: 'z')
				         arguments: { 
						         (TVariableNode named: 'x').
						         (TVariableNode named: 'w') }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((z)
	 ? w
	 : x)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilIfNotNilAsArgumentWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNil:ifNotNil:
				         receiver: (TConstantNode value: nil)
				         arguments: { 
						         (TVariableNode named: 'x').
						         (TVariableNode named: 'w') }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = x'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNilWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfNotNilAsArgument [

	| translation send |
	generator generateDeadCode: true.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNotNil:
				         receiver: (TVariableNode named: 'z')
				         arguments: { TVariableNode named: 'x' }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((z)
	 ? x
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilAsArgumentWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNotNil:
				         receiver: (TConstantNode value: nil)
				         arguments: { TVariableNode named: 'x' }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = null'
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
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfNotNilIfNilAsArgument [

	| translation send |
	generator generateDeadCode: true.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNotNil:ifNil:
				         receiver: (TVariableNode named: 'z')
				         arguments: { 
						         (TVariableNode named: 'x').
						         (TVariableNode named: 'w') }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((z)
	 ? x
	 : w)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilIfNilAsArgumentWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNotNil:ifNil:
				         receiver: (TConstantNode value: nil)
				         arguments: { 
						         (TVariableNode named: 'x').
						         (TVariableNode named: 'w') }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = w'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilIfNilAsArgumentWithNonLeafReceiver [

	| translation send |
	generator generateDeadCode: true.
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifNotNil:ifNil:
				         receiver: (TSendNode new
						          setSelector: #foo
						          receiver: (TVariableNode named: 'x')
						          arguments: { (TConstantNode value: 1) })
				         arguments: { 
						         (TVariableNode named: 'x').
						         (TVariableNode named: 'w') }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((foo(x, 1))
	 ? x
	 : w)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilIfNilWithNilConstantReceiver [

	"nil ifNotNil: [ a:= true. c = 1 ] ifNil: [ b := false. c := 7 ]"

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNotNil:ifNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfNotNilWithArgument [

	| translation send |
	generator generateDeadCode: true.
	send := TSendNode new
		        setSelector: #ifNotNil:
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode new setName: 'self')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: { (TStatementListNode
				         parameters: #( c )
				         statements: { (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'a')
						          expression: (TVariableNode new setName: 'c')) }) }.
	generator currentMethod parseTree: (TStatementListNode statements: { send }).
	translation := self translate: generator currentMethod.

	self assert: translation trimBoth equals: '/* SlangBasicTranslationTest>>#setUp */
sqInt
setUp(void)
{
	sqInt c;

	if (foo(x)) {
		a = c;
	}
	return 0;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfNotNilWithNilConstantReceiver [

	| translation send |
	generator generateDeadCode: false.
	send := TSendNode new
		        setSelector: #ifNotNil:
		        receiver: (TConstantNode value: nil)
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
				         arguments: { (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x)
	 ? ((a = 0), (c = 1))
	 : 0)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueAsArgumentWithNonLeafReceiver [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:
				         receiver: (TSendNode new
						          setSelector: #&
						          receiver: (TVariableNode new setName: 'x')
						          arguments: { (TVariableNode new setName: 'y') })
				         arguments: { (TStatementListNode new statements: { 
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'a')
								           expression: (TConstantNode value: false)).
							          (TAssignmentNode new
								           setVariable: (TVariableNode new setName: 'c')
								           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x && y)
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
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements:
					         { (TAssignmentNode new
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
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: true)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 0)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((x)
	 ? ((a = 0), (c = 1))
	 : ((a = 1), (c = 0)))'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfTrueIfFalseAsArgumentCollapseBothArmsOfConditional [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:ifFalse:
				         receiver: (TSendNode new
						          setSelector: #foo
						          receiver: (TVariableNode new setName: 'x')
						          arguments: { (TConstantNode value: 7) })
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = (foo(x, 7), 
((a = 0), (c = 1)))'
]

{ #category : #'tests-send' }
SlangBasicTranslationTest >> testSendIfTrueIfFalseAsArgumentCollapseBothArmsOfConditionalWithNoSideEffect [

	| translation send |
	send := TAssignmentNode new
		        setVariable: (TVariableNode new setName: 'y')
		        expression: (TSendNode new
				         setSelector: #ifTrue:ifFalse:
				         receiver: (TVariableNode named: 'x')
				         arguments: { 
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }).
						         (TStatementListNode new statements: { 
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'a')
									           expression: (TConstantNode value: false)).
								          (TAssignmentNode new
									           setVariable: (TVariableNode new setName: 'c')
									           expression: (TConstantNode value: 1)) }) }).
	translation := self translate: send.

	self assert: translation trimBoth equals: 'y = ((a = 0), (c = 1))'
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
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).

						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfTrueIfFalseCollapseBothArmsOfConditionalWithNoSideEffect [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:ifFalse:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        (TStatementListNode new statements: { 
						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'a')
							          expression: (TConstantNode value: false)).

						         (TAssignmentNode new
							          setVariable: (TVariableNode new setName: 'c')
							          expression: (TConstantNode value: 1)) }).
				        (TStatementListNode new statements: { 
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
SlangBasicTranslationTest >> testSendIfTrueIfFalseWithSingleStatementArguments [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:ifFalse:
		        receiver: (TVariableNode new setName: 'x')
		        arguments: { 
				        TVariableNode new setName: 'break'.
				        TVariableNode new setName: 'continue' }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'if (x) 
	break;
 else 
	continue;'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIfTrueWithBlockReceiver [

	| translation send |
	send := TSendNode new
		        setSelector: #ifTrue:
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: (TVariableNode new setName: 'y')
						          expression: (TConstantNode value: false)).
					         (TVariableNode new setName: 'x') })
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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
		        arguments: { (TStatementListNode new statements: { 
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

	self assert: translation trimBoth equals: 'if (x) 
	break;'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIntegerObjectOfConstantValue [

	| translation send value |
	"constant values work as signed ints"
	value := 35.
	send := TSendNode new
					setSelector: #integerObjectOf:
					receiver: (TVariableNode named: 'self')
					arguments: { TConstantNode value: value }.
	translation := self translate: send.

	self assert: translation equals: '((((usqInt) ',value asString, ' ) << ', numSmallIntegerTagBits asString, ') | 1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIntegerObjectOfSignedValue [

	| translation send |
	generator currentMethod declarationAt: 'var' put: 'long'.
	send := TSendNode new
					setSelector: #integerObjectOf:
					receiver: (TVariableNode named: 'self')
					arguments: { TVariableNode named: 'var' }.
	translation := self translate: send.

	self assert: translation equals: '((((usqInt) var ) << ', numSmallIntegerTagBits asString, ') | 1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIntegerObjectOfUnsignedSmallValue [

	| translation send |
	generator currentMethod declarationAt: 'var' put: 'unsigned short'.
	send := TSendNode new
					setSelector: #integerObjectOf:
					receiver: (TVariableNode named: 'self')
					arguments: { TVariableNode named: 'var' }.
	translation := self translate: send.

	self assert: translation equals: '((((usqInt) var ) << ', numSmallIntegerTagBits asString, ') | 1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIntegerObjectOfUnsignedValue [

	| translation send |
	generator currentMethod declarationAt: 'var' put: 'unsigned long'.
	send := TSendNode new
					setSelector: #integerObjectOf:
					receiver: (TVariableNode named: 'self')
					arguments: { TVariableNode named: 'var' }.
	translation := self translate: send.

	self assert: translation equals: '((var << ', numSmallIntegerTagBits asString, ') | 1)'
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
SlangBasicTranslationTest >> testSendIsIntegerObjectWithLargeTag [

	| translation send value |
	"constant values work as signed ints"
	value := 35.
	send := TSendNode new
					setSelector: #isIntegerObject:
					receiver: (TVariableNode named: 'self')
					arguments: { TConstantNode value: value }.

	numSmallIntegerTagBits := 42.
	translation := self translate: send.

	self
		assert: translation
		equals: '((', 
			value asString, ' & ', 
			(1 << numSmallIntegerTagBits - 1) asString, ') == 1)'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendIsIntegerObjectWithSingleTag [

	| translation send value |
	"constant values work as signed ints"
	value := 35.
	send := TSendNode new
					setSelector: #isIntegerObject:
					receiver: (TVariableNode named: 'self')
					arguments: { TConstantNode value: value }.

	numSmallIntegerTagBits := 1.
	translation := self translate: send.

	self assert: translation equals: '(',value asString, ' & 1)'
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

	self assert: translation equals: '((sqInt) (((usqInt) -3 ) << 32) )'
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
	generator var: 'toto' declareC: 'VMCallbackContext toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '(toto.stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessFromPointer [

	| translation send |
	generator var: 'toto' declareC: 'VMCallbackContext *toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '(toto->stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithAdressOfVariableStructureReceiver [

	"Tests member access on an adress of a structure variable."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #addressOf:
				         receiver: (TVariableNode new setName: 'aVM')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((&x)->stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithArgumentAssignment [

	"When there is an argument in the send node, it adds an assignement."
	| translation send |
	generator var: 'toto' declareC: 'VMCallbackContext toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: { (TConstantNode value: 1) }.
	translation := self translate: send.

	self assert: translation equals: '(toto.stackp = 1)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithArrayAccessReceiver [

	"Tests member access on a structure contained in an array."

	| translation send |
	generator var: 'tab' declareC: 'VMCallbackContext tab[10]'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #at:
				         receiver: (TVariableNode new setName: 'tab')
				         arguments: { (TConstantNode value: 7) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((tab[7]).stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithArrayOfPointersToStructAccessReceiver [

	"Tests member access on an adress contained in an array of pointers to structures."

	| translation send |
	generator var: 'tab' declareC: 'VMCallbackContext *tab[10]'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #at:
				         receiver: (TVariableNode new setName: 'tab')
				         arguments: { (TConstantNode value: 7) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((tab[7])->stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithCCoercionReceiver [

	"Tests member access of a structure pointer cast."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
			                setSelector: #cCoerceSimple:to:
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { 
					                (TVariableNode new setName: 'var').
					                (TConstantNode value: 'VMCallbackContext *') })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((((VMCallbackContext *) var ))->stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithFunctionCallReceiver [

	"Tests member access on a call function that returns a structure"

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	generator addMethod: (TMethod new
			 selector: 'foo';
			 returnType: 'VMCallbackContext';
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode named: 'self')
				         arguments: {  })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((foo()).stackp)'
]

{ #category : #'tests-sends' }
SlangBasicTranslationTest >> testSendMemberAccessWithFunctionCallReceiverWithPointerToStructReturn [

	"Tests member access on a call function that returns a pointer to a structure."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	generator addMethod: (TMethod new
			 selector: 'foo';
			 returnType: 'VMCallbackContext *';
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode named: 'self')
				         arguments: {  })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((foo())->stackp)'
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
SlangBasicTranslationTest >> testSendMultiplicationWithConstantFoldingOverflowingToLong [

	| translation send |
	
	send := TSendNode new
					setSelector: #*
					receiver: (TConstantNode value: 1024)
					arguments: {
						TSendNode new
							setSelector: #*
							receiver: (TConstantNode value: 1024)
							arguments: {
								TSendNode new
									setSelector: #*
									receiver: (TConstantNode value: 1024)
									arguments: {(TConstantNode value: 1024)}}}.
	translation := self translate: send.

	self assert: translation equals: '0x10000000000LL'
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
SlangBasicTranslationTest >> testSendPerformWithAccessor [

	| translation send |
	generator currentMethod declarationAt: 'aPrimitiveDescriptor' put: #'PrimitiveDescriptor *'.
	send := TSendNode new
		        setSelector: #perform:
		        receiver: (TVariableNode named: 'objectRepresentation')
		        arguments: { TSendNode new
			        setSelector: #primitiveGenerator
			        receiver: (TVariableNode named: 'aPrimitiveDescriptor')
			        arguments: #() }.
	translation := self translate: send.

	self assert: translation equals: '(primitiveGenerator(aPrimitiveDescriptor))()'
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
SlangBasicTranslationTest >> testSendPerformWithWith6times [
	"self perform: #foo with: x with: y"
	| translation send |
	send := TSendNode new
		        setSelector: #perform:with:with:with:with:with:with:
		        receiver: (TVariableNode new setName: 'self')
		        arguments: {
						TConstantNode value: #foo.
						TVariableNode new setName: 'x'.
						TVariableNode new setName: 'y'.
						TVariableNode new setName: 'x'.
						TVariableNode new setName: 'y'.
						TVariableNode new setName: 'x'.
						TVariableNode new setName: 'y'.}.
	translation := self translate: send.

	self assert: translation equals: 'foo(x, y, x, y, x, y)'
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

	self assert: translation equals: '((sqInt) (pow(x, 2)) )'
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
		        receiver: (TStatementListNode new statements:
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
		        arguments: { (TStatementListNode new statements: { 
					         (TSendNode new
						          setSelector: #+
						          receiver: (TConstantNode value: 1)
						          arguments: { (TConstantNode value: 2) }).
					         (TSendNode new
						          setSelector: #=
						          receiver: (TVariableNode new setName: 'a')
						          arguments: { (TVariableNode new setName: 'b') }) }) }.
	translation := self translate: send.

	self assert: translation equals: '1 && ((1 + 2, a == b))'
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

	self assert: translation equals: '((sqLong) a ) >> 3'
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
SlangBasicTranslationTest >> testSendSubstractionWithConstantFoldingIfOverflow [

	| translation send |
	
	send := TSendNode new
					setSelector: #-
					receiver: (TConstantNode value: -1 <<31)
					arguments: {
						TSendNode new
							setSelector: #+
							receiver: (TConstantNode value: 1024)
							arguments: {
								TSendNode new
									setSelector: #+
									receiver: (TConstantNode value: 1024)
									arguments: {(TConstantNode value: 1024)}}}.
	translation := self translate: send.

	self assert: translation equals: '-2147486720LL'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSubstractionWithNoConstantFoldingIfNoOverflow [

	| translation send |
	
	send := TSendNode new
					setSelector: #-
					receiver: (TConstantNode value: -1024)
					arguments: {
						TSendNode new
							setSelector: #+
							receiver: (TConstantNode value: 1024)
							arguments: {
								TSendNode new
									setSelector: #+
									receiver: (TConstantNode value: 1024)
									arguments: {(TConstantNode value: 1024)}}}.
	translation := self translate: send.

	self assert: translation equals: '-1024 - (1024 + (1024 + 1024))'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSumWithConstantFoldingIfOverflow [

	| translation send |
	
	send := TSendNode new
					setSelector: #+
					receiver: (TConstantNode value: 1 <<31)
					arguments: {
						TSendNode new
							setSelector: #+
							receiver: (TConstantNode value: 1024)
							arguments: {
								TSendNode new
									setSelector: #+
									receiver: (TConstantNode value: 1024)
									arguments: {(TConstantNode value: 1024)}}}.
	translation := self translate: send.

	self assert: translation equals: '2147486720U'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendSumWithNoConstantFoldingIfNoOverflow [

	| translation send |
	
	send := TSendNode new
					setSelector: #+
					receiver: (TConstantNode value: 1024)
					arguments: {
						TSendNode new
							setSelector: #+
							receiver: (TConstantNode value: 1024)
							arguments: {
								TSendNode new
									setSelector: #+
									receiver: (TConstantNode value: 1024)
									arguments: {(TConstantNode value: 1024)}}}.
	translation := self translate: send.

	self assert: translation equals: '1024 + (1024 + (1024 + 1024))'
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
		        arguments: { (TStatementListNode new statements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	var -= 7;
}
{
	var -= 7;
}
{
	var -= 7;
}
{
	var -= 7;
}
{
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	sqInt i;

	for (i = 1; i <= 10; i += 2) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }).
						(TVariableNode new setName: 'toDoLimit') }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: '{
	sqInt i;

	for (i = 1, toDoLimit = foo(var); i <= toDoLimit; i += 2) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	sqInt i;

	for (i = 10; i >= 0; i += -2) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: '{
	sqInt i;

	for (i = 1 + (foo(1, 2)); i <= 10; i += 2) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: '{
	sqInt i;

	for (i = 1; i <= 10; i += 1 + (foo(1, 2))) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	sqInt i;

	for (i = 1; i <= 10; i++) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: '{
	sqInt i;

	for (i = 1; i < foo; i++) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self
		assert: translation trimBoth
		equals: '{
	sqInt i;

	for (i = 1; i <= (foo(var)); i++) {
		var -= 7;
	};
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
				        (TStatementListNode new
					         setArguments: #( i )
					         statements:
					         { (TAssignmentNode new
						          setVariable: variable
						          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	sqInt i;

	for (i = 1 + (foo(1, 2)); i <= 10; i++) {
		var -= 7;
	};
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
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments:
			        { (TStatementListNode new statements:
				         { (TAssignmentNode new
					          setVariable: (TVariableNode new setName: 'b')
					          expression: (TSendNode new
							           setSelector: #\\
							           receiver: (TVariableNode new setName: 'var')
							           arguments: { (TConstantNode value: 3) })) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (1) {
	var -= 7;
	if (var >= 21) 
		break;
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
			        (TStatementListNode new statements: { (TSendNode new
					          setSelector: #&
					          receiver: (TVariableNode new setName: 'a')
					          arguments: { (TVariableNode new setName: 'b') }) })
		        arguments: { (TStatementListNode new statements:
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
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	do{
		var -= 7;
	}while(!(var >= 21));
}'
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
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments:
			        { (TStatementListNode new statements:
				         { (TAssignmentNode new
					          setVariable: (TVariableNode new setName: 'b')
					          expression: (TSendNode new
							           setSelector: #\\
							           receiver: (TVariableNode new setName: 'var')
							           arguments: { (TConstantNode value: 3) })) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (1) {
	var -= 7;
	if (!(var >= 21)) 
		break;
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
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #&
						          receiver: (TVariableNode new setName: 'a')
						          arguments: { (TVariableNode new setName: 'b') }) })
		        arguments: { (TStatementListNode new statements:
				         { (TVariableNode new setName: 'nil') }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	do{
		var -= 7;
	}while(a && b);
}'
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
			        (TStatementListNode new statements: { (TSendNode new
					          setSelector: #&
					          receiver: (TVariableNode new setName: 'a')
					          arguments: { (TVariableNode new setName: 'b') }) })
		        arguments: { (TStatementListNode new statements:
				         { (TAssignmentNode new
					          setVariable: variable
					          expression: expression) }) }.
	translation := self translate: send.

	self assert: translation trimBoth equals: 'while (a && b) {
	var -= 7;
}'
]

{ #category : #'tests-builtins' }
SlangBasicTranslationTest >> testSendWhileTrueWithTemporary [

	"[ | temp | var := var - 7. var >= 21 ] whileTrue"

	| translation send variable expression |
	variable := TVariableNode new setName: 'var'.

	expression := TSendNode new
		              setSelector: #-
		              receiver: variable
		              arguments: { (TConstantNode value: 7) }.
	send := TSendNode new
		        setSelector: #whileTrue
		        receiver: (TStatementListNode
						declarations: { 'var' -> 'int var' } asDictionary
						statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	int var;

	do{
		var -= 7;
	}while(var >= 21);
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
		        receiver: (TStatementListNode new statements: { 
					         (TAssignmentNode new
						          setVariable: variable
						          expression: expression).
					         (TSendNode new
						          setSelector: #>=
						          receiver: (TVariableNode new setName: 'var')
						          arguments: { (TConstantNode value: 21) }) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation trimBoth equals: '{
	do{
		var -= 7;
	}while(var >= 21);
}'
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

{ #category : #'tests-case' }
SlangBasicTranslationTest >> testSwitchOnCurrentBytecodeAddsPreDispatchHook [

	| translation |
	
	translation := self translate: (TCaseStmtNode
		newWithExpression: (TVariableNode named: 'currentBytecode')
		selectors: { #someBytecode }
		arguments: {}).

	self assert: translation equals: 'bytecodeDispatchDebugHook();
VM_LABEL(bytecodeDispatch);
switch (currentBytecode) {
	case 0:
	{
		someBytecode();
	}
	break;
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatement [

	| translation |
	translation := self translate: (TSwitchStmtNode new
			                expression: (TVariableNode named: 'x')
			                cases: (TBraceCaseNode new
					                 caseLabels:
						                 { (TStatementListNode new statements:
								                  { (TConstantNode value: 0) }) };
					                 cases:
						                 { (TStatementListNode new statements:
								                  { (TAssignmentNode new
									                   setVariable: (TVariableNode named: 'foo')
									                   expression: (TConstantNode value: 10)) }) };
					                 yourself)
			                otherwiseOrNil:
				                (TStatementListNode new statements:
					                 { (TAssignmentNode new
						                  setVariable: (TVariableNode named: 'foo')
						                  expression: (TConstantNode value: 0)) })).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		foo = 10;
	}
	break;
	default:
	{
		foo = 0;
	}
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementAsArgument [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSwitchStmtNode new
					                 expression: (TVariableNode named: 'x')
					                 cases: (TBraceCaseNode new
							                  caseLabels: { 
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 0) }).
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 1) }) };
							                  cases: { 
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 10)) }).
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 11)) }) };
							                  yourself)
					                 otherwiseOrNil: nil)
			                arguments:
			                { (TStatementListNode new statements: {  }) }).

	self assert: translation trimBoth equals: 'if (((x == 0)
	 ? (foo = 10)
	 : ((x == 1)
		 ? (foo = 11)
		 : (error("Case not found and no otherwise clause"), 0)))) {
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementAsArgumentWithNastedCases [

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: (TSwitchStmtNode new
					                 expression: (TVariableNode named: 'x')
					                 cases: (TBraceCaseNode new
							                  caseLabels: { 
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 0) }).
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 1) }).
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 2) }).
									                  (TStatementListNode new statements:
											                   { (TConstantNode value: 3) }) };
							                  cases: { 
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 10)) }).
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 10)) }).
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 10)) }).
									                  (TStatementListNode new statements:
											                   { (TAssignmentNode new
												                    setVariable:
													                    (TVariableNode named: 'foo')
												                    expression: (TConstantNode value: 1)) }) };
							                  yourself)
					                 otherwiseOrNil: nil)
			                arguments:
			                { (TStatementListNode new statements: {  }) }).

	self assert: translation trimBoth equals: 'if (((x == 0)
	 ? (foo = 10)
	 : ((x == 1)
		 ? (foo = 10)
		 : ((x == 2)
			 ? (foo = 10)
			 : ((x == 3)
				 ? (foo = 1)
				 : (error("Case not found and no otherwise clause"), 0)))))) {
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementAsArgumentWithSwitchVariable [

	"A temporary variable can be used as switch variable, here the variable 'jinx'."

	| translation |
	translation := self translate: (TSendNode new
			                setSelector: #ifTrue:
			                receiver: ((TSwitchStmtNode new
					                  expression: (TVariableNode named: 'x')
					                  cases: (TBraceCaseNode new
							                   caseLabels: { 
									                   (TStatementListNode new statements:
											                    { (TConstantNode value: 0) }).
									                   (TStatementListNode new statements:
											                    { (TConstantNode value: 1) }) };
							                   cases: { 
									                   (TStatementListNode new statements:
											                    { (TAssignmentNode new
												                     setVariable:
													                     (TVariableNode named: 'foo')
												                     expression: (TConstantNode value: 10)) }).
									                   (TStatementListNode new statements:
											                    { (TAssignmentNode new
												                     setVariable:
													                     (TVariableNode named: 'foo')
												                     expression: (TConstantNode value: 11)) }) };
							                   yourself)
					                  otherwiseOrNil: nil) switchVariable: 'jinx')
			                arguments:
			                { (TStatementListNode new statements: {  }) }).

	self assert: translation trimBoth equals: 'if ((((jinx = x) == 0)
	 ? (foo = 10)
	 : ((jinx == 1)
		 ? (foo = 11)
		 : (error("Case not found and no otherwise clause"), 0)))) {
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementInAssignmentAddAssignmentToEndOfCases [

	| translation |
	translation := self translate: (TAssignmentNode new
			                setVariable: (TVariableNode named: 'toto')
			                expression: (TSwitchStmtNode new
					                 expression: (TVariableNode named: 'x')
					                 cases: (TBraceCaseNode new
							                  caseLabels:
								                  { (TStatementListNode new statements:
										                   { (TConstantNode value: 0) }) };
							                  cases:
								                  { (TStatementListNode new statements:
										                   { (TAssignmentNode new
											                    setVariable:
												                    (TVariableNode named: 'foo')
											                    expression: (TConstantNode value: 10)) }) };
							                  yourself)
					                 otherwiseOrNil:
						                 (TStatementListNode new statements:
							                  { (TAssignmentNode new
								                   setVariable: (TVariableNode named: 'foo')
								                   expression: (TConstantNode value: 0)) }))).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		toto = (foo = 10);
	}
	break;
	default:
	{
		toto = (foo = 0);
	}
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementInAssignmentAddAssignmentToEndOfCasesWithNoDefaultStatement [

	| translation |
	generator currentMethod declarationAt: 'toto' put: 'int toto'.
	translation := self translate: (TAssignmentNode new
			                setVariable: (TVariableNode named: 'toto')
			                expression: (TSwitchStmtNode new
					                 expression: (TVariableNode named: 'x')
					                 cases: (TBraceCaseNode new
							                  caseLabels:
								                  { (TStatementListNode new statements:
										                   { (TConstantNode value: 0) }) };
							                  cases:
								                  { (TStatementListNode new statements:
										                   { (TAssignmentNode new
											                    setVariable:
												                    (TVariableNode named: 'foo')
											                    expression: (TConstantNode value: 10)) }) };
							                  yourself)
					                 otherwiseOrNil: nil)).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		toto = (foo = 10);
	}
	break;
	default:
	error("Case not found and no otherwise clause");
	toto = -1;
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementInAssignmentAddAssignmentToEndOfCasesWithNoDefaultStatementAndAssignmentVariableIsPointer [

	| translation |
	generator currentMethod declarationAt: 'toto' put: 'int* toto'.
	translation := self translate: (TAssignmentNode new
			                setVariable: (TVariableNode named: 'toto')
			                expression: (TSwitchStmtNode new
					                 expression: (TVariableNode named: 'x')
					                 cases: (TBraceCaseNode new
							                  caseLabels:
								                  { (TStatementListNode new statements:
										                   { (TConstantNode value: 0) }) };
							                  cases:
								                  { (TStatementListNode new statements:
										                   { (TAssignmentNode new
											                    setVariable:
												                    (TVariableNode named: 'foo')
											                    expression: (TConstantNode value: 10)) }) };
							                  yourself)
					                 otherwiseOrNil: nil)).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		toto = (foo = 10);
	}
	break;
	default:
	error("Case not found and no otherwise clause");
	toto = ((int *) -1 );
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementWithNestedCase [

	| translation |
	translation := self translate: (TSwitchStmtNode new
			                expression: (TVariableNode named: 'x')
			                cases: (TBraceCaseNode new
					                 caseLabels: { 
							                 (TStatementListNode new statements:
									                  { (TConstantNode value: 0) }).
							                 (TStatementListNode new statements:
									                  { (TConstantNode value: 1) }) };
					                 cases: { 
							                 (TStatementListNode new statements:
									                  { (TAssignmentNode new
										                   setVariable: (TVariableNode named: 'foo')
										                   expression: (TConstantNode value: 10)) }).
							                 (TStatementListNode new statements:
									                  { (TAssignmentNode new
										                   setVariable: (TVariableNode named: 'foo')
										                   expression: (TConstantNode value: 10)) }) };
					                 yourself)
			                otherwiseOrNil:
			                (TStatementListNode new statements: {  })).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	case 1:
	{
		foo = 10;
	}
	break;
	default:
	{
	}
}'
]

{ #category : #'tests-switch' }
SlangBasicTranslationTest >> testSwitchStatementWithNoDefaultStatement [

	| translation |
	translation := self translate: (TSwitchStmtNode new
			                expression: (TVariableNode named: 'x')
			                cases: (TBraceCaseNode new
					                 caseLabels:
						                 { (TStatementListNode new statements:
								                  { (TConstantNode value: 0) }) };
					                 cases:
						                 { (TStatementListNode new statements:
								                  { (TAssignmentNode new
									                   setVariable: (TVariableNode named: 'foo')
									                   expression: (TConstantNode value: 10)) }) };
					                 yourself)
			                otherwiseOrNil: nil).

	self assert: translation trimBoth equals: 'switch (x) {
	case 0:
	{
		foo = 10;
	}
	break;
	default:
	error("Case not found and no otherwise clause");
}'
]

{ #category : #'tests-assignment' }
SlangBasicTranslationTest >> testTranslateBlockAssignmentWithManyStatement [

	| translation variable expression |
	" var :=  [ a := b . c := 1 ]."
	variable := TVariableNode new setName: 'var'.

	expression := TStatementListNode new statements: { 
			              (TAssignmentNode new
				               setVariable: (TVariableNode new setName: 'a')
				               expression: (TVariableNode new setName: 'b')).
			              (TAssignmentNode new
				               setVariable: (TVariableNode new setName: 'c')
				               expression: (TConstantNode value: 1)) }.

	translation := self translate:
		               (TAssignmentNode new
			                setVariable: variable
			                expression: expression).

	self assert: translation trimBoth equals: '{
	a = b;
	var = (c = 1);
}'
]

{ #category : #'tests-define' }
SlangBasicTranslationTest >> testTranslateDefineNode [

	| translation |
	translation :=  self translate: (TDefineNode named: 'PharoVM').

	self assert: translation equals: 'PharoVM'
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
		receiver: (TStatementListNode new
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
