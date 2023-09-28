Class {
	#name : 'MockVMStructWithReservedWords',
	#superclass : 'VMStructType',
	#instVars : [
		'foo',
		'case'
	],
	#category : 'VMMakerTests',
	#package : 'VMMakerTests'
}

{ #category : 'enumerating' }
MockVMStructWithReservedWords class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	
	aBinaryBlock value: 'foo' value: 'char *'.
	aBinaryBlock value: 'case' value: 'char *'
]

{ #category : 'accessing' }
MockVMStructWithReservedWords >> case [

	^ case
]

{ #category : 'accessing' }
MockVMStructWithReservedWords >> case: anObject [

	case := anObject
]
