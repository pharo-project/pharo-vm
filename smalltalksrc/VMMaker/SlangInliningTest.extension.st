Extension { #name : 'SlangInliningTest' }

{ #category : '*VMMaker' }
SlangInliningTest >> setUp [

	super setUp.
	ccg addClass: SLMockInliningTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes.
	sLInliner := SLInlinerWithAnnotation new
]
