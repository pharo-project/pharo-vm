Class {
	#name : 'CGLRContinueStatementNode',
	#superclass : 'CGLRAbstractNode',
	#category : 'CAST',
	#package : 'CAST'
}

{ #category : 'generated' }
CGLRContinueStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitContinueStatement: self
]
