Extension { #name : 'SlangMethodPrototypeTranslationTest' }

{ #category : '*VMMaker' }
SlangMethodPrototypeTranslationTest >> setUp [

	super setUp.

	generator := MLVMCCodeGenerator new.
	generator vmMaker: VMMaker new.
	generator vmMaker vmmakerConfiguration: VMMakerConfiguration.
	generator currentMethod: (TMethod new
		labels: Set new;
		yourself).
]
