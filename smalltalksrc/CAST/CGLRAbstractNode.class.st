Class {
	#name : #CGLRAbstractNode,
	#superclass : #SmaCCParseNode,
	#category : #CAST
}

{ #category : #generated }
CGLRAbstractNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitAbstract: self
]

{ #category : #accessing }
CGLRAbstractNode >> ambiguous: aNode [
	(aNode class == self class
		and: [ self children size = aNode children size ])
		ifFalse: [ (self
				attributeNamed: #ambiguous
				ifAbsentPut: [ OrderedCollection new ]) add: aNode ]
		ifTrue: [ self children
				with: aNode children
				do: [ :n1 :n2 | n1 ambiguous: n2 ] ]
]
