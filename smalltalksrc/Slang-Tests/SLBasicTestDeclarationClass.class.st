Class {
	#name : 'SLBasicTestDeclarationClass',
	#superclass : 'SlangClass',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithBlockLocalDeclaration [

	"var does not exist"
	<var: 'var' type: 'toto'>
	[ | var | 1+2 ] value
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithLocal [

	| var |
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithLocalWithDeclaration [

	<var: 'var' type: 'toto'>
	| var |
]

{ #category : 'as yet unclassified' }
SLBasicTestDeclarationClass >> methodWithNonExistingLocalDeclaration [

	"var does not exist"
	<var: 'var' type: 'toto'>
]
