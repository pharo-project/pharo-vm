Class {
	#name : #CogSimulatedAddresses,
	#superclass : #Object,
	#instVars : [
		'simulatedAddresses',
		'simulatedTrampolines',
		'simulatedVariables',
		'cogit',
		'simulatedRanges'
	],
	#category : #'VMMaker-JITSimulation'
}

{ #category : #accessing }
CogSimulatedAddresses >> cogit: aValue [

	cogit := aValue
]

{ #category : #private }
CogSimulatedAddresses >> fakeAddressFor: anObject index: index [
	"Answer a fake address for some variable based on some index.
	 The index will usually be the size of simulatedAddresses, but
	 in determining the varBaseAddress we take a guess at the final
	 size of simulatedAddresses."
	<doNotGenerate>
	^(index + 101 * cogit objectMemory wordSize) negated
		bitAnd: ((cogit backEnd notNil
				and: [cogit backEnd wantsNearAddressFor: anObject])
					ifTrue: [cogit addressSpaceMask]
					ifFalse: [cogit allButTopBitOfAddressSpaceMask])
]

{ #category : #accessing }
CogSimulatedAddresses >> fakeVarBaseAddress [
	"We expect simulatedAddresses to have around 40 entries.  48 is hopefully a good maximum."
	<doNotGenerate>
	^self fakeAddressFor: nil index: 48
]

{ #category : #accessing }
CogSimulatedAddresses >> forAddress: anInteger [ 
	
	self forAddress: anInteger 
		ifFound: [ :anAccessor | ^ anAccessor ] 
		ifNone: [ self error: 'Could not find simulated address ', anInteger ]
]

{ #category : #accessing }
CogSimulatedAddresses >> forAddress: address ifFound: aFoundBlock ifNone: aNoneBlock [

	(simulatedTrampolines includesKey: address) ifTrue:
		[^ aFoundBlock cull: (simulatedTrampolines at: address)].

	(simulatedVariables includesKey: address) ifTrue:
		[^ aFoundBlock cull: (simulatedVariables at: address)].
	
	^ aNoneBlock value
]

{ #category : #private }
CogSimulatedAddresses >> getReceiverForSelector: selectorOrAddress [
	
	^ { cogit. cogit coInterpreter. cogit backEnd. self } 
		detect: [ :aPossibleReceiver | aPossibleReceiver respondsTo: selectorOrAddress ]
		ifNone: [ self ].

]

{ #category : #trampolines }
CogSimulatedAddresses >> hasTrampolineAtAddress: anInteger [ 
	
	^ simulatedTrampolines includesKey: anInteger
]

{ #category : #initialization }
CogSimulatedAddresses >> initialize [

	super initialize.
	
	simulatedAddresses := Dictionary new. 
	simulatedTrampolines := Dictionary new.
	simulatedVariables := Dictionary new.

]

{ #category : #'simulation only' }
CogSimulatedAddresses >> mapPrimitive: primitiveRoutine "<Symbol>" withIndexToUniqueAddress: primIndex [ "<SmallInteger>"
	| uniqueAddress |

	<doNotGenerate>

	self assert: (primitiveRoutine isSymbol or: [primitiveRoutine isBlock]).

	uniqueAddress := -1 - cogit methodZoneBase - (primIndex * 4) - 16r1000 
		bitAnd: cogit allButTopBitOfAddressSpaceMask.
	
	simulatedTrampolines
		at: uniqueAddress
		ifAbsentPut:
			[primitiveRoutine isSymbol
				ifTrue: [MessageSend 
						receiver: cogit coInterpreter 
						selector: primitiveRoutine
						arguments: (1 to: primitiveRoutine numArgs) asArray ]
				ifFalse: [primitiveRoutine]].
	^uniqueAddress
]

{ #category : #private }
CogSimulatedAddresses >> simulatedAddressFor: anObject [
	"Answer a simulated address for a block or a symbol.  This is an address that
	 can be called, read or written by generated machine code, and will be mapped
	 into a Smalltalk message send or block evaluation.

	 N.B. These addresses are at the top end of the bottom half of the address space
	 so that they don't have the sign bit set and so will not look like negative numbers,
	 unless they're the short-cut routines on ARM, where we want to use a bl, not a blx."
	<doNotGenerate>
	^simulatedAddresses
		at: anObject
		ifAbsentPut: [self fakeAddressFor: anObject index: simulatedAddresses size]
]

{ #category : #'simulated variables' }
CogSimulatedAddresses >> simulatedReadOnlyVariableAccessor: getterSelector in: receiver [
	"Answer a simulated variable.  This is a variable whose value can be read
	 and written by generated machine code."

	<doNotGenerate>
	| address accessor |

	accessor := CogSimulatedVariable getterSelector: getterSelector in: receiver.

	address := self simulatedAddressFor: accessor.

	accessor address: address.

	^ simulatedVariables
		at: address
		ifAbsentPut: [accessor].

	
]

{ #category : #trampolines }
CogSimulatedAddresses >> simulatedTrampolineFor: selectorOrAddress [
	"Set a simulated trampoline.  This is a method in the cogit, coInterpreter
	 or objectMemory that is called from a machine code trampoline."
	<doNotGenerate>
	| address |
	selectorOrAddress isInteger ifTrue:
		[self assert: (simulatedTrampolines includesKey: selectorOrAddress).
		 ^selectorOrAddress].
	self assert: selectorOrAddress isSymbol.
	address := self simulatedAddressFor: selectorOrAddress.
	simulatedTrampolines
		at: address
		ifAbsentPut:
			[MessageSend
				receiver: (self getReceiverForSelector: selectorOrAddress)
				selector: selectorOrAddress
				arguments: (1 to: selectorOrAddress numArgs) asArray].
	^address
]

{ #category : #'simulated variables' }
CogSimulatedAddresses >> simulatedVariableAccessor: getterSelector in: receiver [
	"Answer a simulated variable.  This is a variable whose value can be read
	 and written by generated machine code."

	<doNotGenerate>
	| address accessor |

	accessor := CogSimulatedVariable getterSelector: getterSelector in: receiver.

	address := self simulatedAddressFor: accessor.

	accessor address: address.

	^ simulatedVariables
		at: address
		ifAbsentPut: [accessor].

	
]

{ #category : #trampolines }
CogSimulatedAddresses >> trampolineAtAddress: anInteger [ 
	
	^ simulatedTrampolines at: anInteger
]

{ #category : #'simulated variables' }
CogSimulatedAddresses >> variableAtAddress: anInteger [ 
	
	^ simulatedVariables at: anInteger
]
