Extension { #name : 'OCVariableNode' }

{ #category : '*Slang' }
OCVariableNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"
	name = 'true' ifTrue: [^ TConstantNode value: true].
	name = 'false' ifTrue: [^ TConstantNode value: false].
	^ TVariableNode new setName: name
]

{ #category : '*Slang' }
OCVariableNode >> isVariableNode [
	^true
]
