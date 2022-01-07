"
I am a visitor starting from a statement that accumulates all used variables that should be localized/externalized around the statement.
I use a SLCallGraphFreeVariableCollector to visit methods calls I find in the statement.

CAREFUL: I am a stateful AST visitor and I cannot be reused.

Once instantiated and used, the variables are accessed through the #localizableVariables message.

# Usage

```smalltalk
collector := SLLocalizableVariableCollector
             inCodeGenerator: codeGenerator
             localizableCandidateVariables: replacementDict keys
             callgraphVariableCollector: callgraphVariableCollector.
aStatement accept: collector.
collector localizableVariables.
```
"
Class {
	#name : #SLLocalizableVariableCollector,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'alreadyVisited',
		'callgraphVariableCollector',
		'localizableCandidateVariables',
		'localizableVariables'
	],
	#category : #'Slang-Optimizations'
}

{ #category : #'instance creation' }
SLLocalizableVariableCollector class >> inCodeGenerator: aCodeGenerator localizableCandidateVariables: aCollectionOfCandidates callgraphVariableCollector: aCollector [
	
	^ self new
		codeGenerator: aCodeGenerator;
		localizableCandidateVariables: aCollectionOfCandidates;
		callgraphVariableCollector: aCollector;
		yourself
]

{ #category : #accessing }
SLLocalizableVariableCollector >> callgraphVariableCollector [

	^ callgraphVariableCollector
]

{ #category : #accessing }
SLLocalizableVariableCollector >> callgraphVariableCollector: anObject [

	callgraphVariableCollector := anObject
]

{ #category : #accessing }
SLLocalizableVariableCollector >> codeGenerator [

	^ codeGenerator
]

{ #category : #accessing }
SLLocalizableVariableCollector >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #initialization }
SLLocalizableVariableCollector >> initialize [

	super initialize.
	localizableVariables := Set new.
	alreadyVisited := Set new.
]

{ #category : #accessing }
SLLocalizableVariableCollector >> localizableCandidateVariables [

	^ localizableCandidateVariables
]

{ #category : #accessing }
SLLocalizableVariableCollector >> localizableCandidateVariables: anObject [

	localizableCandidateVariables := anObject
]

{ #category : #accessing }
SLLocalizableVariableCollector >> localizableVariables [
	^ localizableVariables
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitAssignmentNode: aTAssignmentNode [ 
	
	aTAssignmentNode variable accept: self.
	aTAssignmentNode expression accept: self.
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitCaseStatementNode: aTCaseStmtNode [ 
	
	"Do not recurse on children of a case statement.
	Children will be recursed as separate statements"
	aTCaseStmtNode expression accept: self
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitConstantNode: aTConstantNode [ 
	
	"Nothing for constants"
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitGoToNode: aTGoToNode [ 
	
	"Nothing"
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitInlineNode: aTInlineNode [
	
	"Do not recurse on children of an inline statement.
	Children will be recursed as separate statements"
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitLabeledCommentNode: aTLabeledCommentNode [ 
	
	"Nothing"
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitReturnNode: aTReturnNode [ 
	
	"If we are doing a return node, we should externalize everything, no need to go into children"
	localizableVariables addAll: localizableCandidateVariables
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitSendNode: aTSendNode [ 
	
	(codeGenerator isDynamicCall: aTSendNode)
		ifTrue: [
			"If we are visiting dynamic call, we should externalize everything since we do not know at compile time what function will be called"
			localizableVariables addAll: localizableCandidateVariables.
			^ self ].

	aTSendNode receiver accept: self.
	aTSendNode arguments do: [ :argument | argument accept: self ].

	callgraphVariableCollector startFromSelector: aTSendNode selector.
	localizableVariables addAll: (callgraphVariableCollector freeVariablesUsedByMethodNamed: aTSendNode selector)
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitStatementListNode: aTStatementListNode [ 
	
	aTStatementListNode statements do: [ :e | e accept: self ]
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitSwitchStatementNode: aTSwitchStmtNode [ 
	
	"Do not recurse on children of a case statement.
	Children will be recursed as separate statements"
	aTSwitchStmtNode expression accept: self
]

{ #category : #visiting }
SLLocalizableVariableCollector >> visitVariableNode: aTVariableNode [ 
	
	(localizableCandidateVariables includes: aTVariableNode name)
		ifTrue: [ localizableVariables add: aTVariableNode name ]
]
