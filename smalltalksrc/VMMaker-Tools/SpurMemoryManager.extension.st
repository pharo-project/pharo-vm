Extension { #name : #SpurMemoryManager }

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
