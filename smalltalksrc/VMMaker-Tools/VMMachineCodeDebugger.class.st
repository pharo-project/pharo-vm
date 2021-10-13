Class {
	#name : #VMMachineCodeDebugger,
	#superclass : #SpPresenter,
	#instVars : [
		'cogit',
		'machineSimulator',
		'instructions',
		'irinstructions',
		'stepButton',
		'disassembleAtPCButton',
		'machineState',
		'initialInstructionToDisassemble',
		'stack',
		'ipInput',
		'jumpToButton',
		'abstractInstructions'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #specs }
VMMachineCodeDebugger class >> defaultSpec [

	^  SpBoxLayout newVertical
		add:(SpBoxLayout newHorizontal
			add: #irinstructions expand: true fill: true padding: 5;
			add: #instructions expand: true fill: true padding: 5;
			add: #machineState expand: true fill: true padding: 5;
			add: #stack expand: true fill: true padding: 5;
			yourself) expand: true fill: true padding: 5;
		add: (SpBoxLayout newHorizontal
			add: (SpBoxLayout newVertical
					add: #machineState;
					add: (SpBoxLayout newHorizontal
						add: #ipInput;
						add: #jumpToButton);
					add: #stepButton;
					add: #disassembleAtPCButton;
					yourself);
			add: #stack;
			yourself)
		yourself
]

{ #category : #'as yet unclassified' }
VMMachineCodeDebugger class >> openOnCogit: aCogit [

	self openOnCogit: aCogit ip: aCogit processor machineSimulator pc
]

{ #category : #'as yet unclassified' }
VMMachineCodeDebugger class >> openOnCogit: aCogit ip: anInstructionPointer [

	self new
		cogit: aCogit;
		machineSimulator: aCogit processor machineSimulator;
		initialInstructionToDisassemble: anInstructionPointer;
		openWithSpec.
]

{ #category : #accessing }
VMMachineCodeDebugger >> abstractInstructions [

	^ abstractInstructions
]

{ #category : #accessing }
VMMachineCodeDebugger >> abstractInstructions: aCollection [

	^ abstractInstructions := aCollection
]

{ #category : #accessing }
VMMachineCodeDebugger >> cogit [
	^ cogit
]

{ #category : #accessing }
VMMachineCodeDebugger >> cogit: anObject [
	cogit := anObject
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectButtons [

	stepButton action: [ self step ].
	disassembleAtPCButton action: [ self disassembleAtPC ].
	jumpToButton action: [ self jump ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectIRInstructionsPresenter [

	|  irinstructionsContextMenu |
	irinstructionsContextMenu := SpMenuPresenter new.
	irinstructionsContextMenu
		addItem: [ :item |
		item
			name: 'Inspect Operands';
			action: [ self selectedIRInstruction operands inspect ] ];
		"Inspect the IR Instruction debugger object"
		addItem: [ :item |
		item
			name: 'Inspect';
			action: [ self inspectSelectedIRInstruction ] ].
	irinstructions contextMenu: irinstructionsContextMenu
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectInstructionsPresenter [

	| instructionsContextMenu |
	instructionsContextMenu := SpMenuPresenter new.
	instructionsContextMenu
		"Set PC to the instruction"
		addItem: [ :item |
		item
			name: 'Set Intruction Pointer Here';
			action: [
				self setInstructionPointerToSelectedInstruction.
				self refreshAll ] ];
		"Run from current PC to instruction"
		addItem: [ :item |
		item
			name: 'Run to Here';
			action: [
				self runToSelectedInstruction.
				self refreshAll ] ];
		"Inspect machine code debugger instruction"
		addItem: [ :item |
		item
			name: 'Inspect';
			action: [ self inspectSelectedInstruction ] ].
	instructions contextMenu: instructionsContextMenu
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectMachineStatePresenter [

	| contextMenu |

	contextMenu := SpMenuPresenter new.
	contextMenu
		"Inspect the value of the register"
		addItem: [ :item |
		item
			name: 'Inspect Value';
			action: [ machineState selection selectedItem inspectValue ] ];
		"Copy the value to the clipboard"
		addItem: [ :item |
		item
			name: 'Copy Value to Clipboard';
			action: [ machineState selection selectedItem copyValueToClipboard ] ];
		"Print the value of the register"
		addItem: [ :item |
		item
			name: 'Print Value';
			action: [ machineState selection selectedItem printValue ] ].

	machineState contextMenu: contextMenu.



]

{ #category : #initialization }
VMMachineCodeDebugger >> connectPresenters [

	self connectButtons.
	self connectIRInstructionsPresenter.
	self connectInstructionsPresenter.
	self connectMachineStatePresenter
]

{ #category : #actions }
VMMachineCodeDebugger >> disassembleAtPC [

	self initialInstructionToDisassemble:  machineSimulator instructionPointerValue.
	self refreshInstructions.
]

{ #category : #showing }
VMMachineCodeDebugger >> doInitialDisassemble [

	^ machineSimulator disassembler
		printImmediatesInHexa;
		useAlternatePrinterVariant;
		disassembleNext: 150
		instructionsIn: (cogit objectMemory memoryManager
			copyFrom: self initialInstructionToDisassemble
			to: self initialInstructionToDisassemble + 600)
		startAddress: self initialInstructionToDisassemble
		pc: machineSimulator instructionPointerValue
]

{ #category : #actions }
VMMachineCodeDebugger >> highlightMCInstructions: aVMDebuggerIRInstruction [

	"Extract the machine code instructions from the IR instruction"

	| indexes instructionAddresses |
	instructionAddresses := aVMDebuggerIRInstruction machineCodeInstructionsAddresses.
	indexes := instructionAddresses collect: [ :addr | (self initialDisassembly collect: [ :e | e address ]) indexOf: addr ].
	indexes size = 1
		ifTrue: [ instructions beSingleSelection ]
		ifFalse: [ instructions beMultipleSelection ].
	instructions selection selectIndexes: indexes.


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightPCInstruction [

	| index |
	index :=	(self initialDisassembly collect: [ :e | e address ]) indexOf: machineSimulator instructionPointerValue.
	instructions selection selectIndex: index

]

{ #category : #actions }
VMMachineCodeDebugger >> highlightRegisters: aVMDebuggerInstruction [

	"Extract registers name from instruction assembly and highlight the corresponding lines"
	| usedRegisters indexes |
	usedRegisters := aVMDebuggerInstruction usedRegisters.
	indexes := usedRegisters collect: [ :reg | machineSimulator registerList indexOf: reg ].
	indexes size = 1
		ifTrue: [ machineState beSingleSelection ]
		ifFalse: [ machineState beMultipleSelection ].
	machineState selection selectIndexes: indexes.


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightSelectedIRInstructionMCInstructions [

	self selectedIRInstruction
		ifNotNil: [ self highlightMCInstructions: self selectedIRInstruction ]


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightSelectedInstructionRegisters [

	self selectedInstruction
		ifNotNil: [ self highlightRegisters: self selectedInstruction ]

]

{ #category : #showing }
VMMachineCodeDebugger >> initialDisassembly [

	^ self doInitialDisassemble collect: [ :anInstruction |
			VMMachineCodeDebuggerInstruction new
				instruction: anInstruction;
				bytes: (anInstruction codeBytes: cogit objectMemory memoryManager);
				debugger: self;
				machineSimulator: machineSimulator;
				yourself ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialExtent [

	^ 1000@1000
]

{ #category : #showing }
VMMachineCodeDebugger >> initialIRDisassembly [

	^ self abstractInstructions collect: [ :anInstruction | VMMachineCodeDebuggerIRInstruction new
				irinstruction: anInstruction;
				debugger: self;
				machineSimulator: machineSimulator;
				processOperands;
				yourself ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialInstructionToDisassemble [

	^ initialInstructionToDisassemble
		ifNil: [ machineSimulator instructionPointerValue ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialInstructionToDisassemble: anInstructionAddress [

	initialInstructionToDisassemble := anInstructionAddress
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeButtons [

	stepButton := self newButton.
	stepButton label: 'Step'.
	disassembleAtPCButton := self newButton.
	disassembleAtPCButton label: 'Disassemble at PC'.
	ipInput := self newTextInput.
	jumpToButton := self newButton.
	jumpToButton label: 'Jump to'
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeIRInstructionsPresenter [

	irinstructions := self newTable.
	irinstructions
		isResizable: true;
		addColumn:
			((SpStringTableColumn
			title: 'Name'
			evaluated: #opCodeName)
				 isSortable: false;
				 yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op1'
			evaluated: #operand1)
				isSortable: false;
				yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op2'
			evaluated: #operand2)
				isSortable: false;
				yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op3'
			evaluated: #operand3)
				isSortable: false;
				yourself);
		showColumnHeaders;
		whenSelectionChangedDo: [ self highlightSelectedIRInstructionMCInstructions ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeInstructionsPresenter [

	instructions := self newTable.
	instructions
		isResizable: true;
		addColumn:
			((SpStringTableColumn title: 'Address' evaluated: #addressString)
				 isSortable: false;
				 yourself);
		addColumn: ((SpImageTableColumn title: '' evaluated: #icon)
				 width: 50;
				 beNotExpandable;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'ASM' evaluated: #assemblyCodeString)
				 isSortable: false;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Bytes' evaluated: #bytesString)
				 isSortable: false;
				 yourself);
		showColumnHeaders;
		whenSelectionChangedDo: [ self highlightSelectedInstructionRegisters ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeMachineStatePresenter [


	machineState := self newTable.
	machineState
		addColumn: (SpStringTableColumn
			title: 'Name'
			evaluated: #name);
		addColumn:(SpStringTableColumn
			title: 'Machine Alias'
			evaluated: #alias);
		addColumn: (SpStringTableColumn
			title: 'Smalltalk Alias'
			evaluated: #smalltalkAlias);
		addColumn: (SpStringTableColumn
			title: 'Value'
			evaluated: [ :register | register printString ])
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializePresenters [

	self initializeIRInstructionsPresenter.
	self initializeInstructionsPresenter.
	self initializeMachineStatePresenter.
	self initializeStackPresenter.
	self initializeButtons
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeStackPresenter [

	stack := self newTable.
	stack
		addColumn: (SpStringTableColumn
				 title: 'Pointer'
				 evaluated: [ :aPosition | aPosition specialRegister ]);
		addColumn: (SpStringTableColumn
				 title: 'Address'
				 evaluated: [ :aPosition | aPosition address hex ]);
		addColumn:
			(SpStringTableColumn title: 'Value' evaluated: [ :aPosition |
					 [ aPosition value hex ]
						 on: Error
						 do: [ 'Error' ] ])
]

{ #category : #actions }
VMMachineCodeDebugger >> inspectSelectedIRInstruction [

	irinstructions selection selectedItem inspect
]

{ #category : #actions }
VMMachineCodeDebugger >> inspectSelectedInstruction [

	instructions selection selectedItem inspect
]

{ #category : #accessing }
VMMachineCodeDebugger >> irinstructions: aCollection [
	irinstructions := aCollection
]

{ #category : #actions }
VMMachineCodeDebugger >> jump [

	machineSimulator instructionPointerValue: (NumberParser parse: ipInput text).
	self refreshInstructions.
	self refreshRegisters.
]

{ #category : #accessing }
VMMachineCodeDebugger >> machineSimulator [
	^ machineSimulator
]

{ #category : #accessing }
VMMachineCodeDebugger >> machineSimulator: anObject [
	machineSimulator := anObject
]

{ #category : #showing }
VMMachineCodeDebugger >> openWithSpec [

	self refreshAll.
	super openWithSpec.
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshAll [

	self refreshIRInstructions.
	self refreshInstructions.
	self refreshStack.

	super openWithSpec.
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshIRInstructions [

	irinstructions items: self initialIRDisassembly
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshInstructions [

	instructions items: self initialDisassembly
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshRegisters [

	machineState items: machineSimulator registerDescriptors
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshStack [

	stack items: machineSimulator stackValues
]

{ #category : #actions }
VMMachineCodeDebugger >> runToSelectedInstruction [

	| selectedInstruction |

	selectedInstruction := self selectedInstruction.

	machineSimulator
		startAt: machineSimulator instructionPointerValue
		until: selectedInstruction address
		timeout: 100000 "microseconds = 100ms"
		count: 0.
	self refreshStack.
]

{ #category : #accessing }
VMMachineCodeDebugger >> selectedIRInstruction [

	^ irinstructions selection selectedItem
]

{ #category : #accessing }
VMMachineCodeDebugger >> selectedInstruction [

	^ instructions selection selectedItem
]

{ #category : #actions }
VMMachineCodeDebugger >> setInstructionPointerToSelectedInstruction [

	machineSimulator instructionPointerValue: instructions selection selectedItem address
]

{ #category : #actions }
VMMachineCodeDebugger >> step [

	machineSimulator step.
	self refreshAll.
	self highlightPCInstruction
]

{ #category : #accessing }
VMMachineCodeDebugger >> title [

	^ 'VM Debugger'
]
