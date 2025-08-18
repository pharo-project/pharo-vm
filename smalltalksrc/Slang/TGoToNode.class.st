Class {
	#name : 'TGoToNode',
	#superclass : 'TParseNode',
	#instVars : [
		'label',
		'indicateAnExitPointInlined'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'instance creation' }
TGoToNode class >> label: aLabel [

	^ self new
		  setLabel: aLabel;
		  yourself
]

{ #category : 'visiting' }
TGoToNode >> accept: aVisitor [ 
	
	^ aVisitor visitGoToNode: self
]

{ #category : 'tranforming' }
TGoToNode >> asCASTIn: aCCodeGenerator [ 
	^ CGotoStatementNode identifier: label
]

{ #category : 'tranforming' }
TGoToNode >> asCASTIn: aBuilder prependToEnd: aNodeOrNil [
	^ self asCASTExpressionIn: aBuilder
]

{ #category : 'accessing' }
TGoToNode >> children [
	
	^ #()
]

{ #category : 'accessing' }
TGoToNode >> indicateAnExitPointInlined [
	"goTo only comes from inlining to keep the execution flow correct where a return was.
	since inlining goes through multiple phases, static analysis may become flawed, for example :
		'a := [... methodWithReturn … b]' gives 'a = [... c . goTo l ... l ... b]' is equivalent (and should be transform to) '[ ... c . goTo l ... l ... a := b]'
		'a := methodeWithMultipleReturn' gives 'a = [... c . goTo l ... l ... b]' is equivalent (and should be transform to) '[ ... a := c . goTo l ... l ... a := b]'
	so after an inlining phases we might invalidate goTo generated so that they do not 'indicate an active exit point' anymore"

	indicateAnExitPointInlined := true
]

{ #category : 'initialization' }
TGoToNode >> initialize [

	super initialize.
	indicateAnExitPointInlined := false
]

{ #category : 'accessing' }
TGoToNode >> isAnExitPointInlined [

	^ indicateAnExitPointInlined
]

{ #category : 'testing' }
TGoToNode >> isGoTo [

	^true
]

{ #category : 'comparing' }
TGoToNode >> isSameAs: aTGoToNode [ 
	
	^ aTGoToNode isGoTo
		and: [ label = aTGoToNode label ]
]

{ #category : 'accessing' }
TGoToNode >> label [

	^label
]

{ #category : 'enumerating' }
TGoToNode >> nodesDo: aBlock parent: parent [
	aBlock value: self value: parent
]

{ #category : 'printing' }
TGoToNode >> printOn: aStream level: level [

	aStream nextPutAll: 'goto '.
	aStream nextPutAll: label.
]

{ #category : 'accessing' }
TGoToNode >> setLabel: aString [
	label := aString
]
