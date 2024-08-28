Class {
	#name : 'CCompoundStatementNode',
	#superclass : 'CGLRAbstractNode',
	#instVars : [
		'declarations',
		'statements',
		'needsBrackets'
	],
	#category : 'CAST-Nodes',
	#package : 'CAST',
	#tag : 'Nodes'
}

{ #category : 'instance creation' }
CCompoundStatementNode class >> declarations: declarations statements: statements [

	^ self new
		declarations: declarations;
		statements: statements;
		yourself
]

{ #category : 'instance creation' }
CCompoundStatementNode class >> statements: statements [

	^ self new
		  statements: statements;
		  yourself
]

{ #category : 'comparing' }
CCompoundStatementNode >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ statements = anObject statements and: [ 
		  declarations = anObject declarations ]
]

{ #category : 'generated' }
CCompoundStatementNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitCompoundStatement: self
]

{ #category : 'adding' }
CCompoundStatementNode >> add: aStatement [

	statements add: aStatement
]

{ #category : 'adding' }
CCompoundStatementNode >> addAll: aCompoundStatement [

	statements addAll: aCompoundStatement statements
]

{ #category : 'accessing' }
CCompoundStatementNode >> comment [

	^ self statements first comment
]

{ #category : 'generated' }
CCompoundStatementNode >> declarations [
	^ declarations
]

{ #category : 'generated' }
CCompoundStatementNode >> declarations: anOrderedCollection [
	self setParents: self declarations to: nil.
	declarations := anOrderedCollection.
	self setParents: self declarations to: self
]

{ #category : 'comparing' }
CCompoundStatementNode >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ statements hash bitXor: declarations hash
]

{ #category : 'generated-initialize-release' }
CCompoundStatementNode >> initialize [
	super initialize.
	statements := OrderedCollection new: 2.
	declarations := OrderedCollection new: 2.
	needsBrackets := true.
	needsSeparator := false
]

{ #category : 'testing' }
CCompoundStatementNode >> isComment [

	^ self statements size = 1 and: [ self statements first isComment ]
]

{ #category : 'testing' }
CCompoundStatementNode >> isCompoundStatement [
	
	^ true
]

{ #category : 'testing' }
CCompoundStatementNode >> isEmpty [
	
	^ statements isEmpty or: [ statements allSatisfy: [ :e | e isEmpty ] ]
]

{ #category : 'accessing' }
CCompoundStatementNode >> last [
	"For some unknown reason, the some compound can be empty."
	[ statements last isEmpty ] whileTrue: [ statements removeAt: statements size ].
	"Recursive call to get the real last if last is also a compound"
	^ statements last last
]

{ #category : 'accessing' }
CCompoundStatementNode >> last: aCReturnStatementNode [ 
	
	"We rewrite the tree recursively.
	Since the last statement of a compound statement can be another compound statement,
	we need to rewrite the last statement of the deepest one"
	statements
		at: statements size
		put: (statements last last: aCReturnStatementNode)
]

{ #category : 'accessing' }
CCompoundStatementNode >> needsBrackets [

	^ needsBrackets
]

{ #category : 'accessing' }
CCompoundStatementNode >> needsBrackets: anObject [

	needsBrackets := anObject
]

{ #category : 'testing' }
CCompoundStatementNode >> needsTrailingSemicolon [

	^ false
]

{ #category : 'generated' }
CCompoundStatementNode >> statements [
	^ statements
]

{ #category : 'generated' }
CCompoundStatementNode >> statements: anOrderedCollection [
	self setParents: self statements to: nil.
	statements := anOrderedCollection.
	self setParents: self statements to: self
]
