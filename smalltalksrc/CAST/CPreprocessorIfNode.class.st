Class {
	#name : #CPreprocessorIfNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'then',
		'else',
		'if'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CPreprocessorIfNode class >> if: aCondition then: anExpression [

	^ self new
		  if: aCondition;
		  then: anExpression;
		  yourself
]

{ #category : #'instance creation' }
CPreprocessorIfNode class >> if: aCondition then: anExpression else: anOtherExpression [

	^ self new
		  if: aCondition;
		  then: anExpression;
		  else: anOtherExpression;
		  yourself
]

{ #category : #accessing }
CPreprocessorIfNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitPreprocessorIf: self
]

{ #category : #accessing }
CPreprocessorIfNode >> else [

	^ else
]

{ #category : #accessing }
CPreprocessorIfNode >> else: aStatement [

	else := aStatement
]

{ #category : #accessing }
CPreprocessorIfNode >> if [

	^ if
]

{ #category : #accessing }
CPreprocessorIfNode >> if: aStatement [

	if := aStatement
]

{ #category : #accessing }
CPreprocessorIfNode >> then [

	^ then
]

{ #category : #accessing }
CPreprocessorIfNode >> then: aStatement [

	then := aStatement
]
