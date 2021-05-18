Class {
	#name : #SpurLayout,
	#superclass : #Object,
	#instVars : [
		'object'
	],
	#category : #'VMMaker-Tools-ImageInspector'
}

{ #category : #'as yet unclassified' }
SpurLayout class >> layoutClassFromFormat: objFormat [
	(objFormat = 0)
		ifTrue: [ ^ SpurEmptyLayout ].
	(objFormat = 1)
		ifTrue: [ ^ SpurFixedLayout ].
	(objFormat = 2) 
		ifTrue: [ ^ SpurVariableLayout ].	
	(objFormat = 3)
		ifTrue: [ ^SpurVariableWithInstanceVariablesLayout ].
	(objFormat = 4)
		ifTrue: [ ^SpurVariableWithInstanceVariablesLayout ].
	(objFormat = 5)
		ifTrue: [ ^SpurVariableWithInstanceVariablesLayout ].	
			
	(objFormat = 7)
		ifTrue: [ ^SpurImmediateLayout].

	(objFormat < 24 and: [ objFormat > 8 ])
		ifTrue: [ ^ SpurByteLayout ].
	(objFormat < 32 and: [ objFormat > 23 ])
		ifTrue: [ ^ SpurCompiledMethodLayout ].
		
	^ self error: 'Unused or invalid format.'
	
]

{ #category : #'as yet unclassified' }
SpurLayout class >> on: aSpurObject image: aSpurImage [
	| layoutClass |
	"TH; Why passing the image here ?" 
	
	layoutClass := self layoutClassFromFormat: aSpurObject objectFormat.
	
	^ layoutClass new 
		object: aSpurObject.
]

{ #category : #accessing }
SpurLayout >> address [
	^ self object address
]

{ #category : #accessing }
SpurLayout >> at: anInteger [ 
	
	^ self slotAt: anInteger
]

{ #category : #accessing }
SpurLayout >> basicNumberOfSlots [
	^ self headerInteger >> (self headerSize * 8 "bits" - 8 "number of slots mask size")
]

{ #category : #accessing }
SpurLayout >> byteSize [
	^ self object byteSize .
]

{ #category : #'gt-inspector-extension' }
SpurLayout >> gtInspectorLayoutIn: composite [
	^composite text
		title: 'Spur view';
		display: [ [self object asString] on:Error do: [ 'Error printing' ]	]
]

{ #category : #accessing }
SpurLayout >> headerInteger [
	^ self object headerInteger 
]

{ #category : #accessing }
SpurLayout >> headerSize [
	^ self object headerSize
]

{ #category : #accessing }
SpurLayout >> image [
	^ self object image
]

{ #category : #testing }
SpurLayout >> isCompiledMethod [

	^ false
]

{ #category : #accessing }
SpurLayout >> memory [
	^ self object memory
]

{ #category : #accessing }
SpurLayout >> numberOfSlots [

	| slotsInHeader |
	slotsInHeader := self basicNumberOfSlots.
	slotsInHeader == 16rFF
		ifTrue: [ ^ self previousHeaderInteger ].
	^ slotsInHeader
]

{ #category : #accessing }
SpurLayout >> object [
	^ object
]

{ #category : #accessing }
SpurLayout >> object: anObject [
	object := anObject
]

{ #category : #printing }
SpurLayout >> objectPrintOn: aStream [
	aStream nextPutAll: 'a ', (self object basicClass asString)
]

{ #category : #accessing }
SpurLayout >> previousHeaderInteger [ 
	^ self object previousHeaderInteger
]

{ #category : #accessing }
SpurLayout >> slotAt: anInteger [

	^ self image objectForOop: (object fetchPointer: anInteger)
]

{ #category : #accessing }
SpurLayout >> wordSize [
	^ self object wordSize
]
