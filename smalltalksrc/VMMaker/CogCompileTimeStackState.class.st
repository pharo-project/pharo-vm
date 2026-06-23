Class {
	#name : 'CogCompileTimeStackState',
	#superclass : 'VMStructType',
	#instVars : [
		'simStack',
		'simStackPtr',
		'simSpillBase'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'translation' }
CogCompileTimeStackState class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"Enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeFixup struct."

	"self withAllSubclasses collect: [:ea| ea typedef]"

	self filteredInstVarNames do: [ :ivn |
		aBinaryBlock value: ivn value: (ivn first ~= $# ifTrue: [
				 ivn caseOf: {
						 ([ 'simStack' ] -> [ {'SimStackEntry' .'[' , StackToRegisterMappingCogit simStackSlots asString , ']'} ]).
						 ([ 'simStackPtr' ] -> [ #'unsigned char' ]).
						 ([ 'simSpillBase' ] -> [ #'unsigned char' ]) } ]) ]
]

{ #category : 'accessing' }
CogCompileTimeStackState >> printSimStack: aSimStack toDepth: limit spillBase: spillBase on: aStream [

	<doNotGenerate>
	aStream newLine.
	limit < 0 ifTrue: [
		^ aStream
			  nextPutAll: 'simStackEmpty';
			  cr;
			  flush ].
	aSimStack ifNil: [
		^ aStream
			  nextPutAll: 'nil simStack';
			  cr;
			  flush ].
	0 to: limit do: [ :i |
		aStream print: i.
		i = simStackPtr ifTrue: [ aStream nextPutAll: '<-' ].
		i = spillBase ifTrue: [ aStream nextPutAll: '(sb)' ].
		aStream tab: (i = spillBase
				 ifTrue: [ 1 ]
				 ifFalse: [ 2 ]).
		aStream
			cr;
			flush ].
	simSpillBase > limit ifTrue: [
		aStream
			nextPutAll: '(sb: ';
			print: simSpillBase;
			nextPut: $);
			cr;
			flush ]
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simSpillBase [

	^ simSpillBase
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simSpillBase: anObject [

	simSpillBase := anObject
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStack [

	^ simStack
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStack: anObject [

	simStack := anObject
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackAt: index [
	<returnTypeC: #'CogSimStackEntry *'>
	^self addressOf: (simStack at: index)
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackAt: index put: simStackEntry [

	<var: #simStackEntry type: #SimStackEntry>
	simStack at: index put: simStackEntry
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackDescriptorAt: index [

	<returnTypeC: #SimStackEntry>
	^ simStack at: index
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackPrintString [
	<doNotGenerate>
	^String streamContents: [:s| self printSimStack: simStack toDepth: simStackPtr spillBase: simSpillBase on: s]
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackPtr [

	^ simStackPtr
]

{ #category : 'accessing' }
CogCompileTimeStackState >> simStackPtr: anObject [

	simStackPtr := anObject
]

{ #category : 'accessing' }
CogCompileTimeStackState >> ssTop [
	<returnTypeC: #'CogSimStackEntry *'>
	^self simStackAt: simStackPtr
]

{ #category : 'accessing' }
CogCompileTimeStackState >> ssTopDescriptor [

	<returnTypeC: #SimStackEntry>
	<inline: true>
	^ self simStackDescriptorAt: simStackPtr
]
