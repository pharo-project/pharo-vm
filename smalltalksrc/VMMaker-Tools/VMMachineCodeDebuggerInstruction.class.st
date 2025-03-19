Class {
	#name : 'VMMachineCodeDebuggerInstruction',
	#superclass : 'Object',
	#instVars : [
		'instruction',
		'bytes',
		'machineSimulator',
		'debugger'
	],
	#category : 'VMMaker-Tools',
	#package : 'VMMaker-Tools'
}

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> address [
	
	^ instruction address
]

{ #category : 'printing' }
VMMachineCodeDebuggerInstruction >> addressString [
	
	^ instruction address hex
]

{ #category : 'printing' }
VMMachineCodeDebuggerInstruction >> assemblyCodeString [

	^ instruction assemblyCodeString 
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> branchTargetAddress [
	
	^ instruction branchTargetAddress
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> bytes: aByteArray [ 
	bytes := aByteArray
]

{ #category : 'printing' }
VMMachineCodeDebuggerInstruction >> bytesString [

	^ String streamContents: [ :aStream |
		aStream nextPutAll: '#['.
		bytes
			do: [ :each | each hex printOn: aStream ]
			separatedBy: [ aStream nextPut: $ ].
		aStream nextPut: $]].


]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> debugger: aVMMachineCodeDebugger [ 
	
	debugger := aVMMachineCodeDebugger
]

{ #category : 'showing' }
VMMachineCodeDebuggerInstruction >> icon [

	self address = machineSimulator instructionPointerRegisterValue 
		ifTrue: [ ^ self iconNamed: #forward ].
	
	debugger selectedInstruction 
		ifNotNil: [ :selectedInstruction |
				selectedInstruction branchTargetAddress = self address 
					ifTrue: [ ^ self iconNamed: #glamorousInto ]].

	^ nil
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> instruction: aLLVMInstruction [ 
	instruction := aLLVMInstruction
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> machineSimulator [ 

	^ machineSimulator
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> machineSimulator: aProcessorSimulator [ 
	machineSimulator := aProcessorSimulator
]

{ #category : 'accessing' }
VMMachineCodeDebuggerInstruction >> usedRegisters [
	"Detect any register name from an asm instruction"

	| registerAliases cleanASM tokens usedRegisters |
	registerAliases := self machineSimulator registerList.
	"Clean and split the ASM"
	cleanASM := self assemblyCodeString copyWithoutAll: ',()'.
	tokens := cleanASM splitOn: [ :each | each isSeparator ].
	"Check if any of the substring "
	usedRegisters := tokens select: [ :token |
		                 registerAliases includes: token ].
	^ usedRegisters removeDuplicates
]
