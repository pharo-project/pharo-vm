Class {
	#name : 'MLVMCCodeGeneratorLocalizationMock',
	#superclass : 'MLVMCCodeGenerator',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'utilities' }
MLVMCCodeGeneratorLocalizationMock >> mustBeGlobal: aName [

	^ (super mustBeGlobal: aName) or: [
		  #( #instanceVariableMustBeGlobal #globalMustBeGlobal ) includes:
			  aName ]
]
