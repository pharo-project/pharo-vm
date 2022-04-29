Class {
	#name : #VMSimulatedEnvironmentBuilder,
	#superclass : #Object,
	#instVars : [
		'interpreter',
		'interpreterClass',
		'initializationOptions',
		'objectMemory',
		'objectMemoryClass',
		'wordSize',
		'initialCodeSize',
		'primitiveTraceLogSize',
		'oldSpaceSize',
		'initialAddress',
		'stackSpaceSize',
		'methodCacheSize',
		'newSpaceSize',
		'permSpaceSize'
	],
	#category : #'VMMakerTests-Builders'
}

{ #category : #building }
VMSimulatedEnvironmentBuilder >> build [
	
	objectMemory := objectMemoryClass simulatorClass new.
	
	interpreterClass
		initializeWithOptions: initializationOptions
		objectMemoryClass: objectMemory class.

	interpreter := interpreterClass basicNew
		  objectMemory: objectMemory;
		  basicInitialize.
		
	self doBuild
]

{ #category : #building }
VMSimulatedEnvironmentBuilder >> doBuild [

	"100 k at least to put the class table in the old space.
	Get total size be a multiple of 4K so Unicorn CPU emulator accepts it"
	| memoryManager edenSize |

	"Check #scavengerDenominator in SpurMemoryManager"
	edenSize := 2 * 1024 + interpreter interpreterAllocationReserveBytes.
 	newSpaceSize := self roundToPageSize: (edenSize * 7 / 5).
	stackSpaceSize := 9 * 4096.
	methodCacheSize := 4096 * wordSize.
	
	initialAddress := 16r1000000.
		
	"Set it to bootstrapping to allow smaller memories"
	memoryManager := MachineSimulatorMemoryManager new.
	memoryManager initialAddress: initialAddress.
	memoryManager wordSize: wordSize.
		
	interpreter memoryManager: memoryManager.
	objectMemory memoryManager: memoryManager.
	objectMemory ensureMemoryMap.
	
	objectMemory coInterpreter: interpreter.
	
	objectMemory
		allocateMemoryOfSize: oldSpaceSize
		newSpaceSize: newSpaceSize
		stackSize: stackSpaceSize
		codeSize: initialCodeSize
		methodCacheSize: methodCacheSize
		primitiveTraceLogSize: (self roundToPageSize: primitiveTraceLogSize)
		rumpCStackSize: self rumpCStackSize
		initialAddress: initialAddress
		permSpaceSize: permSpaceSize.
			
	objectMemory initializePostBootstrap.
	objectMemory setHeapSizeAtPreviousGC.

	self assert: objectMemory objectMemory scavenger eden size > interpreter interpreterAllocationReserveBytes.
	self assert: objectMemory objectMemory scavengeThreshold + interpreter interpreterAllocationReserveBytes <= objectMemory objectMemory scavenger eden limit.

	objectMemory segmentManager collapseSegmentsPostSwizzle.
	objectMemory segmentManager plantBridgeAtTheEndOfMemory.
	objectMemory segmentManager assertBridge.
	
	"Schedule a GC, so it does not try to schedule one"
	objectMemory needGCFlag: 1.

]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> initialCodeSize: anInteger [ 
	initialCodeSize := anInteger
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> initializationOptions: aCollection [ 
	initializationOptions := aCollection
]

{ #category : #initialization }
VMSimulatedEnvironmentBuilder >> initialize [

	super initialize.
	oldSpaceSize := 2048 * 1024.
	permSpaceSize := 0.
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> interpreter [
	^ interpreter
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> interpreterClass: aClass [ 
	interpreterClass := aClass
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> memoryInitialAddress [

	^ initialAddress 
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> methodCacheSize [
	^ methodCacheSize
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> newSpaceSize [
	^ newSpaceSize
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> objectMemory [
	^ objectMemory
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> objectMemoryClass: aClass [ 
	objectMemoryClass := aClass
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> oldSpaceSize [
	^ oldSpaceSize
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> permSpaceSize: anInteger [ 
	permSpaceSize := anInteger
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> primitiveTraceLogSize: anInteger [ 
	primitiveTraceLogSize := anInteger
]

{ #category : #helpers }
VMSimulatedEnvironmentBuilder >> roundToPageSize: anInteger [ 

	"Unicorn simulator requires mapped memory to be multiple of 4096"
	| pageSize remainder |
	pageSize := 4096.
	remainder := anInteger \\ pageSize.
	remainder = 0 ifTrue: [ ^ anInteger ].

	^ anInteger + (pageSize - remainder)
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> rumpCStackSize [

	^ 4096.


]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> stackSpaceSize [
	^ stackSpaceSize
]

{ #category : #accessing }
VMSimulatedEnvironmentBuilder >> wordSize: anInteger [ 
	wordSize := anInteger
]
