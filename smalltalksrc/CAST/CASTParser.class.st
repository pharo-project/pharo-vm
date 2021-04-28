"
I am a C GLR Parser
"
Class {
	#name : #CASTParser,
	#superclass : #SmaCCGLRParser,
	#category : #'CAST-Parser'
}

{ #category : #'generated-accessing' }
CASTParser class >> cacheId [
	^'2017-12-13T09:32:38.213967+01:00'
]

{ #category : #generated }
CASTParser class >> definitionComment [
"<H>
	: [a-fA-F0-9]
	;
<IS>
	: [uUlL]	
	;
<D>
	: [0-9]
	;
<E>
	: [Ee][\+\-]?<D>+	
	;
<FS>
	: [fFlL]	
	;
<ELLIPSIS> 
	: \.\.\. 
	;
<comment>
	: (\/\* [^\*]* \*+ ([^\/\*] [^\*]* \*+)* \/)
	;
<LETTER>
	: [a-zA-Z_] 
	;
<DIGIT> 
	: [0-9] 
	;
<IDENTIFIER>
	: <LETTER> (<LETTER>|<DIGIT>)*
	;
<CONSTANT>
	: (0[xX]<H>+<IS>?) 
	| (<D>+<IS>?) 
	| (<D>+<E><FS>?) 
	| <D>*\.<D>+<E>?<FS>? 
	| (L? \' ( (\\ .) | ([^\\\""]) )+ \')
	;
<STRING_LITERAL>
	: L? \"" ( (\\ .) | ([^\\\""]) )* \""
	;
<LEFT_BLOCK>
	: \[ | (\< \:)
	;
<RIGHT_BLOCK>
	: \] | (\: \>)	
	;
<LEFT_BRACE>
	: \{ | (\< \%)
	;
<RIGHT_BRACE>
	: \} | (\% \>)
	;
<whitespace>
	: \s+
	;

%glr ;
%root Abstract;
%prefix CGLR;
%suffix Node;
%annotate_tokens;

translationUnit
	: external_declaration 'declaration' {{}}
	| translationUnit external_declaration 'declaration' {{}}
	;
primary_expression
	: identifier 'symbol' {{IdentifierExpression}}
	| <CONSTANT> {{Constant}}
	| <STRING_LITERAL> {{StringLiteral}}
	| ""("" expression 'expression' "")"" {{ParenthesizedExpression}}
	;
postfix_expression
	: primary_expression
	| postfix_expression 'array' <LEFT_BLOCK> expression 'index' <RIGHT_BLOCK> {{Array}}
	| postfix_expression 'f' ""("" "")"" {{Call}}
	| postfix_expression 'f' ""("" argument_expression_list "")"" {{Call}}
	| postfix_expression 'object' ""."" identifier 'member' {{Point}}
	| postfix_expression 'pointer' ""->"" identifier 'member' {{Arrow}}
	| postfix_expression 'object' ""++"" {{Increment}}
	| postfix_expression 'object' ""--"" {{Decrement}}
	;
argument_expression_list
	: assignment_expression 'argument'
	| argument_expression_list "","" assignment_expression 'argument'
	;
unary_expression
	: postfix_expression
	| ""++"" 'op' unary_expression 'expr' {{}}
	| ""--"" 'op' unary_expression 'expr' {{}}
	| unary_operator 'op' cast_expression 'expr' {{}}
	| ""sizeof"" unary_expression 'expr' {{}}
	| ""sizeof"" ""("" type_name 'type' "")"" 'expr' {{}}
	;
unary_operator
	: ""&""
	| ""*""
	| ""+""
	| ""-""
	| ""~""
	| ""!""
	;
cast_expression
	: unary_expression
	| ""("" type_name 'type' "")"" cast_expression 'expr' {{}}
	;
multiplicative_expression
	: cast_expression
	| multiplicative_expression 'left' ""*"" 'op' cast_expression 'right' {{Binary}}
	| multiplicative_expression 'left' ""/"" 'op' cast_expression 'right' {{Binary}}
	| multiplicative_expression 'left' ""%"" 'op' cast_expression 'right' {{Binary}}
	;
additive_expression
	: multiplicative_expression
	| additive_expression 'left' ""+"" 'op' multiplicative_expression 'right' {{Binary}}
	| additive_expression 'left' ""-"" 'op' multiplicative_expression 'right' {{Binary}}
	;
shift_expression
	: additive_expression
	| shift_expression 'left' ""<<"" 'op' additive_expression 'right' {{Binary}}
	| shift_expression 'left' "">>"" 'op' additive_expression 'right' {{Binary}}
	;
relational_expression
	: shift_expression
	| relational_expression 'left' ""<"" 'op' shift_expression 'right' {{Binary}}
	| relational_expression 'left' "">"" 'op' shift_expression 'right' {{Binary}}
	| relational_expression 'left' ""<="" 'op' shift_expression 'right' {{Binary}}
	| relational_expression 'left' "">="" 'op' shift_expression 'right' {{Binary}}
	;
equality_expression
	: relational_expression
	| equality_expression 'left' ""=="" 'op' relational_expression 'right' {{Binary}}
	| equality_expression 'left' ""!="" 'op' relational_expression 'right' {{Binary}}
	;
and_expression
	: equality_expression
	| and_expression 'left' ""&"" 'op' equality_expression 'right' {{Binary}}
	;
exclusive_or_expression
	: and_expression
	| exclusive_or_expression 'left' ""^"" 'op' and_expression 'right' {{Binary}}
	;
inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression 'left' ""|"" 'op' exclusive_or_expression 'right' {{Binary}}
	;
logical_and_expression
	: inclusive_or_expression
	| logical_and_expression 'left' ""&&"" 'op' inclusive_or_expression 'right' {{Binary}}
	;
logical_or_expression
	: logical_and_expression
	| logical_or_expression 'left' ""||"" 'op' logical_and_expression 'right' {{Binary}}
	;
conditional_expression
	: logical_or_expression
	| logical_or_expression 'condition' ""?"" expression 'then' "":"" conditional_expression 'else' {{Ternary}} 
	;
assignment_expression
	: conditional_expression
	| unary_expression 'lvalue' assignment_operator 'op' assignment_expression 'rvalue' {{Assignment}}
	;
assignment_operator
	: ""=""
	| ""*=""
	| ""/=""
	| ""%=""
	| ""+=""
	| ""-=""
	| ""<<=""
	| "">>=""
	| ""&=""
	| ""^=""
	| ""|=""
	;
expression
	: assignment_expression 'expression' {{}}
	| expression "","" assignment_expression 'expression' {{}}
	; 
constant_expression
	: conditional_expression
	;
declaration
	: declaration_specifiers "";"" {{}}
	| init_declaration "";"" {{}}
	;
init_declaration
	: declaration_specifiers init_declarator_list 
	;
declaration_specifiers
	: storage_class_specifier 'specifier'
	| storage_class_specifier 'specifier' declaration_specifiers
	| type_specifier 'specifier'
	| type_specifier 'specifier' declaration_specifiers
	| type_qualifier 'specifier'
	| type_qualifier 'specifier' declaration_specifiers
	;
init_declarator_list
	: init_declarator 'declarator'
	| init_declarator_list "","" init_declarator 'declarator'
	;
init_declarator
	: declarator 'declarator' {{}}
	| declarator 'declarator' ""="" initializer 'initializer' {{}}
	;
storage_class_specifier
	: ""typedef""
	| ""extern""
	| ""static""
	| ""auto""
	| ""register""
	;
type_specifier
	: ""void""
	| ""char""
	| ""short""
	| ""int""
	| ""long""
	| ""float""
	| ""double""
	| ""signed""
	| ""unsigned""
	| struct_or_union_specifier
	| enum_specifier
	| typename
	;
struct_or_union_specifier
	: struct_or_union 'prefix' identifier 'symbol' <LEFT_BRACE> struct_declaration_list <RIGHT_BRACE> {{}}
	| struct_or_union 'prefix' <LEFT_BRACE> struct_declaration_list <RIGHT_BRACE> {{}}
	| struct_or_union 'prefix' identifier 'symbol' {{}}
	;
struct_or_union
	: ""struct""
	| ""union""
	;
struct_declaration_list
	: struct_declaration 'member'
	| struct_declaration_list struct_declaration 'member'
	;
struct_declaration
	: specifier_qualifier_list struct_declarator_list "";"" {{}}
	;
specifier_qualifier_list
	: type_specifier 'specifier' specifier_qualifier_list
	| type_specifier 'specifier'
	| type_qualifier 'qualifier' specifier_qualifier_list
	| type_qualifier 'qualifier'
	;
struct_declarator_list
	: struct_declarator 'declarator'
	| struct_declarator_list "","" struct_declarator 'declarator'
	;
struct_declarator
	: declarator 'declarator' {{}}
	| "":"" constant_expression 'size' {{}}
	| declarator 'declarator' "":"" constant_expression 'size' {{}}
	;
enum_specifier
	: ""enum"" <LEFT_BRACE> enumerator_list <RIGHT_BRACE> {{Enum}}
	| ""enum"" identifier 'identifier' <LEFT_BRACE> enumerator_list <RIGHT_BRACE> {{Enum}} 
	| ""enum"" identifier 'identifier' {{Enum}}
	;
enumerator_list
	: enumerator 'enumerator'
	| enumerator_list "","" enumerator 'enumerator'
	;
enumerator
	: identifier 'symbol' {{}}
	| identifier 'symbol' ""="" constant_expression 'expr' {{}}
	;
type_qualifier
	: ""const""
	| ""volatile""
	;
declarator
	: pointer direct_declarator 'direct' {{}}
	| direct_declarator 'direct' {{}}
	;
direct_declarator
	: identifier 'identifier'
	| typename 'identifier'
	| ""("" declarator 'declarator' "")"" {{FunctionPointerDeclarator}}
	| direct_declarator 'declarator' <LEFT_BLOCK> constant_expression 'size' <RIGHT_BLOCK> {{ArrayDeclarator}}
	| direct_declarator 'declarator' <LEFT_BLOCK> <RIGHT_BLOCK> {{ArrayDeclarator}}
	| direct_declarator 'declarator' ""("" parameter_type_list "")"" {{FunctionDeclarator}}
	| direct_declarator 'declarator' ""("" identifier_list "")"" {{FunctionDeclarator}}
	| direct_declarator 'declarator' ""("" "")"" {{FunctionDeclarator}}
	;
pointer
	: ""*"" 'pointer'
	| ""*"" 'pointer' type_qualifier_list
	| ""*"" 'pointer' pointer
	| ""*"" 'pointer' type_qualifier_list pointer
	;
type_qualifier_list
	: type_qualifier 'qualifier'
	| type_qualifier_list type_qualifier 'qualifier'
	;
parameter_type_list
	: parameter_list
	| parameter_list "","" <ELLIPSIS> 'ellipsis'
	;
parameter_list
	: parameter_declaration 'parameter'
	| parameter_list "","" parameter_declaration 'parameter'
	;
parameter_declaration
	: declaration_specifiers 'specifier' declarator 'declarator' {{}}
	| declaration_specifiers 'specifier' abstract_declarator 'declarator' {{}}
	| declaration_specifiers 'specifier' {{}}
	;
identifier_list
	: identifier 'identifier'
	| typename 'identifier'
	| identifier_list "","" identifier 'identifier'
	| identifier_list "","" typename 'identifier'
	;
type_name
	: specifier_qualifier_list {{}}
	| specifier_qualifier_list abstract_declarator 'abstract' {{}}
	;
abstract_declarator
	: pointer {{}}
	| direct_abstract_declarator 'direct' {{}}
	| pointer direct_abstract_declarator 'direct' {{}}
	;
direct_abstract_declarator
	: ""("" abstract_declarator 'declarator' "")"" {{FunctionPointerDeclarator}}
	| <LEFT_BLOCK> <RIGHT_BLOCK> {{ArrayDeclarator}}
	| <LEFT_BLOCK> constant_expression 'size' <RIGHT_BLOCK> {{ArrayDeclarator}}
	| direct_abstract_declarator 'declarator' <LEFT_BLOCK> <RIGHT_BLOCK> {{ArrayDeclarator}}
	| direct_abstract_declarator 'declarator' <LEFT_BLOCK> constant_expression 'size' <RIGHT_BLOCK> {{ArrayDeclarator}}
	| ""("" "")"" {{FunctionDeclarator}}
	| ""("" parameter_type_list "")"" {{FunctionDeclarator}}
	| direct_abstract_declarator 'declarator' ""("" "")"" {{FunctionDeclarator}}
	| direct_abstract_declarator 'declarator' ""("" parameter_type_list "")"" {{FunctionDeclarator}}
	;
initializer
	: assignment_expression
	| <LEFT_BRACE> initializer_list <RIGHT_BRACE> {{}}
	| <LEFT_BRACE> initializer_list "","" <RIGHT_BRACE> {{}}
	;
initializer_list
	: initializer 'initializer'
	| initializer_list "","" initializer 'initializer'
	;
statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;
labeled_statement
	: identifier 'label' "":"" statement 'statement' {{}} 
	| ""case"" constant_expression 'case' "":"" statement 'statement' {{}}
	| ""default"" 'case' "":"" statement 'statement' {{}}
	;
compound_statement
	: <LEFT_BRACE> <RIGHT_BRACE> {{}}
	| <LEFT_BRACE> statement_list <RIGHT_BRACE> {{}}
	| <LEFT_BRACE> declaration_list <RIGHT_BRACE> {{}}
	| <LEFT_BRACE> declaration_list statement_list <RIGHT_BRACE> {{}}
	;
declaration_list
	: declaration 'declaration'
	| declaration_list declaration 'declaration'
	;
statement_list
	: statement 'statement'
	| statement_list statement 'statement'
	;
expression_statement
	: "";"" {{}}
	| expression 'expression' "";"" {{}}
	;
selection_statement
	: ""if"" ""("" expression 'if' "")"" statement 'then' {{}}
	| ""if"" ""("" expression 'if' "")"" statement 'then' ""else"" statement 'else' {{}}
	| ""switch"" ""("" expression 'if' "")"" statement 'statement' {{SwitchStatement}}
	;
iteration_statement
	: ""while"" ""("" expression 'while' "")"" statement 'statement' {{WhileStatement}}
	| ""do"" statement 'statement' ""while"" ""("" expression 'while' "")"" "";"" {{DoStatement}}
	| ""for"" ""("" expression_statement 'init' expression_statement 'until' "")"" statement 'statement' {{ForStatement}} 
	| ""for"" ""("" expression_statement 'init' expression_statement 'until' expression 'step' "")"" statement 'statement' {{ForStatement}}
	;
jump_statement
	: ""goto"" identifier 'label' "";"" {{GotoStatement}}
	| ""continue"" "";"" {{ContinueStatement}}
	| ""break"" "";"" {{BreakStatement}}
	| ""return"" "";"" {{ReturnStatement}}
	| ""return"" expression 'expr' "";"" {{ReturnStatement}}
	;
external_declaration
	: function_definition
	| declaration
	;
function_definition
	: declaration_specifiers 'specifiers' declarator 'declarator' declaration_list 'arguments' compound_statement 'body' {{}}
	| declaration_specifiers 'specifiers' declarator 'declarator' compound_statement 'body' {{}}
	| declarator 'declarator' declaration_list 'arguments' compound_statement 'body' {{}}
	| declarator 'declarator' compound_statement 'body' {{}}
	;
identifier: <IDENTIFIER> 'symbol' {{}};
typename: <IDENTIFIER> 'symbol' {{}};"
]

{ #category : #'generated-accessing' }
CASTParser class >> scannerClass [
	^CASTScanner
]

{ #category : #generated }
CASTParser class >> startingStateFortranslationUnit [
	^ 1
]

{ #category : #generated }
CASTParser >> ambiguousTransitions [
^#(
#[ 0 26 0 30] 
#[ 0 38 0 217] 
#[ 0 18 0 42] 
#[ 0 217 0 242] 
#[ 0 217 0 246] 
#[ 0 18 1 6] 
#[ 2 94 5 125]
	).
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForabstract_declarator1: nodes [
	| result |
	result := CGLRAbstractDeclaratorNode new.
	result addTokens: ((nodes at: 1) at: 1) to: result pointers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForabstract_declarator2: nodes [
	| result |
	result := CGLRAbstractDeclaratorNode new.
	result direct: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForabstract_declarator3: nodes [
	| result |
	result := CGLRAbstractDeclaratorNode new.
	result addTokens: ((nodes at: 1) at: 1) to: result pointers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	result direct: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForassignment_expression2: nodes [
	| result |
	result := CAssignmentNode new.
	result lvalue: (nodes at: 1).
	result operator: (nodes at: 2) value.
	result rvalue: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForcast_expression2: nodes [
	| result |
	result := CCastExpressionNode new.
	result type: (nodes at: 2).
	result expression: (nodes at: 4).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForcompound_statement1: nodes [
	| result |
	result := CCompoundStatementNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForcompound_statement2: nodes [
	| result |
	result := CCompoundStatementNode new.
	result addNodes: (nodes at: 2) to: result statements.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForcompound_statement3: nodes [
	| result |
	result := CCompoundStatementNode new.
	result addNodes: (nodes at: 2) to: result declarations.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForcompound_statement4: nodes [
	| result |
	result := CCompoundStatementNode new.
	result addNodes: (nodes at: 2) to: result declarations.
	result addNodes: (nodes at: 3) to: result statements.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForconditional_expression2: nodes [
	| result |
	result := CTernaryNode new.
	result condition: (nodes at: 1).
	result then: (nodes at: 3).
	result else: (nodes at: 5).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclaration1: nodes [
	| result |
	result := CDeclarationNode new.
	result addObjects: (nodes at: 1) to: result specifiers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclaration2: nodes [
	| result |
	result := CDeclarationNode new.
	result addObjects: ((nodes at: 1) at: 1) to: result specifiers.
	result addNodes: ((nodes at: 1) at: 2) to: result declarators.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclaration_specifiers1: nodes [
	| result |
	result := OrderedCollection new: 2.
	self add: (nodes at: 1) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclaration_specifiers2: nodes [
	| result |
	result := nodes at: 2.
	self addFirst: (nodes at: 1) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclarator1: nodes [
	| result |
	result := CPointerDeclaratorNode new.
	result addTokens: ((nodes at: 1) at: 1) to: result pointers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	result declarator: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordeclarator2: nodes [

	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_abstract_declarator2: nodes [
	| result |
	result := CArrayDeclaratorNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_abstract_declarator3: nodes [
	| result |
	result := CArrayDeclaratorNode new.
	result size: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_abstract_declarator6: nodes [
	| result |
	result := CFunctionDeclaratorNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_abstract_declarator7: nodes [
	| result |
	result := CFunctionDeclaratorNode new.
	result addNodes: ((nodes at: 2) at: 1) to: result parameters.
	result ellipsis: ((nodes at: 2) at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator3: nodes [
	
	^ nodes at: 2
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator4: nodes [
	| result |
	result := CArrayDeclaratorNode new.
	result declarator: (nodes at: 1).
	result size: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator5: nodes [
	| result |
	result := CArrayDeclaratorNode new.
	result declarator: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator6: nodes [
	| result |
	result := CFunctionDeclaratorNode new.
	result declarator: (nodes at: 1).
	result addNodes: ((nodes at: 3) at: 1) to: result parameters.
	result ellipsis: ((nodes at: 3) at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator7: nodes [
	| result |
	result := CFunctionDeclaratorNode new.
	result declarator: (nodes at: 1).
	result addNodes: ((nodes at: 3) at: 1) to: result identifiers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFordirect_declarator8: nodes [
	
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForenum_specifier1: nodes [
	| result |
	result := CGLREnumNode new.
	result addNodes: ((nodes at: 3) at: 1) to: result enumerators.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForenum_specifier2: nodes [
	| result |
	result := CGLREnumNode new.
	result identifier: (nodes at: 2).
	result addNodes: ((nodes at: 4) at: 1) to: result enumerators.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForenum_specifier3: nodes [
	| result |
	result := CGLREnumNode new.
	result identifier: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForenumerator1: nodes [
	| result |
	result := CGLREnumeratorNode new.
	result symbol: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForenumerator2: nodes [
	| result |
	result := CGLREnumeratorNode new.
	result symbol: (nodes at: 1).
	result expression: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForexpression1: nodes [

	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForexpression2: nodes [
	
	^ (nodes at: 1), (nodes at: 3)
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForexpression_statement1: nodes [

	^ CEmptyStatementNode new
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForexpression_statement2: nodes [

	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForfunction_definition1: nodes [
	| result |
	result := CGLRFunctionDefinitionNode new.
	result addObjects: (nodes at: 1) to: result specifierses.
	result declarator: (nodes at: 2).
	result addNodes: (nodes at: 3) to: result argumentses.
	result body: (nodes at: 4).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForfunction_definition2: nodes [
	| result |
	result := CGLRFunctionDefinitionNode new.
	result addObjects: (nodes at: 1) to: result specifierses.
	result declarator: (nodes at: 2).
	result body: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForfunction_definition3: nodes [
	| result |
	result := CGLRFunctionDefinitionNode new.
	result declarator: (nodes at: 1).
	result addNodes: (nodes at: 2) to: result argumentses.
	result body: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForfunction_definition4: nodes [
	| result |
	result := CGLRFunctionDefinitionNode new.
	result declarator: (nodes at: 1).
	result body: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForidentifier1: nodes [
	| result |
	result := CIdentifierNode new.
	result name: (nodes at: 1) value.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinit_declaration1: nodes [
	| result |
	result := Array new: 3.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	result at: 3 put: (OrderedCollection new: 2).
	self addAll: (nodes at: 1) to: (result at: 1).
	self addAll: ((nodes at: 2) at: 1) to: (result at: 2).
	self addAll: ((nodes at: 2) at: 2) to: (result at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinit_declarator1: nodes [
	
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinit_declarator2: nodes [
	| result |
	result := CInitDeclaratorNode new.
	result declarator: (nodes at: 1).
	result initializer: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinit_declarator_list2: nodes [
	| result |
	result := nodes at: 1.
	self add: (nodes at: 2) to: (result at: 2).
	self add: (nodes at: 3) to: (result at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinitializer2: nodes [
	| result |
	result := CGLRInitializerNode new.
	result addNodes: ((nodes at: 2) at: 1) to: result initializers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForinitializer3: nodes [
	| result |
	result := CGLRInitializerNode new.
	result addNodes: ((nodes at: 2) at: 1) to: result initializers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForiteration_statement1: nodes [
	| result |
	result := CWhileStatementNode new.
	result while: (nodes at: 3).
	result statement: (nodes at: 5).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForiteration_statement2: nodes [
	| result |
	result := CDoStatementNode new.
	result statement: (nodes at: 2).
	result while: (nodes at: 5).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForiteration_statement3: nodes [
	| result |
	result := CGLRForStatementNode new.
	result init: (nodes at: 3).
	result until: (nodes at: 4).
	result statement: (nodes at: 6).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForiteration_statement4: nodes [
	| result |
	result := CGLRForStatementNode new.
	result init: (nodes at: 3).
	result until: (nodes at: 4).
	result step: (nodes at: 5).
	result statement: (nodes at: 7).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForjump_statement1: nodes [
	| result |
	result := CGotoStatementNode new.
	result label: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForjump_statement2: nodes [
	| result |
	result := CGLRContinueStatementNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForjump_statement3: nodes [
	| result |
	result := CGLRBreakStatementNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForjump_statement4: nodes [
	| result |
	result := CReturnStatementNode new.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForjump_statement5: nodes [
	| result |
	result := CReturnStatementNode new.
	result expression: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForlabeled_statement1: nodes [
	| result |
	result := CGLRLabeledStatementNode new.
	result label: (nodes at: 1).
	result statement: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForlabeled_statement2: nodes [
	| result |
	result := CGLRLabeledStatementNode new.
	result case: (nodes at: 2).
	result statement: (nodes at: 4).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForlabeled_statement3: nodes [
	| result |
	result := CGLRLabeledStatementNode new.
	result case: (nodes at: 1).
	result statement: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFormultiplicative_expression3: nodes [
	| result |
	result := CBinaryOperatorNode new.
	result left: (nodes at: 1).
	result operator: (nodes at: 2) value.
	result right: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForparameter_declaration1: nodes [
	| result |
	result := CGLRParameterDeclarationNode new.
	result addObjects: (nodes at: 1) to: result specifiers.
	result declarator: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForparameter_declaration3: nodes [
	| result |
	result := CGLRParameterDeclarationNode new.
	result addObjects: (nodes at: 1) to: result specifiers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForparameter_type_list1: nodes [
	| result |
	result := Array new: 3.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self addAll: ((nodes at: 1) at: 1) to: (result at: 1).
	self addAll: ((nodes at: 1) at: 2) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForparameter_type_list2: nodes [
	| result |
	result := Array new: 3.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self addAll: ((nodes at: 1) at: 1) to: (result at: 1).
	self addAll: ((nodes at: 1) at: 2) to: (result at: 2).
	self add: (nodes at: 2) to: (result at: 2).
	result at: 3 put: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpointer1: nodes [
	| result |
	result := Array new: 2.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self add: (nodes at: 1) to: (result at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpointer2: nodes [
	| result |
	result := Array new: 2.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self add: (nodes at: 1) to: (result at: 1).
	self addAll: (nodes at: 2) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpointer3: nodes [
	| result |
	result := nodes at: 2.
	self addFirst: (nodes at: 1) to: (result at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpointer4: nodes [
	| result |
	result := nodes at: 3.
	self addFirst: (nodes at: 1) to: (result at: 1).
	self addAllFirst: (nodes at: 2) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression2: nodes [
	| result |
	result := CArrayAccessNode new.
	result array: (nodes at: 1).
	result index: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression3: nodes [
	| result |
	result := CCallNode new.
	result identifier: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression4: nodes [
	| result |
	result := CCallNode new.
	result identifier: (nodes at: 1).
	result addNodes: ((nodes at: 3) at: 1) to: result arguments.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression5: nodes [
	| result |
	result := CMemberAccessNode new.
	result object: (nodes at: 1).
	result member: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression6: nodes [
	| result |
	result := CStructurePointerAccessNode new.
	result structurePointer: (nodes at: 1).
	result member: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression7: nodes [
	| result |
	result := CGLRIncrementNode new.
	result object: (nodes at: 1).
	result plusPlusToken: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForpostfix_expression8: nodes [
	| result |
	result := CGLRDecrementNode new.
	result object: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForprimary_expression1: nodes [

	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForprimary_expression2: nodes [
	| result |
	result := CConstantNode new.
	result value: (nodes at: 1) value.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForprimary_expression3: nodes [
	| result |
	result := CGLRStringLiteralNode new.
	result value: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForprimary_expression4: nodes [

	^ nodes at: 2
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForselection_statement1: nodes [
	| result |
	result := CIfStatementNode new.
	result if: (nodes at: 3).
	result then: (nodes at: 5).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForselection_statement2: nodes [
	| result |
	result := CIfStatementNode new.
	result if: (nodes at: 3).
	result then: (nodes at: 5).
	result else: (nodes at: 7).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForselection_statement3: nodes [
	| result |
	result := CGLRSwitchStatementNode new.
	result if: (nodes at: 3).
	result statement: (nodes at: 5).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForspecifier_qualifier_list3: nodes [
	| result |
	result := nodes at: 2.
	self addFirst: (nodes at: 1) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForspecifier_qualifier_list4: nodes [
	| result |
	result := Array new: 2.
	result at: 1 put: (OrderedCollection new: 2).
	result at: 2 put: (OrderedCollection new: 2).
	self add: (nodes at: 1) to: (result at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_declaration1: nodes [
	| result |
	result := CGLRStructDeclarationNode new.
	result addObjects: ((nodes at: 1) at: 1) to: result specifiers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	result addNodes: ((nodes at: 2) at: 1) to: result declarators.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_declarator1: nodes [
	| result |
	result := CGLRStructDeclaratorNode new.
	result declarator: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_declarator2: nodes [
	| result |
	result := CGLRStructDeclaratorNode new.
	result size: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_declarator3: nodes [
	| result |
	result := CGLRStructDeclaratorNode new.
	result declarator: (nodes at: 1).
	result size: (nodes at: 3).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_or_union_specifier1: nodes [
	| result |
	result := CGLRStructOrUnionSpecifierNode new.
	result prefix: (nodes at: 1).
	result symbol: (nodes at: 2).
	result addNodes: (nodes at: 4) to: result members.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_or_union_specifier2: nodes [
	| result |
	result := CGLRStructOrUnionSpecifierNode new.
	result prefix: (nodes at: 1).
	result addNodes: (nodes at: 3) to: result members.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForstruct_or_union_specifier3: nodes [
	| result |
	result := CGLRStructOrUnionSpecifierNode new.
	result prefix: (nodes at: 1).
	result symbol: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortranslationUnit1: nodes [
	| result |
	result := CGLRTranslationUnitNode new.
	result addNode: (nodes at: 1) to: result declarations.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortranslationUnit2: nodes [
	| result |
	result := nodes at: 1.
	result addNode: (nodes at: 2) to: result declarations.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortype_name1: nodes [
	| result |
	result := CGLRTypeNode new.
	result addObjects: ((nodes at: 1) at: 1) to: result specifiers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortype_name2: nodes [
	| result |
	result := CGLRTypeNode new.
	result addObjects: ((nodes at: 1) at: 1) to: result specifiers.
	result addTokens: ((nodes at: 1) at: 2) to: result qualifiers.
	result abstract: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortype_qualifier1: nodes [
	^ nodes at: 1
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortype_qualifier_list2: nodes [
	| result |
	result := nodes at: 1.
	self add: (nodes at: 2) to: result.
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionFortypename1: nodes [
	| result |
	result := CTypeNameNode new.
	result symbol: (nodes at: 1).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForunary_expression3: nodes [
	| result |
	result := CUnaryOperatorNode new.
	result operator: (nodes at: 1) value.
	result expression: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForunary_expression5: nodes [
	| result |
	result := CSizeofNode new.
	result child: (nodes at: 2).
	^ result
]

{ #category : #'generated-reduction actions' }
CASTParser >> reduceActionForunary_expression6: nodes [
	| result |
	result := CSizeofNode new.
	result child: (nodes at: 3).
	^ result
]

{ #category : #generated }
CASTParser >> reduceTable [
^#(
	#(127 1 #reduceActionForpointer1:) 
	#(110 1 #reduceActionFortype_qualifier1:) 
	#(117 1 #reduceActionFortype_qualifier1:) 
	#(109 1 #reduceActionFortype_qualifier1:) 
	#(108 1 #reduceActionFortype_qualifier1:) 
	#(120 1 #reduceActionForidentifier1:) 
	#(116 1 #reduceActionFortypename1:) 
	#(151 1 #reduceActionFortype_qualifier1:) 
	#(104 1 #reduceActionFordeclaration_specifiers1:) 
	#(128 1 #reduceActionFortype_qualifier1:) 
	#(112 1 #reduceActionFordeclarator2:) 
	#(148 1 #reduceActionFortranslationUnit1:) 
	#(131 1 #reduceActionFordeclaration_specifiers1:) 
	#(127 2 #reduceActionForpointer3:) 
	#(127 2 #reduceActionForpointer2:) 
	#(115 2 #reduceActionForenum_specifier3:) 
	#(106 2 #reduceActionFordeclaration1:) 
	#(105 2 #reduceActionForinit_declaration1:) 
	#(107 1 #reduceActionForpointer1:) 
	#(111 1 #reduceActionForinit_declarator1:) 
	#(106 2 #reduceActionFordeclaration2:) 
	#(104 2 #reduceActionFordeclaration_specifiers2:) 
	#(146 1 #reduceActionFordeclaration_specifiers1:) 
	#(147 2 #reduceActionForfunction_definition4:) 
	#(114 2 #reduceActionForstruct_or_union_specifier3:) 
	#(112 2 #reduceActionFordeclarator1:) 
	#(148 2 #reduceActionFortranslationUnit2:) 
	#(128 3 #reduceActionFordirect_declarator3:) 
	#(131 2 #reduceActionFortype_qualifier_list2:) 
	#(127 3 #reduceActionForpointer4:) 
	#(126 1 #reduceActionForenumerator1:) 
	#(125 1 #reduceActionForpointer1:) 
	#(147 3 #reduceActionForfunction_definition2:) 
	#(88 1 #reduceActionFortype_qualifier1:) 
	#(140 1 #reduceActionForexpression_statement1:) 
	#(84 1 #reduceActionForprimary_expression2:) 
	#(84 1 #reduceActionForprimary_expression3:) 
	#(139 2 #reduceActionForcompound_statement1:) 
	#(133 1 #reduceActionFortype_qualifier1:) 
	#(118 1 #reduceActionForexpression1:) 
	#(89 1 #reduceActionFortype_qualifier1:) 
	#(91 1 #reduceActionFortype_qualifier1:) 
	#(92 1 #reduceActionFortype_qualifier1:) 
	#(93 1 #reduceActionFortype_qualifier1:) 
	#(94 1 #reduceActionFortype_qualifier1:) 
	#(95 1 #reduceActionFortype_qualifier1:) 
	#(96 1 #reduceActionFortype_qualifier1:) 
	#(97 1 #reduceActionFortype_qualifier1:) 
	#(98 1 #reduceActionFortype_qualifier1:) 
	#(99 1 #reduceActionFortype_qualifier1:) 
	#(100 1 #reduceActionFortype_qualifier1:) 
	#(101 1 #reduceActionFortype_qualifier1:) 
	#(86 1 #reduceActionFortype_qualifier1:) 
	#(84 1 #reduceActionForprimary_expression1:) 
	#(87 1 #reduceActionFortype_qualifier1:) 
	#(144 1 #reduceActionFortype_qualifier1:) 
	#(145 1 #reduceActionFordeclaration_specifiers1:) 
	#(146 2 #reduceActionFortype_qualifier_list2:) 
	#(147 3 #reduceActionForfunction_definition3:) 
	#(122 1 #reduceActionForpointer1:) 
	#(122 1 #reduceActionForspecifier_qualifier_list4:) 
	#(119 1 #reduceActionFordeclaration_specifiers1:) 
	#(128 3 #reduceActionFordirect_declarator8:) 
	#(134 1 #reduceActionForparameter_declaration3:) 
	#(130 1 #reduceActionForpointer1:) 
	#(129 1 #reduceActionForparameter_type_list1:) 
	#(132 1 #reduceActionForpointer1:) 
	#(128 3 #reduceActionFordirect_declarator5:) 
	#(103 1 #reduceActionFortype_qualifier1:) 
	#(115 4 #reduceActionForenum_specifier1:) 
	#(107 3 #reduceActionForinit_declarator_list2:) 
	#(113 1 #reduceActionFortype_qualifier1:) 
	#(111 3 #reduceActionForinit_declarator2:) 
	#(147 4 #reduceActionForfunction_definition1:) 
	#(143 2 #reduceActionForjump_statement4:) 
	#(87 2 #reduceActionForunary_expression3:) 
	#(87 2 #reduceActionForunary_expression5:) 
	#(90 1 #reduceActionFortype_name1:) 
	#(143 2 #reduceActionForjump_statement2:) 
	#(143 2 #reduceActionForjump_statement3:) 
	#(102 1 #reduceActionFortype_qualifier1:) 
	#(140 2 #reduceActionForexpression_statement2:) 
	#(133 2 #reduceActionForpostfix_expression8:) 
	#(133 2 #reduceActionForpostfix_expression7:) 
	#(139 3 #reduceActionForcompound_statement2:) 
	#(145 2 #reduceActionFortype_qualifier_list2:) 
	#(139 3 #reduceActionForcompound_statement3:) 
	#(122 2 #reduceActionForpointer3:) 
	#(122 2 #reduceActionForspecifier_qualifier_list3:) 
	#(114 4 #reduceActionForstruct_or_union_specifier2:) 
	#(119 2 #reduceActionFortype_qualifier_list2:) 
	#(124 1 #reduceActionForstruct_declarator1:) 
	#(123 1 #reduceActionForpointer1:) 
	#(134 2 #reduceActionForparameter_declaration1:) 
	#(135 1 #reduceActionForabstract_declarator1:) 
	#(135 1 #reduceActionForabstract_declarator2:) 
	#(128 4 #reduceActionFordirect_declarator6:) 
	#(128 4 #reduceActionFordirect_declarator7:) 
	#(128 4 #reduceActionFordirect_declarator4:) 
	#(126 3 #reduceActionForenumerator2:) 
	#(125 3 #reduceActionForinit_declarator_list2:) 
	#(115 5 #reduceActionForenum_specifier2:) 
	#(137 1 #reduceActionForpointer1:) 
	#(143 3 #reduceActionForjump_statement5:) 
	#(84 3 #reduceActionForprimary_expression4:) 
	#(90 2 #reduceActionFortype_name2:) 
	#(138 3 #reduceActionForlabeled_statement3:) 
	#(143 3 #reduceActionForjump_statement1:) 
	#(86 3 #reduceActionForassignment_expression2:) 
	#(91 3 #reduceActionFormultiplicative_expression3:) 
	#(92 3 #reduceActionFormultiplicative_expression3:) 
	#(93 3 #reduceActionFormultiplicative_expression3:) 
	#(94 3 #reduceActionFormultiplicative_expression3:) 
	#(95 3 #reduceActionFormultiplicative_expression3:) 
	#(96 3 #reduceActionFormultiplicative_expression3:) 
	#(97 3 #reduceActionFormultiplicative_expression3:) 
	#(98 3 #reduceActionFormultiplicative_expression3:) 
	#(99 3 #reduceActionFormultiplicative_expression3:) 
	#(100 3 #reduceActionFormultiplicative_expression3:) 
	#(118 3 #reduceActionForexpression2:) 
	#(138 3 #reduceActionForlabeled_statement1:) 
	#(133 3 #reduceActionForpostfix_expression6:) 
	#(133 3 #reduceActionForpostfix_expression3:) 
	#(85 1 #reduceActionForpointer1:) 
	#(133 3 #reduceActionForpostfix_expression5:) 
	#(139 4 #reduceActionForcompound_statement4:) 
	#(124 2 #reduceActionForstruct_declarator2:) 
	#(121 3 #reduceActionForstruct_declaration1:) 
	#(114 5 #reduceActionForstruct_or_union_specifier1:) 
	#(136 2 #reduceActionFordirect_abstract_declarator6:) 
	#(136 2 #reduceActionFordirect_abstract_declarator2:) 
	#(135 2 #reduceActionForabstract_declarator3:) 
	#(130 3 #reduceActionForinit_declarator_list2:) 
	#(129 3 #reduceActionForparameter_type_list2:) 
	#(132 3 #reduceActionForinit_declarator_list2:) 
	#(113 3 #reduceActionForinitializer2:) 
	#(87 4 #reduceActionForunary_expression6:) 
	#(89 4 #reduceActionForcast_expression2:) 
	#(138 4 #reduceActionForlabeled_statement2:) 
	#(133 4 #reduceActionForpostfix_expression4:) 
	#(133 4 #reduceActionForpostfix_expression2:) 
	#(124 3 #reduceActionForstruct_declarator3:) 
	#(123 3 #reduceActionForinit_declarator_list2:) 
	#(136 3 #reduceActionFordirect_abstract_declarator7:) 
	#(136 3 #reduceActionFordirect_declarator3:) 
	#(136 3 #reduceActionFordirect_abstract_declarator3:) 
	#(136 3 #reduceActionFordirect_declarator8:) 
	#(136 3 #reduceActionFordirect_declarator5:) 
	#(113 4 #reduceActionForinitializer3:) 
	#(137 3 #reduceActionForinit_declarator_list2:) 
	#(141 5 #reduceActionForselection_statement1:) 
	#(141 5 #reduceActionForselection_statement3:) 
	#(142 5 #reduceActionForiteration_statement1:) 
	#(101 5 #reduceActionForconditional_expression2:) 
	#(85 3 #reduceActionForinit_declarator_list2:) 
	#(136 4 #reduceActionFordirect_declarator6:) 
	#(136 4 #reduceActionFordirect_declarator4:) 
	#(142 6 #reduceActionForiteration_statement3:) 
	#(141 7 #reduceActionForselection_statement2:) 
	#(142 7 #reduceActionForiteration_statement4:) 
	#(142 7 #reduceActionForiteration_statement2:)
	).
]

{ #category : #generated }
CASTParser >> symbolNames [
	^ #('"^"' '"|"' '"=="' '"!="' '"&&"' '">"' '"<="' '">="' '"||"' '"%="' '"+="' '"*="' '"return"' '">>"' '"?"' '":"' '"="' '"<"' '"-="' '"--"' '","' '"->"' '"++"' '"sizeof"' '"("' '")"' '"."' '"&"' '"/"' '"%"' '"~"' '"!"' '"<<"' '"*"' '"+"' '"-"' '"/="' '"case"' '"default"' '"const"' '"volatile"' '"if"' '"struct"' '"union"' '"<<="' '"else"' '"continue"' '"break"' '"for"' '"goto"' '"enum"' '"switch"' '"while"' '"do"' '"unsigned"' '"signed"' '"typedef"' '"extern"' '"|="' '"double"' '"static"' '">>="' '"&="' '"^="' '";"' '"long"' '"float"' '"short"' '"int"' '"auto"' '"register"' '"void"' '"char"' '<ELLIPSIS>' '<comment>' '<IDENTIFIER>' '<CONSTANT>' '<STRING_LITERAL>' '<LEFT_BLOCK>' '<RIGHT_BLOCK>' '<LEFT_BRACE>' '<RIGHT_BRACE>' '<whitespace>' 'primary_expression' 'argument_expression_list' 'assignment_expression' 'unary_expression' 'unary_operator' 'cast_expression' 'type_name' 'multiplicative_expression' 'additive_expression' 'shift_expression' 'relational_expression' 'equality_expression' 'and_expression' 'exclusive_or_expression' 'inclusive_or_expression' 'logical_and_expression' 'logical_or_expression' 'conditional_expression' 'assignment_operator' 'constant_expression' 'declaration_specifiers' 'init_declaration' 'declaration' 'init_declarator_list' 'storage_class_specifier' 'type_specifier' 'type_qualifier' 'init_declarator' 'declarator' 'initializer' 'struct_or_union_specifier' 'enum_specifier' 'typename' 'struct_or_union' 'expression' 'struct_declaration_list' 'identifier' 'struct_declaration' 'specifier_qualifier_list' 'struct_declarator_list' 'struct_declarator' 'enumerator_list' 'enumerator' 'pointer' 'direct_declarator' 'parameter_type_list' 'identifier_list' 'type_qualifier_list' 'parameter_list' 'postfix_expression' 'parameter_declaration' 'abstract_declarator' 'direct_abstract_declarator' 'initializer_list' 'labeled_statement' 'compound_statement' 'expression_statement' 'selection_statement' 'iteration_statement' 'jump_statement' 'statement' 'statement_list' 'declaration_list' 'function_definition' 'translationUnit' 'E O F' 'error' 'external_declaration' 'B e g i n')
]

{ #category : #generated }
CASTParser >> symbolTypes [
	^ #(#SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #SmaCCToken #CGLRAbstractNode #OrderedCollection #CGLRAbstractNode #CGLRAbstractNode #SmaCCToken #CGLRAbstractNode #CGLRTypeNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #SmaCCToken #CGLRAbstractNode #OrderedCollection #OrderedCollection #CDeclarationNode #OrderedCollection #SmaCCToken #Object #SmaCCToken #CInitDeclaratorNode #CPointerDeclaratorNode #CGLRAbstractNode #CGLRStructOrUnionSpecifierNode #CGLREnumNode #CTypeNameNode #SmaCCToken #CExpressionNode #OrderedCollection #CIdentifierNode #CGLRStructDeclarationNode #OrderedCollection #OrderedCollection #CGLRStructDeclaratorNode #OrderedCollection #CGLREnumeratorNode #OrderedCollection #CGLRAbstractNode #OrderedCollection #OrderedCollection #OrderedCollection #OrderedCollection #CGLRAbstractNode #CGLRParameterDeclarationNode #CGLRAbstractDeclaratorNode #CGLRAbstractNode #OrderedCollection #CGLRLabeledStatementNode #CCompoundStatementNode #CGLRExpressionStatementNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #CGLRAbstractNode #OrderedCollection #OrderedCollection #CGLRFunctionDefinitionNode #CGLRTranslationUnitNode #SmaCCToken #SmaCCToken #CGLRAbstractNode #CGLRTranslationUnitNode)
]

{ #category : #generated }
CASTParser >> transitionTable [
^#(
#[1 0 9 0 25 0 13 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 0 97 0 104 0 101 0 105 0 105 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 121 0 112 0 125 0 114 0 129 0 115 0 133 0 116 0 137 0 117 0 141 0 120 0 145 0 127 0 149 0 128 0 153 0 147 0 157 0 148 0 161 0 151] 
#[1 0 9 0 25 0 13 0 34 0 93 0 76 0 165 0 112 0 169 0 116 0 141 0 120 0 145 0 127 0 149 0 128] 
#[1 0 6 0 21 0 6 0 25 0 6 0 26 0 13 0 34 0 17 0 40 0 21 0 41 0 6 0 76 0 6 0 79 0 173 0 110 0 177 0 127 0 181 0 131] 
#[0 0 10 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 10 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 14 0 76 0 81] 
#[0 0 14 0 76 0 81] 
#[1 0 185 0 76 0 189 0 81 0 193 0 120] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 22 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 22 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 22 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 22 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 22 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[1 0 26 0 1 0 26 0 2 0 26 0 3 0 26 0 4 0 26 0 5 0 26 0 6 0 26 0 7 0 26 0 8 0 26 0 9 0 26 0 10 0 26 0 11 0 26 0 12 0 26 0 14 0 26 0 15 0 7 0 16 0 7 0 17 0 26 0 18 0 26 0 19 0 26 0 20 0 7 0 21 0 26 0 22 0 26 0 23 0 7 0 25 0 7 0 26 0 26 0 27 0 26 0 28 0 26 0 29 0 26 0 30 0 26 0 33 0 7 0 34 0 26 0 35 0 26 0 36 0 26 0 37 0 7 0 40 0 7 0 41 0 7 0 43 0 7 0 44 0 26 0 45 0 7 0 51 0 7 0 55 0 7 0 56 0 7 0 57 0 7 0 58 0 26 0 59 0 7 0 60 0 7 0 61 0 26 0 62 0 26 0 63 0 26 0 64 0 7 0 65 0 7 0 66 0 7 0 67 0 7 0 68 0 7 0 69 0 7 0 70 0 7 0 71 0 7 0 72 0 7 0 73 0 7 0 76 0 7 0 79 0 7 0 81] 
#[1 0 9 0 25 0 13 0 34 0 197 0 65 0 93 0 76 0 201 0 107 0 205 0 111 0 209 0 112 0 169 0 116 0 141 0 120 0 145 0 127 0 149 0 128] 
#[0 0 213 0 65] 
#[0 0 34 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[1 0 38 0 21 0 38 0 25 0 38 0 26 0 38 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 38 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 11 0 76 0 38 0 79 0 221 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117] 
#[1 0 38 0 21 0 38 0 25 0 38 0 26 0 38 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 38 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 11 0 76 0 38 0 79 0 229 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117] 
#[1 0 38 0 21 0 38 0 25 0 38 0 26 0 38 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 38 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 11 0 76 0 38 0 79 0 233 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 0 237 0 81 0 241 0 104 0 101 0 105 0 245 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 0 249 0 139 0 253 0 146] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[1 0 18 0 21 0 15 0 25 0 15 0 26 0 18 0 34 0 15 0 40 0 15 0 41 0 15 0 43 0 15 0 44 0 15 0 51 0 15 0 55 0 15 0 56 0 15 0 57 0 15 0 58 0 15 0 60 0 15 0 61 0 18 0 65 0 15 0 66 0 15 0 67 0 15 0 68 0 15 0 69 0 15 0 70 0 15 0 71 0 15 0 72 0 15 0 73 0 15 0 76 0 15 0 79 0 42 0 81] 
#[1 0 185 0 76 1 1 0 81 1 5 0 120] 
#[0 0 42 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[1 0 9 0 25 0 93 0 76 0 169 0 116 0 141 0 120 1 9 0 128] 
#[1 0 46 0 16 0 46 0 17 0 46 0 21 1 13 0 25 0 46 0 26 0 46 0 40 0 46 0 41 0 46 0 43 0 46 0 44 0 46 0 51 0 46 0 55 0 46 0 56 0 46 0 57 0 46 0 58 0 46 0 60 0 46 0 61 0 46 0 65 0 46 0 66 0 46 0 67 0 46 0 68 0 46 0 69 0 46 0 70 0 46 0 71 0 46 0 72 0 46 0 73 0 46 0 76 1 17 0 79 0 46 0 81] 
#[0 0 34 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[1 0 9 0 25 0 13 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 0 97 0 104 0 101 0 105 0 105 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 121 0 112 0 125 0 114 0 129 0 115 0 133 0 116 0 137 0 117 0 141 0 120 0 145 0 127 0 149 0 128 0 153 0 147 0 0 0 149 1 21 0 151] 
#[0 0 50 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[0 1 25 0 26] 
#[0 0 42 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[0 0 54 0 21 0 25 0 26 0 34 0 40 0 41 0 76 0 79] 
#[0 0 58 0 21 0 25 0 26 0 76 0 79] 
#[1 0 62 0 21 0 62 0 25 0 62 0 26 0 13 0 34 0 17 0 40 0 21 0 41 0 62 0 76 0 62 0 79 1 29 0 110 1 33 0 127] 
#[0 0 26 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 40 0 41 0 43 0 44 0 45 0 51 0 55 0 56 0 57 0 58 0 59 0 60 0 61 0 62 0 63 0 64 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 80 0 81 0 82] 
#[1 0 185 0 76 1 37 0 120 1 41 0 125 1 45 0 126] 
#[1 0 66 0 16 0 66 0 21 0 66 0 25 0 66 0 26 0 66 0 34 0 66 0 40 0 66 0 41 0 66 0 43 0 66 0 44 0 66 0 51 0 66 0 55 0 66 0 56 0 66 0 57 0 66 0 58 0 66 0 60 0 66 0 61 0 66 0 65 0 66 0 66 0 66 0 67 0 66 0 68 0 66 0 69 0 66 0 70 0 66 0 71 0 66 0 72 0 66 0 73 0 66 0 76 0 66 0 79 1 49 0 81] 
#[0 0 70 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[1 1 53 0 21 0 74 0 65] 
#[0 0 78 0 21 0 65] 
#[1 1 57 0 17 0 82 0 21 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 82 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 0 237 0 81 0 241 0 104 0 101 0 105 0 245 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 1 61 0 139 1 65 0 146] 
#[0 0 86 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[0 0 30 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 90 0 21 0 25 0 26 0 34 0 65 0 76 0 79] 
#[0 0 18 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 0 90 0 21 0 25 0 26 0 34 0 65 0 76 0 79] 
#[0 0 90 0 21 0 25 0 26 0 34 0 65 0 76 0 79] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 0 17 0 40 0 21 0 41 1 121 0 42 0 25 0 43 0 29 0 44 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 0 33 0 51 1 141 0 52 1 145 0 53 1 149 0 54 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 1 153 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 165 0 82 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 0 241 0 104 0 101 0 105 0 245 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 2 13 0 144 2 17 0 145 2 21 0 146] 
#[1 0 9 0 25 0 13 0 34 0 197 0 65 0 93 0 76 0 201 0 107 0 205 0 111 2 25 0 112 0 169 0 116 0 141 0 120 0 145 0 127 0 149 0 128] 
#[0 0 94 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82] 
#[0 0 98 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 0 237 0 81 0 241 0 104 0 101 0 105 2 29 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 2 33 0 139] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 217 0 76 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 2 45 0 119 2 49 0 121 2 53 0 122] 
#[1 0 102 0 16 0 102 0 21 0 102 0 25 0 102 0 26 0 102 0 34 0 102 0 40 0 102 0 41 0 102 0 43 0 102 0 44 0 102 0 51 0 102 0 55 0 102 0 56 0 102 0 57 0 102 0 58 0 102 0 60 0 102 0 61 0 102 0 65 0 102 0 66 0 102 0 67 0 102 0 68 0 102 0 69 0 102 0 70 0 102 0 71 0 102 0 72 0 102 0 73 0 102 0 76 0 102 0 79 2 57 0 81] 
#[1 0 106 0 16 0 106 0 17 0 106 0 21 1 13 0 25 0 106 0 26 0 106 0 40 0 106 0 41 0 106 0 43 0 106 0 44 0 106 0 51 0 106 0 55 0 106 0 56 0 106 0 57 0 106 0 58 0 106 0 60 0 106 0 61 0 106 0 65 0 106 0 66 0 106 0 67 0 106 0 68 0 106 0 69 0 106 0 70 0 106 0 71 0 106 0 72 0 106 0 73 0 106 0 76 1 17 0 79 0 106 0 81] 
#[1 2 61 0 26 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 2 65 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 2 69 0 116 0 137 0 117 2 73 0 120 2 77 0 129 2 81 0 130 2 85 0 132 2 89 0 134] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 2 93 0 80 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 2 105 0 103 2 109 0 120 1 241 0 133] 
#[0 0 110 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[0 0 114 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[0 0 118 0 21 0 25 0 26 0 34 0 40 0 41 0 76 0 79] 
#[0 0 122 0 21 0 25 0 26 0 76 0 79] 
#[1 2 113 0 17 0 126 0 21 0 126 0 82] 
#[1 2 117 0 21 2 121 0 82] 
#[0 0 130 0 21 0 82] 
#[1 0 185 0 76 1 37 0 120 2 125 0 125 1 45 0 126] 
#[1 0 9 0 25 0 13 0 34 0 93 0 76 2 129 0 111 2 25 0 112 0 169 0 116 0 141 0 120 0 145 0 127 0 149 0 128] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 2 133 0 81 1 169 0 84 2 137 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 141 0 113 2 109 0 120 1 241 0 133] 
#[0 0 134 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 0 237 0 81 0 241 0 104 0 101 0 105 2 29 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 2 145 0 139] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 2 149 0 65 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 153 0 118 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 2 157 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 161 0 87 1 181 0 88 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 2 157 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 165 0 87 1 181 0 88 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 2 169 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 173 0 87 1 181 0 88 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 93 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 2 177 0 90 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 2 181 0 118 2 109 0 120 2 185 0 122 1 241 0 133] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 0 138 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 2 189 0 103 2 109 0 120 1 241 0 133] 
#[0 2 193 0 16] 
#[0 2 197 0 25] 
#[0 2 201 0 65] 
#[0 2 205 0 65] 
#[0 2 209 0 25] 
#[1 0 185 0 76 2 213 0 120] 
#[0 2 217 0 25] 
#[0 2 221 0 25] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 2 225 0 144] 
#[0 0 142 0 13 0 20 0 23 0 24 0 25 0 26 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 146 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 0 150 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 0 154 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 46 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[0 0 158 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 0 162 0 16 0 21 0 26 0 65 0 80] 
#[1 0 166 0 1 0 166 0 2 0 166 0 3 0 166 0 4 0 166 0 5 0 166 0 6 0 166 0 7 0 166 0 8 0 166 0 9 2 229 0 10 2 233 0 11 2 237 0 12 0 166 0 14 0 166 0 15 0 166 0 16 2 241 0 17 0 166 0 18 2 245 0 19 0 166 0 21 0 166 0 26 0 166 0 28 0 166 0 29 0 166 0 30 0 166 0 33 0 166 0 34 0 166 0 35 0 166 0 36 2 249 0 37 2 253 0 45 3 1 0 59 3 5 0 62 3 9 0 63 3 13 0 64 0 166 0 65 0 166 0 80 0 166 0 82 3 17 0 102] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 3 21 0 89 2 109 0 120 1 241 0 133] 
#[0 0 170 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 14 0 15 0 16 0 18 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 65 0 80 0 82] 
#[1 0 174 0 1 0 174 0 2 0 174 0 3 0 174 0 4 0 174 0 5 0 174 0 6 0 174 0 7 0 174 0 8 0 174 0 9 0 174 0 14 0 174 0 15 0 174 0 16 0 174 0 18 0 174 0 21 0 174 0 26 0 174 0 28 3 25 0 29 3 29 0 30 0 174 0 33 3 33 0 34 0 174 0 35 0 174 0 36 0 174 0 65 0 174 0 80 0 174 0 82] 
#[1 0 178 0 1 0 178 0 2 0 178 0 3 0 178 0 4 0 178 0 5 0 178 0 6 0 178 0 7 0 178 0 8 0 178 0 9 0 178 0 14 0 178 0 15 0 178 0 16 0 178 0 18 0 178 0 21 0 178 0 26 0 178 0 28 0 178 0 33 3 37 0 35 3 41 0 36 0 178 0 65 0 178 0 80 0 178 0 82] 
#[1 0 182 0 1 0 182 0 2 0 182 0 3 0 182 0 4 0 182 0 5 0 182 0 6 0 182 0 7 0 182 0 8 0 182 0 9 3 45 0 14 0 182 0 15 0 182 0 16 0 182 0 18 0 182 0 21 0 182 0 26 0 182 0 28 3 49 0 33 0 182 0 65 0 182 0 80 0 182 0 82] 
#[1 0 186 0 1 0 186 0 2 0 186 0 3 0 186 0 4 0 186 0 5 3 53 0 6 3 57 0 7 3 61 0 8 0 186 0 9 0 186 0 15 0 186 0 16 3 65 0 18 0 186 0 21 0 186 0 26 0 186 0 28 0 186 0 65 0 186 0 80 0 186 0 82] 
#[1 0 190 0 1 0 190 0 2 3 69 0 3 3 73 0 4 0 190 0 5 0 190 0 9 0 190 0 15 0 190 0 16 0 190 0 21 0 190 0 26 0 190 0 28 0 190 0 65 0 190 0 80 0 190 0 82] 
#[1 0 194 0 1 0 194 0 2 0 194 0 5 0 194 0 9 0 194 0 15 0 194 0 16 0 194 0 21 0 194 0 26 3 77 0 28 0 194 0 65 0 194 0 80 0 194 0 82] 
#[1 3 81 0 1 0 198 0 2 0 198 0 5 0 198 0 9 0 198 0 15 0 198 0 16 0 198 0 21 0 198 0 26 0 198 0 65 0 198 0 80 0 198 0 82] 
#[1 3 85 0 2 0 202 0 5 0 202 0 9 0 202 0 15 0 202 0 16 0 202 0 21 0 202 0 26 0 202 0 65 0 202 0 80 0 202 0 82] 
#[1 3 89 0 5 0 206 0 9 0 206 0 15 0 206 0 16 0 206 0 21 0 206 0 26 0 206 0 65 0 206 0 80 0 206 0 82] 
#[1 3 93 0 9 3 97 0 15 0 210 0 16 0 210 0 21 0 210 0 26 0 210 0 65 0 210 0 80 0 210 0 82] 
#[0 0 214 0 16 0 21 0 26 0 65 0 80 0 82] 
#[1 3 101 0 21 3 105 0 65] 
#[1 0 218 0 1 0 218 0 2 0 218 0 3 0 218 0 4 0 218 0 5 0 218 0 6 0 218 0 7 0 218 0 8 0 218 0 9 0 218 0 10 0 218 0 11 0 218 0 12 0 218 0 14 0 218 0 15 3 109 0 16 0 218 0 17 0 218 0 18 0 218 0 19 0 218 0 20 0 218 0 21 0 218 0 22 0 218 0 23 0 218 0 25 0 218 0 27 0 218 0 28 0 218 0 29 0 218 0 30 0 218 0 33 0 218 0 34 0 218 0 35 0 218 0 36 0 218 0 37 0 218 0 45 0 218 0 59 0 218 0 62 0 218 0 63 0 218 0 64 0 218 0 65 0 218 0 79] 
#[1 0 222 0 1 0 222 0 2 0 222 0 3 0 222 0 4 0 222 0 5 0 222 0 6 0 222 0 7 0 222 0 8 0 222 0 9 0 222 0 10 0 222 0 11 0 222 0 12 0 222 0 14 0 222 0 15 0 222 0 16 0 222 0 17 0 222 0 18 0 222 0 19 3 113 0 20 0 222 0 21 3 117 0 22 3 121 0 23 3 125 0 25 0 222 0 26 3 129 0 27 0 222 0 28 0 222 0 29 0 222 0 30 0 222 0 33 0 222 0 34 0 222 0 35 0 222 0 36 0 222 0 37 0 222 0 45 0 222 0 59 0 222 0 62 0 222 0 63 0 222 0 64 0 222 0 65 3 133 0 79 0 222 0 80 0 222 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 226 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 0 230 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 3 137 0 82 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 3 141 0 144] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 0 17 0 40 0 21 0 41 1 121 0 42 0 25 0 43 0 29 0 44 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 0 33 0 51 1 141 0 52 1 145 0 53 1 149 0 54 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 1 153 0 65 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 1 157 0 77 1 161 0 78 0 237 0 81 3 145 0 82 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 0 241 0 104 0 101 0 105 2 29 0 106 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 2 13 0 144 3 149 0 145] 
#[1 1 57 0 17 0 82 0 21 0 82 0 65] 
#[0 0 234 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82] 
#[0 0 238 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[1 0 242 0 16 0 242 0 25 0 242 0 26 0 242 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 19 0 76 0 242 0 79 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 3 153 0 122] 
#[1 0 246 0 16 0 246 0 25 0 246 0 26 0 246 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 23 0 76 0 246 0 79 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 3 157 0 122] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 217 0 76 3 161 0 82 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 3 165 0 121 2 53 0 122] 
#[0 0 250 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 60 0 66 0 67 0 68 0 69 0 72 0 73 0 76 0 82] 
#[1 3 169 0 16 0 9 0 25 0 13 0 34 0 93 0 76 3 173 0 112 0 169 0 116 0 141 0 120 3 177 0 123 3 181 0 124 0 145 0 127 0 149 0 128] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 217 0 76 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 3 185 0 119 2 49 0 121 2 53 0 122] 
#[0 0 254 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[1 1 2 0 21 3 189 0 25 1 2 0 26 0 13 0 34 0 93 0 76 3 193 0 79 3 197 0 112 0 169 0 116 0 141 0 120 3 201 0 127 0 149 0 128 3 205 0 135 3 209 0 136] 
#[1 0 27 0 21 0 18 0 25 0 27 0 26 0 18 0 34 0 18 0 40 0 18 0 41 0 18 0 43 0 18 0 44 0 18 0 51 0 18 0 55 0 18 0 56 0 18 0 57 0 18 0 58 0 18 0 60 0 18 0 61 0 18 0 66 0 18 0 67 0 18 0 68 0 18 0 69 0 18 0 70 0 18 0 71 0 18 0 72 0 18 0 73 0 18 0 76 0 18 0 79] 
#[0 1 6 0 21 0 26] 
#[0 3 213 0 26] 
#[1 3 217 0 21 3 221 0 26] 
#[1 3 225 0 21 1 10 0 26] 
#[0 1 14 0 21 0 26] 
#[0 1 18 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[0 0 166 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[0 1 22 0 16 0 21 0 65 0 80 0 82] 
#[0 3 229 0 80] 
#[0 0 218 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 3 233 0 103 2 109 0 120 1 241 0 133] 
#[1 0 185 0 76 1 37 0 120 3 237 0 126] 
#[0 1 26 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[1 2 117 0 21 3 241 0 82] 
#[0 1 30 0 21 0 65] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 2 133 0 81 1 169 0 84 2 137 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 3 245 0 113 2 109 0 120 1 241 0 133 3 249 0 137] 
#[0 1 34 0 21 0 65 0 82] 
#[0 1 38 0 21 0 65] 
#[0 1 42 0 25 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 149] 
#[0 1 46 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 3 101 0 21 3 253 0 65] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 181 0 118 2 109 0 120 1 241 0 133] 
#[0 1 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[0 1 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 93 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 4 1 0 90 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 2 181 0 118 2 109 0 120 2 185 0 122 1 241 0 133] 
#[0 1 54 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[0 4 5 0 26] 
#[1 3 101 0 21 4 9 0 26] 
#[1 4 13 0 25 1 58 0 26 0 13 0 34 3 193 0 79 4 17 0 127 4 21 0 135 3 209 0 136] 
#[0 4 25 0 16] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 4 29 0 144] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 4 33 0 118 2 109 0 120 1 241 0 133] 
#[0 1 62 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 1 66 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 2 109 0 120 1 241 0 133 4 37 0 140] 
#[0 4 41 0 65] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 4 45 0 118 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 4 49 0 118 2 109 0 120 1 241 0 133] 
#[0 4 53 0 53] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[0 1 70 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 76 0 77 0 78] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 4 57 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 109 0 120 1 241 0 133] 
#[0 1 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 4 61 0 89 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 4 65 0 89 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 4 69 0 89 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 4 73 0 91 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 4 77 0 91 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 4 81 0 92 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 4 85 0 92 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 4 89 0 93 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 4 93 0 93 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 4 97 0 93 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 4 101 0 93 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 4 105 0 94 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 4 109 0 94 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 4 113 0 95 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 4 117 0 96 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 4 121 0 97 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 4 125 0 98 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 4 129 0 99 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 4 133 0 118 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 4 137 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 109 0 120 1 241 0 133] 
#[0 1 74 0 13 0 20 0 23 0 24 0 25 0 26 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 4 141 0 144] 
#[0 1 78 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 0 185 0 76 4 145 0 120] 
#[0 1 82 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 4 149 0 26 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 4 153 0 85 4 157 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 109 0 120 1 241 0 133] 
#[1 0 185 0 76 4 161 0 120] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 4 165 0 118 2 109 0 120 1 241 0 133] 
#[0 1 86 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 46 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[0 1 90 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 1 94 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 46 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 4 169 0 82 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 3 141 0 144] 
#[0 1 98 0 16 0 25 0 26 0 34 0 76 0 79] 
#[0 1 102 0 16 0 25 0 26 0 34 0 76 0 79] 
#[0 1 106 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 1 110 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 60 0 66 0 67 0 68 0 69 0 72 0 73 0 76 0 82] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 4 173 0 103 2 109 0 120 1 241 0 133] 
#[1 4 177 0 16 1 114 0 21 1 114 0 65] 
#[1 4 181 0 21 4 185 0 65] 
#[0 1 118 0 21 0 65] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 53 0 60 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 85 0 72 0 89 0 73 0 217 0 76 4 189 0 82 2 37 0 109 2 41 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 3 165 0 121 2 53 0 122] 
#[1 3 189 0 25 4 193 0 26 0 13 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 93 0 76 3 193 0 79 2 65 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 165 0 112 0 125 0 114 0 129 0 115 0 133 0 116 0 137 0 117 0 141 0 120 3 201 0 127 0 149 0 128 4 197 0 129 2 85 0 132 2 89 0 134 4 201 0 135 3 209 0 136] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 4 205 0 80 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 4 209 0 103 2 109 0 120 1 241 0 133] 
#[0 1 122 0 21 0 26] 
#[1 1 126 0 21 3 189 0 25 1 126 0 26 0 93 0 76 3 193 0 79 0 169 0 116 0 141 0 120 1 9 0 128 4 213 0 136] 
#[0 1 122 0 21 0 26] 
#[1 1 130 0 21 4 217 0 25 1 130 0 26 4 221 0 79] 
#[0 1 134 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[1 0 93 0 76 4 225 0 116 4 229 0 120] 
#[0 1 138 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[1 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 4 233 0 74 0 217 0 76 2 65 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 4 237 0 134] 
#[0 1 142 0 16 0 17 0 21 0 25 0 26 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79 0 81] 
#[0 1 146 0 21 0 82] 
#[0 1 150 0 21 0 82] 
#[0 1 154 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 1 158 0 21 0 82] 
#[1 4 241 0 21 4 245 0 82] 
#[0 1 162 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 4 249 0 26] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 4 253 0 89 2 109 0 120 1 241 0 133] 
#[0 1 166 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 4 13 0 25 4 193 0 26 0 13 0 34 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 3 193 0 79 2 65 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 4 17 0 127 4 197 0 129 2 85 0 132 2 89 0 134 4 201 0 135 3 209 0 136] 
#[1 4 13 0 25 1 126 0 26 3 193 0 79 4 213 0 136] 
#[0 1 170 0 26] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 1 0 144] 
#[0 1 174 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 3 101 0 21 5 5 0 26] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 2 109 0 120 1 241 0 133 5 9 0 140] 
#[0 1 178 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 3 101 0 21 5 13 0 26] 
#[1 3 101 0 21 5 17 0 26] 
#[0 5 21 0 25] 
#[0 1 182 0 16 0 21 0 26 0 65 0 80 0 82] 
#[0 1 186 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 14 0 15 0 16 0 18 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 65 0 80 0 82] 
#[0 1 186 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 14 0 15 0 16 0 18 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 65 0 80 0 82] 
#[0 1 186 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 14 0 15 0 16 0 18 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 65 0 80 0 82] 
#[1 1 190 0 1 1 190 0 2 1 190 0 3 1 190 0 4 1 190 0 5 1 190 0 6 1 190 0 7 1 190 0 8 1 190 0 9 1 190 0 14 1 190 0 15 1 190 0 16 1 190 0 18 1 190 0 21 1 190 0 26 1 190 0 28 3 25 0 29 3 29 0 30 1 190 0 33 3 33 0 34 1 190 0 35 1 190 0 36 1 190 0 65 1 190 0 80 1 190 0 82] 
#[1 1 190 0 1 1 190 0 2 1 190 0 3 1 190 0 4 1 190 0 5 1 190 0 6 1 190 0 7 1 190 0 8 1 190 0 9 1 190 0 14 1 190 0 15 1 190 0 16 1 190 0 18 1 190 0 21 1 190 0 26 1 190 0 28 3 25 0 29 3 29 0 30 1 190 0 33 3 33 0 34 1 190 0 35 1 190 0 36 1 190 0 65 1 190 0 80 1 190 0 82] 
#[1 1 194 0 1 1 194 0 2 1 194 0 3 1 194 0 4 1 194 0 5 1 194 0 6 1 194 0 7 1 194 0 8 1 194 0 9 1 194 0 14 1 194 0 15 1 194 0 16 1 194 0 18 1 194 0 21 1 194 0 26 1 194 0 28 1 194 0 33 3 37 0 35 3 41 0 36 1 194 0 65 1 194 0 80 1 194 0 82] 
#[1 1 194 0 1 1 194 0 2 1 194 0 3 1 194 0 4 1 194 0 5 1 194 0 6 1 194 0 7 1 194 0 8 1 194 0 9 1 194 0 14 1 194 0 15 1 194 0 16 1 194 0 18 1 194 0 21 1 194 0 26 1 194 0 28 1 194 0 33 3 37 0 35 3 41 0 36 1 194 0 65 1 194 0 80 1 194 0 82] 
#[1 1 198 0 1 1 198 0 2 1 198 0 3 1 198 0 4 1 198 0 5 1 198 0 6 1 198 0 7 1 198 0 8 1 198 0 9 3 45 0 14 1 198 0 15 1 198 0 16 1 198 0 18 1 198 0 21 1 198 0 26 1 198 0 28 3 49 0 33 1 198 0 65 1 198 0 80 1 198 0 82] 
#[1 1 198 0 1 1 198 0 2 1 198 0 3 1 198 0 4 1 198 0 5 1 198 0 6 1 198 0 7 1 198 0 8 1 198 0 9 3 45 0 14 1 198 0 15 1 198 0 16 1 198 0 18 1 198 0 21 1 198 0 26 1 198 0 28 3 49 0 33 1 198 0 65 1 198 0 80 1 198 0 82] 
#[1 1 198 0 1 1 198 0 2 1 198 0 3 1 198 0 4 1 198 0 5 1 198 0 6 1 198 0 7 1 198 0 8 1 198 0 9 3 45 0 14 1 198 0 15 1 198 0 16 1 198 0 18 1 198 0 21 1 198 0 26 1 198 0 28 3 49 0 33 1 198 0 65 1 198 0 80 1 198 0 82] 
#[1 1 198 0 1 1 198 0 2 1 198 0 3 1 198 0 4 1 198 0 5 1 198 0 6 1 198 0 7 1 198 0 8 1 198 0 9 3 45 0 14 1 198 0 15 1 198 0 16 1 198 0 18 1 198 0 21 1 198 0 26 1 198 0 28 3 49 0 33 1 198 0 65 1 198 0 80 1 198 0 82] 
#[1 1 202 0 1 1 202 0 2 1 202 0 3 1 202 0 4 1 202 0 5 3 53 0 6 3 57 0 7 3 61 0 8 1 202 0 9 1 202 0 15 1 202 0 16 3 65 0 18 1 202 0 21 1 202 0 26 1 202 0 28 1 202 0 65 1 202 0 80 1 202 0 82] 
#[1 1 202 0 1 1 202 0 2 1 202 0 3 1 202 0 4 1 202 0 5 3 53 0 6 3 57 0 7 3 61 0 8 1 202 0 9 1 202 0 15 1 202 0 16 3 65 0 18 1 202 0 21 1 202 0 26 1 202 0 28 1 202 0 65 1 202 0 80 1 202 0 82] 
#[1 1 206 0 1 1 206 0 2 3 69 0 3 3 73 0 4 1 206 0 5 1 206 0 9 1 206 0 15 1 206 0 16 1 206 0 21 1 206 0 26 1 206 0 28 1 206 0 65 1 206 0 80 1 206 0 82] 
#[1 1 210 0 1 1 210 0 2 1 210 0 5 1 210 0 9 1 210 0 15 1 210 0 16 1 210 0 21 1 210 0 26 3 77 0 28 1 210 0 65 1 210 0 80 1 210 0 82] 
#[1 3 81 0 1 1 214 0 2 1 214 0 5 1 214 0 9 1 214 0 15 1 214 0 16 1 214 0 21 1 214 0 26 1 214 0 65 1 214 0 80 1 214 0 82] 
#[1 3 85 0 2 1 218 0 5 1 218 0 9 1 218 0 15 1 218 0 16 1 218 0 21 1 218 0 26 1 218 0 65 1 218 0 80 1 218 0 82] 
#[1 3 89 0 5 1 222 0 9 1 222 0 15 1 222 0 16 1 222 0 21 1 222 0 26 1 222 0 65 1 222 0 80 1 222 0 82] 
#[1 5 25 0 16 3 101 0 21] 
#[0 1 226 0 16 0 21 0 26 0 65 0 80] 
#[0 1 230 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 1 234 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 1 238 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 5 29 0 21 5 33 0 26] 
#[0 1 242 0 21 0 26] 
#[0 1 246 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[1 3 101 0 21 5 37 0 80] 
#[0 1 250 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 40 0 41 0 42 0 43 0 44 0 46 0 47 0 48 0 49 0 50 0 51 0 52 0 53 0 54 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 77 0 78 0 81 0 82 0 149] 
#[0 1 254 0 21 0 65] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 5 41 0 103 2 109 0 120 1 241 0 133] 
#[1 3 169 0 16 0 9 0 25 0 13 0 34 0 93 0 76 3 173 0 112 0 169 0 116 0 141 0 120 5 45 0 124 0 145 0 127 0 149 0 128] 
#[0 2 2 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 60 0 66 0 67 0 68 0 69 0 72 0 73 0 76 0 82] 
#[0 2 6 0 16 0 21 0 25 0 26 0 34 0 40 0 41 0 43 0 44 0 51 0 55 0 56 0 57 0 58 0 60 0 61 0 65 0 66 0 67 0 68 0 69 0 70 0 71 0 72 0 73 0 76 0 79] 
#[0 2 10 0 21 0 25 0 26 0 79] 
#[0 5 49 0 26] 
#[0 5 53 0 26] 
#[0 2 14 0 21 0 25 0 26 0 79] 
#[0 5 57 0 80] 
#[1 2 18 0 21 4 217 0 25 2 18 0 26 4 221 0 79] 
#[1 5 61 0 26 0 17 0 40 0 21 0 41 0 25 0 43 0 29 0 44 0 33 0 51 0 37 0 55 0 41 0 56 0 45 0 57 0 49 0 58 0 53 0 60 0 57 0 61 0 61 0 66 0 65 0 67 0 69 0 68 0 73 0 69 0 77 0 70 0 81 0 71 0 85 0 72 0 89 0 73 0 217 0 76 2 65 0 104 0 109 0 108 0 113 0 109 0 117 0 110 0 125 0 114 0 129 0 115 0 225 0 116 0 137 0 117 5 65 0 129 2 85 0 132 2 89 0 134] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 5 69 0 80 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 2 101 0 101 5 73 0 103 2 109 0 120 1 241 0 133] 
#[0 2 22 0 21 0 26] 
#[0 2 22 0 21 0 26] 
#[0 2 26 0 26] 
#[0 2 30 0 21 0 26] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 2 133 0 81 5 77 0 82 1 169 0 84 2 137 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 5 81 0 113 2 109 0 120 1 241 0 133] 
#[0 2 34 0 21 0 65 0 82] 
#[0 2 38 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[0 2 42 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 21 0 26 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 80 0 82] 
#[0 2 46 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 85 0 144] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 5 89 0 26 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 5 93 0 118 2 109 0 120 1 241 0 133] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 97 0 144] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 101 0 144] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 5 105 0 118 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 2 97 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 5 109 0 101 2 109 0 120 1 241 0 133] 
#[1 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 0 185 0 76 1 157 0 77 1 161 0 78 1 169 0 84 5 113 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 2 109 0 120 1 241 0 133] 
#[0 2 50 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 2 54 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0 9 0 10 0 11 0 12 0 14 0 15 0 16 0 17 0 18 0 19 0 20 0 21 0 22 0 23 0 25 0 26 0 27 0 28 0 29 0 30 0 33 0 34 0 35 0 36 0 37 0 45 0 59 0 62 0 63 0 64 0 65 0 79 0 80 0 82] 
#[0 2 58 0 21 0 65] 
#[0 2 62 0 21 0 65] 
#[0 2 66 0 21 0 25 0 26 0 79] 
#[0 2 70 0 21 0 25 0 26 0 79] 
#[0 2 74 0 21 0 25 0 26 0 79] 
#[0 2 78 0 21 0 25 0 26 0 79] 
#[0 5 117 0 26] 
#[0 2 82 0 21 0 25 0 26 0 79] 
#[0 5 121 0 80] 
#[0 2 86 0 21 0 65 0 82] 
#[0 2 90 0 21 0 82] 
#[1 2 94 0 13 2 94 0 20 2 94 0 23 2 94 0 24 2 94 0 25 2 94 0 28 2 94 0 31 2 94 0 32 2 94 0 34 2 94 0 35 2 94 0 36 2 94 0 38 2 94 0 39 2 94 0 42 0 31 0 46 2 94 0 47 2 94 0 48 2 94 0 49 2 94 0 50 2 94 0 52 2 94 0 53 2 94 0 54 2 94 0 65 2 94 0 76 2 94 0 77 2 94 0 78 2 94 0 81 2 94 0 82] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 129 0 144] 
#[1 3 101 0 21 5 133 0 26] 
#[0 2 98 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 2 102 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 3 101 0 21 5 137 0 26] 
#[0 2 106 0 16 0 21 0 26 0 65 0 80 0 82] 
#[0 2 110 0 21 0 26] 
#[0 2 114 0 21 0 25 0 26 0 79] 
#[0 2 118 0 21 0 25 0 26 0 79] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 141 0 144] 
#[0 2 122 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[1 1 69 0 13 1 73 0 20 1 77 0 23 1 81 0 24 1 85 0 25 1 89 0 28 1 93 0 31 1 97 0 32 1 101 0 34 1 105 0 35 1 109 0 36 1 113 0 38 1 117 0 39 1 121 0 42 1 125 0 47 1 129 0 48 1 133 0 49 1 137 0 50 1 141 0 52 1 145 0 53 1 149 0 54 1 153 0 65 0 185 0 76 1 157 0 77 1 161 0 78 0 237 0 81 1 169 0 84 1 173 0 86 1 177 0 87 1 181 0 88 1 185 0 89 1 189 0 91 1 193 0 92 1 197 0 93 1 201 0 94 1 205 0 95 1 209 0 96 1 213 0 97 1 217 0 98 1 221 0 99 1 225 0 100 1 229 0 101 1 233 0 118 1 237 0 120 1 241 0 133 1 245 0 138 1 249 0 139 1 253 0 140 2 1 0 141 2 5 0 142 2 9 0 143 5 145 0 144] 
#[0 5 149 0 65] 
#[0 2 126 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 2 130 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82] 
#[0 2 134 0 13 0 20 0 23 0 24 0 25 0 28 0 31 0 32 0 34 0 35 0 36 0 38 0 39 0 42 0 46 0 47 0 48 0 49 0 50 0 52 0 53 0 54 0 65 0 76 0 77 0 78 0 81 0 82]
	).
]
