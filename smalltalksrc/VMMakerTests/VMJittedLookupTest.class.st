Class {
	#name : 'VMJittedLookupTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#instVars : [
		'methodOop',
		'selectorOop',
		'receiver',
		'receiverClass'
	],
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests' }
VMJittedLookupTest >> installSelector: aSelectorOop method: aMethodOop inMethodDictionary: aMethodDictionary [
	
	| anArrayOfMethods |
	anArrayOfMethods := memory fetchPointer: MethodArrayIndex ofObject: aMethodDictionary.
	memory
		storePointer: (memory methodDictionaryHash: aSelectorOop mask: 11) + 2
		ofObject: aMethodDictionary
		withValue: aSelectorOop.
	memory
		storePointer: (memory methodDictionaryHash: aSelectorOop mask: 11)
		ofObject: anArrayOfMethods
		withValue: aMethodOop
]

{ #category : 'tests' }
VMJittedLookupTest >> setArrayClassIntoClassTable [
	| aClass |
	aClass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: Array instSpec.
	memory setHashBitsOf: aClass to: ClassArrayCompactIndex.
	memory
		storePointer: ClassArrayCompactIndex
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : 'tests' }
VMJittedLookupTest >> setMessageClassIntoClassTable [
	| aClass |
	aClass := self
		newClassInOldSpaceWithSlots: MessageSend allSlots size 
		instSpec: MessageSend instSpec.
	memory setHashBitsOf: aClass to: ClassMessageCompactIndex.
	memory
		storePointer: ClassMessageCompactIndex
		ofObject: memory classTableFirstPage
		withValue: aClass
]

{ #category : 'tests' }
VMJittedLookupTest >> setUpClassAndMethod [


	methodOop := methodBuilder newMethod buildMethod.
	selectorOop := self
		newClassInOldSpaceWithSlots: 0
		instSpec: memory nonIndexablePointerFormat.
	receiver := memory integerObjectOf: 56.
	receiverClass := self setSmallIntegerClassIntoClassTable
]

{ #category : 'tests' }
VMJittedLookupTest >> setUpMethodDictionaryIn: aClass [
	"2 instances variables the array of methods and the tally
	and 12 entries to put elemetns of the collection"
	
	| aMethodDictionary anArrayOfMethods |
	aMethodDictionary := self
		newObjectWithSlots: 2 + 12
		format: MethodDictionary instSpec
		classIndex: memory arrayClassIndexPun.
	anArrayOfMethods := self
		newObjectWithSlots: 12
		format: Array instSpec
		classIndex: memory arrayClassIndexPun.
	memory
		storePointer: MethodDictionaryIndex
		ofObject: aClass
		withValue: aMethodDictionary.
	memory
		storePointer: MethodArrayIndex
		ofObject: aMethodDictionary
		withValue: anArrayOfMethods.
		
	

]

{ #category : 'tests' }
VMJittedLookupTest >> testLookUpMNUShouldJItCompile [

	| superclass superclassMethodDictionary foundMethod |
	
	self setUpTrampolines.
	cogit computeEntryOffsets.
	
	self setUpClassAndMethod.
	self setArrayClassIntoClassTable.
	self setMessageClassIntoClassTable.
	self setUpMethodDictionaryIn: receiverClass.
	
	superclass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: memory arrayFormat.
	self setUpMethodDictionaryIn: superclass.	
	superclassMethodDictionary := memory fetchPointer: MethodDictionaryIndex ofObject: superclass. 
	memory storePointer: SuperclassIndex ofObject: receiverClass  withValue: superclass.	
	
	self installSelector: selectorOop method: methodOop inMethodDictionary: superclassMethodDictionary.
	
	interpreter methodDictLinearSearchLimit: 3.
	interpreter setBreakSelector: nil.
	interpreter messageSelector: selectorOop.
	
	"Install the selector as a DNU selector"
	memory splObj: SelectorDoesNotUnderstand put: selectorOop.
	
	foundMethod := interpreter mnuMethodOrNilFor: receiver.
	self assert: foundMethod equals: methodOop
]

{ #category : 'tests' }
VMJittedLookupTest >> testLookUpMNUWithAnyNonMethodObjectShouldNotJItCompile [

	| superclass superclassMethodDictionary foundMethod |
	
	self setUpTrampolines.
	cogit computeEntryOffsets.
	
	self setUpClassAndMethod.
	self setArrayClassIntoClassTable.
	self setMessageClassIntoClassTable.
	self setUpMethodDictionaryIn: receiverClass.
	
	superclass := self
		newClassInOldSpaceWithSlots: 0
		instSpec: memory arrayFormat.
	self setUpMethodDictionaryIn: superclass.	
	superclassMethodDictionary := memory fetchPointer: MethodDictionaryIndex ofObject: superclass. 
	memory storePointer: SuperclassIndex ofObject: receiverClass  withValue: superclass.	
	
	self installSelector: selectorOop method: (memory integerValueOf: 37) inMethodDictionary: superclassMethodDictionary.
	
	interpreter methodDictLinearSearchLimit: 3.
	interpreter setBreakSelector: nil.
	interpreter messageSelector: selectorOop.
	
	"Install the selector as a DNU selector"
	memory splObj: SelectorDoesNotUnderstand put: selectorOop.
	
	foundMethod := interpreter mnuMethodOrNilFor: receiver.
	self assert: foundMethod isNil
]
