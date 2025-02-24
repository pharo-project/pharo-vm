Class {
	#name : 'SLNormalizeVariablesTestClass',
	#superclass : 'SlangClass',
	#instVars : [
		'instanceVariable1',
		'instanceVariable2'
	],
	#classVars : [
		'ConstantWithNoReplacement',
		'ConstantWithReplacementShouldBeGenerated',
		'ConstantWithReplacementShouldNotBeGenerated'
	],
	#pools : [
		'SLNormalizeVariablesTestSharedPoolClass'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'initialization' }
SLNormalizeVariablesTestClass class >> initializeGlobals [

	ConstantWithReplacementShouldBeGenerated := #replacement.
	ConstantWithReplacementShouldNotBeGenerated := '#should not be seen'.
	ConstantFromPoolWithReplacementShouldBeGenerated := #'replacement from pool'.
	ConstantFromPoolWithReplacementShouldNotBeGenerated := #'should not be seen'
]

{ #category : 'helpers' }
SLNormalizeVariablesTestClass >> emptyMethod: arg [ 
]

{ #category : 'methods-referencing-struct-classes' }
SLNormalizeVariablesTestClass >> methodReferencingStructClass [
	SLNormalizeVariablesTestStructClass
]

{ #category : 'methods-with-globals-variables' }
SLNormalizeVariablesTestClass >> methodWithInstancesVariables [

	instanceVariable1.
	instanceVariable2
]

{ #category : 'methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithReservedArgumentsName: cascade arg: arg1 [

	self emptyMethod: self.
	self emptyMethod: super.
	self emptyMethod: cascade.
	self emptyMethod: arg1
]

{ #category : 'methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithReservedLocalsName [

	<var: #var1 type: #implicit>
	| cascade var1 var2 self_in_methodWithReservedLocalsName interpreterProxy |
	self.
	"would be generated if SLNormalizeVariablesTestClass was a subclass of SlangStructType, here we simulate it to simplify all the other test"
	self_in_methodWithReservedLocalsName.
	super.
	cascade.
	"reserved name for MLVMCCodeGenerator"
	interpreterProxy.
	var1.
	var2
]

{ #category : 'methods-with-globals-variables' }
SLNormalizeVariablesTestClass >> methodWithSharedVariables [ 
	ConstantWithNoReplacement. 
	ConstantWithReplacementShouldBeGenerated.
	ConstantWithReplacementShouldNotBeGenerated.
]

{ #category : 'methods-with-unused-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUnusedArguments: arg1 arg: arg2 [

	
]

{ #category : 'methods-with-unused-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUnusedLocals [

	| var1 var2 |
	
]

{ #category : 'methods-with-unused-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUsedAndUnusedArguments: arg1 arg: arg2 [

	arg1
]

{ #category : 'methods-with-unused-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUsedAndUnusedLocals [

	| var1 var2 |
	var2.
]

{ #category : 'methods-with-unused-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUsedAndUnusedLocalsAndArguments: arg1 arg: arg2 [

	| var1 var2 |
	var2.
	arg2
]

{ #category : 'methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUsedArguments: arg1 arg: arg2 [

	self emptyMethod: arg1.
	self emptyMethod: (self emptyMethod: arg2).
	self emptyMethod: [ :arg3 | arg3 ]
]

{ #category : 'methods-with-used-locals-and-arguments' }
SLNormalizeVariablesTestClass >> methodWithUsedLocals [

	| var1 var2 |
	var1.
	var2.
	[
	| var3 var4 |
	var3.
	var4.
	[
	| var5 var6 |
	var5.
	var6 ] ]
]

{ #category : 'methods-with-globals-variables' }
SLNormalizeVariablesTestClass >> methodWithVariablesFromSharedPools [

	ConstantFromPoolWithNoReplacement.
	ConstantFromPoolWithReplacementShouldBeGenerated.
	ConstantFromPoolWithReplacementShouldNotBeGenerated
]

{ #category : 'methods-with-variables-in-cCode' }
SLNormalizeVariablesTestClass >> methodWithVariablesInCCode [

	| var1 var2 |
	self cCode: 'var1 *var2'.
	self cCode: 'var2 *var1' inSmalltalk: [
		var1.
		var2 ]
]

{ #category : 'methods-with-variables-in-cCode' }
SLNormalizeVariablesTestClass >> methodWithVariablesInCCodePrint [
	"same case as printMethodCacheFor:, we have to be careful of n and s"

	| n s |
	self cCode:
		'vm_printf("%" PRIxSQPTR " %.*s\n", s, (int)(numBytesOf(s)), (char *)firstIndexableField(s))'.
	n.
	s
]

{ #category : 'methods-with-var-return-type-C' }
SLNormalizeVariablesTestClass >> methodWithVariablesInVarReturnTypeC [

	<returnTypeC: #'var1 *'>
	| var1 |
	var1
]

{ #category : 'methods-with-var-type-declaration' }
SLNormalizeVariablesTestClass >> methodWithVariablesInVarTypeDeclaration [

	<var: #var1 type: #'char *'>
	<var: #var2 type: #'var1 *'>
	| var1 var2 |
	var1.
	var2
]
