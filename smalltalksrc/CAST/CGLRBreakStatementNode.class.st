Class {
	#name : #CGLRBreakStatementNode,
	#superclass : #CGLRAbstractNode,
	#category : #CAST
}

{ #category : #generated }
CGLRBreakStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitBreakStatement: self
]
