Extension { #name : 'RBLiteralNode' }

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
RBLiteralNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"

	^TConstantNode value: self value
]
