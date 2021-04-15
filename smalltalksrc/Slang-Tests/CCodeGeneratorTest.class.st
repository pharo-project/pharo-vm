"
A CCodeGeneratorTest is a test class for testing the behavior of CCodeGenerator
"
Class {
	#name : #CCodeGeneratorTest,
	#superclass : #TestCase,
	#category : #'Slang-Tests-CodeGeneration'
}

{ #category : #test }
CCodeGeneratorTest >> testNilOrBooleanConstantReceiverOf [

	self flag: #toImplement.
	self assert: false
]
