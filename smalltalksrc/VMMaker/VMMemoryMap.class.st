Class {
	#name : #VMMemoryMap,
	#superclass : #VMStructType,
	#instVars : [
		'memoryManager',
		'oldSpaceStart',
		'oldSpaceEnd',
		'newSpaceStart',
		'newSpaceEnd'
	],
	#category : #'VMMaker-Memory'
}

{ #category : #translation }
VMMemoryMap class >> filteredInstVarNames [

	^ super filteredInstVarNames copyWithout: #memoryManager
]

{ #category : #translation }
VMMemoryMap class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :aName |
		aBinaryBlock value: aName value: #'usqInt'  ]
]

{ #category : #accessing }
VMMemoryMap >> memoryManager [

	^ memoryManager
]

{ #category : #accessing }
VMMemoryMap >> memoryManager: anObject [

	memoryManager := anObject
]

{ #category : #accessing }
VMMemoryMap >> newSpaceEnd [

	^ newSpaceEnd
]

{ #category : #accessing }
VMMemoryMap >> newSpaceEnd: anObject [

	newSpaceEnd := anObject
]

{ #category : #accessing }
VMMemoryMap >> newSpaceStart [

	^ newSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> newSpaceStart: anObject [

	newSpaceStart := anObject
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceEnd [
	^ oldSpaceEnd
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceEnd: anInteger [ 
	
	oldSpaceEnd := anInteger
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceStart [

	^ oldSpaceStart
]

{ #category : #accessing }
VMMemoryMap >> oldSpaceStart: anObject [

	oldSpaceStart := anObject
]
