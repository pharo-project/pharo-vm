Class {
	#name : 'VMStackPageSurrogate',
	#superclass : 'Object',
	#instVars : [
		'address',
		'stackPages',
		'memory',
		'zoneBase',
		'zoneLimit'
	],
	#category : 'VMMaker-InterpreterSimulation',
	#package : 'VMMaker',
	#tag : 'InterpreterSimulation'
}

{ #category : 'comparing' }
VMStackPageSurrogate >> = aThing [
	^aThing class = self class
	and: [aThing address = address]
]

{ #category : 'accessing' }
VMStackPageSurrogate >> address [
	^address
]

{ #category : 'instance initialization' }
VMStackPageSurrogate >> address: theAddress simulator: aCoInterpreterSimulator zoneBase: base zoneLimit: limit [
	address := theAddress.
	stackPages := aCoInterpreterSimulator stackPages.
	memory := aCoInterpreterSimulator memoryManager.
	zoneBase := base.
	zoneLimit := limit
]

{ #category : 'testing' }
VMStackPageSurrogate >> addressIsInPage: address [
	"For assert-checking"
	^self lastAddress < address and: [address < self baseAddress]
]

{ #category : 'accessing' }
VMStackPageSurrogate >> asInteger [
	^address
]

{ #category : 'accessing' }
VMStackPageSurrogate >> asIntegerPtr [
	^address
]

{ #category : 'accessing' }
VMStackPageSurrogate >> asUnsignedInteger [
	^address
]

{ #category : 'accessing' }
VMStackPageSurrogate >> asUnsignedIntegerPtr [
	^address
]

{ #category : 'comparing' }
VMStackPageSurrogate >> hash [
	^address hash
]

{ #category : 'testing' }
VMStackPageSurrogate >> isFree [
	^self baseFP = 0
]

{ #category : 'printing' }
VMStackPageSurrogate >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $@; print: address; nextPut: $/.
	address printOn: aStream base: 16
]
