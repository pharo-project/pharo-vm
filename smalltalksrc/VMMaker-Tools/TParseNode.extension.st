Extension { #name : #TParseNode }

{ #category : #'*VMMaker-Tools' }
TParseNode >> inspectNode: specBuilder [
	<inspectorPresentationOrder: 910 title: 'C'>

	^  SpTextPresenter new 
		text: (String streamContents: [ : stream | 
			| cg |
			cg := MLVMCCodeGenerator new.
			cg vmMaker: VMMaker new.
			cg vmMaker vmmakerConfiguration: VMMakerConfiguration.
			cg currentMethod: (TMethod new
					labels: Set new;
					definingClass: self class;
					yourself).
			cg pushScope: TStatementListNode new.
			(self respondsTo: #expression)
				ifTrue: [ (self asCASTExpressionIn: cg) prettyPrintOn: stream ]
				ifFalse: [ (self asCASTIn: cg) prettyPrintOn: stream ] ]);
		yourself   
]

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
						nextPutAll: each displayString;
						nextPut: $)
			 ] ];
		expandAll;
		yourself
]
