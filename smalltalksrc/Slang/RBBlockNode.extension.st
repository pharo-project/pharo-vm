Extension { #name : 'RBBlockNode' }

{ #category : '*Slang' }
RBBlockNode >> asTranslatorNodeIn: aTMethod [

	body := body asTranslatorNodeIn: aTMethod.
	body statements ifEmpty: [
		body statements add: (TConstantNode value: nil) ].
	^ body
]

{ #category : '*Slang' }
RBBlockNode >> isBlockNode [
	^true
]

{ #category : '*Slang' }
RBBlockNode >> isPotentialCCaseLabel: stmt in: aTMethod [
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

{ #category : '*Slang' }
RBBlockNode >> isPotentialCCaseLabelIn: aTMethod [
	body statements size ~= 1 ifTrue: [^false].
	^self isPotentialCCaseLabel: body statements first in: aTMethod
]
