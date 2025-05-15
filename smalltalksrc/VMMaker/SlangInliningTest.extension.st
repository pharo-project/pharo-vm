Extension { #name : 'SlangInliningTest' }

{ #category : '*VMMaker' }
SlangInliningTest >> setUp [

	super setUp.
	ccg addClass: SLMockInliningTestClass.
	ccg inferTypes.
	sLInliner := SLInliner new
]
