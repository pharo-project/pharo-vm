"
Here's a doit to generate my code:
	| offset crtab |
	offset := 1.
	crtab := String with: Character cr with: Character tab.
	CogMethod instVarNamesAndTypesForTranslationDo:
		[:name :type| | isByte class |
		(isByte := type = 'unsigned char') ifFalse:
			[offset := (offset - 1 + 3 bitAnd: -4) + 1].
		class := (CogBlockMethod instVarNames includes: name)
					ifTrue: [CogBlockMethodSurrogate32]
					ifFalse: [CogMethodSurrogate32].
		class
			compile: name, crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongAt:']), ' address + ', offset printString
			classified: #accessing.
		class
			compile: name, ': aValue', crtab, '^memory unsigned', (isByte ifTrue: ['ByteAt:'] ifFalse: ['LongAt:']), ' address + ', offset printString,
					' put: aValue'
			classified: #accessing.
		offset := offset + (isByte ifTrue: [1] ifFalse: [4])].
	CogMethodSurrogate32 class compile: 'alignedByteSize', crtab, '^', (offset - 1 + 3 bitAnd: -4) printString classified: #'instance creation'

"
Class {
	#name : 'CogMethodSurrogate32',
	#superclass : 'CogMethodSurrogate',
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
CogMethodSurrogate32 class >> alignedByteSize [
	^20 + self baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 class >> offsetOf: aByteSymbol [
	"These should be generated!!"
	| baseHeaderSize |
	baseHeaderSize := self objectMemoryClass baseHeaderSize.
	^aByteSymbol caseOf:
		{	[#methodObject]		-> [8 + baseHeaderSize].
			[#methodHeader]		-> [12 + baseHeaderSize].
			[#selector]				-> [16 + baseHeaderSize].
			[#picUsage]	-> [6 + baseHeaderSize].
		}
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> blockSize [
	^memory unsignedShortAt: address + 4 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> blockSize: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 4
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cbUsesInstVars [
	^(((memory unsignedByteAt: address + 2 + baseHeaderSize) bitShift: -1) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cbUsesInstVars: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 2
		put: (((memory unsignedByteAt: address + baseHeaderSize + 2) bitAnd: 16rFD) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 1)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmIsUnlinked [
	^(((memory unsignedByteAt: address + 6) bitShift: -4) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmIsUnlinked: aValue [
	memory
		unsignedByteAt: address + 6
		put: (((memory unsignedByteAt: address + 6) bitAnd: 16rEF) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 4)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmNumArgs [
	^memory unsignedByteAt: address + 0 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmNumArgs: aValue [
	^memory
		unsignedByteAt: address + baseHeaderSize + 0
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmRefersToYoung [
	^(((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -3) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmRefersToYoung: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: (((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rF7) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 3)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmType [
	^(memory unsignedByteAt: address + 1 + baseHeaderSize) bitAnd: 16r7
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmType: aValue [
	self assert: (aValue between: 0 and: 16r7).
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: ((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rF8) + aValue.
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmUsageCount [
	^((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -5) bitAnd: 16r7
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmUsageCount: aValue [
	self assert: (aValue between: 0 and: 16r7).
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: ((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16r1F) + (aValue bitShift: 5).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmUsesPenultimateLit [
	^((memory unsignedByteAt: address + 2 + baseHeaderSize) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cmUsesPenultimateLit: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 2
		put: (((memory unsignedByteAt: address + baseHeaderSize + 2) bitAnd: 16rFE) + (aValue ifTrue: [1] ifFalse: [0])).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cpicHasMNUCaseOrCMIsFullBlock [
	^(((memory unsignedByteAt: address + 1 + baseHeaderSize) bitShift: -4) bitAnd: 16r1) ~= 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> cpicHasMNUCaseOrCMIsFullBlock: aValue [
	memory
		unsignedByteAt: address + baseHeaderSize + 1
		put: (((memory unsignedByteAt: address + baseHeaderSize + 1) bitAnd: 16rEF) + ((aValue ifTrue: [1] ifFalse: [0]) bitShift: 4)).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> homeOffset [
	^memory unsignedShortAt: address + 0
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> homeOffset: aValue [
	^memory
		unsignedShortAt: address + 0
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> methodHeader [
	^memory unsignedLong32At: address + 12 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> methodHeader: aValue [
	^memory
		unsignedLong32At: address + baseHeaderSize + 12
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> methodObject [
	^memory unsignedLong32At: address + 8 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> methodObject: aValue [
	^memory
		unsignedLong32At: address + baseHeaderSize + 8
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> padToWord [
	^memory unsignedLong32At: address + 4
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> padToWord: aValue [
	^memory
		unsignedLong32At: address + 4
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> picUsage [
	^memory unsignedShortAt: address + 6 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> picUsage: aValue [
	^memory
		unsignedShortAt: address + baseHeaderSize + 6
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> selector [
	^memory unsignedLong32At: address + 16 + baseHeaderSize
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> selector: aValue [
	^memory
		unsignedLong32At: address + baseHeaderSize + 16
		put: aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> stackCheckOffset [
	^((memory unsignedShortAt: address + 2 + baseHeaderSize) bitShift: -4) bitAnd: 16rFFF
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> stackCheckOffset: aValue [
	self assert: (aValue between: 0 and: 16rFFF).
	memory
		unsignedShortAt: address + baseHeaderSize + 2
		put: ((memory unsignedShortAt: address + baseHeaderSize + 2) bitAnd: 16rF) + (aValue bitShift: 4).
	^aValue
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> startpc [
	^memory unsignedShortAt: address + 2
]

{ #category : 'accessing' }
CogMethodSurrogate32 >> startpc: aValue [
	^memory
		unsignedShortAt: address + 2
		put: aValue
]
