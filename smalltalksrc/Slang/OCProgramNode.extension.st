Extension { #name : 'OCProgramNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCProgramNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCProgramNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBProgramNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBProgramNode.extension.st
	"Answer a TParseNode subclass equivalent of me"
	self subclassResponsibility
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCProgramNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCProgramNode >> commentOrNil [
========
{ #category : '*Slang' }
RBProgramNode >> commentOrNil [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBProgramNode.extension.st
	
	| comments |
	comments := self propertyAt: #comments ifAbsent: [ ^ nil ].
	^ comments collect: #contents
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCProgramNode.extension.st
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
========
{ #category : '*Slang' }
RBProgramNode >> isBlockNode [
	^false
]

{ #category : '*Slang' }
RBProgramNode >> isConstantNumber [  "Overridden in RBLiteralValueNode"
	^false
]

{ #category : '*Slang' }
RBProgramNode >> isNodeNil [
	^false
]

{ #category : '*Slang' }
RBProgramNode >> isVariableNode [
	^false
]

{ #category : '*Slang' }
RBProgramNode >> missingCommentNeededForCTranslation [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBProgramNode.extension.st
	"So far the RBProgramNode hierarchy omits/elides comments :-("
	^nil
]
