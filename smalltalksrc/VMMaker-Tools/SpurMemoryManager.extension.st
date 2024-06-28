Extension { #name : #SpurMemoryManager }

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> asVMOop: oop [
	<doNotGenerate>

	^ VMOop new
		memory: self;
		oop: oop;
		yourself.
]

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> inspectorEntities: composite [

	<inspectorPresentationOrder: 2 title: 'Entities'>

	| entities unscannedEphemeronList |
	entities := self allHeapEntities collect: [ :oop | self asVMOop: oop ].
	unscannedEphemeronList := #().
	unscannedEphemerons start ifNotNil: [ unscannedEphemeronList := (unscannedEphemerons start to: unscannedEphemerons top - self bytesPerOop by: self bytesPerOop) collect: [ :p | self longAt: p] ].

	^ SpTreeTablePresenter new
"		alternateRowsColor;"
		enableSearch;
		items: entities;
		children: [ :oop | oop pointers ];
		addColumn: (SpStringTableColumn title: 'Oop' evaluated: [ :oop | oop oop ]);
		addColumn: (SpStringTableColumn title: 'Oop(hex)' evaluated: [ :oop | oop oop hex ]);
		addColumn: (SpStringTableColumn title: 'Label' evaluated: [ :oop | oop label ]);
		addColumn: (SpStringTableColumn title: 'Type' evaluated: [ :oop | oop type ]);
		addColumn: (SpStringTableColumn title: 'classIndex' evaluated: [ :oop | oop classIndex ]);
		addColumn: (SpStringTableColumn title: 'rawNumSlots' evaluated: [ :oop | oop rawNumSlots ]);
		addColumn: (SpStringTableColumn title: 'numSlots' evaluated: [ :oop | oop numSlots ]);
		addColumn: (SpStringTableColumn title: 'bytes' evaluated: [ :oop | oop bytes ]);
		addColumn: (SpStringTableColumn title: '1st pointer' evaluated: [ :oop | oop pointer: 0 ]);
		addColumn: (SpStringTableColumn title: 'Format' evaluated: [ :oop | oop format ]);
		addColumn: (SpStringTableColumn title: 'Flags&Misc' evaluated: [ :oop | oop flags,
			 ((unscannedEphemeronList includes: oop oop) ifTrue: ['U'] ifFalse: ['.'])]);
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

{ #category : #'*VMMaker-Tools' }
SpurMemoryManager >> inspectorOldSpaceEntities: composite [

	<inspectorPresentationOrder: 3 title: 'Old Space Entities'>

	| entities unscannedEphemeronList |
	entities := self allOldSpaceEntities collect: [ :oop | self asVMOop: oop ].
	unscannedEphemeronList := #().
	unscannedEphemerons start ifNotNil: [ unscannedEphemeronList := (unscannedEphemerons start to: unscannedEphemerons top - self bytesPerOop by: self bytesPerOop) collect: [ :p | self longAt: p] ].

	^ SpTreeTablePresenter new
"		alternateRowsColor;"
		enableSearch;
		items: entities;
		children: [ :oop | oop pointers ];
		addColumn: (SpStringTableColumn title: 'Oop' evaluated: [ :oop | oop oop ]);
		addColumn: (SpStringTableColumn title: 'Oop(hex)' evaluated: [ :oop | oop oop hex ]);
		addColumn: (SpStringTableColumn title: 'Label' evaluated: [ :oop | oop label ]);
		addColumn: (SpStringTableColumn title: 'Type' evaluated: [ :oop | oop type ]);
		addColumn: (SpStringTableColumn title: 'classIndex' evaluated: [ :oop | oop classIndex ]);
		addColumn: (SpStringTableColumn title: 'rawNumSlots' evaluated: [ :oop | oop rawNumSlots ]);
		addColumn: (SpStringTableColumn title: 'numSlots' evaluated: [ :oop | oop numSlots ]);
		addColumn: (SpStringTableColumn title: 'bytes' evaluated: [ :oop | oop bytes ]);
		addColumn: (SpStringTableColumn title: '1st pointer' evaluated: [ :oop | oop pointer: 0 ]);
		addColumn: (SpStringTableColumn title: 'Format' evaluated: [ :oop | oop format ]);
		addColumn: (SpStringTableColumn title: 'Flags&Misc' evaluated: [ :oop | oop flags,
			 ((unscannedEphemeronList includes: oop oop) ifTrue: ['U'] ifFalse: ['.'])]);
		yourself

]
