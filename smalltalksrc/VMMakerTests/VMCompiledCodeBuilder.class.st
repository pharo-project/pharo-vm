Class {
	#name : #VMCompiledCodeBuilder,
	#superclass : #VMAbstractBuilder,
	#instVars : [
		'slotSize',
		'numberOfTemporaries',
		'isSmall',
		'literals',
		'method',
		'bytecodes',
		'numberOfArguments',
		'isPrimitive',
		'originalLiterals'
	],
	#category : #'VMMakerTests-Builders'
}

{ #category : #accessing }
VMCompiledCodeBuilder >> address [
	
	^ method
]

{ #category : #building }
VMCompiledCodeBuilder >> buildMethod [
	self instantiateMethod.
	self fillMethod.
	^ method
]

{ #category : #building }
VMCompiledCodeBuilder >> buildMethodHeader [

	^ memory minSmallInteger "Alternate Bytecode set to force Sista"
		+ (numberOfArguments bitShift: 24)
		+ (numberOfTemporaries bitShift: 18) 
		+ (isSmall ifTrue: [ 0 ] ifFalse: [ 1 bitShift: 17 ])
		+ literals size 
		+ (isPrimitive asBit << 16)
]

{ #category : #helper }
VMCompiledCodeBuilder >> bytecodeAt: anIndex forMethod: aMethodOop [
	| methodHeader |
	"1 based"
	methodHeader := memory methodHeaderOf: aMethodOop.

	^ (interpreter initialIPForHeader: methodHeader method: aMethodOop) + anIndex - 1.

]

{ #category : #accessing }
VMCompiledCodeBuilder >> bytecodes [
	^ bytecodes
]

{ #category : #accessing }
VMCompiledCodeBuilder >> bytecodes: anObject [
	bytecodes := anObject
]

{ #category : #filling }
VMCompiledCodeBuilder >> classIndexToUse [
	
	"This is not used anymore by the VM but we have to put something."
	^ 16
]

{ #category : #filling }
VMCompiledCodeBuilder >> fillFromPharoMethod: aCompiledMethod [ 

	self newMethod.
	self numberOfTemporaries: aCompiledMethod numTemps.
	self numberOfArguments: aCompiledMethod numArgs.
	self bytecodes: aCompiledMethod bytecode.
	self isPrimitive: aCompiledMethod isPrimitive.
	self fillLiteralsFromPharo: aCompiledMethod allLiterals 
]

{ #category : #filling }
VMCompiledCodeBuilder >> fillLiteralsFromPharo: pharoLiterals [

	originalLiterals := pharoLiterals copy.
	literals := originalLiterals collect: [ :e | memory nilObject ].

]

{ #category : #filling }
VMCompiledCodeBuilder >> fillMethod [
	self putHeaderInMethod.
	self putLiteralInMethod.
	self putBytecodesInMethod.
]

{ #category : #initialization }
VMCompiledCodeBuilder >> initialize [
	bytecodes := #[1 2 3 4 5 6 7 8 9 0].
	literals := OrderedCollection new. 
	originalLiterals := OrderedCollection new.
	isSmall := true.
	isPrimitive := false.
	numberOfArguments := 0.
	numberOfTemporaries := 0.
	
	"We reuse initialize to reset the builder, so we nil those objects"
	method := nil.
	slotSize := nil.
]

{ #category : #inspecting }
VMCompiledCodeBuilder >> inspectMethodIn: aBuilder [
	<inspectorPresentationOrder: 0 title: 'Items'> 

	| items |
	items :={
		#currentMethodOop -> method.
		#literals -> literals.
		#numberOfArguments -> numberOfArguments.
		#bytecodes -> bytecodes.
		#context -> (isSmall ifTrue: [ 'Small context '] ifFalse: [ 'Big context' ] ).
		#isPrimitive ->  isPrimitive.
		#slotSize ->  slotSize.
		 }.
	
	^ aBuilder newTable 
		addColumn: (SpStringTableColumn 
			title: 'Key'
			evaluated: [ :each | StObjectPrinter asTruncatedTextFrom: each key ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Value' 
			evaluated: [ :each | StObjectPrinter asTruncatedTextFrom: each value ])
			beSortable;
		items: items;
		yourself
]

{ #category : #building }
VMCompiledCodeBuilder >> instantiateMethod [
	slotSize := literals size 
			+ (bytecodes size / memory wordSize) ceiling
			+ 1 "method header".
	method := 
		memory allocateSlotsInOldSpace: slotSize
		format: (memory compiledMethodFormatForNumBytes: bytecodes size)
		classIndex: self classIndexToUse.
	
	method ifNotNil: [ memory fillObj: method numSlots: slotSize with: memory nilObject ].
]

{ #category : #accessing }
VMCompiledCodeBuilder >> isPrimitive [
	^ isPrimitive
]

{ #category : #accessing }
VMCompiledCodeBuilder >> isPrimitive: anObject [
	isPrimitive := anObject
]

{ #category : #accessing }
VMCompiledCodeBuilder >> isSmall [
	^ isSmall
]

{ #category : #accessing }
VMCompiledCodeBuilder >> isSmall: anObject [
	isSmall := anObject
]

{ #category : #accessing }
VMCompiledCodeBuilder >> literalAt: anIndex put: anOop [
	self collection: literals at: anIndex put: anOop
]

{ #category : #accessing }
VMCompiledCodeBuilder >> literals [
	^ literals
]

{ #category : #accessing }
VMCompiledCodeBuilder >> literals: anObject [
	literals := anObject.

]

{ #category : #accessing }
VMCompiledCodeBuilder >> method [
	^ method
]

{ #category : #building }
VMCompiledCodeBuilder >> newMethod [
	self initialize.
]

{ #category : #accessing }
VMCompiledCodeBuilder >> numberOfArguments [
	^ numberOfArguments
]

{ #category : #accessing }
VMCompiledCodeBuilder >> numberOfArguments: anObject [
	numberOfArguments := anObject
]

{ #category : #accessing }
VMCompiledCodeBuilder >> numberOfTemporaries [
	^ numberOfTemporaries
]

{ #category : #accessing }
VMCompiledCodeBuilder >> numberOfTemporaries: anObject [
	numberOfTemporaries := anObject
]

{ #category : #filling }
VMCompiledCodeBuilder >> putBytecodesInMethod [
	bytecodes doWithIndex:[ :aBytecode :anIndex | 
		memory storeByte: 
			(memory wordSize "First word is the header"
			+ (literals size * memory wordSize) "bytecodes are stored after literals"
			+ anIndex
			- 1) "0 based"
			ofObject: method 
			withValue: aBytecode
		]
]

{ #category : #filling }
VMCompiledCodeBuilder >> putHeaderInMethod [
	memory storePointer: 0 
		ofObject: method
		withValue: (memory integerObjectOf: self buildMethodHeader)

]

{ #category : #filling }
VMCompiledCodeBuilder >> putLiteralInMethod [

	originalLiterals doWithIndex: [ :aLiteral :anIndex | 
		"I will only transform the literals that has not been overriden."
		"I Skip the last 2 literals (selector/additional, association)"
		((literals at: anIndex) = memory nilObject and: [ 
			 anIndex < (originalLiterals size - 1) ]) ifTrue: [ 
			literals
				at: anIndex
				put: (aLiteral forMemory: memory inMethod: self) ] ].

	"the vm is 0 based, but anIndex will take the values 1 --- n,
	and the 0 indexed element is the header so it's okay."
	literals doWithIndex: [ :aLiteral :anIndex | 
		memory storePointer: anIndex ofObject: method withValue: aLiteral ]
]

{ #category : #filling }
VMCompiledCodeBuilder >> setOuterCode: aVMCompiledCodeBuilder [ 

	"In the case of CompiledBlocks we need to put the outerCode object (the last literal).
	We use the number of literals, as the VM is 0 based but the header is occupying the 0th index, everything works"

	literals at: literals size put: aVMCompiledCodeBuilder address
]

{ #category : #accessing }
VMCompiledCodeBuilder >> slotSize [
	"Do not set by hand !"
	^ slotSize
]
