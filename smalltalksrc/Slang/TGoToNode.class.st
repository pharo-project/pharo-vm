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

{ #category : #visiting }
TGoToNode >> accept: aVisitor [ 
	
	^ aVisitor visitGoToNode: self
]

{ #category : #tranforming }
TGoToNode >> asCASTIn: aCCodeGenerator [ 
	^ CGotoStatementNode identifier: label
]

{ #category : #tranforming }
TGoToNode >> asCASTIn: aBuilder prependToEnd: aNodeOrNil [
	^ self asCASTExpressionIn: aBuilder
]

{ #category : #accessing }
TGoToNode >> children [
	
	^ #()
]

{ #category : #testing }
TGoToNode >> isGoTo [

	^true
]

{ #category : #comparing }
TGoToNode >> isSameAs: aTGoToNode [ 
	
	^ aTGoToNode isGoTo
		and: [ label = aTGoToNode label ]
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
