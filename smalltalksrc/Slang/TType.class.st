Class {
	#name : #TType,
	#superclass : #Object,
	#instVars : [
		'cType',
		'isBoolean'
	],
	#category : #'Slang-AST'
}

{ #category : #accessing }
TType class >> boolean [

	^ self int
		  isBoolean: true;
		  yourself
]

{ #category : #intantiation }
TType class >> cType: aString [

	^ self new
		  cType: aString;
		  yourself
]

{ #category : #instatiation }
TType class >> int [
	^self cType: #int.
]

{ #category : #instatiation }
TType class >> sqInt [
	^self cType: #sqInt.
]

{ #category : #comparing }
TType >> = other [

	| matchesStructure |
	matchesStructure := other isTType not or: [
		                    self isBoolean = other isBoolean ].
	^ self asString = other asString and: [ matchesStructure ]
]

{ #category : #converting }
TType >> asString [
	^cType asString.
]

{ #category : #matching }
TType >> beginsWith: aString [

	^cType beginsWith: aString
]

{ #category : #intantiation }
TType >> cType: aString [ 
	cType:= aString.
]

{ #category : #declaration }
TType >> declarationFor: aVarName [
	^self asString, ' ', aVarName.
]

{ #category : #accessing }
TType >> findLastOccurrenceOfString: aString startingAt: anInteger [

	^ cType findLastOccurrenceOfString: aString startingAt: anInteger
]

{ #category : #accessing }
TType >> first [
	^cType first.
]

{ #category : #comparing }
TType >> hash [

	^ cType hash bitXor: isBoolean hash
]

{ #category : #testing }
TType >> includes: aCharacter [

	^ cType includes: aCharacter
]

{ #category : #testing }
TType >> includesSubstring: aString [ 
	^cType includesSubstring: aString.
]

{ #category : #accessing }
TType >> indexOf: aCharacter startingAt: anInteger [ 
	^cType indexOf: aCharacter startingAt: anInteger.
]

{ #category : #accessing }
TType >> indexOfSubCollection: aString [

	^ cType indexOfSubCollection: aString
]

{ #category : #initialization }
TType >> initialize [

	self isBoolean: false
]

{ #category : #testing }
TType >> isBoolean [
	^isBoolean.
]

{ #category : #accessing }
TType >> isBoolean: aBoolean [ 
	isBoolean := aBoolean
]

{ #category : #testing }
TType >> isTType [
	^true.
]

{ #category : #accessing }
TType >> last [

	^ cType last
]

{ #category : #comparing }
TType >> printOn: aStream [

	super printOn: aStream.
	aStream << ': ' << cType
]

{ #category : #string }
TType >> withBlanksTrimmed [
	^cType withBlanksTrimmed.
]
