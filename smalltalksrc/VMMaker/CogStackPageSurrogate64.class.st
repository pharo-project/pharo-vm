"
Here's a doit to generate most of my code:
	| offset crtab |
	offset := 1.
	crtab := String with: Character cr with: Character tab.
	CogStackPage instVarNamesAndTypesForTranslationDo:
		[:name :type| | isByte |
		isByte := type = 'unsigned char'.
		CogStackPageSurrogate64
			compile: name, crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongLongAt:']), ' address + ', offset printString
			classified: #accessing.
		CogStackPageSurrogate64
			compile: name, ': aValue', crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongLongAt:']), ' address + ', offset printString,
					' put: aValue'
			classified: #accessing.
		offset := offset + (isByte ifTrue: [1] ifFalse: [8])].
	CogStackPageSurrogate64 class compile: 'alignedByteSize', crtab, '^', (offset - 1 + 3 bitAnd: -4) printString classified: #'instance creation'

"
Class {
	#name : #CogStackPageSurrogate64,
	#superclass : #CogStackPageSurrogate,
	#category : #'VMMaker-JITSimulation'
}

{ #category : #accessing }
CogStackPageSurrogate64 class >> alignedByteSize [
	^80
]

{ #category : #accessing }
CogStackPageSurrogate64 >> baseAddress [
	^memory unsignedLong64At: address + 32
]

{ #category : #accessing }
CogStackPageSurrogate64 >> baseAddress: aValue [
	self assert: (address + 32 >= zoneBase and: [address + 39 < zoneLimit]).
	^memory unsignedLong64At: address + 32 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> baseFP [
	^memory unsignedLong64At: address + 24
]

{ #category : #accessing }
CogStackPageSurrogate64 >> baseFP: aValue [
	self assert: (address + 24 >= zoneBase and: [address + 31 < zoneLimit]).
	^memory unsignedLong64At: address + 24 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> headFP [
	^memory unsignedLong64At: address + 16
]

{ #category : #accessing }
CogStackPageSurrogate64 >> headFP: aValue [
	self assert: (address + 16 >= zoneBase and: [address + 23 < zoneLimit]).
	^memory unsignedLong64At: address + 16 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> headSP [
	^memory unsignedLong64At: address + 8
]

{ #category : #accessing }
CogStackPageSurrogate64 >> headSP: aValue [
	self assert: (address + 8 >= zoneBase and: [address + 15 < zoneLimit]).
	^memory unsignedLong64At: address + 8 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> lastAddress [
	^memory unsignedLong64At: address + 48
]

{ #category : #accessing }
CogStackPageSurrogate64 >> lastAddress: aValue [
	self assert: (address + 48 >= zoneBase and: [address + 55 < zoneLimit]).
	^memory unsignedLong64At: address + 48 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> nextPage [
	^stackPages surrogateAtAddress: (memory unsignedLong64At: address + 64)
]

{ #category : #accessing }
CogStackPageSurrogate64 >> nextPage: aValue [
	self assert: (address + 64 >= zoneBase and: [address + 71 < zoneLimit]).
	memory unsignedLong64At: address + 64 put: aValue asInteger.
	^aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> padToWord [
	^memory longAt: address + 60
]

{ #category : #accessing }
CogStackPageSurrogate64 >> padToWord: aValue [
	self assert: (address + 60 >= zoneBase and: [address + 63 < zoneLimit]).
	^memory longAt: address + 60 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> prevPage [
	^stackPages surrogateAtAddress: (memory unsignedLong64At: address + 72)
]

{ #category : #accessing }
CogStackPageSurrogate64 >> prevPage: aValue [
	self assert: (address + 72 >= zoneBase and: [address + 79 < zoneLimit]).
	memory unsignedLong64At: address + 72 put: aValue asInteger.
	^aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> realStackLimit [
	^memory unsignedLong64At: address + 40
]

{ #category : #accessing }
CogStackPageSurrogate64 >> realStackLimit: aValue [
	self assert: (address + 40 >= zoneBase and: [address + 47 < zoneLimit]).
	^memory unsignedLong64At: address + 40 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> stackLimit [
	^memory unsignedLong64At: address + 0
]

{ #category : #accessing }
CogStackPageSurrogate64 >> stackLimit: aValue [
	self assert: (address + 0 >= zoneBase and: [address + 7 < zoneLimit]).
	^memory unsignedLong64At: address + 0 put: aValue
]

{ #category : #accessing }
CogStackPageSurrogate64 >> trace [
	^memory longAt: address + 56
]

{ #category : #accessing }
CogStackPageSurrogate64 >> trace: aValue [
	self assert: (address + 56 >= zoneBase and: [address + 59 < zoneLimit]).
	^memory longAt: address + 56 put: aValue
]
