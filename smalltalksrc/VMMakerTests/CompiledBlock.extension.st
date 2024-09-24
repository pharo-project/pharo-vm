Extension { #name : 'CompiledBlock' }

{ #category : '*VMMakerTests' }
CompiledBlock >> forMemory: memory inMethod: aMethodBuilder [ 

	| methodBuilder |
	
	methodBuilder := VMCompiledCodeBuilder new
		interpreter: aMethodBuilder interpreter; 
		memory: memory;
		fillFromPharoMethod: self;
		yourself.

	methodBuilder setOuterCode: aMethodBuilder.

	^ methodBuilder buildMethod
]
