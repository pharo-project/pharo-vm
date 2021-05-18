"
""| version (4 bytes) | headerSize (4 bytes) | datasize (4 bytes) | old base address  (4 bytes) | special objects oop (4 bytes) | = 20 bytes
 | last hash (4 bytes)| saved window size (4 bytes) | headerFlags (4 bytes) | extraVMMemory (4bytes) | stack pages (2 bytes)   | = 18 bytes
 | native method zone size (2 bytes) | eden size (4 bytes) | semaphore table max size (2 bytes) | the2ndUnknownShort (2 bytes) | = 10 bytes
 | first segment size (4 bytes) | free old space (4 bytes) | = 8 bytes
 | The rest 8 bytes are empty""

(spur specialObjectsArray slotAt: 1) address = spur firstObject address.
"
Class {
	#name : #SpurImage,
	#superclass : #Object,
	#instVars : [
		'hiddenRoots',
		'classTable',
		'simulator'
	],
	#category : #'VMMaker-Tools-ImageInspector'
}

{ #category : #constants }
SpurImage >> arrayClassIndexPun [
	^ 16
]

{ #category : #constants }
SpurImage >> arrayFormat [
	^ 2
]

{ #category : #constants }
SpurImage >> classIndexFieldWidth [
	"22-bit class mask => ~ 4M classes"
	^22
]

{ #category : #accessing }
SpurImage >> classTable [

	^ classTable
]

{ #category : #accessing }
SpurImage >> classTable: anObject [

	classTable := anObject
]

{ #category : #constants }
SpurImage >> classTableMajorIndexShift [
	"1024 entries per page (2^10); 22 bit classIndex implies 2^12 pages"
	^10
]

{ #category : #constants }
SpurImage >> classTableMinorIndexMask [
	"1024 entries per page (2^10); 22 bit classIndex implies 2^12 pages"
	"self basicNew classTableMinorIndexMask"
	^1 << self classTableMajorIndexShift - 1
]

{ #category : #constants }
SpurImage >> classTablePageSize [

	^1 << self classTableMajorIndexShift
]

{ #category : #constants }
SpurImage >> classTableRootSlots [
	"Answer the number of slots for class table pages in the hidden root object."
	^1 << (self classIndexFieldWidth - self classTableMajorIndexShift)
]

{ #category : #'special-objects' }
SpurImage >> falseObject [
	^ self nilObject nextObject
]

{ #category : #'special-objects' }
SpurImage >> freeListObj [

	^ self trueObject 	nextObject
]

{ #category : #'as yet unclassified' }
SpurImage >> hiddenRoots: anInteger [ 
	hiddenRoots := anInteger
]

{ #category : #'special-objects' }
SpurImage >> hiddenRootsObj [

	hiddenRoots ifNil: [ 
		hiddenRoots := self freeListObj nextObject address ].
	^ SpurHiddenRoots on: hiddenRoots image: self
]

{ #category : #'as yet unclassified' }
SpurImage >> imageFormat: anInteger [ 
	self shouldBeImplemented.
]

{ #category : #'special-objects' }
SpurImage >> nextObjectOf: anOop [
	^ self subclassResponsibility
]

{ #category : #'special-objects' }
SpurImage >> nilObject [
	^ self subclassResponsibility 
]

{ #category : #'as yet unclassified' }
SpurImage >> simulator [
	^ simulator
]

{ #category : #'as yet unclassified' }
SpurImage >> simulator: aSpur64BitMMLESimulator [ 
	simulator := aSpur64BitMMLESimulator
]

{ #category : #'special-objects' }
SpurImage >> trueObject [
	^ self falseObject nextObject
]

{ #category : #'special-objects' }
SpurImage >> wordsize [
	^ self subclassResponsibility
]
