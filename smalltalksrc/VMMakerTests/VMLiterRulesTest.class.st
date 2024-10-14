Class {
	#name : 'VMLiterRulesTest',
	#superclass : 'TestCase',
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'tests' }
VMLiterRulesTest >> testSlangRedundantTypeDeclaration [

	| ast |
	ast := self class compiler parse:
		       'testMethod <var:#aVar type: #aType>'.
	self assert:
		(ReSlangRedundantTypeDeclarationRule new basicCheck:
			 ast pragmas first).
	ast := self class compiler parse:
		       'testMethod <var:#aVar declareC: #aDeclaration>'.
	self assert:
		(ReSlangRedundantTypeDeclarationRule new basicCheck:
			 ast pragmas first).
]

{ #category : 'tests' }
VMLiterRulesTest >> testSlangTypeDeclarationForArgument [

	| ast |
	ast := self class compiler parse:
		       'testMethod: anArg <var:#anArg declareC: #aDeclaration>'.
	self deny:
		(ReSlangRedundantTypeDeclarationRule new basicCheck:
			 ast pragmas first)
]

{ #category : 'tests' }
VMLiterRulesTest >> testSlangTypeDeclarationForVariable [

	| ast |
	ast := self class compiler parse:
		       'testMethod <var:#aVar declareC: #aDeclaration> | aVar |'.
	self deny:
		(ReSlangRedundantTypeDeclarationRule new basicCheck:
			 ast pragmas first)
]
