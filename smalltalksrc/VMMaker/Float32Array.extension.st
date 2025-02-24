Extension { #name : 'Float32Array' }

{ #category : '*VMMaker' }
Float32Array >> ccg: cg prolog: aBlock expr: aString index: anInteger [

	^cg ccgLoad: aBlock expr: aString asWBFloatPtrFrom: anInteger
]

{ #category : '*VMMaker' }
Float32Array >> ccgDeclareCForVar: aSymbolOrString [

	^'float *', aSymbolOrString
]
