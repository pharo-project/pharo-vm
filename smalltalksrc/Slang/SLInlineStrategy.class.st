Class {
	#name : 'SLInlineStrategy',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'accessing' }
SLInlineStrategy class >> codeGenerator: aCodeGenerator [

	^ self new
		  codeGenerator: aCodeGenerator;
		  yourself
]

{ #category : 'accessing' }
SLInlineStrategy >> codeGenerator: aCodeGenerator [

	codeGenerator := aCodeGenerator
]

{ #category : 'inlining' }
SLInlineStrategy >> doInliningIn: aTMethod [

	self subclassResponsibility
]
