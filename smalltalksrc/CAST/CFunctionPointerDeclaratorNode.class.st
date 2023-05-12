Class {
	#name : #CFunctionPointerDeclaratorNode,
	#superclass : #CAbstractDeclaratorNode,
	#category : #'CAST-Nodes'
}

{ #category : #comparing }
CFunctionPointerDeclaratorNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ declarator = anObject declarator2
]

{ #category : #generated }
CFunctionPointerDeclaratorNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitFunctionPointerDeclarator: self
]

{ #category : #accessing }
CFunctionPointerDeclaratorNode >> declarator2 [

	^ declarator
]

{ #category : #comparing }
CFunctionPointerDeclaratorNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ declarator hash
]
