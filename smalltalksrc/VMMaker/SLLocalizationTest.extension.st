Extension { #name : 'SLLocalizationTest' }

{ #category : '*VMMaker' }
SLLocalizationTest >> setUp [

	ccg := MLVMCCodeGeneratorLocalizationMock new.
	ccg vmClass: VMClass.
	ccg vmMaker: VMMaker new.
	ccg vmMaker vmmakerConfiguration: VMMakerConfiguration.
	ccg declareVar: #globalMustBeGlobal type: #int.
	ccg addClass: SLLocalizationTestClass
]
