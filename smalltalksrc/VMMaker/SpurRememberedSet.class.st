Class {
	#name : #SpurRememberedSet,
	#superclass : #VMClass,
	#instVars : [
		'manager',
		'eden',
		'rememberedSetSize',
		'rememberedSetLimit',
		'rememberedSetArray',
		'rememberedSetRedZone',
		'numRememberedEphemerons',
		'previousRememberedSetSize'
	],
	#category : #VMMaker
}

{ #category : #'as yet unclassified' }
SpurRememberedSet class >> eden: newSpace [

	^ self new
		  eden: newSpace;
		  yourself
]

{ #category : #accessing }
SpurRememberedSet >> eden: anObject [

	eden := anObject
]

{ #category : #'remembered set' }
SpurRememberedSet >> growRememberedSet [
	| obj numSlots newObj base |
	<inline: false> "Don't ruin locality in remember:"
	<var: #base type: #'sqInt *'>
	obj := manager rememberedSetObj.
	numSlots := manager numSlotsOf: obj.
	self assert: numSlots >= 1024.
	newObj := manager allocatePinnedSlots: numSlots * 2.
	newObj ifNil:
		[newObj := manager allocatePinnedSlots: numSlots + 1024.
		 newObj ifNil:
			[(manager growOldSpaceByAtLeast: numSlots + 1024) ifNil: [self error: 'could not grow remembered set'].
			 newObj := manager allocatePinnedSlots: numSlots + 1024. "cannot fail"]].
	manager rememberedSetObj: newObj.
	base := manager firstIndexableField: newObj.
	0 to: rememberedSetSize - 1 do:
		[:i| base at: i put: (rememberedSetArray at: i)].
	"if growing in the middle of a GC, need to preserve marked status."
	(manager isMarked: obj) ifTrue:
		[manager
			setIsMarkedOf: newObj to: true;
			setIsMarkedOf: obj to: false].
	manager freeObject: obj.
	rememberedSetArray := base.
	rememberedSetLimit := manager numSlotsOf: newObj.
	self setRememberedSetRedZone
	
]

{ #category : #accessing }
SpurRememberedSet >> hasSameSize [

	^ previousRememberedSetSize = rememberedSetSize
]

{ #category : #initialization }
SpurRememberedSet >> initialize [

	rememberedSetSize := 0.
	numRememberedEphemerons := 0
]

{ #category : #initialization }
SpurRememberedSet >> initializeRememberedSet [
	| obj |
	obj := manager rememberedSetObj.
	obj = manager nilObject
		ifTrue:
			[obj := manager allocatePinnedSlots: 1024.
			 manager rememberedSetObj: obj]
		ifFalse: "The Spur32to64BitBootstrap failed to set the type of rememberedSetObj to 64-bit indexability.
				 This is unimportant except for simulation; rememberedSet is declared as sqInt *, but in to have
				 firstIndexableField: below answer a suitable type the format must be wordIndexableFormat."
			[manager setFormatOf: obj to: manager wordIndexableFormat].
	self assert: (manager formatOf: obj) = manager wordIndexableFormat.
	self assert: (manager isPinned: obj).
	rememberedSetArray := manager firstIndexableField: obj.
	rememberedSetSize := 0.
	rememberedSetLimit := manager numSlotsOf: obj.
	self setRememberedSetRedZone
]

{ #category : #accessing }
SpurRememberedSet >> isInRedZone [

	^ rememberedSetSize >= rememberedSetRedZone
]

{ #category : #'store check' }
SpurRememberedSet >> isInRememberedSet: objOop [
	0 to: rememberedSetSize - 1 do:
		[:i|
		(rememberedSetArray at: i) = objOop ifTrue:
			[^true]].
	^false
]

{ #category : #accessing }
SpurRememberedSet >> manager: anObject [

	manager := anObject
]

{ #category : #'debug support' }
SpurRememberedSet >> moveEphemeron: ephemeron destinationIndex: destIndex [

	rememberedSetArray
		at: destIndex put: (rememberedSetArray at: numRememberedEphemerons);
		at: numRememberedEphemerons put: ephemeron.

	numRememberedEphemerons := numRememberedEphemerons + 1
]

{ #category : #accessing }
SpurRememberedSet >> moveLastObjectTo: anIndex [

	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: rememberedSetSize - 1)
]

{ #category : #accessing }
SpurRememberedSet >> numRememberedEphemerons [
	^ numRememberedEphemerons
]

{ #category : #accessing }
SpurRememberedSet >> numRememberedEphemerons: anInteger [ 
	numRememberedEphemerons := anInteger
]

{ #category : #accessing }
SpurRememberedSet >> objectAt: anIndex [
	
	^ rememberedSetArray at: anIndex 
]

{ #category : #accessing }
SpurRememberedSet >> previousRememberedSetSize [
	^ previousRememberedSetSize
]

{ #category : #'remembered set' }
SpurRememberedSet >> relocateRememberedSet [

	"For SpurPlanningCompactor"
	rememberedSetArray := manager firstIndexableField: manager rememberedSetObj
]

{ #category : #'store check' }
SpurRememberedSet >> remember: objOop [
	"Add the argument to the remembered set and set its isRemembered bit to true.
	 Answer the argument for the benefit of the Cogit."
	<api>
	<inline: false>
	self assert: (manager isNonImmediate: objOop).
	self deny: (manager getMemoryMap isYoungObject: objOop).
	self deny: (manager isRemembered: objOop).
	self deny: (self isInRememberedSet: objOop).
	self deny: (manager getMemoryMap isPermanentObject: objOop).
	
	manager setIsRememberedOf: objOop to: true.
	rememberedSetSize >= rememberedSetLimit ifTrue:
		[self growRememberedSet].
	rememberedSetArray at: rememberedSetSize put: objOop.
	(rememberedSetSize := rememberedSetSize + 1) >= rememberedSetRedZone ifTrue:
		[manager scheduleScavenge].
	^objOop
]

{ #category : #accessing }
SpurRememberedSet >> rememberPreviousSize [

	previousRememberedSetSize := rememberedSetSize
]

{ #category : #accessing }
SpurRememberedSet >> rememberedSetLimit [
	<cmacro: '() GIV(rememberedSetLimit)'>
	^rememberedSetLimit
]

{ #category : #accessing }
SpurRememberedSet >> rememberedSetRedZone [
	^ rememberedSetRedZone
]

{ #category : #accessing }
SpurRememberedSet >> rememberedSetSize [
	<cmacro: '() GIV(rememberedSetSize)'>
	^rememberedSetSize
]

{ #category : #accessing }
SpurRememberedSet >> rememberedSetSize: aSize [

	rememberedSetSize := aSize
]

{ #category : #'debug support' }
SpurRememberedSet >> rememberedSetWithIndexDo: aBlock [

	self rememberedSetWithIndexDo: aBlock startingAt: 0
]

{ #category : #'debug support' }
SpurRememberedSet >> rememberedSetWithIndexDo: aBlock startingAt: startIndex [

	startIndex to: rememberedSetSize - 1 do: [ :i | 
	aBlock value: (rememberedSetArray at: i) value: i ]
]

{ #category : #accessing }
SpurRememberedSet >> removeByIndexUsingPreviousSize: anIndex [

	previousRememberedSetSize := previousRememberedSetSize - 1.
	rememberedSetSize := rememberedSetSize - 1.
	
	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: previousRememberedSetSize);
		at: previousRememberedSetSize
		put: (rememberedSetArray at: rememberedSetSize)
]

{ #category : #'debug support' }
SpurRememberedSet >> removeLastEphemeronAndKeepIn: index [

	numRememberedEphemerons := numRememberedEphemerons - 1.
	rememberedSetArray
		at: index
		put: (rememberedSetArray at: numRememberedEphemerons)
]

{ #category : #accessing }
SpurRememberedSet >> removeLastEphemeronAndMoveTo: index [

	self removeLastEphemeronAndKeepIn: index.

	self removeByIndexUsingPreviousSize: numRememberedEphemerons.
]

{ #category : #accessing }
SpurRememberedSet >> removeLastEphemeronTo: index andSave: anOop [

	self removeLastEphemeronAndKeepIn: index.

	self save: anOop at: numRememberedEphemerons
]

{ #category : #accessing }
SpurRememberedSet >> removeLastObject [

	rememberedSetSize := rememberedSetSize - 1
]

{ #category : #accessing }
SpurRememberedSet >> removeObjectAt: anIndex [

	rememberedSetSize := rememberedSetSize - 1.
	
	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: rememberedSetSize)
]

{ #category : #accessing }
SpurRememberedSet >> save: anOop at: index [

	rememberedSetArray at: index put: anOop
]

{ #category : #'remembered set' }
SpurRememberedSet >> setRememberedSetRedZone [
	| fudge |
	<inline: true>
	"fudge is a minimum below which we don't care about growing the Remembered Set.
	 It is chosen so that with a default 4Mb new space, the Remembered Set is not considered
	 full until it has from 512 to 1024 entries."
	fudge := eden limit - eden start / manager wordSize // 1024.
	rememberedSetRedZone := rememberedSetLimit * 3 // 4 max: fudge
]

{ #category : #scavenger }
SpurRememberedSet >> startingLoop [

	numRememberedEphemerons := 0.
	previousRememberedSetSize := 0
]
