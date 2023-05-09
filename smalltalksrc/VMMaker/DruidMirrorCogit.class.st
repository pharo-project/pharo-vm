Class {
	#name : #DruidMirrorCogit,
	#superclass : #StackToRegisterMappingCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #'class initialization' }
DruidMirrorCogit class >> bytecodeTable [

	^ DruidJIT bytecodeTable collect: [ :entry | "Replace just the bytecode's name"
		  entry copyReplaceAt: 4 with: [ :e | | selector |
			selector := (e copyReplaceAll: '_' with: '') asSymbol.
			selector last isDigit ifTrue: [ selector := selector allButLast ].
			selector  ] ]
]

{ #category : #initialization }
DruidMirrorCogit class >> initializeBytecodeTableForSistaV1 [

	self flag: #TODO. "Move this code to superclass (the posta)"
	numPushNilsFunction := #sistaV1:Num:Push:Nils:.
	pushNilSizeFunction := #sistaV1PushNilSize:numInitialNils:.
	BytecodeSetHasDirectedSuperSend := true.
	BytecodeSetHasExtensions := true.
	FirstSpecialSelector := 96.
	NumSpecialSelectors := 32.
	self generatorTableFrom: self bytecodeTable
]

{ #category : #initialization }
DruidMirrorCogit class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := self primitiveTableArray size.
	primitiveTable := CArrayAccessor on: (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray
]

{ #category : #'class initialization' }
DruidMirrorCogit class >> primitiveTableArray [

	^ DruidJIT primitiveTableArray collect: [ :entry | "Replace just the primitive's name"
		   entry copyReplaceAt: 2 with: [ :e | (e copyReplaceAll: '_' with: '') asSymbol ]  ]
]
