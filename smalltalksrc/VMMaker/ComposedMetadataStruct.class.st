Class {
	#name : #ComposedMetadataStruct,
	#superclass : #VMStructType,
	#instVars : [
		'startAddress',
		'dataSize'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'simulation only' }
ComposedMetadataStruct class >> byteSizeForSimulator: aCogit [

	"Answer an approximation of the byte size of an AbstractInstruction struct.
	 This is for estimating the alloca in allocateOpcodes:bytecodes:ifFail:"
	^self instSize * (aCogit sizeof: #'void *'). 
]

{ #category : #translation }
ComposedMetadataStruct class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a struct of this type."

	<var: #segSize type: #size_t>
	<var: #segStart type: #squeakFileOffsetType>

	aBinaryBlock
		value: 'segSize' value:'size_t';
		value: 'segStart' value:'squeakFileOffsetType'.
	

]

{ #category : #accessing }
ComposedMetadataStruct >> dataSize [

	^ dataSize
]

{ #category : #accessing }
ComposedMetadataStruct >> dataSize: anObject [

	dataSize := anObject
]

{ #category : #accessing }
ComposedMetadataStruct >> startAddress [

	^ startAddress
]

{ #category : #accessing }
ComposedMetadataStruct >> startAddress: anObject [

	startAddress := anObject
]
