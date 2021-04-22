Class {
	#name : #CCompoundStatementNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'declarations',
		'statements',
		'needsBrackets',
		'needsCarriageReturn'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CCompoundStatementNode class >> declarations: declarations statements: statements [

	^ self new
		declarations: declarations;
		statements: statements;
		yourself
]

{ #category : #'instance creation' }
CCompoundStatementNode class >> statements: statements [

	^ self declarations: #() statements: statements
]

{ #category : #comparing }
CCompoundStatementNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ statements = anObject statements and: [ 
		  declarations = anObject declarations ]
]

{ #category : #generated }
CCompoundStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitCompoundStatement: self
]

{ #category : #generated }
CCompoundStatementNode >> declarations [
	^ declarations
]

{ #category : #generated }
CCompoundStatementNode >> declarations: anOrderedCollection [
	self setParents: self declarations to: nil.
	declarations := anOrderedCollection.
	self setParents: self declarations to: self
]

{ #category : #comparing }
CCompoundStatementNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ statements hash bitXor: declarations hash
]

{ #category : #'generated-initialize-release' }
CCompoundStatementNode >> initialize [
	super initialize.
	statements := OrderedCollection new: 2.
	declarations := OrderedCollection new: 2.
	needsBrackets := true.
	needsCarriageReturn := true
]

{ #category : #testing }
CCompoundStatementNode >> isCompoundStatement [
	
	^ true
]

{ #category : #accessing }
CCompoundStatementNode >> needsBrackets [

	^ needsBrackets
]

{ #category : #accessing }
CCompoundStatementNode >> needsBrackets: anObject [

	needsBrackets := anObject
]

{ #category : #accessing }
CCompoundStatementNode >> needsCarriageReturn [

	^ needsCarriageReturn
]

{ #category : #accessing }
CCompoundStatementNode >> needsCarriageReturn: aBoolean [

	needsCarriageReturn := aBoolean
]

{ #category : #generated }
CCompoundStatementNode >> statements [
	^ statements
]

{ #category : #generated }
CCompoundStatementNode >> statements: anOrderedCollection [
	self setParents: self statements to: nil.
	statements := anOrderedCollection.
	self setParents: self statements to: self
]
