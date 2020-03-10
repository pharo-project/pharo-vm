Extension { #name : #CogMethodSurrogate }

{ #category : #'*VMMakerPharoDebug' }
CogMethodSurrogate >> codeBlocksForDisassembly [
	<doNotGenerate>
	| labelMap |
	labelMap := cogit buildMethodLabelMapFor: self.
	^ (cogit codeRangesFor: self) collect: [ :each |
		| machineCode destIndex |
		machineCode := ByteArray new: each size.
		destIndex := 1.
		each do: [ :sourceAddress |
			machineCode at: destIndex put: (memory byteAt: sourceAddress + 1).
			destIndex := destIndex + 1.
		].
	
		CogMethodBlockForDisassembly new
			labelMap: labelMap;
			pc: each first;
			startpc: each startpc;
			machineCode: machineCode;
			yourself.
	]
]

{ #category : #'*VMMakerPharoDebug' }
CogMethodSurrogate >> disassemblyCodeBlock: codeBlock with: disassembler into: disassembledInstructions [
	<doNotGenerate>
	| machineInstructions labelMap instructionBuffer sourceOffset pc |
	machineInstructions := codeBlock machineCode.
	labelMap := codeBlock labelMap.
	instructionBuffer := ByteArray new: 32.
	pc := codeBlock pc.
	sourceOffset := 0.
	[sourceOffset < machineInstructions size ] whileTrue: [
		| label |
		label := labelMap at: pc ifAbsent: [ nil ].
		[
			| instruction copySize |
			copySize := machineInstructions size - sourceOffset min: instructionBuffer size.
			instructionBuffer replaceFrom: 1 to: copySize with: machineInstructions startingAt: sourceOffset + 1.
			
			instruction := disassembler disassembleInstructionIn: instructionBuffer pc: pc.
			disassembledInstructions add: (CogMethodDisassemblyInstruction new
				label: label;
				pc: pc;
				assembly: instruction assembly;
				size: instruction size;
				bytes: (instructionBuffer first: instruction size);
				yourself).
			pc := pc + instruction size.
			sourceOffset := sourceOffset + instruction size
		] on: LLVMInvalidInstructionError do: [ :e |
			disassembledInstructions add: (CogMethodDisassemblyInstruction new
				label: label;
				pc: pc;
				assembly: '(illegal)';
				bytes: (instructionBuffer first: 1);
				size: 1;
				yourself).
			pc := pc + 1.
			sourceOffset := sourceOffset + 1
		]
	].

	^ disassembledInstructions
]

{ #category : #'*VMMakerPharoDebug' }
CogMethodSurrogate >> disassemblyWith: disassembler [
	<doNotGenerate>
	| disassembledInstructions |
	disassembledInstructions := OrderedCollection new.
	self codeBlocksForDisassembly do: [ :each |
		self disassemblyCodeBlock: each with: disassembler into: disassembledInstructions
	].
	^ disassembledInstructions
]

{ #category : #'*VMMakerPharoDebug' }
CogMethodSurrogate >> disassemblyX86_64 [
	<doNotGenerate>
	^ self disassemblyWith: LLVMDisassembler amd64

]

{ #category : #'*VMMakerPharoDebug' }
CogMethodSurrogate >> gtDisassemblyX86_64In: composite [
	<doNotGenerate>
	<gtInspectorPresentationOrder: 500>
	^ composite fastTable
		title: 'Instructions';
		beMultiple;
		display: [self disassemblyX86_64];
		column: 'PC' evaluated: [ :each | each pc printStringBase: 16 length: 8 padded: true ];
		column: 'Label' evaluated: [ :each |
			each label
				ifNil: [ '' ]
				ifNotNil: [ :label | label , ':' ]
		];
		column: 'Assembly' evaluated: [ :each | each assembly ];
		column: 'Bytes' evaluated: [:each |
			ByteString streamContents: [:out |
				each bytes doWithIndex: [ :byte :index |
					index > 1 ifTrue: [ out nextPutAll: ' ' ].
					out nextPutAll: (byte printStringBase: 16 length: 2 padded: true)
				]
			]
		].
		

]
