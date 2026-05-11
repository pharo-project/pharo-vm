Extension { #name : 'OCMethodNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCMethodNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCMethodNode >> asTranslationMethodOfClass: aTMethodClass [
========
{ #category : '*Slang' }
RBMethodNode >> asTranslationMethodOfClass: aTMethodClass [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBMethodNode.extension.st
 	"Answer a TMethod (or subclass) derived from the receiver."
	| additionalMethodState comment |
	additionalMethodState := AdditionalMethodState forMethod: nil selector: selector.
	pragmas ifNotNil:
		[pragmas do:
			[:pragmaNode|
			additionalMethodState := additionalMethodState copyWith: pragmaNode asPragma]].

	comment := self commentOrNil.
	self body commentOrNil ifNotNil: [ :bodyComment |
		comment := comment 
			ifNil: [ bodyComment ]
			ifNotNil: [ comment, self body commentOrNil ].
	].

	^aTMethodClass new
		setSelector: selector
		definingClass: self methodClass
		args: arguments
		locals: ((self allDefinedVariables copyWithoutAll: (arguments collect: #name)) collect: [:string| string -> string])
		block: (body lastIsReturn
					ifTrue: [body]
					ifFalse: [body shallowCopy
									addSelfReturn;
									yourself])
		primitive: ((pragmas ifNotNil:
							[pragmas detect: [:pragmaNode| pragmaNode selector beginsWith: #primitve:] ifNone: []])
						ifNil: [0]
						ifNotNil: [:pragmaNode| pragmaNode arguments first value])
		properties: additionalMethodState
		comment: comment
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCMethodNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCMethodNode >> asTranslationMethodOfClass: aTMethodClass forCodeGenerator: aCodeGenerator [
 	"Answer a TMethod (or subclass) derived from the receiver."
	| additionalMethodState comment renamedSelector |
	additionalMethodState := AdditionalMethodState forMethod: nil selector: selector.
	pragmas ifNotNil:
		[pragmas do:
			[:pragmaNode|
			additionalMethodState := additionalMethodState copyWith: pragmaNode asPragma]].
========
{ #category : '*Slang' }
RBMethodNode >> asTranslationMethodOfClass: aTMethodClass forCodeGenerator: aCodeGenerator [
	"Answer a TMethod (or subclass) derived from the receiver."
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBMethodNode.extension.st

	| additionalMethodState comment renamedSelector |
	additionalMethodState := AdditionalMethodState
		                         forMethod: nil
		                         selector: selector.
	pragmas ifNotNil: [
		pragmas do: [ :pragmaNode |
			additionalMethodState := additionalMethodState copyWith:
				                         pragmaNode asPragma ] ].

	additionalMethodState := additionalMethodState copyWith:
		                         #codeGenerator -> aCodeGenerator.

	comment := self commentOrNil.
	self body commentOrNil ifNotNil: [ :bodyComment |
		comment := comment
			           ifNil: [ bodyComment ]
			           ifNotNil: [ comment , self body commentOrNil ] ].

	renamedSelector := self methodClass
		                   renameSelectorIfStaticallyResolved: selector.

	^ aTMethodClass new
		  setSelector: renamedSelector
		  definingClass: self methodClass
		  args: arguments
		  locals:
			  ((self allDefinedVariables copyWithoutAll:
					    (arguments collect: #name)) collect: [ :string |
					   string -> string ])
		  block: (body lastIsReturn
				   ifTrue: [ body ]
				   ifFalse: [
					   body shallowCopy
						   addSelfReturn;
						   yourself ])
		  primitive: ((pragmas ifNotNil: [
				    pragmas
					    detect: [ :pragmaNode |
					    pragmaNode selector beginsWith: #primitve: ]
					    ifNone: [  ] ])
				   ifNil: [ 0 ]
				   ifNotNil: [ :pragmaNode | pragmaNode arguments first value ])
		  properties: additionalMethodState
		  comment: comment;
		  yourself
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCMethodNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-results' }
OCMethodNode >> printSchematicTempsFor: blockNode in: blockScope on: stream [
========
{ #category : '*Slang' }
RBMethodNode >> printSchematicTempsFor: blockNode in: blockScope on: stream [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBMethodNode.extension.st
	| startPos vectorStartPos |
	startPos := stream position.
	blockNode arguments do:
		[:n|
		 stream position > startPos ifTrue: [stream space].
		 stream nextPutAll: n name].
	blockScope isBlockScope ifTrue:
		[(blockScope copiedVars "filter out remotes, e.g. 0vector0"
				reject: [:var| var name first isDigit]) do:
			[:var|
			 stream position > startPos ifTrue: [stream space].
			 stream nextPutAll: var name]].
	(blockNode temporaries reject: [:var| (blockScope lookupVar: var name) isRemote]) do:
		[:var|
		 stream position > startPos ifTrue: [stream space].
		 stream nextPutAll: var name].
	vectorStartPos := stream position.
	(blockNode temporaries select: [:var| (blockScope lookupVar: var name) isRemote]) do:
		[:var|
		 stream position = vectorStartPos ifTrue:
			[vectorStartPos > startPos ifTrue: [stream space].
			 stream nextPut: $(].
		 stream nextPutAll: var name].
	stream position > vectorStartPos ifTrue: [stream nextPut: $)]
]

<<<<<<<< HEAD:smalltalksrc/Slang/OCMethodNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-C translation' }
OCMethodNode >> quickMethodReturnLiteral [
========
{ #category : '*Slang' }
RBMethodNode >> quickMethodReturnLiteral [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBMethodNode.extension.st
	| node |
	node := body statements last value.
	^node isVariable
		ifTrue: [node name]
		ifFalse: [node value]
]
