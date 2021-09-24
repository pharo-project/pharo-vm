Class {
	#name : #TExternalSendNode,
	#superclass : #TParseNode,
	#instVars : [
		'variableBindings',
		'wrappedSendNode'
	],
	#category : #'Slang-AST'
}

{ #category : #'instance-creation' }
TExternalSendNode class >> send: aWrappedSendNode variableBindings: bindings [

	^ self new
		wrappedSendNode: aWrappedSendNode;
		variableBindings: bindings;
		yourself
]

{ #category : #tranforming }
TExternalSendNode >> asCASTIn: aCodeGenerator [

	^ CCompoundStatementNode statements: (self cExternalizationsIn: aCodeGenerator)
		  , { (wrappedSendNode asCASTIn: aCodeGenerator) }
		  , (self cInternalizationsIn: aCodeGenerator)
]

{ #category : #'c-translation' }
TExternalSendNode >> cExternalizationsIn: codeGenerator [
	
	| tAssignments |
	tAssignments := OrderedCollection new.
	variableBindings keysAndValuesDo: [ :global :local |
		tAssignments add: (TAssignmentNode
			variable: (TVariableNode named: global)
			expression: (TVariableNode named: local name))
	].

	^ tAssignments collect: [ :e | e asCASTIn: codeGenerator ]
]

{ #category : #'c-translations' }
TExternalSendNode >> cInternalizationsIn: codeGenerator [
	
	| tAssignments |
	tAssignments := OrderedCollection new.
	variableBindings keysAndValuesDo: [ :global :local |
		tAssignments add: (TAssignmentNode
			variable: (TVariableNode named: local name)
			expression: (TVariableNode named: global))
	].

	^ tAssignments collect: [ :e | e asCASTIn: codeGenerator ]
]

{ #category : #accessing }
TExternalSendNode >> isExternalSend [

	^ true
]

{ #category : #accessing }
TExternalSendNode >> localizedVariables [
	
	^ variableBindings keys
]

{ #category : #accessing }
TExternalSendNode >> nodesDo: aBlock [

	aBlock value: wrappedSendNode.
	super nodesDo: aBlock
]

{ #category : #accessing }
TExternalSendNode >> variableBindings [
	^ variableBindings
]

{ #category : #accessing }
TExternalSendNode >> variableBindings: aCollection [
	
	variableBindings := aCollection 
]

{ #category : #accessing }
TExternalSendNode >> wrappedSendNode [

	^ wrappedSendNode
]

{ #category : #accessing }
TExternalSendNode >> wrappedSendNode: anObject [

	wrappedSendNode := anObject
]
