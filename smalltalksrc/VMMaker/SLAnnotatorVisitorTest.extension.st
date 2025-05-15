Extension { #name : 'SLAnnotatorVisitorTest' }

{ #category : '*VMMaker' }
SLAnnotatorVisitorTest >> setUp [

	super setUp.
	sLNodeAnnotatorVisitor := SLNodeAnnotatorVisitor
		                                    new.
	ccg addClass: SLNodeAnnotatorVisitorTestClass.
	ccg inferTypes
]
