Class {
	#name : #CPreprocessorDefineNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'token',
		'expression',
		'rawMacro'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CPreprocessorDefineNode class >> token: anIdentifier expression: anExpression [

	^ self new
		  token: anIdentifier;
		  expression: anExpression;
		  yourself
]

{ #category : #'instance creation' }
CPreprocessorDefineNode class >> token: anIdentifier rawMacro: aString [

	^ self new
		  token: anIdentifier;
		  rawMacro: aString;
		  yourself
]

{ #category : #generated }
CPreprocessorDefineNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitPreprocessorDefine: self
]

{ #category : #accessing }
CPreprocessorDefineNode >> expression [

	^ expression
]

{ #category : #accessing }
CPreprocessorDefineNode >> expression: anObject [

	expression := anObject
]

{ #category : #accessing }
CPreprocessorDefineNode >> rawMacro [

	^ rawMacro
]

{ #category : #accessing }
CPreprocessorDefineNode >> rawMacro: anObject [

	rawMacro := anObject
]

{ #category : #accessing }
CPreprocessorDefineNode >> token [

	^ token
]

{ #category : #accessing }
CPreprocessorDefineNode >> token: anObject [

	token := anObject
]
