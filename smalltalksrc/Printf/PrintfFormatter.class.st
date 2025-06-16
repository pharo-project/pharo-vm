"
PrintfFormatter implements something close to C89's printf(3), outputting to a given stream.

Format description
	syntax: %{flags}{width}{precision}{length modifier}<operator>
	
	flags
		-		left flush
		+		right flush
		space	non-negative numbers are left padded with blanks
		#		display integer with a radix indicator (0=octal, 0x=hex, float have .)
		0		0 is used as left padding character for numbers
	width		minimum field width (rest is padded)
	.precision	maximum field width or trailing digits
	l,h			ignored but noted so that a printf string can print itself accurately
	operator
		a,A		float in hex
		c,C		display object as character (in printf(3) C implies wide character, a.k.a. lc, but MS differs)
		d		display as integer
		e,E		float in scientific notation
		f		display as float
		g,G		display as f or e,E using least amount of space
		o		display as octal value
		p		display as pointer (hex, prefixed with '0x')
		P		output the printString of the argument (an extension for Smalltalk)
		s,S		display as string (in printf(3) S implies wide string, a.k.a. ls, but MS differs)
		u		display as unsigned
		x,X		display as hex value	
"
Class {
	#name : #PrintfFormatter,
	#superclass : #Object,
	#instVars : [
		'format',
		'string',
		'outputStream',
		'arguments',
		'total'
	],
	#category : #Printf
}

{ #category : #examples }
PrintfFormatter class >> examples [
	"self examples"
	Transcript f: 'Here is a string "%s".\n' printf: 'hello world'.
	Transcript f: 'Here is a string "%s" and another shortened "%-14.7s".\n' printf: #('hello world' 'hello world').

	Transcript f: 'Here is a number "%d".\n' printf: 42.
	Transcript f: 'Here is a string "%07.7d".\n' printf: 42.

	Transcript f: 'Here is a number "%e".\n' printf: 42.0.
	Transcript f: 'Here is a float "%e" and an integer "%d".\n' printf: #(42.0 42).
	Transcript f: 'Here is a string "%013.5e".\n' printf: 42.1234567.

	Transcript f: 'Here is a %s string "%s" and the same shortened "%-14.7s" with left flush.\nThe new line has a number "%e" and a 0-padded limited precision one "%013.5e".\n'
		printf: { 'long'. 'hello world'. 'hello world'. 42.0. 42.1234567}.

	Transcript f: 'Here is a string shortened with a variable via %%.*s\nHello %.*s!!\n' printf: #(5 'world world world')
]

{ #category : #printf }
PrintfFormatter >> << object [ 
	"Render object according to next format descriptor in format. 
	Append it to string"
	"Format description 
	syntax: %{flags}{width}{precision}{long}<operator> 
	
	flags 
		-		left flush 
		+		right flush 
		space	non-negative number are preceeded by a blank 
		#		display integer with a radix indicator (0=octal, 0x=hex, float have .) 
		0		0 is used as left padding character for numbers 
	width		minimum field width (rest is padded) 
	.precision	maximum field width or trailing digits 
	long		ignored 
	operator 
		c		display object as character 
		d		display as integer 
		e,E		float in scientific notation 
		f		display as float 
		g,G		display as f or e,E using least amount of space 
		o		display as octal value 
		s		display as string 
		u		display as unsigned 
		x,X		display as hex value 
	"

	outputStream nextPutAll: string next.
	outputStream nextPutAll: (format next render: object for: self).
	format atEnd ifTrue: 
		[format reset.
		outputStream nextPutAll: string next.
		string reset].
	^self string
]

{ #category : #private }
PrintfFormatter >> collectFormatDescriptorsAndStrings: formatStream [
	format := ReadWriteStream on: (Array new: 10).
	string := ReadWriteStream on: (Array new: 10).
	[| descriptor |
	 "copy actual formatstrings to format"
	 string nextPut: (self scanStringFrom: formatStream).
	 formatStream atEnd ifTrue:
		[self reset.
		 ^self].
	 descriptor := PrintfFormatDescriptor scanFrom: formatStream.
	 "copy any nonformating text to string"
	 descriptor isArray
		ifTrue: [format nextPutAll: descriptor]
		ifFalse: [format nextPut: descriptor]] repeat
]

{ #category : #printf }
PrintfFormatter >> f: aStream printf: arguments [
	"inst var string holds all text contained in the formatstring. %f blabla %d"
	| savedStream |
	savedStream := outputStream.
	outputStream := aStream.
	self reset.
	^[self process: arguments]
		ensure: [outputStream := savedStream]
]

{ #category : #accessing }
PrintfFormatter >> nextArgument [
	^arguments next
]

{ #category : #accessing }
PrintfFormatter >> nextFormat [
	^format next
]

{ #category : #private }
PrintfFormatter >> output: aString [
	| code length |
	length := aString basicSize. "Use basicSize to coerce nil to the null string..."
	length > 0 ifTrue:
		[total := total + length.
		 outputStream nextPutAll: aString.
		 code := aString basicAt: length.
		 (code = 10 or: [code = 13]) ifTrue:
			[outputStream flush]]
]

{ #category : #printf }
PrintfFormatter >> printf: arguments [
	"inst var string holds all text contained in the formatstring. %f blabla %d"

	"inst var format is a stream of FormatDescriptors"
	self reset.
	^self process: arguments
]

{ #category : #private }
PrintfFormatter >> process: argumentOrArgumentArray [
 	arguments := ReadStream on: argumentOrArgumentArray asArgumentArrayForFormatString.
	[arguments atEnd] whileFalse:
		["put any text from the format string into outputStream"
		self output: string next. 
		"get next FormatDescriptor from format and render object as specified"
		format atEnd ifFalse: [self output: (format next render: arguments next for: self)]].
	"any remainder is string, if so append to outputStream"
	string atEnd ifFalse: [self output: string next].
	^total
]

{ #category : #private }
PrintfFormatter >> reset [
	format reset.
	string reset.
	total := 0
]

{ #category : #private }
PrintfFormatter >> scanStringFrom: aStream [ 
	| newString |
	newString := (String new: 40) writeStream.
	[aStream atEnd] whileFalse: 
		[| next | 
		next := aStream next.
		next == $% ifTrue:
			[aStream peek ~~ $% ifTrue: [^newString contents].
			 aStream next].
		next == $\ ifTrue: 
				[next := aStream next.
				next == $n ifTrue: [next := Character cr].
				next == $t ifTrue: [next := Character tab].
				next == $r ifTrue: [next := Character cr].
				next == $\ ifTrue: [next := $\]].
		newString nextPut: next].
	^newString contents
]

{ #category : #'initialize-release' }
PrintfFormatter >> setFormat: aFormatString [
	outputStream := (String new: (aFormatString size max: 20)) writeStream.
	self collectFormatDescriptorsAndStrings: aFormatString readStream
]

{ #category : #'initialize-release' }
PrintfFormatter >> setFormat: aFormatString output: aStreamOrSelector [
	"copy actual formatstrings to format"
	"copy any nonformating text to string"
	"For the VM simulator accept a selector, e.g. #stderr, and respond by searching the stack for an implementor of the selector."
	aStreamOrSelector isSymbol
		ifTrue: [thisContext findContextSuchThat:
					[:ctxt|
					 ([ctxt receiver perform: aStreamOrSelector]
								on: MessageNotUnderstood
								do: [:ex| ex return: nil])
						ifNil: [false]
						ifNotNil: [:result|
							outputStream := result.
							true]]]
		ifFalse: [outputStream := aStreamOrSelector].
	self collectFormatDescriptorsAndStrings: aFormatString readStream
]

{ #category : #printf }
PrintfFormatter >> string [
	^outputStream contents
]
