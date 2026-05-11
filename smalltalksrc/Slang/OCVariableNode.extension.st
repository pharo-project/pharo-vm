Extension { #name : 'OCVariableNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCVariableNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCVariableNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBVariableNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBVariableNode.extension.st
	"Answer a TParseNode subclass equivalent of me"
	name = 'true' ifTrue: [^ TConstantNode value: true].
	name = 'false' ifTrue: [^ TConstantNode value: false].
	^ TVariableNode new setName: name
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCVariableNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCVariableNode >> isVariableNode [
========
{ #category : '*Slang' }
RBVariableNode >> isVariableNode [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBVariableNode.extension.st
	^true
]
