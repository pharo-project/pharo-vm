Class {
	#name : 'SLOldInlineStrategy',
	#superclass : 'SLAbstractInlineStrategy',
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'inlining' }
SLOldInlineStrategy >> doInliningIn: aTMethod [

	^ aTMethod tryToInlineMethodsIn: codeGenerator
]
