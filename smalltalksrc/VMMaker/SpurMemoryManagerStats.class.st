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

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementCoalesces [

	statCoalesces := statCoalesces + 1
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementCompactionUsecsBy: usecs [

	<var: #usecs type: #usqLong>
	statCompactionUsecs := statCompactionUsecs + usecs
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementFullGCUsecsBy: usecs [

	<var: #usecs type: #usqLong>
	statFullGCUsecs := statFullGCUsecs + usecs
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementFullGCs [

	statFullGCs := statFullGCs + 1
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementGrowMemory [

	statGrowMemory := statGrowMemory + 1
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementMarkUsecsBy: usecs [

	<var: #usecs type: #usqLong>
	statMarkUsecs := statMarkUsecs + usecs
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementScavengeGCUsecsBy: usecs [

	<var: #usecs type: #usqLong>
	statScavengeGCUsecs := statScavengeGCUsecs + usecs
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementScavenges [

	statScavenges := statScavenges + 1
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementShrinkMemory [

	statShrinkMemory := statShrinkMemory + 1
]

{ #category : 'updating' }
SpurMemoryManagerStats >> incrementSweepUsecsBy: usecs [

	<var: #usecs type: #usqLong>
	statSweepUsecs := statSweepUsecs + usecs
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
SpurMemoryManagerStats >> statCompMoveCount [
	"Spur never compacts by moving; but it does make compaction passes."

	^ statCompactPassCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactPassCount [

	^ statCompactPassCount
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statCompactionUsecs [

	^ statCompactionUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFGCDeltaUsecs [

	^ statFGCDeltaUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCUsecs [

	^ statFullGCUsecs
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statFullGCs [

	^ statFullGCs
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
SpurMemoryManagerStats >> statIGCDeltaUsecs [

	^ statIGCDeltaUsecs
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
SpurMemoryManagerStats >> statScavenges [

	^ statScavenges
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statShrinkMemory [

	^ statShrinkMemory
]

{ #category : 'accessing' }
SpurMemoryManagerStats >> statSweepUsecs [

	^ statSweepUsecs
]

{ #category : 'updating' }
SpurMemoryManagerStats >> updateFullGCStatsStartUsecs: startUsecs markEndUsecs: markEndUsecs compactionStartUsecs: compactionStartTime sweepEndUsecs: sweepEndUsecs [
	"Stats updated (since VM start-up): 
	1) number of full GCs,
	2) time spent in full GC,
	3) time spent in compaction (included in 2)
	4) time spent in sweep phase (included in 2 & 3, 0 if no sweep phase)
	5) time spent in mark phase (included in 2)"

	<var: #startUsecs type: #usqLong>
	<var: #markEndUsecs type: #usqLong>
	<var: #compactionStartTime type: #usqLong>
	<var: #sweepEndUsecs type: #usqLong>
	self incrementFullGCs.
	self incrementFullGCUsecsBy: statGCEndUsecs - startUsecs.
	self incrementCompactionUsecsBy: statGCEndUsecs - compactionStartTime.
	sweepEndUsecs = 0 ifFalse: [
		self incrementSweepUsecsBy: sweepEndUsecs - compactionStartTime ].
	self incrementMarkUsecsBy: markEndUsecs - startUsecs
]
