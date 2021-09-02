Class {
	#name : #CBreakStatementNode,
	#superclass : #CGLRAbstractNode,
	#category : #'CAST-Nodes'
}

{ #category : #generated }
CBreakStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitBreakStatement: self
]

{ #category : #testing }
CBreakStatementNode >> isBreakStatement [

	^true
]
