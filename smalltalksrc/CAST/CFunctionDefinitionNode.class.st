Class {
	#name : #CFunctionDefinitionNode,
	#superclass : #CGLRAbstractNode,
	#instVars : [
		'declarator',
		'body',
		'specifiers',
		'arguments',
		'hasRawPrototype'
	],
	#category : #'CAST-Nodes'
}

{ #category : #'instance creation' }
CFunctionDefinitionNode class >> declarator: aDeclarator body: aBlock specifiers: specifiers [

	^ self new
		  declarator: aDeclarator;
		  body: aBlock;
		  specifiers: specifiers;
		  yourself
]

{ #category : #'instance creation' }
CFunctionDefinitionNode class >> declarator: aDeclarator body: aBlock specifiers: specifiers arguments: arguments [

	^ self new
		  declarator: aDeclarator;
		  body: aBlock;
		  specifiers: specifiers;
		  arguments: arguments;
		  yourself
]

{ #category : #'instance creation' }
CFunctionDefinitionNode class >> declarator: aDeclarator specifiers: specifiers [

	^ self new
		  declarator: aDeclarator;
		  specifiers: specifiers;
		  yourself
]

{ #category : #'instance creation' }
CFunctionDefinitionNode class >> declarator: aDeclarator specifiers: specifiers arguments: arguments [

	^ self new
		  declarator: aDeclarator;
		  specifiers: specifiers;
		  arguments: arguments;
		  yourself
]

{ #category : #generated }
CFunctionDefinitionNode >> acceptVisitor: anAbstractVisitor [
	^ anAbstractVisitor visitFunctionDefinition: self
]

{ #category : #generated }
CFunctionDefinitionNode >> arguments [
	^ arguments
]

{ #category : #generated }
CFunctionDefinitionNode >> arguments: anOrderedCollection [
	self setParents: self arguments to: nil.
	arguments := anOrderedCollection.
	self setParents: self arguments to: self
]

{ #category : #generated }
CFunctionDefinitionNode >> body [
	^ body
]

{ #category : #generated }
CFunctionDefinitionNode >> body: aCGLRCompoundStatementNode [
	self body notNil
		ifTrue: [ self body parent: nil ].
	body := aCGLRCompoundStatementNode.
	self body notNil
		ifTrue: [ self body parent: self ]
]

{ #category : #accessing }
CFunctionDefinitionNode >> declarations [
	
	^ body declarations
]

{ #category : #generated }
CFunctionDefinitionNode >> declarator [
	^ declarator
]

{ #category : #generated }
CFunctionDefinitionNode >> declarator: aCGLRDeclaratorNode [
	self declarator notNil
		ifTrue: [ self declarator parent: nil ].
	declarator := aCGLRDeclaratorNode.
	self declarator notNil
		ifTrue: [ self declarator parent: self ]
]

{ #category : #accessing }
CFunctionDefinitionNode >> hasRawPrototype [

	^ hasRawPrototype
]

{ #category : #accessing }
CFunctionDefinitionNode >> hasRawPrototype: aBoolean [

	hasRawPrototype := aBoolean
]

{ #category : #'generated-initialize-release' }
CFunctionDefinitionNode >> initialize [
	super initialize.
	hasRawPrototype := false.
	specifiers := OrderedCollection new: 2.
	arguments := OrderedCollection new: 2.
]

{ #category : #generated }
CFunctionDefinitionNode >> isPrototype [

	^ body isNil
]

{ #category : #testing }
CFunctionDefinitionNode >> needsSeparator [

	^ false
]

{ #category : #testing }
CFunctionDefinitionNode >> needsTrailingSemicolon [

	^ false
]

{ #category : #generated }
CFunctionDefinitionNode >> specifiers [
	^ specifiers
]

{ #category : #generated }
CFunctionDefinitionNode >> specifiers: anOrderedCollection [
	specifiers := anOrderedCollection
]

{ #category : #accessing }
CFunctionDefinitionNode >> statements [
	
	^ body statements 
]
