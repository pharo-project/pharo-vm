Class {
	#name : #SpurMethod,
	#superclass : #SpurObject,
	#category : #'VMMaker-Tools-imageInspector'
}

{ #category : #accessing }
SpurMethod >> lastLiteral [

	^ self literalAt: (self numberOfLiterals + 1)
]

{ #category : #accessing }
SpurMethod >> literalAt: anIndex [
	
	^ self slotAt: anIndex
]

{ #category : #accessing }
SpurMethod >> methodClass [
	
	| methodClassBinding |
	methodClassBinding := self lastLiteral.
	^ (methodClassBinding slotAt: 2) vmPrintOop
]

{ #category : #accessing }
SpurMethod >> methodHeader [	
	^ self slotAt: 1
]

{ #category : #accessing }
SpurMethod >> numberOfLiterals [
	"Mask to get the numberOfLietrals"
	^self methodHeader bitAnd: 16r7FFF
]

{ #category : #accessing }
SpurMethod >> penultimateLiteral [

	^ self literalAt: self numberOfLiterals
]

{ #category : #accessing }
SpurMethod >> selector [
	| selectorLiteral |
	selectorLiteral := self penultimateLiteral.
	(selectorLiteral basicClass asSpurClass className
		= 'AdditionalMethodState')
		ifFalse: [ ^ self image printByteSymbol: selectorLiteral ]
		ifTrue: [ | selectorInAdditional |
			selectorInAdditional := selectorLiteral
				slotAt: 2. "Supossed to be the selector"
			^ self image printByteSymbol: selectorInAdditional ]
]
