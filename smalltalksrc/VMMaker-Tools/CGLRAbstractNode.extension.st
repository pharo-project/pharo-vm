Extension { #name : 'CGLRAbstractNode' }

{ #category : '*VMMaker-Tools' }
CGLRAbstractNode >> inspectNode: specBuilder [
	<inspectorPresentationOrder: 910 title: 'C'>

	^  SpTextPresenter new 
		text: (String streamContents: [ : stream | self prettyPrintOn: stream ]);
		yourself   
]
