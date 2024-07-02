Class {
	#name : #TBraceCaseNode,
	#superclass : #TParseNode,
	#instVars : [
		'caseLabels',
		'cases',
		'oldCases'
	],
	#category : #'Slang-AST'
}

{ #category : #transformations }
TBraceCaseNode >> bindVariableUsesIn: aDictionary [

	self caseLabels: (caseLabels collect: [:node| node bindVariableUsesIn: aDictionary]).
	self cases: (cases collect: [:node| node bindVariableUsesIn: aDictionary])
]

{ #category : #transformations }
TBraceCaseNode >> bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen [
	"Answer either the receiver, if it contains no references to the given variables, or a new node with the given variables rebound."
	| newCaseLabels newCases |
	newCaseLabels := caseLabels collect: [:node| node bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen].
	newCases := cases collect: [:node| node bindVariableUsesIn: aDictionary andConstantFoldIf: constantFold in: codeGen].
	^(newCaseLabels = caseLabels
	   and: [newCases = cases])
		ifTrue: [self]
		ifFalse: [self shallowCopy
					caseLabels: newCaseLabels;
					cases: newCases;
					yourself]
]

{ #category : #transformations }
TBraceCaseNode >> bindVariablesIn: aDictionary [

	self caseLabels: (caseLabels collect: [:node| node bindVariablesIn: aDictionary]).
	self cases: (cases collect: [:node| node bindVariablesIn: aDictionary])
]

{ #category : #transformations }
TBraceCaseNode >> bindVariablesIn: aDictionary unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	self caseLabels: (caseLabels collect: [:node| node bindVariablesIn: aDictionary unless: cautionaryBlock]).
	self cases: (cases collect: [:node| node bindVariablesIn: aDictionary unless: cautionaryBlock])
]

{ #category : #accessing }
TBraceCaseNode >> caseLabels [
	"Answer the value of caseLabels"

	^ caseLabels
]

{ #category : #accessing }
TBraceCaseNode >> caseLabels: anObject [

	"Set the value of caseLabels"

	caseLabels := anObject.
	caseLabels do: [ :e | e parent: self ]
]

{ #category : #accessing }
TBraceCaseNode >> cases [
	"Answer the value of cases"

	^ cases
]

{ #category : #accessing }
TBraceCaseNode >> cases: anObject [
	"Set the value of cases"

	cases := anObject.	
	cases do: [ :e | e parent: self ]
]

{ #category : #enumerating }
TBraceCaseNode >> nodesDo: aBlock [
	"Apply aBlock to all nodes in the receiver.
	 N.B. This is assumed to be bottom-up, leaves first."
	caseLabels do:
		[:node| node nodesDo: aBlock].
	cases do:
		[:node| node nodesDo: aBlock].
	aBlock value: self
]

{ #category : #enumerating }
TBraceCaseNode >> nodesDo: aBlock parent: parent [
	"Apply aBlock to all nodes in the receiver with each node's parent.
	 N.B. This is assumed to be bottom-up, leaves first."
	caseLabels do:
		[:node| node nodesDo: aBlock parent: self.].
	cases do:
		[:node| node nodesDo: aBlock parent: self].
	aBlock value: self value: parent
]

{ #category : #enumerating }
TBraceCaseNode >> nodesDo: aBlock parent: parent unless: cautionaryBlock [

	(cautionaryBlock value: self value: parent) ifTrue: [^self].
	caseLabels do:
		[:node| node nodesDo: aBlock parent: self unless: cautionaryBlock].
	cases do:
		[:node| node nodesDo: aBlock parent: self unless: cautionaryBlock].
	aBlock value: self value: parent
]

{ #category : #enumerating }
TBraceCaseNode >> nodesDo: aBlock unless: cautionaryBlock [

	(cautionaryBlock value: self) ifTrue: [^self].
	caseLabels do:
		[:node| node nodesDo: aBlock unless: cautionaryBlock].
	cases do:
		[:node| node nodesDo: aBlock unless: cautionaryBlock].
	aBlock value: self
]

{ #category : #enumerating }
TBraceCaseNode >> replaceNodesIn: aDictionary [

	^aDictionary at: self ifAbsent: [
		self caseLabels: (caseLabels collect: [:node| node replaceNodesIn: aDictionary]).
		self cases: (cases collect: [:node| node replaceNodesIn: aDictionary]).
		self]
]

{ #category : #'type inference' }
TBraceCaseNode >> typeOrNilFrom: aCodeGenerator in: aTMethod [
	| types |
	types := Set withAll: (cases collect: [:case| case typeOrNilFrom: aCodeGenerator in: aTMethod]).
	^types size = 1 ifTrue: [types anyOne]
]
