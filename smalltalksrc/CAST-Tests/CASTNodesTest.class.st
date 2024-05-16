Class {
	#name : #CASTNodesTest,
	#superclass : #TestCase,
	#category : #'CAST-Tests'
}

{ #category : #identifiers }
CASTNodesTest >> testIdentifierNodeNameIsInvalid [

	| identifier |
	identifier := CIdentifierNode new name: 'setter:'.
	self shouldnt: identifier hasValidName
]

{ #category : #identifiers }
CASTNodesTest >> testIdentifierNodeNameIsValid [

	| identifier |
	identifier := CIdentifierNode new name: 'setter'.
	self should: identifier hasValidName
]
