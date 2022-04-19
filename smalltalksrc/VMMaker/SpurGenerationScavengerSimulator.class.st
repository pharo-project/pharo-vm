Class {
	#name : #SpurGenerationScavengerSimulator,
	#superclass : #SpurGenerationScavenger,
	#instVars : [
		'cameFrom'
	],
	#category : #'VMMaker-SpurMemoryManagerSimulation'
}

{ #category : #accessing }
SpurGenerationScavengerSimulator >> cameFrom [

	^ cameFrom
]

{ #category : #accessing }
SpurGenerationScavengerSimulator >> cameFrom: anObject [

	cameFrom := anObject
]

{ #category : #scavenger }
SpurGenerationScavengerSimulator >> copyAndForward: survivor [
	| relocatedOop |
	relocatedOop := super copyAndForward: survivor.
	cameFrom ifNotNil:
		[cameFrom at: relocatedOop put: survivor].
	^relocatedOop
]

{ #category : #scavenger }
SpurGenerationScavengerSimulator >> copyAndForwardMourner: survivor [
	| relocatedOop |
	relocatedOop := super copyAndForwardMourner: survivor.
	cameFrom ifNotNil:
		[cameFrom at: relocatedOop put: survivor].
	^relocatedOop
]

{ #category : #initialization }
SpurGenerationScavengerSimulator >> manager: aSpurNBitMMXEndianSimulator [
	manager := aSpurNBitMMXEndianSimulator.
	aSpurNBitMMXEndianSimulator coInterpreter ifNotNil:
		[:coint| coInterpreter := coint]
]

{ #category : #scavenger }
SpurGenerationScavengerSimulator >> recordMovements [
	cameFrom := Dictionary new
]

{ #category : #accessing }
SpurGenerationScavengerSimulator >> rememberedSet [

	^ rememberedSet
]
