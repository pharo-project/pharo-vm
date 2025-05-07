Extension { #name : 'SLStatementOrExpressionAnnotatorTest' }

{ #category : '*VMMaker' }
SLStatementOrExpressionAnnotatorTest >> setUp [

	super setUp.
	sLStatementOrExpressionAnnotator := SLStatementOrExpressionAnnotator
		                                    new.
	ccg addClass: SLStatementOrExpressionAnnotatorTestClass.
	ccg inferTypes
]
