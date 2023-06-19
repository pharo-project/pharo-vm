"
I am a class that helps organize the StackInterpreter's collection of stack pages.  I represent the control block for a single stack page in the collection of stack pages represented by an InterpreterStackPages or CoInterpreterStackPages instance.
"
Class {
	#name : #VMStackPage,
	#superclass : #VMStructType,
	#instVars : [
		'stackLimit',
		'headSP',
		'headFP',
		'baseFP',
		'baseAddress',
		'realStackLimit',
		'lastAddress',
		'trace',
		'padToWord',
		'nextPage',
		'prevPage'
	],
	#pools : [
		'VMBasicConstants',
		'VMBytecodeConstants'
	],
	#category : #'VMMaker-Interpreter'
}

{ #category : #translation }
VMStackPage class >> alignedByteSize [
	^self surrogateClass alignedByteSize
]

{ #category : #translation }
VMStackPage class >> alignedByteSizeOf: anObject forClient: aVMClass [
	^self surrogateClass alignedByteSize
]

{ #category : #'code generation' }
VMStackPage class >> getter: getter bitPosition: bitPosition bitWidth: bitWidth type: typeOrNil [
	^String streamContents:
		[:s| | startByte endByte accessor |
		startByte := bitPosition // 8.
		endByte := bitPosition + bitWidth - 1 // 8.
		self assert: bitPosition \\ 8 = 0.

		accessor := #('byte' 'short' 'long32' 'long32')
							at: endByte - startByte + 1
							ifAbsent: ['long64'].
		s	nextPutAll: getter; crtab: 1; nextPut: $^.
		(typeOrNil notNil and: [typeOrNil last = $*]) ifTrue:
			[accessor := 'unsigned', (accessor copy
										at: 1 put: accessor first asUppercase;
										yourself)].
		(typeOrNil notNil and: ['*StackPage*' match: typeOrNil]) ifTrue:
			[s nextPutAll: 'stackPages surrogateAtAddress: ('].
		s nextPutAll: 'memory ';
		   nextPutAll: accessor;
		   nextPutAll: 'At: address + '; print: startByte.
		(typeOrNil notNil and: ['*StackPage*' match: typeOrNil]) ifTrue:
			[s nextPut: $)]]

	"| bitPosition |
	bitPosition := 0.
	(self fieldAccessorsForBytesPerWord: 4) collect:
		[:spec|
		bitPosition := bitPosition + spec second.
		self getter: spec first
			 bitPosition: bitPosition - spec second
			 bitWidth: spec second
			 type: (spec at: 3 ifAbsent: [])]"
]

{ #category : #translation }
VMStackPage class >> initialize [
	"self initialize"
	(Smalltalk classNamed: #VMStackPageSurrogate32) ifNotNil:
		[:csps32|
		self checkGenerateSurrogate: csps32 bytesPerWord: 4].
	(Smalltalk classNamed: #VMStackPageSurrogate64) ifNotNil:
		[:csps64|
		self checkGenerateSurrogate: csps64 bytesPerWord: 8]
]

{ #category : #translation }
VMStackPage class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a StackPage struct."

	self allInstVarNames do:
		[:ivn|
		(ivn = 'padToWord' and: [BytesPerWord = 4]) ifFalse:
			[aBinaryBlock
				value: ivn
				value: ((ivn = 'trace' or: [ivn = 'padToWord'])
						ifTrue: [#int]
						ifFalse:
							[(ivn endsWith: 'Page')
								ifTrue: ['struct _StackPage *']
								ifFalse: [#'char *']])]]
]

{ #category : #'code generation' }
VMStackPage class >> setter: getter bitPosition: bitPosition bitWidth: bitWidth type: typeOrNil [
	^String streamContents:
		[:s| | startByte endByte accessor |
		startByte := bitPosition // 8.
		endByte := bitPosition + bitWidth - 1 // 8.
		self assert: bitPosition \\ 8 = 0.

		accessor := #('byte' 'short' 'long32' 'long32')
							at: endByte - startByte + 1
							ifAbsent: ['long64'].
		s	nextPutAll: getter; nextPutAll: ': aValue'; crtab: 1;
			nextPutAll: 'self assert: (address + '; print: startByte;
			nextPutAll: ' >= zoneBase and: [address + '; print: endByte;
			nextPutAll: ' < zoneLimit]).'; crtab: 1.
		(typeOrNil notNil and: [typeOrNil last = $*]) ifTrue:
			[accessor := 'unsigned', (accessor copy
										at: 1 put: accessor first asUppercase;
										yourself)].
		(typeOrNil notNil and: ['*StackPage*' match: typeOrNil]) ifFalse:
			[s nextPut: $^].
		s nextPutAll: 'memory ';
		   nextPutAll: accessor; nextPutAll: 'At: address + '; print: startByte;
		   nextPutAll: ' put: aValue'.
		(typeOrNil notNil and: ['*StackPage*' match: typeOrNil]) ifTrue:
			[s nextPutAll: ' asInteger.'; crtab: 1; nextPutAll: '^aValue']]

	"| bitPosition |
	bitPosition := 0.
	(self fieldAccessorsForBytesPerWord: 4) collect:
		[:spec|
		bitPosition := bitPosition + spec second.
		self setter: spec first
			 bitPosition: bitPosition - spec second
			 bitWidth: spec second
			 type: (spec at: 3 ifAbsent: [])]"
]

{ #category : #translation }
VMStackPage class >> structTypeName [
	^'StackPage' "Drop initial Cog or Interpreter"
]

{ #category : #'simulation only' }
VMStackPage class >> surrogateClass [
	^BytesPerWord = 4
		ifTrue: [VMStackPageSurrogate32]
		ifFalse: [VMStackPageSurrogate64]
]

{ #category : #'simulation only' }
VMStackPage >> address [
	<doNotGenerate>
	^baseAddress
]

{ #category : #testing }
VMStackPage >> addressIsInPage: address [
	<var: #address type: #'char *'>
	"For assert-checking"
	^lastAddress < address and: [address < baseAddress]
]

{ #category : #accessing }
VMStackPage >> baseAddress [
	^baseAddress
]

{ #category : #accessing }
VMStackPage >> baseAddress: anAddress [
	^baseAddress := anAddress
]

{ #category : #accessing }
VMStackPage >> baseFP [
	"Answer the value of baseFP"

	^ baseFP
]

{ #category : #accessing }
VMStackPage >> baseFP: pointer [ "<Integer>"
	"Set the value of baseFP"
	self assert: (pointer = 0 or: [pointer < baseAddress and: [realStackLimit < pointer]]).
	^baseFP := pointer
]

{ #category : #accessing }
VMStackPage >> headFP [
	"Answer the value of headFP"

	^headFP
]

{ #category : #accessing }
VMStackPage >> headFP: pointer [ "<Integer>"
	"Set the value of headFP"
	^headFP := pointer
]

{ #category : #accessing }
VMStackPage >> headSP [
	"Answer the value of headSP"

	^headSP
]

{ #category : #accessing }
VMStackPage >> headSP: pointer [ "<Integer>"
	"Set the value of headSP"
	^headSP := pointer
]

{ #category : #testing }
VMStackPage >> isFree [
	^baseFP = 0
]

{ #category : #accessing }
VMStackPage >> lastAddress [
	^lastAddress
]

{ #category : #accessing }
VMStackPage >> lastAddress: anAddress [
	^lastAddress := anAddress
]

{ #category : #accessing }
VMStackPage >> nextPage [
	"Answer the value of nextPage"

	^ nextPage
]

{ #category : #accessing }
VMStackPage >> nextPage: anObject [
	"Set the value of nextPage"

	^nextPage := anObject
]

{ #category : #accessing }
VMStackPage >> prevPage [
	"Answer the value of prevPage"

	^ prevPage
]

{ #category : #accessing }
VMStackPage >> prevPage: anObject [
	"Set the value of prevPage"

	^prevPage := anObject
]

{ #category : #printing }
VMStackPage >> printOn: aStream [
	<doNotGenerate>
	super printOn: aStream.
	aStream nextPut: $@; print: baseAddress; space.
	self isFree
		ifTrue: [aStream nextPutAll: 'free']
		ifFalse: [aStream print: baseFP; nextPutAll: '<->'; print: headFP; space; nextPutAll: 'trace '; print: trace]
]

{ #category : #accessing }
VMStackPage >> realStackLimit [
	"Answer the value of realStackLimit"

	^ realStackLimit
]

{ #category : #accessing }
VMStackPage >> realStackLimit: anObject [
	"Set the value of realStackLimit"

	^realStackLimit := anObject
]

{ #category : #accessing }
VMStackPage >> stackLimit [
	"Answer the value of stackLimit"

	^ stackLimit
]

{ #category : #accessing }
VMStackPage >> stackLimit: anObject [
	"Set the value of stackLimit"

	^stackLimit := anObject
]

{ #category : #accessing }
VMStackPage >> trace [
	"Answer the page's trace state.
	 0 = untraced.  1 = should be traced. 2 = has been traced.
	-1 = invalid (for assertions)"
	^trace
]

{ #category : #accessing }
VMStackPage >> trace: anInteger [
	"Set the page's trace state.
	 0 = untraced.  1 = should be traced. 2 = has been traced.
	-1 = invalid (for assertions)"
	^trace := anInteger
]
