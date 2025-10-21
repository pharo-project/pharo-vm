Class {
	#name : 'VMTryPrimitivePrimitiveTest',
	#superclass : 'VMBasicPrimitiveTest',
	#instVars : [
		'tryPrimitiveMethod',
		'tryPrimitiveMirrorMethod',
		'externalCallMethod'
	],
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'running' }
VMTryPrimitivePrimitiveTest >> setUp [

	super setUp.
	
	interpreter initializePluginEntries.

	"Prototype of #tryPrimitive:withArgs: 
	callPrimitive: 118 #[ f8 76 00 ]"
	tryPrimitiveMethod := methodBuilder
		isPrimitive: true;
		numberOfArguments: 2;
		bytecodes: #[ 16rf8 16r76 16r00 ];
		buildMethod.
		
	"Prototype of #withReceiver:tryPrimitive:withArguments:
	callPrimitive: 118 #[ f8 76 00 ]"
	tryPrimitiveMirrorMethod := methodBuilder
		isPrimitive: true;
		numberOfArguments: 3;
		bytecodes: #[ 16rf8 16r76 16r00 ];
		buildMethod.
	
	"Prototype of #externalCall"
	externalCallMethod := methodBuilder
		isPrimitive: true;
		numberOfArguments: 1;
		literals: {(#( nil nil nil 19) forMemory: memory inMethod: nil)};
		buildMethod
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveMirrorTryPrimitiveWithReentrantFailure [
	" Call the primitive tryPrimitive reflectively, calling in turn out of bounds array access
	SomeObject withReceiver: ( 17 ) tryPrimitive: 118 withArgs: #( 60 #( 2 ) )
		=> 17"

	| arrayAccessPrimitiveArguments tryPrimitiveArguments receiver canary |
	canary := memory integerObjectOf: 16rAF3BAB3.
	interpreter push: canary.	

	"Push the receiver of the mirror primitive, which is not the receiver of the invoked primitive"
	interpreter push: memory nilObject.

	receiver := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: receiver withValue: (memory integerObjectOf: 17).
	
	interpreter push: receiver.
	interpreter push: (memory integerObjectOf: 118).
	
	arrayAccessPrimitiveArguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arrayAccessPrimitiveArguments withValue: (memory integerObjectOf: 2).
	
	tryPrimitiveArguments := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: tryPrimitiveArguments withValue: (memory integerObjectOf: 60).
	memory storePointer: 1 ofObject: tryPrimitiveArguments withValue: arrayAccessPrimitiveArguments.
	interpreter push: tryPrimitiveArguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMirrorMethod.
	interpreter argumentCount: 3.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	"This should fail and leave the stack untouched"
	self assert: interpreter failed.
	self assert: interpreter popStack equals: tryPrimitiveArguments.
	self assert: interpreter popStack equals: (memory integerObjectOf: 118).
	self assert: interpreter popStack equals: receiver.
	self assert: interpreter popStack equals: memory nilObject.
	self assert: interpreter popStack equals: canary
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveFailsAndLeaveTheStackUnchanged [
	" Call the primitive plus reflectively, failing because of wrong argument type
	17 tryPrimitive: 1 withArgs: #( Object new )
		=> Should activate the `tryPrimitive:withArgs:` method"

	| arguments canary |
	canary := memory integerObjectOf: 16rAF3BAB3.
	interpreter push: canary.
	
	interpreter push: (memory integerObjectOf: 17).
	interpreter push: (memory integerObjectOf: 1).
	
	arguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arguments withValue: (self newObjectWithSlots: 0).
	interpreter push: arguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	"This should fail and leave the stack untouched"
	self assert: interpreter failed.
	3 timesRepeat: [interpreter popStack].
	self assert: interpreter popStack equals: canary.

]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveFailsIfPrimitiveFails [
	" Call the primitive plus reflectively, failing because of wrong argument type
	17 tryPrimitive: 1 withArgs: #( Object new )
		=> Should activate the `tryPrimitive:withArgs:` method"

	| arguments |
	interpreter push: (memory integerObjectOf: 17).
	interpreter push: (memory integerObjectOf: 1).
	
	arguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arguments withValue: (self newObjectWithSlots: 0).
	interpreter push: arguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	"This should fail and leave the stack untouched"
	self assert: interpreter failed.
	self assert: interpreter popStack equals: arguments.
	self assert: interpreter popStack equals: (memory integerObjectOf: 1).
	self assert: interpreter popStack equals: (memory integerObjectOf: 17).
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveShouldInvokeAddition [
	" Call the primitive plus reflectively
	17 tryPrimitive: 1 withArgs: #( 42 )
		=> 59"

	| arguments |
	interpreter push: (memory integerObjectOf: 17).
	interpreter push: (memory integerObjectOf: 1).
	
	arguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arguments withValue: (memory integerObjectOf: 42).
	interpreter push: arguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	self deny: interpreter failed.
	self assert: interpreter popStack equals: ((memory integerObjectOf: 59))
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveShouldInvokeItself [
	" Call the primitive tryPrimitive reflectively, calling in turn the addition
	17 tryPrimitive: 118 withArgs: #( 1 #( 42 ) )
		=> 59"

	| additionPrimitiveArguments tryPrimitiveArguments |
	interpreter push: (memory integerObjectOf: 17).
	interpreter push: (memory integerObjectOf: 118).
	
	additionPrimitiveArguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: additionPrimitiveArguments withValue: (memory integerObjectOf: 42).
	
	tryPrimitiveArguments := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: tryPrimitiveArguments withValue: (memory integerObjectOf: 1).
	memory storePointer: 1 ofObject: tryPrimitiveArguments withValue: additionPrimitiveArguments.
	interpreter push: tryPrimitiveArguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	self deny: interpreter failed.
	self assert: interpreter popStack equals: ((memory integerObjectOf: 59))
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveWithArrayAccess [
	" Call the primitive tryPrimitive reflectively, calling in turn array access
	#( 17 ) tryPrimitive: 118 withArgs: #( 60 #( 1 ) )
		=> 17"

	| arrayAccessPrimitiveArguments tryPrimitiveArguments receiver |
	receiver := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: receiver withValue: (memory integerObjectOf: 17).
	
	interpreter push: receiver.
	interpreter push: (memory integerObjectOf: 118).
	
	arrayAccessPrimitiveArguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arrayAccessPrimitiveArguments withValue: (memory integerObjectOf: 1).
	
	tryPrimitiveArguments := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: tryPrimitiveArguments withValue: (memory integerObjectOf: 60).
	memory storePointer: 1 ofObject: tryPrimitiveArguments withValue: arrayAccessPrimitiveArguments.
	interpreter push: tryPrimitiveArguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	self deny: interpreter failed.
	self assert: interpreter popStack equals: ((memory integerObjectOf: 17))
]

{ #category : 'tests - primitiveTryPrimitive' }
VMTryPrimitivePrimitiveTest >> testPrimitiveTryPrimitiveWithReentrantFailure [
	" Call the primitive tryPrimitive reflectively, calling in turn out of bounds array access
	#( 17 ) tryPrimitive: 118 withArgs: #( 60 #( 2 ) )
		=> 17"

	| arrayAccessPrimitiveArguments tryPrimitiveArguments receiver canary |
	canary := memory integerObjectOf: 16rAF3BAB3.
	interpreter push: canary.	

	receiver := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: receiver withValue: (memory integerObjectOf: 17).
	
	interpreter push: receiver.
	interpreter push: (memory integerObjectOf: 118).
	
	arrayAccessPrimitiveArguments := self newArrayWithSlots: 1.
	memory storePointer: 0 ofObject: arrayAccessPrimitiveArguments withValue: (memory integerObjectOf: 2).
	
	tryPrimitiveArguments := self newArrayWithSlots: 2.
	memory storePointer: 0 ofObject: tryPrimitiveArguments withValue: (memory integerObjectOf: 60).
	memory storePointer: 1 ofObject: tryPrimitiveArguments withValue: arrayAccessPrimitiveArguments.
	interpreter push: tryPrimitiveArguments.
	
	"Simulate calling the method tryPrimitive:withArgs:"
	interpreter newMethod: tryPrimitiveMethod.
	interpreter argumentCount: 2.
	interpreter primitiveDoPrimitiveWithArgs. 
	
	"This should fail and leave the stack untouched"
	self assert: interpreter failed.
	self assert: interpreter popStack equals: tryPrimitiveArguments.
	self assert: interpreter popStack equals: (memory integerObjectOf: 118).
	self assert: interpreter popStack equals: receiver.
	self assert: interpreter popStack equals: canary
]
