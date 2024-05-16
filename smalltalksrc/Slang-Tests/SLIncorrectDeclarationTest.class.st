Class {
	#name : #SLIncorrectDeclarationTest,
	#superclass : #SlangAbstractTestCase,
	#category : #'Slang-Tests'
}

{ #category : #running }
SLIncorrectDeclarationTest >> setUp [ 
	super setUp.
	ccg addClass: SlangIncorrectTypeDefinitionTestClass.
	ccg inferTypes.
]

{ #category : #tests }
SLIncorrectDeclarationTest >> testTypeDeclarationOfNoExistingVariable [
	"default to int and produce an error in Transcript"
	| tMethod |
	tMethod := ccg methodNamed: #typeDeclarationOfNoExistingVariable.
	
	self assert: tMethod isNotNil.
	self assert: (ccg typeFor: tMethod statements first in: tMethod) equals: #sqInt.
	self assert: tMethod returnType equals: #sqInt
	
	
]

{ #category : #tests }
SLIncorrectDeclarationTest >> testTypeDeclarationOfNoExistingVariableAndACorrectOne [
	"work and produce an error in Transcript"
	| tMethod |
	tMethod := ccg methodNamed: #typeDeclarationOfNoExistingVariableAndACorrectOne.
	self assert: tMethod isNotNil.
	self assert: (ccg typeFor: tMethod statements first in: tMethod) equals: #'long long'.
	self assert: tMethod returnType equals: #sqLong
	
	
]

{ #category : #tests }
SLIncorrectDeclarationTest >> testTypeDeclarationOfTwoNoExistingVariablesAndACorrectOne [
	"work and produce an error in Transcript"
	| tMethod |
	tMethod := ccg methodNamed: #typeDeclarationOfTwoNoExistingVariablesAndACorrectOne.
	self assert: tMethod isNotNil.
	self assert: (ccg typeFor: tMethod statements first in: tMethod) equals: #'long long'.
	self assert: tMethod returnType equals: #sqLong
	
	
]
