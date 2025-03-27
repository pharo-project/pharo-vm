Extension { #name : 'SLLocalizationTest' }

{ #category : '*VMMaker' }
SLLocalizationTest >> setUp [

	ccg := MLVMCCodeGeneratorLocalizationMock new.
	ccg vmClass: VMClass.
	ccg vmMaker: VMMaker new.
	ccg vmMaker vmmakerConfiguration: VMMakerConfiguration.
	ccg declareVar: #globalWithNoUsage type: #int.
	ccg declareVar: #globalWithUsage type: #int.
	ccg declareVar: #globalToLocalize type: #int.
	ccg declareVar: #globalMustBeGlobal type: #int.
	ccg addClass: SLLocalizationTestClass
]
