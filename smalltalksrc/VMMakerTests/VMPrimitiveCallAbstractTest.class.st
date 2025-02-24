Class {
	#name : 'VMPrimitiveCallAbstractTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#instVars : [
		'baseMethodIP',
		'baseFrame',
		'baseMethod'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'helpers' }
VMPrimitiveCallAbstractTest >> callCogMethod: callingMethod receiver: receiver arguments: arguments returnAddress: returnAddress [

	machineSimulator receiverRegisterValue: receiver.
	self pushAddress: receiver.
	
	arguments do: [ :e | self pushAddress: e ].

	arguments size = 1 
		ifTrue: [ machineSimulator arg0RegisterValue: (arguments at: 1) ].

	arguments size = 2 
		ifTrue: [
			machineSimulator arg0RegisterValue: (arguments at: 1).
			machineSimulator arg1RegisterValue: (arguments at: 2). ].
	
	self prepareCall.
	machineSimulator instructionPointerRegisterValue: callingMethod address + cogit noCheckEntryOffset. 

	self runFrom: callingMethod address + cogit noCheckEntryOffset until: returnAddress.

]

{ #category : 'helpers' }
VMPrimitiveCallAbstractTest >> findMethod: aSelector [

	^ self class lookupSelector: aSelector
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> jitCompilerClass [

	^ StackToRegisterMappingCogit 
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> jitOptions [

	^ super jitOptions
		  at: #IMMUTABILITY put: true;
		  yourself
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodReturningNil [

	^ nil
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodSendingCharacterArgument [

	"This method is used to test sends.
	This send can be unlinked, linked to a method, or to a PIC"
	^ self methodWithSend: $7
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodSendingLiteralVariableArgument [

	"This method is used to test sends.
	This send can be unlinked, linked to a method, or to a PIC"
	^ self methodWithSend: Object
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodSendingNilArgument [

	"This method is used to test sends.
	This send can be unlinked, linked to a method, or to a PIC"
	^ self methodWithSend: nil
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodThatCallNamedPrimitive: anArg [

	"This method is used to test the invocation of a primitive.
	The primitive to invoke is later changed in the primitive table of the interpreter used in the test"
	<primitive: 'primitiveThatDoNothingWithOneArgument'>
	
	^ 84
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodThatCallNamedPrimitiveCounting: anArg [

	"This method is used to test the invocation of a primitive.
	The primitive to invoke is later changed in the primitive table of the interpreter used in the test"
	<primitive: 'primitiveFailCounting'>
	
	^ 84
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodThatCallPrimitive159 [

	<primitive: 159>

	^ 42 
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodThatCallPrimitive173: anArg [

	"This method is used to test the invocation of a primitive.
	The primitive to invoke is later changed in the primitive table of the interpreter used in the test"
	<primitive: 173>
	
	^ 42
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodThatCallPrimitive1: anArg [

	"This method is used to test the invocation of a primitive.
	The primitive to invoke is later changed in the primitive table of the interpreter used in the test"
	<primitive: 1>
	
	^ 42
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodToCompile1 [

	^ 42
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodWithSend [

	"This method is used to test sends.
	This send can be unlinked, linked to a method, or to a PIC"
	^ self send
]

{ #category : 'methods under test' }
VMPrimitiveCallAbstractTest >> methodWithSend: arg [

	"This method is used to test sends.
	This send can be unlinked, linked to a method, or to a PIC"
	^ arg send
]

{ #category : 'running' }
VMPrimitiveCallAbstractTest >> setUp [

	| primitiveAccessorDepthTable |
	
	super setUp.
	
	self setUpCogMethodEntry.
	cogit generateClosedPICPrototype.
	cogit methodZone manageFrom: cogit methodZoneBase to: cogit methodZone effectiveLimit.

	"Initializing the accessor depth table with a value for the first primitive"
	primitiveAccessorDepthTable := Array new: interpreter primitiveTable size.
	
	1 to: interpreter primitiveTable size 
		do: [ :i | primitiveAccessorDepthTable at: i put: -1 ].	 

	interpreter primitiveAccessorDepthTable: primitiveAccessorDepthTable.
	
	cogit 	lastNInstructions: OrderedCollection new.
	
	cogit guardPageSize: cogit class guardPageSize.

]

{ #category : 'running' }
VMPrimitiveCallAbstractTest >> setUpTrampolines [

	super setUpTrampolines.
	
	cogit methodAbortTrampolines at: 0 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 1 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 2 put: cogit ceMethodAbortTrampoline.
	cogit methodAbortTrampolines at: 3 put: cogit ceMethodAbortTrampoline.
	
	cogit picMissTrampolines at: 0 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 1 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 2 put: cogit ceCPICMissTrampoline.
	cogit picMissTrampolines at: 3 put: cogit ceCPICMissTrampoline.

	cogit picAbortTrampolines at: 0 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 1 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 2 put: cogit cePICAbortTrampoline.
	cogit picAbortTrampolines at: 3 put: cogit cePICAbortTrampoline.
	
	cogit ceStoreCheckTrampoline: (self compileTrampoline: [ cogit RetN: 0 ] named:#ceStoreCheckTrampoline).
	cogit objectRepresentation setAllStoreTrampolinesWith: (self compileTrampoline: [ cogit RetN: 0 ] named: #ceStoreTrampoline).
]
