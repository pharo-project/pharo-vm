Extension { #name : 'SLAnnotatorVisitorTest' }

{ #category : '*VMMaker' }
SLAnnotatorVisitorTest >> setUp [

	super setUp.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor new.
	ccg addClass: SLNodeAnnotatorVisitorTestClass.
	nonEffectiveExpressionOrStatementCollection := OrderedCollection new.
	effectiveExpressionValueCollection := OrderedCollection new.
	"necessary to get the type of sqInt"
	SpurMemoryManager initBytesPerWord: 8.
	ccg inferTypes
]
