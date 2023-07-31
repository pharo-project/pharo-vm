Class {
	#name : #VMLiterRulesTest,
	#superclass : #TestCase,
	#category : #VMMakerTests
}

{ #category : #tests }
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

	ast := self class compiler parse:
		       'testMethod <var:#aVar declareC: #aDeclaration> | aVar |'.
	self deny:
		(ReSlangRedundantTypeDeclarationRule new basicCheck:
			 ast pragmas first)
]
