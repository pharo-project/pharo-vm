Class {
	#name : #TGoToNode,
	#superclass : #TParseNode,
	#instVars : [
		'label'
	],
	#category : #'Slang-AST'
}

{ #category : #'instance creation' }
TGoToNode class >> label: aLabel [

	^ self new
		  setLabel: aLabel;
		  yourself
]

{ #category : #tranforming }
TGoToNode >> asCASTIn: aCCodeGenerator [ 
	^ CGotoStatementNode identifier: label
]

{ #category : #tranforming }
TGoToNode >> asCASTIn: aBuilder prependToEnd: aNodeOrNil [
	^ self asCASTExpressionIn: aBuilder
]

{ #category : #testing }
TGoToNode >> isGoTo [

	^true
]

{ #category : #accessing }
TGoToNode >> label [

	^label
]

{ #category : #enumerating }
TGoToNode >> nodesDo: aBlock parent: parent [
	aBlock value: self value: parent
]

{ #category : #printing }
TGoToNode >> printOn: aStream level: level [

	aStream nextPutAll: 'goto '.
	aStream nextPutAll: label.
]

{ #category : #accessing }
TGoToNode >> setLabel: aString [
	label := aString
]
