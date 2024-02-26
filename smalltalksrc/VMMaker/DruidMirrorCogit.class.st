Class {
	#name : #DruidMirrorCogit,
	#superclass : #StackToRegisterMappingCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #'class initialization' }
DruidMirrorCogit class >> bytecodeTable [

	| found |
	^ StackToRegisterMappingCogit bytecodeTable flatCollect: [ :e |
		  (e second to: e third) collect: [ :bindex |
			  found := DruidJIT bytecodeTable detect: [ :dbytecode |
				           dbytecode second = bindex ].
			  found fourth = #unknownBytecode
				  ifTrue: [ found ]
				  ifFalse: [
					  | copy |
					  copy := e copy.
					  copy at: 2 put: bindex.
					  copy at: 3 put: bindex.
					  copy ] ] ]
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
		   entry copyReplaceAt: 2 with: [ :e | | handwrittenGenSelector |
			handwrittenGenSelector := (e copyReplaceAll: '_' with: '') asSymbol.
			self assert: (StackToRegisterMappingCogit objectRepresentationClass lookupSelector: handwrittenGenSelector) isNotNil.
			handwrittenGenSelector ]  ]
]
