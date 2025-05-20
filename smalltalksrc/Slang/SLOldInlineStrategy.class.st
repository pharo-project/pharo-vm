Class {
	#name : 'SLOldInlineStrategy',
	#superclass : 'SLInlineStrategy',
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'inlining' }
SLOldInlineStrategy >> doInliningIn: aTMethod [

	^ aTMethod tryToInlineMethodsIn: codeGenerator
]
