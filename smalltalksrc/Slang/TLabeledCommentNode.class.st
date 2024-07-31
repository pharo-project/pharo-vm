"
some comment
"
Class {
	#name : 'TLabeledCommentNode',
	#superclass : 'TParseNode',
	#instVars : [
		'label',
		'asmLabel'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'accessing' }
TLabeledCommentNode class >> label: aLabel [

	^ self new
		setLabel: aLabel;
		yourself
]

{ #category : 'accessing' }
TLabeledCommentNode class >> withComment: aComment [

	^ self new
		setComment: aComment;
		yourself
]

{ #category : 'visiting' }
TLabeledCommentNode >> accept: aVisitor [
	
	^ aVisitor visitLabeledCommentNode: self
]

{ #category : 'tranforming' }
TLabeledCommentNode >> asCASTIn: aBuilder [

	| result |
	result := CCompoundStatementNode new.
	result needsBrackets: false.

	label ifNotNil: [
		| labelledNode |
		labelledNode := CLabeledStatementNode new.
		labelledNode label: (CIdentifierNode name: label).
		labelledNode statement: CEmptyStatementNode new.
		result add: labelledNode ].


	comment ifNotNil: [
		| commentNode |
		commentNode := CCommentNode new.
		commentNode comment: (String streamContents: [ :s |
				 s space.
				 s nextPutAll: self comment.
				 s space ]).
		result add: commentNode.
		aBuilder previousCommenter: self ].

	(asmLabel notNil and: [
		 aBuilder currentMethod selector == #interpret ]) ifTrue: [
		| asmLabelNode |
		asmLabelNode := aBuilder asmLabelNodeFor: asmLabel.
		result add: asmLabelNode ]. "only output labels in the interpret function."

	^ result
]

{ #category : 'accessing' }
TLabeledCommentNode >> asmLabel [

	^asmLabel
]

{ #category : 'accessing' }
TLabeledCommentNode >> asmLabel: labelString [

	asmLabel := labelString
]

{ #category : 'accessing' }
TLabeledCommentNode >> children [
	
	^ #()
]

{ #category : 'testing' }
TLabeledCommentNode >> isComment [
	"Answer true if the receiver is just a comment (i.e., it has no label)."

	^label = nil
]

{ #category : 'testing' }
TLabeledCommentNode >> isLabel [

	^true
]

{ #category : 'testing' }
TLabeledCommentNode >> isLeaf [

	^true
]

{ #category : 'comparing' }
TLabeledCommentNode >> isSameAs: anotherNode [ 
	
	^anotherNode isLabel
	 and: [comment = anotherNode comment]
]

{ #category : 'accessing' }
TLabeledCommentNode >> label [

	^label
]

{ #category : 'testing' }
TLabeledCommentNode >> needsTrailingSemicolon [
	"Answer if, when emitted as a statement (in particular in a TStmtList), the
	 receiver needs a trailing semicolon.  Comments do not.  You'd think that
	 labels do not, but we put them at the end of blocks where there needs
	 to be a null statement following the label and before the end of block."
	^self isComment not
]

{ #category : 'enumerating' }
TLabeledCommentNode >> nodesDo: aBlock parent: parent [
	aBlock value: self value: parent
]

{ #category : 'printing' }
TLabeledCommentNode >> printOn: aStream level: level [

	self printOptionalLabelOn: aStream.
	comment ifNotNil:
		[aStream nextPut: $".
		 aStream nextPutAll: comment.
		 aStream nextPut: $"]
]

{ #category : 'printing' }
TLabeledCommentNode >> printOptionalLabelOn: aStream [

	label ifNotNil: [ 
		self unindentTabs: aStream.
		aStream
			nextPutAll: label;
			nextPut: $:;
			cr;
			nextPut: $; ]
]

{ #category : 'accessing' }
TLabeledCommentNode >> setComment: commentString [

	label := nil.
	comment := commentString.
]

{ #category : 'accessing' }
TLabeledCommentNode >> setLabel: labelString [

	label := labelString.
]

{ #category : 'accessing' }
TLabeledCommentNode >> setLabel: labelString comment: commentString [

	label := labelString.
	comment := commentString.
]

{ #category : 'C code generation' }
TLabeledCommentNode >> unindentTabs: aStream [
	"Remove all but one tab up to the beginning of line from the given stream if possible."

	(aStream isKindOf: ReadWriteStream) ifFalse: [ ^self ].
	[aStream position > 0] whileTrue:
		[aStream position: aStream position - 1.
		 "restore stream position if previous char was not a tab"
		 aStream peek == Character tab ifFalse:
			[^aStream next; tab]]
]
