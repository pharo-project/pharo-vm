"
A reified view of a `oop` (an integer address) for a `memory` manager.

This class is used for debuging and vizualisation to handle oops as first object-oriented programing citizens when coding visual inspectors.
They obviously *should not* be used for implementing runtime behavior.

VMOops are also indented to be robust and capable of dealing with corrupted things (because we rarely debug uncorrupted memory), or during low-level operations (durring GC for instance).
"
Class {
	#name : 'VMOop',
	#superclass : 'Object',
	#instVars : [
		'oop',
		'memory'
	],
	#category : 'VMMaker-Tools',
	#package : 'VMMaker-Tools'
}

{ #category : 'object access' }
VMOop >> bytes [

	self ifBroken: [ ^ nil ].
	^ memory bytesInObject: oop
]

{ #category : 'object access' }
VMOop >> classIndex [

	self ifBroken: [ ^ nil ].
	^ memory classIndexOf: oop
]

{ #category : 'printing' }
VMOop >> flags [

	self ifBroken: [ ^ 'broken' ].
	^ ((memory isGrey: oop) ifTrue: ['g'] ifFalse: ['.']),
			 ((memory isImmutable: oop) ifTrue: ['i'] ifFalse: ['.']),
			 ((memory isMarked: oop) ifTrue: ['m'] ifFalse: ['.']),
			 ((memory isPinned: oop) ifTrue: ['p'] ifFalse: ['.']),
			 ((memory isRemembered: oop) ifTrue: ['r'] ifFalse: ['.'])
]

{ #category : 'printing' }
VMOop >> format [

	self ifBroken: [ ^ 'broken' ].
	^ ((memory formatOf: oop) <= 16rF ifTrue: ['0'] ifFalse: ['']),
	  (memory formatOf: oop) printStringHex, ' ',
	  (memory formatStringOf: oop)

]

{ #category : 'testing' }
VMOop >> ifBroken: aBlock [

	^ self isBroken ifTrue: aBlock.
]

{ #category : 'testing' }
VMOop >> isBroken [

	oop ifNil: [ ^true ].
	^ (memory memoryManager isValidAddress: oop) not.
]

{ #category : 'printing' }
VMOop >> label [

	self ifBroken: [ ^ 'broken' ].
	^ memory labelOfOop: oop
]

{ #category : 'accessing' }
VMOop >> memory [

	^ memory
]

{ #category : 'accessing' }
VMOop >> memory: anObject [

	memory := anObject
]

{ #category : 'object access' }
VMOop >> numSlots [

	self ifBroken: [ ^ nil ].
	^ memory numSlotsOfAny: oop
]

{ #category : 'accessing' }
VMOop >> oop [

	^ oop
]

{ #category : 'accessing' }
VMOop >> oop: anObject [

	oop := anObject
]

{ #category : 'object access' }
VMOop >> pointer: idx [

	^ memory asVMOop: (self rawPointer: idx)
]

{ #category : 'object access' }
VMOop >> pointers [

	"Return a collection of all pointed `VMOop` (in slots)"

	| n |
	
	n := self numSlots.
	n ifNil: [ ^ #() ].
	^ (1 to: n) collect: [ :i | self pointer: i-1 ].
]

{ #category : 'printing' }
VMOop >> printOn: aStream [

	^ aStream print: oop
]

{ #category : 'object access' }
VMOop >> rawNumSlots [

	self ifBroken: [ ^ nil ].
	^ memory rawNumSlotsOf: oop
]

{ #category : 'object access' }
VMOop >> rawPointer: idx [

	"0 based pointer, as a classic integer oop"

	self ifBroken: [ ^ nil ].
	(memory isFreeObject: oop) ifTrue: [ ^ memory fetchPointer: idx ofFreeChunk: oop ].
	(memory isSegmentBridge: oop) ifTrue: [ ^ nil ].
	((memory numSlotsOfAny: oop) > 0) ifTrue: [ ^ memory fetchPointer: idx ofMaybeForwardedObject: oop ].
	^ nil.

]

{ #category : 'printing' }
VMOop >> type [

	self ifBroken: [ ^ 'broken' ].
	(memory isFreeObject: oop) ifTrue: [ ^ 'free'].
	(memory isSegmentBridge: oop) ifTrue: [ ^ 'bridge'].
	(memory isForwarded: oop) ifTrue: [ ^ 'forwarder'].
	(memory classIndexOf: oop) <= memory lastClassIndexPun ifTrue: [ ^ 'pun/obj stack'].
	^ 'object'

]
