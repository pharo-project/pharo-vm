Extension { #name : 'CompiledMethod' }

{ #category : '*VMMaker' }
CompiledMethod >> abstractBytecodeMessageAt: pc [

	^ [
	  (InstructionStream new method: self pc: pc)
		  interpretNextInstructionFor: nil ]
		  on: MessageNotUnderstood
		  do: [ :ex | ex message ]
]

{ #category : '*VMMaker-support' }
CompiledMethod >> abstractDetailedSymbolic [
	^String streamContents: [:s| (RelativeDetailedInstructionPrinter on: self) printInstructionsOn: s]
]

{ #category : '*VMMaker-C translation' }
CompiledMethod >> asTranslationMethodOfClass: aTMethodClass [

	^ self parseTree asTranslationMethodOfClass: aTMethodClass
]

{ #category : '*VMMaker-C translation' }
CompiledMethod >> asTranslationMethodOfClass: aTMethodClass forCodeGenerator: aCodeGenerator [

	^ self parseTree asTranslationMethodOfClass: aTMethodClass forCodeGenerator: aCodeGenerator
]
