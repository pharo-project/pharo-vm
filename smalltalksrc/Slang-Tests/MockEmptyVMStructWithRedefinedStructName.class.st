Class {
	#name : #MockEmptyVMStructWithRedefinedStructName,
	#superclass : #SlangStructType,
	#category : #'Slang-Tests'
}

{ #category : #enumerating }
MockEmptyVMStructWithRedefinedStructName class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	"Nothing, no fields"
]

{ #category : #enumerating }
MockEmptyVMStructWithRedefinedStructName class >> structTypeName [
	"Provide the typedef name.  Subclases can override."
	^ 'RedefinedStruct'
]
