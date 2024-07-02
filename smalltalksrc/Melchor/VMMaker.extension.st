Extension { #name : 'VMMaker' }

{ #category : '*Melchor' }
VMMaker >> createCodeGenerator [
"set up a CCodeGenerator for this VMMaker"
	^MLVMCCodeGenerator new
		vmMaker: self;
		logger: logger;
		options: optionsDictionary;
		stopOnErrors: stopOnErrors;
		yourself
]

{ #category : '*Melchor' }
VMMaker >> createCogitCodeGenerator [
	^MLVMCCodeGenerator new
		vmMaker: self;
		logger: logger;
		options: optionsDictionary;
		yourself
]
