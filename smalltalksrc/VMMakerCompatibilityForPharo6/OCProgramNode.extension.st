Extension { #name : 'OCProgramNode' }

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCProgramNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"
	self subclassResponsibility
]

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCProgramNode >> commentOrNil [
	
	| comments |
	comments := self propertyAt: #comments ifAbsent: [ ^ nil ].
	^ comments collect: #contents
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCProgramNode >> isBlockNode [
	^false
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCProgramNode >> isConstantNumber [  "Overridden in RBLiteralValueNode"
	^false
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCProgramNode >> isNodeNil [
	^false
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCProgramNode >> isVariableNode [
	^false
]

{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCProgramNode >> missingCommentNeededForCTranslation [
	"So far the RBProgramNode hierarchy omits/elides comments :-("
	^nil
]
