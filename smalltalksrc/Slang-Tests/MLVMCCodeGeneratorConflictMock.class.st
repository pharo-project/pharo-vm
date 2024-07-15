Class {
	#name : 'MLVMCCodeGeneratorConflictMock',
	#superclass : 'MLVMCCodeGenerator',
	#instVars : [
		'slangTyper'
	],
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'type inference' }
MLVMCCodeGeneratorConflictMock >> inferTypes [
	slangTyper  := 	SlangTyperConflictMock new
		codeGenerator: self.
	(slangTyper)
		stopOnErrors: stopOnErrors;
		inferTypes
]

{ #category : 'accessing' }
MLVMCCodeGeneratorConflictMock >> slangTyper [ 
	^ slangTyper
]
