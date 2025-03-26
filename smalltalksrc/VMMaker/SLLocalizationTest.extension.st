Extension { #name : 'SLLocalizationTest' }

{ #category : '*VMMaker' }
SLLocalizationTest >> setUp [

	super setUp.
	ccg declareVar: #globalWithNoUsage type: #int.
	ccg declareVar: #globalWithUsage type: #int.
	ccg declareVar: #globalToLocalize type: #int.
	ccg declareVar: #globalMustBeGlobal type: #int
]
