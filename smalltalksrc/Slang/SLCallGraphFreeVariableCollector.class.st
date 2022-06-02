"
I am a callgraph visitor that computes the free variables used recursively by a method and its callees.

I keep inside a cache of (selector -> list of free variables).
I can be called many times and i will cut as soon as i finds a method found in a previous invocation.
"
Class {
	#name : #SLCallGraphFreeVariableCollector,
	#superclass : #SLCallGraphVisitor,
	#instVars : [
		'accumulatedFreeVariables',
		'freeVariablesPerMethod'
	],
	#category : #'Slang-Optimizations'
}

{ #category : #accessing }
SLCallGraphFreeVariableCollector >> freeVariablesUsedByMethodNamed: aSelector [

	^ freeVariablesPerMethod at: aSelector ifAbsent: [ ^ #() ]
]

{ #category : #initialization }
SLCallGraphFreeVariableCollector >> initialize [

	super initialize.
	freeVariablesPerMethod := Dictionary new.
	accumulatedFreeVariables := OrderedCollection new.
]

{ #category : #private }
SLCallGraphFreeVariableCollector >> internalVisitMethod: aTMethod [

	"If we already visited this method, 
		add its previously computed variables to the accumulated parent variables"
	(alreadyVisited includes: aTMethod) ifTrue: [ 
		accumulatedFreeVariables last value addAll:
			(self freeVariablesUsedByMethodNamed: aTMethod selector).
		^ self ].

	^ super internalVisitMethod: aTMethod
]

{ #category : #hooks }
SLCallGraphFreeVariableCollector >> postVisitMethod: aMethod [

	"This are all variables accessed by this method and its children"
	| myVariables parentVariables |
	myVariables := accumulatedFreeVariables removeLast.
	myVariables value addAll: aMethod freeVariableReferences.

	freeVariablesPerMethod at: aMethod selector put: myVariables value.
	
	"Now accumulate my variables in my parent one's, if I'm not the top one"
	accumulatedFreeVariables ifEmpty: [ ^ self ].
	parentVariables := accumulatedFreeVariables last.
	parentVariables value addAll: myVariables value
]

{ #category : #hooks }
SLCallGraphFreeVariableCollector >> preVisitMethod: aMethod [

	"Work as a cache to make this instance reusable.
	It can be called many times and it will cut as soon as it finds a method found in a previous invocation"
	freeVariablesPerMethod at: aMethod selector ifPresent: [ ^ false "stop" ].

	accumulatedFreeVariables addLast: aMethod selector -> OrderedCollection new.
	"Continue"
	^ true
]
