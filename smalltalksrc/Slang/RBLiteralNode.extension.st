Extension { #name : 'RBLiteralNode' }

{ #category : '*Slang' }
RBLiteralNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"

	^TConstantNode value: self value
]
