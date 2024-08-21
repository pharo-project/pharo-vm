Class {
	#name : 'CBreakStatementNode',
	#superclass : 'CGLRAbstractNode',
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'generated' }
CBreakStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitBreakStatement: self
]

{ #category : 'testing' }
CBreakStatementNode >> isBreakStatement [

	^true
]
