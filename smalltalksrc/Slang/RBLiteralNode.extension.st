Extension { #name : 'OCLiteralNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCLiteralNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCLiteralNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBLiteralNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBLiteralNode.extension.st
	"Answer a TParseNode subclass equivalent of me"

	^TConstantNode value: self value
]
