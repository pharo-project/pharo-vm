Class {
	#name : 'MockVMStructWithoutTypeDeclarations',
	#superclass : 'VMStructType',
	#instVars : [
		'foo',
		'bar'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'enumerating' }
MockVMStructWithoutTypeDeclarations class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"Missing the bar type declaration"
	
	aBinaryBlock value: 'foo' value: 'char *'
]
