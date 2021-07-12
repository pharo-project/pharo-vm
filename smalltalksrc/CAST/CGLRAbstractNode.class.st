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

{ #category : #testing }
CGLRAbstractNode >> isBinaryOperation [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isCastExpression [

	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isCompoundStatement [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isConstant [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isFunctionCall [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isFunctionDeclarator [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isIdentifier [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isLeaf [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> isUnaryOperation [
	
	^ false
]

{ #category : #testing }
CGLRAbstractNode >> needsSeparator [
	"By default all statements require a separator"
	^ true
]

{ #category : #testing }
CGLRAbstractNode >> needsTrailingSemicolon [ 
	
	^ true
]
