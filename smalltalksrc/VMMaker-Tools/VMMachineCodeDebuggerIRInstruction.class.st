Class {
	#name : #VMMachineCodeDebuggerIRInstruction,
	#superclass : #Object,
	#instVars : [
		'irinstruction',
		'machineSimulator',
		'debugger',
		'operands'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> address [ 

	^ irinstruction address
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> addressString [

	^ irinstruction address hex
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> debugger: aVMMachineCodeDebugger [

	debugger:= aVMMachineCodeDebugger
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> initialize [ 

	super initialize.
	operands := Array ofSize: 4.
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> irinstruction: aCogAbstractInstruction [

	irinstruction := aCogAbstractInstruction
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> machineCodeInstructionsAddresses [ 

	| startAddress endAddress |	
	startAddress := self address.
	endAddress := startAddress + self machineCodeSize - 4.
	^ (startAddress to: endAddress by: 4) collect: [ :address |  address ].
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> machineCodeSize [ 

	^ irinstruction machineCodeSize
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> machineSimulator: aMachineSimulator [ 

	machineSimulator := aMachineSimulator 
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> opCodeName [ 

	^ irinstruction class nameForOpcode: irinstruction opcode
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> operand1 [ 

	^ operands at: 1
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> operand2 [

	^ operands at: 2
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> operand3 [

	^ operands at: 3
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> operands [
	^ operands
]

{ #category : #accessing }
VMMachineCodeDebuggerIRInstruction >> processOperands [ 

	| format strOperands |
	format := irinstruction getFormatFromOpCodeName: self opCodeName.
	strOperands := irinstruction getOperandsWithFormat: format.
	strOperands withIndexDo: 
		[ :op :i | op ifNotNil: [ operands at: i put: op ] ].

]
