Extension { #name : #TParseNode }

{ #category : #'*VMMaker-Tools' }
TParseNode >> inspectionTree [
	<inspectorPresentationOrder: 35 title: 'Tree'>

	^ SpTreePresenter new 
		roots: { self };
		children: [ :aNode | aNode children ];
		display: [ :each | 
			String
				streamContents: [ :stream | 
					stream
						nextPutAll: each class name;
						nextPut: $(;
						nextPutAll: ((each asString truncateTo: 50) copyReplaceAll: String cr with: String space);
						nextPut: $)
			 ] ];
		expandAll;
		yourself
]
