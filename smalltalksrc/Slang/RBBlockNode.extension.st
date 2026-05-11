Extension { #name : 'OCBlockNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCBlockNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCBlockNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBBlockNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBBlockNode.extension.st

	body := body asTranslatorNodeIn: aTMethod.
	body statements ifEmpty: [
		body statements add: (TConstantNode value: nil) ].
	^ body
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCBlockNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCBlockNode >> isBlockNode [
	^true
]

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCBlockNode >> isPotentialCCaseLabel: stmt in: aTMethod [
========
{ #category : '*Slang' }
RBBlockNode >> isBlockNode [
	^true
]

{ #category : '*Slang' }
RBBlockNode >> isPotentialCCaseLabel: stmt in: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBBlockNode.extension.st
	(stmt isVariable
	 or: [stmt isLiteralNode
		and: [stmt isConstantNumber or: [stmt literalValue isSymbol]]]) ifTrue:
		[^true].
	stmt isMessage ifTrue:
		[| selector implementingClass method |
		 selector := stmt selector.
		 (#(* + -) includes: selector) ifTrue:
			[^(self isPotentialCCaseLabel: stmt receiver in: aTMethod)
			   and: [self isPotentialCCaseLabel: stmt arguments first in: aTMethod]].

		 (selector = #asSymbol
		  and: [stmt receiver isLiteralNode
		  and: [stmt receiver literalValue isSymbol]]) ifTrue:
			[^true].

		 (stmt arguments isEmpty
		  and: [implementingClass := aTMethod definingClass whichClassIncludesSelector: selector.
			   implementingClass ifNil:
				[implementingClass := aTMethod definingClass objectMemoryClass whichClassIncludesSelector: selector].
			   method := implementingClass >> selector.
			   (method isQuick
				or: [(method literalAt: 1) isInteger
					and: [method numLiterals = 3]])
		   and: [(implementingClass basicNew perform: selector) isInteger]]) ifTrue:
				[^true]].
	^false
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCBlockNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCBlockNode >> isPotentialCCaseLabelIn: aTMethod [
========
{ #category : '*Slang' }
RBBlockNode >> isPotentialCCaseLabelIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBBlockNode.extension.st
	body statements size ~= 1 ifTrue: [^false].
	^self isPotentialCCaseLabel: body statements first in: aTMethod
]
