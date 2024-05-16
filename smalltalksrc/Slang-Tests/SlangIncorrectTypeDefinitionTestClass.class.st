Class {
	#name : #SlangIncorrectTypeDefinitionTestClass,
	#superclass : #SlangClass,
	#category : #'Slang-Tests'
}

{ #category : #experiments }
SlangIncorrectTypeDefinitionTestClass >> typeDeclarationOfNoExistingVariable [
	<var: #x type: #int>
	| theX |
	^ theX 
	 

]

{ #category : #experiments }
SlangIncorrectTypeDefinitionTestClass >> typeDeclarationOfNoExistingVariableAndACorrectOne [
	<var: #x type: #int>
	<var: #theX type: #'long long'>
	| theX |
	^ theX 

]

{ #category : #experiments }
SlangIncorrectTypeDefinitionTestClass >> typeDeclarationOfTwoNoExistingVariablesAndACorrectOne [
	<var: #x type: #int>
	<var: #y type: #int>
	<var: #theX type: #'long long'>
	| theX |
	^ theX 

]
