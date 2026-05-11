Class {
	#name : 'SLASTTransformationTestClass',
	#superclass : 'SlangClass',
	#instVars : [
		'something'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLASTTransformationTestClass >> emptyMethod [
]

{ #category : 'helpers' }
SLASTTransformationTestClass >> emptyMethod: arg [ 
]

{ #category : 'helpers' }
SLASTTransformationTestClass >> f: string printf: args [

	
]

{ #category : 'send-transformation' }
SLASTTransformationTestClass >> methodWithBlockValue [

	[ :arg | arg + 1 ] value: 2
]

{ #category : 'send-transformation' }
SLASTTransformationTestClass >> methodWithBlockValueValue [

	[ :arg1 :arg2 | arg1 + arg2 ] value: 2 value: 3
]

{ #category : 'assignment-transformation' }
SLASTTransformationTestClass >> methodWithBockInAssignment [

	| var |
	var := [
	       self emptyMethod.
	       5 ]
]

{ #category : 'assignment-transformation' }
SLASTTransformationTestClass >> methodWithBockValueInAssignment [

	| var |
	var := [ :arg |
	       self emptyMethod: arg.
	       5 ] value: 1
]

{ #category : 'assignment-transformation' }
SLASTTransformationTestClass >> methodWithBockValueValueInAssignment [

	| var |
	var := [ :arg1 :arg2 |
	       self emptyMethod: arg1.
	       self emptyMethod: arg2.
	       5 ] value: 1 value: 2
]

{ #category : 'send-transformation' }
SLASTTransformationTestClass >> methodWithFPrintF [ 
	something f: '%d %d %d %d %d %d'
		printf:{	1. 2. 3. 4. 5. 6 }.
]
