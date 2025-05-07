Extension { #name : 'SlangInliningTest' }

{ #category : '*VMMaker' }
SlangInliningTest >> setUp [

	super setUp.
	ccg addClass: SLMockInliningTestClass.
	sLInliner := SLInliner new
]
