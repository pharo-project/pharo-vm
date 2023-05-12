Class {
	#name : #CGLRContinueStatementNode,
	#superclass : #CGLRAbstractNode,
	#category : #CAST
}

{ #category : #generated }
CGLRContinueStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitContinueStatement: self
]
