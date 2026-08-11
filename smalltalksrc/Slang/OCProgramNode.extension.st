Extension { #name : 'OCProgramNode' }

{ #category : '*Slang' }
OCProgramNode >> asTranslatorNodeIn: aTMethod [
	"Answer a TParseNode subclass equivalent of me"
	self subclassResponsibility
]

{ #category : '*Slang' }
OCProgramNode >> commentOrNil [
	
	| comments |
	comments := self propertyAt: #comments ifAbsent: [ ^ nil ].
	^ comments collect: #contents
]

{ #category : '*Slang' }
OCProgramNode >> isBlockNode [
	^false
]

{ #category : '*Slang' }
OCProgramNode >> isConstantNumber [  "Overridden in RBLiteralValueNode"
	^false
]

{ #category : '*Slang' }
OCProgramNode >> isNodeNil [
	^false
]

{ #category : '*Slang' }
OCProgramNode >> isVariableNode [
	^false
]

{ #category : '*Slang' }
OCProgramNode >> missingCommentNeededForCTranslation [
	"So far the RBProgramNode hierarchy omits/elides comments :-("
	^nil
]
