Extension { #name : #WriteStream }

{ #category : #'*Printf-printing' }
WriteStream >> f: printfString printf: arguments [
	"Use the printf convention to output on the receiver."
	^(PrintfFormatter new setFormat: printfString output: self) printf: arguments
]

{ #category : #'*Printf-printing' }
WriteStream >> fprintf: printfString [
	"Use the printf convention to output on the receiver."
	^(PrintfFormatter new setFormat: printfString output: self) printf: #()
]
