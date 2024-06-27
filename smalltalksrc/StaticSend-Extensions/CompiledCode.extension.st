Extension { #name : #CompiledCode }

{ #category : #'*StaticSend-Extensions' }
CompiledCode >> refersToLiteral: aLiteral [
	"Answer true if any literal in this method is literal,
	even if embedded in array structure."

	1 to: self numLiterals - self literalsToSkip do: [ :index | "exclude selector or additional method state (penultimate slot)
		and methodClass or outerCode (last slot)"
		(self literalAt: index) == self ifFalse: [
			((self literalAt: index) refersToLiteral: aLiteral) ifTrue: [
				^ true ] ] ].

	^ false
]
