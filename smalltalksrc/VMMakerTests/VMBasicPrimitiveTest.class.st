Class {
	#name : 'VMBasicPrimitiveTest',
	#superclass : 'VMInterpreterTests',
	#category : 'VMMakerTests-InterpreterTests',
	#package : 'VMMakerTests',
	#tag : 'InterpreterTests'
}

{ #category : 'asserting' }
VMBasicPrimitiveTest >> assert: anOop contentEquals: oopToCompare [ 

	| numSlotOop numSlotOopToCompare |
	numSlotOop := memory numSlotsOf: anOop.
	numSlotOopToCompare := (memory numSlotsOf: anOop).
	self assert:  numSlotOop equals: numSlotOopToCompare.
	
	0 to: numSlotOop do: [:index | 
	self assert: (memory fetchByte: index ofObject: anOop) equals: (memory fetchByte: index ofObject:oopToCompare)		
		]	
	
]

{ #category : 'as yet unclassified' }
VMBasicPrimitiveTest >> fillNewSpace [

	"Allocate enough space to generate a full new space"

	self assert: (memory
			 allocateSlots: (memory scavengeThreshold - memory freeStart
				  - (2 * memory baseHeaderSize) roundDownTo: 8) // self wordSize
			 format: memory arrayFormat
			 classIndex: memory arrayClassIndexPun) isNotNil
]

{ #category : 'instance creation' }
VMBasicPrimitiveTest >> newArrayWith: aCollection [ 
	| array |
	array := self newObjectWithSlots: aCollection size format: memory arrayFormat classIndex: memory arrayClassIndexPun.
	aCollection withIndexDo: [ :item :index | 
		memory storePointer: index - 1 ofObject: array withValue: item	
	].
	^ array
	
]

{ #category : 'running' }
VMBasicPrimitiveTest >> setUp [
	"taken from VMSimpleStackBasedCogitBytecodeTest >> #setup"

	| newMethod ctx page |
	super setUp.

	"Create the root context with a valid method"
	"Let's create a method with enough size. It should have at least a literal (4 or 8 bytes depending the word size) and some bytecodes, so we can put the IP inside the method"
	newMethod := methodBuilder newMethod buildMethod.

	"The context has 5 (in 32 bits) or 9 (in 64 bits) as initial IP, as method has at least one literal"
	ctx := self
		       newSmallContextReceiver: memory nilObject
		       method: newMethod
		       arguments: #(  )
		       temporaries: #(  )
		       ip: self wordSize + 1.

	page := interpreter makeBaseFrameFor: ctx.
	interpreter setStackPointersFromPage: page.
	interpreter setStackPageAndLimit: page
]

{ #category : 'tests - primitiveIdentical' }
VMBasicPrimitiveTest >> setUpForwardedObjects [
	| class1 class2 object1 object2 array1 array2 |
	
	class1 := self newClassInOldSpaceWithSlots: 1 instSpec: memory nonIndexablePointerFormat.
	class2 := self newClassInOldSpaceWithSlots: 2 instSpec: memory nonIndexablePointerFormat.
	
	object1 := memory instantiateClass: class1.
	object2 := memory instantiateClass: class2.
	
	array1 := self newArrayWith: { object1 }.
	array2 := self newArrayWith: { object2 }.
	
	interpreter push: array1.
	interpreter push: array2. 
	
	interpreter primitiveArrayBecome.
	
	self assert: (memory isForwarded: object1) equals: true.
	self assert: (memory isForwarded: object2) equals: true.
	
	^ object1. 
]
