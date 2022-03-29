Class {
	#name : #ComposedSegmentMetadataStruct,
	#superclass : #VMStructType,
	#instVars : [
		'segStart',
		'segSize'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'simulation only' }
ComposedSegmentMetadataStruct class >> byteSizeForSimulator: aCogit [

	"Answer an approximation of the byte size of an AbstractInstruction struct.
	 This is for estimating the alloca in allocateOpcodes:bytecodes:ifFail:"
	^self instSize * (aCogit sizeof: #'void *'). 
]

{ #category : #translation }
ComposedSegmentMetadataStruct class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a struct of this type."

	<var: #segSize type: #size_t>
	<var: #segStart type: #squeakFileOffsetType>

	aBinaryBlock
		value: 'segSize' value:'size_t';
		value: 'segStart' value:'squeakFileOffsetType'.
	

]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segSize [

	^ segSize
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segSize: anInt [

	segSize := anInt
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segStart [

	^ segStart
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segStart: anInt [

	segStart := anInt
]
