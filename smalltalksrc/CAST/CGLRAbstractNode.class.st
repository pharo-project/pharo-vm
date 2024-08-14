Class {
	#name : 'CGLRAbstractNode',
	#superclass : 'SmaCCParseNode',
	#instVars : [
		'needsSeparator'
	],
	#category : 'CAST',
	#package : 'CAST'
}

{ #category : 'generated' }
CGLRAbstractNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitAbstract: self
]

{ #category : 'accessing' }
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

{ #category : 'asserting' }
CGLRAbstractNode >> assertExpression: aNode [

	self assert: aNode isExpression
]

{ #category : 'asserting' }
CGLRAbstractNode >> assertListOfExpressions: aCollection [ 
	
	self assert: (aCollection allSatisfy: [ :e | e isExpression ])
]

{ #category : 'testing' }
CGLRAbstractNode >> comments [

	^ super comments ifNil: [ #() ]
]

{ #category : 'testing' }
CGLRAbstractNode >> initialize [

	super initialize.
	needsSeparator := true
]

{ #category : 'testing' }
CGLRAbstractNode >> isBinaryOperation [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isCastExpression [

	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isComment [ 
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isCompoundStatement [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isConstant [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isEmpty [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isEmptyStatement [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isExpression [

	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isFunctionCall [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isFunctionDeclarator [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isIdentifier [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isLeaf [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isReturn [
	
	^ false
]

{ #category : 'testing' }
CGLRAbstractNode >> isUnaryOperation [
	
	^ false
]

{ #category : 'rewriting' }
CGLRAbstractNode >> last [
	"I'm the last statement of myself"
	^ self
]

{ #category : 'rewriting' }
CGLRAbstractNode >> last: aReplacement [
	
	"I replace myself by the node as argument"
	^ aReplacement
]

{ #category : 'accessing' }
CGLRAbstractNode >> needsSeparator [

	^ needsSeparator
]

{ #category : 'accessing' }
CGLRAbstractNode >> needsSeparator: aBoolean [

	needsSeparator := aBoolean
]

{ #category : 'testing' }
CGLRAbstractNode >> needsTrailingSemicolon [ 
	
	^ true
]
