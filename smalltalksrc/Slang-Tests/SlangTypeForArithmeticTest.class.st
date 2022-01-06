Class {
	#name : #SlangTypeForArithmeticTest,
	#superclass : #SlangAbstractTestCase,
	#instVars : [
		'visitor',
		'propertyName'
	],
	#category : #'Slang-Tests'
}

{ #category : #running }
SlangTypeForArithmeticTest >> setUp [
	super setUp.
	ccg addClass: SlangTypeForDereferenceTestClass.
	ccg inferTypes.
]

{ #category : #tests }
SlangTypeForArithmeticTest >> testAtOnMatrix [
	| tMethod |
	tMethod := ccg methodNamed: #aMethodReturningAnAtOnAMatrix.
	
	self assert: tMethod isNotNil.
	self assert: (ccg typeFor: tMethod statements first expression in: tMethod) equals: #'int *'."at: node"
	self assert: (ccg typeFor: tMethod statements first in: tMethod) equals: #'int *'."returnNode"
	
	self assertReturnTypeOf: tMethod equalsHarmonized: #'int *'
]
