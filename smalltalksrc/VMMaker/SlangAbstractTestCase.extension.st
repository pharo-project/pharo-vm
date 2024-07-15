Extension { #name : 'SlangAbstractTestCase' }

{ #category : '*VMMaker' }
SlangAbstractTestCase >> setUp [

	super setUp.
	ccg := MLVMCCodeGeneratorConflictMock new.
	ccg vmMaker: VMMaker new.
	ccg vmMaker vmmakerConfiguration: VMMakerConfiguration
]
