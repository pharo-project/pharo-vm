Class {
	#name : 'VMMemoryMapConfiguration',
	#superclass : 'VMClass',
	#category : 'VMMaker-Memory',
	#package : 'VMMaker',
	#tag : 'Memory'
}

{ #category : 'instance-creation' }
VMMemoryMapConfiguration class >> forWordsize: anInteger [

	anInteger = 8 ifTrue: [ ^ VMMemoryMapConfigurationFor64Bits ].

	^ VMMemoryMapConfigurationFor32Bits
]

{ #category : 'testing' }
VMMemoryMapConfiguration class >> isAbstract [
		
	^ self == VMMemoryMapConfiguration
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> codeZoneInitialAddress [

	^ self subclassResponsibility 
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> confWordSize [

	^ self subclassResponsibility
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> newSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> oldSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> permSpaceInitialAddress [

	^ self subclassResponsibility 
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> stackPagesInitialAddress [

	^ self subclassResponsibility 
]
