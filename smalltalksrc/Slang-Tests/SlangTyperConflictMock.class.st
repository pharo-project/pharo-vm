Class {
	#name : #SlangTyperConflictMock,
	#superclass : #SlangTyper,
	#instVars : [
		'conflictRecord'
	],
	#category : #'Slang-Tests'
}

{ #category : #setting }
SlangTyperConflictMock >> conflictAt: aMethod put: aCollectionOfType [
	conflictRecord ifNil: [ self resetConflictRecord ].
	conflictRecord at: aMethod put: aCollectionOfType
	
]

{ #category : #accessing }
SlangTyperConflictMock >> conflictFor: aMethod [
	^ conflictRecord  at: aMethod ifAbsent: [ nil ]
]

{ #category : #accessing }
SlangTyperConflictMock >> conflictRecord [

	^ conflictRecord
]

{ #category : #setting }
SlangTyperConflictMock >> resetConflictRecord [

	conflictRecord := Dictionary new
]

{ #category : #exceptions }
SlangTyperConflictMock >> throwConflictExceptionIn: aMethod with: returnTypes [
	"does nothing expect recording the error to prevent interrupting the execution during tests"

	self conflictAt: aMethod put: returnTypes
]
