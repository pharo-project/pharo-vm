"
Here's a doit to generate my code:
	| offset crtab |
	offset := 1.
	crtab := String with: Character cr with: Character tab.
	CogMethod instVarNamesAndTypesForTranslationDo:
		[:name :type| | isByte class |
		(isByte := type = 'unsigned char') ifFalse:
			[offset := (offset - 1 + 7 bitAnd: -8) + 1].
		class := (CogBlockMethod instVarNames includes: name)
					ifTrue: [CogBlockMethodSurrogate64]
					ifFalse: [CogMethodSurrogate64].
		class
			compile: name, crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongLongAt:']), ' address + ', offset printString
			classified: #accessing.
		class
			compile: name, ': aValue', crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongLongAt:']), ' address + ', offset printString,
					' put: aValue'
			classified: #accessing.
		offset := offset + (isByte ifTrue: [1] ifFalse: [8])].
	CogMethodSurrogate64 class compile: 'alignedByteSize', crtab, '^', (offset + 7 bitAnd: -8) printString classified: #'instance creation'

"
Class {
	#name : #CogMethodSurrogate64,
	#superclass : #CogBlockMethodSurrogate64,
	#category : #'VMMaker-JITSimulation'
}

{ #category : #accessing }
CogMethodSurrogate64 class >> alignedByteSize [
	^32 + self baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 class >> offsetOf: aByteSymbol [
	"These should be generated!!"
	| baseHeaderSize |
	baseHeaderSize := self objectMemoryClass baseHeaderSize.
	^aByteSymbol caseOf:
		{	[#methodObject]		-> [8 + baseHeaderSize].
			[#methodHeader]		-> [16 + baseHeaderSize].
			[#selector]				-> [24 + baseHeaderSize].
			[#picUsage]	-> [6 + baseHeaderSize].
		}
]

{ #category : #accessing }
CogMethodSurrogate64 >> blockSize [
	^memory unsignedShortAt: address + 4 + baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 >> blockSize: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 4
		put: aValue
]

{ #category : #accessing }
CogMethodSurrogate64 >> methodHeader [
	^memory unsignedLong64At: address + 16 + baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 >> methodHeader: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 16
		put: aValue
]

{ #category : #accessing }
CogMethodSurrogate64 >> methodObject [
	^memory unsignedLong64At: address + 8 + baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 >> methodObject: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 8
		put: aValue
]

{ #category : #accessing }
CogMethodSurrogate64 >> picUsage [
	^memory unsignedShortAt: address + 6 + baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 >> picUsage: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 6
		put: aValue
]

{ #category : #accessing }
CogMethodSurrogate64 >> selector [
	^memory unsignedLong64At: address + 24 + baseHeaderSize
]

{ #category : #accessing }
CogMethodSurrogate64 >> selector: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 24
		put: aValue
]
