Class {
	#name : #SpurMethodDictionary,
	#superclass : #SpurObject,
	#category : #'VMMaker-Tools'
}

{ #category : #accessing }
SpurMethodDictionary >> firstMethod [

	| index arrayOfMethod |
	index := self firstSelectorIndex.

	arrayOfMethod := self slotAt: 2.
	^arrayOfMethod slotAt: index.
	
]

{ #category : #accessing }
SpurMethodDictionary >> firstSelector [
	
	^ self slotAt: self firstSelectorIndex + 2
]

{ #category : #accessing }
SpurMethodDictionary >> firstSelectorIndex [
	| currentIndex found |
	currentIndex := 1.
	found := nil.
	[ currentIndex + 2 < self numberOfSlots and: [ found isNil ] ]
		whileTrue: [ | object |
			(object := (self slotAt: currentIndex + 2)) spIsNil
				ifTrue: [ currentIndex := currentIndex + 1 ]
				ifFalse: [ found := object. ^currentIndex ]. ].
	^ nil
]
