Class {
	#name : #SLAutomaticLocalization,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'selector'
	],
	#category : #'Slang-Optimizations'
}

{ #category : #applying }
SLAutomaticLocalization >> applyMethodNamed: interpreterSelector [ 

	| autolocalizedVariables |
	autolocalizedVariables := codeGenerator
		initAutoLocalizationOfVariablesIn: interpreterSelector.
	self
		autoLocalizationOfVariablesIn: interpreterSelector
		withVariableBindings: autolocalizedVariables
]

{ #category : #applying }
SLAutomaticLocalization >> autoLocalizationOfVariablesIn: aSelector withVariableBindings: replacementList [

	| m replacementDict |
	(m := codeGenerator methodNamed: aSelector) ifNil: [ ^ self ].
	(replacementList isNil or: [ replacementList isEmpty ]) ifTrue: [ ^ self ].

	codeGenerator currentMethod: m.

	replacementDict := (replacementList collect: [ :asso | 
				 asso key -> (TVariableNode named: asso value) ]) asDictionary.
	"Replace all localized variables by their localized versions"
	m parseTree
		bindVariablesIn: replacementDict.

	self linearizeExternalCallsIn: m withVariableBindings: replacementDict.

	"Wrap sends with externalization/internalization statements"
	self wrapStatements: m withVariableBindings: replacementDict.

	"Localize global values at the beginning of the function
	AND externalize local values on each return"
	replacementDict associationsDo: [ :asso | 
		m statements addFirst: (TAssignmentNode
				 variable: asso value copy
				 expression: (TVariableNode named: asso key)) ].
]

{ #category : #accessing }
SLAutomaticLocalization >> codeGenerator [

	^ codeGenerator
]

{ #category : #accessing }
SLAutomaticLocalization >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #applying }
SLAutomaticLocalization >> externalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: aVariableName
			expression: (TVariableNode named: #local_, aVariableName))
]

{ #category : #applying }
SLAutomaticLocalization >> internalizationOf: aVariableName [

	^ (TAssignmentNode
			variableNamed: #local_, aVariableName
			expression: (TVariableNode named: aVariableName))
]

{ #category : #applying }
SLAutomaticLocalization >> linearizeExternalCallsIn: aTMethod withVariableBindings: replacementDict [

	"Should be applied after inlining.
	Linearize all calls inside this method"

	| replacementDictionary statementListsToLinearize |
	replacementDictionary := Dictionary new.

	statementListsToLinearize := aTMethod parseTree select: [ :e | e isStatementList ].
	statementListsToLinearize do: [ :statementList | 
		statementList statements do: [ :statement | 
			| replacement previousParent |
			(self
				 shouldLinearizeStatement: statement
				 withVariableBindings: replacementDict) ifTrue: [ 
					previousParent := statement parent.
					replacement := statement linearizeIn: codeGenerator.

					"Do not ask the child to replace itself, as it may have been already moved"
					previousParent replaceChild: statement with: replacement ] ] ]
]

{ #category : #applying }
SLAutomaticLocalization >> shouldLinearizeStatement: statement withVariableBindings: replacementDict [

	"Optimization: only externalize/localize variables used by the statement's called functions"
	| collector |
	collector := MLVMVariableAccessCollector
		             inCodeGenerator: codeGenerator
		             fromGlobals: replacementDict keys.
	^ (statement accept: collector) accessedVariables notEmpty
]

{ #category : #applying }
SLAutomaticLocalization >> wrapStatementWithExternalizationAndLocalizations: statement ofLocalizedVariables: localizedVariables [

	| collector variablesToExternalize replacementStatements potentialCall |

	"Only non inlined sends, or message sends in assignments `tx := send` should be wrapped"
	potentialCall := statement isAssignment ifTrue: [ statement expression ] ifFalse: [ statement ].
	(potentialCall isReturn or: [
		(codeGenerator isFunctionCall: potentialCall)
			or: [ codeGenerator isDynamicCall: potentialCall ]])
				ifFalse: [ ^ statement ].
	
	"Optimization: only externalize/localize variables used by the statement's called functions"
	collector := MLVMVariableAccessCollector
		             inCodeGenerator: codeGenerator
		             fromGlobals: localizedVariables.
	statement accept: collector.

	"Sorted to guarantee determinism in the output"
	variablesToExternalize := collector accessedVariables sorted.
	variablesToExternalize ifEmpty: [ ^ statement ].

	"Wrap the statement with externalization/localizations"
	replacementStatements := OrderedCollection new.
	replacementStatements addAll: (variablesToExternalize collect: [ :e | self externalizationOf: e ]).
	replacementStatements add: statement.
	statement isReturn ifFalse: [ 
		replacementStatements addAll: (variablesToExternalize collect: [ :e | self internalizationOf: e ]) ].
	^ TStatementListNode statements: replacementStatements
]

{ #category : #applying }
SLAutomaticLocalization >> wrapStatements: tMethod withVariableBindings: replacementDict [

	"Wrap statements with external calls with TExternalSendNode"
	"Apply externalization/localization of variables around 
	 - static function calls
	 - dynamic function calls (perform & co)"
	tMethod allStatements do: [ :statement | | replacement oldParent |
		oldParent := statement parent.
		replacement := self
			wrapStatementWithExternalizationAndLocalizations: statement
			ofLocalizedVariables: replacementDict keys.
		oldParent replaceChild: statement with: replacement.
	].
]
