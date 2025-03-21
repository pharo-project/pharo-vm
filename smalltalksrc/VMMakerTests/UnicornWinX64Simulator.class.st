Class {
	#name : 'UnicornWinX64Simulator',
	#superclass : 'UnicornX64Simulator',
	#category : 'VMMakerTests-Unicorn',
	#package : 'VMMakerTests',
	#tag : 'Unicorn'
}

{ #category : 'as yet unclassified' }
UnicornWinX64Simulator class >> supportISA: isa andAbi: abi [ 
	
	^ isa = #X64 and: [ abi = #'_WIN64' ]
]

{ #category : 'registers' }
UnicornWinX64Simulator >> carg0Register [
	
	^ UcX86Registers rcx
]

{ #category : 'registers' }
UnicornWinX64Simulator >> carg1Register [ 
	
	^ UcX86Registers rdx
]

{ #category : 'registers' }
UnicornWinX64Simulator >> carg2Register [
	
	^ UcX86Registers r8
]

{ #category : 'registers' }
UnicornWinX64Simulator >> carg3Register [
	
	^ UcX86Registers r9
]

{ #category : 'as yet unclassified' }
UnicornWinX64Simulator >> fetchArgumentsOfTypes: argumentTypes [

	| byteArray |

	^ argumentTypes withIndexCollect: [ :type :index | 
		index <= 4 ifTrue: [  
			byteArray := type isFloatType 
				ifTrue: [ self doublePrecisionFloatingPointRegisterRaw: index  ]
				ifFalse: [ self cArgRegisterRaw: index ]]
		ifFalse: [  
			index = 6 ifTrue: [ self halt ].
			"The fifth argument is in the 6th position, we have the return address, and the FP"
			byteArray := self stackValueBytesAt: 6.
		].
		type marshallToSmalltalkFromByteArray: byteArray
	]
]

{ #category : 'virtual-registers' }
UnicornWinX64Simulator >> receiverRegister [
	
	^ UcX86Registers r9
]

{ #category : 'virtual-registers' }
UnicornWinX64Simulator >> sendNumberOfArgumentsRegister [
	
	^ UcX86Registers r10
]
