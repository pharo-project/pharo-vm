Class {
	#name : 'SLAbstractInlineStrategy',
	#superclass : 'Object',
	#instVars : [
		'codeGenerator'
	],
	#category : 'Slang',
	#package : 'Slang'
}

{ #category : 'accessing' }
SLAbstractInlineStrategy class >> codeGenerator: aCodeGenerator [

	^ self new
		  codeGenerator: aCodeGenerator;
		  yourself
]

{ #category : 'accessing' }
SLAbstractInlineStrategy >> codeGenerator: aCodeGenerator [

	codeGenerator := aCodeGenerator
]

{ #category : 'inlining' }
SLAbstractInlineStrategy >> doInliningIn: aTMethod [

	self subclassResponsibility
]
