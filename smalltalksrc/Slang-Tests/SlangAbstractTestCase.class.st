Class {
	#name : #SlangAbstractTestCase,
	#superclass : #TestCase,
	#instVars : [
		'ccg'
	],
	#category : #'Slang-Tests'
}

{ #category : #running }
SlangAbstractTestCase >> setUp [
	super setUp.
	ccg := MLVMCCodeGenerator new.
	ccg vmMaker: VMMaker new.
	ccg vmMaker vmmakerConfiguration: VMMakerConfiguration.
]
