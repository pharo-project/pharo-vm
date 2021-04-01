"
I am a GLR based C scanner.
"
Class {
	#name : #CASTScanner,
	#superclass : #SmaCCScanner,
	#category : #'CAST-Parser'
}

{ #category : #'generated-initialization' }
CASTScanner class >> initializeKeywordMap [
	keywordMap := Dictionary new.
	#(#(76 'auto' 70) #(76 'break' 48) #(76 'case' 38) #(76 'char' 73) #(76 'const' 40) #(76 'continue' 47) #(76 'default' 39) #(76 'do' 54) #(76 'double' 60) #(76 'else' 46) #(76 'enum' 51) #(76 'extern' 58) #(76 'float' 67) #(76 'for' 49) #(76 'goto' 50) #(76 'if' 42) #(76 'int' 69) #(76 'long' 66) #(76 'register' 71) #(76 'return' 13) #(76 'short' 68) #(76 'signed' 56) #(76 'sizeof' 24) #(76 'static' 61) #(76 'struct' 43) #(76 'switch' 52) #(76 'typedef' 57) #(76 'union' 44) #(76 'unsigned' 55) #(76 'void' 72) #(76 'volatile' 41) #(76 'while' 53))
		do: [ :each | 
			(keywordMap at: each first ifAbsentPut: [ Dictionary new ])
				at: (each at: 2)
				put: each last ].
	^ keywordMap
]

{ #category : #generated }
CASTScanner >> emptySymbolTokenId [
	^ 149
]

{ #category : #generated }
CASTScanner >> errorTokenId [
	^ 150
]

{ #category : #generated }
CASTScanner >> scan1 [
	[ self step.
	currentCharacter == $"
		ifTrue: [ ^ self recordAndReportMatch: #(78) ].
	currentCharacter == $\
		ifTrue: [ self step.
			^ self scan1 ].
	true ] whileTrue
]

{ #category : #generated }
CASTScanner >> scan10 [
	[ self recordMatch: #(77).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan9 ].
	currentCharacter between: $0 and: $9 ] whileTrue.
	('Ee' includes: currentCharacter)
		ifTrue: [ ^ self scan6 ].
	('LUlu' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(77) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan2 [
	self step.
	currentCharacter == $\
		ifTrue: [ ^ self scan4 ].
	(currentCharacter <= $!
		or: [ (currentCharacter between: $# and: $[)
				or: [ currentCharacter >= $] ] ])
		ifTrue: [ ^ self scan3 ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan3 [
	[ self step.
	currentCharacter == $'
		ifTrue: [ [ self recordMatch: #(77).
			self step.
			currentCharacter == $' ] whileTrue.
			currentCharacter == $\
				ifTrue: [ ^ self scan4 ].
			(currentCharacter <= $!
				or: [ (currentCharacter between: $# and: $&)
						or: [ (currentCharacter between: $( and: $[)
								or: [ currentCharacter >= $] ] ] ])
				ifTrue: [ ^ self scan3 ].
			^ self reportLastMatch ].
	currentCharacter == $\
		ifTrue: [ ^ self scan4 ].
	currentCharacter <= $!
		or: [ (currentCharacter between: $# and: $&)
				or: [ (currentCharacter between: $( and: $[)
						or: [ currentCharacter >= $] ] ] ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan4 [
	self step.
	^ self scan3
]

{ #category : #generated }
CASTScanner >> scan5 [
	[ self recordMatch: #(77).
	self step.
	currentCharacter between: $0 and: $9 ] whileTrue.
	('Ee' includes: currentCharacter)
		ifTrue: [ ^ self scan6 ].
	('FLfl' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(77) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan6 [
	self step.
	('+-' includes: currentCharacter)
		ifTrue: [ self step ].
	(currentCharacter between: $0 and: $9)
		ifTrue: [ ^ self scan7 ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan7 [
	[ self recordMatch: #(77).
	self step.
	currentCharacter between: $0 and: $9 ] whileTrue.
	('FLfl' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(77) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scan8 [
	[ self step.
	currentCharacter == $*
		ifTrue: [ [ self step.
			currentCharacter == $* ] whileTrue.
			currentCharacter == $/
				ifTrue: [ ^ self recordAndReportMatch: #(75) ].
			^ self scan8 ].
	true ] whileTrue
]

{ #category : #generated }
CASTScanner >> scan9 [
	self step.
	(currentCharacter between: $0 and: $9)
		ifTrue: [ ^ self scan5 ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForToken [
	self step.
	currentCharacter == $!
		ifTrue:
			[ ^ self scanForTokenX18 ].
	currentCharacter == $"
		ifTrue: [ ^ self scan1 ].
	currentCharacter == $%
		ifTrue:
			[ ^ self scanForTokenX12 ].
	currentCharacter == $&
		ifTrue:
			[ ^ self scanForTokenX11 ].
	currentCharacter == $'
		ifTrue: [ ^ self scan2 ].
	currentCharacter == $(
		ifTrue: [ ^ self recordAndReportMatch: #(25) ].
	currentCharacter == $)
		ifTrue: [ ^ self recordAndReportMatch: #(26) ].
	currentCharacter == $*
		ifTrue:
			[ ^ self scanForTokenX17 ].
	currentCharacter == $+
		ifTrue:
			[ ^ self scanForTokenX10 ].
	^ self scanForTokenX20
]

{ #category : #generated }
CASTScanner >> scanForTokenX1 [
	self recordMatch: #(77).
	self step.
	currentCharacter == $.
		ifTrue: [ ^ self scan9 ].
	(currentCharacter between: $0 and: $9)
		ifTrue: [ ^ self scan10 ].
	('Ee' includes: currentCharacter)
		ifTrue: [ ^ self scan6 ].
	('Xx' includes: currentCharacter)
		ifTrue: [ self step.
			((currentCharacter between: $0 and: $9)
				or: [ (currentCharacter between: $A and: $F)
						or: [ currentCharacter between: $a and: $f ] ])
				ifTrue: [ [ self recordMatch: #(77).
					self step.
					(currentCharacter between: $0 and: $9)
						or: [ (currentCharacter between: $A and: $F)
								or: [ currentCharacter between: $a and: $f ] ] ] whileTrue.
					('LUlu' includes: currentCharacter)
						ifTrue: [ ^ self recordAndReportMatch: #(77) ] ].
			^ self reportLastMatch ].
	('LUlu' includes: currentCharacter)
		ifTrue: [ ^ self recordAndReportMatch: #(77) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX10 [
	self recordMatch: #(35).
	self step.
	currentCharacter == $+
		ifTrue: [ ^ self recordAndReportMatch: #(23) ].
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(11) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX11 [
	self recordMatch: #(28).
	self step.
	currentCharacter == $&
		ifTrue: [ ^ self recordAndReportMatch: #(5) ].
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(63) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX12 [
	self recordMatch: #(30).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(10) ].
	currentCharacter == $>
		ifTrue: [ ^ self recordAndReportMatch: #(82) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX13 [
	[ self recordMatch: #(83).
	self step.
	currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ] ] whileTrue.
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX14 [
	self recordMatch: #(1).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(64) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX15 [
	self recordMatch: #(17).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(3) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX16 [
	self recordMatch: #(16).
	self step.
	currentCharacter == $>
		ifTrue: [ ^ self recordAndReportMatch: #(80) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX17 [
	self recordMatch: #(34).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(12) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX18 [
	self recordMatch: #(32).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(4) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX19 [
	currentCharacter == $[
		ifTrue: [ ^ self recordAndReportMatch: #(79) ].
	currentCharacter == $]
		ifTrue: [ ^ self recordAndReportMatch: #(80) ].
	currentCharacter == $^
		ifTrue:
			[ ^ self scanForTokenX14 ].
	currentCharacter == ${
		ifTrue: [ ^ self recordAndReportMatch: #(81) ].
	currentCharacter == $|
		ifTrue:
			[ ^ self scanForTokenX8 ].
	currentCharacter == $}
		ifTrue: [ ^ self recordAndReportMatch: #(82) ].
	currentCharacter == $~
		ifTrue: [ ^ self recordAndReportMatch: #(31) ].
	(currentCharacter between: $1 and: $9)
		ifTrue: [ ^ self scan10 ].
	(currentCharacter isSeparator
		or: [ currentCharacter == Character pageUp ])
		ifTrue:
			[ ^ self scanForTokenX13 ].
	currentCharacter isSafeForHTTP
		ifTrue:
			[ self scanForTokenX4 ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX2 [
	self recordMatch: #(76).
	self step.
	currentCharacter == $"
		ifTrue: [ ^ self scan1 ].
	currentCharacter == $'
		ifTrue: [ ^ self scan2 ].
	((currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_ or: [ currentCharacter between: $a and: $z ] ] ])
		ifTrue: [ [ self recordMatch: #(76).
			self step.
			(currentCharacter between: $0 and: $9)
				or: [ (currentCharacter between: $A and: $Z)
						or: [ currentCharacter == $_ or: [ currentCharacter between: $a and: $z ] ] ] ]
				whileTrue ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX20 [
	currentCharacter == $,
		ifTrue: [ ^ self recordAndReportMatch: #(21) ].
	currentCharacter == $-
		ifTrue:
			[ ^ self scanForTokenX6 ].
	currentCharacter == $.
		ifTrue:
			[ ^ self scanForTokenX5 ].
	currentCharacter == $/
		ifTrue:
			[ ^ self scanForTokenX9 ].
	currentCharacter == $0
		ifTrue:
			[ ^ self scanForTokenX1 ].
	currentCharacter == $:
		ifTrue:
			[ ^ self scanForTokenX16 ].
	currentCharacter == $;
		ifTrue: [ ^ self recordAndReportMatch: #(65) ].
	currentCharacter == $<
		ifTrue:
			[ ^ self scanForTokenX3 ].
	currentCharacter == $=
		ifTrue:
			[ ^ self scanForTokenX15 ].
	currentCharacter == $>
		ifTrue:
			[ ^ self scanForTokenX7 ].
	currentCharacter == $?
		ifTrue: [ ^ self recordAndReportMatch: #(15) ].
	currentCharacter == $L
		ifTrue:
			[ ^ self scanForTokenX2 ].
	^ self scanForTokenX19
]

{ #category : #generated }
CASTScanner >> scanForTokenX3 [
	self recordMatch: #(18).
	self step.
	currentCharacter == $%
		ifTrue: [ ^ self recordAndReportMatch: #(81) ].
	currentCharacter == $:
		ifTrue: [ ^ self recordAndReportMatch: #(79) ].
	currentCharacter == $<
		ifTrue: [ self recordMatch: #(33).
			self step.
			currentCharacter == $=
				ifTrue: [ ^ self recordAndReportMatch: #(45) ].
			^ self reportLastMatch ].
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(7) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX4 [
	[ self recordMatch: #(76).
	self step.
	(currentCharacter between: $0 and: $9)
		or: [ (currentCharacter between: $A and: $Z)
				or: [ currentCharacter == $_ or: [ currentCharacter between: $a and: $z ] ] ] ]
		whileTrue
]

{ #category : #generated }
CASTScanner >> scanForTokenX5 [
	self recordMatch: #(27).
	self step.
	currentCharacter == $.
		ifTrue: [ self step.
			currentCharacter == $.
				ifTrue: [ ^ self recordAndReportMatch: #(74) ].
			^ self reportLastMatch ].
	(currentCharacter between: $0 and: $9)
		ifTrue: [ ^ self scan5 ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX6 [
	self recordMatch: #(36).
	self step.
	currentCharacter == $-
		ifTrue: [ ^ self recordAndReportMatch: #(20) ].
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(19) ].
	currentCharacter == $>
		ifTrue: [ ^ self recordAndReportMatch: #(22) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX7 [
	self recordMatch: #(6).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(8) ].
	currentCharacter == $>
		ifTrue: [ self recordMatch: #(14).
			self step.
			currentCharacter == $=
				ifTrue: [ ^ self recordAndReportMatch: #(62) ] ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX8 [
	self recordMatch: #(2).
	self step.
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(59) ].
	currentCharacter == $|
		ifTrue: [ ^ self recordAndReportMatch: #(9) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> scanForTokenX9 [
	self recordMatch: #(29).
	self step.
	currentCharacter == $*
		ifTrue: [ ^ self scan8 ].
	currentCharacter == $=
		ifTrue: [ ^ self recordAndReportMatch: #(37) ].
	^ self reportLastMatch
]

{ #category : #generated }
CASTScanner >> tokenActions [
	^ #(nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil #comment nil nil nil nil nil nil nil #whitespace)
]
