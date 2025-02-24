Extension { #name : 'RBVariableNode' }

{ #category : '*Slang' }
RBVariableNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"
	name = 'true' ifTrue: [^ TConstantNode value: true].
	name = 'false' ifTrue: [^ TConstantNode value: false].
	^ TVariableNode new setName: name
]

{ #category : '*Slang' }
RBVariableNode >> isVariableNode [
	^true
]
