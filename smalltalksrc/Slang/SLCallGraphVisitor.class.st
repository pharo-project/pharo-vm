"
I am a call graph visitor visiting all methods found in a callgraph starting at a particular method.
Starting from the given method, I recursively look into its called methods.
For each called method, I call the preVisitMethod: and postVisitMethod: on myself with the method as argument.
I am an abstract class, my subclasses should redefine preVisitMethod: and postVisitMethod: with concrete implementations.

I implement a depth first algorithm on the callgraph, stopping recursion as soon as a cycle is found.
Users may redefine the [pre/post]VisitMethod: variants to implement a pre-order or a post-order traversal.
- preVisitMethod: is called before the recursive call on its children
- postVisitMethod: is called after the recursive call on its children

preVisitMethod: returns a boolean indicating if the method should be recursively visited or not, as a user-available hook to stop computation

# Usage

- I am created with the #codeGenerator: class side method with a code generator as argument.
- I am started from a method with the #startFromMethod: message with a TMethod as argument.

# Example

v := SLCallGraphVisitor codeGenerator: generator.
v startFromMethod: (generator methodNamed: #foo).
"
Class {
	#name : #SLCallGraphVisitor,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'alreadyVisited'
	],
	#category : #'Slang-Optimizations'
}

{ #category : #'instance creation' }
SLCallGraphVisitor class >> codeGenerator: aCodeGenerator [
	
	^ self new
		codeGenerator: aCodeGenerator;
		yourself
]

{ #category : #accessing }
SLCallGraphVisitor >> codeGenerator [

	^ codeGenerator
]

{ #category : #accessing }
SLCallGraphVisitor >> codeGenerator: anObject [

	codeGenerator := anObject
]

{ #category : #initialization }
SLCallGraphVisitor >> initialize [

	super initialize.
	alreadyVisited := Set new.
]

{ #category : #private }
SLCallGraphVisitor >> internalVisitMethod: aTMethod [

	"Recursive private method. Called only once per selector/method in the callgraph visit"

	| shouldVisitMethod |
	(alreadyVisited includes: aTMethod) ifTrue: [ ^ self ].
	alreadyVisited add: aTMethod.

	shouldVisitMethod := self preVisitMethod: aTMethod.
	shouldVisitMethod ifFalse: [ ^ self ].

	(aTMethod externalCallsIn: codeGenerator) do: [ :aTSendNode |
		self internalVisitSelector: aTSendNode selector ].
	
	self postVisitMethod: aTMethod.
]

{ #category : #private }
SLCallGraphVisitor >> internalVisitSelector: aSelector [

	"Recursive private method. Called only once per selector/method in the callgraph visit"

	| method |
	method := codeGenerator methodNamed: aSelector.

	"The method could be nil if not found in the list of methods to translate.
		This could be because the selector is either
		 - a special selector (+, /, perform: ...)
		 - a C selector (str:cpy:_:_:)
		 - or a selector that was inlined and removed by some other pass..."
	method ifNotNil: [ self internalVisitMethod: method ]
]

{ #category : #hooks }
SLCallGraphVisitor >> postVisitMethod: aTMethod [
	
	^ true
]

{ #category : #hooks }
SLCallGraphVisitor >> preVisitMethod: aTMethod [
	
	^ true
]

{ #category : #api }
SLCallGraphVisitor >> startFromMethod: aTMethod [

	"Non-recursive public method. Called only once per callgraph visit"
	self internalVisitMethod: aTMethod
]

{ #category : #api }
SLCallGraphVisitor >> startFromSelector: aSelector [
	
	"Non-recursive public method. Called only once per callgraph visit"
	^ self internalVisitSelector: aSelector
]
