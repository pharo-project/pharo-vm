Extension { #name : #CGLRAbstractNode }

{ #category : #'*Slang' }
CGLRAbstractNode >> prettyPrintOn: aStream [

	| prettyPrinter |
	prettyPrinter := CSlangPrettyPrinter new.
	prettyPrinter writeStream: aStream.
	self acceptVisitor: prettyPrinter
]
