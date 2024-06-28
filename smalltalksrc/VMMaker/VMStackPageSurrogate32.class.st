"
Here's a doit to generate most of my code:
	| offset crtab |
	offset := 1.
	crtab := String with: Character cr with: Character tab.
	CogStackPage instVarNamesAndTypesForTranslationDo:
		[:name :type| | isByte |
		isByte := type = 'unsigned char'.
		CogStackPageSurrogate32
			compile: name, crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongAt:']), ' address + ', offset printString
			classified: #accessing.
		CogStackPageSurrogate32
			compile: name, ': aValue', crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongAt:']), ' address + ', offset printString,
					' put: aValue'
			classified: #accessing.
		offset := offset + (isByte ifTrue: [1] ifFalse: [4])].
	CogStackPageSurrogate32 class compile: 'alignedByteSize', crtab, '^', (offset - 1 + 3 bitAnd: -4) printString classified: #'instance creation'

"
Class {
	#name : 'VMStackPageSurrogate32',
	#superclass : 'VMStackPageSurrogate',
	#category : 'VMMaker-InterpreterSimulation',
	#package : 'VMMaker',
	#tag : 'InterpreterSimulation'
}

{ #category : 'accessing' }
VMStackPageSurrogate32 class >> alignedByteSize [
	^40
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> baseAddress [
	^memory unsignedLong32At: address + 16
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> baseAddress: aValue [
	self assert: (address + 16 >= zoneBase and: [address + 19 < zoneLimit]).
	^memory unsignedLong32At: address + 16 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> baseFP [
	^memory unsignedLong32At: address + 12
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> baseFP: aValue [
	self assert: (address + 12 >= zoneBase and: [address + 15 < zoneLimit]).
	^memory unsignedLong32At: address + 12 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> headFP [
	^memory unsignedLong32At: address + 8
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> headFP: aValue [
	self assert: (address + 8 >= zoneBase and: [address + 11 < zoneLimit]).
	^memory unsignedLong32At: address + 8 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> headSP [
	^memory unsignedLong32At: address + 4
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> headSP: aValue [
	self assert: (address + 4 >= zoneBase and: [address + 7 < zoneLimit]).
	^memory unsignedLong32At: address + 4 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> lastAddress [
	^memory unsignedLong32At: address + 24
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> lastAddress: aValue [
	self assert: (address + 24 >= zoneBase and: [address + 27 < zoneLimit]).
	^memory unsignedLong32At: address + 24 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> nextPage [
	^stackPages surrogateAtAddress: (memory unsignedLong32At: address + 32)
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> nextPage: aValue [
	self assert: (address + 32 >= zoneBase and: [address + 35 < zoneLimit]).
	memory unsignedLong32At: address + 32 put: aValue asInteger.
	^aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> padToWord [
	^memory long32At: address + 32
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> padToWord: aValue [
	self assert: (address + 32 >= zoneBase and: [address + 35 < zoneLimit]).
	^memory long32At: address + 32 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> prevPage [
	^stackPages surrogateAtAddress: (memory unsignedLong32At: address + 36)
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> prevPage: aValue [
	self assert: (address + 36 >= zoneBase and: [address + 39 < zoneLimit]).
	memory unsignedLong32At: address + 36 put: aValue asInteger.
	^aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> realStackLimit [
	^memory unsignedLong32At: address + 20
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> realStackLimit: aValue [
	self assert: (address + 20 >= zoneBase and: [address + 23 < zoneLimit]).
	^memory unsignedLong32At: address + 20 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> stackLimit [
	^memory unsignedLong32At: address + 0
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> stackLimit: aValue [
	self assert: (address + 0 >= zoneBase and: [address + 3 < zoneLimit]).
	^memory unsignedLong32At: address + 0 put: aValue
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> trace [
	^memory long32At: address + 28
]

{ #category : 'accessing' }
VMStackPageSurrogate32 >> trace: aValue [
	self assert: (address + 28 >= zoneBase and: [address + 31 < zoneLimit]).
	^memory long32At: address + 28 put: aValue
]
