Extension { #name : 'SLInliningTest' }

{ #category : '*VMMaker' }
SLInliningTest >> setUp [
	super setUp.	
	
	self perform: inliningStrategy.
	inliner codeGenerator: ccg.
	ccg inliner: inliner.
	
	ccg addClass: SLMockInliningTestClass.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes.
	sLInliner := SLInlinerWithAnnotation new
]
