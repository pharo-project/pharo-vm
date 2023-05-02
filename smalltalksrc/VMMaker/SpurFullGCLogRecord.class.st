Class {
	#name : #SpurFullGCLogRecord,
	#superclass : #VMStructType,
	#instVars : [
		'fullGCs',
		'fullUsecs',
		'compactionUsecs',
		'sweepUsecs',
		'markUsecs'
	],
	#category : #'VMMaker-SpurMemoryManager'
}

{ #category : #enumerating }
SpurFullGCLogRecord class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	self allInstVarNames do:
		[:ivn|
		(SpurMemoryManager isNonArgumentImplicitReceiverVariableName: ivn) ifFalse:
			[aBinaryBlock value: ivn value: #usqInt]]
]

{ #category : #accessing }
SpurFullGCLogRecord >> compactionUsecs [

	^ compactionUsecs
]

{ #category : #accessing }
SpurFullGCLogRecord >> compactionUsecs: anObject [

	compactionUsecs := anObject
]

{ #category : #accessing }
SpurFullGCLogRecord >> fullGCs [

	^ fullGCs
]

{ #category : #accessing }
SpurFullGCLogRecord >> fullGCs: anObject [

	fullGCs := anObject
]

{ #category : #accessing }
SpurFullGCLogRecord >> fullUsecs [

	^ fullUsecs
]

{ #category : #accessing }
SpurFullGCLogRecord >> fullUsecs: anObject [

	fullUsecs := anObject
]

{ #category : #accessing }
SpurFullGCLogRecord >> markUsecs [

	^ markUsecs
]

{ #category : #accessing }
SpurFullGCLogRecord >> markUsecs: anObject [

	markUsecs := anObject
]

{ #category : #accessing }
SpurFullGCLogRecord >> sweepUsecs [

	^ sweepUsecs
]

{ #category : #accessing }
SpurFullGCLogRecord >> sweepUsecs: anObject [

	sweepUsecs := anObject
]
