Class {
	#name : #PrintfFormatStringTest,
	#superclass : #TestCase,
	#category : #Printf
}

{ #category : #tests }
PrintfFormatStringTest >> testFprintf [
	| stream expected |
	stream := String new writeStream.
	expected := 'Here is a long string "hello world" and the same shortened "hello w       " with left flush.\The new line has a number "4.200000e+01"\and a 0-padded limited precision one "0000042.12346".' withCRs.
	self assert: expected size equals: (stream f: 'Here is a %s string "%s" and the same shortened "%-14.7s" with left flush.\nThe new line has a number "%e"
and a 0-padded limited precision one "%013.5f".'
		printf: #('long' 'hello world' 'hello world' 42.0 42.1234567)).
	self assert: expected equals: stream contents
]

{ #category : #tests }
PrintfFormatStringTest >> testManyArguments [

	self assert: 'Here is a long string "hello world" and the same shortened "hello w       " with left flush.
The new line has a number "42" and a 0-padded limited precision one "0000042.12346".' equals: ('Here is a %s string "%s" and the same shortened "%-14.7s" with left flush.\nThe new line has a number "%g" and a 0-padded limited precision one "%013.5f".'
		printf: #('long' 'hello world' 'hello world' 42.0 42.1234567))
]

{ #category : #tests }
PrintfFormatStringTest >> testOneExponent [

	self assert: 'Here is a number "42".' equals: ('Here is a number "%g".' printf: 42).
	self assert: 'Here is a number "42.000000".' equals: ('Here is a number "%f".' printf: 42).
	self assert: 'Here is a number "4.200000e+01".' equals: ('Here is a number "%e".' printf: 42).
]

{ #category : #tests }
PrintfFormatStringTest >> testOneExponentAndOneInteger [

	self assert: 'Here is a float "42.000000" and an integer "42".' equals: ('Here is a float "%f" and an integer "%d".' printf: #(42.0 42)).
]

{ #category : #tests }
PrintfFormatStringTest >> testOneExponentWithLength [

	self assert: 'Here is a string "0000042.12346".' equals: ('Here is a string "%013.5f".' printf: 42.1234567).
	self assert: 'Here is a string "    +42.12346".' equals: ('Here is a string "%+13.5f".' printf: 42.1234567).
	self assert: 'Here is a string "42.12346     ".' equals: ('Here is a string "%-13.5f".' printf: 42.1234567).
]

{ #category : #tests }
PrintfFormatStringTest >> testOneInteger [

	self assert: 'Here is a number "42".' equals: ('Here is a number "%d".' printf: 42).
]

{ #category : #tests }
PrintfFormatStringTest >> testOneIntegerWithLength [

	self assert: 'Here is a string "0000042".' equals: ('Here is a string "%07.7d".' printf: 42).
]

{ #category : #tests }
PrintfFormatStringTest >> testOnePrintPointer [

	self assert: 'Here is a pointer "0x12345678".' equals: ('Here is a pointer "%p".' printf: 16r12345678)
]

{ #category : #tests }
PrintfFormatStringTest >> testOnePrintString [

	self assert: 'Here is a point "3@4".' equals: ('Here is a point "%P".' printf: 3@4)
]

{ #category : #tests }
PrintfFormatStringTest >> testOneString [

	self assert: 'Here is a string "hello world".' equals: ('Here is a string "%s".' printf: 'hello world')
]

{ #category : #tests }
PrintfFormatStringTest >> testOneStringWithLength [

	self assert:  'Here is a string "hello world" and another shortened "hello w       ".' equals: ('Here is a string "%s" and another shortened "%-14.7s".' printf: #('hello world' 'hello world'))
]

{ #category : #tests }
PrintfFormatStringTest >> testOneStringWithVariableLength [

	self assert: 'Hello world!!' equals: ('Hello %.*s!!' printf: #(5 'world world world'))
]

{ #category : #tests }
PrintfFormatStringTest >> testReturnValue [

	self assert: 6+8 equals: ((PrintfFormatString new setFormat: 'hello %ld') printf: {12345678})
]
