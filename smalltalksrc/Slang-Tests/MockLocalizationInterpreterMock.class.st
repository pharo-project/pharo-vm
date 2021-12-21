Class {
	#name : #MockLocalizationInterpreterMock,
	#superclass : #AbstractInterpreter,
	#instVars : [
		'variableToLocalize',
		'sharedVariableToLocalize',
		'sharedVariableToLocalizeBeforeInlining',
		'autoLocalizedVariable',
		'autoLocalizedVariable1',
		'autoLocalizedVariable2',
		'autoLocalizedVariable3',
		'autoLocalizedVariable4'
	],
	#classVars : [
		'BytecodeTable'
	],
	#category : #'Slang-Tests'
}

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initialize [

	BytecodeTable := Array new: 5.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeToInline)
	(  1  bytecodeUsingLocalizedVariable)
	(  2  bytecodeUsingSharedLocalizedVariable)
	(  3  bytecodeUsingSharedLocalizedVariableBeforeInlining)
	(  4  bytecodeUsingAutoLocalizedVariable)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithAutoLocalizedVariableOnly [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingAutoLocalizedVariable)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithEscapingCall [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeWithEscapingCall)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithEscapingCallAsArgument [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeWithEscapingCallAsArgument)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithEscapingCallAsArgumentOfExternalCall [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeWithEscapingCallAsArgumentOfExternalCall)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithExternalizedAutoLocalizedVariableInExpressionOnly [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingExternalizedAutoLocalizedVariableAsExpression)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithExternalizedAutoLocalizedVariableOnly [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingExternalizedAutoLocalizedVariable)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithInlinedMethodCall [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingInlinedCall)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithMacroCall [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingMacro)
	)
]

{ #category : #initialization }
MockLocalizationInterpreterMock class >> initializeWithSafeEscapingCall [

	BytecodeTable := Array new: 1.
	self table: BytecodeTable from:
	#(
	(  0  bytecodeUsingSafeExternalCall)
	)
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeInliningSharedMethod [

	self sharedMethod
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeToInline [

	"Do nothing"
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingAutoLocalizedVariable [

	autoLocalizedVariable := 17
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariable [

	autoLocalizedVariable := 17.
	self nonInlinedMethodUsingAutolocalizedVariable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariableAsExpression [

	self foo: self nonInlinedMethodUsingAutolocalizedVariable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInAssignment [

	| foo |
	foo := self foo: self nonInlinedMethodUsingAutolocalizedVariable.
	^ foo
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariableAsExpressionInReturn [

	^ self foo: self nonInlinedMethodUsingAutolocalizedVariable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingExternalizedAutoLocalizedVariableInNestedLexicalScope [

	true ifTrue: [
		self foo: self nonInlinedMethodUsingAutolocalizedVariable
	]
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingInlinedCall [

	self inlinedMethodUsingExternalCall
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingLocalizedVariable [

	variableToLocalize := 42
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingMacro [

	self macroMethod
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingSafeExternalCall [

	self nonInlinedMethodNotUsingAutolocalizedVariables: (autoLocalizedVariable := autoLocalizedVariable +1)
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingSharedLocalizedVariable [

	sharedVariableToLocalize := 42
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeUsingSharedLocalizedVariableBeforeInlining [

	sharedVariableToLocalizeBeforeInlining := 42.
	self methodAlsoSharedLocalizedVariableBeforeInlining
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeWithEscapingCall [

	self foo: (autoLocalizedVariable := autoLocalizedVariable + 1)
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeWithEscapingCallAsArgument [

	1 = self foo2 ifTrue: [ ]
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> bytecodeWithEscapingCallAsArgumentOfExternalCall [

	self foo: self nonInlinedMethodUsingAutolocalizedVariable1
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> foo2 [

	<inline: false>
	autoLocalizedVariable := 10.
	autoLocalizedVariable1 := 11.
	^ 1
]

{ #category : #inline }
MockLocalizationInterpreterMock >> foo: anObject [

	<inline: false>
	autoLocalizedVariable2 := 11.
	self foo2
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> inlinedMethodUsingExternalCall [

	<inline: true>
	|arg arg1|
	self foo2
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> interpret [
	<localizedVariable: #autoLocalizedVariable>

	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #inline }
MockLocalizationInterpreterMock >> interpretWithExternalCallBeforeDispatch [
	
	<localizedVariable: #autoLocalizedVariable>
	self nonInlinedMethodUsingAutolocalizedVariable.
	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #inline }
MockLocalizationInterpreterMock >> interpretWithLocalizedVariableConflict [

	"This method should create a conflict with automatically inlined arguments"
	| local_autoLocalizedVariable |
	<localizedVariable: #autoLocalizedVariable>

	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #inline }
MockLocalizationInterpreterMock >> interpretWithReturnExpression [

	<localizedVariable: #autoLocalizedVariable>
	self dispatchOn: 1 in: BytecodeTable.
	true
		ifTrue: [ ^ 2 + 2 ]
		ifFalse: [ ^ 1 + 1 ]
]

{ #category : #inline }
MockLocalizationInterpreterMock >> interpretWithReturnExpressionUpdatingAutoLocalizedVariable [

	<localizedVariable: #autoLocalizedVariable>
	<localizedVariable: #autoLocalizedVariable1>
	self dispatchOn: 1 in: BytecodeTable.

	^ autoLocalizedVariable := autoLocalizedVariable + 1
]

{ #category : #inline }
MockLocalizationInterpreterMock >> interpretWithSeveralVariablesToLocalize [
	
	<localizedVariable: #autoLocalizedVariable>
	<localizedVariable: #autoLocalizedVariable1>
	<localizedVariable: #autoLocalizedVariable2>
	<localizedVariable: #autoLocalizedVariable3>
	<localizedVariable: #autoLocalizedVariable4>

	self dispatchOn: 1 in: BytecodeTable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> macroMethod [
	<cmacro: 'doesnotmatter'>
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> methodAlsoSharedLocalizedVariableBeforeInlining [

	sharedVariableToLocalizeBeforeInlining := 17
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonBytecodeUsingSharedLocalizedVariable [

	sharedVariableToLocalize := 17
]

{ #category : #inline }
MockLocalizationInterpreterMock >> nonInlinedMethodNotUsingAutolocalizedVariables: anObject [

	<inline:false>
	^ anObject + 10
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonInlinedMethodUsingAutolocalizedVariable [

	<inline:false>
	^ autoLocalizedVariable
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> nonInlinedMethodUsingAutolocalizedVariable1 [

	<inline:false>
	^ autoLocalizedVariable1
]

{ #category : #'interpreter shell' }
MockLocalizationInterpreterMock >> sharedMethod [

	<sharedCodeInCase: #bytecodeInliningSharedMethod>
	^ 1
]
