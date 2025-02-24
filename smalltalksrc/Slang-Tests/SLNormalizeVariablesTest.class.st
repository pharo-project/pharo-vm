Class {
	#name : 'SLNormalizeVariablesTest',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLNormalizeVariablesTest >> collectArgumentsNameIn: aNodeWithArguments [

	^ aNodeWithArguments arguments collect: [ :arg | arg name ]
]

{ #category : 'helpers' }
SLNormalizeVariablesTest >> collectVariablesNameIn: aTStatementListNode [
	| variables|
	variables  := OrderedCollection new.
	aTStatementListNode nodesDo: [ :node |
		   node isVariable ifTrue: [ variables add:  node name ] ].
	^ variables asArray 

]

{ #category : 'running' }
SLNormalizeVariablesTest >> setUp [

	super setUp.
	SLNormalizeVariablesTestClass initializeGlobals.
	ccg addClass: SLNormalizeVariablesTestClass.
	ccg removeConstant: #ConstantWithReplacementShouldNotBeGenerated.
	ccg removeConstant:
		#ConstantFromPoolWithReplacementShouldNotBeGenerated.
	ccg inferTypes.
	ccg prepareMethods
]

{ #category : 'tests-methods-referencing-struct-classes' }
SLNormalizeVariablesTest >> testMethodReferencingStructClass [

	| method body |
	method := ccg methodNamed: #methodReferencingStructClass.
	body := method parseTree statements.
	self assert: method allLocals isEmpty.
	self
		assert: (body at: 1) name
		equals: #SLNormalizeVariablesTestStructClass.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-globals-variables' }
SLNormalizeVariablesTest >> testMethodWithInstancesVariables [

	| method body |
	method := ccg methodNamed: #methodWithInstancesVariables.
	body := method parseTree statements.
	"instances variables are seen as globals"
	self assert: method allLocals isEmpty.
	self assert: (body at: 1) name equals: #instanceVariable1.
	self assert: (body at: 2) name equals: #instanceVariable2.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTest >> testMethodWithReservedArgumentsName [
	"the reserved name self, super and cascade are not modified"

	| method body |
	method := ccg methodNamed: #methodWithReservedArgumentsName:arg:.
	body := method parseTree statements.
	self
		assert: (self collectArgumentsNameIn: (body at: 1))
		equals: { #self }.
	self
		assert: (self collectArgumentsNameIn: (body at: 2))
		equals: { #super }.
	self
		assert: (self collectArgumentsNameIn: (body at: 3))
		equals: { #cascade }.
	self
		assert: (self collectArgumentsNameIn: (body at: 4))
		equals: { #_arg1 }.
	self assert: method args asArray equals: { #cascade. #_arg1 }
]

{ #category : 'tests-methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTest >> testMethodWithReservedLocalsName [
	"the reserved name self, super and cascade are not modified"

	| method body |
	method := ccg methodNamed: #methodWithReservedLocalsName.
	body := method parseTree statements.
	"super and self are not in the locals"
	self
		assert: method allLocals
		equals: { #var1. #_var2. #cascade. #self_in_methodWithReservedLocalsName. #interpreterProxy} asSet.
	
	self assert: (body at: 1) name equals: #self.
	self assert: (body at: 2) name equals: #self_in_methodWithReservedLocalsName.
	self assert: (body at: 3) name equals: #super.
	self assert: (body at: 4) name equals: #cascade.
	"implicit variable, they won't appear in the C code but might be hard coded somewhere in Slang"
	self assert: (body at: 5) name equals: #interpreterProxy.
	"implicit variable"
	self assert: (body at: 6) name equals: #var1.
	self assert: (body at: 7) name equals: #_var2.	

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-globals-variables' }
SLNormalizeVariablesTest >> testMethodWithSharedVariables [

	| method body constant1 constant2 constant3 |
	method := ccg methodNamed: #methodWithSharedVariables.
	body := method parseTree statements.
	constant1 := body at: 1.
	constant2 := body at: 2.
	constant3 := body at: 3.

	"sharedVariables variables are seen as globals"
	self assert: method allLocals isEmpty.

	self assert: constant1 isDefine.
	self assert: constant1 name equals: #ConstantWithNoReplacement.
	self assert: constant1 value equals: nil.
	self assert: constant1 shouldBeGenerated equals: true.

	self assert: constant2 isDefine.
	self assert: constant2 name equals: #ConstantWithReplacementShouldBeGenerated.
	self assert: constant2 value equals: #replacement.
	self assert: constant2 shouldBeGenerated equals: true.
	
	self assert: constant3 isVariable.
	self assert: constant3 name equals: #ConstantWithReplacementShouldNotBeGenerated.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-unused-locals-and-variables' }
SLNormalizeVariablesTest >> testMethodWithUnusedArguments [
	"the two parameters does not appear in the parseTree, they doesn't change"

	| method |
	method := ccg methodNamed: #methodWithUnusedArguments:arg:.
	self assert: method allLocals isEmpty.
	
	self assert: method args asArray equals: { #arg1. #arg2 }
]

{ #category : 'tests-methods-with-unused-locals-and-variables' }
SLNormalizeVariablesTest >> testMethodWithUnusedLocals [
	"var1 and var2 doesn't appear in the parseeTree, they doesn't change"

	| method |
	method := ccg methodNamed: #methodWithUnusedLocals.
	self assert: method allLocals equals: { #var1. #var2 } asSet.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-unused-locals-and-variables' }
SLNormalizeVariablesTest >> testMethodWithUsedAndUnusedArguments [
	"arg2 doesn't appear in the parseeTree, it doesn't change."

	| method |
	method := ccg methodNamed: #methodWithUsedAndUnusedArguments:arg:.
	self assert: method args asArray equals: { #_arg1. #arg2 }.
	
	self assert: method locals isEmpty
]

{ #category : 'tests-methods-with-unused-locals-and-variables' }
SLNormalizeVariablesTest >> testMethodWithUsedAndUnusedLocals [
	"var1 doesn't appear in the parseeTree, it doesn't change. Normalize the var2"

	| method |
	method := ccg methodNamed: #methodWithUsedAndUnusedLocals.
	self assert: method allLocals equals: { #var1. #_var2 } asSet.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-unused-locals-and-variables' }
SLNormalizeVariablesTest >> testMethodWithUsedAndUnusedLocalsAndArgument [
	"var1 and arg1 doesn't appear in the parseeTree, they doesn't change"

	| method |
	method := ccg methodNamed:
		          #methodWithUsedAndUnusedLocalsAndArguments:arg:.
	self assert: method allLocals equals: { #var1. #_var2 } asSet.
	self assert: method args asArray equals: { #arg1. #_arg2 }
]

{ #category : 'tests-methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTest >> testMethodWithUsedArguments [
	"the reserved name self, super and cascade are not modified"

	| method body |
	method := ccg methodNamed: #methodWithUsedArguments:arg:.
	body := method parseTree statements.
	self
		assert: (self collectArgumentsNameIn: (body at: 1))
		equals: { #_arg1 }.
	self
		assert: (self collectArgumentsNameIn: (body at: 2) arguments first)
		equals: { #_arg2 }.
	self
		assert: (body at: 3) arguments first arguments
		equals: { #_arg3 }.
	self assert: method args asArray equals: { #_arg1. #_arg2 }.

	self assert: method allLocals equals: { #_arg3 } asSet
]

{ #category : 'tests-methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTest >> testMethodWithUsedLocals [

	| method body subBlock subsubBlock |
	method := ccg methodNamed: #methodWithUsedLocals.
	body := method parseTree statements.
	subBlock := body at: 3.
	subsubBlock := subBlock statements at: 3.
	self
		assert: method allLocals
		equals: { #_var1. #_var2. #_var3. #_var4. #_var5. #_var6 } asSet.
	self
		assert: (self collectVariablesNameIn: subBlock)
		equals: { #_var3. #_var4. #_var5. #_var6 }.
	self
		assert: (self collectVariablesNameIn: subsubBlock)
		equals: { #_var5. #_var6 }.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-globals-variables' }
SLNormalizeVariablesTest >> testMethodWithVariablesFromSharedPools [

	| method body constant1 constant2 constant3 |
	method := ccg methodNamed: #methodWithVariablesFromSharedPools.
	body := method parseTree statements.
	constant1 := body at: 1.
	constant2 := body at: 2.
	constant3 := body at: 3.
	
	"sharedVariables variables are seen as globals"
	self assert: method allLocals isEmpty.

	self assert: constant1 isDefine.
	self assert: constant1 name equals: #ConstantFromPoolWithNoReplacement.
	self assert: constant1 value equals: nil.
	self assert: constant1 shouldBeGenerated equals: true.

	self assert: constant2 isDefine.
	self assert: constant2 name equals: #ConstantFromPoolWithReplacementShouldBeGenerated.
	self assert: constant2 value equals: #'replacement from pool'.
	self assert: constant2 shouldBeGenerated equals: true.
	
	self assert: constant3 isVariable.
	self assert: constant3 name equals: #ConstantFromPoolWithReplacementShouldNotBeGenerated.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-variables-in-cCode' }
SLNormalizeVariablesTest >> testMethodWithVariablesInCCode [
	"rare case but it can happen, see addressIsInFixups:"

	| method body |
	method := ccg methodNamed: #methodWithVariablesInCCode.
	body := method parseTree statements.

	self
		assert: (body at: 1) arguments first value
		equals: #'_var1 *_var2'.
	self
		assert: (body at: 2) arguments first value
		equals: #'_var2 *_var1'.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-variables-in-cCode' }
SLNormalizeVariablesTest >> testMethodWithVariablesInCCodePrint [
	"rare case but it can happen, see printMethodCacheFor:, s need to be kept intact in some place of the print and n should't be modified in it"

	| method body |
	method := ccg methodNamed: #methodWithVariablesInCCodePrint.
	body := method parseTree statements.

	self
		assert: (body at: 1) arguments first value
		equals:
		#'vm_printf("%" PRIxSQPTR " %.*s\n", _s, (int)(numBytesOf(_s)), (char *)firstIndexableField(_s))'.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-var-return-type-C' }
SLNormalizeVariablesTest >> testMethodWithVariablesInVarReturnTypeC [
	"rare case but it can happen, see genCallPICEnilopmartNumArgs:"
	| method body |
	method := ccg methodNamed: #methodWithVariablesInVarReturnTypeC.
	body := method parseTree statements.

	self assert: (body at: 1) name equals: #_var1.

	self assert: method returnType equals: #'_var1 *'.

	self assert: method args isEmpty
]

{ #category : 'tests-methods-with-var-type-declaration' }
SLNormalizeVariablesTest >> testMethodWithVariablesInVarTypeDeclaration [

	| method body |
	method := ccg methodNamed: #methodWithVariablesInVarTypeDeclaration.
	body := method parseTree statements.

	self assert: (body at: 1) name equals: #_var1.
	self assert: (body at: 2) name equals: #_var2.

	self assert: (method declarations at: #_var1) equals: #'char *_var1'.
	"maybe shouldn't be this way, but doesnt appear in the VM"
	self assert: (method declarations at: #_var2) equals: #'var1 *_var2'.

	self assert: method args isEmpty
]
