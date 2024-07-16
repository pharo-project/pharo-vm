"
Basic tests for the type inference used in CCodeGenerator.
Support methods are in SlangTypeInferenceTestClass.
There is only one possible type by node, no ambiguities.

1 Constant
	test constantNode in a method.
	tests are tailor made for the current TConstantNode >> #typeOrNilFrom:in:.

2 Return-constant
	test return a constant node in a method.
	uses the previous categorie's values.

3 Return-temp-assigned-constant
	assign a temporary node with a constant
	then returns the temporary variable in the next statement.
	
4 Return-temp-assigned-message
	assign a temporary node with a message
	then returns the temporary variable in the next statement.
	
5 Return-explicit-temp
	returns a temporary typed by a pragma #var:type:.

6 Return-explicit-arg
	returns an argument typed by a pragma #var:type:.
"
Class {
	#name : 'SlangBasicTypeInferenceTest',
	#superclass : 'SlangAbstractTestCase',
	#instVars : [
		'conflictException'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testABigNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aBigNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aBigNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAFalseConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aFalseConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aFalseConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAFloatConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aFloatConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aFloatConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testANilConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aNilConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aNilConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testASmallNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aSmallNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aSmallNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAStringConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aStringConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aStringConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testATrueConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #aTrueConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #aTrueConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAnIntEqual32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #anIntEqual32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #anIntEqual32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAnIntEqual64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #anIntEqual64ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #anIntEqual64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned long long'
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAnIntGreater64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #anIntGreater64ConstantNode.
	ccg inferTypes.

	tMethod := ccg methodNamed: #anIntGreater64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'
]

{ #category : 'constant' }
SlangBasicTypeInferenceTest >> testAnIntLess32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #anIntLesser32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #anIntLesser32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnABigNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnABigNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnABigNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'.
	self assert: tMethod returnType equals: #sqLong
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnABigNegativeIntegerMessageSend [

	| tMethod |
		ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnABigNegativeIntegerConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnABigNegativeIntegerMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnABigNegativeIntegerMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqLong.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqLong.
	self assert: tMethod returnType equals: #sqLong
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAFalseConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFalseConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAFalseConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAFalseMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFalseConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFalseMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAFalseMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-float' }
SlangBasicTypeInferenceTest >> testReturnAFloat [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloat.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAFloat.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAFloatMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloatConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloatMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAFloatMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-signed' }
SlangBasicTypeInferenceTest >> testReturnANegativeNumber [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnANegativeNumber.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnANegativeNumber.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnANilConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnANilConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnANilConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnANilMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnANilConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnANilMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnANilMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnASmallNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnASmallNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnASmallNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnASmallNegativeIntegerMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnASmallNegativeIntegerConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnASmallNegativeIntegerMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnASmallNegativeIntegerMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAStringConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAStringConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAStringConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAStringMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAStringConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAStringMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAStringMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #'char *'.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnATrueConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnATrueConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnATrueConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnATrueMessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnATrueConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnATrueMessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnATrueMessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAnIntEqual32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntEqual32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAnIntEqual32MessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual32ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual32MessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntEqual32MessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAnIntEqual64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual64ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntEqual64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned long long'.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAnIntEqual64MessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual64ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual64MessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntEqual64MessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAnIntGreater64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntGreater64ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntGreater64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAnIntGreater64MessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntGreater64ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntGreater64MessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntGreater64MessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnAnIntLess32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntLesser32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntLesser32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-message-send' }
SlangBasicTypeInferenceTest >> testReturnAnIntLesser32MessageSend [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntLesser32ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntLesser32MessageSend.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAnIntLesser32MessageSend.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgDouble [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgDouble:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgDouble:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgFloat [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgFloat:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgFloat:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #float.
	self assert: tMethod returnType equals: #float
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgInt [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgInt:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgInt:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgLongLong [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgLongLong:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgLongLong:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'.
	self assert: tMethod returnType equals: #sqLong
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgRandom [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgRandom:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgRandom:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #completelyRandom.
	self assert: tMethod returnType equals: #completelyRandom
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgString [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgString:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgString:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgUnsignedInt [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgUnsignedInt:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgUnsignedInt:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-explicit-arg' }
SlangBasicTypeInferenceTest >> testReturnExplicitArgUnsignedLongLong [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitArgUnsignedLongLong:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitArgUnsignedLongLong:.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned long long'.
	self assert: tMethod returnType equals: #usqLong
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempDouble [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempDouble.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempDouble.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempFloat [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempFloat.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempFloat.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #float.
	self assert: tMethod returnType equals: #float
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempInt [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempInt.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempInt.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempLongLong [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempLongLong.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempLongLong.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'.
	self assert: tMethod returnType equals: #sqLong
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempRandom [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempRandom.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempRandom.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #completelyRandom.
	self assert: tMethod returnType equals: #completelyRandom
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempString [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempString.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempString.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempUnsignedInt [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempUnsignedInt.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempUnsignedInt.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-explicit-temp' }
SlangBasicTypeInferenceTest >> testReturnExplicitTempUnsignedLongLong [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnExplicitTempUnsignedLongLong.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnExplicitTempUnsignedLongLong.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned long long'.
	self assert: tMethod returnType equals: #usqLong
]

{ #category : 'return-constant' }
SlangBasicTypeInferenceTest >> testReturnFloatConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloatConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnAFloatConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-long-int' }
SlangBasicTypeInferenceTest >> testReturnLongIntInVariable [
	"the type is automatically determined, no need to annotate"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnLongIntInVariable.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnLongIntInVariable.

	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-long-int' }
SlangBasicTypeInferenceTest >> testReturnLongIntNotWorking [
	"doesn't check for type limit"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnLongInt.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnLongInt.

	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-long-int' }
SlangBasicTypeInferenceTest >> testReturnMultipleLongInt [
	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnMultipleLongInt.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnMultipleLongInt.
	
	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-long-int' }
SlangBasicTypeInferenceTest >> testReturnMultipleLongIntAnnotation [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnMultipleLongIntAnnotation:.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnMultipleLongIntAnnotation:.

	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-long-int' }
SlangBasicTypeInferenceTest >> testReturnMultipleLongIntNotWorking [
	"doesn't check for type limit"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnMultipleLongIntNotWorking.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnMultipleLongIntNotWorking.

	self assert: tMethod isNotNil.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-multiple-type' }
SlangBasicTypeInferenceTest >> testReturnStringAndIntIfTrue1 [
	"a conflict appear, the type are not harmonized"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnStringAndIntInIfTrue1.
	tMethod := ccg methodNamed: #returnStringAndIntInIfTrue1.
	self assert: tMethod isNotNil.
	self
		should: [ ccg inferTypes ]
		raise: SlangReturnTypeConflictException
		whoseDescriptionIncludes:
		'conflicting return types sqInt, char * in SlangBasicTypeInferenceTestClass >> returnStringAndIntInIfTrue1'
		description: 'Should get a conflict error with sqInt and char *'
]

{ #category : 'return-multiple-type' }
SlangBasicTypeInferenceTest >> testReturnStringAndIntIfTrue2 [
	"a conflict appear, the type are not harmonized"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnStringAndIntInIfTrue2.
	tMethod := ccg methodNamed: #returnStringAndIntInIfTrue2.
	self assert: tMethod isNotNil.
	self
		should: [ ccg inferTypes ]
		raise: SlangReturnTypeConflictException
		whoseDescriptionIncludes:
		'conflicting return types sqInt, char * in SlangBasicTypeInferenceTestClass >> returnStringAndIntInIfTrue2'
		description: 'Should get a conflict error with sqInt and char *'
]

{ #category : 'return-multiple-type' }
SlangBasicTypeInferenceTest >> testReturnStringAndIntInIfTrueifFalse1 [
	"a conflict appear, the type are not harmonized"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnStringAndIntInIfTrueifFalse1.
	tMethod := ccg methodNamed: #returnStringAndIntInIfTrueifFalse1.
	self assert: tMethod isNotNil.
	self
		should: [ ccg inferTypes ]
		raise: SlangReturnTypeConflictException
		whoseDescriptionIncludes:
		'conflicting return types sqInt, char * in SlangBasicTypeInferenceTestClass >> returnStringAndIntInIfTrueifFalse1'
		description: 'Should get a conflict error with sqInt and char *'
]

{ #category : 'return-multiple-type' }
SlangBasicTypeInferenceTest >> testReturnStringAndIntInIfTrueifFalse2 [
	"a conflict appear, the type are not harmonized"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnStringAndIntInIfTrueifFalse2.
	tMethod := ccg methodNamed: #returnStringAndIntInIfTrueifFalse2.
	self assert: tMethod isNotNil.
	self
		should: [ ccg inferTypes ]
		raise: SlangReturnTypeConflictException
		whoseDescriptionIncludes:
		'conflicting return types sqInt, char * in SlangBasicTypeInferenceTestClass >> returnStringAndIntInIfTrueifFalse2'
		description: 'Should get a conflict error with sqInt and char *'
]

{ #category : 'return-multiple-type' }
SlangBasicTypeInferenceTest >> testReturnStringAndIntInIfTrueifFalse3 [
	"a conflict appear, the type are not harmonized"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnStringAndIntInIfTrueifFalse3.
	tMethod := ccg methodNamed: #returnStringAndIntInIfTrueifFalse3.
	self assert: tMethod isNotNil.
	self
		should: [ ccg inferTypes ]
		raise: SlangReturnTypeConflictException
		whoseDescriptionIncludes:
		'conflicting return types sqInt, char * in SlangBasicTypeInferenceTestClass >> returnStringAndIntInIfTrueifFalse3'
		description: 'Should get a conflict error with sqInt and char *'
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempBigNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempBigNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempBigNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #'long long'. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'long long'. " variable, temporaryNode "
	self assertReturnTypeOf: tMethod equalsHarmonized: #'long long'
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempBigNegativeIntegerMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnABigNegativeIntegerConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempBigNegativeIntegerMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempBigNegativeIntegerMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqLong.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqLong.
	self assert: tMethod returnType equals: #sqLong
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempFalseConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempFalseConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempFalseConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #int. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #int. " variable, temporaryNode "

	self assertReturnTypeOf: tMethod equalsHarmonized: #int
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempFalseMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFalseConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempFalseMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempFalseMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempFloatConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempFloatConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempFloatConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #double. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #double. " variable, temporaryNode "
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempFloatMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloatConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAFloatMessageSend.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempFloatMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempFloatMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #double.
	self
		assert:
		(ccg typeFor: tMethod statements first expression in: tMethod)
		equals: #double.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #double.
	self assert: tMethod returnType equals: #double
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempIntEqual32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntEqual32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntEqual32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #'unsigned int'. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'unsigned int'. " variable, temporaryNode "
	self assertReturnTypeOf: tMethod equalsHarmonized: #'unsigned int'
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempIntEqual32MessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual32ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntEqual32MessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntEqual32MessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempIntEqual64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntEqual64ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntEqual64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned long long'. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #'unsigned long long'. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'unsigned long long'. " variable, temporaryNode "
	self
		assertReturnTypeOf: tMethod
		equalsHarmonized: #'unsigned long long'
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempIntEqual64MessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntEqual64ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntEqual64MessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntEqual64MessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempIntGreater64ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntGreater64ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntGreater64ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'long long'. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #'long long'. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'long long'. " variable, temporaryNode "
	self assertReturnTypeOf: tMethod equalsHarmonized: #'long long'
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempIntGreater64MessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntGreater64ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntGreater64MessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntGreater64MessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempIntLesser32ConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntLesser32ConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntLesser32ConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #int. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #int. " variable, temporaryNode "

	self assertReturnTypeOf: tMethod equalsHarmonized: #int
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempIntLesser32MessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAnIntLesser32ConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempIntLesser32MessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempIntLesser32MessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempNilConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempNilConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempNilConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #int. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #int. " variable, temporaryNode "

	self assertReturnTypeOf: tMethod equalsHarmonized: #int
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempNilMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnANilConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempNilMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempNilMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempSmallNegativeIntegerConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempSmallNegativeIntegerConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed:
		           #returnTempSmallNegativeIntegerConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #int. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #int. " variable, temporaryNode "

	self assertReturnTypeOf: tMethod equalsHarmonized: #int
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempSmallNegativeIntegerMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnASmallNegativeIntegerConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempSmallNegativeIntegerMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed:
		           #returnTempSmallNegativeIntegerMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempStringConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempStringConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempStringConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #'char *'. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'char *'. " variable, temporaryNode "
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempStringMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnAStringConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempStringMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempStringMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'char *'.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #'char *'.
	self assert: tMethod returnType equals: #'char *'
]

{ #category : 'return-temp-assigned-const' }
SlangBasicTypeInferenceTest >> testReturnTempTrueConstantNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempTrueConstantNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempTrueConstantNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int. " assignementNode "
	self
		assert: (ccg typeFor: tMethod statements first value in: tMethod)
		equals: #int. " value, constantNode "
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #int. " variable, temporaryNode "

	self assertReturnTypeOf: tMethod equalsHarmonized: #int
]

{ #category : 'return-temp-assigned-message' }
SlangBasicTypeInferenceTest >> testReturnTempTrueMessageNode [

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnATrueConstantNode.
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #returnTempTrueMessageNode.
	ccg inferTypes.
	tMethod := ccg methodNamed: #returnTempTrueMessageNode.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #sqInt.
	self
		assert: (ccg typeFor: tMethod statements first variable in: tMethod)
		equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
]

{ #category : 'return-signed' }
SlangBasicTypeInferenceTest >> testUnsignedIntInASignedExpressionNotWorking [
	"Slang will try to signed a variable if it is present in an iteration with a comparator (>,<,>=,<=) in its expression, here it does not work"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #unsignedIntInASignedOperationNotWorking.
	ccg inferTypes.
	tMethod := ccg methodNamed: #unsignedIntInASignedOperationNotWorking.

	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'.
	self assert: tMethod returnType equals: #usqInt
]

{ #category : 'return-signed' }
SlangBasicTypeInferenceTest >> testUnsignedIntInASignedOperation [
	"Slang will try to signed a variable if it is present in an iteration with a comparator (>,<,>=,<=) in its expression, here i is first automatically typed as unsigned int but change its type to int eventually (Slang doesn't check for type limit)"

	| tMethod |
	ccg
		addMethodFor: SlangBasicTypeInferenceTestClass
		selector: #unsignedIntInASignedOperation.
	tMethod := ccg methodNamed: #unsignedIntInASignedOperation.
	self assert: tMethod isNotNil.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #'unsigned int'.
	ccg inferTypes.
	self
		assert: (ccg typeFor: tMethod statements first in: tMethod)
		equals: #int.
	self assert: tMethod returnType equals: #sqInt
]
