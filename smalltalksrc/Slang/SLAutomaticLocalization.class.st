"
One common optimization for language interpreters is to put critical variables in registers. From the point of view of a C program, this is implementable by caching those variables in local variables, hinting the C compiler to better optimize the reads/writes to those variables. Usual candidates for those optimizations are variables such as the stackPointer, the framePointer, the instructionPointer or even the value at the top of the stack.

A more general description of the optimization can be found in the following article: VMGen - A Generator of Efficient Virtual Machine Interpreters.

## Previous status

The Slang VM generator peforms as of today (21/09/2021) two simple localization algorithms:
 - (automatic) after inlining and removal of unreferenced methods, if a variable is only referenced a single method, the variable definition is moved locally to the said function
 - (semi-automatic) after inlining and customization of the interpreter switch cases, a fixed list of variables (`localIP`, `localSP`, `localFP`...) are always localized inside the function defining the interpreter loop. All other methods referencing those variables are considered broken. The goal being that within the interpreter, the local variable is used, and outside of it functions should refer to a global variable (i.e., respectively `instructionPointer`, `stackPointer`, `framePointer`...).

A consequence of this semi-automatic localization of the variables in the interpreter loop function (e.g., `localIP`) is that values should be copied from/to the local and global variables. Moreover, nowadays such copies are explicitly managed in the VM's source code. This means that every piece of code that is supposed to *escape* the scope of the interpreter loop function, is surrounded with so-called **externalization** and **internalization** of those variable values. In general, this means that all functions that are meant to be inlined can freely access the localized versions of the variables, and those that are never inlined (e.g., by means of a `inline:false` annotation) should always access the global versions.

```smalltalk
bytecodePrimBitOr
  | rcvr arg |
  arg := self internalStackTop.
  rcvr := self internalStackValue: 1.
  
  ""Type checks and fast path""
  [...]

  ""Slow path, call the primitive code, which is not inlined and thus requires externalization/internalization""
  self externalizeIPandSP.
  self primitiveBitOr.
  self internalizeIPandSP.

  ""Continue and check the values
  [...]
```

### Transformations

This transformation will be implemented as a series of transformations:

1. During inlining, all inlined usages of the global variable are replaced by the corresponding local variable
2. During inlining, all non-inlined messages are surrounded by copy instructions (local->global upon call, global->local upon return)
3. At the entry of the method, all localized variables are initialized with the values of the global variables
4. At each return point, all values in localized variables are copied back to their corresponding global variables

Special care must be taken when calls are used as expressions, and in particular when those expressions modify the localized variables.

Moreover, this process can be enhanced with an optimization pass that:
 - avoids copies when we can statically determine that the called function does not use the localized variable
 - collapses sequences of copies when we find sequences of non-inlined calls
"
Class {
	#name : #SLAutomaticLocalization,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'selector',
		'callgraphVariableCollector'
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

	codeGenerator := anObject.
	callgraphVariableCollector := SLCallGraphFreeVariableCollector codeGenerator: codeGenerator
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

	| lineariser linearStatementList |
	lineariser := SLLinearisationVisitor new
		codeGenerator: codeGenerator;
		localizedVariables: replacementDict keys;
		yourself.

	linearStatementList := aTMethod parseTree accept: lineariser.
	aTMethod parseTree: linearStatementList
]

{ #category : #applying }
SLAutomaticLocalization >> localizableVariablesInStatement: statement withVariableBindings: localizedVariables [

	"Optimization: only externalize/localize variables used by the statement's called functions"

	| collector |
	collector := SLLocalizableVariableCollector
		             inCodeGenerator: codeGenerator
		             localizableCandidateVariables: localizedVariables
		             callgraphVariableCollector: callgraphVariableCollector.
	^ (statement accept: collector) localizableVariables
]

{ #category : #applying }
SLAutomaticLocalization >> wrapStatementWithExternalizationAndLocalizations: statement ofLocalizedVariables: localizedVariables [

	| variablesToExternalize replacementStatements potentialCall |

	"Only non inlined sends, or message sends in assignments `tx := send` should be wrapped"
	potentialCall := statement isAssignment ifTrue: [ statement expression ] ifFalse: [ statement ].
	(potentialCall isReturn or: [
		(codeGenerator isFunctionCall: potentialCall)
			or: [ codeGenerator isDynamicCall: potentialCall ]])
				ifFalse: [ ^ statement ].
	
	"Optimization: only externalize/localize variables used by the statement's called functions"
	variablesToExternalize := (self
		localizableVariablesInStatement: statement
		withVariableBindings: localizedVariables) sorted.

	"Sorted to guarantee determinism in the output"
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
