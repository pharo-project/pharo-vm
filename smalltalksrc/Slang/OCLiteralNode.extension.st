Extension { #name : 'OCLiteralNode' }

{ #category : '*Slang' }
OCLiteralNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"

	^TConstantNode value: self value
]
