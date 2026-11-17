"
I hold the statistics gathered by a SpurMemoryManager (number of GCs, time spent in each GC phase, memory growth and shrinkage, allocated bytes, ...).

The memory manager keeps me in its statistics instance variable. In the generated C code I am an ancillary class, my instance variables become globals and sends to statistics become plain function calls.
"
Class {
	#name : 'SpurMemoryManagerStats',
	#superclass : 'VMClass',
	#instVars : [
		'statCoalesces',
		'statCompactPassCount',
		'statFGCDeltaUsecs',
		'statFullGCUsecs',
		'statCompactionUsecs',
		'statSweepUsecs',
		'statMarkUsecs',
		'statFullGCs',
		'statGCEndUsecs',
		'statGrowMemory',
		'statIGCDeltaUsecs',
		'statMarkCount',
		'statRootTableCount',
		'statRootTableOverflows',
		'statSGCDeltaUsecs',
		'statScavengeGCUsecs',
		'statScavenges',
		'statShrinkMemory',
		'statAllocatedBytes',
		'statMaxAllocSegmentTime'
	],
	#category : 'VMMaker-SpurMemoryManager',
	#package : 'VMMaker',
	#tag : 'SpurMemoryManager'
}

{ #category : 'translation' }
SpurMemoryManagerStats class >> declareCVarsIn: aCCodeGenerator [

	self
		declareCAsUSqLong:
			(self allInstVarNames select: [ :ivn | ivn endsWith: 'Usecs' ])
			, #( statAllocatedBytes )
		in: aCCodeGenerator
]

{ #category : 'translation' }
SpurMemoryManagerStats class >> implicitReturnTypeFor: aSelector [
	"Answer the return type for methods that don't have an explicit return."

	^ #void
]

{ #category : 'initialization' }
SpurMemoryManagerStats >> initialize [
	"In C all global variables are initialized to 0."

	statScavenges := statFullGCs := 0.
	statMaxAllocSegmentTime := 0.
	statMarkUsecs := statSweepUsecs := statScavengeGCUsecs := statFullGCUsecs := statCompactionUsecs := statGCEndUsecs := 0.
	statSGCDeltaUsecs := statIGCDeltaUsecs := statFGCDeltaUsecs := 0.
	statGrowMemory := statShrinkMemory := statRootTableCount := statAllocatedBytes := 0.
	statRootTableOverflows := statMarkCount := statCompactPassCount := statCoalesces := 0
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statAllocatedBytes [

	^ statAllocatedBytes
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statAllocatedBytes: aValue [

	<var: #aValue type: #usqLong>
	statAllocatedBytes := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCoalesces [

	^ statCoalesces
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCoalesces: aValue [

	statCoalesces := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompMoveCount [
	"Spur never compacts by moving; but it does make compaction passes."

	^ statCompactPassCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactPassCount [

	^ statCompactPassCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactPassCount: aValue [

	statCompactPassCount := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactionUsecs [

	^ statCompactionUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactionUsecs: aValue [

	<var: #aValue type: #usqLong>
	statCompactionUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFGCDeltaUsecs [

	^ statFGCDeltaUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFGCDeltaUsecs: aValue [

	<var: #aValue type: #usqLong>
	statFGCDeltaUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCUsecs [

	^ statFullGCUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCUsecs: aValue [

	<var: #aValue type: #usqLong>
	statFullGCUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCs [

	^ statFullGCs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCs: aValue [

	statFullGCs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statGCEndUsecs [

	^ statGCEndUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statGCEndUsecs: aValue [

	<var: #aValue type: #usqLong>
	statGCEndUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statGrowMemory [

	^ statGrowMemory
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statGrowMemory: aValue [

	statGrowMemory := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statIGCDeltaUsecs [

	^ statIGCDeltaUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statIGCDeltaUsecs: aValue [

	<var: #aValue type: #usqLong>
	statIGCDeltaUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMarkCount [

	^ statMarkCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMarkCount: aValue [

	statMarkCount := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMarkUsecs [

	^ statMarkUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMarkUsecs: aValue [

	<var: #aValue type: #usqLong>
	statMarkUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMaxAllocSegmentTime [

	^ statMaxAllocSegmentTime
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statMaxAllocSegmentTime: aValue [

	statMaxAllocSegmentTime := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statNumGCs [

	<export: true>
	^ statScavenges + statFullGCs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statRootTableCount [

	^ statRootTableCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statRootTableCount: aValue [

	statRootTableCount := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statRootTableOverflows [

	^ statRootTableOverflows
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statRootTableOverflows: aValue [

	statRootTableOverflows := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statSGCDeltaUsecs [

	^ statSGCDeltaUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statSGCDeltaUsecs: aValue [

	<var: #aValue type: #usqLong>
	statSGCDeltaUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statScavengeGCUsecs [

	^ statScavengeGCUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statScavengeGCUsecs: aValue [

	<var: #aValue type: #usqLong>
	statScavengeGCUsecs := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statScavenges [

	^ statScavenges
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statScavenges: aValue [

	statScavenges := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statShrinkMemory [

	^ statShrinkMemory
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statShrinkMemory: aValue [

	statShrinkMemory := aValue
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statSweepUsecs [

	^ statSweepUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statSweepUsecs: aValue [

	<var: #aValue type: #usqLong>
	statSweepUsecs := aValue
]
