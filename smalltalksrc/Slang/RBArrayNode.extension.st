Extension { #name : 'RBArrayNode' }

{ #category : '*Slang' }
RBArrayNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me."

	"This is for case statements"
	(statements allSatisfy: [:elem| elem isMessage and: [elem selector = #->]]) ifTrue:
		[self assert: (statements allSatisfy:
			[:elem|
			elem receiver isBlockNode
			and: [elem arguments first isBlockNode
			and: [elem receiver isPotentialCCaseLabelIn: aTMethod]]]).
		^TBraceCaseNode new
			caseLabels: (statements collect: [:elem| elem receiver asTranslatorNodeIn: aTMethod]);
			cases: (statements collect: [:elem| elem arguments first asTranslatorNodeIn: aTMethod]);
			comment: statements].

	"This is for varargs selectors (variants of printf:)"
	^TStatementListNode statements: (statements collect: [:elem| elem asTranslatorNodeIn: aTMethod])
]
