Class {
	#name : #VMRememberedSet,
	#superclass : #VMStructType,
	#instVars : [
		'manager',
		'fudge',
		'rootIndex',
		'rememberedSetSize',
		'rememberedSetLimit',
		'rememberedSetArray',
		'rememberedSetRedZone',
		'numRememberedEphemerons',
		'previousRememberedSetSize',
		'doFullScan'
	],
	#category : #VMMaker
}

{ #category : #translation }
VMRememberedSet class >> filteredInstVarNames [

	^ super filteredInstVarNames copyWithoutAll: #(manager)
]

{ #category : #translation }
VMRememberedSet class >> generateHeader: aBinaryBlock [

	aBinaryBlock
		value: 'vmRememberedSet.h'
		value: (String streamContents: [ :s | 
				 self printTypedefOn: s.
				 s cr ])
]

{ #category : #translation }
VMRememberedSet class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [

	self filteredInstVarNames do: [ :aName |
		aBinaryBlock value: aName value: (aName caseOf: {
						['rememberedSetArray']		-> [#'sqInt *'].
				} otherwise: [ #sqLong ]) ].

]

{ #category : #translation }
VMRememberedSet class >> needsTypeTag [

	^true
]

{ #category : #translation }
VMRememberedSet class >> shouldBeGenerated [

	^ false
]

{ #category : #initialization }
VMRememberedSet >> countNotNilObjects [

	<inline: false>

	| count |
	count := 0.

	0 to: self rememberedSetLimit do: [ :i | 
		"The remembered set might be initialized with 0"
		((self objectAt: i) = manager nilObject or: [ (self objectAt: i) = 0 ]) ifTrue: [ ^ i ].
		count := i ].

	^ count
]

{ #category : #accessing }
VMRememberedSet >> doFullScan [

	^ doFullScan
]

{ #category : #accessing }
VMRememberedSet >> doFullScan: aValue [	

	doFullScan := aValue
]

{ #category : #initialization }
VMRememberedSet >> emptyRememberedSet [

	| oldObj |
	
	oldObj := self objectOop.
	oldObj = manager nilObject
		ifFalse: [ 
			manager rememberedSet: rootIndex oop: manager nilObject.
			manager freeObject: oldObj ].
		
	self initializeRememberedSetShouldStartEmpty: true. 

]

{ #category : #'store check' }
VMRememberedSet >> forgetObject: objOop [

	self assert: rememberedSetSize > 0.
	self assert: (manager isRemembered: objOop).
	manager setIsRememberedOf: objOop to: false.
	objOop = (rememberedSetArray at: rememberedSetSize - 1) ifFalse:
		[| index |
		 index := 0.
		 [index < rememberedSetSize] whileTrue:
			[objOop = (rememberedSetArray at: index)
				ifTrue:
					[rememberedSetArray at: index put: (rememberedSetArray at: rememberedSetSize - 1).
					 index := rememberedSetSize]
				ifFalse: [index := index + 1]]].
				
	self setRememberedSetSize: rememberedSetSize - 1.

	self assert: rememberedSetSize >= 0
]

{ #category : #accessing }
VMRememberedSet >> fudge [

	^ fudge
]

{ #category : #accessing }
VMRememberedSet >> fudge: anObject [

	fudge := anObject
]

{ #category : #'remembered set' }
VMRememberedSet >> growRememberedSet [
	| obj numSlots newObj base |

	<inline: false> "Don't ruin locality in remember:"
	<var: #base type: #'sqInt *'>


	obj := self objectOop.
	numSlots := manager numSlotsOf: obj.
	self assert: numSlots >= 1024.
	newObj := manager allocatePinnedSlots: numSlots * 2.
	newObj ifNil:
		[newObj := manager allocatePinnedSlots: numSlots + 1024.
		 newObj ifNil:
			[(manager growOldSpaceByAtLeast: (numSlots + 1024) * manager wordSize) ifNil: [self error: 'could not grow remembered set'].
			 newObj := manager allocatePinnedSlots: numSlots + 1024. "cannot fail"]].

	manager rememberedSet: rootIndex oop: newObj.
	base := self rememberedSetArrayPointerFromObject: newObj.

	0 to: rememberedSetSize - 1 do:
		[:i| base at: i put: (self rememberedSetArray at: i)].
	"if growing in the middle of a GC, need to preserve marked status."
	(manager isMarked: obj) ifTrue:
		[manager
			setIsMarkedOf: newObj to: true;
			setIsMarkedOf: obj to: false].
	manager freeObject: obj.
	self rememberedSetArray: base.
	self rememberedSetLimit: (manager numSlotsOf: newObj).
	self setRememberedSetRedZone
	
]

{ #category : #initialization }
VMRememberedSet >> initialize [

	rememberedSetSize := 0.
	numRememberedEphemerons := 0.
	fudge := 0.
	doFullScan := false
]

{ #category : #initialization }
VMRememberedSet >> initializeRememberedSetShouldStartEmpty: shouldStartEmpty [
	| obj |
	obj := self objectOop.
	
	(manager isInOldSpace: obj) 
		ifFalse: [ 
			manager logWarn: 'Remembered Set is in an invalid position %p. Signal of a corrupted root table.' _: obj.
			shouldStartEmpty 
				ifTrue: [ 
					obj := manager nilObject.
					manager logWarn: 'As it starts empty, we can ignore it' ]]. 
	
	obj = manager nilObject
		ifTrue:
			[obj := manager allocatePinnedSlots: 1024.
			 manager rememberedSet: rootIndex oop: obj]
		ifFalse: "The Spur32to64BitBootstrap failed to set the type of rememberedSetObj to 64-bit indexability.
				 This is unimportant except for simulation; rememberedSet is declared as sqInt *, but in to have
				 firstIndexableField: below answer a suitable type the format must be wordIndexableFormat."
			[manager setFormatOf: obj to: manager wordIndexableFormat].

	self assert: (manager formatOf: obj) = manager wordIndexableFormat.
	self assert: (manager isPinned: obj).
	self rememberedSetArray: (self rememberedSetArrayPointerFromObject: obj).

	self rememberedSetLimit: (manager numSlotsOf: obj).

	shouldStartEmpty 
		ifTrue: [rememberedSetSize := 0]
		ifFalse: [rememberedSetSize := self countNotNilObjects].
		
	self setRememberedSetRedZone
]

{ #category : #accessing }
VMRememberedSet >> isInRedZone [

	^ rememberedSetSize >= rememberedSetRedZone
]

{ #category : #'store check' }
VMRememberedSet >> isInRememberedSet: objOop [
	0 to: rememberedSetSize - 1 do:
		[:i|
		(rememberedSetArray at: i) = objOop ifTrue:
			[^true]].
	^false
]

{ #category : #accessing }
VMRememberedSet >> keepSameSize [

	^ previousRememberedSetSize = rememberedSetSize
]

{ #category : #accessing }
VMRememberedSet >> manager: anObject [
	<doNotGenerate>
	manager := anObject
]

{ #category : #accessing }
VMRememberedSet >> moveLastObjectTo: anIndex [

	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: rememberedSetSize - 1)
]

{ #category : #'debug support' }
VMRememberedSet >> moveNewEphemeron: ephemeron destinationIndex: destIndex [

	rememberedSetArray
		at: destIndex put: (rememberedSetArray at: numRememberedEphemerons);
		at: numRememberedEphemerons put: ephemeron.

	numRememberedEphemerons := numRememberedEphemerons + 1
]

{ #category : #accessing }
VMRememberedSet >> numRememberedEphemerons [
	^ numRememberedEphemerons
]

{ #category : #accessing }
VMRememberedSet >> numRememberedEphemerons: anInteger [ 
	numRememberedEphemerons := anInteger
]

{ #category : #accessing }
VMRememberedSet >> objectAt: anIndex [

	<inline: true>	
 	^ self rememberedSetArray at: anIndex 
]

{ #category : #accessing }
VMRememberedSet >> objectOop [

	^ manager objStackAt: rootIndex
]

{ #category : #accessing }
VMRememberedSet >> previousRememberedSetSize [
	^ previousRememberedSetSize
]

{ #category : #'remembered set' }
VMRememberedSet >> referenceCountRememberedReferents: population maxRefCount: maxRefCount [
	"Both reference count young objects reachable from the RT,
	 and count the populations of each ref count, in a single pass."
	<var: 'population' declareC: 'long population[MaxRTRefCount + 1]'>
	<inline: true>

	0 to: rememberedSetSize - 1 do:
		[:i| | elephant |
		elephant := rememberedSetArray at: i.
		(manager isForwarded: elephant) ifTrue:
			[elephant := manager followForwarded: elephant.
			 (manager isImmediate: elephant) ifTrue: "take care if elephant forwarded to an immediate"
				[elephant := manager nilObject]].
		0 to: (manager numPointerSlotsOf: elephant) - 1 do:
			[:j| | referent refCount |
			referent := manager fetchPointer: j ofObject: elephant.
			(manager isReallyYoung: referent) ifTrue:
				[refCount := manager rtRefCountOf: referent.
				 refCount < maxRefCount ifTrue:
					[refCount > 0 ifTrue:
						[population at: refCount put: (population at: refCount) - 1].
					 refCount := refCount + 1.
					 manager rtRefCountOf: referent put: refCount.
					 population at: refCount put: (population at: refCount) + 1]]]].
]

{ #category : #'remembered set' }
VMRememberedSet >> relocateRememberedSet [

	"For SpurPlanningCompactor"
	self rememberedSetArray: (self rememberedSetArrayPointerFromObject: self objectOop)
]

{ #category : #'store check' }
VMRememberedSet >> remember: objOop [
	"Add the argument to the remembered set and set its isRemembered bit to true.
	 Answer the argument for the benefit of the Cogit."
	<api>
	<inline: false>
	self deny: (self isInRememberedSet: objOop).
	
	manager setIsRememberedOf: objOop to: true.

	^ self rememberWithoutMarkingAsRemembered: objOop
]

{ #category : #accessing }
VMRememberedSet >> rememberPreviousSize [

	previousRememberedSetSize := rememberedSetSize
]

{ #category : #'store check' }
VMRememberedSet >> rememberWithoutMarkingAsRemembered: objOop [

	<api>
	<inline: false>

	self assert: (manager isNonImmediate: objOop).
	self deny: (manager getMemoryMap isYoungObject: objOop).

	rememberedSetSize >= rememberedSetLimit ifTrue:
		[self growRememberedSet.
		 doFullScan 
			ifFalse: [ manager scheduleScavenge ]].

	rememberedSetArray at: rememberedSetSize put: objOop.
	self setRememberedSetSize: rememberedSetSize + 1.

	^objOop
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetArray [

	^ rememberedSetArray
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetArray: anObject [

	rememberedSetArray := anObject
]

{ #category : #initialization }
VMRememberedSet >> rememberedSetArrayPointerFromObject: anOop [ 
	
	^ manager cCoerce: (manager firstIndexableField: anOop) to: 'usqInt *'
	
	
	
	
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetLimit [

	^rememberedSetLimit
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetLimit: anObject [

	rememberedSetLimit := anObject
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetRedZone [
	^ rememberedSetRedZone
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetRedZone: anInteger [

	rememberedSetRedZone := anInteger
]

{ #category : #accessing }
VMRememberedSet >> rememberedSetSize [

	^rememberedSetSize
]

{ #category : #'debug support' }
VMRememberedSet >> rememberedSetWithIndexDo: aBlock [

	self rememberedSetWithIndexDo: aBlock startingAt: 0
]

{ #category : #'debug support' }
VMRememberedSet >> rememberedSetWithIndexDo: aBlock startingAt: startIndex [

	startIndex to: rememberedSetSize - 1 do: [ :i | 
	aBlock value: (rememberedSetArray at: i) value: i ]
]

{ #category : #accessing }
VMRememberedSet >> removeByIndexUsingPreviousSize: anIndex [

	| newRememberedSetSize |

	previousRememberedSetSize := previousRememberedSetSize - 1.
	newRememberedSetSize := rememberedSetSize - 1.
	
	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: previousRememberedSetSize);
		at: previousRememberedSetSize
		put: (rememberedSetArray at: newRememberedSetSize).
		
	self setRememberedSetSize: newRememberedSetSize.
]

{ #category : #'debug support' }
VMRememberedSet >> removeLastEphemeronAndKeepIn: index [

	numRememberedEphemerons := numRememberedEphemerons - 1.
	rememberedSetArray
		at: index
		put: (rememberedSetArray at: numRememberedEphemerons)
]

{ #category : #accessing }
VMRememberedSet >> removeLastEphemeronAndMoveTo: index [

	self removeLastEphemeronAndKeepIn: index.

	self removeByIndexUsingPreviousSize: numRememberedEphemerons.
]

{ #category : #accessing }
VMRememberedSet >> removeLastEphemeronTo: index andSave: anOop [

	self removeLastEphemeronAndKeepIn: index.

	self save: anOop at: numRememberedEphemerons
]

{ #category : #accessing }
VMRememberedSet >> removeLastObject [

	self setRememberedSetSize: rememberedSetSize - 1
]

{ #category : #accessing }
VMRememberedSet >> removeObjectAt: anIndex [

	| newRememberedSetSize |
	newRememberedSetSize := rememberedSetSize - 1.
	
	rememberedSetArray
		at: anIndex put: (rememberedSetArray at: newRememberedSetSize).
		
	self setRememberedSetSize: newRememberedSetSize.
]

{ #category : #accessing }
VMRememberedSet >> replace: oldOop with: newOop [

	self rememberedSetWithIndexDo: [ :oop :index | 
		oop = oldOop ifTrue: [ 
			manager setIsRememberedOf: oldOop to: false.
			manager setIsRememberedOf: newOop to: true.
			^ self save: newOop at: index ] ]
]

{ #category : #accessing }
VMRememberedSet >> rootIndex [

	^ rootIndex
]

{ #category : #accessing }
VMRememberedSet >> rootIndex: anIndex [

	rootIndex := anIndex
]

{ #category : #accessing }
VMRememberedSet >> save: anOop at: index [

	rememberedSetArray at: index put: anOop
]

{ #category : #'remembered set' }
VMRememberedSet >> setRememberedSetRedZone [

	<inline: true>
	self rememberedSetRedZone: ((self rememberedSetLimit - 4) max: self fudge)
]

{ #category : #initialization }
VMRememberedSet >> setRememberedSetSize: aNewValue [

	"We want to guarantee that the first free position is a with 0"
	rememberedSetSize := aNewValue.
	aNewValue < rememberedSetLimit ifTrue: [ rememberedSetArray at: aNewValue put: 0 ].

]

{ #category : #'remembered set' }
VMRememberedSet >> shrinkRememberedSet [
	| obj numSlots newObj base |

	<inline: false>
	<var: #base type: #'sqInt *'>

	rememberedSetLimit >= 2048 ifFalse: [ ^ self ].
	rememberedSetSize < (self rememberedSetLimit // 2) 
		ifFalse: [ ^ self ].

	obj := self objectOop.
	numSlots := ((manager numSlotsOf: obj) // 2) max: 2048.

	newObj := manager allocatePinnedSlots: numSlots.
	newObj ifNil:
		[newObj := manager allocatePinnedSlots: numSlots.
		 newObj ifNil:
			[(manager growOldSpaceByAtLeast: numSlots * manager wordSize) ifNil: [self error: 'could not shrink remembered set'].
			 newObj := manager allocatePinnedSlots: numSlots. "cannot fail"]].

	manager rememberedSet: rootIndex oop: newObj.
	base := self rememberedSetArrayPointerFromObject: newObj.

	0 to: rememberedSetSize - 1 do:
		[:i| base at: i put: (self rememberedSetArray at: i)].
	"if growing in the middle of a GC, need to preserve marked status."
	(manager isMarked: obj) ifTrue:
		[manager
			setIsMarkedOf: newObj to: true;
			setIsMarkedOf: obj to: false].
	manager freeObject: obj.
	self rememberedSetArray: base.
	self rememberedSetLimit: (manager numSlotsOf: newObj).
	self setRememberedSetRedZone
	
]

{ #category : #scavenger }
VMRememberedSet >> startingLoop [

	numRememberedEphemerons := 0.
	previousRememberedSetSize := 0
]
