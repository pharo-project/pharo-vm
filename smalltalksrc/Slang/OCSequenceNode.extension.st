Extension { #name : 'OCSequenceNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCSequenceNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCSequenceNode >> asTranslatorNodeIn: aTMethod [
========
{ #category : '*Slang' }
RBSequenceNode >> asTranslatorNodeIn: aTMethod [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBSequenceNode.extension.st

	"Answer a TParseNode subclass equivalent of me"

	| statementList |
	statementList := OrderedCollection new.
	statements do: [ :s | 
		| newS |
		newS := s asTranslatorNodeIn: aTMethod.
		"inline the statement list returned when a CascadeNode is translated and/or when ifNotNil: is transformed"
		statementList add: newS ].
	^ TStatementListNode new
		  setArguments: (parent isMethod
				   ifTrue: [ #(  ) ]
				   ifFalse: [ 
					   parent arguments asArray collect: [ :arg | arg name ] ])
		  statements: statementList;
		  comment: self commentOrNil
]
