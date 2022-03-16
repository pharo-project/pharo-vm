Class {
	#name : #VMCogitHelpersTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#instVars : [
		'checkIsSmallInteger',
		'checkNotSmallInteger'
	],
	#pools : [
		'CogAbstractRegisters',
		'CogRTLOpcodes'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> assertIsInSmallIntegerRange: anInteger [

	machineSimulator classRegisterValue: anInteger.

	self runUntilReturnFrom: checkIsSmallInteger.
	
	self assert: machineSimulator classRegisterValue equals: 0
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> assertNotInSmallIntegerRange: anInteger [

	machineSimulator classRegisterValue: anInteger.

	self runUntilReturnFrom: checkNotSmallInteger.
	
	self assert: machineSimulator classRegisterValue equals: 0
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> denyIsInSmallIntegerRange: anInteger [

	machineSimulator classRegisterValue: anInteger.

	self runUntilReturnFrom: checkIsSmallInteger.
	
	self assert: machineSimulator classRegisterValue equals: 1
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> denyIsNotInSmallIntegerRange: anInteger [

	machineSimulator classRegisterValue: anInteger.

	self runUntilReturnFrom: checkNotSmallInteger.
	
	self assert: machineSimulator classRegisterValue equals: 1
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> runUntilReturnFrom: anAddress [
	
	self prepareCall.
	super runUntilReturnFrom: anAddress
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> setUp [

	super setUp.
	"Compile a simple routine that checks if the Class register has a small integer or not.
	Puts 0 in the class register if ok, puts 1 if not"
	checkIsSmallInteger := self compile: [ | jump |
		jump := cogit objectRepresentation genJumpIsSmallIntegerValue: ClassReg scratch: ReceiverResultReg.
		"If not integer"
		cogit MoveCq: 1 R: ClassReg.
		cogit RetN: 0.
		"if integer"
		jump jmpTarget: cogit Label.
		cogit MoveCq: 0 R: ClassReg.
		cogit RetN: 0
	].

	"Compile a simple routine that checks if the Class register has not small integer.
	Puts 0 in the class register if ok, puts 1 if not"
	checkNotSmallInteger := self compile: [ | jump |
		jump := cogit objectRepresentation genJumpNotSmallIntegerValue: ClassReg scratch: ReceiverResultReg.
		"If not integer"
		cogit MoveCq: 1 R: ClassReg.
		cogit RetN: 0.
		"if integer"
		jump jmpTarget: cogit Label.
		cogit MoveCq: 0 R: ClassReg.
		cogit RetN: 0
	].
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> testCheckNotSmallIntegerWithNonValidSmallIntegers [

	self assertNotInSmallIntegerRange: memory maxSmallInteger + 1.

	"In 32 bits check shifting only by one, in 64 bits by 1, 2 and 3"
	1 to: memory numSmallIntegerTagBits do: [ :i |
		self assertNotInSmallIntegerRange: memory maxSmallInteger << i.
	]
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> testCheckNotSmallIntegerWithValidSmallIntegers [

	self denyIsNotInSmallIntegerRange: 0.
	self denyIsNotInSmallIntegerRange: memory maxSmallInteger.
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> testCheckSmallIntegerWithNonValidSmallIntegers [

	self denyIsInSmallIntegerRange: memory maxSmallInteger + 1.

	"In 32 bits check shifting only by one, in 64 bits by 1, 2 and 3"
	1 to: memory numSmallIntegerTagBits do: [ :i |
		self denyIsInSmallIntegerRange: memory maxSmallInteger << i.
	]
]

{ #category : #'as yet unclassified' }
VMCogitHelpersTest >> testCheckSmallIntegerWithValidSmallIntegers [

	self assertIsInSmallIntegerRange: 0.
	self assertIsInSmallIntegerRange: memory maxSmallInteger
]
