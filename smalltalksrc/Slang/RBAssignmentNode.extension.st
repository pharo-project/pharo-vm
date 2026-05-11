Extension { #name : 'OCAssignmentNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCAssignmentNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCAssignmentNode >> anyReturns: aSequenceOfNodes [
========
{ #category : '*Slang' }
RBAssignmentNode >> anyReturns: aSequenceOfNodes [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBAssignmentNode.extension.st
	aSequenceOfNodes do:
		[:node|
		node nodesDo:
			[:n|
			n isReturn ifTrue:
				[^true]]].
	^false
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCAssignmentNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCAssignmentNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBAssignmentNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBAssignmentNode.extension.st
	"Answer a TParseNode subclass equivalent of me"
	| varNode valueNode |
	varNode := variable asTranslatorNodeIn: aTMethod.
	valueNode := value asTranslatorNodeIn: aTMethod.
	valueNode isStatementList ifFalse:
		[^TAssignmentNode new
			setVariable: varNode
			expression: valueNode;
			comment: self commentOrNil].
	 "This is a super expansion.  We are in trouble if any statement other than the last is a return."
	(self anyReturns: valueNode statements allButLast) ifTrue:
		[self error: 'haven''t implemented pushing down assignments into other than the last return'].
	"As of 6/25/2012 19:30 superExpansionNodeFor:args: elides the final return."
	self assert: valueNode statements last isReturn not.
	^TStatementListNode statements: valueNode statements allButLast,
					{ TAssignmentNode new
						setVariable: varNode
						expression: valueNode statements last;
						comment: self commentOrNil }
]
