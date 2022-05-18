Class {
	#name : #AbstractImageAccess,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter',
		'segmentManager'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
AbstractImageAccess class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator
		removeVariable: 'objectMemory';
		removeVariable: 'interpreter';
		removeVariable: 'segmentManager'
]

{ #category : #translation }
AbstractImageAccess class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."
	^#void
]

{ #category : #'instance creation' }
AbstractImageAccess class >> newWithMemory: memory andInterpreter: anInterpreter [

	| newInstance |
	
	newInstance := self new.
	newInstance objectMemory: memory.
	newInstance interpreter: anInterpreter.
	newInstance segmentManager: memory segmentManager.
	
	^ newInstance
]

{ #category : #accessing }
AbstractImageAccess >> interpreter [

	<doNotGenerate>

	^ interpreter
]

{ #category : #accessing }
AbstractImageAccess >> interpreter: anObject [

	<doNotGenerate>

	interpreter := anObject
]

{ #category : #accessing }
AbstractImageAccess >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #accessing }
AbstractImageAccess >> segmentManager: anObject [

	<doNotGenerate>
	segmentManager := anObject
]
