Class {
	#name : #AbstractImageAccess,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
AbstractImageAccess class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		removeVariable: 'objectMemory';
		removeVariable: 'interpreter'.

]

{ #category : #translation }
AbstractImageAccess class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."
	^#void
]

{ #category : #'instance creation' }
AbstractImageAccess class >> newWithMemory: memory andInterpreter: anInterpreter [

	| imageReader |
	imageReader := self new.
	imageReader objectMemory: memory.
	imageReader interpreter: anInterpreter.
	^ imageReader
]
