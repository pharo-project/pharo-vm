Extension { #name : 'WordArray' }

{ #category : '*VMMaker-Simulation-accessing' }
WordArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 4
]

{ #category : '*VMMaker-plugin generation' }
WordArray class >> ccg: cg prolog: aBlock expr: aString index: anInteger [

	^cg 
		ccgLoad: aBlock 
		expr: aString 
		asUnsignedPtrFrom: anInteger
		andThen: (cg ccgValBlock: 'isWords')
]

{ #category : '*VMMaker-plugin generation' }
WordArray class >> ccgDeclareCForVar: aSymbolOrString [
	"Address of an unsigned 32 bit value, regardless of Smalltalk wordSize"

	^'unsigned *', aSymbolOrString
]
