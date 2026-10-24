Class {
	#name : 'CogitDecompiler',
	#superclass : 'Object',
	#instVars : [
		'temporaries'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'ast building' }
CogitDecompiler >> argumentNodesFor: argumentNames [

	^ argumentNames collect: [ :arg |
		  | argString |
		  argString := arg.
		  (argString includes: $/) ifTrue: [
			  argString := ($/ split: argString) first ].

		  argString isAllDigits
			  ifTrue: [ self literalNumber: argString asNumber ]
			  ifFalse: [ RBVariableNode named: argString ] ]
]

{ #category : 'api' }
CogitDecompiler >> buildFrom: abstractInstructions [

	| statements |
	statements := abstractInstructions
		              collect: [ :absInt | self statementFor: absInt ]
		              thenReject: [ :statement | statement isNil ].

	^ RBMethodNode selector: #foo arguments: {  } body: (RBSequenceNode
			   temporaries: self temporariesNode
			   statements: statements)
]

{ #category : 'ast building' }
CogitDecompiler >> compilerNode [

	^ RBVariableNode named: 'cogit'
]

{ #category : 'decompiling' }
CogitDecompiler >> generateAdd: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Add' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateAlignment: anAbstractInstruction [

	^ RBMessageNode receiver: self compilerNode selector: #Nop
]

{ #category : 'decompiling' }
CogitDecompiler >> generateAnd: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'And' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateCall: anAbstractInstruction [

	| address |
	address := anAbstractInstruction operands first.

	^ RBMessageNode
		  receiver: self compilerNode
		  selector: #CallRT:
		  arguments: { (self literalAddress: address) }
]

{ #category : 'decompiling' }
CogitDecompiler >> generateCmp: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Cmp' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateJump: anAbstractInstruction [

	| selector label variableName |
	selector := anAbstractInstruction opCodeName , ':'.
	label := anAbstractInstruction operands first.
	variableName := 'label' , label operands first asString.

	^ RBMessageNode
		  receiver: self compilerNode
		  selector: selector
		  arguments: { (RBVariableNode named: variableName) }
]

{ #category : 'decompiling' }
CogitDecompiler >> generateLabel: anAbstractInstruction [

	| index variableName |
	index := anAbstractInstruction operands first.
	variableName := 'label' , index asString.

	temporaries add: variableName.

	^ RBAssignmentNode
		  variable: (RBVariableNode named: variableName)
		  value:
		  (RBMessageNode receiver: self compilerNode selector: #Label)
]

{ #category : 'decompiling' }
CogitDecompiler >> generateMove: anAbstractInstruction [ 

	| selector arguments opName |
	opName := (anAbstractInstruction opCodeName includesSubstring: 'PatcheableC')
					ifTrue: [ 'MovePatcheableC' ]
					ifFalse: [ 'Move' ].
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: opName size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.

	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generatePop: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Pop' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generatePush: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Push' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateRet: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Ret' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateSub: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Sub' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'decompiling' }
CogitDecompiler >> generateTst: anAbstractInstruction [ 

	| selector arguments |
	selector := self selectorForOpCode: anAbstractInstruction opCodeName after: 'Tst' size.
	arguments := self argumentNodesFor: anAbstractInstruction argumentNames.
	
	^ RBMessageNode 
		receiver: self compilerNode
		selector:  selector
		arguments: arguments
]

{ #category : 'initialization' }
CogitDecompiler >> initialize [

	super initialize.
	temporaries := OrderedCollection new
]

{ #category : 'as yet unclassified' }
CogitDecompiler >> kindOfOpCode: opCodeName [
	" #MoveCqR -> 'Move' "

	[ :c | c isUppercase ]
		split: opCodeName
		indicesDo: [ :start :end |
		end > 1 ifTrue: [ ^ opCodeName copyFrom: 1 to: end ] ].
	
	self unexplored
]

{ #category : 'ast building' }
CogitDecompiler >> literalAddress: address [

	^ RBLiteralValueNode new
		  value: address
		  start: 0
		  stop: -1
		  source: address hex
]

{ #category : 'ast building' }
CogitDecompiler >> literalNumber: aNumber [

	aNumber < 10000 ifTrue: [ ^ RBLiteralNode value: aNumber ].
	^ self literalAddress: aNumber
]

{ #category : 'ast building' }
CogitDecompiler >> selectorForOpCode: opCodeName after: index [

	^ String streamContents: [ :s |
		  opCodeName doWithIndex: [ :char :i |
			  (i > (index + 1) and: [
				   char isUppercase or: [
					   char = $r and: [
						   i = opCodeName size or: [ (opCodeName at: i + 1) = $R ] ] ] ])
				  ifTrue: [ s << ':' ].
			  s << char ].
		  s << ':' ]
]

{ #category : 'as yet unclassified' }
CogitDecompiler >> statementFor: anAbstractInstruction [
	"a CogOutOfLineLiteralsARMv8Compiler (MoveCqR 0 ReceiverResultReg D2800017@320000520)"

	| kind |
	anAbstractInstruction address ifNil: [ ^ nil ].
	
	kind := self kindOfOpCode: anAbstractInstruction opCodeName.
	^ kind asSymbol
		caseOf: {
				([ #Move ] -> [ self generateMove: anAbstractInstruction ]).
				([ #Push ] -> [ self generatePush: anAbstractInstruction ]).
				([ #Pop ] -> [ self generatePop: anAbstractInstruction ]).
				([ #Call ] -> [ self generateCall: anAbstractInstruction ]).
				([ #Label ] -> [ self generateLabel: anAbstractInstruction ]).
				([ #And ] -> [ self generateAnd: anAbstractInstruction ]).
				([ #Jump ] -> [ self generateJump: anAbstractInstruction ]).
				([ #Cmp ] -> [ self generateCmp: anAbstractInstruction ]).
				([ #Tst ] -> [ self generateTst: anAbstractInstruction ]).
				([ #Add ] -> [ self generateAdd: anAbstractInstruction ]).
				([ #Sub ] -> [ self generateSub: anAbstractInstruction ]).
				([ #Ret ] -> [ self generateRet: anAbstractInstruction ]).
				([ #Alignment ] -> [ self generateAlignment: anAbstractInstruction "?" ]).
				([ #Literal ] -> [ "?" ]). }
		otherwise: [ self shouldBeImplemented ]
]

{ #category : 'ast building' }
CogitDecompiler >> temporariesNode [

	^ temporaries collect: [ :name | RBVariableNode named: name ]
]
