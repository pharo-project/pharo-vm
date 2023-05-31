Class {
	#name : #MockVMStructWithoutTypeDeclarations,
	#superclass : #VMStructType,
	#instVars : [
		'foo',
		'bar'
	],
	#category : #'Slang-Tests'
}

{ #category : #enumerating }
MockVMStructWithoutTypeDeclarations class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"Missing the bar type declaration"
	
	aBinaryBlock value: 'foo' value: 'char *'
]
