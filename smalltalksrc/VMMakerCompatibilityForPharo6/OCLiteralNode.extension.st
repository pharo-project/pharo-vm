Extension { #name : 'OCLiteralNode' }

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCLiteralNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"

	^TConstantNode value: self value
]
