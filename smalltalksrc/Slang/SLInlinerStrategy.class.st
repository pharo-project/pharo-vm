Class {
	#name : 'SLInlinerStrategy',
	#superclass : 'SLInlineStrategy',
	#instVars : [
		'sLInliner'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'inlining' }
SLInlinerStrategy >> doInliningIn: aTMethod [

	sLInliner currentMethod: aTMethod.
	sLInliner codeGenerator: codeGenerator.
	^ sLInliner tryToInlineMethodsInCurrentMethod
]

{ #category : 'initialization' }
SLInlinerStrategy >> initialize [

	super initialize.
	sLInliner := SLInliner new
]
