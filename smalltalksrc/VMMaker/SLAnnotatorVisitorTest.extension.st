Extension { #name : 'SLAnnotatorVisitorTest' }

{ #category : '*VMMaker' }
SLAnnotatorVisitorTest >> setUp [

	super setUp.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor new.
	ccg addClass: SLNodeAnnotatorVisitorTestClass.
	nonEffectiveExpressionOrStatementCollection := OrderedCollection new.
	effectiveExpressionValueCollection := OrderedCollection new.
	ccg inferTypes
]
