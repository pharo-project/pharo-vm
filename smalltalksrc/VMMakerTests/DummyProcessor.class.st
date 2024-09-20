Class {
	#name : #DummyProcessor,
	#superclass : #Object,
	#instVars : [
		'stackPointer',
		'framePointer',
		'baseRegisterValue',
		'programCounter',
		'smalltalkStackPointerRegisterValue',
		'linkRegisterValue',
		'receiverRegisterValue'
	],
	#category : #'VMMakerTests-JitTests'
}

{ #category : #accessing }
DummyProcessor >> baseRegisterValue: anInteger [ 
	
	baseRegisterValue := anInteger
]

{ #category : #accessing }
DummyProcessor >> cResultRegister [
	
	^ nil
]

{ #category : #accessing }
DummyProcessor >> disassembler [
	
	^ LLVMDisassembler aarch64
]

{ #category : #operations }
DummyProcessor >> flushICacheFrom: anInteger to: anInteger2 [ 
	
	
]

{ #category : #accessing }
DummyProcessor >> fp [
	
	^ framePointer 
]

{ #category : #accessing }
DummyProcessor >> fp: anInteger [ 
	
	framePointer := anInteger 
]

{ #category : #accessing }
DummyProcessor >> framePointerRegisterValue: anInteger [ 

	framePointer := anInteger 
]

{ #category : #accessing }
DummyProcessor >> hasLinkRegister [
	
	^ true
]

{ #category : #initialization }
DummyProcessor >> initializeStackFor: aSimpleStackBasedCogit [ 

	"We are dummy...."
]

{ #category : #accessing }
DummyProcessor >> instructionPointerRegisterValue [
	
	^ programCounter 
]

{ #category : #accessing }
DummyProcessor >> integerRegisterState [
	
	^ #()
]

{ #category : #accessing }
DummyProcessor >> linkRegisterValue: anInteger [ 

	linkRegisterValue := anInteger 
]

{ #category : #accessing }
DummyProcessor >> machineSimulator [
	
	^ self
]

{ #category : #accessing }
DummyProcessor >> memoryAt: anInteger write: aCollection size: anInteger3 [ 

	
]

{ #category : #accessing }
DummyProcessor >> pc [
	
	^ programCounter
]

{ #category : #accessing }
DummyProcessor >> pc: anInteger [ 
	
	programCounter := anInteger
]

{ #category : #operations }
DummyProcessor >> pushWord: anInteger [ 

	stackPointer := stackPointer - 8
]

{ #category : #accessing }
DummyProcessor >> receiverRegisterValue: anInteger [ 

	receiverRegisterValue := anInteger 
]

{ #category : #accessing }
DummyProcessor >> runUntil: anInteger [ 
	
	programCounter := anInteger
	
]

{ #category : #accessing }
DummyProcessor >> setFramePointer: aFPValue stackPointer: aSPValue [
 
	stackPointer := aSPValue.
	framePointer := aFPValue 
]

{ #category : #accessing }
DummyProcessor >> simulateLeafCallOf: anInteger nextpc: anInteger2 memory: anUndefinedObject [ 

	
]

{ #category : #accessing }
DummyProcessor >> smalltalkStackPointerRegisterValue [
	^ smalltalkStackPointerRegisterValue
]

{ #category : #accessing }
DummyProcessor >> smalltalkStackPointerRegisterValue: anInteger [ 

	smalltalkStackPointerRegisterValue := anInteger 	
]

{ #category : #accessing }
DummyProcessor >> sp [
	
	^ stackPointer 
]
