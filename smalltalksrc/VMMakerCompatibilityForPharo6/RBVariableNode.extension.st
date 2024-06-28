Extension { #name : 'RBVariableNode' }

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
RBVariableNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"
	name = 'true' ifTrue: [^ TConstantNode value: true].
	name = 'false' ifTrue: [^ TConstantNode value: false].
	^ TVariableNode new setName: name
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
RBVariableNode >> isVariableNode [
	^true
]
