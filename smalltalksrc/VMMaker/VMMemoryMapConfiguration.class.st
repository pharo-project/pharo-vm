Class {
	#name : #VMMemoryMapConfiguration,
	#superclass : #VMClass,
	#category : #'VMMaker-Memory'
}

{ #category : #'instance-creation' }
VMMemoryMapConfiguration class >> forWordsize: anInteger [

	anInteger = 8 ifTrue: [ ^ VMMemoryMapConfigurationFor64Bits ].

	^ VMMemoryMapConfigurationFor32Bits
]

{ #category : #testing }
VMMemoryMapConfiguration class >> isAbstract [
		
	^ self == VMMemoryMapConfiguration
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> calculateMaskToUse [

	| newSpaceFirst newSpaceLast newSpaceMask oldSpaceFirst oldSpaceLast oldSpaceMask maskToUse |

	newSpaceFirst := self newSpaceInitialAddress.
	newSpaceLast := self oldSpaceInitialAddress - 1.
	newSpaceMask := (newSpaceLast - newSpaceFirst) bitXor: (1 << (self confWordSize * 8)) - 1.

	oldSpaceFirst := self oldSpaceInitialAddress.
	oldSpaceLast := self permSpaceInitialAddress - 1.
	oldSpaceMask := (oldSpaceLast - oldSpaceFirst) bitXor: (1 << (self confWordSize * 8)) - 1.

	maskToUse := newSpaceMask bitAnd: oldSpaceMask.
	maskToUse = 0 ifTrue: [ self error: 'Could not calculate mask to use to identify new/old/perm objects' ].
	
	^ maskToUse
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> codeZoneInitialAddress [

	^ self subclassResponsibility 
]

{ #category : #accessing }
VMMemoryMapConfiguration >> confWordSize [

	^ self subclassResponsibility
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> newSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> oldSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> permSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : #'initial addresses' }
VMMemoryMapConfiguration >> stackPagesInitialAddress [

	^ self subclassResponsibility 
]
