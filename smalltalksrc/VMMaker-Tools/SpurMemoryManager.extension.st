Extension { #name : #SpurMemoryManager }

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> asVMOop: oop [

	^ VMOop new
		memory: self;
		oop: oop;
		yourself.
]

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> inspectorEntities: composite [

	<inspectorPresentationOrder: 2 title: 'Entities'>

	| entities |
	entities := OrderedCollection new.
	self allHeapEntitiesDo: [ :e | entities add: e ].

	^ SpTablePresenter new
		alternateRowsColor;
		enableSearch;
		items: entities;
		addColumn: (SpStringTableColumn title: 'Oop' evaluated: [ :oop | oop ]);
		addColumn: (SpStringTableColumn title: 'Oop(hex)' evaluated: [ :oop | oop hex ]);
		addColumn: (SpStringTableColumn title: 'Label' evaluated: [ :oop | self labelOfOop: oop ]);
		addColumn: (SpStringTableColumn title: 'Type' evaluated: [ :oop |
				((self isFreeObject: oop) ifTrue: ['free'] ifFalse:
				[(self isSegmentBridge: oop) ifTrue: ['bridge'] ifFalse:
				[(self isForwarded: oop) ifTrue: ['forwarder'] ifFalse:
				[(self classIndexOf: oop) <= self lastClassIndexPun ifTrue: ['pun/obj stack'] ifFalse:
				['object']]]]) ]);
		addColumn: (SpStringTableColumn title: 'classIndex' evaluated: [ :oop | self classIndexOf: oop ]);
		addColumn: (SpStringTableColumn title: 'rawNumSlots' evaluated: [ :oop | self rawNumSlotsOf: oop ]);
		addColumn: (SpStringTableColumn title: 'numSlots' evaluated: [ :oop |
			self numSlotsOfAny: oop ]);
		addColumn: (SpStringTableColumn title: 'bytesInObject' evaluated: [ :oop | self bytesInObject: oop ]);
		addColumn: (SpStringTableColumn title: '1st field' evaluated: [ :oop |
			(self isFreeObject: oop) ifTrue: [ self fetchPointer: 0 ofFreeChunk: oop ] ifFalse:
			[(self isSegmentBridge: oop) ifTrue: [ '' ] ifFalse:
			[(self isForwarded: oop) ifTrue: [ self followForwarded: oop ] ifFalse:
			[((self numSlotsOfAny: oop) > 0) ifTrue: [ self fetchPointer: 0 ofObject: oop ] ifFalse:
			[ '' ]]]]]);
		addColumn: (SpStringTableColumn title: 'Format' evaluated: [ :oop | 
			 ((self formatOf: oop) <= 16rF ifTrue: ['0'] ifFalse: ['']),
			 (self formatOf: oop) printStringHex, ' ',
			 (self formatStringOf: oop)]);
		addColumn: (SpStringTableColumn title: 'Flags' evaluated: [ :oop | 
			 ((self isGrey: oop) ifTrue: ['g'] ifFalse: ['.']),
			 ((self isImmutable: oop) ifTrue: ['i'] ifFalse: ['.']),
			 ((self isMarked: oop) ifTrue: ['m'] ifFalse: ['.']),
			 ((self isPinned: oop) ifTrue: ['p'] ifFalse: ['.']),
			 ((self isRemembered: oop) ifTrue: ['r'] ifFalse: ['.'])]);
		yourself

]

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> inspectorFreeListIn: composite [

	<inspectorPresentationOrder: 0 title: 'Free Lists'>

	^ SpTreeTablePresenter  new
		roots: (VMTFreeLists on: self) children;
		children: [ :aNode | aNode hasChildren ifTrue: [aNode children] ifFalse: [ #() ] ];
		addColumn: (SpStringTableColumn title: 'Label' evaluated: [ :aNode | aNode printString ]);
		addColumn: (SpStringTableColumn title: 'Size' evaluated: [ :aNode | aNode size ])

]

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> inspectorHiddenRootsIn: composite [

	<inspectorPresentationOrder: 0 title: 'HiddenRoots'>

	^ SpTablePresenter new
		items: (VMTHiddenRootTable on: self) children;
		addColumn: (SpStringTableColumn title: 'Index' evaluated: [ :hiddenRoot | hiddenRoot index ]);
		addColumn: (SpStringTableColumn title: 'Label' evaluated: [ :hiddenRoot | hiddenRoot label ]);
		addColumn: (SpStringTableColumn title: 'Address' evaluated: [ :hiddenRoot | hiddenRoot oop ])

]
