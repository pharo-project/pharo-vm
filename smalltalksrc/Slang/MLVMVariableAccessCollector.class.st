Class {
	#name : #MLVMVariableAccessCollector,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'variableSubset',
		'alreadyVisited',
		'accessedVariables'
	],
	#category : #'Slang-CodeGeneration'
}

{ #category : #'instance creation' }
MLVMVariableAccessCollector class >> inCodeGenerator: aCodeGenerator fromGlobals: aCollection [ 
	
	^ self new
		codeGenerator: aCodeGenerator;
		variableSubset: aCollection;
		yourself
]

{ #category : #accessing }
MLVMVariableAccessCollector >> accessedVariables [
	^ accessedVariables
]

{ #category : #callgraph }
MLVMVariableAccessCollector >> analyzeCallGraphFromMessageSend: aTMessageSend [
	
	| method |
	method := codeGenerator methodNamed: aTMessageSend selector.
	
	"The method could be nil if not found in the list of methods to translate.
	This could be because the selector is either
	 - a special selector (+, /, perform: ...)
	 - a C selector (str:cpy:_:_:)
	 - or a selector that was inlined and removed by some other pass..."
	method ifNil: [ ^ self ].
	
	self analyzeCallGraphFromMethod: method
]

{ #category : #callgraph }
MLVMVariableAccessCollector >> analyzeCallGraphFromMethod: aTMethod [ 
	
	(alreadyVisited includes: aTMethod)
		ifTrue: [ ^ self ].
	alreadyVisited add: aTMethod.

	accessedVariables addAll: (aTMethod freeVariableReferences intersection: variableSubset).
	(aTMethod externalCallsIn: codeGenerator) do: [ :aTSendNode |
		self analyzeCallGraphFromMessageSend: aTSendNode
	]
]

{ #category : #accessing }
MLVMVariableAccessCollector >> codeGenerator [

	^ codeGenerator
]

{ #category : #accessing }
MLVMVariableAccessCollector >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #initialization }
MLVMVariableAccessCollector >> initialize [

	super initialize.
	accessedVariables := Set new.
	alreadyVisited := Set new.
]

{ #category : #accessing }
MLVMVariableAccessCollector >> variableSubset [

	^ variableSubset
]

{ #category : #accessing }
MLVMVariableAccessCollector >> variableSubset: anObject [

	variableSubset := anObject
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitAssignmentNode: aTAssignmentNode [ 
	
	aTAssignmentNode variable accept: self.
	aTAssignmentNode expression accept: self.
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitCastStatementNode: aTCaseStmtNode [ 
	
	"Do not recurse on children of a case statement.
	Children will be recursed as separate statements"
	aTCaseStmtNode expression accept: self
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitConstantNode: aTConstantNode [ 
	
	"Nothing for constants"
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitGoToNode: aTGoToNode [ 
	
	"Nothing"
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitInlineNode: aTInlineNode [
	
	"Do not recurse on children of an inline statement.
	Children will be recursed as separate statements"
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitLabeledCommentNode: aTLabeledCommentNode [ 
	
	"Nothing for now?"
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitReturnNode: aTReturnNode [ 
	
	"If we are doing a return node, we should externalize everything"
	accessedVariables addAll: variableSubset
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitSendNode: aTSendNode [ 
	
	(codeGenerator isDynamicCall: aTSendNode)
		ifTrue: [
			accessedVariables addAll: variableSubset.
			^ self ].

	aTSendNode receiver accept: self.
	aTSendNode arguments do: [ :argument | argument accept: self ].
	self analyzeCallGraphFromMessageSend: aTSendNode
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitStatementListNode: aTStatementListNode [ 
	
	aTStatementListNode statements do: [ :e | e accept: self ]
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitSwitchStatementNode: aTSwitchStmtNode [ 
	
	"Do not recurse on children of a case statement.
	Children will be recursed as separate statements"
	aTSwitchStmtNode expression accept: self
]

{ #category : #visiting }
MLVMVariableAccessCollector >> visitVariableNode: aTVariableNode [ 
	
	(variableSubset includes: aTVariableNode name)
		ifTrue: [ accessedVariables add: aTVariableNode name ]
]
