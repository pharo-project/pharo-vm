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
	#name : 'CogMethodSurrogate64',
	#superclass : 'CogMethodSurrogate',
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
CogMethodSurrogate64 class >> alignedByteSize [
	^32 + self baseHeaderSize
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
CogMethodSurrogate64 >> blockSize [
	^memory unsignedShortAt: address + 4 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> blockSize: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 4
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cbUsesInstVars [
	^(((memory unsignedByteAt: address + 2 + baseHeaderSize) bitShift: -1) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cbUsesInstVars: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 2
		put: (((memory unsignedByteAt: address + baseHeaderSize + 2) bitAnd: 16rFD) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 1)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmIsUnlinked [
	^(((memory unsignedByteAt: address + 10) bitShift: -4) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmIsUnlinked: aValue [
	memory
		unsignedByteAt: address + 10
		put: (((memory unsignedByteAt: address + 10) bitAnd: 16rEF) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 4)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmNumArgs [
	^memory unsignedByteAt: address + 0 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmNumArgs: aValue [
	^memory
		unsignedByteAt: address + baseHeaderSize + 0
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmRefersToYoung [
	^(((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -3) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmRefersToYoung: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: (((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rF7) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 3)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmType [
	^(memory unsignedByteAt: address + 1 + baseHeaderSize) bitAnd: 16r7
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmType: aValue [
	self assert: (aValue between: 0 and: 16r7).
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: ((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rF8) + aValue.
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmUsageCount [
	^((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -5) bitAnd: 16r7
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmUsageCount: aValue [
	self assert: (aValue between: 0 and: 16r7).
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: ((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16r1F) + (aValue bitShift: 5).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmUsesPenultimateLit [
	^((memory unsignedByteAt: address + 2 + baseHeaderSize) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cmUsesPenultimateLit: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 2
		put: (((memory unsignedByteAt: address + baseHeaderSize + 2) bitAnd: 16rFE) + (aValue ifTrue: [1] ifFalse: [0])).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cpicHasMNUCaseOrCMIsFullBlock [
	^(((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -4) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> cpicHasMNUCaseOrCMIsFullBlock: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: (((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rEF) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 4)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> homeOffset [
	^memory unsignedShortAt: address + 0
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> homeOffset: aValue [
	^memory
		unsignedShortAt: address + 0
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> methodHeader [
	^memory unsignedLong64At: address + 16 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> methodHeader: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 16
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> methodObject [
	^memory unsignedLong64At: address + 8 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> methodObject: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 8
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> padToWord [
	^memory unsignedLong64At: address + 4
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> padToWord: aValue [
	^memory
		unsignedLong64At: address + 4
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> picUsage [
	^memory unsignedShortAt: address + 6 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> picUsage: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 6
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> selector [
	^memory unsignedLong64At: address + 24 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> selector: aValue [
	^memory
		unsignedLong64At: address + baseHeaderSize + 24
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> stackCheckOffset [
	^((memory unsignedShortAt: address + 2 + baseHeaderSize) bitShift: -4) bitAnd: 16rFFF
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> stackCheckOffset: aValue [
	self assert: (aValue between: 0 and: 16rFFF).
	memory
		unsignedShortAt: address + baseHeaderSize + 2
		put: ((memory unsignedShortAt: address + baseHeaderSize + 2) bitAnd: 16rF) + (aValue bitShift: 4).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> startpc [
	^memory unsignedShortAt: address + 2
]

{ #category : 'accessing' }
CogMethodSurrogate64 >> startpc: aValue [
	^memory
		unsignedShortAt: address + 2
		put: aValue
]
