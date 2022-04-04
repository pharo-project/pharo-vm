"
I am a class that helps organize the StackInterpreter's collection of stack pages.  I hold the set of stack pages represented by InterpreterStackPage instances/StackPage structs.  The pages are held in a doubly-linked list that notionally has two heads:

mostRecentlyUsedPage-->used page<->used page<->used page<->used page<--leastRecentlyUsedPage
                                       ^                        <-next-prev->                         ^
                                        |                                                                       |
                                        v                        <-prev-next->                         v
                                        free page<->free page<->free page<->free page

In fact we don't need the least-recently-used page, and so it is only present conceptually.  The point is that there is a possibly empty but contiguous sequence of free pages starting at mostRecentlyUsedPage nextPage.  New pages are allocated preferentially from the free page next to the MRUP.
If there are no free pages then (effectively) the LRUP's frames are flushed to contexts and it is used instead.

I have two concrete classes, one for the StackInterpreter and one for the CoInterpreter.

Instance Variables
	bytesPerPage:						<Integer>
	coInterpreter:						<StackInterpreter>
	mostRecentlyUsedPage:			<CogStackPage>
	objectMemory:						<ObjectMemory|SpurMemoryManager>
	overflowLimit:						<Integer>
	pages:								<Array of: CogStackPage>
	statNumMaps:						<Integer>
	statPageCountWhenMappingSum:		<Integer>

bytesPerPage
	- the size of a page in bytes

coInterpreter
	- the interpreter the receiver is holding pages for

mostRecentlyUsedPage
	- the most recently used stack page

objectMemory
	- the objectMemory of the interpreter

overflowLimit
	- the length in bytes of the portion of teh stack that can be used for frames before the page is judged to have overflowed

pages
	- the collection of stack pages the receiver is managing

statNumMaps
	- the number of mapStackPages calls

statPageCountWhenMappingSum:
	- the sum of the number of in use pages at each mapStackPages, used to estimate the average number of in use pages at scavenge, which heavily influences scavenger performance

"
Class {
	#name : #VMStackPages,
	#superclass : #VMClass,
	#instVars : [
		'coInterpreter',
		'objectMemory',
		'pages',
		'mostRecentlyUsedPage',
		'overflowLimit',
		'bytesPerPage',
		'statNumMaps',
		'statPageCountWhenMappingSum',
		'statMaxPageCountWhenMapping',
		'stackBasePlus1',
		'pageMap',
		'maxStackAddress',
		'minStackAddress'
	],
	#pools : [
		'VMBasicConstants'
	],
	#category : #'VMMaker-Interpreter'
}

{ #category : #translation }
VMStackPages class >> declareCVarsIn: aCCodeGenerator [
	aCCodeGenerator
		var: #mostRecentlyUsedPage type: #'StackPage *';
		var: #pages type: #'StackPage *'.
	aCCodeGenerator
		removeVariable: 'coInterpreter'; "These are simulation/debugging things only"
		removeVariable: 'objectMemory'; "These are simulation/debugging things only"
		var: #stackBasePlus1 type: #'char *';
		removeVariable: 'pageMap'; "These are simulation/debugging things only"
		removeVariable: 'maxStackAddress'; "These are simulation/debugging things only"
		removeVariable: 'minStackAddress' "These are simulation/debugging things only"		
]

{ #category : #assertions }
VMStackPages >> allPagesFree [
	<doNotGenerate>
	^pages allSatisfy: [:page| (self isFree: page)]
]

{ #category : #'memory access' }
VMStackPages >> byteAt: byteAddress [ "<Integer>" 
	self subclassResponsibility
]

{ #category : #assertions }
VMStackPages >> couldBeFramePointer: pointer [
	"Answer if the argument is a properly aligned pointer into the stack zone."
	<var: #pointer type: #'void *'>
	^(pointer asUnsignedInteger bitAnd: objectMemory wordSize - 1) = 0
	   and: [pointer asUnsignedInteger
				between: (stackBasePlus1 - 1) asUnsignedInteger
				and: (self cCode: [pages asUnsignedInteger]
							inSmalltalk: [(self stackPageAt: 0) asUnsignedInteger])]
]

{ #category : #initialization }
VMStackPages >> extraStackBytes [
	"See initializeStack:numSlots:pageSize:stackLimitOffset:stackPageHeadroom:
	``Because stack pages grow down...''"
	^objectMemory wordSize
]

{ #category : #'page access' }
VMStackPages >> freeStackPage: aPage [ "<InterpreterStackPage>"
	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"
	<var: #aPage type: #'StackPage *'>
	<inline: false>
	self freeStackPageNoAssert: aPage.
	self assert: self pageListIsWellFormed
]

{ #category : #'page access' }
VMStackPages >> freeStackPageNoAssert: aPage [ "<InterpreterStackPage>"
	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"
	<var: #aPage type: #'StackPage *'>
	<returnTypeC: #void>
	| prev |
	<var: #prev type: #'StackPage *'>
	aPage baseFP: 0.
	aPage == mostRecentlyUsedPage ifTrue:
		[mostRecentlyUsedPage := mostRecentlyUsedPage prevPage.
		 ^nil].
	(prev := aPage prevPage) isFree ifTrue:
		[^nil].
	prev nextPage: aPage nextPage.
	aPage nextPage prevPage: prev.
	aPage nextPage: mostRecentlyUsedPage nextPage.
	mostRecentlyUsedPage nextPage prevPage: aPage.
	aPage prevPage: mostRecentlyUsedPage.
	mostRecentlyUsedPage nextPage: aPage
]

{ #category : #initialization }
VMStackPages >> initialize [
	"Here we can initialize the variables C initializes to zero.  #initialize methods do /not/ get translated."
	statNumMaps := statPageCountWhenMappingSum := statMaxPageCountWhenMapping := 0
]

{ #category : #initialization }
VMStackPages >> initializeStack: theStackPages numSlots: stackSlots pageSize: slotsPerPage [
	"Initialize the stack pages.  In the C VM theStackPages will be alloca'ed memory to hold the
	 stack pages on the C stack.  In the simulator they are housed in the memory between the
	 cogMethodZone and the heap."

	<var: #theStackPages type: #'char *'>
	<returnTypeC: #void>
	| numPages page structStackPageSize pageStructBase count |
	<var: #page type: #'StackPage *'>
	<var: #pageStructBase type: #'char *'>

	structStackPageSize := coInterpreter sizeof: VMStackPage.
	bytesPerPage := slotsPerPage * objectMemory wordSize.
	numPages := coInterpreter numStkPages.

	"Because stack pages grow down baseAddress is at the top of a stack page and so to avoid
	 subtracting BytesPerWord from baseAddress and lastAddress in the init loop below we simply
	 push the stackPage array up one word to avoid the overlap.  This word is extraStackBytes."
	pageStructBase := theStackPages + (numPages * bytesPerPage) + objectMemory wordSize.
	
	pages := self cCode: [self cCoerceSimple: pageStructBase to: #'StackPage *']
				  inSmalltalk:
					[pageMap := Dictionary new.
					 ((0 to: numPages - 1) collect:
						[:i|
						 VMStackPage surrogateClass new
							address: pageStructBase + (i * structStackPageSize)
							simulator: coInterpreter
							zoneBase: minStackAddress
							zoneLimit: maxStackAddress])
						do: [:pageSurrogate|
							pageMap at: pageSurrogate address put: pageSurrogate];
						yourself].
	"make sure there's enough headroom"
	self assert: coInterpreter stackPageByteSize - coInterpreter stackLimitBytes - coInterpreter stackLimitOffset
				>= coInterpreter stackPageHeadroom.
	0 to: numPages - 1 do:
		[:index|
		 page := self stackPageAt: index.
		 page
			lastAddress: theStackPages + (index * bytesPerPage);
			baseAddress: page lastAddress + bytesPerPage;
			stackLimit: page baseAddress - coInterpreter stackLimitBytes;
			realStackLimit: page stackLimit;
			baseFP: 0;
			nextPage: (self stackPageAt: (index = (numPages - 1) ifTrue: [0] ifFalse: [index + 1]));
			prevPage: (self stackPageAt: (index = 0 ifTrue: [numPages - 1] ifFalse: [index - 1]))].

	"Now compute stackBasePlus1 so that the pageIndexFor: call maps all addresses from
	 aPage baseAddress to aBase limitAddress + 1 to the same index (stacks grow down)"
	stackBasePlus1 := (self cCoerceSimple: theStackPages to: #'char *') + 1.

	"The overflow limit is the amount of stack to retain when moving frames from an overflowing
	 stack to reduce thrashing.  See stackOverflowOrEvent:mayContextSwitch:"
	page := self stackPageAt: 0.
	overflowLimit := page baseAddress - page realStackLimit * 3 // 5.
	0 to: numPages - 1 do:
		[:index|
		 page := self stackPageAt: index.
		 self assert: (self pageIndexFor: page baseAddress) == index.
		 self assert: (self pageIndexFor: page baseAddress - (slotsPerPage - 1 * objectMemory wordSize)) == index.
		 self assert: (self stackPageFor: page baseAddress) == page.
		 self assert: (self stackPageFor: page stackLimit) == page.
		 self cCode: []
			inSmalltalk:
				[| memIndex |
				 memIndex := index * slotsPerPage + 1. "this is memIndex in the block above"
				 self assert: (self memIndexFor: (self oopForPointer: page baseAddress))
							== (memIndex + slotsPerPage - 1).
				 index < (numPages - 1) ifTrue:
					[self assert: (self stackPageFor: page baseAddress + objectMemory wordSize) == (self stackPageAt: index + 1)]].
		coInterpreter initializePageTraceToInvalid: page].

	mostRecentlyUsedPage := self stackPageAt: 0.
	page := mostRecentlyUsedPage.
	count := 0.
	[| theIndex |
	 count := count + 1.
	 theIndex := self pageIndexFor: page baseAddress.
	 self assert: (self stackPageAt: theIndex) == page.
	 self assert: (self pageIndexFor: page baseAddress) == theIndex.
	 self assert: (self pageIndexFor: page stackLimit) == theIndex.
	 self assert: (self pageIndexFor: page lastAddress + 1) == theIndex.
	 (page := page nextPage) ~= mostRecentlyUsedPage] whileTrue.
	self assert: count == numPages.
	self assert: self pageListIsWellFormed
]

{ #category : #initialization }
VMStackPages >> initializeWithByteSize: byteSize "<Integer>" for: anInterpreter [ "<CoInterpreter>" "^<Array of: <Integer>"
	"Initialize the stackPages memory for simulation.  To keep access monitoring
	 in one place we defer to the coInterpreter for accessing memory.  Answer the
	 base address of th ememory."
	<doNotGenerate>
	coInterpreter := anInterpreter.
	objectMemory := coInterpreter objectMemory.
		
	minStackAddress := objectMemory memoryManager allocate: byteSize.
	maxStackAddress := minStackAddress + byteSize.
	
	^ minStackAddress 
]

{ #category : #'page access' }
VMStackPages >> isFree: thePage [
	"This is an anachronism.  Previously Slang couldn't generate the method correctly
	 from e.g. CogStackPageSurrogate>>isFree since Slang didn't do substitution on self.
	 Now it does, but there are still callers of isFree: so we keep this for simulation."
	<doNotGenerate>
	^thePage baseFP = 0
]

{ #category : #'memory access' }
VMStackPages >> longAt: byteAddress [
	<doNotGenerate>
	"Note: Adjusted for Smalltalk's 1-based array indexing."
	self assert: (byteAddress >= minStackAddress and: [byteAddress < maxStackAddress]).
	^objectMemory longAt: byteAddress
]

{ #category : #'memory access' }
VMStackPages >> longAt: byteAddress put: a32Or64BitValue [
	<doNotGenerate>
	self assert: (byteAddress >= minStackAddress and: [byteAddress < maxStackAddress]).
	^objectMemory longAt: byteAddress put: a32Or64BitValue
]

{ #category : #'page access' }
VMStackPages >> markStackPageLeastMostRecentlyUsed: page [ "<InterpreterStackPage>"
	"This method is used to move a page to the end of the used pages.
	 This is to keep asserts checking pageListIsWellFormed happy."

	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"

	<var: #page type: #'StackPage *'>
	<returnTypeC: #void>
	| lastUsedPage |
	<var: #lastUsedPage type: #'StackPage *'>
	self assert: page = mostRecentlyUsedPage nextPage.
	lastUsedPage := page nextPage.
	[lastUsedPage isFree] whileTrue:
		[lastUsedPage := lastUsedPage nextPage].
	lastUsedPage nextPage = page ifTrue:
		[^nil].
	page prevPage nextPage: page nextPage.
	page nextPage prevPage: page prevPage.
	lastUsedPage prevPage nextPage: page.
	page prevPage: lastUsedPage prevPage.
	page nextPage: lastUsedPage.
	lastUsedPage prevPage: page.
	self assert: self pageListIsWellFormed
]

{ #category : #'page access' }
VMStackPages >> markStackPageMostRecentlyUsed: page [ "<InterpreterStackPage>"
	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"
	<var: #page type: #'StackPage *'>
	<returnTypeC: #void>
	page == mostRecentlyUsedPage ifTrue:
		[^nil].
	"Common case; making new page most recently used."
	page prevPage == mostRecentlyUsedPage ifTrue:
		[mostRecentlyUsedPage := page.
		 self assert: self pageListIsWellFormed.
		 ^nil].
	page prevPage nextPage: page nextPage.
	page nextPage prevPage: page prevPage.
	mostRecentlyUsedPage nextPage prevPage: page.
	page prevPage: mostRecentlyUsedPage.
	page nextPage: mostRecentlyUsedPage nextPage.
	mostRecentlyUsedPage nextPage: page.
	mostRecentlyUsedPage := page.
	self assert: self pageListIsWellFormed
]

{ #category : #'page access' }
VMStackPages >> markStackPageNextMostRecentlyUsed: page [ "<InterpreterStackPage>"
	"This method is used to move a page to a position in the list such that it cannot
	 be deallocated when a new page is allocated, without changing the most recently
	 used page.  There must be at least 3 pages in the system.  So making the page
	 the MRU's prevPage is sufficient to ensure it won't be deallocated."

	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"

	<var: #page type: #'StackPage *'>
	<returnTypeC: #void>
	self assert: page ~~ mostRecentlyUsedPage.
	page nextPage == mostRecentlyUsedPage ifTrue:
		[^nil].
	page prevPage nextPage: page nextPage.
	page nextPage prevPage: page prevPage.
	mostRecentlyUsedPage prevPage nextPage: page.
	page prevPage: mostRecentlyUsedPage prevPage.
	page nextPage: mostRecentlyUsedPage.
	mostRecentlyUsedPage prevPage: page.
	self assert: self pageListIsWellFormed
]

{ #category : #'page access' }
VMStackPages >> memIndexFor: byteAddress [
	"Map an address into the stack zone into a word index into the slots in the stack zone."
	<doNotGenerate>
	^(self oopForPointer: byteAddress) - minStackAddress - 1 // objectMemory wordSize + 1
]

{ #category : #'as yet unclassified' }
VMStackPages >> minStackAddress [
	<doNotGenerate>
	^ minStackAddress
]

{ #category : #'page access' }
VMStackPages >> mostRecentlyUsedPage [
	<cmacro: '() GIV(mostRecentlyUsedPage)'>
	<returnTypeC: #'StackPage *'> "this is to guide Slang's inliner"
	^mostRecentlyUsedPage
]

{ #category : #'page access' }
VMStackPages >> newStackPage [
	"MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"
	<returnTypeC: #'StackPage *'>
	| lruOrFree |
	<var: #lruOrFree type: #'StackPage *'>
	lruOrFree := mostRecentlyUsedPage nextPage.
	lruOrFree isFree ifTrue:
		[^lruOrFree].
	coInterpreter divorceFramesIn: lruOrFree.
	^lruOrFree
]

{ #category : #'page access' }
VMStackPages >> overflowLimit [
	^overflowLimit
]

{ #category : #'page access' }
VMStackPages >> pageIndexFor: pointer [ "<Integer>"
	"Answer the page index for a pointer into stack memory, i.e. the index
	 for the page the address is in.  N.B.  This is a zero-relative index."
	<var: #pointer type: #'void *'>
	<inline: true>
	self assert: ((self cCoerceSimple: pointer to: #'char *')
					between: stackBasePlus1 - 1
					and: (self cCode: [self cCoerceSimple: pages to: #'char *']
							inSmalltalk: [(self stackPageAt: 0) asInteger])).
	^self pageIndexFor: pointer stackBasePlus1: stackBasePlus1 bytesPerPage: bytesPerPage
]

{ #category : #'page access' }
VMStackPages >> pageIndexFor: pointer "<Integer>" stackBasePlus1: stkBasePlus1 "<Integer>" bytesPerPage: pageByteSize [ "<Integer>"
	"Answer the page index for a pointer into stack memory, i.e. the index
	 for the page the address is in.  N.B.  This is a zero-relative index."
	<cmacro: '(pointer,stkBasePlus1,pageByteSize) (((char *)(pointer) - (stkBasePlus1)) / (pageByteSize))'>
	^pointer - stkBasePlus1 // pageByteSize
]

{ #category : #assertions }
VMStackPages >> pageListIsWellFormed [
	"Answer if the stack page list is well-formed.
	 MRUP-->used page<->used page<->used page<->used page<--LRUP
	               ^                        <-next-prev->                         ^
	                |                                                                       |
	                v                        <-prev-next->                         v
	                free page<->free page<->free page<->free page"
	| ok page count limit |
	<inline: false>
	<var: #page type: #'StackPage *'>
	ok := true.
	page := mostRecentlyUsedPage nextPage.
	count := 1.
	limit := coInterpreter numStkPages * 2.
	[page isFree
	 and: [page ~= mostRecentlyUsedPage
	 and: [count <= limit]]] whileTrue:
		[(self asserta: page nextPage prevPage == page) ifFalse:
			[ok := false].
		 page := page nextPage.
		 count := count + 1].
	[page ~= mostRecentlyUsedPage
	 and: [count <= limit]] whileTrue:
		[(self asserta: page nextPage prevPage == page) ifFalse:
			[ok := false].
		 (self asserta: page isFree not)
			ifTrue:
				[(self asserta: ((page addressIsInPage: page baseFP)
								and: [page addressIsInPage: page headSP])) ifFalse:
					[ok := false]]
			ifFalse:
				[ok := false].
		 page := page nextPage.
		 count := count + 1].
	(self asserta: count = coInterpreter numStkPages) ifFalse:
		[ok := false].
	^ok
]

{ #category : #accessing }
VMStackPages >> pages [
	<doNotGenerate>
	^pages
]

{ #category : #statistics }
VMStackPages >> recordLivePagesOnMapping: numLivePages [
	<inline: true>
	statNumMaps := statNumMaps + 1.
	statPageCountWhenMappingSum := statPageCountWhenMappingSum + numLivePages.
	statMaxPageCountWhenMapping := statMaxPageCountWhenMapping max: numLivePages
]

{ #category : #initialization }
VMStackPages >> setInterpreter: anInterpreter [
	"Initialize the stackPages memory for simulation.  To keep access monitoring
	 in one place we defer to the coInterpreter for accessing memory."
	<doNotGenerate>
	coInterpreter := anInterpreter.
	objectMemory := coInterpreter objectMemory
]

{ #category : #assertions }
VMStackPages >> somePageHasHeadFrameFP: theFP [
	<doNotGenerate>
	^pages anySatisfy: [:page| page headFP = theFP]

]

{ #category : #'page access' }
VMStackPages >> stackPageAt: index [
	"Answer the page for a page index.
	 N.B.  This is a zero-relative index."
	<returnTypeC: #'StackPage *'>
	<inline: true>
	^self stackPageAt: index pages: pages
]

{ #category : #'page access' }
VMStackPages >> stackPageAt: index pages: thePages [
	"Answer the page for a page index.
	 N.B.  This is a zero-relative index."
	<cmacro: '(index,pages) ((pages) + (index))'>
	<returnTypeC: #'StackPage *'> "for Slang..."
	^thePages at: index + 1
]

{ #category : #'page access' }
VMStackPages >> stackPageFor: pointer [ "<Integer>"
	<inline: true>
	<var: #pointer type: #'void *'>
	<returnTypeC: #'StackPage *'>
	^self stackPageAt: (self pageIndexFor: pointer)
]

{ #category : #statistics }
VMStackPages >> statAverageLivePagesWhenMapping [
	<returnTypeC: #double>
	^statNumMaps = 0
		ifTrue: [0.0]
		ifFalse: [statPageCountWhenMappingSum asFloat / statNumMaps]
]

{ #category : #statistics }
VMStackPages >> statAverageLivePagesWhenMapping: aFloat [
	<var: #aFloat type: #double>
	aFloat == 0.0
		ifTrue: [statPageCountWhenMappingSum := statNumMaps := 0]
		ifFalse: [coInterpreter primitiveFailFor: PrimErrBadArgument]
]

{ #category : #statistics }
VMStackPages >> statMaxPageCountWhenMapping [
	<cmacro: '() GIV(statMaxPageCountWhenMapping)'>
	^statMaxPageCountWhenMapping
]

{ #category : #statistics }
VMStackPages >> statMaxPageCountWhenMapping: num [
	statMaxPageCountWhenMapping := num
]

{ #category : #accessing }
VMStackPages >> surrogateAtAddress: anAddress [
	<doNotGenerate>
	^pageMap at: anAddress
]

{ #category : #'debug printing' }
VMStackPages >> whereIsMaybeStackThing: anOop [
	"If anOop is an address within the stack zone answer a string stating that, otherwise answer nil."
	<returnTypeC: 'char *'>
	(self oop: anOop
		isGreaterThanOrEqualTo: (stackBasePlus1 - 1)
		andLessThan: (self cCode: [pages]
							inSmalltalk: [(self stackPageAt: 0) asUnsignedInteger])) ifTrue:
		[^' is in the stack zone'].
	^nil
]
