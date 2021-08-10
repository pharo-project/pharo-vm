Class {
	#name : #CEmptyStatementNode,
	#superclass : #CGLRAbstractNode,
	#category : #'CAST-Nodes'
}

{ #category : #testing }
CEmptyStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitEmptyStatement: self
]

{ #category : #testing }
CEmptyStatementNode >> isEmpty [
	
	^ true
]

{ #category : #testing }
CEmptyStatementNode >> isEmptyStatement [
	
	^ true
]
