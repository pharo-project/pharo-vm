Extension { #name : #TParseNode }

{ #category : #'*VMMaker-Tools' }
TParseNode >> inspectNode [
	<inspectorPresentationOrder: 912 title: 'C (AST)'>

	^  SpTextPresenter new 
		text: (String streamContents: [ : stream | 
			(self asCASTIn: self newCodeGeneratorForInspection) prettyPrintOn: stream ]);
		yourself
]

{ #category : #'*VMMaker-Tools' }
TParseNode >> inspectNodeExpression [
	<inspectorPresentationOrder: 910 title: 'C (AST Expr)'>

	^  SpTextPresenter new 
		text: (String streamContents: [ : stream | 
			(self asCASTExpressionIn: self newCodeGeneratorForInspection) prettyPrintOn: stream ]);
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

{ #category : #'*VMMaker-Tools' }
TParseNode >> newCodeGeneratorForInspection [

	| cg |
	cg := MLVMCCodeGenerator new.
	cg vmMaker: VMMaker new.
	cg vmMaker vmmakerConfiguration: VMMakerConfiguration.
	cg currentMethod: (TMethod new
			 labels: Set new;
			 definingClass: self class;
			 yourself).
	cg pushScope: TStatementListNode new.
	^ cg
]
